#############################################################################
# Menu de Modulo: ctc44m03                                        Gilberto  #
#                                                                  Marcelo  #
# Manutencao no Relacionamento Socorrista X Prestador             Jul/1999  #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 07/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador    #
#                                       B-Bloqueado.                        #
#---------------------------------------------------------------------------#
# 02/02/2007  PSI206679  Cristiane Silva  Enviar e-mail quando houver nova  #
#					  vigencia	                    #
#---------------------------------------------------------------------------#
# 02/02/2007  CT7063816  Sergio Burini    Retirada da Validacao de vigencia #
#				            inicial menor que 10 anos	    #
#---------------------------------------------------------------------------#
# 21/10/2009  PSI249530  Beatriz Araujo   Passar diretamento para o forne-  #
#				          cedor de crach�s as novos solici- #
#                                         ta��es                            #
#---------------------------------------------------------------------------#
# 28/05/2010  PSI257206  Robert Lima      Inclus�o do modulo para gravar em #
# 					  historico a solicitacao de cracha #
#---------------------------------------------------------------------------#
# 31/08/2010  PAS103306  Beatriz Araujo   Adicionar o campo RG no e-mail    # 
# 					  para o fornecedor de crach�       #
#---------------------------------------------------------------------------#
# 30/03/2011             Ueslei Oliveira  Adicionar c�digo do prestador e   #
#					  informacao do m�todo de envio do  #
#					  cracha no e-mail do fornecedor e  #
#					  inclus�o do e-mail de aviso ao pst#
#---------------------------------------------------------------------------# 
# 16/11/2011             Jorge Modena     Adicionar empresa Itau na solici- #
#                                         ta��o de crach� e realizar valida-#
#                                         ��es adicionais                   #
#############################################################################


 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_ctc44m03        record 
       rspnom          like dpaksocor.rspnom ,   
       pcpatvcod       like dpaksocor.pcpatvcod,
       pstcoddig       like dpaksocor.pstcoddig,
       nomrazsoc       like dpaksocor.nomrazsoc,
       srrcoddig       like datrsrrpst.srrcoddig,
       srrabvnom       like datksrr.srrabvnom,
       srrnom          like datksrr.srrnom,  
       pstvintip       like datrsrrpst.pstvintip,
       envsoltip       like datmcrhsol.envsoltip, # Tipo de solicita��o enviada(Porto/Azul,Porto,Azul,Itau,Porto/Itau,Itau/Azul,Porto/Itau/Azul)
       envsoldes       like iddkdominio.cpodes,   # Descri��o da solita��o enviada
       path            char(1000),
       qntemail        integer,
       seqcod          smallint,                  # Numero da sequencia de solicitacoes de cracha
       pcpatv          like datkgeral.grlinf,     # Principal atividade do prestador para gerar crach�
       vintip          like datkgeral.grlinf,     # Cargo do socorrista para gerar crach�
       frtrpn          like datkgeral.grlinf,     # Tipo do respons�vel para gerar crach�
       vigfnl          like datrsrrpst.vigfnl,
       rlzsoltip       like datmcrhsol.rlzsoltip, # Meio pelo qual a solicita��o foi realizada   
       cgccpfnum       like datksrr.cgccpfnum,    
       rgenum          like datksrr.rgenum,       # Rg do socorrista
       craenvtip       char(1), 	          #R para retirar cracha na Porto e E para enviar pelo correio
       maidespsr       like dpaksocor.maides,     # E-mail do Prestador 
       srrstt          like datksrr.srrstt        # Status do Socorrista
end record
 
define m_assunto char(300)
define data  date

define m_qtdarray       integer

# empresas atendidas pelo socorrista
 define ma_empatdsrr   array[3] of record
    aux                char(1),	
    ciaempdes          like gabkemp.empsgl,
    ciaempcod          like gabkemp.empcod
 end record
 
 define m_porto, m_itau, m_azul char(1)
 define m_autore                char(4)
 
 define m_arr_curr     integer
 define m_scr_curr     integer  

 define mr_aux    record 
        dddcod    like datksrr.celdddcod,
        telnum    like datksrr.celtelnum,
        maides    like datksrr.maides,
        pstvindes char (50),
	pstcoddig like dpaksocor.pstcoddig,
	pstcoddig_atu like dpaksocor.pstcoddig,
	nomgrr    like dpaksocor.nomgrr,
        srrcoddig like datksrr.srrcoddig,
        srrabvnom like datksrr.srrabvnom,
        perfil    char(50),
	pcpatvdes like iddkdominio.cpodes,
        usrcod    char(020)
	end record

define a_pcpatvcod  array[30] of like dpaksocor.pcpatvcod

#---------------------------------------------------------------
 function ctc44m03(param)
#---------------------------------------------------------------

 define param        record
    srrcoddig        like datksrr.srrcoddig,
    srrnom           like datksrr.srrnom
 end record

 define a_ctc44m03   array[30] of record
    viginc           like datrsrrpst.viginc,
    vigfnl           like datrsrrpst.vigfnl,
    pstvintip        like datrsrrpst.pstvintip,
    pstvindes        char (50),
    pstcoddig        like datrsrrpst.pstcoddig,
    nomgrr           like dpaksocor.nomgrr
 end record

 define ws           record
    viginc           like datrsrrpst.viginc,
    vigfnl           like datrsrrpst.vigfnl,
    pstcoddig        like datrsrrpst.pstcoddig,
    prssitcod        like dpaksocor.prssitcod,
    viginc2          like datrsrrpst.viginc,
    operacao         char (01),
    confirma         char (01)
 end record

 define l_cod_erro integer,
         l_msg_erro char(70),
         l_data     date,
         l_hora     datetime hour to second 
 
 
 define arr_aux          integer
 define scr_aux          integer
 define l_msg            char(500)
 define l_mensagem       char(100)
 define l_erro           smallint
 define l_socanlsitcod   like datksrr.socanlsitcod
 define resp             char(1)
 
 define l_qldgracod  integer
 define l_cponom     char(20)

 define arr_pso like datrsrrpst.pstcoddig
 define arr_vintip like datrsrrpst.pstvintip
 define l_retorno,pso_atual integer
 define l_lin integer
 
 let m_porto = "N"
 let m_itau  = "N"
 let m_azul  = "N"

 let m_assunto = ""
 let l_retorno = 0
 
 initialize a_ctc44m03, mr_aux.*  to null
 initialize ws.*,mr_ctc44m03.*        to null
 let int_flag  =  false
 let arr_aux   =  1
 

 open window w_ctc44m03 at 06,02 with form "ctc44m03"
      attribute(form line first, comment line last - 1)

 display by name param.srrcoddig
 display by name param.srrnom

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    message " (F17)Abandona"
 else
    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"
 end if


 declare c_ctc44m03  cursor for
   select datrsrrpst.viginc,
          datrsrrpst.vigfnl,
          datrsrrpst.pstvintip,
          datrsrrpst.pstcoddig
     from datrsrrpst
    where datrsrrpst.srrcoddig  =  param.srrcoddig
    order by viginc desc

      	 	

 foreach c_ctc44m03 into  a_ctc44m03[arr_aux].viginc,
                          a_ctc44m03[arr_aux].vigfnl,
                          a_ctc44m03[arr_aux].pstvintip,
                          a_ctc44m03[arr_aux].pstcoddig

    select cpodes
      into a_ctc44m03[arr_aux].pstvindes
      from iddkdominio
     where cponom  =  "pstvintip"
       and cpocod  =  a_ctc44m03[arr_aux].pstvintip

    select nomgrr, pcpatvcod
      into a_ctc44m03[arr_aux].nomgrr, a_pcpatvcod[arr_aux]
      from dpaksocor
     where pstcoddig  =  a_ctc44m03[arr_aux].pstcoddig

     if arr_aux = 1 then
        let mr_aux.pstcoddig = a_ctc44m03[arr_aux].pstcoddig
        let mr_aux.nomgrr    = a_ctc44m03[arr_aux].nomgrr
     else
        if a_ctc44m03[arr_aux].viginc > a_ctc44m03[arr_aux-1].viginc then
           let mr_aux.pstcoddig = a_ctc44m03[arr_aux].pstcoddig
           let mr_aux.nomgrr    = a_ctc44m03[arr_aux].nomgrr
        end if
     end if

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, socorrista com mais de 30 vinculos!"
       exit foreach
    end if

 end foreach
 
 

 #---------------------------------------------------------------
 # Nivel de acesso apenas para consulta
 #---------------------------------------------------------------
 call set_count(arr_aux-1)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display array a_ctc44m03 to s_ctc44m03.*

       on key (interrupt,control-c)
          initialize a_ctc44m03  to null
          exit display

    end display
 end if

 #---------------------------------------------------------------
 # Nivel de acesso para consulta/atualizacao
 #---------------------------------------------------------------
 while true

    if g_issk.acsnivcod  <  g_issk.acsnivatl   then
       exit while
    end if

    let l_lin = null

    let int_flag = false
    let pso_atual = arr_curr()
    let arr_pso =  a_ctc44m03[pso_atual].pstcoddig
    let arr_vintip = a_ctc44m03[pso_atual].pstvintip


    input array a_ctc44m03  without defaults from  s_ctc44m03.*
       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao  =  "a"
             let ws.viginc    =  a_ctc44m03[arr_aux].viginc
             let ws.vigfnl    =  a_ctc44m03[arr_aux].vigfnl
             let ws.pstcoddig =  a_ctc44m03[arr_aux].pstcoddig
             
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc44m03[arr_aux]  to null
          initialize ws.viginc            to null
          initialize ws.pstcoddig         to null
          initialize a_ctc44m03[arr_aux]  to null
          display a_ctc44m03[arr_aux].*   to  s_ctc44m03[scr_aux].*
      
       before field viginc
          display a_ctc44m03[arr_aux].viginc   to
                  s_ctc44m03[scr_aux].viginc   attribute (reverse)

       after field viginc
          display a_ctc44m03[arr_aux].viginc   to
                  s_ctc44m03[scr_aux].viginc

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc44m03[arr_aux].viginc  is null   then
             error " Vigencia inicial deve ser informada!"
             next field viginc
          end if

          if ws.operacao                 <>  "i"         and
             a_ctc44m03[arr_aux].viginc  <>  ws.viginc   then
             error " Vigencia inicial nao deve ser alterada!"
             next field viginc
          end if

          if a_ctc44m03[arr_aux].viginc  >  today + 30 units day   then
             error " Vigencia inicial nao deve ser superior a 30 dias!"
             next field viginc
          end if
          
          # CT 7063816 
          # if a_ctc44m03[arr_aux].viginc  <  today - 10 units year  then
          #    error " Vigencia inicial nao deve ser anterior a 10 anos!"
          #    next field viginc
          # end if

          if ws.operacao  =   "i"                          or
             ws.viginc    <>  a_ctc44m03[arr_aux].viginc   then

             select pstcoddig
               from datrsrrpst
              where datrsrrpst.srrcoddig  =  param.srrcoddig
                and a_ctc44m03[arr_aux].viginc  between viginc and vigfnl

             if sqlca.sqlcode  =  0   then
                error " Vigencia inicial ja' compreendida em outro periodo!"
                next field  viginc
             end if

          end if
      	
       before field vigfnl
          display a_ctc44m03[arr_aux].vigfnl   to
                  s_ctc44m03[scr_aux].vigfnl   attribute (reverse)

       after field vigfnl
          display a_ctc44m03[arr_aux].vigfnl   to
                  s_ctc44m03[scr_aux].vigfnl

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   then
             let ws.operacao = " "
          else
             if fgl_lastkey() = fgl_keyval("left")   then
                next field viginc
             end if
          end if

          if a_ctc44m03[arr_aux].vigfnl  is null   then
             error " Vigencia final deve ser informada!"
             next field vigfnl
          end if

          if a_ctc44m03[arr_aux].vigfnl  <  today - 10 units year  then
             error " Vigencia final nao deve ser anterior a 10 anos!"
             next field vigfnl
          end if

          if a_ctc44m03[arr_aux].vigfnl  <=  a_ctc44m03[arr_aux].viginc   then
            error " Vigencia final nao deve ser menor/igual a vigencia inicial!"
            next field vigfnl
          end if

          if ws.operacao  =   "i"                          or
             ws.vigfnl    <>  a_ctc44m03[arr_aux].vigfnl   then

             select viginc
               into ws.viginc2
               from datrsrrpst
              where datrsrrpst.srrcoddig  =  param.srrcoddig
                and a_ctc44m03[arr_aux].vigfnl  between viginc and vigfnl

             if sqlca.sqlcode  =   0                            and
                ws.viginc2     <>  a_ctc44m03[arr_aux].viginc   then
                error " Vigencia final ja' compreendida em outro periodo!"
                next field  vigfnl
             end if

             select pstcoddig
               from datrsrrpst
              where datrsrrpst.srrcoddig  =  param.srrcoddig
                and datrsrrpst.viginc     >  a_ctc44m03[arr_aux].viginc
                and datrsrrpst.vigfnl     <  a_ctc44m03[arr_aux].vigfnl

             if sqlca.sqlcode  =  0   then
                error " Vigencia ja' compreendida em outro periodo!"
                next field  vigfnl
             end if

          end if

       before field pstvintip
          display a_ctc44m03[arr_aux].pstvintip   to
                  s_ctc44m03[scr_aux].pstvintip   attribute (reverse)

       after field pstvintip
          display a_ctc44m03[arr_aux].pstvintip   to
                  s_ctc44m03[scr_aux].pstvintip

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   then
             let ws.operacao = " "
          else
             if fgl_lastkey() = fgl_keyval("left")   then
                next field vigfnl
             end if
          end if
   
          if a_ctc44m03[arr_aux].pstvintip  is null   then
             error " Tipo de vinculo deve ser informado!"
              call ctn36c00("Tipo de vinculo", "pstvintip")
                   returning  a_ctc44m03[arr_aux].pstvintip
             next field pstvintip
          end if

          select cpodes
            into a_ctc44m03[arr_aux].pstvindes
            from iddkdominio
           where cponom  =  "pstvintip"
             and cpocod  =  a_ctc44m03[arr_aux].pstvintip

          if sqlca.sqlcode  <>  0   then
             error " Tipo de vinculo nao cadastrado!"
              call ctn36c00("Tipo de vinculo", "pstvintip")
                   returning  a_ctc44m03[arr_aux].pstvintip
             next field pstvintip
          end if
          display a_ctc44m03[arr_aux].pstvindes to s_ctc44m03[scr_aux].pstvindes

       before field pstcoddig
          display a_ctc44m03[arr_aux].pstcoddig   to
                  s_ctc44m03[scr_aux].pstcoddig   attribute (reverse)

       after field pstcoddig
          display a_ctc44m03[arr_aux].pstcoddig   to
                  s_ctc44m03[scr_aux].pstcoddig

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   then
             let ws.operacao = " "
          else
             if fgl_lastkey() = fgl_keyval("left")   then
                next field pstvintip
             end if
          end if

          if a_ctc44m03[arr_aux].pstcoddig  is null   then
             error " Prestador deve ser informado!"
             next field pstcoddig
          end if   

          if ws.operacao                    <>  "i"            and
             a_ctc44m03[arr_aux].pstcoddig  <>  ws.pstcoddig   then
             error " Prestador nao deve ser alterado!"
             next field pstcoddig
          end if
                         
          select qldgracod 
            into l_qldgracod  
            from dpaksocor 
           where pstcoddig = a_ctc44m03[arr_aux].pstcoddig
           
           if sqlca.sqlcode  <>  0   then
               error " Prestador sem qualidade cadastrada!"
               next field pstcoddig
           end if
          
          let l_cponom = "VINQLT", l_qldgracod using "<<<<<<&"

          select 1
            from iddkdominio 
           where cponom = l_cponom
             and cpocod = a_ctc44m03[arr_aux].pstvintip

          if sqlca.sqlcode <> 0 then
             error "Vinculo nao permitido para esse tipo de prestador."
             next field pstvintip
          end if

          select nomgrr,
                 prssitcod
            into a_ctc44m03[arr_aux].nomgrr,
                 ws.prssitcod
            from dpaksocor
           where pstcoddig  =  a_ctc44m03[arr_aux].pstcoddig

          if sqlca.sqlcode  <>  0   then
             error " Prestador nao cadastrado!"
             next field pstcoddig
          end if
          display a_ctc44m03[arr_aux].nomgrr  to s_ctc44m03[scr_aux].nomgrr

          if ws.prssitcod  <>  "A"  then
             case ws.prssitcod
                when "C"  error " Prestador cancelado!"
                when "P"  error " Prestador em proposta!"
                when "B"  error " Prestador bloqueado!"
             end case
             next field pstcoddig
          end if
        initialize mr_ctc44m03.rlzsoltip to null
        #PSI206679 - inicio
        
        
        if ws.operacao == "i" then
        	{let m_assunto = "Inclus�o no QRA: ", param.srrcoddig, " ", param.srrnom, " - Solicite um novo crach�"
		call ctx22g00_envia_email("CTC44M03", m_assunto, "") returning l_retorno
		if l_retorno <> 0 then
			error "Erro ao enviar email"
		else
			error "Email enviado com sucesso"
		end if}
		#ENVIAR E-MAIL PARA O FORNECEDOR DE CRACH�S
		if( a_ctc44m03[arr_aux].pstcoddig  !=  arr_pso)or
		  (arr_pso is null)or
		  (a_ctc44m03[arr_aux].pstcoddig is null) then
		   let mr_ctc44m03.rlzsoltip = "Inclusao"
		else
		   initialize mr_ctc44m03.rlzsoltip to null
		end if
	else
	        if ws.operacao == "a" and  
		  (a_ctc44m03[arr_aux].pstcoddig  <>  ws.pstcoddig or 
		   a_ctc44m03[arr_aux].pstvintip !=  arr_vintip) then
		 	if( a_ctc44m03[arr_aux].pstcoddig  !=  arr_pso)or
		          (arr_pso is null)or
		          (a_ctc44m03[arr_aux].pstcoddig is null) then
		             let mr_ctc44m03.rlzsoltip = "Altera��o"
		        else
		           if (a_ctc44m03[arr_aux].pstcoddig !=  arr_pso) or  
		              (a_ctc44m03[arr_aux].pstvintip !=  arr_vintip)
		            then
                              let mr_ctc44m03.rlzsoltip = "Altera��o" 
	        	           else 
	        	             initialize mr_ctc44m03.rlzsoltip to null
	        	           end if  
	        	    end if
	      	  end if
	      end if
	
	
	#PSI206679 - fim
	        
     before delete
         let ws.operacao = "d"

         select prssitcod
           into ws.prssitcod
           from dpaksocor
          where pstcoddig  =  a_ctc44m03[arr_aux].pstcoddig

         if ws.prssitcod  <>  "A"   then
            error " Prestador cancelado, vinculo nao deve ser removido!"
            exit input
         end if

         if a_ctc44m03[arr_aux].viginc  is null   then
            continue input
         else
            let  ws.confirma  =  "N"
            call cts08g01("A","S", "","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                 returning ws.confirma

            if ws.confirma  =  "N"   then
               display a_ctc44m03[arr_aux].* to s_ctc44m03[scr_aux].*
               exit input
            end if

            begin work
               delete
                 from datrsrrpst
                where datrsrrpst.srrcoddig  =  param.srrcoddig
                  and datrsrrpst.pstcoddig  =  a_ctc44m03[arr_aux].pstcoddig
                  and datrsrrpst.viginc     =  a_ctc44m03[arr_aux].viginc
                  
                  if sqlca.sqlcode = 0 then
                     commit work
                  else
                     rollback work
                  end if
                  
            

            let l_mensagem = 'Delecao  no cadastro do socorrista.Codigo : ',
			param.srrcoddig

            let l_msg = "Prestador.: [", a_ctc44m03[arr_aux].pstcoddig , 
		        " - ", a_ctc44m03[arr_aux].nomgrr ,"] Vigencia ",
		        a_ctc44m03[arr_aux].viginc,"-", 
			a_ctc44m03[arr_aux].vigfnl, " Deletado!"

            let l_erro =  ctc44m00_grava_hist(param.srrcoddig
	                                        ,l_msg clipped
		                                ,today 
		                                ,l_mensagem,"I")

            initialize a_ctc44m03[arr_aux].* to null
            display    a_ctc44m03[arr_aux].* to s_ctc44m03[scr_aux].*
         end if

       after row
          let arr_aux = arr_curr() 
          if  ws.operacao = "i" or ws.operacao = "a" then

          #begin work

          case ws.operacao
            when "i"
                 insert into datrsrrpst ( srrcoddig,
                                          pstcoddig,
                                          viginc,
                                          vigfnl,
                                          pstvintip,
                                          atldat,
                                          atlemp,
                                          atlmat )
                               values   ( param.srrcoddig,
                                          a_ctc44m03[arr_aux].pstcoddig,
                                          a_ctc44m03[arr_aux].viginc,
                                          a_ctc44m03[arr_aux].vigfnl,
                                          a_ctc44m03[arr_aux].pstvintip,
                                          today,
                                          g_issk.empcod,
                                          g_issk.funmat )

                 let l_mensagem = 'Inclusao no cadastro do socorrista.Codigo : ',
				  param.srrcoddig

                 let l_msg = "Prestador.: [", a_ctc44m03[arr_aux].pstcoddig , 
		             " - ", a_ctc44m03[arr_aux].nomgrr ,"] Vigencia ",
		             a_ctc44m03[arr_aux].viginc,"-", 
		   	     a_ctc44m03[arr_aux].vigfnl, " Incluido!"
                 
                 let l_erro =  ctc44m00_grava_hist(param.srrcoddig
		                                   ,l_msg clipped
		                                   ,today 
		                                   ,l_mensagem,"I")
		 
            when "a"

                 update datrsrrpst set ( pstvintip,
                                         vigfnl )
                                    =  ( a_ctc44m03[arr_aux].pstvintip,
                                         a_ctc44m03[arr_aux].vigfnl )
                  where datrsrrpst.srrcoddig = param.srrcoddig
                    and datrsrrpst.pstcoddig = a_ctc44m03[arr_aux].pstcoddig
                    and datrsrrpst.viginc    = a_ctc44m03[arr_aux].viginc

            #if  SQLCA.SQLERRD[3] = 1 then
            #    commit work
            #else    
            #    rollback work
            #end if
            
            let l_mensagem = 'Alteracao no cadastro do socorrista.Codigo : ',
				param.srrcoddig

              let l_msg = "Prestador.: [", a_ctc44m03[arr_aux].pstcoddig , 
		" - ", a_ctc44m03[arr_aux].nomgrr ,"] Vigencia ",
		a_ctc44m03[arr_aux].viginc,"-", a_ctc44m03[arr_aux].vigfnl,
		   " Alterado Vigencia!"

              let l_erro =  ctc44m00_grava_hist(param.srrcoddig
		                                   ,l_msg clipped
		                                   ,today 
		                                   ,l_mensagem,"I")
          end case

          if ws.operacao = 'i' or 
            (ws.operacao = 'a' and mr_ctc44m03.rlzsoltip is not null ) then 
             call ctc44m03_email(param.srrcoddig,mr_ctc44m03.rlzsoltip)
          end if 
          
          #begin work
          
	  let mr_aux.srrcoddig = param.srrcoddig
	  let mr_aux.pstvindes = a_ctc44m03[arr_aux].pstvindes
          let mr_aux.pstcoddig_atu = a_ctc44m03[arr_aux].pstcoddig

	  if mr_aux.pstcoddig is null then
             let mr_aux.pstcoddig = a_ctc44m03[arr_aux].pstcoddig
	  end if
   
          select nomgrr, pcpatvcod
            into mr_aux.nomgrr, a_pcpatvcod[arr_aux]
            from dpaksocor
           where pstcoddig  =  a_ctc44m03[arr_aux].pstcoddig

          select cpodes into mr_aux.pcpatvdes
	    from iddkdominio
           where cponom  =  "pcpatvcod"
	     and cpocod  =  a_pcpatvcod[arr_aux]
   
	  let mr_aux.perfil = mr_aux.pcpatvdes clipped, "_", mr_aux.pstvindes
	  let mr_aux.perfil = ctd40g00_removeespacoembranco(mr_aux.perfil)
	  let ws.operacao = 'x'

                #Validacao para envio do acesso apenas se candidato liberado
                select socanlsitcod
                  into l_socanlsitcod
                  from datksrr
                 where srrcoddig = param.srrcoddig
								
                 if l_socanlsitcod = 2 then
                                             
                    if mr_aux.srrabvnom is not null then
                        call ctd40g00_inclui_webusr_qra(mr_aux.srrabvnom,
		                                                    mr_aux.pstvindes,
		       	                                           mr_aux.dddcod,
		       		                                         mr_aux.telnum,
		       		                                         mr_aux.maides,
		       	                                           mr_aux.pstcoddig,
		       	                                           mr_aux.nomgrr,
		       		                                         param.srrcoddig,
		       		                                         mr_aux.perfil,
		       		                                         mr_aux.pstcoddig_atu,
		       		                                         param.srrcoddig)
                          returning l_cod_erro,
		                                l_msg_erro,
	                                  mr_aux.usrcod
                     
                    
                            if l_cod_erro <> 0 then
                               error l_msg_erro sleep 2
                               #rollback work
                            else
                               #commit work
		                           let int_flag = true
		                           exit input
                            end if
                     #else
                     #   rollback  work
                     end if
                 else
                     call cts08g01("A","N",
                                  "O USUARIO PARA ACESSO A",
                                  "PORTONET DOS PRESTADORES NAO SERA CRIADO",
                                  "JA QUE O USUARIO AINDA N�O EST� LIBERADO.",
                                  "")
                     returning resp   
                 end if
               
          end if 
             
     on key (interrupt)
          exit input

    end input
    let l_lin = null
    if int_flag   then
       exit while
    end if

 end while
 
 #call ctd30g00_busca_qra_cpf("CPF", param.srrcoddig)
 #     returning l_cod_erro, 
 #               l_msg_erro,
 #               mr_ctc44m03.cgccpfnum
 #
 #display "RETORNO ctd30g00_busca_qra_cpf"
 #display "l_cod_erro           = ", l_cod_erro
 #display "l_msg_erro           = ", l_msg_erro  
 #display "d_ctc44m00.cgccpfnum = ", mr_ctc44m03.cgccpfnum

 #if  l_cod_erro = 0 then
#    call ctd40g00_usrweb_qra("A",
#                             param.srrcoddig,
#                             "",
#                             "",
#                             "",
#                             "") 
#    returning l_cod_erro,
#              l_msg_erro 
#ligia inibido em 22/08 - fornax     
 #end if

 let int_flag = false
 close c_ctc44m03

 close window w_ctc44m03

end function   ###-- ctc44m03


#-------------------------------
function ctc44m03_prepare()
#-------------------------------
        
        define l_sql   char(5000)

        let l_sql = "select max(solcntnum) " 
                   ," from datmcrhsol "  
                   ," where srrcoddig = ?  " 
                          
        prepare pctc44m03_03 from l_sql 
        declare cctc44m03_03 cursor for pctc44m03_03
        
        
        let l_sql = "select max(vigfnl) "  
                    ," from datrsrrpst "  
                   ," where srrcoddig = ?  "    

        prepare pctc44m03_04 from l_sql  
        declare cctc44m03_04 cursor for pctc44m03_04 
        
        
        let l_sql = "select max(soldat)  ",
                    "  from datmcrhsol   ",
                    " where srrcoddig = ? "
        prepare pctc44m03_05 from l_sql  
        declare cctc44m03_05 cursor for pctc44m03_05 
        
        
        let l_sql = "select empcod,                         ",
                    "       funmat                          ",
                    "  from datmcrhsol                      ",
                    " where soldat = (select max(soldat)    ",
                    "                   from datmcrhsol     ",
                    "                  where srrcoddig = ?) "
        prepare pctc44m03_06 from l_sql 
        declare cctc44m03_06 cursor for pctc44m03_06 
        
        ## consulta status atual do socorrista
        ## Jorge Modena - 16/11/2011
        let l_sql = "select srrstt, celdddcod, celtelnum, maides, srrabvnom" 
                    ," from datksrr "    
                   ," where srrcoddig = ?  "  
        prepare pctc44m03_07 from l_sql 
        declare cctc44m03_07 cursor for pctc44m03_07 
        
        ## consulta empresas que prestador do socorrista atende (Porto, Itau e Azul)
        ## Jorge Modena - 16/11/2011
        let l_sql = "select ciaempcod                          ",
                    " from dparpstemp                          ", 
                    "where pstcoddig = (select pstcoddig       ",
                    "                     from datrsrrpst      ",
                    "                    where vigfnl >= today ",
                    "                      and srrcoddig = ?)  ",
                    " and ciaempcod in (1,35,84)               "
        prepare pctc44m03_08 from l_sql  
        declare cctc44m03_08 cursor for pctc44m03_08 
               
                  
end function        
                    
#----------------------
function ctc44m03_email(srrcoddig,rlzsoltip)
#----------------------
define srrcoddig        like datksrr.srrcoddig,
       rlzsoltip        char(10)

 define lr_retorno     record
        erro           smallint,
        mensagem       char(60)
 end record

define l_sql   char(5000)
 
define l_cod_erro   integer,
       l_msg_erro   char(20),
       l_confirma   char(1),
       l_quant_dias integer, 
       arr_aux      integer
       
         
define param_popup   record      
   linha1              char (40),  
   linha2              char (40),  
   linha3              char (40),
   linha4              char (40),
   confirma            char (01)  
 end record 
 
initialize param_popup.*,lr_retorno.* to null  
initialize l_cod_erro,   
           l_msg_erro,  
           l_confirma,  
           l_quant_dias to null 
                      
initialize ma_empatdsrr to null
           
let mr_ctc44m03.srrcoddig = srrcoddig
let mr_ctc44m03.rlzsoltip = rlzsoltip 
let arr_aux = 1

let m_porto = "N"
let m_itau = "N"
let m_azul = "N"
let m_autore = ""

 
call ctc44m03_prepare()
     let data = current

call cta12m00_seleciona_datkgeral("PSOPCPATV")
   returning  lr_retorno.erro
             ,lr_retorno.mensagem 
             ,mr_ctc44m03.pcpatv   

call cta12m00_seleciona_datkgeral("PSOVINTIP") 
   returning  lr_retorno.erro 
             ,lr_retorno.mensagem  
             ,mr_ctc44m03.vintip  

call cta12m00_seleciona_datkgeral("PSOFRTRPN") 
   returning  lr_retorno.erro 
             ,lr_retorno.mensagem  
             ,mr_ctc44m03.frtrpn  
             
# Para verificar a vigencia atual daquele socorrista 
open cctc44m03_04 using srrcoddig 
fetch cctc44m03_04 into  mr_ctc44m03.vigfnl

# Para verificar se socorrista est� Ativo  
# Jorge Modena - 16/11/2011          
open cctc44m03_07 using mr_ctc44m03.srrcoddig 
fetch cctc44m03_07 into  mr_ctc44m03.srrstt, mr_aux.dddcod, 
			 mr_aux.telnum, mr_aux.maides, mr_aux.srrabvnom
close cctc44m03_07

if (mr_ctc44m03.srrstt == 1) then  

  # Verifica se a atividade principal do prestador � 1-Guincheiro e 2-Chaveiro,
  # se o respons�vel � porto socorro ou Frota daf, se a qualidade do prestador � 1-Porto
  # e se o socorrista � 1-AJUDANTE, 2-APRENDIZ, 3-AUTONOMO, 4-GESTOR ou 5-SOCORRISTA
                                                           
  let l_sql ="select distinct k.rspnom,  ",    #nome do responsavel
                     "      k.pcpatvcod, ",    #principal atividade 
                     "      k.pstcoddig, ", 
                     "      k.nomrazsoc, ", 
                     "      p.srrcoddig, ", 
                     "      s.srrabvnom, ", 
                     "      s.srrnom,    ",    
                     "      p.pstvintip, ",
                     "      s.rgenum,    ",
                     "      k.maides     ",   
                     " from dpaksocor k, ",
                     "      datksrr s,   ",
                     "      datrsrrpst p ",
                     "where s.srrcoddig = p.srrcoddig ",
                     "  and k.pstcoddig = p.pstcoddig ",
                     "  and s.srrcoddig = ? ",
                     "  and p.vigfnl = ? ",
                     "  and k.qldgracod = 1 ",              #qualidade Prestador 1-Porto
                     "  and k.pcpatvcod in (1,2)",          #principal atividade 
                     "  and k.frtrpnflg in (",mr_ctc44m03.frtrpn,")",
                     "  and p.pstvintip in (",mr_ctc44m03.vintip,")",   
                     "order by 1 "

  prepare pctc44m03_01 from l_sql
  declare cctc44m03_01 cursor for pctc44m03_01
                       
  open cctc44m03_01 using srrcoddig, 
                          mr_ctc44m03.vigfnl
                        
  # Para Crach� Porto, Azul e Itau
  fetch cctc44m03_01 into  mr_ctc44m03.rspnom,
                           mr_ctc44m03.pcpatvcod, 
                           mr_ctc44m03.pstcoddig, 
                           mr_ctc44m03.nomrazsoc, 
                           mr_ctc44m03.srrcoddig, 
                           mr_ctc44m03.srrabvnom,
                           mr_ctc44m03.srrnom ,  
                           mr_ctc44m03.pstvintip,
                           mr_ctc44m03.rgenum, 
                           mr_ctc44m03.maidespsr

  
  case sqlca.sqlcode 
      when notfound     
          # Verifica se a atividade principal do prestador � 7-hdesk, 8-lbca e 11-lbas
          # se o respons�vel � porto socorro ou Frota daf, se a qualidade do prestador � 1-Porto
          # e se o socorrista � 1-AJUDANTE, 2-APRENDIZ, 3-AUTONOMO, 4-GESTOR ou 5-SOCORRISTA
          let l_sql ="select distinct k.rspnom , ",       #nome do responsavel
                     "      k.pcpatvcod ,",               #principal atividade 
                     "      k.pstcoddig ,", 
                     "      k.nomrazsoc ,", 
                     "      p.srrcoddig ,", 
                     "      s.srrabvnom ,", 
                     "      s.srrnom ,   ",    
                     "      p.pstvintip, ",  
                     "      s.rgenum,    ", 
                     "      k.maides    ",  
                     " from dpaksocor k, ",
                     "      datksrr s,   ",
                     "      datrsrrpst p ",
                     "where s.srrcoddig = p.srrcoddig ",
                     "  and k.pstcoddig = p.pstcoddig ",
                     "  and s.srrcoddig = ? ",
                     "  and p.vigfnl = '",mr_ctc44m03.vigfnl,"'",
                     "  and k.qldgracod = 1 ",                     #qualidade Prestador 1-Porto
                     "  and k.pcpatvcod in (7,8,11)",              #principal atividade  
                     "  and k.frtrpnflg in (",mr_ctc44m03.frtrpn,")",
                     "  and p.pstvintip in (",mr_ctc44m03.vintip,") ",   
                     "order by 1 "
          prepare pctc44m03_02 from l_sql
          declare cctc44m03_02 cursor for pctc44m03_02 
          open cctc44m03_02 using srrcoddig
         
          # Para Crach� Porto e Itau
          fetch cctc44m03_02 into   mr_ctc44m03.rspnom,
                                     mr_ctc44m03.pcpatvcod, 
                                     mr_ctc44m03.pstcoddig, 
                                     mr_ctc44m03.nomrazsoc, 
                                     mr_ctc44m03.srrcoddig, 
                                     mr_ctc44m03.srrabvnom,
                                     mr_ctc44m03.srrnom ,  
                                     mr_ctc44m03.pstvintip,
                                     mr_ctc44m03.rgenum, 
                                     mr_ctc44m03.maidespsr 
          
          case sqlca.sqlcode
                when notfound
                     if(mr_ctc44m03.rlzsoltip == "Menu") then
                           error "Nao e possivel solicitar cracha para este socorrista! " sleep 2
                           display "Nao e possivel solicitar cracha para o QRA: ",mr_ctc44m03.srrcoddig
                     end if 
                when 0 
                   if(mr_ctc44m03.rlzsoltip == "Menu" ) then
		           call ctc44m03_UltimaSolicitacao(mr_ctc44m03.srrcoddig)    
		                returning param_popup.confirma  
		               
		           if  param_popup.confirma = 'S' or
		               param_popup.confirma = 's' then 
		              # seta o tipo do socorrista
		              let m_autore = "RE"
		              call ctc44m03_popup("A")
		              
		              if (int_flag) then
		              	error "Solicitacao de Cracha Cancelada" 
		              else 
		              	call ctc44m03_envia_email() 
		              end if
		           end if
	           else
	           	if(mr_ctc44m03.rlzsoltip <> "Menu" and mr_ctc44m03.rlzsoltip is not null) then
                           # Verifica se foi enviada uma solicitacao de cracha em menos de 30 dias
                            call ctc44m03_UltimaSolicitacao(mr_ctc44m03.srrcoddig)
                              returning param_popup.confirma                           
                         end if
                         # Solicita cracha automatico Porto e Itau 
                         	           
	                 if(param_popup.confirma <> "N" or param_popup.confirma is null ) then	                    
		            let m_assunto = "Solicitacao cracha Porto/Itau - ",mr_ctc44m03.srrnom
		            let mr_ctc44m03.envsoltip = 5 
		            call ctc44m03_grav_hist("Cracha Porto/Itau solicitado automaticamente.")		                  
		            call ctc44m03_envia_email()                                       
	                 end if
	           end if
          end case
          close cctc44m03_02               
      when 0
         if(mr_ctc44m03.rlzsoltip <> "Menu" and mr_ctc44m03.rlzsoltip is not null) then
            # Verifica se foi enviada uma solicitacao de cracha em menos de 30 dias
              call ctc44m03_UltimaSolicitacao(mr_ctc44m03.srrcoddig)
                   returning param_popup.confirma
         end if
         if(mr_ctc44m03.rlzsoltip == "Menu" ) then
           call ctc44m03_UltimaSolicitacao(mr_ctc44m03.srrcoddig)    
                returning param_popup.confirma  
               
           if  param_popup.confirma = 'S' or
               param_popup.confirma = 's' then 
              # seta o tipo do socorrista
              let m_autore = "AUTO"                        
              call ctc44m03_popup("A")
              
              if (int_flag) then              
              	error "Solicitacao de Cracha Cancelada" 
              else                    
              	call ctc44m03_envia_email() 
              end if
           end if                   
         else
           if (param_popup.confirma <> "N" or param_popup.confirma is null ) then             
               # Solicita cracha automatico Porto, Azul e Itau 
               let m_assunto = "Solicitacao cracha Porto/Itau/Azul - ",mr_ctc44m03.srrnom
               let mr_ctc44m03.envsoltip = 7 
               call ctc44m03_grav_hist("Cracha Porto/Itau/Azul solicitado automaticamente.")
               call ctc44m03_envia_email()   
           end if                 
         end if
  end case
  close cctc44m03_01
else
 error "Nao e possivel solicitar cracha para este socorrista, Socorrista INATIVO!" sleep 2
end if

end function

#---------------------------------
function ctc44m03_envia_email()
#---------------------------------

define cargosrr char(60)      
 
 define ctc44m03_lr_mail record
     ass                 char(500),
     msg                 char(32000)
  end record 
  
define lr_mail record
     rem char(50),
     des char(250),
     ccp char(250),
     cco char(250),
     ass char(500),
     msg char(32000),
     idr char(20),
     tip char(4)
end record  


    
define l_cod_erro integer,
       l_msg_erro char(20),
       l_data     date,
       l_hora     datetime hour to second,
       l_gstcdicod like dpaksocor.gstcdicod 
            
let cargosrr = "" 
             
let mr_ctc44m03.craenvtip = ""

       
whenever error continue

   select gstcdicod
     into l_gstcdicod
     from dpaksocor 
    where pstcoddig = mr_ctc44m03.pstcoddig 

whenever error stop 

if sqlca.sqlcode = 0   then
   
   whenever error continue
     select 1 
      from iddkdominio 
     where cponom = 'envcracha'
     and   cpocod = l_gstcdicod
   whenever error stop
   
   if sqlca.sqlcode  =  0   then 
        let mr_ctc44m03.craenvtip = 'E'
   else
        whenever error continue
   	  select 1 
   	   from iddkdominio 
   	  where cponom = 'retcracha'
   	  and   cpocod = l_gstcdicod
        whenever error stop
        
        if sqlca.sqlcode  =  0   then
           let mr_ctc44m03.craenvtip = 'R' 
        end if 
   end if
	
end if 

initialize ctc44m03_lr_mail.* to null
initialize l_cod_erro, 
           l_msg_erro,
           l_data,    
           l_hora to null   


#display "Entrei"
#display "m_assunto: ",m_assunto
     let  cargosrr = "Socorrista"  
     let l_data = today
     let l_hora = current
     whenever error continue
        select cpodes into mr_ctc44m03.envsoldes
          from iddkdominio
         where cponom = "soltip"
           and cpocod = mr_ctc44m03.envsoltip
     whenever error stop
     let ctc44m03_lr_mail.ass = m_assunto  
     let ctc44m03_lr_mail.msg ="<html>",
                             "<body>",
                                 "<br>Confeccionar crachas para atendimento ",mr_ctc44m03.envsoldes clipped, 
                                 " com as seguintes especificacoes: <br><br><b>Dados da Frente:</b> ",
                                 "<br><i>Nome frente: </i>",upshift(mr_ctc44m03.srrabvnom) clipped,
                                 "<br><i>Cargo: </i>", upshift(cargosrr) clipped,
                                 "<br><b>Dados verso:</b>",
                                 "<br><i>Nome Completo: </i>",upshift(mr_ctc44m03.srrnom) clipped,
                                 "<br><i>RG: </i>",upshift(mr_ctc44m03.rgenum) clipped,
                                 "<br><i>Empresa: </i>", upshift(mr_ctc44m03.pstcoddig) clipped," - " ,upshift(mr_ctc44m03.nomrazsoc) clipped,
                                 "<br><i>QRA: </i>",upshift(mr_ctc44m03.srrcoddig) clipped,
                                 "<br><i>Tipo envio: </i>",upshift(mr_ctc44m03.craenvtip) clipped,
                                 "<br><br><br>Em caso de duvidas, procurar pela Area de Suprimentos (fone 11 3803-2426).",
                             "</body>",
                         "</html>" 
                         
     open cctc44m03_03 using mr_ctc44m03.srrcoddig 
     fetch cctc44m03_03 into mr_ctc44m03.seqcod
     if( mr_ctc44m03.seqcod is null)then
              let mr_ctc44m03.seqcod = 1
     else 
              let mr_ctc44m03.seqcod = mr_ctc44m03.seqcod + 1
     end if
     if(mr_ctc44m03.rlzsoltip is not null and int_flag = false )then
        whenever error continue
        insert into datmcrhsol 
                          (srrcoddig,
                           soldat,
                           solcntnum,
                           envsoltip,
                           empcod,
                           funmat,
                           pstcoddig,
                           rlzsoltip) 
             values       (mr_ctc44m03.srrcoddig,
                           current,
                           mr_ctc44m03.seqcod,
                           mr_ctc44m03.envsoltip,
                           g_issk.empcod,
                           g_issk.funmat,
                           mr_ctc44m03.pstcoddig,
                           mr_ctc44m03.rlzsoltip)
        whenever error stop
        if(sqlca.sqlcode = 0) then
           call ctx22g00_envia_email_html("FCTC44M0",ctc44m03_lr_mail.ass,ctc44m03_lr_mail.msg)
                returning l_cod_erro
           
           if  l_cod_erro <> 0 then
              #display "Erro no envio do email: ",
              #        l_cod_erro using "<<<<<<&", " - ",
              #        l_msg_erro clipped
              error "Erro ao enviar a Solicitacao : ",l_cod_erro ," !"         
           else 
              initialize l_cod_erro, 
           		 l_msg_erro,
           		 l_data,    
           		 l_hora to null
           
              let mr_ctc44m03.qntemail = mr_ctc44m03.qntemail + 1
              error "Solicitacao realizada com sucesso!" 

              #Enviando email ao prestador 
              
              let l_data = today
              let l_hora = current

              let lr_mail.des = mr_ctc44m03.maidespsr 
              let lr_mail.rem = "porto.socorro@portoseguro.com.br"
              let lr_mail.ccp = ""
              let lr_mail.cco = ""
              let lr_mail.ass = m_assunto
              let lr_mail.idr = "F0110413"
              let lr_mail.tip = "html"   
              
              let lr_mail.msg = "<html>",
                                    "<body>",
                                         "<br />Prezado Prestador,<br /><br /> ",
                                         "Solicitamos, neste momento, o crach&aacute; do QRA <b>",upshift(mr_ctc44m03.srrcoddig) clipped,
                                         " - ", upshift(mr_ctc44m03.srrnom) clipped," </b>ao fornecedor.<br />"
                                         
              case mr_ctc44m03.craenvtip  
		   when 'R'  
		       let  lr_mail.msg = lr_mail.msg clipped,"<br />Em 15 dias voc&ecirc; poder&aacute; retir&aacute;-loaqui na recep&ccedil;&atilde;o do Porto Socorro.<br>"
		       exit case
		   when 'E'  
		       let  lr_mail.msg = lr_mail.msg clipped,"<br />Em 15 dias ele ser&aacute; enviado ao seu endere&ccedil;o cadastrado no sistema.<br>"
		       exit case
		   otherwise 
		       let  lr_mail.msg = lr_mail.msg clipped," "
	      end case
                                         
              let  lr_mail.msg = lr_mail.msg clipped, 
              			         
              			         "<br />O crach&aacute; &eacute; um item essencial do nosso uniforme. &Eacute; muito importante que estejamos devidamente ",
                                         "identificados durante os atendimentos.<br /><br />",
                                         "Atentamente,<br><br>Porto Socorro - Suprimentos ",
                                    "</body>",
                                 "</html>" 
           
 
              
              call figrc009_mail_send1(lr_mail.*)
                   returning l_cod_erro, l_msg_erro
                   
              if  l_cod_erro <> 0 then
                  display "Erro no envio do email ao prestador: ",
                          l_cod_erro using "<<<<<<&", " - ",
                          l_msg_erro clipped     
              end if 

              initialize mr_ctc44m03.rlzsoltip to null 
           end if
        else   
            error "Nao foi possivel realizar essa solicitacao(1) ---->> ",sqlca.sqlcode
            display "Nao foi possivel realizar essa solicitacao para o QRA: ",mr_ctc44m03.srrcoddig 
        end if
     else
        error "Nao foi possivel realizar essa solicitacao(2) ---->> ",mr_ctc44m03.rlzsoltip,"-",int_flag           
        display "Nao foi possivel realizar essa solicitacao para o QRA: ",mr_ctc44m03.srrcoddig 
     end if
     
end function
    
#-----------------------------------------------------------------------------
 function ctc44m03_popup(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01)  ###  Tipo do Cabecalho   
 end record

 define d_ctc44m03   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record 
 
 define arr_aux     integer

 initialize  d_ctc44m03.*  to  null 

 initialize  ws.*  to  null 
 
 let int_flag = true

 open window w_ctc44m03 at 11,19 with form "ctc44m03p"
           attribute(border, form line first, message line last - 1)
           
 while (int_flag)
 	 
 	 let arr_aux = 1
 	 let m_porto = "N"
         let m_itau  = "N"
         let m_azul  = "N"  
         initialize ma_empatdsrr to null
         
         clear form

	 case param.cabtip
	    when "A"  
	    	let  d_ctc44m03.cabtxt = "A T E N C A O"
	 end case

 	let d_ctc44m03.cabtxt = cts08g01_center(d_ctc44m03.cabtxt) 
 
 	#open cctc44m03_08 using mr_ctc44m03.srrcoddig 	
        #
	#	 foreach cctc44m03_08 into ma_empatdsrr[arr_aux].ciaempcod 
	#	
	#	    select empsgl
	#	      into ma_empatdsrr[arr_aux].ciaempdes
	#	      from gabkemp
	#	     where empcod  =  ma_empatdsrr[arr_aux].ciaempcod
	#	     
	#	    let arr_aux = arr_aux + 1
	#	    let ma_empatdsrr[arr_aux].aux = " "
	#	              
	#	 end foreach
		 
		 
 
 	#let arr_aux = arr_aux -1
 	
 	# n�o valida empresa por atendimento do prestador e sim chumba no c�digo
 	# solicitacao Luis Melo - Porto Socorro
 	
 	if (m_autore = "AUTO") then
 	    let ma_empatdsrr[1].ciaempcod = 1
 	    let ma_empatdsrr[1].ciaempdes = "PORTO"
 	    let ma_empatdsrr[1].aux = " "
 	
 	    let ma_empatdsrr[2].ciaempcod = 35
 	    let ma_empatdsrr[2].ciaempdes = "AZUL"
 	    let ma_empatdsrr[2].aux = " "
 	
 	    let ma_empatdsrr[3].ciaempcod = 84
 	    let ma_empatdsrr[3].ciaempdes = "ITAU"
 	    let ma_empatdsrr[3].aux = " "
 	    
 	    let arr_aux = 3
 	
 	else
 	    let ma_empatdsrr[1].ciaempcod = 1
 	    let ma_empatdsrr[1].ciaempdes = "PORTO"
 	    let ma_empatdsrr[1].aux = " "
 	
 	    let ma_empatdsrr[2].ciaempcod = 84
 	    let ma_empatdsrr[2].ciaempdes = "ITAU"
 	    let ma_empatdsrr[2].aux = " "
 	    
 	    let arr_aux = 2
 	
 	end if 	
 	 
 	display by name d_ctc44m03.cabtxt  attribute (reverse) 
 	  
 	call set_count(arr_aux) 
 	
 	input array ma_empatdsrr without defaults from s_empresas.*  
	    	
	    	before row
	               let m_arr_curr = arr_curr()
	               let m_scr_curr = scr_line() 
	               
	               
	               
	         before field ciaempcod
                 display ma_empatdsrr[m_scr_curr].aux to 
                          s_empresas[m_scr_curr].aux attribute(reverse)
                            
	         after field ciaempcod
	         display ma_empatdsrr[m_scr_curr].aux to 
	                  s_empresas[m_scr_curr].aux 	
	         after row
	               let m_arr_curr = arr_curr()
	               let m_scr_curr = scr_line()  
	               
	               if (ma_empatdsrr[m_scr_curr].ciaempcod is null) then
	               	   let  ma_empatdsrr[m_scr_curr].aux = " "    
	               end if 
	
	        on key (F8)  
	        
	        #display "Quantidade registro ", m_arr_curr   
	                             
	           for i = 1 to arr_aux            		
	           	if (ma_empatdsrr[i].aux = "X" or ma_empatdsrr[i].aux ="x") then
	           		case ma_empatdsrr[i].ciaempcod 		    
				    when 1  
				        let m_porto = "S"    
				    when 35
				    	let m_azul = "S"    
				    when 84
				    	let m_itau = "S"    
				 end case 
	           	end if 
	           end for
	           
	           # solicita cracha conforme empresa que prestador presta servi�os  
	           
	           if (m_porto = "N" and m_itau = "N" and m_azul = "N") then
	               initialize d_ctc44m03.confirma to null
	               error "Opcao invalida! Escolha uma opcao e confirme com F8"	               
	               exit input               
	           end if 
	                          
	           if (m_porto = "S" and m_itau = "N" and m_azul = "S") then
	               let m_assunto = "Solicitacao cracha Porto/Azul - ",mr_ctc44m03.srrnom
	               let mr_ctc44m03.envsoltip = 1  
	               call ctc44m03_grav_hist("Cracha Porto/Azul solicitado manualmente.")
	           end if
	                 
	           if (m_porto = "S" and m_itau = "N" and m_azul = "N") then
	               let m_assunto = "Solicitacao cracha Porto - ",mr_ctc44m03.srrnom
	               let mr_ctc44m03.envsoltip = 2   
	               call ctc44m03_grav_hist("Cracha Porto solicitado manualmente.")      
	           end if 
	                 
	           if (m_porto = "N" and m_itau = "N" and m_azul = "S") then
	               let m_assunto = "Solicitacao cracha Azul - ",mr_ctc44m03.srrnom
	               let mr_ctc44m03.envsoltip = 3 
	               call ctc44m03_grav_hist("Cracha Azul solicitado manualmente.")
	           end if 
	                 
	           if (m_porto = "N" and m_itau = "S" and m_azul = "N") then 
	              let m_assunto = "Solicitacao cracha Itau - ",mr_ctc44m03.srrnom
	              let mr_ctc44m03.envsoltip = 4 
	              call ctc44m03_grav_hist("Cracha Itau solicitado manualmente.")
	           end if 
	                 
	           if (m_porto = "S" and m_itau = "S" and m_azul = "N") then
	               let m_assunto = "Solicitacao cracha Porto/Itau - ",mr_ctc44m03.srrnom
	               let mr_ctc44m03.envsoltip = 5 
	               call ctc44m03_grav_hist("Cracha Porto/Itau solicitado manualmente.")
	           end if                        
	                                         
	           if (m_porto = "N" and m_itau = "S" and m_azul = "S") then
	               let m_assunto = "Solicitacao cracha Itau/Azul - ",mr_ctc44m03.srrnom
	               let mr_ctc44m03.envsoltip = 6 
	               call ctc44m03_grav_hist("Cracha Itau/Azul solicitado manualmente.") 
	           end if
	                 
	           if (m_porto = "S" and m_itau = "S" and m_azul = "S") then
	               let m_assunto = "Solicitacao cracha Porto/Itau/Azul - ",mr_ctc44m03.srrnom
	               let mr_ctc44m03.envsoltip = 7 
	               call ctc44m03_grav_hist("Cracha Porto/Itau/Azul solicitado manualmente.")	               
	           end if      
	           
	           let int_flag = false
	           exit while

	      on key (interrupt, control-c)
	         exit while
	         
    end input
 end while 
 
 #display "Tipo de solicitacao" ,  mr_ctc44m03.envsoltip
        
 close window w_ctc44m03
end function  ###  cts08g01

#-----------------------------------------------------------------------------
function ctc44m03_grav_hist(param)
#-----------------------------------------------------------------------------

#variaveis Robert Lima      
define param        record                      
       mesg     char(3000)
end record

define l_mensagem char(100)
######### 


#Alteracao realizada por Robert Lima        
let l_mensagem = 'Solicitacao do cracha para socorrista. Codigo : ',
                  mr_ctc44m03.srrcoddig    
                  
if not ctc44m00_grava_hist(mr_ctc44m03.srrcoddig
                          ,param.mesg
                          ,today
                          ,l_mensagem,"A") then     
    error "Erro gravacao Historico " 
end if   
#####################


end function

#----------------------
function ctc44m03_UltimaSolicitacao(param)
#----------------------
define param      record
     srrcoddig    like datksrr.srrcoddig
end record

define l_data_sol  date,
       l_dia_hoje  date,
       l_data_lim  date 

define l_confirma char(1) # Confirma igual a S eh para o operador confirma se quer enviar o cracha
                          # igual a N o Operador nao tem que confirmar
 
define l_quant_dias integer

define param_popup   record      
   linha1              char (40),  
   linha2              char (40),  
   linha3              char (40),
   linha4              char (40),
   confirma            char (01)  
 end record 

define l_funnom    like isskfunc.funnom

initialize l_data_sol,
           l_dia_hoje,
           l_data_lim,
           l_confirma to null

initialize param_popup.* to null


call  busca_func(mr_ctc44m03.srrcoddig)    
     returning l_funnom                    

#display "l_funnom: ",l_funnom

whenever error continue

    open cctc44m03_05 using  param.srrcoddig
    fetch cctc44m03_05 into l_data_sol

whenever error stop
 
# display "1 l_data_sol: ",l_data_sol
 let l_data_sol = date(l_data_sol) 
 let l_dia_hoje = today
 let l_data_lim = l_data_sol + 30 units day
 let l_quant_dias = l_dia_hoje - l_data_sol
# display "2 l_data_sol: ",l_data_sol
# display "l_dia_hoje: ",l_dia_hoje
# display "l_quant_dias: ",l_quant_dias
# display "l_data_lim: ",l_data_lim
 
 if l_data_lim > l_dia_hoje  then
    let l_confirma = 'S'
 else
    let l_confirma = 'N'
 end if
 
# display "confirma: ",l_confirma
 
 
 if l_confirma = 'S' then
    let param_popup.linha1   = "ATENCAO: Este cracha foi solicitado "
    let param_popup.linha2   = "    a ",l_quant_dias using "<<<<<<&"," dia(s) por ",l_funnom clipped,"."       
    let param_popup.linha3   = "    Deseja solicitar novamente "
    let param_popup.linha4   = "     cracha para este socorrista?"
 else
    let param_popup.linha1   = " "
    let param_popup.linha2   = "ATENCAO: Sera encaminhada um solicitacao" 
    let param_popup.linha3   = "      de cracha para este socorrista."
    let param_popup.linha4   = " "   
 end if
 
 let param_popup.confirma = abre_popup(param_popup.linha1,
                                       param_popup.linha2,
                                       param_popup.linha3,
                                       param_popup.linha4)
 
 
 return param_popup.confirma

end function


#----------------------  
function abre_popup(param_linha)
#---------------------- 

define param_linha   record      
   linha1              char (40),  
   linha2              char (40),  
   linha3              char (40),
   linha4              char (40) 
 end record 
 
 define l_confirma     char (01) 
 
 let l_confirma = cts08g01("A","F",param_linha.linha1,
                                  param_linha.linha2, 
                                  param_linha.linha3, 
                                  param_linha.linha4)
 return l_confirma
 
end function


#----------------------            
function busca_func(param)   
#----------------------   

define param      record
     srrcoddig    like datksrr.srrcoddig
end record

define lr_func  record
    empcod    like datmcrhsol.empcod,  
    funmat    like datmcrhsol.funmat,
    funnom    like isskfunc.funnom
end record


whenever error continue
 open cctc44m03_06 using  param.srrcoddig
 fetch cctc44m03_06 into lr_func.empcod,
                         lr_func.funmat
whenever error stop

  # Verifica o nome do funcionario que atualizou o envio de cracha    
  call ctc44m00_func(lr_func.empcod, lr_func.funmat)                    
       returning lr_func.funnom                                    
                                                                      
 return lr_func.funnom 
 
end function         
