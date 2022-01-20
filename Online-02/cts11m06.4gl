#############################################################################
# Nome do Modulo: CTS11M06                                         Marcelo  #
#                                                                  Gilberto #
# Localidades para assistencia a passageiros                       Jun/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
# 13/05/2015  RobertoFornax             Mercosul                            #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
 function cts11m06(d_cts11m06)
#--------------------------------------------------------------------

 define d_cts11m06    record
    atddmccidnom      like glakcid.cidnom,
    atddmcufdcod      like glakcid.ufdcod,
    atdocrcidnom      like glakcid.cidnom,
    atdocrufdcod      like glakcid.ufdcod,
    atddstcidnom      like glakcid.cidnom,
    atddstufdcod      like glakcid.ufdcod
 end record

 define ws            record
    		sql           char (300),
    		cidcod        like glakcid.cidcod,
    		codpais    		char(11),
    		despais    		char(40),
    		erro       		smallint
 end record
 
 define l_sql         char(300)
 define l_resposta    char (1)
 define l_retorno     smallint

 
 
 
 define l_descricao char(15)


	initialize  ws.*  to  null

 initialize ws.*      to null

 let int_flag  =  false
 let l_retorno = 0
#--------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------
 let ws.sql = "select ufdnom    ",
              "  from glakest   ",
              " where ufdcod = ?"
 prepare p_cts11m06_001 from ws.sql
 declare c_cts11m06_001 cursor for p_cts11m06_001

 let ws.sql = "select cidcod    ",
              "  from glakcid   ",
              " where cidnom = ?",
              "   and ufdcod = ?"
 prepare p_cts11m06_002 from ws.sql
 declare c_cts11m06_002 cursor for p_cts11m06_002
 

 open window cts11m06 at 12,10 with form "cts11m06"
                      attribute (form line 1, border, comment line last - 1)

 if g_documento.atdsrvorg = 3 then #hospedagem
    let l_descricao = "Hospedagem:"
 else
    let l_descricao = "Destino...:"
 end if

 display l_descricao to descricao

 message " (F17)Abandona "

 input by name d_cts11m06.* without defaults

    before field atddmccidnom
       display by name d_cts11m06.atddmccidnom attribute (reverse)

    after  field atddmccidnom
       display by name d_cts11m06.atddmccidnom

       if d_cts11m06.atddmccidnom is null  then
          error " Cidade de domicilio deve ser informada!"
          next field atddmccidnom
       end if

    before field atddmcufdcod
       display by name d_cts11m06.atddmcufdcod attribute (reverse)

    after  field atddmcufdcod
       display by name d_cts11m06.atddmcufdcod

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then

          if d_cts11m06.atddmcufdcod is null  then
             error " Sigla da unidade da federacao de domicilio deve ser informada!"
             next field atddmcufdcod
          end if

          #--------------------------------------------------------------
          # Verifica se UF esta cadastrada
          #--------------------------------------------------------------
          open  c_cts11m06_001 using d_cts11m06.atddmcufdcod
          fetch c_cts11m06_001

          if sqlca.sqlcode = notfound then
             error " Unidade federativa nao cadastrada!"
             next field atddmcufdcod
          end if

          close c_cts11m06_001

          if d_cts11m06.atddmcufdcod = d_cts11m06.atddmccidnom  then
             open  c_cts11m06_001 using d_cts11m06.atddmccidnom
             fetch c_cts11m06_001 into  d_cts11m06.atddmccidnom

             if sqlca.sqlcode = 0  then
                display by name d_cts11m06.atddmccidnom
             else
                let d_cts11m06.atddmccidnom = d_cts11m06.atddmcufdcod
             end if

             close c_cts11m06_001
          end if

          #--------------------------------------------------------------
          # Verifica se a cidade esta cadastrada
          #--------------------------------------------------------------
          open  c_cts11m06_002 using d_cts11m06.atddmccidnom, d_cts11m06.atddmcufdcod
          fetch c_cts11m06_002  into  ws.cidcod

          if sqlca.sqlcode  =  100   then
             call cts06g04(d_cts11m06.atddmccidnom, d_cts11m06.atddmcufdcod)
                 returning ws.cidcod, d_cts11m06.atddmccidnom, d_cts11m06.atddmcufdcod

             if d_cts11m06.atddmccidnom  is null   then
                error " Cidade de domicilio deve ser informada!"
             end if
             next field atddmccidnom
          end if

          close c_cts11m06_002
       end if       	 
			
				  #-------------------------------
					#Verifica o agrupamento
					#-------------------------------															
						  if (g_documento.c24astcod = 'M15'  or
						      g_documento.c24astcod = 'M20'  or
						      g_documento.c24astcod = 'M23'  or
						      g_documento.c24astcod = 'M33'  or
						      g_documento.c24astcod = 'KM1'  or 
						      g_documento.c24astcod = 'KM2'  or 
						      g_documento.c24astcod = 'KM3') then 
						     						     
						     let l_sql = "select cpocod "
						                      ,",cpodes "
						                       ,"from datkdominio "
						                       ,"where cponom = 'paises_mercosul' "						                       
						                       ,"order by cpodes "
						      call ofgrc001_popup(10,10,"PAISES - MERCOSUL","CODIGO","DESCRICAO",
                                       'N',l_sql, 
                                       "",'D')
                            returning ws.erro,
									                    ws.codpais,
									                    ws.despais 
									let d_cts11m06.atdocrcidnom = ws.despais
									let d_cts11m06.atdocrufdcod = "EX" 
									let l_retorno = 1
									next field atddstcidnom
							end if
				
					
    before field atdocrcidnom
       display by name d_cts11m06.atdocrcidnom attribute (reverse)                    	

    after  field atdocrcidnom
       display by name d_cts11m06.atdocrcidnom              

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
           if d_cts11m06.atdocrcidnom is null  then
              error " Cidade de ocorrencia deve ser informada!"
              next field atdocrcidnom
           end if
       end if

    before field atdocrufdcod
       display by name d_cts11m06.atdocrufdcod attribute (reverse)

    after  field atdocrufdcod
       display by name d_cts11m06.atdocrufdcod

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then

          if d_cts11m06.atdocrufdcod is null  then
             error " Sigla da unidade da federacao de ocorrencia deve ser informada!"
             next field atdocrufdcod
          end if

          #--------------------------------------------------------------
          # Verifica se UF esta cadastrada
          #--------------------------------------------------------------
        	
          open  c_cts11m06_001 using d_cts11m06.atdocrufdcod
          fetch c_cts11m06_001

          if sqlca.sqlcode = notfound then
             error " Unidade federativa nao cadastrada!"
             next field atdocrufdcod
          end if

          close c_cts11m06_001

          if d_cts11m06.atdocrufdcod = d_cts11m06.atdocrcidnom  then
             open  c_cts11m06_001 using d_cts11m06.atdocrcidnom
             fetch c_cts11m06_001 into  d_cts11m06.atdocrcidnom

             if sqlca.sqlcode = 0  then
                display by name d_cts11m06.atdocrcidnom
             else
                let d_cts11m06.atdocrcidnom = d_cts11m06.atdocrufdcod
             end if

             close c_cts11m06_001
          end if

          #--------------------------------------------------------------
          # Verifica se a cidade esta cadastrada
          #--------------------------------------------------------------
          open  c_cts11m06_002 using d_cts11m06.atdocrcidnom, d_cts11m06.atdocrufdcod
          fetch c_cts11m06_002  into  ws.cidcod

          if sqlca.sqlcode  =  100   then
             call cts06g04(d_cts11m06.atdocrcidnom, d_cts11m06.atdocrufdcod)
                  returning ws.cidcod, d_cts11m06.atdocrcidnom, d_cts11m06.atdocrufdcod

             if d_cts11m06.atdocrcidnom  is null   then
                error " Cidade de ocorrencia deve ser informada!"
             end if
             next field atdocrcidnom
          end if

          close c_cts11m06_002
       end if		   	
       	
    before field atddstcidnom
       display by name d_cts11m06.atddstcidnom attribute (reverse) 
         
        if (g_documento.c24astcod = 'M15'  or
					  g_documento.c24astcod = 'M20'  or
					  g_documento.c24astcod = 'M23'  or
					  g_documento.c24astcod = 'KM1'  or 
					  g_documento.c24astcod = 'KM2') then 
					   
					   if l_retorno = 1 then 
							call cts08g01("C","S",""," DESTINO SERA O BRASIL ? ","", "")
					       returning l_resposta
					   end if
				end if 
				   if g_documento.c24astcod = 'M33' or 
				   	  g_documento.c24astcod = 'KM3' then
				      if l_retorno = 1 then
				        call cts08g01("C","S",""," A HOSPEDAGEM SERA NO BRASIL ? ","", "")
					       returning l_resposta
					     end if
		       end if						     
			
			  if l_resposta = "N" then
			        call ofgrc001_popup(10,10,"PAISES - MERCOSUL","CODIGO","DESCRICAO",
                                       'N',l_sql, 
                                       "",'D')
                            returning ws.erro,
													            ws.codpais,
													            ws.despais 
													            
										let d_cts11m06.atddstcidnom = ws.despais
										let	d_cts11m06.atddstufdcod = "EX"
										exit input									             			  
			 end if
				
    after  field atddstcidnom 
       display by name d_cts11m06.atddstcidnom
      
       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
           if d_cts11m06.atddstcidnom is null  then
              error " Cidade de destino deve ser informada!"
              next field atddstcidnom
           end if
       end if

    before field atddstufdcod
       display by name d_cts11m06.atddstufdcod attribute (reverse)

    after  field atddstufdcod
        
       display by name d_cts11m06.atddstufdcod

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then

          if d_cts11m06.atddstufdcod is null  then
             error " Sigla da unidade da federacao de destino deve ser informada!"
             next field atddstufdcod
          end if                 			
		 
          #--------------------------------------------------------------
          # Verifica se UF esta cadastrada
          #--------------------------------------------------------------  
      if l_retorno = 0 then        
          open  c_cts11m06_001 using d_cts11m06.atddstufdcod
          fetch c_cts11m06_001

          if sqlca.sqlcode = notfound then
             error " Unidade federativa nao cadastrada!"
             next field atddstufdcod
          end if

          if d_cts11m06.atddstufdcod = d_cts11m06.atddstcidnom  then
             open  c_cts11m06_001 using d_cts11m06.atddstcidnom
             fetch c_cts11m06_001 into  d_cts11m06.atddstcidnom

             if sqlca.sqlcode = 0  then
                display by name d_cts11m06.atddstcidnom
             else
                let d_cts11m06.atddstcidnom = d_cts11m06.atddstufdcod
             end if

             close c_cts11m06_001
          end if
     
          #--------------------------------------------------------------
          # Verifica se a cidade esta cadastrada
          #--------------------------------------------------------------
          open  c_cts11m06_002 using d_cts11m06.atddstcidnom, d_cts11m06.atddstufdcod
          fetch c_cts11m06_002  into  ws.cidcod

          if sqlca.sqlcode  =  100   then
             call cts06g04(d_cts11m06.atddstcidnom, d_cts11m06.atddstufdcod)
                  returning ws.cidcod, d_cts11m06.atddstcidnom, d_cts11m06.atddstufdcod

             if d_cts11m06.atddstcidnom  is null   then
                error " Cidade de destino deve ser informada!"
             end if
             next field atddstcidnom
          end if

          close c_cts11m06_002
       end if
     end if  
    on key (interrupt)
       exit input

 end input
						
 let int_flag = false

 close window cts11m06

 return d_cts11m06.*

end function  ###  cts11m06
