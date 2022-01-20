############################################################################
# Menu de Modulo: ctc34m08                                        Gilberto #
#                                                                  Marcelo #
# Manutencao no Relacionamento Veiculos/Equipamento/Fabricantes   Set/1998 #
############################################################################
#..........................................................................#
#                  * * *  ALTERACOES  * * *                                #
#                                                                          #
# Data       Autor Fabrica PSI       Alteracao                             #
# --------   ------------- ------    --------------------------------------#
# 06/08/2008 Eliane, META  PSI226300 Manutencao no cadastro loja de equipa-#
#                                    mento do veiculo.                     #
# 30/11/2010 Burini                  Filtro por naturezas ativas           #
#--------------------------------------------------------------------------#

# database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc34m08(param)
#---------------------------------------------------------------

 define param        record
    socvclcod        like datreqpvcl.socvclcod,
    atdvclsgl        like datkveiculo.atdvclsgl,
    vcldes           char (58)
 end record

 define a_ctc34m08   array[30] of record
    soceqpcod        like datreqpvcl.soceqpcod,
    soceqpabv        like datkvcleqp.soceqpabv,
    eqpfabcod        like datreqpvcl.eqpfabcod,
    eqpfababv        like datkeqpfab.eqpfababv,
    caddat           like datreqpvcl.caddat,
    cadfunnom        like isskfunc.funnom
 end record

 define ws           record
    soceqpcod        like datreqpvcl.soceqpcod,
    soceqpstt        like datkvcleqp.soceqpstt,
    soceqpfabobrflg  like datkvcleqp.soceqpfabobrflg,
    eqpfabstt        like datkeqpfab.eqpfabstt,
    cademp           like datreqpvcl.cademp,
    cadmat           like datreqpvcl.cadmat,
    operacao         char (01)
 end record

 define lr_ctc34m08  record
                     soceqpcod  like datreqpvcl.soceqpcod
                   , soceqpabv  like datkvcleqp.soceqpabv
                   , eqpfabcod  like datreqpvcl.eqpfabcod
                   , eqpfababv  like datkeqpfab.eqpfababv
                   , caddat     like datreqpvcl.caddat
                   , cadfunnom  like isskfunc.funnom
                 end record

 define arr_aux      smallint
 define scr_aux      smallint
 define l_msg        char(100)
 define l_errcod     smallint
 define l_errmsg     char(200)
 define l_caminho    char(60)
 define l_stt        smallint
 define l_erro       smallint
 define l_titulo     char(100)


 if not get_niv_mod(g_issk.prgsgl, "ctc34m08") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 initialize a_ctc34m08  to null
 initialize ws.*        to null
 initialize lr_ctc34m08 to null
 let int_flag  =  false
 let arr_aux   =  1
 let l_msg     = null
 let l_errcod  = null
 let l_errmsg  = null
 let l_caminho = null
 let l_stt     = null

 open window w_ctc34m08 at 06,02 with form "ctc34m08"
      attribute(form line first, comment line last - 2)

 display by name param.socvclcod   attribute(reverse)
 display by name param.atdvclsgl   attribute(reverse)
 display by name param.vcldes      attribute(reverse)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    message " (F17)Abandona"
 else
    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"
 end if


 declare c_ctc34m08  cursor for
    select datreqpvcl.soceqpcod,                            
           datkvcleqp.soceqpabv,                            
           datreqpvcl.eqpfabcod,                            
           datreqpvcl.caddat,                               
           datreqpvcl.cademp,                               
           datreqpvcl.cadmat,                               
           datkeqpfab.eqpfababv                             
      from datreqpvcl, datkvcleqp, outer datkeqpfab         
     where datreqpvcl.socvclcod  =  param.socvclcod                    
       and datkvcleqp.soceqpcod  =  datreqpvcl.soceqpcod    
       and datkeqpfab.eqpfabcod  =  datreqpvcl.eqpfabcod    
       and datkvcleqp.soceqpstt  = 'A'                      

 foreach c_ctc34m08 into  a_ctc34m08[arr_aux].soceqpcod,
                          a_ctc34m08[arr_aux].soceqpabv,
                          a_ctc34m08[arr_aux].eqpfabcod,
                          a_ctc34m08[arr_aux].caddat,
                          ws.cademp,
                          ws.cadmat,
                          a_ctc34m08[arr_aux].eqpfababv

    call ctc34m08_func (ws.cademp, ws.cadmat)
         returning a_ctc34m08[arr_aux].cadfunnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, veiculo com mais de 30 equipamentos!"
       exit foreach
    end if
 end foreach


#---------------------------------------------------------------
# Nivel de acesso apenas para consulta
#---------------------------------------------------------------
 call set_count(arr_aux-1)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display array a_ctc34m08 to s_ctc34m08.*

       on key (interrupt,control-c)
          initialize a_ctc34m08  to null
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

    input array a_ctc34m08  without defaults from  s_ctc34m08.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
             let ws.soceqpcod   =  a_ctc34m08[arr_aux].soceqpcod
          end if
          let lr_ctc34m08.soceqpcod = a_ctc34m08[arr_aux].soceqpcod
          let lr_ctc34m08.soceqpabv = a_ctc34m08[arr_aux].soceqpabv
          let lr_ctc34m08.eqpfabcod = a_ctc34m08[arr_aux].eqpfabcod
          let lr_ctc34m08.eqpfababv = a_ctc34m08[arr_aux].eqpfababv
          let lr_ctc34m08.caddat    = a_ctc34m08[arr_aux].caddat   
          let lr_ctc34m08.cadfunnom = a_ctc34m08[arr_aux].cadfunnom

       before insert
          let ws.operacao = "i"
          initialize a_ctc34m08[arr_aux]  to null
          display a_ctc34m08[arr_aux].*  to  s_ctc34m08[scr_aux].*

       before field soceqpcod
          display a_ctc34m08[arr_aux].soceqpcod   to
                  s_ctc34m08[scr_aux].soceqpcod   attribute (reverse)

       after field soceqpcod
          display a_ctc34m08[arr_aux].soceqpcod   to
                  s_ctc34m08[scr_aux].soceqpcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if fgl_lastkey() = fgl_keyval("down")   and
             ws.operacao   = "i"                  then
             next field soceqpcod
          end if

          if a_ctc34m08[arr_aux].soceqpcod   is null   then
             error " Equipamento deve ser informado!"
             call ctn37c00()  returning  a_ctc34m08[arr_aux].soceqpcod
             next field soceqpcod
          end if

          select soceqpstt,
                 soceqpabv,
                 soceqpfabobrflg
            into ws.soceqpstt,
                 a_ctc34m08[arr_aux].soceqpabv,
                 ws.soceqpfabobrflg
            from datkvcleqp
           where datkvcleqp.soceqpcod = a_ctc34m08[arr_aux].soceqpcod

          if sqlca.sqlcode  =  notfound   then
             error " Equipamento nao cadastrado!"
             call ctn37c00()  returning  a_ctc34m08[arr_aux].soceqpcod
             next field soceqpcod
          end if

          if ws.soceqpstt  <>  "A"   then
             error " Equipamento cancelado!"
             next field soceqpcod
          end if

          display a_ctc34m08[arr_aux].soceqpabv   to
                  s_ctc34m08[scr_aux].soceqpabv

          #-------------------------------------------------------------
          # Verifica se equipamento ja' cadastrado (inclusao)
          #-------------------------------------------------------------
          if ws.operacao  =  "i"   then
             select soceqpcod
               from datreqpvcl
              where datreqpvcl.socvclcod = param.socvclcod
                and datreqpvcl.soceqpcod = a_ctc34m08[arr_aux].soceqpcod
             if sqlca.sqlcode  =  0   then
                error " Equipamento ja' cadastrado!"
                next field soceqpcod
             end if
          end if

          if ws.operacao  =  "a"   then
             if ws.soceqpcod  <>  a_ctc34m08[arr_aux].soceqpcod    then
                error " Equipamento nao deve ser alterado!"
                next field soceqpcod
             end if
          end if

       before field eqpfabcod
          display a_ctc34m08[arr_aux].eqpfabcod   to
                  s_ctc34m08[scr_aux].eqpfabcod   attribute (reverse)

       after field eqpfabcod
          display a_ctc34m08[arr_aux].eqpfabcod   to
                  s_ctc34m08[scr_aux].eqpfabcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field soceqpcod
          end if

          if fgl_lastkey() = fgl_keyval("down")   then
             next field eqpfabcod
          end if

          if ws.soceqpfabobrflg  =  "S"   then
             if a_ctc34m08[arr_aux].eqpfabcod   is null   then
                error " Para este equipamento, fabricante deve ser informado!"
                call ctn35c00()  returning  a_ctc34m08[arr_aux].eqpfabcod
                next field eqpfabcod
             end if

             select eqpfabstt, eqpfababv
               into ws.eqpfabstt, a_ctc34m08[arr_aux].eqpfababv
               from datkeqpfab
              where datkeqpfab.eqpfabcod = a_ctc34m08[arr_aux].eqpfabcod

             if sqlca.sqlcode  =  notfound   then
                error " Fabricante nao cadastrado!"
                call ctn35c00()  returning  a_ctc34m08[arr_aux].eqpfabcod
                next field eqpfabcod
             end if

             if ws.operacao  =  "i"   then
                if ws.eqpfabstt  <>  "A"   then
                   error " Fabricante cancelado!"
                   next field eqpfabcod
                end if
             end if

             display a_ctc34m08[arr_aux].eqpfababv   to
                     s_ctc34m08[scr_aux].eqpfababv
          end if

      on key (interrupt)
          exit input

      before delete
         let ws.operacao = "d"
         if a_ctc34m08[arr_aux].soceqpcod   is null   then
            continue input
         else
            if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
               exit input
            end if

            begin work
               delete
                 from datreqpvcl
                where datreqpvcl.socvclcod = param.socvclcod
                  and datreqpvcl.soceqpcod = a_ctc34m08[arr_aux].soceqpcod
            commit work
            
            let l_msg = 'Equipamento [',a_ctc34m08[arr_aux].soceqpcod clipped,'-',
                a_ctc34m08[arr_aux].soceqpabv clipped,']. Excluido!'
            call ctb85g01_grava_hist( 1
                                    , param.socvclcod
                                    , l_msg
                                    , today
                                    , g_issk.empcod
                                    , g_issk.funmat 
                                    , g_issk.usrtip )
               returning l_errcod
                       , l_errmsg  
                       
            if l_errcod = 0 then
               let l_titulo = 'Delecao no cadastro de equipamento ',
			  ' de veiculo. Codigo: ',param.socvclcod 
	       call ctb85g01_mtcorpo_email_html('CTC34M01',
	   		                a_ctc34m08[arr_aux].caddat,
	   		                current hour to minute,
	   		                g_issk.empcod,
	   		                g_issk.usrtip,
			                g_issk.funmat,
			                l_titulo,
			                l_msg)
			returning l_erro

            end if

            initialize a_ctc34m08[arr_aux].* to null
            display    a_ctc34m08[arr_aux].* to s_ctc34m08[scr_aux].*
         end if

       after row
          begin work
             case ws.operacao
               when "i"
                   let a_ctc34m08[arr_aux].caddat = today

                   insert into datreqpvcl ( socvclcod,
                                            soceqpcod,
                                            eqpfabcod,
                                            caddat,
                                            cademp,
                                            cadmat )
                               values     ( param.socvclcod,
                                            a_ctc34m08[arr_aux].soceqpcod,
                                            a_ctc34m08[arr_aux].eqpfabcod,
                                            a_ctc34m08[arr_aux].caddat,
                                            g_issk.empcod,
                                            g_issk.funmat )
                   
                   let l_msg = 'Equipamento [', a_ctc34m08[arr_aux].soceqpcod clipped,
                       '-',a_ctc34m08[arr_aux].soceqpabv clipped,']. Incluido!'

                   call ctb85g01_grava_hist( 1
                                           , param.socvclcod
                                           , l_msg
                                           , today
                                           , g_issk.empcod
                                           , g_issk.funmat 
                                           , g_issk.usrtip )
                      returning l_errcod
                              , l_errmsg  
                              
                   if l_errcod = 0 then
                      let l_titulo = 'Inclusao no cadastro de equipamento ',
				' de veiculo.Codigo: ', param.socvclcod 
	              call ctb85g01_mtcorpo_email_html('CTC34M01',
	   	       	                       a_ctc34m08[arr_aux].caddat,
	   	       	                       current hour to minute,
	   		                       g_issk.empcod,
	   		                       g_issk.usrtip,
			                       g_issk.funmat,
			                       l_titulo,
			                       l_msg)
		       	       returning l_erro

                   end if

                   display a_ctc34m08[arr_aux].caddat      to
                           s_ctc34m08[scr_aux].caddat

                   call ctc34m08_func (g_issk.empcod, g_issk.funmat)
                        returning a_ctc34m08[arr_aux].cadfunnom

                   display a_ctc34m08[arr_aux].cadfunnom   to
                           s_ctc34m08[scr_aux].cadfunnom

              when "a"
                  update datreqpvcl set  ( eqpfabcod )
                                     =   ( a_ctc34m08[arr_aux].eqpfabcod )
                   where datreqpvcl.socvclcod = param.socvclcod
                     and datreqpvcl.soceqpcod = a_ctc34m08[arr_aux].soceqpcod
                     
                  if lr_ctc34m08.soceqpcod <> a_ctc34m08[arr_aux].soceqpcod or
                     lr_ctc34m08.soceqpabv <> a_ctc34m08[arr_aux].soceqpabv or
                     lr_ctc34m08.eqpfabcod <> a_ctc34m08[arr_aux].eqpfabcod or
                     lr_ctc34m08.eqpfababv <> a_ctc34m08[arr_aux].eqpfababv or
                     lr_ctc34m08.caddat    <> a_ctc34m08[arr_aux].caddat    or
                     lr_ctc34m08.cadfunnom <> a_ctc34m08[arr_aux].cadfunnom then
                  
                     let l_msg = 'Equipamento [',a_ctc34m08[arr_aux].eqpfabcod clipped,
                         '-',a_ctc34m08[arr_aux].soceqpabv clipped,']. Alterado!'

                     call ctb85g01_grava_hist( 1
                                             , param.socvclcod
                                             , l_msg
                                             , today
                                             , g_issk.empcod
                                             , g_issk.funmat 
                                             , g_issk.usrtip )
                        returning l_errcod
                                , l_errmsg  
                     
                     if l_errcod = 0 then
                        let l_titulo = 'Alteracao no cadastro de equipamento ',
			    ' de  veiculo.  Codigo: ', param.socvclcod 
	                call ctb85g01_mtcorpo_email_html('CTC34M01',
	   	         	                a_ctc34m08[arr_aux].caddat,
	   		                         current hour to minute,
	   		                         g_issk.empcod,
	   		                         g_issk.usrtip,
			                         g_issk.funmat,
			                         l_titulo,
			                         l_msg)
         			returning l_erro

                     end if
                  end if
                  initialize lr_ctc34m08 to null

             end case
          commit work

          let ws.operacao = " "

    end input

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false
 close c_ctc34m08

 close window w_ctc34m08

end function   ###-- ctc34m08


#---------------------------------------------------------
 function ctc34m08_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctc34m08_func


