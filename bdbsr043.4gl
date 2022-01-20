#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# .......................................................................... #
# Sistema........: Porto Socorro - Central 24 Horas                          #
# Modulo.........: bdbsr043                                                  #
# Analista Resp..: Rafael Moreira Gomes                                      #
# Objetivo.......: Ler arquivo ITAU PAGAMENTO.                               #
# .......................................................................... #
# Desenvolvimento: Eliane Kawachiya - Fornax                                 #
# Data de criacao: 08/01/2016                                                #
#. ......................................................................... #
#                       * * *  ALTERACOES  * * *                             #
# OSF/PSI     Autor          Data        Alteracao                           #
# --------    -------------  ----------  ----------------------------------- #
#                                                                            #
#............................................................................#
#----------------------------------------------------------------------------#

database porto

define m_data           char(10)
define m_datautil       char(10)
define m_arq            char(100)
define m_sql            char(500)
define m_linha          char(2000)
define m_email          int
define m_fim            char(3)
define m_pulalinha      char(10)
define m_datatxt        char(08)
define m_tam            int
define m_finalarq       int
define m_comando        char(250)
define m_erro           integer
                        
define mr_email record  
   rem     char(50)     
  ,des     char(10000)  
  ,ccp     char(10000)  
  ,cco     char(10000)
  ,ass     char(500)    
  ,msg     char(32000)  
  ,idr     char(20)     
  ,tip     char(4)      
end record              
                        
define m_anexo          char(300)
define m_mensagem_erro  char(20)

main

   initialize m_mensagem_erro, m_comando, m_erro, mr_email.*, m_anexo to null
   initialize m_data, m_datautil, m_arq, m_sql, m_linha, m_fim        to null
   initialize m_pulalinha, m_datatxt, m_tam, m_finalarq               to null
   
   call cts40g03_exibe_info("I", "BDBSR043")

   call bdbsr043_carrega_email()

   let m_pulalinha = '<br>'
   let m_finalarq = 0
   let m_tam = 0
   let m_email = 0

#------------------------------------------------------------
# verifica a data para o processamento
#-----------------------------------------------------------
   let m_data = arg_val(1)

   if m_data is null or m_data = " " then
      let m_data = today
   end if

   display 'Data atual.....: ', m_data

#------------------------------------------------------------
# VERIFICA SE A DATA DE PROCESSAMENTO E DIA UTIL
#------------------------------------------------------------
   let m_datautil = dias_uteis(m_data, 2, "", "S", "S")

   display 'Dia util.......: ', m_datautil

   call bdbsr043_drop_tmp()
   
   call bdbsr043_create_tmp()
   
   call bdbsr043_carga_tmp()

   call bdbsr043()

   call bdbsr043_envia_email()

   call bdbsr043_drop_tmp()
   
   database porto
   
   call cts40g03_exibe_info("F", "BDBSR043")


end main


#---------------------------
function bdbsr043_drop_tmp()
#----------------------------

 database work

 whenever error continue
 delete from itapgto
 drop table itapgto
 whenever error stop

#-----------
end function
#-----------

#---------------------------
function bdbsr043_carga_tmp()
#----------------------------

   database work

   let m_datatxt = m_datautil[7,10], m_datautil[4,5], m_datautil[1,2]
   let m_arq = '/adbs/ITAU.PGTO.', m_datatxt clipped, '.txt'

   whenever error continue

   display "Arquivo........: ", m_arq
   load from m_arq delimiter ";" insert into work:itapgto

   if sqlca.sqlcode <> 0 then
      display "Erro no Load do arquivo ITAUPGTO"
      
      let mr_email.msg = 'Erro no Load do arquivo ITAUPGTO'
      call bdbsr043_envia_email()
      
      call cts40g03_exibe_info("F", "BDBSR043")
      
      exit program
   else
      display "Carga realizada com sucesso"
   end if
   
   whenever error stop

#-----------
end function
#-----------


#---------------------------
function bdbsr043_create_tmp()
#----------------------------

   database work

   create temp table itapgto (linha char(2000)) with no log

   if sqlca.sqlcode <> 0 then
      let mr_email.msg = '<html><body>'
	       	         , m_pulalinha clipped
		               , '<p>', 'Erro ao criar tabela temporaria','</p>'
		               , m_pulalinha
			             ,'</body></html>'
			
      display "Erro ao criar tabela temporaria"

      call bdbsr043_envia_email()
      
      call cts40g03_exibe_info("F", "BDBSR043")

      exit program

   end if

#-----------
end function
#-----------


#---------------------------
function bdbsr043_envia_email()
#----------------------------

   database porto
   
   let m_erro = ctx22g00_envia_email_overload(mr_email.*, m_anexo)

   if  m_erro <> 0 then
      if  m_erro <> 99 then
         display "Erro ao enviar email"
      else
         display "Erro no destinatario de email ITAUPAG"
      end if
   else
      display "Enviado email com sucesso."
   end if

#-----------
end function
#-----------


#---------------------------
function bdbsr043_carrega_email()
#----------------------------

   let mr_email.rem = 'central.24horas@porto-seguro.com.br'
   let mr_email.des = 'rafaelmoreira.gomes@portoseguro.com.br'
   let mr_email.ass = 'Processamento ITAU PGTO em ', m_data
   let mr_email.ccp = null
   let mr_email.cco = null
   let mr_email.msg = null
   let mr_email.tip = 'html'
   let m_anexo = 'arquivo.html'

#-----------
end function
#-----------

#---------------------------
function bdbsr043()
#----------------------------

   database work

   let m_sql = "select linha from work:itapgto"
   prepare p_select_tmp from m_sql
   declare c_select_tmp cursor with hold for p_select_tmp

      open c_select_tmp
   foreach c_select_tmp into m_linha

	    let m_tam = length(m_linha clipped)
	    if m_tam > 1483 then
         let m_finalarq = 1
      end if

	    let m_fim = m_linha[1,1], m_linha[2,2], m_linha[3,3]

	    if m_fim = '999' then
         let m_email = 1    # achou final do arquivo
         exit foreach
      end if

   end foreach

   close c_select_tmp  

   ##--------------------------------------------
   #Envia email apos verificacao do final arquivo
   #---------------------------------------------
   if m_email = 1 and m_finalarq = 0 then  # email: Processado com sucesso
      let mr_email.msg = '<html><body>'
             			 ,m_pulalinha clipped
		               ,'<p>', 'Arquivo : ', m_arq clipped, ' processado com sucesso.', '</p>'
         	         ,m_pulalinha
			             ,'</body></html>'
			             
		  display 'Arquivo : ', m_arq clipped, ' processado com sucesso.'
		  
   else
      if m_email = 1 and m_finalarq = 1 then
         let mr_email.msg = '<html><body>'
	                    ,m_pulalinha clipped
		                  ,'<p>', 'Arquivo : ', m_arq clipped, ' gerado'
		                  ,', porem ha linhas com mais de 1483 colunas', '</p>'
		                  ,m_pulalinha
		                  ,'</body></html>'
		                  
		     display 'Arquivo : ', m_arq clipped, ' gerado, porem ha linhas com mais de 1483 colunas.'
		  
      else
         if m_email = 0 then
            let mr_email.msg = '<html><body>'
	                       ,m_pulalinha clipped
		                     ,'<p>', 'Arquivo : ', m_arq clipped, ' com Erro no processamento.', '</p>'
		                     ,m_pulalinha
		                     ,'</body></html>'
		                     
		        display 'Arquivo : ', m_arq clipped, ' com Erro no processamento.'
		     
		     end if
	    end if
   end if
   
#-----------
end function
#-----------