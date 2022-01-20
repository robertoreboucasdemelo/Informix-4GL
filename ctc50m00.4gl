############################################################################3
# Nome do Modulo: ctc50m00                                                  #
#                                                                           #
# Cadastro de cidades, que funcionarao de acordo com o grupo de acionamento #
#                                                                           #
# Data: 08/12/00                                                            #
#############################################################################

# ..........................................................................#
#                                                                           #
#                      * * * Alteracoes * * *                               #
#                                                                           #
# Data       Autor Fabrica   Origem        Alteracao                        #
# ---------- --------------  ----------    ---------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao                # 
#                                          "fun_dba_abre_banco" e troca da  #
#                                          "systables" por "dual"           #
#---------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso  #
#---------------------------------------------------------------------------#
# 31/01/2007  Burini                   Corrigir validação de cidade         #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#main
#   call ctc50m00()
#end main
  define am_origens array[30] of record
    atdsrvorg      like datrorgcidacntip.atdsrvorg,
    gpsacngrpcod   like datrorgcidacntip.gpsacngrpcod,
    gpsacngrpdes   like datkacngrp.gpsacngrpdes
  end record

#---------------------------#
 function ctc50m00_prepare()
#---------------------------# 
     
     define l_sql char(300)
     
     let l_sql = " select distinct 1 ",
                   " from glakcid ", 
                  " where cidnom = ? ",
                    " and ufdcod = ? "
                    
     prepare pcctc50m00_01 from l_sql
     declare cqctc50m00_01 cursor for pcctc50m00_01
     
     let l_sql = " select mpacidcod ",
                   " from datkmpacid ",
                  " where datkmpacid.lclltt = ? ",
                    " and datkmpacid.lcllgt = ? "
                    
     prepare pcctc50m00_02 from l_sql
     declare cqctc50m00_02 cursor for pcctc50m00_02 
     
     let l_sql = " select atdsrvorg, gpsacngrpcod ",
                   " from datrorgcidacntip ",
                  " where mpacidcod = ? ", 
                  " order by atdsrvorg asc"
                  
                    
     prepare pcctc50m00_03 from l_sql
     declare cqctc50m00_03 cursor for pcctc50m00_03
                         

 end function

#------------------------------------------------------------
 function ctc50m00()
#------------------------------------------------------------

 define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkmpacid.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record
 

 
 
 let int_flag = false
 initialize d_ctc50m00.*  to null

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc50m00") then
    #error " Modulo sem nivel de consulta e atualizacao!"
    #return
 #end if

 call ctc50m00_prepare()
 
 open window ctc50m00 at 4,2 with form "ctc50m00"

 menu "CIDADES"

  before menu
     hide option all
     show option all
     #PSI 202290
     #if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #   show option "Seleciona", "Proximo", "Anterior",
     #               "pesQuisa"
     #end if
     #if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"  ,
                    "pesQuisa"
     #end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa cidade conforme criterios"
          call ctc50m00_seleciona(d_ctc50m00.mpacidcod)
               returning d_ctc50m00.*
          if d_ctc50m00.mpacidcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma cidade selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima cidade selecionada"
          message ""
          call ctc50m00_proximo(d_ctc50m00.mpacidcod)
               returning d_ctc50m00.*

 command key ("A") "Anterior"
                   "Mostra cidade anterior selecionado"
          message ""
          if d_ctc50m00.mpacidcod is not null then
             call ctc50m00_anterior(d_ctc50m00.mpacidcod)
                  returning d_ctc50m00.*
          else
             error " Nenhuma cidade nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica cidade selecionada"
          message ""
          if d_ctc50m00.mpacidcod  is not null then
             call ctc50m00_modifica(d_ctc50m00.mpacidcod, d_ctc50m00.*)
                  returning d_ctc50m00.*
             next option "Seleciona"
          else
             error " Nenhuma cidade selecionada!"
             next option "Seleciona"
          end if
          initialize d_ctc50m00.*  to null

 command key ("I") "Inclui"
                   "Inclui cidade"
          message ""
          call ctc50m00_inclui()
          next option "Seleciona"
          initialize d_ctc50m00.*  to null

 command key ("Q") "pesQuisa"
                   "Pesquisa cidade por: uf/cidade"
          message ""
          initialize d_ctc50m00.*  to null
          display by name d_ctc50m00.*

          call ctc50m01() returning d_ctc50m00.mpacidcod
          next option "Seleciona"

   command "Remove" "Remove cidade selecionada"
            message ""
            if d_ctc50m00.mpacidcod  is not null   then
               call ctc50m00_remove(d_ctc50m00.*)
                    returning d_ctc50m00.*
               next option "Seleciona"
            else
               error " Nenhuma cidade selecionada!"
               next option "Seleciona"
            end if
          initialize d_ctc50m00.*  to null

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc50m00

 end function  # ctc50m00


#------------------------------------------------------------
 function ctc50m00_seleciona(param)
#------------------------------------------------------------

 define param         record
    mpacidcod         like datkmpacid.mpacidcod
 end record

 define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkmpacid.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record


 let int_flag = false
 initialize d_ctc50m00.*  to null
 let d_ctc50m00.mpacidcod  =  param.mpacidcod

 display by name d_ctc50m00.*

 input by name d_ctc50m00.mpacidcod  without defaults

    before field mpacidcod

        display by name d_ctc50m00.mpacidcod attribute (reverse)

    after  field mpacidcod
        display by name d_ctc50m00.mpacidcod

        if d_ctc50m00.mpacidcod  is null   then
           error " Cidade deve ser informada!"
           next field mpacidcod
        end if

        select mpacidcod
          from datkmpacid
         where datkmpacid.mpacidcod = d_ctc50m00.mpacidcod

        if sqlca.sqlcode  =  notfound   then
           error " Cidade nao cadastrada!"
           next field mpacidcod       
        end if
        

    on key (interrupt)
        exit input   
    	
    
        
        
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc50m00.*   to null
    display by name d_ctc50m00.*
    error " Operacao cancelada!"
    return d_ctc50m00.*
 end if

 call ctc50m00_ler(d_ctc50m00.mpacidcod)
      returning d_ctc50m00.*

 if d_ctc50m00.mpacidcod  is not null   then
    display by name  d_ctc50m00.*
 else
    error " Cidade nao cadastrada!"
    initialize d_ctc50m00.*    to null
 end if

 return d_ctc50m00.*

 end function  # ctc50m00_seleciona

#------------------------------------------------------------
 function ctc50m00_proximo(param)
#------------------------------------------------------------

 define param         record
    mpacidcod         like datkmpacid.mpacidcod
 end record

 define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkmpacid.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record

 let int_flag = false
 initialize d_ctc50m00.*   to null

 if param.mpacidcod  is null   then
    let param.mpacidcod = 0
 end if

 select min(datkmpacid.mpacidcod)
   into d_ctc50m00.mpacidcod
   from datkmpacid
  where datkmpacid.mpacidcod  >  param.mpacidcod

 if d_ctc50m00.mpacidcod  is not null   then

    call ctc50m00_ler(d_ctc50m00.mpacidcod)
         returning d_ctc50m00.*

    if d_ctc50m00.mpacidcod  is not null   then
       display by name d_ctc50m00.*
    else
       error " Nao ha' cidade nesta direcao!"
       initialize d_ctc50m00.*    to null
    end if
 else
    error " Nao ha' cidade nesta direcao!"
    initialize d_ctc50m00.*    to null
 end if

 return d_ctc50m00.*

 end function    # ctc50m00_proximo


#------------------------------------------------------------
 function ctc50m00_anterior(param)
#------------------------------------------------------------

 define param         record
    mpacidcod         like datkmpacid.mpacidcod
 end record

 define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkmpacid.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record

 let int_flag = false
 initialize d_ctc50m00.*  to null

 if param.mpacidcod  is null   then
    let param.mpacidcod = 0
 end if

 select max(datkmpacid.mpacidcod)
   into d_ctc50m00.mpacidcod
   from datkmpacid
  where datkmpacid.mpacidcod <  param.mpacidcod

 if d_ctc50m00.mpacidcod is not null   then

    call ctc50m00_ler(d_ctc50m00.mpacidcod)
         returning d_ctc50m00.*

    if d_ctc50m00.mpacidcod  is not null   then
       display by name  d_ctc50m00.*
    else
       error " Nao ha' cidade nesta direcao!"
       initialize d_ctc50m00.*    to null
    end if
 else
    error " Nao ha' cidade nesta direcao!"
    initialize d_ctc50m00.*    to null
 end if

 return d_ctc50m00.*

 end function    # ctc50m00_anterior


#------------------------------------------------------------
 function ctc50m00_modifica(param, d_ctc50m00)
#------------------------------------------------------------

 define param         record
    mpacidcod         like datkmpacid.mpacidcod
 end record

 define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkacngrp.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record

 call ctc50m00_input("a", d_ctc50m00.*) returning d_ctc50m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc50m00.*  to null
    display by name d_ctc50m00.*
    error " Operacao cancelada!"    
    return d_ctc50m00.*
 end if
 
 display "                              " at 17,01
 
 whenever error continue


 begin work
    update datkmpacid    set  ( ufdcod,
                                cidnom,
                                lclltt,
                                lcllgt,
                                gpsacngrpcod)
                           =  ( d_ctc50m00.ufdcod,
                                d_ctc50m00.cidnom,
                                d_ctc50m00.lclltt,
                                d_ctc50m00.lcllgt,
                                d_ctc50m00.gpsacngrpcod)
           where datkmpacid.mpacidcod    = param.mpacidcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao da cidade!"
       rollback work
       initialize d_ctc50m00.*   to null
       return d_ctc50m00.*
    else
       sleep(4)
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc50m00.*  to null
 display by name d_ctc50m00.*
 message ""
 return d_ctc50m00.*

 end function   #  ctc50m00_modifica


#------------------------------------------------------------
 function ctc50m00_inclui()
#------------------------------------------------------------

 define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkacngrp.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record

 define  ws_resp      char(01)


 initialize d_ctc50m00.*   to null
 display by name d_ctc50m00.*

 call ctc50m00_input("i", d_ctc50m00.*) returning d_ctc50m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc50m00.*  to null
    display by name d_ctc50m00.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc50m00.caddat = today


 declare c_ctc50m00m  cursor with hold  for
    select max(mpacidcod)
      from datkmpacid
     where datkmpacid.mpacidcod > 0

 foreach c_ctc50m00m  into  d_ctc50m00.mpacidcod
     exit foreach
 end foreach

 if d_ctc50m00.mpacidcod is null   then
    let d_ctc50m00.mpacidcod = 0
 end if
 let d_ctc50m00.mpacidcod = d_ctc50m00.mpacidcod + 1

 whenever error continue

 begin work
    insert into datkmpacid             ( mpacidcod,
                                         ufdcod,
                                         cidnom,
                                         lclltt,
                                         lcllgt,
                                         caddat,
                                         gpsacngrpcod)
                         values
                                      ( d_ctc50m00.mpacidcod,
                                        d_ctc50m00.ufdcod,
                                        d_ctc50m00.cidnom,
                                        d_ctc50m00.lclltt,
                                        d_ctc50m00.lcllgt,
                                        d_ctc50m00.caddat,
                                        d_ctc50m00.gpsacngrpcod)

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao da cidade!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 display by name  d_ctc50m00.*

 display by name d_ctc50m00.mpacidcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc50m00.*  to null
 display by name d_ctc50m00.*

 end function   #  ctc50m00_inclui


#--------------------------------------------------------------------
 function ctc50m00_input(param, d_ctc50m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

  define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkacngrp.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record
 
 define ws            record
    mpacidcod         like datkmpacid.mpacidcod
 end record
 
 define l_cidnom      like datkmpacid.cidnom
 
 define l_count    smallint,
        scr_aux    smallint,
        arr_aux    smallint,
        l_aux      smallint, 
        l_gpsacngrpcod like datrorgcidacntip.gpsacngrpcod 


 initialize ws.*  to null
 initialize am_origens to null
 let int_flag     =  false
 let l_gpsacngrpcod = null
      
 display "(F1) Origem x Tp Acionamento" at 17,01 attribute (reverse)
 
 input by name d_ctc50m00.ufdcod,
               d_ctc50m00.cidnom,
               d_ctc50m00.lclltt,
               d_ctc50m00.lcllgt,
               d_ctc50m00.gpsacngrpcod without defaults

    before field ufdcod
           display by name d_ctc50m00.ufdcod attribute (reverse)

    after  field ufdcod
           display by name d_ctc50m00.ufdcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ufdcod
           end if

           if d_ctc50m00.ufdcod  is null   then
              error " UF deve ser informada!"
              next field ufdcod
           end if

           select ufdcod
             from glakest
            where ufdcod  =  d_ctc50m00.ufdcod

           if sqlca.sqlcode  =  notfound   then
              error " UF nao cadastrada!"
              next field ufdcod
           end if

    before field cidnom
           display by name d_ctc50m00.cidnom attribute (reverse)

    after  field cidnom
           display by name d_ctc50m00.cidnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ufdcod
           end if

           if d_ctc50m00.cidnom  is null   then
              error " Cidade deve ser informada!"
              next field cidnom
           end if
          
           # Alteração Burini
           open cqctc50m00_01 using d_ctc50m00.cidnom,
                                    d_ctc50m00.ufdcod
                                    
           fetch cqctc50m00_01 into l_cidnom

           if sqlca.sqlcode  =  notfound   then
              error " Cidade nao cadastrada!"
              next field cidnom
           end if

    before field lclltt
           display by name d_ctc50m00.lclltt attribute (reverse)

    after  field lclltt
           display by name d_ctc50m00.lclltt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cidnom
           end if

           if d_ctc50m00.lclltt  is null   then
              error " Latitude deve ser informada!"
              next field lclltt
           end if

          #if d_ctc45m00.lclltt  <  -23.999999   or
          #   d_ctc45m00.lclltt  >  -23.000000   then
          #   error " Latitude incorreta!"
          #   next field lclltt
          #end if

    before field lcllgt
           display by name d_ctc50m00.lcllgt attribute (reverse)

    after  field lcllgt
           display by name d_ctc50m00.lcllgt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  lclltt
           end if

           if d_ctc50m00.lcllgt  is null   then
              error " Longitude deve ser informada!"
              next field lcllgt
           end if

          #if d_ctc45m00.lcllgt  <  -46.999999   or
          #   d_ctc45m00.lcllgt  >  -46.000000   then
          #   error " Longitude incorreta!"
          #   next field lcllgt
          #end if

           #------------------------------------------------------------
           # Verifica se latitude/longitude ja' cadastrada
           #------------------------------------------------------------

           initialize ws.mpacidcod  to null
           
           # Alteração Burini
           open cqctc50m00_02 using d_ctc50m00.lclltt,
                                    d_ctc50m00.lcllgt
           fetch cqctc50m00_02 into ws.mpacidcod      

           if sqlca.sqlcode  =  0   then
              if param.operacao  =  "i"   then
                 error " Latitude/longitude ja' cadastrada em outra",
                       " cidade! --> ", ws.mpacidcod
                 next field lcllgt
              else
                 if d_ctc50m00.mpacidcod  <>  ws.mpacidcod   then
                    error " Latitude/longitude ja' cadastrada em outra",
                          " cidade! --> ", ws.mpacidcod
                    next field lcllgt
                 end if
              end if
           end if

     before field gpsacngrpcod
         display by name d_ctc50m00.gpsacngrpcod attribute (reverse)

     after field gpsacngrpcod
         if d_ctc50m00.gpsacngrpcod is null then
	    error " Grupo de Acionamento deve ser informado!"
            next field gpsacngrpcod
         end if

         select gpsacngrpdes into d_ctc50m00.gpsacngrpdes from datkacngrp
         where  gpsacngrpcod = d_ctc50m00.gpsacngrpcod

         if sqlca.sqlcode <> 0 and d_ctc50m00.gpsacngrpcod <> 0 then
            error " Descricao Grupo de acionamento nao cadastrada"
            next field gpsacngrpcod
         end if

         if d_ctc50m00.gpsacngrpcod = 0 then
            let d_ctc50m00.gpsacngrpdes = "Nao acionado por GPS"
         end if

         display by name d_ctc50m00.gpsacngrpdes attribute (reverse)

    on key (interrupt)
       exit input
    
    on key (f1)
    
    	let l_count = 1
    
        open cqctc50m00_03 using d_ctc50m00.mpacidcod
        
        foreach cqctc50m00_03 into am_origens[l_count].atdsrvorg
                                  ,am_origens[l_count].gpsacngrpcod
                 
	         if am_origens[l_count].gpsacngrpcod = 0 then
	            let am_origens[l_count].gpsacngrpdes = "Nao acionado por GPS"
	         else 
	            select gpsacngrpdes into am_origens[l_count].gpsacngrpdes from datkacngrp
	            where  gpsacngrpcod = am_origens[l_count].gpsacngrpcod	     
	         end if
	         
	         let  l_count = l_count + 1
	end foreach                
    
    	    
    	open window w_ctc50m00a at 08,13 with form "ctc50m00a"
                    attribute(border)
        
            display d_ctc50m00.cidnom to texto 
            
            options
       		 insert key f1, 
       		 delete key control-y
            
            call set_count(l_count - 1)   
        
            input array  am_origens without defaults from s_ctc50m00a.*   
        
                before row
                     let scr_aux = scr_line()
                     let arr_aux = arr_curr()  
                     
                 before field atdsrvorg
                 	 display am_origens[arr_aux].atdsrvorg to 
                          s_ctc50m00a[scr_aux].atdsrvorg attribute(reverse)
                 
                 after field atdsrvorg
                         display am_origens[arr_aux].atdsrvorg to s_ctc50m00a[scr_aux].atdsrvorg 
                     	     
	                 if fgl_lastkey() <> fgl_keyval("up") then
	                 
		                 if am_origens[arr_aux].atdsrvorg is null then
				    error " Origem deve ser informado!"
				    next field atdsrvorg
			          end if
			          
			         for l_aux = 1 to 30 
			            if arr_aux <> l_aux then
			                    if 	am_origens[arr_aux].atdsrvorg is not null then	            
					            if am_origens[arr_aux].atdsrvorg = am_origens[l_aux].atdsrvorg then
					               error "Origem já cadastrada!"
					               next field atdsrvorg
					            end if
					    else
					           exit for
					    end if
			            end if
			         end for 
			         
			         whenever error continue
			            select atdsrvorg into am_origens[arr_aux].atdsrvorg
			               from datksrvtip
			                where atdsrvorg = am_origens[arr_aux].atdsrvorg			                
			         whenever error stop
			            display "Origem" ,am_origens[arr_aux].atdsrvorg	
			                
			            if sqlca.sqlcode <> 0   then                           
				       error "Origem cadastrada não existe"
				       call cts00m09() returning am_origens[arr_aux].atdsrvorg
				       next field atdsrvorg
				    else			         			          
	                               next field gpsacngrpcod
	                            end if
	                  else
	                 	if am_origens[arr_aux].atdsrvorg is null and am_origens[arr_aux].gpsacngrpcod is not null then      
                                    error " Origem deve ser informado!"
				    next field atdsrvorg                                
				end if 
				
                                if am_origens[arr_aux].atdsrvorg is not null and am_origens[arr_aux].gpsacngrpcod is  null then
                                    let am_origens[arr_aux].atdsrvorg = null                                            
                                end if
                          end if
                          
                 before field gpsacngrpcod
                 	 display am_origens[arr_aux].gpsacngrpcod to 
                          s_ctc50m00a[scr_aux].gpsacngrpcod attribute(reverse)
                          
                 after field gpsacngrpcod
                         display am_origens[arr_aux].gpsacngrpcod to 
                          s_ctc50m00a[scr_aux].gpsacngrpcod 
                          
                          if am_origens[arr_aux].gpsacngrpcod is null
                             and fgl_lastkey() <> fgl_keyval("up")
                             and am_origens[arr_aux].atdsrvorg is not null then
			    error " Grupo de Acionamento deve ser informado!"
		            next field gpsacngrpcod
	        	  end if 
	        	  
	        	  if (am_origens[arr_aux].gpsacngrpcod != 0 and am_origens[arr_aux].gpsacngrpcod !=1) then
                             error "Informar 1 para Acionado por GPS e 0 para Não Acionado por GPS"  
                             next field gpsacngrpcod
                          else
	                       if am_origens[arr_aux].gpsacngrpcod = 0 then
		                 let am_origens[arr_aux].gpsacngrpdes = "Nao acionado por GPS"
		                 display am_origens[arr_aux].gpsacngrpdes to s_ctc50m00a[scr_aux].gpsacngrpdes 
		               else 
		                   select gpsacngrpdes into am_origens[arr_aux].gpsacngrpdes from datkacngrp
		                    where  gpsacngrpcod = am_origens[arr_aux].gpsacngrpcod
		                    display am_origens[arr_aux].gpsacngrpdes to s_ctc50m00a[scr_aux].gpsacngrpdes 	     
		               end if 
		          end if
	                  
	                  
	            on key (f2)
	            	
	            	select atdsrvorg from datrorgcidacntip 
	            	where mpacidcod = d_ctc50m00.mpacidcod
	            	and atdsrvorg = am_origens[arr_aux].atdsrvorg
	            	
	            	if sqlca.sqlcode == 0   then
	            	 begin work
	                   delete from datrorgcidacntip
	                   where mpacidcod = d_ctc50m00.mpacidcod
	            	    and atdsrvorg = am_origens[arr_aux].atdsrvorg
	            	 commit work	
	            	  
	            	  if sqlca.sqlcode <> 0   then                           
                             error " Erro (",sqlca.sqlcode,") na exclusao da origem!"
	            	  else 
	            	     call ctc50m00_deleta_linha(arr_aux,scr_aux) 
	            	     error "Origem deletada corretamente" sleep 1
	            	  end if
	                else	                   
	                    call ctc50m00_deleta_linha(arr_aux,scr_aux)
	                end if
	            
	            
	            on key (f8)
	            
	               for l_aux = 1 to 30
	                       
	                       if (am_origens[l_aux].atdsrvorg is not null and am_origens[l_aux].gpsacngrpcod is not null) then
			               select gpsacngrpcod into l_gpsacngrpcod from datrorgcidacntip 
			            	where mpacidcod = d_ctc50m00.mpacidcod
			            	and atdsrvorg = am_origens[l_aux].atdsrvorg
			            	
			            	if sqlca.sqlcode == 0   then
			                   if l_gpsacngrpcod != am_origens[l_aux].gpsacngrpcod then
			                      update datrorgcidacntip set gpsacngrpcod = am_origens[l_aux].gpsacngrpcod
			                        where mpacidcod = d_ctc50m00.mpacidcod
			            	         and atdsrvorg = am_origens[l_aux].atdsrvorg 	                 
			                   end if	                               
			                else
			                    insert into datrorgcidacntip (mpacidcod, atdsrvorg, gpsacngrpcod) 
			                    values (d_ctc50m00.mpacidcod,am_origens[l_aux].atdsrvorg, am_origens[l_aux].gpsacngrpcod)	                 
			                end if
			       else
			           exit for
			       end if  
	            	end for
	            	
	            	error "Dados gravados com sucesso"
	            	exit input	            	
            end input
        close window w_ctc50m00a
     

 end input

 if int_flag   then
    initialize d_ctc50m00.*  to null
 end if
 
  display "                            " at 17,01 

 return d_ctc50m00.*

 end function   # ctc50m00_input

#--------------------------------------------------------------------
 function ctc50m00_remove(d_ctc50m00)
#--------------------------------------------------------------------

 define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkacngrp.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record
 
 define l_count       smallint
 
 let l_count = 0

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui cidade"
            clear form
            initialize d_ctc50m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui cidade"
            call ctc50m00_ler(d_ctc50m00.mpacidcod) returning d_ctc50m00.*

            if d_ctc50m00.mpacidcod  is null   then
               initialize d_ctc50m00.* to null
               error " Cidade nao localizada!"
            else 
               select count(*) into l_count from datrorgcidacntip
                 where mpacidcod = d_ctc50m00.mpacidcod
                 
                 if l_count > 0   then
                  begin work
                      delete from datrorgcidacntip
                        where datrorgcidacntip.mpacidcod = d_ctc50m00.mpacidcod
                  commit work                 
                 end if
                 
                  if sqlca.sqlcode <> 0   then
	                  initialize d_ctc50m00.* to null
	                  error " Erro (",sqlca.sqlcode,") na exlusao das origens da cidade!"
                  else                  	
                       begin work   
                           delete from datkmpacid
                             where datkmpacid.mpacidcod = d_ctc50m00.mpacidcod
                       commit work

                       if sqlca.sqlcode <> 0   then
                           initialize d_ctc50m00.* to null
                           error " Erro (",sqlca.sqlcode,") na exlusao da cidade!"
                       else
                           initialize d_ctc50m00.* to null
                           error   " Cidade excluida!"
                           message ""
                           clear form
                       end if                   
                  end if   
            end if
            exit menu
 end menu

 return d_ctc50m00.*

end function    # ctc50m00_remove


#--------------------------------------------------------------------
 function ctc50m00_ler(param)
#--------------------------------------------------------------------

 define param         record
    mpacidcod         like datkmpacid.mpacidcod
 end record

 define d_ctc50m00    record
    mpacidcod         like datkmpacid.mpacidcod,
    cidnom            like datkmpacid.cidnom,
    ufdcod            like datkmpacid.ufdcod,
    caddat            like datkmpacid.caddat,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    gpsacngrpcod      like datkacngrp.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes
 end record

 initialize d_ctc50m00.*   to null

 select  mpacidcod,
         ufdcod,
         cidnom,
         lclltt,
         lcllgt,
         caddat,
         gpsacngrpcod
   into  d_ctc50m00.mpacidcod,
         d_ctc50m00.ufdcod,
         d_ctc50m00.cidnom,
         d_ctc50m00.lclltt,
         d_ctc50m00.lcllgt,
         d_ctc50m00.caddat,
         d_ctc50m00.gpsacngrpcod
   from  datkmpacid
  where  datkmpacid.mpacidcod    = param.mpacidcod

 if sqlca.sqlcode = notfound   then
    error " Cidade nao cadastrada!"
    initialize d_ctc50m00.*    to null
    return d_ctc50m00.*
 end if

 select gpsacngrpdes into d_ctc50m00.gpsacngrpdes
 from   datkacngrp
 where  gpsacngrpcod = d_ctc50m00.gpsacngrpcod

 if sqlca.sqlcode = notfound   then
    let d_ctc50m00.gpsacngrpdes = "Nao acionado por GPS"
 end if

 return d_ctc50m00.*

 end function   # ctc50m00_ler
 
 #---------------------------------------#
 function ctc50m00_deleta_linha(l_arr, l_scr)
 #---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint

  for l_cont = l_arr to 29   #uma posição antes do limite do array
     if am_origens[l_arr].atdsrvorg is not null then
        let am_origens[l_cont].* = am_origens[l_cont + 1].*
     else
        initialize am_origens[l_cont].* to null
     end if
  end for

  for l_cont = l_scr to 4
     display am_origens[l_arr].atdsrvorg    to s_ctc50m00a[l_cont].atdsrvorg
     display am_origens[l_arr].gpsacngrpcod to s_ctc50m00a[l_cont].gpsacngrpcod
     display am_origens[l_arr].gpsacngrpdes to s_ctc50m00a[l_cont].gpsacngrpdes
     let l_arr = l_arr + 1
  end for

 end function
