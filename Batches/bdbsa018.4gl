##############################################################################
# Nome do Modulo: BDBSA018                                         Beatriz   #
#                                                                  Araujo    #
# Notificar o RE quando for pago um serviço da apólice deste ramo  Maio/2010 #
#                                                                            #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
#                                                                            #
#                                                                            #
#----------------------------------------------------------------------------#
database porto

define m_log  char(200)        
define m_path char(100)      
define l_path char(100) 
define l_sql  char(600)     

#-------------------------------------------------------------
main
#-------------------------------------------------------------
  call fun_dba_abre_banco("CT24HS")
  
  let m_path = f_path("DBS","LOG")
  if m_path is null then
     let m_path = "."
  end if
  
  let m_path = m_path clipped, "/bdbsa018.log"
  call startlog(m_path)
  
  call bdbsa018()   
   
end main


####################-------------------------------------------- 
function bdbsa018_prepare()                                              
#--------------------------------------------------------------- 

  let l_sql  =  null

  let l_sql = "select socopgnum        ", 
              "  from dbsmopg          ",
              " where socopgsitcod = 7 ", 
              "   and socfatpgtdat = ? ",
              "   and socopgnum >= ?   ",
              "  order by socopgnum    "  
  
  prepare pbdbsa018_001 from l_sql
  declare cbdbsa018_001 cursor for pbdbsa018_001


  let l_sql = "select socopgitmnum,",
              "       atdsrvnum   ,",
              "       atdsrvano   ,",
              "       socopgitmvlr ",
              "  from dbsmopgitm   ",
              " where socopgnum = ? ",
              "   and socopgitmnum > ?",
              " order by socopgitmnum "  
  prepare pbdbsa018_002 from l_sql
  declare cbdbsa018_002 cursor for pbdbsa018_002
  
  
  let l_sql = "select grlinf                 ",
              "  from datkgeral              ",
              " where grlchv ='BDBSA018_DATA'"
  prepare pbdbsa018_003 from l_sql
  declare cbdbsa018_003 cursor for pbdbsa018_003
  
  
  
  let l_sql = "select grlinf               ",
              "  from datkgeral            ",
              " where grlchv ='BDBSA018_OP'"
  prepare pbdbsa018_004 from l_sql
  declare cbdbsa018_004 cursor for pbdbsa018_004
  
  
  
  let l_sql = "select grlinf                 ",
              "  from datkgeral              ",
              " where grlchv ='BDBSA018_ITEM'"
  prepare pbdbsa018_005 from l_sql
  declare cbdbsa018_005 cursor for pbdbsa018_005
  
  
  
  let l_sql = "update datkgeral              ",
              "   set grlinf = ?             ",
              " where grlchv ='BDBSA018_DATA'"
  prepare pbdbsa018_006 from l_sql
  
  
  
  let l_sql = "update datkgeral            ",
              "  set grlinf = ?            ",
              " where grlchv ='BDBSA018_OP'"
  prepare pbdbsa018_007 from l_sql
  
  
  let l_sql = "update datkgeral               ",
              "  set grlinf = ?               ",
              " where grlchv ='BDBSA018_ITEM'"
  prepare pbdbsa018_008 from l_sql
  
end function



####################-------------------------------------------- 
function bdbsa018()                                              
#--------------------------------------------------------------- 

define l_data   date

define l_bdbsa018  record 
  socopgnum        like dbsmopgfas.socopgnum   ,
  socopgitmnum     like dbsmopgitm.socopgitmnum, 
  atdsrvnum        like dbsmopgitm.atdsrvnum   , 
  atdsrvano        like dbsmopgitm.atdsrvano   , 
  socopgitmvlr     like dbsmopgitm.socopgitmvlr 
end record
 
define grlinf   record
  data       like datkgeral.grlinf,
  item       like datkgeral.grlinf,
  op         like datkgeral.grlinf  
end record
 
initialize l_data to null

   #-------------------------------------------------|
   # Verifica se a data foi passada como parametro   |
   #-------------------------------------------------|
   
   let l_data = arg_val(1)
   if l_data is null then
      #--------------------------------------------|
      # Para pegar as OP's pagas no dia anterior   |
      #--------------------------------------------|
        let l_data = today #- 1
   end if 
   display "l_data: ",l_data         
   
     
   #--------------------------------------------|	
   # Para preparar os cursores                  |
   #--------------------------------------------|
     call bdbsa018_prepare() 
	
#------------------------------------------------------------------------|	
# VERIFICA SE JA FOI PROCESSADA ESSA DATA,PARA SABER SE EH REESTART      |
#------------------------------------------------------------------------|	
whenever error continue
   open cbdbsa018_003
   fetch cbdbsa018_003 into grlinf.data
   close cbdbsa018_003
   if sqlca.sqlcode = 0 then
      display "grlinf.data: ",grlinf.data
      
      #------------------------------------------------------------------------|	
      # VERIFICA SE A DATA EM QUE O PROCESSAMENTO PAROU EH IGUAL A QUE ESTE    |
      # DEVE SER FEITO                                                         |
      #------------------------------------------------------------------------|	
      if grlinf.data = l_data then
                         
         #------------------------------------------------------------------------|
         # VERIFICA EM QUAL OP O PROCESSO PAROU                                   |
         #------------------------------------------------------------------------|
         whenever error continue
            open cbdbsa018_004
            fetch cbdbsa018_004 into grlinf.op
               if sqlca.sqlcode = 0 then
                  
                  #------------------------------------------------------------------------|
                  # VERIFICA EM QUAL ITEM O PROCESSO PAROU                                 |
                  #------------------------------------------------------------------------|
                  whenever error continue
                     open cbdbsa018_005
                     fetch cbdbsa018_005 into grlinf.item
                        if sqlca.sqlcode <> 0 then
                           display "Erro ao pesquisar o ultimo Item processado - ", sqlca.sqlcode    
                           let grlinf.item = 0
                        end if
                     close cbdbsa018_005
                  whenever error continue
         
                  display "grlinf.item: ",grlinf.item
               else 
                  display "Erro ao pesquisar a ultima OP processada - ", sqlca.sqlcode
                  let grlinf.op = 0  
                  let grlinf.item = 0     
               end if 
            close cbdbsa018_004     
         whenever error stop          
            display "grlinf.op: " ,grlinf.op
      else 
         let grlinf.op   = 0
         let grlinf.item = 0 
      end if      
       display "OP: ", grlinf.op  
       display "ITEM:  ",grlinf.item 
                      
      #------------------------------------------------------------------------|
      # BUSCA AS OPs MAIORES DO QUE A QUE O PROCESSO PARAOU                    |
      #------------------------------------------------------------------------|
      whenever error continue
         open cbdbsa018_001 using l_data,
                                  grlinf.op  
         foreach cbdbsa018_001 into l_bdbsa018.socopgnum
            
            #------------------------------------------------------------------------|
            # BUSCA AS OPs MAIORES DO QUE A QUE O PROCESSO PARAOU                    |
            #------------------------------------------------------------------------|

            if l_bdbsa018.socopgnum <> grlinf.op and
               l_bdbsa018.socopgnum > grlinf.op then
               let grlinf.item = 0                                               
            end if 
            
            #------------------------------------------------------------------------|
            # BUSCA OS ITENS DA OP PARA PROCESSAMENTO                                |
            #------------------------------------------------------------------------|
            whenever error continue
               open cbdbsa018_002 using l_bdbsa018.socopgnum,
                                        grlinf.item
               foreach cbdbsa018_002 into l_bdbsa018.socopgitmnum ,
                                          l_bdbsa018.atdsrvnum    ,
                                          l_bdbsa018.atdsrvano    ,
                                          l_bdbsa018.socopgitmvlr
                  display "************************************************************************"                           
                  display "grlinf.item: ",grlinf.item
                  call cts17m11_pagosrvre(l_bdbsa018.atdsrvnum ,
                                          l_bdbsa018.atdsrvano ,
                                          l_data,
                                          l_bdbsa018.socopgitmvlr,
                                          'N') 
                  display "************************************************************************"                           
                  
                  #------------------------------------------------------------------------|
                  # ATUALIZA O ITEM QUE FOI PROCESSADO                                     |
                  #------------------------------------------------------------------------|
                  whenever error continue                  
                     execute pbdbsa018_008 using l_bdbsa018.socopgitmnum
                     display "Item sqlca.sqlcode: ",sqlca.sqlcode
                     display "l_bdbsa018.socopgitmnum: ",l_bdbsa018.socopgitmnum
                  whenever error stop 
               end foreach
            whenever error stop 
            
            #------------------------------------------------------------------------|
            # ATUALIZA A OP QUE FOI PROCESSADO                                       |
            #------------------------------------------------------------------------|
            whenever error continue
               execute pbdbsa018_007 using l_bdbsa018.socopgnum
               display "OP sqlca.sqlcode: ",sqlca.sqlcode
               display "l_bdbsa018.socopgnum: ",l_bdbsa018.socopgnum
            whenever error stop         
         end foreach 
      whenever error stop
      if grlinf.data <= l_data then
         whenever error stop                   
            execute pbdbsa018_006 using l_data
            display "Data sqlca.sqlcode: ",sqlca.sqlcode           
            display "l_data: ",l_data
         whenever error stop 
      end if                     
   else
      display "Erro ao pesquisar a data do ultimo processamento - ", sqlca.sqlcode
      let grlinf.data = l_data
      let grlinf.op = 0  
      let grlinf.item = 0
   end if   
whenever error stop
                    
end function