#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : ctc00m22                                                       #
# Programa   : Manutenção do cadastro de cadeia de responsaveis               #
#                          - Porto Socorro -                                  #
#-----------------------------------------------------------------------------#
# anlnom Resp. : Robert Lima                                                  #
# PSI            : PSI00009EV                                                 #
#                                                                             #
# Desenvolvedor  : Robert Lima                                                #
# DATA           : 16/09/2010                                                 #
#.............................................................................#
# Data        Autor        Alteracao                                          #
#                                                                             #
# ----------  -----------  ---------------------------------------------------#
# 18/11/2010  Robert Lima  Aumento do array ctc00m22_popup para 500           #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_ctc00m22 record
     gstcdicod like dpakprsgstcdi.gstcdicod,
     sprnom    like dpakprsgstcdi.sprnom   ,
     gernom    like dpakprsgstcdi.gernom   ,
     cdnnom    like dpakprsgstcdi.cdnnom   ,
     anlnom    like dpakprsgstcdi.anlnom   ,
     cadmat    like dpakprsgstcdi.cadmat   ,
     caddat    like dpakprsgstcdi.caddat   ,
     cademp    like dpakprsgstcdi.cademp   ,
     cadusrtip like dpakprsgstcdi.cadusrtip,
     atlmat    like dpakprsgstcdi.atlmat   ,
     atldat    like dpakprsgstcdi.atldat   ,
     atlemp    like dpakprsgstcdi.atlemp   ,
     atlusrtip like dpakprsgstcdi.atlusrtip
end record

define m_ctc00m22_prep smallint

#---------------------------------------------- 
function ctc00m22()                     
#---------------------------------------------- 

 open window w_ctc00m22 AT 4,2 with form "ctc00m22"
              attribute (border) 
 
 menu "Cadeia de Responsaveis"
    
    command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
          call ctc00m22_seleciona() 
          next option "Proximo"	
          
    command key ("P") "Proximo" "Mostra proximo registro selecionado" 
          message ""
          if m_ctc00m22.gstcdicod is not null then
             call ctc00m22_proximo()
          else
             error " Nao ha' mais registros nesta direcao!"
             next option "Seleciona"
          end if 	  
 
    command key ("A") "Anterior" "Mostra registro anterior selecionado"
          message ""
          if m_ctc00m22.gstcdicod is not null then
             call ctc00m22_anterior()
          else
             error " Nao ha' mais registros nesta direcao!"
             next option "Seleciona"
          end if 	   
    
    command key ("I") "Inclui" "Inclui Registro na Tabela"
          call ctc00m22_inclui()	
 
    command key ("M") "Modifica" "Modifica registro corrente selecionado"
          if m_ctc00m22.gstcdicod is null then
             error "NENHUM CADASTRO SELECIONADO"
             next option "Seleciona"
          else
             call ctc00m22_modifica()
          end if
 
    command key ("X") "Exclui" "Exclui registro corrente selecionado"
          if m_ctc00m22.gstcdicod is null then
             error "NENHUM CADASTRO SELECIONADO"
             next option "Seleciona"
          else
             call ctc00m22_exclui()
          end if	
 
    command key ("E",interrupt)"Encerra" "Retorna ao menu anterior" 
          exit menu
 end menu               
                          
 close window w_ctc00m22

end function

#---------------------------------------------- 
function ctc00m22_prepare()                             
#----------------------------------------------

 define l_sql char(500)
 
 let l_sql = "select gstcdicod,     ",
             "       sprnom,        ",
             "       gernom,        ",
             "       cdnnom,        ",
             "       anlnom,        ",
             "       cadmat,        ",
             "       caddat,        ",
             "       atlmat,        ",
             "       atldat         ",
             "  from dpakprsgstcdi  ",
             " where gstcdicod = ? "
 prepare pctc00m22001 from l_sql                         
 declare cctc00m22001 cursor for pctc00m22001

 let m_ctc00m22_prep = true

end function

#---------------------------------------------- 
function ctc00m22_seleciona()                             
#---------------------------------------------- 

 define l_cadfunnom like isskfunc.funnom
 
 clear form
 let int_flag = false
 
 if m_ctc00m22_prep <> true then
    call ctc00m22_prepare() 
 end if
 
 input by name m_ctc00m22.gstcdicod
 
       before field gstcdicod                                                   
          display by name m_ctc00m22.gstcdicod attribute(reverse)          
                                                                           
       after field gstcdicod                                                    
          display by name m_ctc00m22.gstcdicod                             
                                                                           
          if m_ctc00m22.gstcdicod is null or m_ctc00m22.gstcdicod = "" then
             let m_ctc00m22.gstcdicod = 1                                            
          end if  
       
       whenever error continue
       
       open cctc00m22001 using m_ctc00m22.gstcdicod
       
       fetch cctc00m22001 into m_ctc00m22.gstcdicod,
                               m_ctc00m22.sprnom,
                               m_ctc00m22.gernom,
                               m_ctc00m22.cdnnom,
                               m_ctc00m22.anlnom,
                               m_ctc00m22.cadmat,
                               m_ctc00m22.caddat,
                               m_ctc00m22.atlmat,
                               m_ctc00m22.atldat
       
       if sqlca.sqlcode  =  notfound then
         error "Nenhum cadastro encontrado"
         initialize m_ctc00m22.* to null
       end if
       
       whenever error stop
                               
       on key (interrupt)
             exit input
             
 end input

 if int_flag  then
    let int_flag = false
    initialize m_ctc00m22.*   to null
    error " Operacao cancelada!"
    return
 end if           
           
 display by name  m_ctc00m22.gstcdicod,
                  m_ctc00m22.sprnom,
                  m_ctc00m22.gernom,
                  m_ctc00m22.cdnnom,
                  m_ctc00m22.anlnom,
                  m_ctc00m22.caddat,
                  m_ctc00m22.atldat
 
 call ctc00m22_func(1, m_ctc00m22.cadmat)
      returning l_cadfunnom 
 display l_cadfunnom to fucmat
 
 call ctc00m22_func(1, m_ctc00m22.atlmat)
      returning l_cadfunnom 
 display l_cadfunnom to fucalt                                           
                                 
end function

#-----------------------------------------------------------
function ctc00m22_proximo()
#-----------------------------------------------------------

define l_gstcdicod like dpakprsgstcdi.gstcdicod

let l_gstcdicod = m_ctc00m22.gstcdicod

  if m_ctc00m22_prep <> true then
     call ctc00m22_prepare()     
  end if                 
          
  whenever error continue
  
  select min (gstcdicod)
    into l_gstcdicod
    from dpakprsgstcdi
   where gstcdicod > m_ctc00m22.gstcdicod

  if l_gstcdicod is not null then
     open cctc00m22001 using l_gstcdicod
       
     fetch cctc00m22001 into m_ctc00m22.gstcdicod,
                             m_ctc00m22.sprnom,
                             m_ctc00m22.gernom,
                             m_ctc00m22.cdnnom,
                             m_ctc00m22.anlnom,
                             m_ctc00m22.cadmat,
                             m_ctc00m22.caddat,
                             m_ctc00m22.atlmat,
                             m_ctc00m22.atldat
     display by name  m_ctc00m22.gstcdicod,
                      m_ctc00m22.sprnom,
                      m_ctc00m22.gernom,
                      m_ctc00m22.cdnnom,
                      m_ctc00m22.anlnom,
                      m_ctc00m22.caddat,
                      m_ctc00m22.atldat                             
                             
  end if

  if l_gstcdicod  is null   or
     sqlca.sqlcode  =  notfound      then
     error " Nao ha' mais registros nesta direcao!"
  end if
  
  whenever error stop
  
end function    #-- ctc00m22_proximo

#-----------------------------------------------------------
function ctc00m22_anterior()
#-----------------------------------------------------------

define l_gstcdicod like dpakprsgstcdi.gstcdicod

let l_gstcdicod = m_ctc00m22.gstcdicod

  if m_ctc00m22_prep <> true then
     call ctc00m22_prepare()     
  end if                         

  whenever error continue
  select max (gstcdicod)
    into l_gstcdicod
    from dpakprsgstcdi
   where gstcdicod < m_ctc00m22.gstcdicod

  if l_gstcdicod is not null then
     open cctc00m22001 using l_gstcdicod
       
     fetch cctc00m22001 into m_ctc00m22.gstcdicod,
                             m_ctc00m22.sprnom,
                             m_ctc00m22.gernom,
                             m_ctc00m22.cdnnom,
                             m_ctc00m22.anlnom,
                             m_ctc00m22.cadmat,
                             m_ctc00m22.caddat,
                             m_ctc00m22.atlmat,
                             m_ctc00m22.atldat
     display by name  m_ctc00m22.gstcdicod,
                      m_ctc00m22.sprnom,
                      m_ctc00m22.gernom,
                      m_ctc00m22.cdnnom,
                      m_ctc00m22.anlnom,
                      m_ctc00m22.caddat,
                      m_ctc00m22.atldat                             
                             
  end if

  if l_gstcdicod  is null   or
     sqlca.sqlcode  =  notfound      then
     error " Nao ha' mais registros nesta direcao!"
  end if
  
  whenever error stop
  
end function    #-- ctc00m22_anterior



#---------------------------------------------- 
function ctc00m22_input()                             
#---------------------------------------------- 
 
 input by name m_ctc00m22.sprnom,
               m_ctc00m22.gernom,
               m_ctc00m22.cdnnom,
               m_ctc00m22.anlnom without defaults
         
       before field sprnom                                                   
          display by name m_ctc00m22.sprnom attribute(reverse)          
                                                                           
       after field sprnom                                                    
          display by name m_ctc00m22.sprnom                             
                                                                           
          if m_ctc00m22.sprnom is null or m_ctc00m22.sprnom = "" then
             error "CAMPO SUPERINTENDENTE E' OBRIGATORIO"                             
             next field sprnom                                               
          end if  
 
       before field gernom                                                   
          display by name m_ctc00m22.gernom attribute(reverse)
       
       after field gernom                                                    
          display by name m_ctc00m22.gernom                             
          
          if fgl_lastkey() = fgl_keyval("up")    or                                         
             fgl_lastkey() = fgl_keyval("left") then                                        
             next field sprnom                                                          
          end if
                                                                           
          if m_ctc00m22.gernom is null or m_ctc00m22.gernom = "" then
             error "CAMPO gernom E' OBRIGATORIO"                             
             next field gernom                                               
          end if
       
       before field cdnnom                                                   
          display by name m_ctc00m22.cdnnom attribute(reverse)  
       
       after field cdnnom                                                    
          display by name m_ctc00m22.cdnnom                             
 
          if fgl_lastkey() = fgl_keyval("up")    or                                         
             fgl_lastkey() = fgl_keyval("left") then                                        
             next field gernom                                                          
          end if
                                                                           
          if m_ctc00m22.cdnnom is null or m_ctc00m22.cdnnom = "" then
             error "CAMPO cdnnom E' OBRIGATORIO"                             
             next field cdnnom                                               
          end if
       
       before field anlnom                                                   
          display by name m_ctc00m22.anlnom attribute(reverse)  
       
       after field anlnom                                                    
          display by name m_ctc00m22.anlnom                             
 
          if fgl_lastkey() = fgl_keyval("up")    or                                         
             fgl_lastkey() = fgl_keyval("left") then                                        
             next field cdnnom                                                          
          end if
                                                                           
          if m_ctc00m22.anlnom is null or m_ctc00m22.anlnom = "" then
             error "CAMPO anlnom E' OBRIGATORIO"                             
             next field anlnom                                               
          end if
       
       on key(f17,interrupt)
          exit input
          
 end input
                         
end function             

#---------------------------------------------- 
function ctc00m22_inclui()                             
#----------------------------------------------                         

 define l_cadfunnom like isskfunc.funnom
 define l_data      date
 
 clear form
 initialize m_ctc00m22.* to null
 let l_cadfunnom = null
 
 call ctc00m22_input()
 
 if int_flag then
  let int_flag = false
  initialize m_ctc00m22.* to null
  error " Operacao cancelada!"
  clear form                  
  return
 end if 
  
 whenever error continue
 
 select max(gstcdicod)
   into m_ctc00m22.gstcdicod
   from dpakprsgstcdi
   
  if m_ctc00m22.gstcdicod is null or
     m_ctc00m22.gstcdicod = " "   then
     let m_ctc00m22.gstcdicod = 1
  else
     let m_ctc00m22.gstcdicod = m_ctc00m22.gstcdicod + 1
  end if
 
  begin work
  
     insert 
       into dpakprsgstcdi(gstcdicod,
                          sprnom, 
                          gernom,
                          cdnnom, 
                          anlnom,
                          cadmat,
                          caddat,
                          cademp,
                          cadusrtip,
                          atlmat,
                          atldat,
                          atlemp,
                          atlusrtip)
                   values(m_ctc00m22.gstcdicod,
                          m_ctc00m22.sprnom,
                          m_ctc00m22.gernom,       
                          m_ctc00m22.cdnnom,   
                          m_ctc00m22.anlnom,
                          g_issk.funmat,
                          today,
                          g_issk.empcod,
                          g_issk.usrtip,
                          g_issk.funmat,
                          today,
                          g_issk.empcod,
                          g_issk.usrtip)
                            
     if sqlca.sqlcode <> 0 then                                   
      error 'Erro INSERT / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5] 
      sleep 2                                                     
      error 'CTC00M22 / ctc00m22_inclui() '  sleep 2
      rollback work
      return
     else
      error 'Grupo cadastrado com sucesso'
      display by name m_ctc00m22.gstcdicod
     end if  
                                                          
  commit work
   
     call ctc00m22_func(g_issk.empcod, g_issk.funmat)
          returning l_cadfunnom
          
     display l_cadfunnom to fucmat
     display l_cadfunnom to fucalt
     let l_data = today
     display l_data to caddat 
     display l_data to atldat
    
 whenever error stop

end function

#---------------------------------------------- 
function ctc00m22_modifica()                             
#----------------------------------------------                         

 define l_cadfunnom like isskfunc.funnom
 define l_data      date
 
 let l_cadfunnom = null
 
 call ctc00m22_input()
 
 if int_flag then
  let int_flag = false
  initialize m_ctc00m22.* to null
  error " Operacao cancelada!"
  clear form                  
  return
 end if
  
 whenever error continue
 
  begin work
  
     update dpakprsgstcdi
                  set  (sprnom, 
                        gernom,
                        cdnnom, 
                        anlnom,
                        atlmat,
                        atldat)
                  =    
                       (m_ctc00m22.sprnom,
                        m_ctc00m22.gernom,       
                        m_ctc00m22.cdnnom,   
                        m_ctc00m22.anlnom,
                        g_issk.funmat,
                        today)
     where gstcdicod = m_ctc00m22.gstcdicod
                            
     if sqlca.sqlcode <> 0 then                                   
      error 'Erro UPDATE / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5] 
      sleep 2                                                     
      error 'CTC00M22 / ctc00m22_modifica() '  sleep 2
      rollback work
      return
     else
      error 'Grupo alterado com sucesso'
     end if  
                                                          
  commit work
  
     call ctc00m22_func(g_issk.empcod, g_issk.funmat)
          returning l_cadfunnom

     display l_cadfunnom to fucalt
     let l_data = today
     display l_data to atldat
    
 whenever error stop

end function

#---------------------------------------------- 
function ctc00m22_exclui()                             
#----------------------------------------------                         

 define l_confirmacao char(1)

 call cts08g01('C','S',"","CONFIRMA A EXCLUSAO DESTA","CADEIA DE RESPONSAVEIS?","")
      returning l_confirmacao
 
 if l_confirmacao = 'S' then
    whenever error continue
    clear form
    
     begin work
     
        delete from dpakprsgstcdi
         where gstcdicod = m_ctc00m22.gstcdicod
                         
        if sqlca.sqlcode <> 0 then                                   
         error 'Erro DELETE / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5] 
         sleep 2                                                     
         error 'CTC00M22 / ctc00m22_exclui() '  sleep 2
         rollback work
         return
        else
         error 'Grupo deletado com sucesso'
        end if  
                                                             
     commit work
     initialize m_ctc00m22.* to null 
    whenever error stop
 else
    error "Operacao cancelada"
 end if
 
end function
    
#---------------------------------------------------------
 function ctc00m22_func(param)
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

end function    

#=============================
function ctc00m22_popup()
#=============================

define ctc00m22_popup ARRAY[500] of record
   gstcdicod  like dpakprsgstcdi.gstcdicod,
   respdesc   char(50) 
end record

define l_indice smallint
define l_sql    char(200)

open window w_popup_ctc00m22_popup AT 11,06 WITH FORM "ctc00m22a"
        ATTRIBUTE (form line 1,comment line last,border)

let l_indice = 1

let l_sql = "select gstcdicod,nvl(sprnom,'')||'/ '||nvl(gernom,'')||'/ '||nvl(cdnnom,'')||'/ '||nvl(anlnom,'')  ",
            "  from dpakprsgstcdi   ",
            "  order by gstcdicod"
prepare pctc00m22_popup_001 from l_sql              
declare cctc00m22_popup_001 cursor for pctc00m22_popup_001 

open cctc00m22_popup_001 
foreach cctc00m22_popup_001 into ctc00m22_popup[l_indice].gstcdicod,
                           ctc00m22_popup[l_indice].respdesc 
        let l_indice = l_indice + 1
end foreach
close cctc00m22_popup_001

call set_count(l_indice-1)

display ARRAY ctc00m22_popup to s_ctc00m22_popup.*

        on key(control-c)
                initialize l_indice to null 
                exit display

        on key(F8)
                let l_indice = arr_curr()
                exit display 
		
end display
 
close window w_popup_ctc00m22_popup
 
 if l_indice is null then
    return l_indice,l_indice,l_indice 
 else
    return ctc00m22_popup[l_indice].gstcdicod
 end if    

end function    
