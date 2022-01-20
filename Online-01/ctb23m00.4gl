########################################################################### 
# Nome do Modulo: CTB23m00                                        Wagner  # 
#                                                                         # 
# Manutencao bloqueio temporario do socorrita                    Jun/2001 #
########################################################################### 

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"
 
#------------------------------------------------------------
 function ctb23m00()
#------------------------------------------------------------

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,     
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 

 define ws_hora       char(05)

 let int_flag = false
 initialize d_ctb23m00.*  to null

#if not get_niv_mod(g_issk.prgsgl, "ctb23m00") then
#   error " Modulo sem nivel de consulta e atualizacao!"
#   return
#end if
 
 open window ctb23m00 at 4,2 with form "ctb23m00"
   
 menu "BLOQUEIO SOCORRISTA" 
                
  before menu
     hide option all
#    if g_issk.acsnivcod >= g_issk.acsnivcns  then
#       show option "Seleciona", "Proximo", "Anterior"
#    end if
#    if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Desbloqueio" 
#    end if
 
     show option "Encerra"
    
 command key ("S") "Seleciona"
                   "Pesquisa bloqueio socorrista conforme criterios"
          call ctb23m00_seleciona()  returning d_ctb23m00.*
          if d_ctb23m00.srrcoddig  is not null  then  
             message ""
             next option "Proximo"
          else
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo bloqueio selecionado"   
          message ""
          if d_ctb23m00.srrcoddig is not null then
             call ctb23m00_proximo(d_ctb23m00.srrcoddig)
                  returning d_ctb23m00.*
          else
             error " Nenhum socorrista nesta direcao!"
             next option "Seleciona"
          end if

 command key ("A") "Anterior"
                   "Mostra bloqueio anterior selecionado"   
          message ""
          if d_ctb23m00.srrcoddig is not null then
             call ctb23m00_anterior(d_ctb23m00.srrcoddig)
                  returning d_ctb23m00.*
          else
             error " Nenhum socorrista nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica" 
                   "Modifica bloqueio socorrista corrente selecionado"
          message ""
          if d_ctb23m00.srrcoddig  is not null then
             if today > d_ctb23m00.blqfnldat then
                error " Periodo de bloqueio ja' vencido, favor criar outro!"
                next option "Seleciona"
             else  
                let ws_hora = time
                if today = d_ctb23m00.blqfnldat  and  
                   ws_hora > d_ctb23m00.blqfnlhor then
                   error " Periodo de bloqueio ja' vencido, favor criar outro!"
                   next option "Seleciona"
                else
                   call ctb23m00_modifica(d_ctb23m00.srrcoddig, d_ctb23m00.*)
                        returning d_ctb23m00.*
                   next option "Seleciona"
                end if
             end if
          else
             error " Nenhum socorrista selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui bloqueio socorrista"
          message ""
          call ctb23m00_inclui()
          next option "Seleciona"

 command "Desbloqueio" "Desbloqueio imediato do socorrista"               
          message ""
          if d_ctb23m00.srrcoddig  is not null then
             call ctb23m00_desbloq(d_ctb23m00.*)            
                         returning d_ctb23m00.*
               next option "Seleciona"
          else
             error " Nenhum socorrista selecionado!"
             next option "Seleciona"
          end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctb23m00

 end function  # ctb23m00


#------------------------------------------------------------
 function ctb23m00_seleciona()      
#------------------------------------------------------------

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,   
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 

 let int_flag = false
 initialize d_ctb23m00.*  to null
 display by name d_ctb23m00.*

 input by name d_ctb23m00.srrcoddig 

    before field srrcoddig 
        display by name d_ctb23m00.srrcoddig attribute (reverse)

        if d_ctb23m00.srrcoddig is null then 
           let d_ctb23m00.srrcoddig = 0
        end if 

    after  field srrcoddig 
        display by name d_ctb23m00.srrcoddig 
 
        if d_ctb23m00.srrcoddig is null or  
           d_ctb23m00.srrcoddig = 0     then 
           error " Favor informar o codigo do socorrista para a pesquisa!"
           next field srrcoddig
        else
           select srrcoddig
             from datksrr
            where datksrr.srrcoddig = d_ctb23m00.srrcoddig 
           if sqlca.sqlcode = notfound then
              error " Codigo do socorrista nao existe!"
              next field srrcoddig
           end if
        end if 

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctb23m00.*   to null
    display by name d_ctb23m00.*  
    error " Operacao cancelada!"
    clear form
    return d_ctb23m00.*
 end if

 if d_ctb23m00.srrcoddig = 0 then 
    select min(srrcoddig)
      into d_ctb23m00.srrcoddig 
          from datmsrrblq
         where datmsrrblq.srrcoddig > d_ctb23m00.srrcoddig      
 end if

 declare c_ctb23m00_sel scroll cursor with hold for
  select srrcoddig, c24evtcod, blqincdat, blqinchor
    from datmsrrblq
   where datmsrrblq.srrcoddig = d_ctb23m00.srrcoddig      
   order by 1,3,4

 open c_ctb23m00_sel
 fetch first c_ctb23m00_sel into d_ctb23m00.srrcoddig, 
                                 d_ctb23m00.c24evtcod, 
                                 d_ctb23m00.blqincdat,
                                 d_ctb23m00.blqinchor 
 
 if sqlca.sqlcode <> notfound then
    call ctb23m00_ler(d_ctb23m00.srrcoddig, d_ctb23m00.c24evtcod, 
                      d_ctb23m00.blqincdat, d_ctb23m00.blqinchor) 
            returning d_ctb23m00.*

    if d_ctb23m00.srrcoddig  is not null   then
       display by name  d_ctb23m00.*
    else
       error " Nao ha' bloqueios para este socorrista!"
       initialize d_ctb23m00.*    to null
    end if
 else
    error " Nao ha' bloqueios para este socorrista!"
    initialize d_ctb23m00.*    to null
 end if

 return d_ctb23m00.*

 end function  # ctb23m00_seleciona


#------------------------------------------------------------
 function ctb23m00_proximo(param)      
#------------------------------------------------------------

 define param         record
    srrcoddig         like datmsrrblq.srrcoddig
 end record 

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,   
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 

 let int_flag = false
 initialize d_ctb23m00.*   to null

 fetch next  c_ctb23m00_sel into d_ctb23m00.srrcoddig, 
                                 d_ctb23m00.c24evtcod, 
                                 d_ctb23m00.blqincdat,
                                 d_ctb23m00.blqinchor 

 if sqlca.sqlcode = 0 then 
    call ctb23m00_ler(d_ctb23m00.srrcoddig, d_ctb23m00.c24evtcod, 
                      d_ctb23m00.blqincdat, d_ctb23m00.blqinchor) 
            returning d_ctb23m00.*

    if d_ctb23m00.srrcoddig  is not null   then
       display by name d_ctb23m00.*
    else
       error " Nao ha' local de vistoria nesta direcao!"
       initialize d_ctb23m00.*    to null
    end if
 else
    error " Nao ha' mais bloqueios nesta direcao para este socorrista!"
    initialize d_ctb23m00.*    to null
 end if

 return d_ctb23m00.*

 end function    # ctb23m00_proximo


#------------------------------------------------------------
 function ctb23m00_anterior(param)
#------------------------------------------------------------

 define param         record
    srrcoddig         like datmsrrblq.srrcoddig
 end record 

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,   
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 

 let int_flag = false
 initialize d_ctb23m00.*  to null

 fetch previous c_ctb23m00_sel into d_ctb23m00.srrcoddig, 
                                    d_ctb23m00.c24evtcod, 
                                    d_ctb23m00.blqincdat,
                                    d_ctb23m00.blqinchor 

 if sqlca.sqlcode = 0 then 
    call ctb23m00_ler(d_ctb23m00.srrcoddig, d_ctb23m00.c24evtcod, 
                      d_ctb23m00.blqincdat, d_ctb23m00.blqinchor) 
            returning d_ctb23m00.*

    if d_ctb23m00.srrcoddig  is not null   then
       display by name  d_ctb23m00.*
    else
       error " Nao ha' local de vistoria nesta direcao!"
       initialize d_ctb23m00.*    to null
    end if
 else
    error " Nao ha' local de vistoria nesta direcao!"
    initialize d_ctb23m00.*    to null
 end if

 return d_ctb23m00.*

 end function    # ctb23m00_anterior


#------------------------------------------------------------
 function ctb23m00_modifica(param, d_ctb23m00)
#------------------------------------------------------------

 define param         record
    srrcoddig         like datmsrrblq.srrcoddig
 end record 

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,   
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 
 
 define d_ctb23m00_ant record
    blqfnldat         like datmsrrblq.blqfnldat, 
    blqfnlhor         like datmsrrblq.blqfnlhor
 end record

 define  ws_hora      char (05)                  
 
 define l_mesg     char(3000)
       ,l_mensagem char(100)
       ,l_flg      integer  
       ,l_stt      smallint 
       ,l_cmd      char(100)
       ,l_mensmail char(3000)
 
 let l_mensagem = 'Alteracao no Bloqueio do Socorrista. Codigo : ',
     d_ctb23m00.srrcoddig
 let l_flg      = 0 
 let l_mensmail = null       
 
 let d_ctb23m00_ant.blqfnldat = d_ctb23m00.blqfnldat
 let d_ctb23m00_ant.blqfnlhor = d_ctb23m00.blqfnlhor
 
 call ctb23m00_input("a", d_ctb23m00.*) returning d_ctb23m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb23m00.*  to null
    display by name d_ctb23m00.*  
    error " Operacao cancelada!"
    return d_ctb23m00.*
 end if

 whenever error continue

 let d_ctb23m00.atldat = today

 begin work
    update datmsrrblq set  ( blqfnldat,      
                             blqfnlhor,          
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctb23m00.blqfnldat, 
                             d_ctb23m00.blqfnlhor,
                             d_ctb23m00.atldat, 
                             g_issk.empcod,     
                             g_issk.funmat ) 
     where datmsrrblq.srrcoddig = d_ctb23m00.srrcoddig
       and datmsrrblq.c24evtcod = d_ctb23m00.c24evtcod
       and datmsrrblq.blqincdat = d_ctb23m00.blqincdat
       and datmsrrblq.blqinchor = d_ctb23m00.blqinchor

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do bloqueio corrente!"
       rollback work
       initialize d_ctb23m00.*   to null
       return d_ctb23m00.*
    else
       #---------------------------------
       # Verificar e  bloqueia socorrista
       #---------------------------------
       if today >= d_ctb23m00.blqincdat    and 
          today <= d_ctb23m00.blqfnldat    then   
          let ws_hora = time 
          if today   =  d_ctb23m00.blqincdat and      
             ws_hora >= d_ctb23m00.blqinchor then 
             update datksrr set srrstt = 2    
              where datksrr.srrcoddig = d_ctb23m00.srrcoddig
              if sqlca.sqlcode <>  0   then
                 error " Erro (",sqlca.sqlcode,") no bloqueio do socorrista!"  
                 rollback work
                 return
              else
                 let d_ctb23m00.srrstt = 2                
                 let d_ctb23m00.srrsttdes = "BLOQUEADO"
              end if
          end if
       end if
       
       if (d_ctb23m00_ant.blqfnldat is null     and d_ctb23m00.blqfnldat is not null) or
          (d_ctb23m00_ant.blqfnldat is not null and d_ctb23m00.blqfnldat is null)     or
          (d_ctb23m00_ant.blqfnldat              <> d_ctb23m00.blqfnldat)             then
          let l_mesg = "Data final para bloqueio alterada de [",d_ctb23m00_ant.blqfnldat clipped, "] para [",
                       d_ctb23m00.blqfnldat clipped,"]"
       
          let l_mensmail = l_mensmail clipped," ",l_mesg clipped
          let l_flg = 1
       
          if not ctb23m00_grava_hist(d_ctb23m00.srrcoddig
                                    ,l_mesg
                                    ,today
                                    ,l_mensagem,"A") then
             
             let l_mesg     = "Erro gravacao Historico " 
             let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
          end if
       
       end if
       
       if (d_ctb23m00_ant.blqfnlhor is null     and d_ctb23m00.blqfnlhor is not null) or
          (d_ctb23m00_ant.blqfnlhor is not null and d_ctb23m00.blqfnlhor is null)     or
          (d_ctb23m00_ant.blqfnlhor              <> d_ctb23m00.blqfnlhor)             then
          let l_mesg = "Horario final do bloqueio alterada de [",d_ctb23m00_ant.blqfnlhor clipped, "] para [",
                       d_ctb23m00.blqfnlhor clipped,"]"
       
          let l_mensmail = l_mensmail clipped," ",l_mesg clipped
          let l_flg = 1
       
          if not ctb23m00_grava_hist(d_ctb23m00.srrcoddig
                                    ,l_mesg
                                    ,today
                                    ,l_mensagem,"A") then
             
             let l_mesg     = "Erro gravacao Historico " 
             let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
          end if
       
       end if
       
       if l_flg = 1 then
          call ctb23m00_envia_email(l_mensagem,today ,
	    			    current hour to minute ,l_flg,l_mensmail)
          returning l_stt
       end if
       
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctb23m00.*  to null 
 display by name d_ctb23m00.*
 message ""

 return d_ctb23m00.*

 end function   #  ctb23m00_modifica


#------------------------------------------------------------
 function ctb23m00_inclui()
#------------------------------------------------------------

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 

 define  ws_resp      char(01)
 define  ws_hora      char(05) 
 define  ws_atual     datetime year to minute
 
 define l_mensagem   char(60)
       ,l_mesg       char(200)
       ,l_stt        smallint
 
 let l_mensagem  = null
 let l_mesg      = null
 let l_stt       = null
 
 initialize d_ctb23m00.*   to null 
 display by name d_ctb23m00.*

 call ctb23m00_input("i", d_ctb23m00.*) returning d_ctb23m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctb23m00.*  to null
    display by name d_ctb23m00.*
    error " Operacao cancelada!"
    return
 end if

 whenever error continue

 begin work
    insert into datmsrrblq ( srrcoddig,
                             c24evtcod,     
                             blqincdat, 
                             blqinchor, 
                             blqfnldat, 
                             blqfnlhor, 
                             blqcaddat,
                             blqcademp,
                             blqcadmat,
                             atldat,
                             atlemp, 
                             atlmat, 
                             atlusrtip)
                  values
                           ( d_ctb23m00.srrcoddig,
                             d_ctb23m00.c24evtcod, 
                             d_ctb23m00.blqincdat, 
                             d_ctb23m00.blqinchor, 
                             d_ctb23m00.blqfnldat, 
                             d_ctb23m00.blqfnlhor, 
                             today,  
                             g_issk.empcod, 
                             g_issk.funmat, 
                             today,  
                             g_issk.empcod, 
                             g_issk.funmat,   
                             g_issk.usrtip )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao bloqueio do socorrista!"
       rollback work
       return
    end if
    #---------------------------------
    # Verificar e  bloqueia socorrista
    #---------------------------------
    if today >= d_ctb23m00.blqincdat    and 
       today <= d_ctb23m00.blqfnldat    then   
       let ws_hora = time 
       if today   =  d_ctb23m00.blqincdat and      
          ws_hora >= d_ctb23m00.blqinchor then 
          update datksrr set srrstt = 2    
           where datksrr.srrcoddig = d_ctb23m00.srrcoddig
           if sqlca.sqlcode <>  0   then
              error " Erro (",sqlca.sqlcode,") no bloqueio do socorrista!"  
              rollback work
              return
           else
              let d_ctb23m00.srrstt = 2                
              let d_ctb23m00.srrsttdes = "BLOQUEADO"
           end if
       end if
    end if
    #---------------------------------
    # Grava analise socorrista 
    #---------------------------------
    let ws_atual = current
    call ctb00g01_anlsrr (d_ctb23m00.c24evtcod, 
                          "",
                          d_ctb23m00.srrcoddig,
                          ws_atual,  
                          g_issk.funmat)  

 commit work

 whenever error stop

 call ctb23m00_func(g_issk.empcod, g_issk.funmat) 
      returning d_ctb23m00.cadfunnom

 call ctb23m00_func(g_issk.empcod, g_issk.funmat) 
      returning d_ctb23m00.funnom

 display by name  d_ctb23m00.*

 let l_mensagem = 'Inclusao de Bloqueio de Socorrista'                   
 let l_mesg = "Socorrista bloqueado via tela de Analise:                           ",
              "   de [",d_ctb23m00.blqincdat,"-",d_ctb23m00.blqinchor,"]",
              " ate [",d_ctb23m00.blqfnldat,"-",d_ctb23m00.blqfnlhor,"] !"
                                                                         
 let l_stt = ctb23m00_grava_hist(d_ctb23m00.srrcoddig                    
                                ,l_mesg                                  
                                ,today                                   
                                ,l_mensagem,"I")                                                       

 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctb23m00.*  to null
 display by name d_ctb23m00.*
 
 end function   #  ctb23m00_inclui

#--------------------------------------------------------------------
 function ctb23m00_desbloq(d_ctb23m00)
#--------------------------------------------------------------------

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 

 define ws_hora       char (05) 

 define l_mensagem   char(60)
       ,l_mesg       char(60)
       ,l_stt        smallint
                             
 let l_mensagem  = null      
 let l_mesg      = null      
 let l_stt       = null      

 
 menu "Confirma desbloqueio ?"
 
    command "Nao" "Nao desbloqueia socorrista "        
            clear form
            initialize d_ctb23m00.* to null
            exit menu

    command "Sim" "Desbloqueia socorrista"       
            call ctb23m00_ler(d_ctb23m00.srrcoddig, d_ctb23m00.c24evtcod, 
                               d_ctb23m00.blqincdat, d_ctb23m00.blqinchor) 
                     returning d_ctb23m00.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctb23m00.* to null
               error " Registro de bloqueio nao localizado!"
            else
               whenever error continue

               let ws_hora  = time  
               let d_ctb23m00.atldat    = today
               let d_ctb23m00.blqfnldat = today
               let d_ctb23m00.blqfnlhor = ws_hora 

               begin work
                 update datmsrrblq set  ( blqfnldat,      
                                          blqfnlhor,          
                                          atldat,
                                          atlemp,
                                          atlmat )
                                     =  ( d_ctb23m00.blqfnldat, 
                                          d_ctb23m00.blqfnlhor,
                                          d_ctb23m00.atldat, 
                                          g_issk.empcod,     
                                          g_issk.funmat ) 
                  where datmsrrblq.srrcoddig = d_ctb23m00.srrcoddig
                    and datmsrrblq.c24evtcod = d_ctb23m00.c24evtcod
                    and datmsrrblq.blqincdat = d_ctb23m00.blqincdat
                    and datmsrrblq.blqinchor = d_ctb23m00.blqinchor
             
                 if sqlca.sqlcode <>  0  then
                    error " Erro (",sqlca.sqlcode,") no besbloqueio do socorrista corrente!"
                    rollback work
                    initialize d_ctb23m00.*   to null
                    return d_ctb23m00.*
                 else
                    update datksrr set srrstt = 1   
                     where datksrr.srrcoddig = d_ctb23m00.srrcoddig
                    if sqlca.sqlcode <>  0   then
                       error " Erro (",sqlca.sqlcode,") no bloqueio do socorrista!"  
                       rollback work
                       return
                    else
                       let d_ctb23m00.srrstt = 1                
                       let d_ctb23m00.srrsttdes = "ATIVO"       
                       display by name d_ctb23m00.srrstt 
                       display by name d_ctb23m00.srrsttdes 
                       sleep 1
                    end if
                 end if
                 
                 let l_mensagem = 'Inclusao de Desbloqueio de Socorrista'
                 let l_mesg = "Socorrista desbloqueado via tela de Analise !"
                 
                 let l_stt = ctb23m00_grava_hist(d_ctb23m00.srrcoddig
                                                ,l_mesg
                                                ,today
                                                ,l_mensagem,"I")
                 
                 
                 error " Desbloqueio efetuado com sucesso!"
            end if

            commit work

            whenever error stop
            exit menu
 end menu 

 return d_ctb23m00.*

end function    # ctb23m00_desbloq




#--------------------------------------------------------------------
 function ctb23m00_input(param, d_ctb23m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record 

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 

 define ws            record
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    count             integer,  
    srrcoddig         like datmsrrblq.srrcoddig
 end record 

 define ws_hora       char (05) 

 initialize ws.*  to null
 let int_flag = false
 let ws_hora  = time  
 if param.operacao = "i"   then  
    let d_ctb23m00.blqincdat = today  
    let d_ctb23m00.blqinchor = ws_hora
 end if 
 
 input by name d_ctb23m00.srrcoddig,
               d_ctb23m00.blqincdat,
               d_ctb23m00.blqinchor,
               d_ctb23m00.blqfnldat,
               d_ctb23m00.blqfnlhor,
               d_ctb23m00.c24evtcod  without defaults

    before field srrcoddig        
           if param.operacao = "a"   then  
              next field blqfnldat
           end if
           display by name d_ctb23m00.srrcoddig attribute (reverse)

    after  field srrcoddig
           display by name d_ctb23m00.srrcoddig

           if fgl_lastkey() = fgl_keyval ("up")     or 
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srrcoddig 
           end if 

           select srrnom, srrstt
             into d_ctb23m00.srrnom, d_ctb23m00.srrstt
             from datksrr
            where datksrr.srrcoddig = d_ctb23m00.srrcoddig

           if sqlca.sqlcode = notfound then
              error " Codigo do socorrista nao existe!"
              next field  srrcoddig 
           end if  

           select cpodes
             into d_ctb23m00.srrsttdes 
             from iddkdominio
            where cponom = "srrstt"
              and cpocod = d_ctb23m00.srrstt

           display by name d_ctb23m00.srrnom
           display by name d_ctb23m00.srrstt
           display by name d_ctb23m00.srrsttdes

           if d_ctb23m00.srrstt <>  1  and
              d_ctb23m00.srrstt <>  2  then
              error " Atencao: Situacao atual do socorrista nao admite bloqueio!"
              next field srrcoddig 
           end if
           
    before field blqincdat
           display by name d_ctb23m00.blqincdat attribute (reverse)

    after  field blqincdat
           display by name d_ctb23m00.blqincdat

           if fgl_lastkey() = fgl_keyval ("up")     or 
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srrcoddig 
           end if 
 
           if d_ctb23m00.blqincdat  is null   then
              error " Data inicio bloqueio deve ser informada!"
              next field blqincdat
           end if
           if d_ctb23m00.blqincdat < today    then
              error " Data inicio bloqueio nao deve ser inferior a hoje!"
              next field blqincdat
           end if

    before field blqinchor
           display by name d_ctb23m00.blqinchor attribute (reverse)

    after  field blqinchor
           display by name d_ctb23m00.blqinchor

           if fgl_lastkey() = fgl_keyval ("up")     or 
              fgl_lastkey() = fgl_keyval ("left")   then
              next field blqincdat
           end if 
 
           if d_ctb23m00.blqinchor  is null   then
              error " Hora inicio bloqueio deve ser informado!"
              next field blqinchor
           end if
           if d_ctb23m00.blqincdat = today    and 
              d_ctb23m00.blqinchor < ws_hora  then
              error " Hora inicio bloqueio nao pode ser inferior ao atual!"
              next field blqinchor
           end if
           declare c_ctb23m00_vblq cursor for
           select blqincdat, blqinchor, blqfnldat, blqfnlhor  
             from datmsrrblq
            where datmsrrblq.srrcoddig  = d_ctb23m00.srrcoddig
              and d_ctb23m00.blqincdat >= datmsrrblq.blqincdat 
              and d_ctb23m00.blqincdat <= datmsrrblq.blqfnldat 
           foreach c_ctb23m00_vblq into ws.blqincdat, ws.blqinchor,
                                          ws.blqfnldat, ws.blqfnlhor  
              if ws.blqincdat = ws.blqfnldat then
                 if d_ctb23m00.blqinchor <= ws.blqfnlhor then
                    error " ATENCAO: Ja' existe bloqueio(s) para este socorrista neste intervalo!"
                    next field blqinchor
                 end if
              else
                 if d_ctb23m00.blqincdat < ws.blqfnldat then
                    error " ATENCAO: Ja' existe bloqueio(s) para este socorrista neste intervalo!"
                    next field blqinchor
                 end if
                 if d_ctb23m00.blqincdat = ws.blqfnldat then
                    if d_ctb23m00.blqinchor <= ws.blqfnlhor then
                       error " ATENCAO: Ja' existe bloqueio(s) para este socorrista neste intervalo!"
                       next field blqinchor
                    end if
                 end if
              end if
           end foreach

    before field blqfnldat
           display by name d_ctb23m00.blqfnldat attribute (reverse)

    after  field blqfnldat
           display by name d_ctb23m00.blqfnldat

           if fgl_lastkey() = fgl_keyval ("up")     or 
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao    = "i"   then  
                 next field blqinchor 
              else 
                 next field blqfnldat
              end if
           end if 
 
           if d_ctb23m00.blqfnldat  is null   then
              error " Data final bloqueio deve ser informada!"
              next field blqfnldat
           end if
           if d_ctb23m00.blqfnldat < today    then
              error " Data final bloqueio nao deve ser inferior a hoje!"
              next field blqfnldat
           end if
           if d_ctb23m00.blqfnldat < d_ctb23m00.blqincdat    then
              error " Data final bloqueio nao deve menor que data inicio!" 
              next field blqfnldat
           end if

    before field blqfnlhor
           display by name d_ctb23m00.blqfnlhor attribute (reverse)

    after  field blqfnlhor
           display by name d_ctb23m00.blqfnlhor

           if fgl_lastkey() = fgl_keyval ("up")     or 
              fgl_lastkey() = fgl_keyval ("left")   then
              next field blqfnldat 
           end if 
           if d_ctb23m00.blqfnlhor  is null   then
              error " Hora final bloqueio deve ser informado!"
              next field blqfnlhor
           end if
           if d_ctb23m00.blqincdat =  d_ctb23m00.blqfnldat and   
              d_ctb23m00.blqinchor >= d_ctb23m00.blqfnlhor then
              error " Hora final bloqueio nao pode ser inferior ou igual a hora inicial!"
              next field blqfnlhor
           end if
           if d_ctb23m00.blqfnldat = today    and  
              d_ctb23m00.blqfnlhor < ws_hora  then
              error " Hora final bloqueio nao pode ser inferior ao atual!"
              next field blqfnlhor
           end if
           declare c_ctb23m00_vblq2 cursor for
           select blqincdat, blqinchor, blqfnldat, blqfnlhor  
             from datmsrrblq
            where datmsrrblq.srrcoddig  = d_ctb23m00.srrcoddig
              and d_ctb23m00.blqfnldat >= datmsrrblq.blqincdat 
              and d_ctb23m00.blqfnldat <= datmsrrblq.blqfnldat 
           foreach c_ctb23m00_vblq2 into ws.blqincdat, ws.blqinchor,
                                         ws.blqfnldat, ws.blqfnlhor  
              if ws.blqincdat = ws.blqfnldat then
                 if d_ctb23m00.blqfnlhor <= ws.blqfnlhor then
                    error " ATENCAO: Ja' existe bloqueio(s) para este socorrista neste intervalo!"
                    next field blqfnlhor
                 end if
              else
                 if d_ctb23m00.blqfnldat < ws.blqfnldat then
                    error " ATENCAO: Ja' existe bloqueio(s) para este socorrista neste intervalo!"
                    next field blqfnlhor
                 end if
                 if d_ctb23m00.blqfnldat = ws.blqfnldat then
                    if d_ctb23m00.blqfnlhor <= ws.blqfnlhor then
                       error " ATENCAO: Ja' existe bloqueio(s) para este socorrista neste intervalo!"
                       next field blqfnlhor
                    end if
                 end if
              end if
           end foreach

           if param.operacao  = "a"   then
              exit input  
           end if
   
    before field c24evtcod
           display by name d_ctb23m00.c24evtcod attribute (reverse)

    after  field c24evtcod
           display by name d_ctb23m00.c24evtcod

           if fgl_lastkey() = fgl_keyval ("up")     or 
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao        = "i"   then
                 next field blqfnlhor
              else
                 next field c24evtcod 
              end if
           end if 
           if d_ctb23m00.c24evtcod  is null   then
              error " Codigo do evento deve ser informado!"
              call ctb14m01() returning d_ctb23m00.c24evtcod
              next field c24evtcod
           end if
           select c24evtrdzdes
             into d_ctb23m00.c24evtdes
             from datkevt
            where c24evtcod = d_ctb23m00.c24evtcod
           if sqlca.sqlcode = notfound then
              error " Codigo do evento nao cadastrado!"
              next field c24evtcod
           end if
           display by name d_ctb23m00.c24evtdes

    on key (interrupt)
       exit input
 
 end input

 if int_flag   then
    initialize d_ctb23m00.*  to null
 end if

 return d_ctb23m00.*

 end function   # ctb23m00_input
          
#---------------------------------------------------------
 function ctb23m00_ler(param)
#---------------------------------------------------------

 define param         record
    srrcoddig         like datmsrrblq.srrcoddig, 
    c24evtcod         like datmsrrblq.c24evtcod, 
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor
 end record 

 define d_ctb23m00    record
    srrcoddig         like datmsrrblq.srrcoddig, 
    srrnom            like datksrr.srrnom,
    srrstt            like datksrr.srrstt,
    srrsttdes         char (10),  
    blqincdat         like datmsrrblq.blqincdat,
    blqinchor         like datmsrrblq.blqinchor,
    blqfnldat         like datmsrrblq.blqfnldat,
    blqfnlhor         like datmsrrblq.blqfnlhor,
    c24evtcod         like datmsrrblq.c24evtcod, 
    c24evtdes         like datkevt.c24evtrdzdes,
    blqcaddat         like datmsrrblq.blqcaddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datmsrrblq.atldat,
    funnom            like isskfunc.funnom
 end record 

 define ws            record 
    atlemp            like isskfunc.empcod,              
    atlmat            like isskfunc.funmat,              
    blqcademp         like isskfunc.empcod, 
    blqcadmat         like isskfunc.funmat, 
    usrtip            like isskfunc.usrtip      
 end record

 initialize d_ctb23m00.*   to null
 initialize ws.*           to null

 select srrnom, srrstt
   into d_ctb23m00.srrnom, d_ctb23m00.srrstt
   from datksrr
  where datksrr.srrcoddig = param.srrcoddig

 select cpodes
   into d_ctb23m00.srrsttdes 
   from iddkdominio
  where cponom = "srrstt"
    and cpocod = d_ctb23m00.srrstt

 display by name d_ctb23m00.srrnom
 display by name d_ctb23m00.srrstt
 display by name d_ctb23m00.srrsttdes

 select  srrcoddig,                         
         c24evtcod, 
         blqincdat, 
         blqinchor,  
         blqfnldat, 
         blqfnlhor,  
         blqcaddat,                         
         blqcademp,                         
         blqcadmat,                         
         atldat,                         
         atlemp,                         
         atlmat,
         atlusrtip  
   into  d_ctb23m00.srrcoddig,                         
         d_ctb23m00.c24evtcod,                         
         d_ctb23m00.blqincdat,                         
         d_ctb23m00.blqinchor,                         
         d_ctb23m00.blqfnldat,                         
         d_ctb23m00.blqfnlhor,                         
         d_ctb23m00.blqcaddat,                         
         ws.blqcademp,              
         ws.blqcadmat,              
         d_ctb23m00.atldat,                         
         ws.atlemp,
         ws.atlmat,        
         ws.usrtip         
   from  datmsrrblq
  where  datmsrrblq.srrcoddig = param.srrcoddig
    and  datmsrrblq.c24evtcod = param.c24evtcod
    and  datmsrrblq.blqincdat = param.blqincdat
    and  datmsrrblq.blqinchor = param.blqinchor
    
 if sqlca.sqlcode = notfound   then
    error " Nao ha' bloqueios para este socorrista!"
    initialize d_ctb23m00.*    to null
    return d_ctb23m00.*
 else
    let d_ctb23m00.c24evtdes = "NAO ENCONTRADO!"
    select c24evtrdzdes
      into d_ctb23m00.c24evtdes
      from datkevt
     where c24evtcod = d_ctb23m00.c24evtcod

    call ctb23m00_func(ws.blqcademp, ws.blqcadmat) 
         returning d_ctb23m00.cadfunnom

    call ctb23m00_func(ws.atlemp, ws.atlmat) 
         returning d_ctb23m00.funnom
 end if

 return d_ctb23m00.*

 end function   # ctb23m00_ler


#---------------------------------------------------------
 function ctb23m00_func(param)
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

 end function   # ctb23m00_func

#------------------------------------------------------------
function ctb23m00_grava_hist(lr_param,l_titulo,l_operacao)
#------------------------------------------------------------

   define lr_param record
          srrcoddig  like datksrr.srrcoddig
         ,mensagem   char(3000)
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
         ,l_prshstdes2  char(3000)
	 ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint
         
   let l_stt  = true  
   let l_path = null

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
                                     current hour to minute, 
	   		             g_issk.empcod,
                                     g_issk.usrtip,
                                     g_issk.funmat, 
				     l_titulo,				     
	   		             lr_param.mensagem)
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
function ctb23m00_envia_email(lr_param)
#------------------------------------------------

   define lr_param record
	  titulo     char(100)
         ,data       date
         ,hora       datetime hour to minute
	 ,flag       smallint
	 ,mensmail   char(3000)
          end record

   define l_stt       smallint
         ,l_path      char(100)
         ,l_cmd       char(4000)
         ,l_texto     char(3000)
         ,l_mensmail2 like dbsmhstprs.prshstdes 
         ,l_count 
         ,l_iter 
         ,l_erro 
         ,l_length 
         ,l_length2    smallint

   let l_stt  = true
   let l_path = null

   call ctb85g01_mtcorpo_email_html('CTC44M00', # Utiliza os mesmos parametros do Frt_ct24h
				    lr_param.data,
                                    lr_param.hora,
                                    g_issk.empcod,
                                    g_issk.usrtip,
                                    g_issk.funmat,
                                    lr_param.titulo,
                                    lr_param.mensmail)
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