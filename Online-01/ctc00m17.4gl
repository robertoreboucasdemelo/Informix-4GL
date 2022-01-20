#############################################################################
# Menu de Modulo: ctc00m17                                         Adriano  #
#                                                                           #
# Controle de vigencia de contrato do prestador                   Out/2009  #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                                                                           #
#############################################################################


 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc00m17(param)
#---------------------------------------------------------------

 define param        record
    pstcoddig        like dpaksocor.pstcoddig,
    nomgrr           like dpaksocor.nomgrr
 end record

 define a_ctc00m17   array[30] of record
    cntvigincdat     like dpakprscntvigctr.cntvigincdat,
    cntvigfnldat     like dpakprscntvigctr.cntvigfnldat,
    atldat           like dpakprscntvigctr.atldat      ,
    altfunnom        like isskfunc.funnom  
 end record

 define ws           record
    cntvigincdat     like dpakprscntvigctr.cntvigincdat,
    cntvigincdat2    like dpakprscntvigctr.cntvigincdat,
    cntvigfnldat     like dpakprscntvigctr.cntvigfnldat,
    atldat           like dpakprscntvigctr.atldat      ,
    atlemp           like dpakprscntvigctr.atlemp      ,
    atlusrtip        like dpakprscntvigctr.atlusrtip   ,
    atlmat           like dpakprscntvigctr.atlmat      ,    
    confirma         char(1)                           ,
    operacao         char(1)   
 end record
 
 define l_total      smallint
 
 define arr_aux      integer
 define scr_aux      integer
 define l_msg        char(500)
 define l_mensagem   char(100)
 define l_erro       smallint

 define l_assunto char(300)
 define l_retorno integer

 let l_assunto = ""
 let l_retorno = 0

 initialize a_ctc00m17  to null
 initialize ws.*        to null
 let int_flag  =  false
 let arr_aux   =  1
 
 open window w_ctc00m17 at 06,02 with form "ctc00m17"
      attribute(form line first, comment line last - 1)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    message " (F17)Abandona"
 else
    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"
 end if


 declare c_ctc00m17  cursor for
   select dpakprscntvigctr.cntvigincdat,
          dpakprscntvigctr.cntvigfnldat,
          dpakprscntvigctr.atldat,
          dpakprscntvigctr.atlemp,
          dpakprscntvigctr.atlusrtip,
          dpakprscntvigctr.atlmat
     from dpakprscntvigctr
    where dpakprscntvigctr.pstcoddig  =  param.pstcoddig
    order by cntvigincdat desc


 foreach c_ctc00m17 into  a_ctc00m17[arr_aux].cntvigincdat,
                          a_ctc00m17[arr_aux].cntvigfnldat,
                          a_ctc00m17[arr_aux].atldat      ,
                          ws.atlemp                       ,  
                          ws.atlusrtip                    ,
                          ws.atlmat   
                              

    call ctc00m17_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)       
         returning a_ctc00m17[arr_aux].altfunnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, socorrista com mais de 30 vinculos!"
       exit foreach
    end if

 end foreach
 
 let l_total = arr_aux - 1

 #---------------------------------------------------------------
 # Nivel de acesso apenas para consulta
 #---------------------------------------------------------------
 call set_count(arr_aux-1)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display l_total to total
    display array a_ctc00m17 to s_ctc00m17.*
    
       on key (interrupt,control-c)
          initialize a_ctc00m17  to null
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

    let int_flag = false

    input array a_ctc00m17  without defaults from  s_ctc00m17.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          display l_total to total
          if arr_aux <= arr_count()  then
             let ws.operacao  =  "a"
             let ws.cntvigincdat    =  a_ctc00m17[arr_aux].cntvigincdat
             let ws.cntvigfnldat    =  a_ctc00m17[arr_aux].cntvigfnldat
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc00m17[arr_aux]  to null
          initialize ws.cntvigincdat     to null
          initialize ws.cntvigincdat2    to null
          initialize ws.cntvigfnldat     to null
          initialize ws.atldat           to null
          initialize ws.atlemp           to null
          initialize ws.atlusrtip        to null
          initialize ws.atlmat           to null
          
          display a_ctc00m17[arr_aux].*   to  s_ctc00m17[scr_aux].*
          let l_total = arr_aux - 1
          display l_total to total

       before field cntvigincdat
          display a_ctc00m17[arr_aux].cntvigincdat   to
                  s_ctc00m17[scr_aux].cntvigincdat   attribute (reverse)

       after field cntvigincdat
          display a_ctc00m17[arr_aux].cntvigincdat   to
                  s_ctc00m17[scr_aux].cntvigincdat

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc00m17[arr_aux].cntvigincdat  is null   then
             error " Vigencia inicial deve ser informada!"
             next field cntvigincdat
          end if

          if ws.operacao                 <>  "i"         and
             a_ctc00m17[arr_aux].cntvigincdat  <>  ws.cntvigincdat   then
             error " Vigencia inicial nao deve ser alterada!"
             next field cntvigincdat
          end if

          if a_ctc00m17[arr_aux].cntvigincdat  >  today + 30 units day   then
             error " Vigencia inicial nao deve ser superior a 30 dias!"
             next field cntvigincdat
          end if
          
          # CT 7063816 
          # if a_ctc00m17[arr_aux].viginc  <  today - 10 units year  then
          #    error " Vigencia inicial nao deve ser anterior a 10 anos!"
          #    next field viginc
          # end if

          if ws.operacao  =   "i"                          or
             ws.cntvigincdat    <>  a_ctc00m17[arr_aux].cntvigincdat   then

             select pstcoddig
               from dpakprscntvigctr
              where dpakprscntvigctr.pstcoddig  =  param.pstcoddig
                and a_ctc00m17[arr_aux].cntvigincdat  between cntvigincdat and cntvigfnldat

             if sqlca.sqlcode  =  0   then
                error " Vigencia inicial ja' compreendida em outro periodo!"
                next field  cntvigincdat
             end if

          end if

       before field cntvigfnldat
          display a_ctc00m17[arr_aux].cntvigfnldat   to
                  s_ctc00m17[scr_aux].cntvigfnldat   attribute (reverse)

       after field cntvigfnldat
          display a_ctc00m17[arr_aux].cntvigfnldat   to
                  s_ctc00m17[scr_aux].cntvigfnldat

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   then
             let ws.operacao = " "
          else
             if fgl_lastkey() = fgl_keyval("left")   then
                next field cntvigincdat
             end if
          end if

          if a_ctc00m17[arr_aux].cntvigfnldat  is null   then
             error " Vigencia final deve ser informada!"
             next field cntvigfnldat
          end if

          if a_ctc00m17[arr_aux].cntvigfnldat  <  today - 10 units year  then
             error " Vigencia final nao deve ser anterior a 10 anos!"
             next field cntvigfnldat
          end if

          if a_ctc00m17[arr_aux].cntvigfnldat  <=  a_ctc00m17[arr_aux].cntvigincdat   then
            error " Vigencia final nao deve ser menor/igual a vigencia inicial!"
            next field cntvigfnldat
          end if

          if ws.operacao  =   "i"                          or
             ws.cntvigfnldat    <>  a_ctc00m17[arr_aux].cntvigfnldat   then

             select cntvigincdat
               into ws.cntvigincdat2
               from dpakprscntvigctr
              where dpakprscntvigctr.pstcoddig  =  param.pstcoddig
                and a_ctc00m17[arr_aux].cntvigfnldat  between cntvigincdat and cntvigfnldat

             if sqlca.sqlcode  =   0                            and
                ws.cntvigincdat2     <>  a_ctc00m17[arr_aux].cntvigincdat   then
                error " Vigencia final ja' compreendida em outro periodo!"
                next field  vigfnl
             end if

             select pstcoddig
               from dpakprscntvigctr
              where dpakprscntvigctr.pstcoddig  =  param.pstcoddig
                and dpakprscntvigctr.cntvigincdat     >  a_ctc00m17[arr_aux].cntvigincdat
                and dpakprscntvigctr.cntvigfnldat     <  a_ctc00m17[arr_aux].cntvigfnldat

             if sqlca.sqlcode  =  0   then
                error " Vigencia ja' compreendida em outro periodo!"
                next field  cntvigfnldat
             end if

          end if
          
	      ##PSI206679 - inicio
        #if ws.operacao = "i" then
        #	  #let l_assunto = "Inclusão no QRA: ", param.srrcoddig, " ", param.srrnom, " - Solicite um novo crachá"
	    	#    #call ctx22g00_envia_email("ctc00m17", l_assunto, "") returning l_retorno
	    	#    #if l_retorno <> 0 then
	    	#    #	error "Erro ao enviar email"
	    	#    #else
	    	#    #	error "Email enviado com sucesso"
	    	#    #end if
	      #else
	      #	  if ws.operacao = "a" and  a_ctc00m17[arr_aux].pstcoddig  <>  ws.pstcoddig or
	      #	  a_ctc00m17[arr_aux].viginc  <>  ws.viginc or a_ctc00m17[arr_aux].vigfnl  <>  ws.vigfnl then
        #                 	let l_assunto = "Alteração no QRA: ", param.srrcoddig, " ", param.srrnom, " - Solicite um novo crachá"
        #                 	call ctx22g00_envia_email("ctc00m17", l_assunto, "") returning l_retorno
	      #	   	if l_retorno <> 0 then
	      #	   		error "Erro ao enviar email"
	      #	   	else
	      #	  	 	error "Email enviado com sucesso"
	      #	   	end if
	      #	  end if
	      #end if
	      ##PSI206679 - fim

      before delete
         let ws.operacao = "d"

         #select prssitcod
         #  into ws.prssitcod
         #  from dpaksocor
         # where pstcoddig  =  a_ctc00m17[arr_aux].pstcoddig
         #
         #if ws.prssitcod  <>  "A"   then
         #   error " Prestador cancelado, vigencia nao deve ser removido!"
         #   exit input
         #end if

         if a_ctc00m17[arr_aux].cntvigincdat  is null   then
            continue input
         else
            let  ws.confirma  =  "N"
            call cts08g01("A","S", "","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                 returning ws.confirma

            if ws.confirma  =  "N"   then
               display a_ctc00m17[arr_aux].* to s_ctc00m17[scr_aux].*
               let l_total = arr_aux - 1
               display l_total to total
               exit input
            end if

            begin work
               delete
                 from dpakprscntvigctr
                where dpakprscntvigctr.pstcoddig        =  param.pstcoddig
                  and dpakprscntvigctr.cntvigincdat     =  a_ctc00m17[arr_aux].cntvigincdat
            commit work

            let l_msg = "Vigencia ",
		                    a_ctc00m17[arr_aux].cntvigincdat,"-", 
			                  a_ctc00m17[arr_aux].cntvigfnldat, " Deletada!"

            call ctc00m02_grava_hist(param.pstcoddig, 
                                     l_msg,"E") 
                                     
            initialize a_ctc00m17[arr_aux].* to null
            display    a_ctc00m17[arr_aux].* to s_ctc00m17[scr_aux].*
            let l_total = arr_aux - 1
            display l_total to total
         end if

       after row
                          
             case ws.operacao
               when "i"
                 begin work
                 
                    insert into dpakprscntvigctr ( pstcoddig,
                                                   cntvigincdat,
                                                   cntvigfnldat,
                                                   atldat,
                                                   atlemp,
                                                   atlusrtip,
                                                   atlmat )
                                        values   ( param.pstcoddig,
                                                   a_ctc00m17[arr_aux].cntvigincdat,
                                                   a_ctc00m17[arr_aux].cntvigfnldat,
                                                   today,
                                                   g_issk.empcod,
                                                   g_issk.usrtip,
                                                   g_issk.funmat )

                 commit work

                 let l_total = l_total - 1
                 
                 let a_ctc00m17[arr_aux].atldat = today                                 
                                                                                        
                 display a_ctc00m17[arr_aux].atldat      to                             
                         s_ctc00m17[scr_aux].atldat                                     
                                                                                        
                 call ctc00m17_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)       
                      returning a_ctc00m17[arr_aux].altfunnom                           
                                                                                        
                 display a_ctc00m17[arr_aux].altfunnom to s_ctc00m17[scr_aux].altfunnom 
                 
                 let l_msg = "Vigencia ",
		                         a_ctc00m17[arr_aux].cntvigincdat,"-", 
			                       a_ctc00m17[arr_aux].cntvigfnldat, " Incluida!"

                 call ctc00m02_grava_hist(param.pstcoddig,
                                          l_msg,"I")

               when "a"
                 begin work
                    update dpakprscntvigctr set ( cntvigfnldat,
                                                  atldat,   
                                                  atlemp,   
                                                  atlusrtip,
                                                  atlmat ) 
                                             =  ( a_ctc00m17[arr_aux].cntvigfnldat,
                                                  today,         
                                                  g_issk.empcod, 
                                                  g_issk.usrtip, 
                                                  g_issk.funmat )
                     where dpakprscntvigctr.pstcoddig = param.pstcoddig
                       and dpakprscntvigctr.cntvigincdat    = a_ctc00m17[arr_aux].cntvigincdat

                 commit work
                 
                 let l_msg = "Vigencia ",
		                         a_ctc00m17[arr_aux].cntvigincdat,"-", a_ctc00m17[arr_aux].cntvigfnldat,
		                            " Alterada!"

                 call ctc00m02_grava_hist(param.pstcoddig,
                                          l_msg,"A")
                 
                 let l_total = l_total + 1
                 
             end case
             
          display l_total to total

          let ws.operacao = " "

      on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false
 close c_ctc00m17

 close window w_ctc00m17

end function   ###-- ctc00m17


#---------------------------------------------------------
function ctc00m17_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat,
    usrtip            like isskfunc.usrtip
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record
 
 define l_sql         char(200)

 initialize ws.*    to null

 let l_sql = " select funnom    "             
            ," from isskfunc    "             
            ," where empcod = ? "             
            ,"   and funmat = ? "             
            ,"   and usrtip = ? "             
 prepare pctc00m17006 from l_sql              
 declare cctc00m17006 cursor for pctc00m17006 
 
 open cctc00m17006 using param.empcod, param.funmat, param.usrtip
 fetch cctc00m17006 into ws.funnom
 if sqlca.sqlcode  =  notfound   then
    error "Problemas ao buscar nome do funcionario do cadastro do tipo de natureza!"
 end if

 return ws.funnom

end function   # ctc00m17_func