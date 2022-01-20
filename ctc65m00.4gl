#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Pegasus / Porto Socorro                                   #
# Modulo.........: ctc65m00                                                  #
# Objetivo.......: Cadastro para relacionar a natureza com os grupos         #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 211982                                                    #
#............................................................................#
# Desenvolvimento: Luiz Alberto, Meta                                        #
# Liberacao      :                                                           #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define mr_tela record
                   socntzcod         like datksocntz.socntzcod,             
                   socntzdes         like datksocntz.socntzdes
                end record

 define am_array array[100] of record
                    socntzgrpcod    like datrgrpntz.socntzgrpcod,
                    socntzgrpdes    like datksocntzgrp.socntzgrpdes,
                    srvabrprsinfflg like datrgrpntz.srvabrprsinfflg,
                    atmacnatchorqtd like datrgrpntz.atmacnatchorqtd,
                    srvacthorqtd    like datrgrpntz.srvacthorqtd,
                    cliavsenvhorqtd like datrgrpntz.cliavsenvhorqtd
                 end record
                 
                 
 define m_srvabrprsinfflg like datrgrpntz.srvabrprsinfflg,
        m_atmacnatchorqtd like datrgrpntz.atmacnatchorqtd,
        m_srvacthorqtd    like datrgrpntz.srvacthorqtd,  
        m_cliavsenvhorqtd like datrgrpntz.cliavsenvhorqtd                 

 define m_prep_ctc65m00 smallint
 define m_nro_reg smallint
 define m_res     smallint,
        m_msg     char(40)

#-------------------------------#
 function ctc65m00_prepare()
#-------------------------------#

   define l_sql char(500)

   let l_sql = ' select socntzgrpcod, '
                     ,' srvabrprsinfflg, '
                     ,' srvacthorqtd, '  
                     ,' atmacnatchorqtd, '
                     ,' cliavsenvhorqtd '
                ,' from datrgrpntz  '
               ,' where socntzcod = ? '               
               ,' order by socntzgrpcod '
              
   prepare pctc65m0001 from l_sql
   declare cctc65m0001 cursor for pctc65m0001

   let l_sql = ' select srvabrprsinfflg, '
                     ,' atmacnatchorqtd, '
                     ,' srvacthorqtd, ' 
                     ,' cliavsenvhorqtd '
                ,' from datrgrpntz ' 
               ,' where socntzgrpcod = ? '              
               ,'   and socntzcod = ? '

   prepare pctc65m0003 from l_sql
   declare cctc65m0003 cursor for pctc65m0003

   let l_sql = ' insert into datrgrpntz(socntzgrpcod, '
                                     ,' socntzcod, '
                                     ,' srvabrprsinfflg, '
                                     ,' atmacnatchorqtd, ' 
                                     ,' srvacthorqtd, '  
                                     ,' cliavsenvhorqtd) '
                              ,' values (?,?,?,?,?,?) '

   prepare pctc65m0004 from l_sql

   let l_sql = ' delete from datrgrpntz ' 
                    ,' Where socntzgrpcod = ? '
                      ,' and socntzcod = ? '

   prepare pctc65m0005 from l_sql
   
   let l_sql = ' update datrgrpntz ',
                  ' set srvabrprsinfflg = ?, ',
                      ' atmacnatchorqtd = ?, ',
                      ' srvacthorqtd    = ?, ',
                      ' cliavsenvhorqtd = ? ',
                ' where socntzgrpcod = ? ',
                  ' and socntzcod = ? '  
   
   prepare pctc65m0006 from l_sql   

   let m_prep_ctc65m00 = true

end function

#----------------------------------------------#
 function ctc65m00(l_socntzcod, l_socntzdes)
#----------------------------------------------#
 define l_socntzcod       like datksocntz.socntzcod
 define l_socntzdes       like datksocntz.socntzdes 
 define l_erro            smallint

 let l_erro = false
 let m_res = null
 let m_msg = null

  if m_prep_ctc65m00 is null or
     m_prep_ctc65m00 <> true then
     call ctc65m00_prepare()
  end if

  open window w_ctc65m00 at 06,02 with form "ctc65m00"   

  let mr_tela.socntzcod = l_socntzcod
  let mr_tela.socntzdes = l_socntzdes

  options 
    delete key control-y

  call ctc65m00_carrega_array()
  call ctc65m00_input_array()

  close window w_ctc65m00

  options 
    delete key f2
    
  let int_flag = false

end function

#----------------------------------#
 function ctc65m00_carrega_array()
#----------------------------------#

   define l_cont smallint

   let l_cont = 1
   initialize am_array to null
   clear form

   open cctc65m0001 using mr_tela.socntzcod
   #whenever error continue             
   foreach cctc65m0001 into am_array[l_cont].socntzgrpcod,
                            am_array[l_cont].srvabrprsinfflg,
                            am_array[l_cont].srvacthorqtd,
                            am_array[l_cont].atmacnatchorqtd,
                            am_array[l_cont].cliavsenvhorqtd

     call ctx24g00_descricao(am_array[l_cont].socntzgrpcod)
          returning m_res, m_msg, am_array[l_cont].socntzgrpdes

     if l_cont > 100 then
        error 'Limite do array excedido'
        exit foreach
     end if

     let l_cont = l_cont + 1  
   
   end foreach
   let m_nro_reg = l_cont - 1

 end function

#-------------------------------
 function ctc65m00_input_array()
#-------------------------------

define l_arr         smallint
      ,l_scr         smallint
      ,l_cont        integer
      ,l_resp        char(1)
   
 let int_flag = false
 let l_cont   = 0
 let l_arr    = 0
 let l_scr    = 0
 
 call set_count(m_nro_reg)
 display by name mr_tela.*
 
 input array am_array without defaults from s_ctc65m00.*
      before row
          let l_arr = arr_curr()
          let l_scr = scr_line()

      before field socntzgrpcod
         display am_array[l_arr].socntzgrpcod to 
                 s_ctc65m00[l_scr].socntzgrpcod attribute(reverse)

      after field socntzgrpcod
        display am_array[l_arr].socntzgrpcod to s_ctc65m00[l_scr].socntzgrpcod

        if am_array[l_arr].socntzgrpcod is null then 
           call ctx24g00_popup_grupo()
                returning m_res, am_array[l_arr].socntzgrpcod
        end if

        call ctx24g00_descricao(am_array[l_arr].socntzgrpcod)
             returning m_res, m_msg, am_array[l_arr].socntzgrpdes

        if m_res <> 1 then
           error m_msg
           next field socntzgrpcod
        end if

        display am_array[l_arr].socntzgrpcod to s_ctc65m00[l_scr].socntzgrpcod
        display am_array[l_arr].socntzgrpdes to s_ctc65m00[l_scr].socntzgrpdes

      before field srvabrprsinfflg
        display am_array[l_arr].srvabrprsinfflg to                   
                s_ctc65m00[l_scr].srvabrprsinfflg attribute(reverse) 

      after field srvabrprsinfflg                                   
        display am_array[l_arr].srvabrprsinfflg to                   
                s_ctc65m00[l_scr].srvabrprsinfflg

        if (am_array[l_arr].srvabrprsinfflg <> 'N' and
            am_array[l_arr].srvabrprsinfflg <> 'S') or 
            am_array[l_arr].srvabrprsinfflg is null or 
            am_array[l_arr].srvabrprsinfflg = " " then   
            error "Informe 'S' para informar prestador ou 'N' para nao informar"
            next field srvabrprsinfflg
        end if 
        
      #Altercao Burini
      
      before field atmacnatchorqtd
        display am_array[l_arr].atmacnatchorqtd to                   
                s_ctc65m00[l_scr].atmacnatchorqtd attribute(reverse) 

      after field atmacnatchorqtd                                   
        display am_array[l_arr].atmacnatchorqtd to                   
                s_ctc65m00[l_scr].atmacnatchorqtd

        if  am_array[l_arr].atmacnatchorqtd > "999:99" or 
            am_array[l_arr].atmacnatchorqtd < "000:00" then
            error "A quantidade de horas deve ser superior a 000:00 e inferior a 999:00"
            next field atmacnatchorqtd
        else
            if  fgl_lastkey() == fgl_keyval("LEFT") then
                next field srvabrprsinfflg
            end if
            if  am_array[l_arr].atmacnatchorqtd == "0:00" then
                prompt "Confirma Tempo de Acionamento igual a 0:00 (S/N)?" for char l_resp
                if  int_flag then
                    let int_flag = 0
                    next field atmacnatchorqtd
                end if
                if  l_resp not matches '[nNsS]' then
                    error "Digite apenas 'S' ou 'N'"
                    sleep 2
                    next field atmacnatchorqtd
                else 
                   if  l_resp matches '[nN]' then   
                       next field atmacnatchorqtd
                   end if
                end if
            end if  
        end if

      before field srvacthorqtd
        display am_array[l_arr].srvacthorqtd to                   
                s_ctc65m00[l_scr].srvacthorqtd attribute(reverse) 

      after field srvacthorqtd                                   
        display am_array[l_arr].srvacthorqtd to                   
                s_ctc65m00[l_scr].srvacthorqtd

        if  am_array[l_arr].srvacthorqtd > "999:99" or 
            am_array[l_arr].srvacthorqtd < "000:00" then
            error "A quantidade de horas deve ser superior a 000:00 e inferior a 999:00"
            next field srvacthorqtd
        else
            if  fgl_lastkey() == fgl_keyval("LEFT") then
                next field atmacnatchorqtd
            end if
            if  am_array[l_arr].srvacthorqtd == "0:00" then
                prompt "Confirma Tempo de Aceite igual a 0:00 (S/N)?" for char l_resp
                if  int_flag then
                    let int_flag = 0
                    next field srvacthorqtd
                end if
                if  l_resp not matches '[nNsS]' then
                    error "Digite apenas 'S' ou 'N'"
                    sleep 2
                    next field srvacthorqtd
                else 
                   if  l_resp matches '[nN]' then   
                       next field srvacthorqtd
                   end if
                end if
            end if    
        end if      
      
      before field cliavsenvhorqtd
        display am_array[l_arr].cliavsenvhorqtd to                   
                s_ctc65m00[l_scr].cliavsenvhorqtd attribute(reverse) 

      after field cliavsenvhorqtd                                   
        display am_array[l_arr].cliavsenvhorqtd to                   
                s_ctc65m00[l_scr].cliavsenvhorqtd

        if  am_array[l_arr].cliavsenvhorqtd > "999:99" or 
            am_array[l_arr].cliavsenvhorqtd < "000:00" then
            error "A quantidade de horas deve ser superior a 000:00 e inferior a 999:00"
            next field cliavsenvhorqtd
        else
            if  fgl_lastkey() == fgl_keyval("LEFT") then
                next field srvacthorqtd
            end if
            if  am_array[l_arr].cliavsenvhorqtd == "0:00" then
                prompt "Confirma Tempo de Aviso igual a 0:00 (S/N)?" for char l_resp
                if  int_flag then
                    let int_flag = 0
                    next field cliavsenvhorqtd
                end if
                if  l_resp not matches '[nNsS]' then
                    error "Digite apenas 'S' ou 'N'"
                    sleep 2
                    next field cliavsenvhorqtd
                else 
                   if  l_resp matches '[nN]' then   
                       next field cliavsenvhorqtd
                   end if
                end if
            end if        
        end if       
      
        if not ctc65m00_grava(l_arr) then
           next field socntzgrpcod
        end if      
      
      #LAteracao Burini
      
      on key(f2)
          call ctc65m00_exclui(l_arr) returning m_res
          call ctc65m00_dellinha(l_arr,l_scr)

      on key(f17,control-c,interrupt)
         clear form
         exit input
   end input 

 let int_flag = false
 
end function
 
#-----------------------------------------------#
 function ctc65m00_verifica_se_existe(l_arr)
#-----------------------------------------------#

   define l_arr smallint
   define l_erro smallint

   let l_erro = 1

   initialize m_srvabrprsinfflg,
              m_atmacnatchorqtd,
              m_srvacthorqtd,   
              m_cliavsenvhorqtd to null
              
   #whenever error continue
   open cctc65m0003 using am_array[l_arr].socntzgrpcod, mr_tela.socntzcod
   fetch cctc65m0003 into m_srvabrprsinfflg,
                          m_atmacnatchorqtd,
                          m_srvacthorqtd,  
                          m_cliavsenvhorqtd
   
   #whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_erro = 2
      else
         let l_erro = 3
      end if
   end if

   close cctc65m0003
   return l_erro

 end function

#-------------------------------#
 function ctc65m00_exclui(l_arr)
#-------------------------------#

   define l_arr smallint
   define l_erro smallint

   let l_erro = false

   #whenever error continue
   execute pctc65m0005 using am_array[l_arr].socntzgrpcod
                            ,mr_tela.socntzcod
   #whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'Erro DELETE cctc65m0005: ',sqlca.sqlcode
      let l_erro = true
   end if

   return l_erro

 end function

#-------------------------------#
 function ctc65m00_grava(l_arr)
#-------------------------------#

   define l_arr smallint
   define l_erro smallint

   let l_erro = false

   call ctc65m00_verifica_se_existe(l_arr)
        returning l_erro
   if  am_array[l_arr].atmacnatchorqtd = " " then
       let am_array[l_arr].atmacnatchorqtd = null
   end if
   if  am_array[l_arr].srvacthorqtd = " "    then 
       let am_array[l_arr].srvacthorqtd = null
   end if
   if  am_array[l_arr].cliavsenvhorqtd = " " then    
       let am_array[l_arr].cliavsenvhorqtd = null
   end if
       
   if l_erro = 2 then
      #whenever error continue
      execute pctc65m0004 using am_array[l_arr].socntzgrpcod
                               ,mr_tela.socntzcod
                               ,am_array[l_arr].srvabrprsinfflg
                               ,am_array[l_arr].atmacnatchorqtd
                               ,am_array[l_arr].srvacthorqtd  
                               ,am_array[l_arr].cliavsenvhorqtd
                                       
      #whenever error stop
      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT pctc65m0004: ',sqlca.sqlcode
         let l_erro = true   
         return l_erro   
      end if
   else
       if  l_erro = 1 then

           if m_srvabrprsinfflg <> am_array[l_arr].srvabrprsinfflg or
              m_atmacnatchorqtd <> am_array[l_arr].atmacnatchorqtd or
              m_srvacthorqtd    <> am_array[l_arr].srvacthorqtd    or 
              m_cliavsenvhorqtd <> am_array[l_arr].cliavsenvhorqtd or
              (m_srvabrprsinfflg is not null and am_array[l_arr].srvabrprsinfflg is not null) then 
              
              
              execute pctc65m0006 using am_array[l_arr].srvabrprsinfflg,
                                        am_array[l_arr].atmacnatchorqtd,
                                        am_array[l_arr].srvacthorqtd,   
                                        am_array[l_arr].cliavsenvhorqtd,
                                        am_array[l_arr].socntzgrpcod,
                                        mr_tela.socntzcod  
              
              if sqlca.sqlcode <> 0 then                                                              
                 error 'Erro UPDATE pctc65m0004: ',sqlca.sqlcode                                      
                 let l_erro = true                                                                    
                 return l_erro                                                                        
              end if                                                                                  
           end if
       end if
   end if

   return l_erro

 end function

#------------------------------------------#
 function ctc65m00_dellinha(l_arr, l_scr)
#------------------------------------------#

   define l_arr  smallint
   define l_scr  smallint
   define l_cont smallint

   for l_cont = l_arr to 99
      if am_array[l_arr].socntzgrpcod is not null then
         let am_array[l_cont].* = am_array[l_cont + 1].*
      else
         initialize am_array[l_arr].* to null
      end if
   end for

   for l_cont = l_scr to 4
      display am_array[l_arr].socntzgrpcod to s_ctc65m00[l_cont].socntzgrpcod
      display am_array[l_arr].socntzgrpdes to s_ctc65m00[l_cont].socntzgrpdes
      let l_arr = l_arr + 1
   end for

 end function
