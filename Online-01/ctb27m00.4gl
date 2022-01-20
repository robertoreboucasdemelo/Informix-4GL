#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h - Porto Socorro                         #
# Modulo        : ctb27m00                                            #
# Analista Resp.: Carlos Zyon                                         #
# PSI           : 187801                                              #
# Objetivo      : Cadastro de Mensagens para Prestadores              #
#.....................................................................#
# Desenvolvimento: Mariana , META                                     #
# Liberacao      : 07/10/2004                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare       smallint 
      ,m_arr           integer
      ,m_erro          smallint

define mr_ctb27m00     record
       prsmsgcod       like dpakprsmsg.prsmsgcod
      ,prsmsgtitdes    like dpakprsmsg.prsmsgtitdes
      ,prsmsgstt       like dpakprsmsg.prsmsgstt
                       end record

define ma_ctb27m00     array[500] of record
       prsmsgtxt       like dpakprsmsgtxt.prsmsgtxt 
                       end record

define m_pagina        smallint

#----------------------------#
function ctb27m00_prepare()
#----------------------------#
define l_comando     char(800)

   let l_comando = "select prsmsgtitdes, prsmsgstt "
                  ,"  from dpakprsmsg "
                  ," where prsmsgcod  = ? "
                  
   prepare pctb27m00001 from l_comando
   declare cctb27m00001 cursor for pctb27m00001
   
   let l_comando = "select prsmsgtxt "
                  ,"  from dpakprsmsgtxt "
                  ," where prsmsgcod = ? "                  
                  
   prepare pctb27m00002 from l_comando
   declare cctb27m00002 cursor for pctb27m00002

   let m_prepare = true 

   let l_comando = "select max(prsmsgcod) "
                  ,"  from dpakprsmsg "
                  
   prepare pctb27m00003 from l_comando
   declare cctb27m00003 cursor for pctb27m00003
                  
   let l_comando = "insert into dpakprsmsg "
                  ,"      (prsmsgcod,prsmsgtitdes,prsmsgstt, "
                  ,"       caddat   ,cadusrtip   ,cademp   , "
                  ,"       cadmat   ,atldat      ,atlusrtip, "
                  ,"       atlemp   ,atlmat)  "
                  ,"values(?,?,?,current,?,?,?,current,?,?,?) "

   prepare pctb27m00004 from l_comando

   let l_comando = "insert into dpakprsmsgtxt "
                  ,"      (prsmsgcod,prsmsglinseq,prsmsgtxt) "
                  ,"values(?,?,?)  "
                  
   prepare pctb27m00005 from l_comando                  

   let l_comando = "update dpakprsmsg "
                  ,"   set prsmsgtitdes = ? ,"
                  ,"       prsmsgstt    = ?  "
                  ," where prsmsgcod    = ?  "
                  
   prepare pctb27m00006 from l_comando                  

  
   let l_comando = "update dpakprsmsgtxt    "
                  ,"   set prsmsgtxt = ?    "
                  ," where prsmsgcod = ?    "
                  ,"   and prsmsglinseq = ? "
   
   prepare pctb27m00007 from l_comando                     
   
   let l_comando = "select prsmsglinseq     "
                  ,"  from dpakprsmsgtxt    "
                  ," where prsmsgcod    = ? "
                  ,"   and prsmsglinseq = ? "

   prepare pctb27m00008 from l_comando                                       
   declare cctb27m00008 cursor for pctb27m00008         
   
   let l_comando = "select prsmsgcod,prsmsgtitdes,prsmsgstt "
                  ,"  from dpakprsmsg order by 1"
                  
   prepare pctb27m00009 from l_comando                                       
   declare cctb27m00009 scroll cursor for pctb27m00009

   let l_comando = ' delete from dpakprsmsgtxt '
                  ,'  where prsmsgcod = ? '
   prepare pctb27m00010 from l_comando                                       
                  
   let m_prepare = true 
   
end function 

#------------------------#
function ctb27m00()
#------------------------#

   initialize mr_ctb27m00.* to null
   initialize ma_ctb27m00 to null 

   if m_prepare is null or 
      m_prepare <> true then 
      call ctb27m00_prepare()
   end if 
   
   let int_flag = false
   
   open window w_ctb27m00 at 4,2 with form "ctb27m00"
      attributes(prompt line last, message line last)


      menu "MENSAGENS"
      
         command key("S") "Seleciona"  "Seleciona Mensagem"
            call ctb27m00_seleciona()
            if mr_ctb27m00.prsmsgcod is not null then 
               next option "Proximo"
            end if 
            
         command key("P") "Proximo"    "Seleciona Proximo Registro"
            if m_pagina then 
               call ctb27m00_pagina(1)
               next option "Proximo"
            else 
               error "Nao existem registros nesta direcao"
            end if 
            
         command key("A") "Anterior"  "Seleciona Registro Anterior "
            if m_pagina then 
               call ctb27m00_pagina(-1)
               next option "Anterior"
            else
               error "Nao existem registros nesta direcao"
            end if 
            
         command key("M") "Modifica"  "Modifica Mensagem "
            if mr_ctb27m00.prsmsgcod is null then 
               error "Nenhum registro Selecionado "
               next option "Seleciona"
            else 
               call ctb27m00_input("M")
            end if 
            
         command key("I") "Inclui"    "Inclui Mensagem "
            clear form
            call ctb27m00_input("I")
            
         command key("Q") "pesQuisa"  "Pesquisa Mensagens"
            call ctb27m02()
            
         command key (F8)
            if mr_ctb27m00.prsmsgcod is not null then 
               call ctb27m01(mr_ctb27m00.prsmsgcod)
            else
               error  "Nao ha nenhum registro valido" sleep 2
            end if

         command key (control-c, interrupt,f17)
            exit menu
            
         command key("E") "Encerra"   "Retorna ao menu Anterior "
            exit menu
            
      end menu       
   
   let int_flag = false
   close window w_ctb27m00
   
end function 

#----------------------------#
function ctb27m00_seleciona()
#----------------------------#
define l_arr            integer 
      ,l_ind            smallint
      ,l_tecla          char(20)
      ,l_mostra         smallint

    initialize mr_ctb27m00.* to null
    initialize ma_ctb27m00   to null 
    
    let m_erro   = false
    let m_pagina = false
    let l_tecla  = null 
    let int_flag = false
    
    display by name mr_ctb27m00.*
    
    for l_ind = 1 to 13
        display ma_ctb27m00[l_ind].* to s_ctb27m00[l_ind].*
    end for 
    
    input by name mr_ctb27m00.prsmsgcod 
          
        after field prsmsgcod
           if mr_ctb27m00.prsmsgcod  is not null then 
              whenever error continue
              open cctb27m00001 using mr_ctb27m00.prsmsgcod
              fetch cctb27m00001
              whenever error stop 
              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode < 0 then 
                    error "Erro SELECT cctb27m00001, ",sqlca.sqlcode,'/'
                                                      ,sqlca.sqlerrd[2]    
                    sleep 2
                    error "ctb27m00_seleciona(), ", mr_ctb27m00.prsmsgcod      
                    sleep 2
                    let m_erro = true
                    exit input
                 end if
              end if 
           end if          
    
        on key(control-c, interrupt,f17)
           exit input

           
    end input       
    
    if not int_flag   and 
       m_erro = false then 
       if mr_ctb27m00.prsmsgcod is not null then 
          whenever error continue 
          open cctb27m00001 using mr_ctb27m00.prsmsgcod      
          fetch cctb27m00001 into mr_ctb27m00.prsmsgtitdes 
                                 ,mr_ctb27m00.prsmsgstt
          whenever error stop 
          if sqlca.sqlcode <> 0 then 
             if sqlca.sqlcode < 0 then 
                error "Erro SELECT cctb27m00001, ",sqlca.sqlcode,'/'
                                                  ,sqlca.sqlerrd[2]    
                sleep 2
                error "ctb27m00_seleciona(), ", mr_ctb27m00.prsmsgcod      
                sleep 2
              else  
                 error "Registro nao Encontrado !"
              end if 
              return 
          end if 
          display by name mr_ctb27m00.*
       else 
          let m_pagina = true 
          whenever error continue 
          open cctb27m00009
          fetch first cctb27m00009 into mr_ctb27m00.*
          whenever error stop  
          if sqlca.sqlcode <> 0 then 
             if sqlca.sqlcode < 0 then 
                error "Erro SELECT cctb27m00009, ",sqlca.sqlcode,'/'
                                                  ,sqlca.sqlerrd[2]    
                sleep 2
                error "ctb27m00_seleciona(), "
                sleep 2
                return
             end if 
          end if 
          display by name mr_ctb27m00.*
       end if  
       
       let l_arr = 1
       
       open cctb27m00002 using mr_ctb27m00.prsmsgcod  
       foreach cctb27m00002 into ma_ctb27m00[l_arr].*
       
           let l_arr = l_arr + 1
           
           if l_arr > 500 then 
              error "Limite de array Estourado. Avise a Informatica"
              exit foreach
           end if 
       end foreach 
        
       let l_arr = l_arr - 1
       
       call set_count(l_arr)
       
       for l_mostra = 1 to 13
       
           if ma_ctb27m00[l_mostra].prsmsgtxt is null then
              exit for
           end if
       
           display ma_ctb27m00[l_mostra].prsmsgtxt to s_ctb27m00[l_mostra].prsmsgtxt
       
       end for
              
       #display array ma_ctb27m00 to s_ctb27m00.*
       #
       #   on key(control-c, interrupt,f17)
       #      exit display
       #      
       #   on key(f8)
       #      call ctb27m01(mr_ctb27m00.prsmsgcod)
       #     
       #end display
    else     
       error "Selecao Cancelada !"
       let int_flag = false
    end if 
    
end function     

#------------------------------#
function ctb27m00_input(l_acao)
#------------------------------#

define l_acao            char(01)
      ,l_ind             integer
      ,l_arr             integer
      ,l_scr             integer
      ,l_ini             smallint
      ,l_pos             smallint
      ,l_ate             smallint

define l_prsmsglinseq    like dpakprsmsgtxt.prsmsglinseq  

   let m_erro   = false 
   let int_flag = false 

   if l_acao = "I" then 
      initialize mr_ctb27m00.* to null
      initialize ma_ctb27m00 to null

      for l_ind = 1 to 10
          display ma_ctb27m00[l_ind].* to s_ctb27m00[l_ind].*
      end for 

      whenever error continue
      open cctb27m00003 
      fetch cctb27m00003 into mr_ctb27m00.prsmsgcod 
      whenever error stop 
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "Erro SELECT cctb27m00003, ",sqlca.sqlcode,'/'
                                              ,sqlca.sqlerrd[2]    
            sleep 2
            error "ctb27m00_input(), "  sleep 2
            let m_erro = true 
            return 
         end if 
      else
         if mr_ctb27m00.prsmsgcod is null then 
            let mr_ctb27m00.prsmsgcod = 1
         else 
            let mr_ctb27m00.prsmsgcod = mr_ctb27m00.prsmsgcod + 1
         end if 
      end if 
   end if 

   display by name mr_ctb27m00.*
    
   
   input by name mr_ctb27m00.* without defaults
  
       before field prsmsgcod
          next field prsmsgtitdes
        

      after field prsmsgstt               
        if mr_ctb27m00.prsmsgstt is null then
           if fgl_lastkey() <> fgl_keyval("left") then 
              error "Informe a Situacao da Mensagem "
              next field prsmsgstt
           end if 
        else
           if mr_ctb27m00.prsmsgstt <> "A" and 
              mr_ctb27m00.prsmsgstt <> "C" then 
              error "Informe C(ancelada) ou A(tiva) "
              next field prsmsgstt
           end if 
        end if

      on key (control-c, interrupt,f17)
         exit input
 
   end input            
      
   if m_erro or 
      int_flag then 
      if l_acao = 'I' then 
         error "Inclusao Cancelada ! "
         clear form
      else
         error "Modificacao Cancelada ! "
      end if 
      let m_erro   = false
      let int_flag = false
      return
   end if      

   input array ma_ctb27m00 without defaults from s_ctb27m00.*
    
       before row
         let l_arr = arr_curr()
         let l_scr = scr_line()
       
       after field prsmsgtxt
          if ma_ctb27m00[l_arr].prsmsgtxt is null then
             if fgl_lastkey() <> fgl_keyval("up") then 
                error "Informe a Mensagem "
                next field prsmsgtxt
             end if 
          end if  
          
          if fgl_lastkey() = fgl_keyval("down") then 
             if ma_ctb27m00[l_arr + 1].prsmsgtxt is null then
                error "Nao ha mais registros nesta direcao"
                next field prsmsgtxt
             end if 
          end if 

        on key(f8)
           if l_acao = "I" then
              error 'Opcao Invalida para Inclusao !' sleep 2
           else
              call ctb27m01(mr_ctb27m00.prsmsgcod)
           end if
          
        on key(f5,control-o) 
           
           if l_acao = "M" then 
              let l_pos = arr_curr()
              let l_ate = arr_count()
              
              for l_ini = l_pos to l_ate
                  let ma_ctb27m00[l_ini].prsmsgtxt = null
              end for
           
           end if
        
           if l_acao = "I" then 
              begin work
              whenever error continue
              execute pctb27m00004 using mr_ctb27m00.prsmsgcod
                                        ,mr_ctb27m00.prsmsgtitdes
                                        ,mr_ctb27m00.prsmsgstt
                                        ,g_issk.usrtip
                                        ,g_issk.empcod
                                        ,g_issk.funmat
                                        ,g_issk.usrtip
                                        ,g_issk.empcod
                                        ,g_issk.funmat
              whenever error stop 
              if sqlca.sqlcode <> 0 then
                 error "Erro INSERT pctb27m00004 ",sqlca.sqlcode,'/'
                                                  ,sqlca.sqlerrd[2]    
                 sleep 2
                 error "ctb27m00_input(), ",mr_ctb27m00.prsmsgcod,'/' 
                                           ,mr_ctb27m00.prsmsgtitdes,'/' 
                                           ,mr_ctb27m00.prsmsgstt,'/'     
                                           ,g_issk.usrtip,'/'             
                                           ,g_issk.empcod,'/'             
                                           ,g_issk.funmat,'/'             
                                           ,g_issk.usrtip,'/'             
                                           ,g_issk.empcod,'/'             
                                           ,g_issk.funmat             
                 rollback work
                 let m_erro = true 
                 exit input
              end if     
               
              for l_ind = 1 to arr_count() 
              
                  if ma_ctb27m00[l_ind].prsmsgtxt is null then 
                     exit for
                  end if 
                  
                  whenever error continue 
                  execute pctb27m00005 using mr_ctb27m00.prsmsgcod
                                            ,l_ind
                                            ,ma_ctb27m00[l_ind].prsmsgtxt
                  whenever error stop 
                  if sqlca.sqlcode <> 0 then
                     error "Erro INSERT pctb27m00005 ",sqlca.sqlcode,'/'
                                                      ,sqlca.sqlerrd[2]    
                     sleep 2
                     error "ctb27m00_input(), ",mr_ctb27m00.prsmsgcod,'/' 
                                               ,l_ind, '/'
                                               ,ma_ctb27m00[l_ind].prsmsgtxt
                     rollback work
                     let m_erro = true 
                     exit for 
                  end if                                                              
              end for    
              
              if not m_erro then 
                 commit work
              end if 
              exit input
           else          #-- > Modificacao 
              begin work
              whenever error continue
              execute pctb27m00006 using mr_ctb27m00.prsmsgtitdes
                                        ,mr_ctb27m00.prsmsgstt
                                        ,mr_ctb27m00.prsmsgcod
              whenever error stop 
              if sqlca.sqlcode <> 0 then
                 error "Erro UPDATE pctb27m00006 ",sqlca.sqlcode,'/'
                                                  ,sqlca.sqlerrd[2]    
                 sleep 2
                 error "ctb27m00_input(), ",mr_ctb27m00.prsmsgtitdes,'/' 
                                           ,mr_ctb27m00.prsmsgstt
                                           ,mr_ctb27m00.prsmsgcod    
                 rollback work
                 let m_erro = true 
                 exit input
              end if 

              whenever error continue
              execute pctb27m00010 using mr_ctb27m00.prsmsgcod
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 error "Erro DELETE pctb27m00010 ",sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                 error "ctb27m00_input()/",mr_ctb27m00.prsmsgcod
                 rollback work
                 let m_erro = true 
                 exit input
              end if
              
              for l_ind = 1 to arr_count()
                  if ma_ctb27m00[l_ind].prsmsgtxt is null then
                     exit for 
                  end if 
                  let ma_ctb27m00[l_ind].prsmsgtxt =  ma_ctb27m00[l_ind].prsmsgtxt clipped
                  whenever error continue 
                  execute pctb27m00005 using mr_ctb27m00.prsmsgcod
                                            ,l_ind
                                            ,ma_ctb27m00[l_ind].prsmsgtxt
                  whenever error stop 
                  if sqlca.sqlcode <> 0 then
                     error "Erro INSERT pctb27m00005 ",sqlca.sqlcode,'/'
                                                      ,sqlca.sqlerrd[2]    
                     sleep 2
                     error "ctb27m00_input(), ",mr_ctb27m00.prsmsgcod,'/' 
                                               ,l_ind, '/'
                                               ,ma_ctb27m00[l_ind].prsmsgtxt
                     rollback work
                     let m_erro = true 
                     exit for 
                  end if                                                              
              end for     
              
              if not m_erro then 
                 commit work
              end if 
             
              exit input 
              
           end if 

   end input

   if m_erro or 
      int_flag then 
      if l_acao = 'I' then 
         error "Inclusao Cancelada ! "
      else
         error "Modificacao Cancelada ! "
      end if 
      let m_erro   = false
      let int_flag = false
   else 
      if l_acao = 'I' then 
         error "Inclusao Efetuada !"
      else
         error "Modificacao Efetuada !"
      end if
   end if 

end function       

#-------------------------------#
function ctb27m00_pagina(l_pos)
#-------------------------------#

define l_pos           integer
      ,l_arr           integer
      ,l_mostra        smallint
  
   whenever error continue
   fetch relative l_pos cctb27m00009 into mr_ctb27m00.*
   whenever error stop
   
   if sqlca.sqlcode <> 0 then 
      if sqlca.sqlcode < 0 then    
         error "Erro SELECT cctb27m00009 ",sqlca.sqlcode,'/'
                                          ,sqlca.sqlerrd[2]    
         sleep 2
         error "ctb27m00_pagina(), " sleep 2
      else 
         error "Nao existem registros nesta direcao"
      end if 
      return 
   end if 

   clear form
                            
   display by name mr_ctb27m00.*                     
                         
   let l_arr = 1
   initialize ma_ctb27m00 to null
   
   whenever error continue
   open cctb27m00002 using mr_ctb27m00.prsmsgcod  
     
   foreach cctb27m00002 into ma_ctb27m00[l_arr].*
   
       let l_arr = l_arr + 1
       
       if l_arr > 500 then 
          error "Limite de array Estourado. Avise a Informatica"
          exit foreach
       end if 
   end foreach 
    
   let l_arr = l_arr - 1
   
   call set_count(l_arr)

   for l_mostra = 1 to 13
   
       if ma_ctb27m00[l_mostra].prsmsgtxt is null then
          exit for
       end if
   
       display ma_ctb27m00[l_mostra].prsmsgtxt to s_ctb27m00[l_mostra].prsmsgtxt
   
   end for
   
   #display array ma_ctb27m00 to s_ctb27m00.*
   #
   #   on key(f8)
   #      call ctb27m01(mr_ctb27m00.prsmsgcod)
   #
   #   on key(control-c, interrupt,f17)
   #      exit display
   #      
   #end display
   
end function    
                                            