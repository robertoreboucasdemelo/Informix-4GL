#-----------------------------------------------------------------------------#
#              *** Porto  Seguro  Cia.  de  Seguros  Gerais ***               #
#.............................................................................#
#                                                                             #
# Sistema.: Ct24hs   - Central 24hs e Pronto Socorro                          #
# Modulo..: ctc60m03 - Manutencao Socorrista                                  #
# Analista: Wagner Agostinho                                                  #
# PSI.....:                  OSF: 10570                                       #
#                                                                             #
# Desenvolvimento: Fabrica de Software  -  Talita Menezes - DEZ/02            #
#-----------------------------------------------------------------------------#
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 05/04/09    PSI 237337   Kevellin     Adaptações atendimento PSI 237337     #
#-----------------------------------------------------------------------------#

#globals  "/homedsa/projetos/geral/globals/glre.4gl"
#globals  "glre.4gl"

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------------#
function ctc60m03()
#-----------------------------------------------------------------------------#

   define l_ctc60m03       record
          srrcoddig        like datksrr.srrcoddig
         ,srrnom           like datksrr.srrnom
         ,celdddcod        like datksrr.celdddcod
         ,celtelnum        like datksrr.celtelnum
         ,nxtide           like datkveiculo.nxtide
         ,nxtdddcod        like datkveiculo.nxtdddcod
         ,nxtnum           like datkveiculo.nxtnum
   end record

   define l_posicao        smallint
         ,l_cmd            char(150)
         ,ant_srrcoddig    like datksrr.srrcoddig


	let	l_posicao  =  null
	let	l_cmd  =  null
	let	ant_srrcoddig  =  null

	initialize  l_ctc60m03.*  to  null

   initialize l_ctc60m03.* to null

   open window ctc60m03 at 4,2 with form "ctc60m03"
     attribute (form line 1, message  line last)

   let int_flag    = false

   clear form

   let l_cmd = " select srrcoddig "
                    ," ,srrnom "
                    ," ,celdddcod "
                    ," ,celtelnum "
                    ," ,nxtide "
                    ," ,nxtdddcod "
                    ," ,nxtnum "
                ," from datksrr "
               ," where srrcoddig >= ? "
   prepare pctc60m03001 from l_cmd
   declare cctc60m03001 scroll cursor for pctc60m03001

   menu "PRESTADOR"

      command key ("S") "Seleciona"   "Consulta Socorrista"
              call seleciona_ctc60m03()
                 returning l_ctc60m03.*

      command key ("P") "Proximo"     "Consulta o Proximo Socorrista"
              if l_ctc60m03.srrcoddig is null or
                 l_ctc60m03.srrcoddig =  0    then
                 error "Nenhum Socorrista selecionado !"
                 next option "Seleciona"
              else
                 call scroll_ctc60m03(+1)
                    returning l_ctc60m03.*
                             ,int_flag

                 if int_flag then
                    let int_flag = false
                    error "Voce ja esta no ultimo Socorrista"
                    next option "Anterior"
                 else
                    display by name l_ctc60m03.*
                 end if
              end if

      command key ("A") "Anterior"    "Consulta o Socorrista Anterior"
              if l_ctc60m03.srrcoddig is null or
                 l_ctc60m03.srrcoddig =  0    then
                 error "Nenhum Socorrista selecionado !"
                 next option "Seleciona"
              else
                 call scroll_ctc60m03(-1)
                    returning l_ctc60m03.*
                             ,int_flag

                 if int_flag then
                    let int_flag = false
                    error "Voce ja esta no primeiro Socorrista"
                    if l_ctc60m03.srrcoddig is null then
                       let l_ctc60m03.srrcoddig = ant_srrcoddig
                    end if
                    next option "Proximo"
                 else
                    display by name l_ctc60m03.*
                 end if

                 let ant_srrcoddig = l_ctc60m03.srrcoddig

              end if


      command key ("M") "Manutencao"  "Manutencao de Socorristaes"
              if l_ctc60m03.srrcoddig is null or
                 l_ctc60m03.srrcoddig =  0    then
                 error "Nenhum Socorrista selecionado !"
                 next option "Seleciona"
              else
                 call manutenir_ctc60m03(l_ctc60m03.*)
              end if

      command key (interrupt, "E") "Encerra" "Retorna ao menu anterior "
                   message " "
                   exit menu
   end menu

   close window ctc60m03

   return

end function

#-----------------------------------------------------------------------------#
function seleciona_ctc60m03()
#-----------------------------------------------------------------------------#

   define l_ctc60m03       record
          srrcoddig        like datksrr.srrcoddig
         ,srrnom           like datksrr.srrnom
         ,celdddcod        like datksrr.celdddcod
         ,celtelnum        like datksrr.celtelnum
         ,nxtide           like datkveiculo.nxtide
         ,nxtdddcod        like datkveiculo.nxtdddcod
         ,nxtnum           like datkveiculo.nxtnum
   end record



	initialize  l_ctc60m03.*  to  null

   initialize l_ctc60m03.* to null
   clear form

   call ctc60m03_input("S",l_ctc60m03.*)
      returning l_ctc60m03.*

   if int_flag then
      error " Operacao Cancelada! "
      let int_flag = false
      return l_ctc60m03.*
   end if

   open cctc60m03001 using l_ctc60m03.srrcoddig

   return l_ctc60m03.*

end function

#-----------------------------------------------------------------------------#
function ctc60m03_input(aux_manut,l_ctc60m03)
#-----------------------------------------------------------------------------#

   define l_ctc60m03       record
          srrcoddig        like datksrr.srrcoddig
         ,srrnom           like datksrr.srrnom
         ,celdddcod        like datksrr.celdddcod
         ,celtelnum        like datksrr.celtelnum
         ,nxtide           like datksrr.nxtide
         ,nxtdddcod        like datksrr.nxtdddcod
         ,nxtnum           like datksrr.nxtnum
   end record

   define aux_manut        char(01)



   input by name l_ctc60m03.srrcoddig
                ,l_ctc60m03.celdddcod
                ,l_ctc60m03.celtelnum
                ,l_ctc60m03.nxtide
                ,l_ctc60m03.nxtdddcod
                ,l_ctc60m03.nxtnum without defaults

      before field srrcoddig
         if aux_manut = "M" then
            next field celdddcod
         end if
         display by name l_ctc60m03.srrcoddig attribute(reverse)

      after field srrcoddig
         display by name l_ctc60m03.srrcoddig

         if l_ctc60m03.srrcoddig is null or
            l_ctc60m03.srrcoddig =  0    then
            error " Informe o Codigo do Socorrista! "
            next field srrcoddig
         end if

         #---[ Valida Codigo do Socorrista ]---#
         #######################################
         declare cctc60m03002 cursor with hold for
            select srrcoddig
                  ,srrnom
                  ,celdddcod
                  ,celtelnum
                  ,nxtide
                  ,nxtdddcod
                  ,nxtnum
              from datksrr
             where srrcoddig = l_ctc60m03.srrcoddig

         open cctc60m03002
         fetch cctc60m03002 into l_ctc60m03.srrcoddig
                                ,l_ctc60m03.srrnom
                                ,l_ctc60m03.celdddcod
                                ,l_ctc60m03.celtelnum
                                ,l_ctc60m03.nxtide
                                ,l_ctc60m03.nxtdddcod
                                ,l_ctc60m03.nxtnum

         if sqlca.sqlcode <> 0 then
            error " Socorrista nao cadastrado! "
            initialize l_ctc60m03.* to null
            clear form
            next field srrcoddig
         end if

         display by name l_ctc60m03.*

         if aux_manut = "S" then
            exit input
         end if

      before field celdddcod
         display by name l_ctc60m03.celdddcod attribute(reverse)

      after field celdddcod
         display by name l_ctc60m03.celdddcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field srrcoddig
         end if

         if (l_ctc60m03.celtelnum is not null  and
             l_ctc60m03.celtelnum <> 0       ) and
            (l_ctc60m03.celdddcod is null      or
             l_ctc60m03.celdddcod =  " "     ) then
            error " Informe DDD do Celular! "
            next field celdddcod
         end if

      before field celtelnum
         display by name l_ctc60m03.celtelnum attribute(reverse)

      after field celtelnum
         display by name l_ctc60m03.celtelnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field celdddcod
         end if

         if (l_ctc60m03.celdddcod is not null  and
             l_ctc60m03.celdddcod <> " "     ) and
            (l_ctc60m03.celtelnum is null      or
             l_ctc60m03.celtelnum =  0       ) then
            error " Informe o Numero do Celular! "
            next field celtelnum
         end if

      before field nxtide
         display by name l_ctc60m03.nxtide attribute(reverse)
      
      after field nxtide
         display by name l_ctc60m03.nxtide
      
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field celtelnum
         end if   
      
      before field nxtdddcod
         display by name l_ctc60m03.nxtdddcod attribute(reverse)
      
      after field nxtdddcod
         display by name l_ctc60m03.nxtdddcod
      
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field nxtide
         end if  
         
      before field nxtnum
         display by name l_ctc60m03.nxtnum attribute(reverse)
      
      after field nxtnum
         display by name l_ctc60m03.nxtnum
      
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field nxtdddcod
         end if     
      
      on key (interrupt, control-c)
         let int_flag = true
         exit input

   end input

   return l_ctc60m03.*

end function

#-----------------------------------------------------------------------------#
function scroll_ctc60m03(i)
#-----------------------------------------------------------------------------#

   define i                integer
         ,l_flg            smallint

   define l_ctc60m03       record
          srrcoddig        like datksrr.srrcoddig
         ,srrnom           like datksrr.srrnom
         ,celdddcod        like datksrr.celdddcod
         ,celtelnum        like datksrr.celtelnum
         ,nxtide           like datksrr.nxtide
         ,nxtdddcod        like datksrr.nxtdddcod
         ,nxtnum           like datksrr.nxtnum
   end record


	let	l_flg  =  null

	initialize  l_ctc60m03.*  to  null

   fetch relative i cctc60m03001 into l_ctc60m03.srrcoddig
                                     ,l_ctc60m03.srrnom
                                     ,l_ctc60m03.celdddcod
                                     ,l_ctc60m03.celtelnum
                                     ,l_ctc60m03.nxtide
                                     ,l_ctc60m03.nxtdddcod
                                     ,l_ctc60m03.nxtnum

   if sqlca.sqlcode <> 0 then
      let l_flg = true
   else
      let l_flg = false
   end if

   return l_ctc60m03.*
         ,l_flg

end function

#-----------------------------------------------------------------------------#
function manutenir_ctc60m03(l_ctc60m03)
#-----------------------------------------------------------------------------#

   define l_ctc60m03       record
          srrcoddig        like datksrr.srrcoddig
         ,srrnom           like datksrr.srrnom
         ,celdddcod        like datksrr.celdddcod
         ,celtelnum        like datksrr.celtelnum
         ,nxtide           like datksrr.nxtide
         ,nxtdddcod        like datksrr.nxtdddcod
         ,nxtnum           like datksrr.nxtnum
   end record

   define l_ctc60m03_ant   record
          srrcoddig        like datksrr.srrcoddig
         ,srrnom           like datksrr.srrnom
         ,celdddcod        like datksrr.celdddcod
         ,celtelnum        like datksrr.celtelnum
         ,nxtide           like datksrr.nxtide
         ,nxtdddcod        like datksrr.nxtdddcod
         ,nxtnum           like datksrr.nxtnum
   end record
   
   define l_mesg     char(2000)
         ,l_mensagem char(100)
	 ,l_flg      integer  
	 ,l_stt      smallint 
         ,l_cmd      char(100)
         ,l_mensmail char(2000)
         ,l_today    like datksrr.atldat
         ,l_hora     datetime hour to minute
   
   let l_mensagem = 'Alteracao no cadastro do socorrista. Codigo : ',
		    l_ctc60m03.srrcoddig
   let l_flg      = 0 
   let l_mensmail = null    
   let l_today    = today  
   let l_hora     = current hour to minute
   
   let l_ctc60m03_ant.srrcoddig = l_ctc60m03.srrcoddig
   let l_ctc60m03_ant.srrnom    = l_ctc60m03.srrnom   
   let l_ctc60m03_ant.celdddcod = l_ctc60m03.celdddcod
   let l_ctc60m03_ant.celtelnum = l_ctc60m03.celtelnum
   let l_ctc60m03_ant.nxtide    = l_ctc60m03.nxtide   
   let l_ctc60m03_ant.nxtdddcod = l_ctc60m03.nxtdddcod
   let l_ctc60m03_ant.nxtnum    = l_ctc60m03.nxtnum   
                               
   call ctc60m03_input("M",l_ctc60m03.*)
      returning l_ctc60m03.*   
              
   if int_flag then            
      error " Operacao Cancelada! "
      let int_flag = false
      return
   end if

   if l_ctc60m03.srrcoddig is not null and
      l_ctc60m03.srrcoddig <> 0        then
      update datksrr set (celdddcod
                         ,celtelnum
                         ,nxtide
                         ,nxtdddcod
                         ,nxtnum
                         ,atldat
                         ,atlemp
                         ,atlmat)
                       = (l_ctc60m03.celdddcod
                         ,l_ctc60m03.celtelnum
                         ,l_ctc60m03.nxtide
                         ,l_ctc60m03.nxtdddcod
                         ,l_ctc60m03.nxtnum
                         ,l_today
                         ,g_issk.empcod
                         ,g_issk.funmat)
       where srrcoddig = l_ctc60m03.srrcoddig

      if sqlca.sqlcode <> 0 then
         error " Erro na alteracao do Socorrista! "
         return
      end if

   end if
   
   if (l_ctc60m03_ant.celdddcod is null     and l_ctc60m03.celdddcod is not null) or
      (l_ctc60m03_ant.celdddcod is not null and l_ctc60m03.celdddcod is null)     or
      (l_ctc60m03_ant.celdddcod              <> l_ctc60m03.celdddcod)             then
      let l_mesg = "DDD Celular alterado de [",l_ctc60m03_ant.celdddcod clipped, "] para [",
                   l_ctc60m03.celdddcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc60m03_grava_hist(l_ctc60m03.srrcoddig
                                ,l_mesg
                                ,l_today
                                ,l_mensagem,"A") then
         
         let l_mesg     = "Erro gravacao Historico " 
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if
   
   if (l_ctc60m03_ant.celtelnum is null     and l_ctc60m03.celtelnum is not null) or
      (l_ctc60m03_ant.celtelnum is not null and l_ctc60m03.celtelnum is null)     or
      (l_ctc60m03_ant.celtelnum              <> l_ctc60m03.celtelnum)             then
      let l_mesg = "Numero Celular alterado de [",l_ctc60m03_ant.celtelnum, "] para [",
                   l_ctc60m03.celtelnum,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc60m03_grava_hist(l_ctc60m03.srrcoddig
                                ,l_mesg
                                ,l_today
                                ,l_mensagem,"A") then
         
         let l_mesg     = "Erro gravacao Historico " 
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if
   
   if (l_ctc60m03_ant.nxtide is null     and l_ctc60m03.nxtide is not null) or
      (l_ctc60m03_ant.nxtide is not null and l_ctc60m03.nxtide is null)     or
      (l_ctc60m03_ant.nxtide              <> l_ctc60m03.nxtide)             then
      let l_mesg = "ID Nextel alterado de [",l_ctc60m03_ant.nxtide clipped, "] para [",
                   l_ctc60m03.nxtide clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc60m03_grava_hist(l_ctc60m03.srrcoddig
                                ,l_mesg
                                ,l_today
                                ,l_mensagem,"A") then
         
         let l_mesg     = "Erro gravacao Historico " 
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if
   
   if (l_ctc60m03_ant.nxtdddcod is null     and l_ctc60m03.nxtdddcod is not null) or
      (l_ctc60m03_ant.nxtdddcod is not null and l_ctc60m03.nxtdddcod is null)     or
      (l_ctc60m03_ant.nxtdddcod              <> l_ctc60m03.nxtdddcod)             then
      let l_mesg = "DDD Nextel alterado de [",l_ctc60m03_ant.celtelnum, "] para [",
                   l_ctc60m03.nxtdddcod,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc60m03_grava_hist(l_ctc60m03.srrcoddig
                                ,l_mesg
                                ,l_today
                                ,l_mensagem,"A") then
         
         let l_mesg     = "Erro gravacao Historico " 
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if
   
   if (l_ctc60m03_ant.nxtnum is null     and l_ctc60m03.nxtnum is not null) or
      (l_ctc60m03_ant.nxtnum is not null and l_ctc60m03.nxtnum is null)     or
      (l_ctc60m03_ant.nxtnum              <> l_ctc60m03.nxtnum)             then
      let l_mesg = "Linha Nextel alterado de [",l_ctc60m03_ant.nxtnum, "] para [",
                   l_ctc60m03.nxtnum,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc60m03_grava_hist(l_ctc60m03.srrcoddig
                                ,l_mesg
                                ,l_today
                                ,l_mensagem,"A") then
         
         let l_mesg     = "Erro gravacao Historico " 
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if
      
   if l_flg = 1 then
      call ctc60m03_envia_email(l_mensagem clipped, l_today, l_hora, l_flg, l_mensmail clipped)
      returning l_stt
   end if
   
   error " Alteracao efetuada com sucesso! "
   return

end function

#------------------------------------------------------------
function ctc60m03_grava_hist(lr_param,l_titulo,l_operacao)
#------------------------------------------------------------

   define lr_param record
          srrcoddig  like datksrr.srrcoddig
         ,mensagem   char(2000)
         ,data       date
          end record

   define lr_retorno record
                     stt smallint
                    ,msg char(50)
          end record

   define l_titulo      char(100)
         ,l_stt         smallint
         ,l_path        char(100)
         ,l_operacao    char(1)
         ,l_fimtxt      char(15)
	 ,l_cmd         char(200)
	 ,l_erro        smallint  
         ,l_prshstdes2  char(2000)
	 ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint
         ,l_hora       datetime hour to minute
         
   let l_stt  = true  
   let l_path = null
   let l_hora = current hour to minute

   initialize lr_retorno to null

   let l_length = length(lr_param.mensagem clipped)
   if  l_length mod 70 = 0 then
       let l_iter = l_length / 70
   else
       let l_iter = l_length / 70 + 1
   end if

   let l_length2     = 0
   let l_erro        = 0
   
   for l_count = 1 to l_iter
       if  l_count = l_iter then
           let l_prshstdes2 = lr_param.mensagem[l_length2 + 1, l_length]
       else
           let l_length2 = l_length2 + 70
           let l_prshstdes2 = lr_param.mensagem[l_length2 - 69, l_length2]
       end if
            
       call ctd18g01_grava_hist(lr_param.srrcoddig
                               ,l_prshstdes2
                               ,lr_param.data
                               ,g_issk.empcod
                               ,g_issk.funmat
                               ,'F')
            returning lr_retorno.stt
                     ,lr_retorno.msg

  end for
  
   if l_operacao = "I" then
      if lr_retorno.stt  = 1 then

         call ctb85g01_mtcorpo_email_html('CTC44M00', # Utiliza os mesmos parametros do Frt_ct24h
	                                  lr_param.data,
                                          l_hora, 
	   		                  g_issk.empcod,
                                          g_issk.usrtip,
                                          g_issk.funmat, 
				          l_titulo clipped,				     
	   		                  lr_param.mensagem clipped)
                 returning l_erro

      else    
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
      end if
     else    
      if lr_retorno.stt <> 1 then
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
       end if
   end if

   return l_stt

end function


#------------------------------------------------
function ctc60m03_envia_email(lr_param)
#------------------------------------------------

   define lr_param record
	  titulo     char(100)
         ,data       date
         ,hora       datetime hour to minute
	 ,flag       smallint
	 ,mensmail   char(2000)
          end record

   define l_stt       smallint
         ,l_titulo      char(100)
         ,l_cmd       char(4000)
         ,l_texto     char(2000)
         ,l_mensmail2 like dbsmhstprs.prshstdes 
         ,l_count 
         ,l_iter 
         ,l_erro 
         ,l_length 
         ,l_length2    smallint

   let l_stt    = true
   let l_titulo = null
   
   
   let l_titulo = lr_param.titulo clipped
   let l_texto  = lr_param.mensmail clipped
   
   call ctb85g01_mtcorpo_email_html('CTC44M00', # Utiliza os mesmos parametros do Frt_ct24h
				    lr_param.data,
                                    lr_param.hora,
                                    g_issk.empcod,
                                    g_issk.usrtip,
                                    g_issk.funmat,
                                    l_titulo clipped,
                                    l_texto clipped)
                  returning l_erro

   if l_erro <> 0 then
      error 'Erro no envio do e-mail' sleep 2
      let l_stt = false
     else
       let l_stt = true
   end if

   return l_stt   

end function

#-----------------------------------------------------------------------------#
