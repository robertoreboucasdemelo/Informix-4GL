{--------------------------------------------------------------------    
Porto Seguro Cia Seguros Gerais                                          
....................................................................     
Sistema       : Central 24h                                              
Modulo        : ctc62m00                                                 
Analista Resp.: Roberto Melo                                             
PSI           :                                                          
Objetivo      : Manutencao do Acesso a Tela de Serviços       
....................................................................     
Desenvolvimento:  Roberto Melo                                          
Liberacao      :                                                         
....................................................................     
----------------------------------------------------------------------}

                                                                            
                                                                            
globals "/homedsa/projetos/geral/globals/glct.4gl"                          


define m_prep smallint

define a_ctc62m00 array[2000] of record
  funmat         like isskfunc.funmat, 
  empsgl         like gabkemp.empsgl , 
  emp1           char(01)            ,
  emp2           char(01)            , 
  emp3           char(01)            , 
  emp4           char(01)            , 
  emp5           char(01)            , 
  emp6           char(01)            , 
  emp7           char(01)                            
end record           

define a_aux_ctc62m00 array[2000] of record   
  cponom      like datkdominio.cponom ,
  empcod      like gabkemp.empcod     ,
  rhmfunnom   like isskfunc.rhmfunnom       
end record 

define a_titulo record      
  tit1       smallint ,         
  tit2       smallint ,         
  tit3       smallint ,         
  tit4       smallint ,         
  tit5       smallint ,         
  tit6       smallint ,         
  tit7       smallint           
end record                      

                
#------------------------------------------------------------------
function ctc62m00_prepare()
#------------------------------------------------------------------

define l_sql char(1000)

   let l_sql = ' select count(*)  '  ,
               ' from isskfunc '     ,
               ' where funmat  =  ? ',
               ' and usrtip = "F" '
   prepare pctc62m00001 from l_sql                            
   declare cctc62m00001 cursor for pctc62m00001   
   
   let l_sql = ' select rhmfunnom  '          ,         
               ' from isskfunc '              ,         
               ' where funmat  =  ? '         ,         
               ' and empcod    =  ? '         ,
               ' and usrtip = "F" '            
   prepare pctc62m00002 from l_sql             
   declare cctc62m00002 cursor for pctc62m00002
   
   
   let l_sql = "insert into datkdominio (cponom ,", 
               " 			 cpocod ,",   
               "                         cpodes )",                        
               " values (?,?,?)"                                  
   prepare pctc62m00003 from l_sql  
   
   
   let l_sql = "delete from datkdominio ",
               " where cponom    = ?     ",
               " and cpodes[1,9] = ?     "
   prepare pctc62m00004 from l_sql                       
                         
   let l_sql = " select cpocod     ",    
               " from datkdominio  ",
               " where cponom  = ? ",
               " order by 1        "             
   prepare pctc62m00005 from l_sql                                                          
   declare cctc62m00005 cursor for pctc62m00005
   
   let l_sql = " select count(*)         ",           
               " from datkdominio        ",           
               " where cponom  = ?       ",           
               " and   cpodes[1,9]  = ?  "            
   prepare pctc62m00006 from l_sql              
   declare cctc62m00006 cursor for pctc62m00006 
   
   let l_sql = " select cpodes           ",    
               " from datkdominio        ",    
               " where cponom  = ?       ",
               " order by 1              "
   prepare pctc62m00007 from l_sql             
   declare cctc62m00007 cursor for pctc62m00007 
   
   let l_sql = ' select empcod  '             ,
               ' from isskfunc  '             ,
               ' where funmat  =  ? '         ,
               ' and usrtip = "F" '            
   prepare pctc62m00008 from l_sql             
   declare cctc62m00008 cursor for pctc62m00008
   
   let l_sql = " select cpodes           ",    
               " from datkdominio        ",    
               " where cponom  = ?       ",    
               " and   cpodes[1,9]  = ?  "     
   prepare pctc62m00009 from l_sql             
   declare cctc62m00009 cursor for pctc62m00009
   
      
   let m_prep = true 


end function 
                                                                            
#------------------------------------------------------------------         
 function ctc62m00()          
#------------------------------------------------------------------         
                                                                          

define lr_retorno  record
  cont        integer                 ,
  operacao    char(1)                 ,
  empcod      like gabkemp.empcod     ,
  funmat      like isskfunc.funmat    , 
  empsgl      like gabkemp.empsgl     , 
  rodape      char(70)                ,
  errocod     smallint                , 
  msg         char(300) 
end record

define arr_aux        smallint
define scr_aux        smallint
 
  
initialize lr_retorno.*, a_titulo.* to null    

for  arr_aux  =  1  to  2000                    
   initialize  a_ctc62m00[arr_aux].* ,
               a_aux_ctc62m00[arr_aux].* to  null   
end  for                                        

options delete key F2

open window w_ctc62m00 at 6,2 with form "ctc62m00"
     attribute(form line first, comment line last - 1)

let lr_retorno.rodape = " (F17)Abandona, (F1)Inclui, (F2)Exclui"

message lr_retorno.rodape
     

let a_aux_ctc62m00[1].cponom = "CTC62M00_MATRIC"    
let a_aux_ctc62m00[2].cponom = "CTC62M00_TIT"      

 if m_prep = false or 
    m_prep = " " then     
    call ctc62m00_prepare()
 end if 
 
 
call ctc62m00_titulo()

call ctc62m00_consulta()    
returning arr_aux

call set_count(arr_aux-1)
     

while true

   let int_flag = false
   
   display by name a_titulo.*

   input array a_ctc62m00 without defaults from s_ctc62m00.*

    #---------------------------------------------------
      before row
    #---------------------------------------------------
         let arr_aux = arr_curr()
         let scr_aux = scr_line()         

    #---------------------------------------------------
      before insert
    #---------------------------------------------------
         let lr_retorno.operacao = "i"
         initialize  a_ctc62m00[arr_aux]  to null
         display a_ctc62m00[arr_aux].funmat     to
                 s_ctc62m00[scr_aux].funmat          
         
    #---------------------------------------------------
      before field funmat
    #---------------------------------------------------
         display a_ctc62m00[arr_aux].funmat  to
                 s_ctc62m00[scr_aux].funmat  attribute (reverse)
         
         message lr_retorno.rodape
         
         let lr_retorno.funmat = a_ctc62m00[arr_aux].funmat
         call ctc62m00_display_nome(a_aux_ctc62m00[arr_aux].rhmfunnom)
         
    #---------------------------------------------------                   
      after field funmat 
    #---------------------------------------------------  
         display a_ctc62m00[arr_aux].funmat   to
                 s_ctc62m00[scr_aux].funmat

         
         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then            
            let lr_retorno.operacao = " "
         else                      
            if a_ctc62m00[arr_aux].funmat  is null   then
               error " Matricula do Funcionario deve ser Informado!"            
               next field funmat                 
            else 
                
                if a_ctc62m00[arr_aux].funmat <> lr_retorno.funmat then
                    error "Alteração não Permitida!"
                    let a_ctc62m00[arr_aux].funmat = lr_retorno.funmat
                    next field funmat
                end if
                
                call ctc62m00_valida_func(a_ctc62m00[arr_aux].funmat)
                returning lr_retorno.cont  ,
                          lr_retorno.empcod
                                
                if lr_retorno.cont = 0 then          
                   error "Matricula nao cadastrada!" 
                   next field funmat                     
                end if                                                              
                                                                                                     
            end if
         end if    
  

 
    
    #---------------------------------------------------
      before field empsgl
    #---------------------------------------------------
         display a_ctc62m00[arr_aux].empsgl   to
                 s_ctc62m00[scr_aux].empsgl   attribute (reverse)
  
         
         if lr_retorno.cont <> 0 then
          
                if lr_retorno.cont = 1 then                     
                    
                    
                    call ctc62m00_consulta_func(a_ctc62m00[arr_aux].funmat,
                                                lr_retorno.empcod         ) 
                    returning a_aux_ctc62m00[arr_aux].rhmfunnom ,
                              lr_retorno.errocod
                    
                    if lr_retorno.errocod <> 0 then
                         next field funmat 
                    end if                     
                               
                    call cty14g00_empresa(1,lr_retorno.empcod)
                    returning lr_retorno.errocod , 
                              lr_retorno.msg     ,
                              a_ctc62m00[arr_aux].empsgl                                                 
                                                                                                                                                                                                                                                                                                         
                    if lr_retorno.errocod <> 1 then                                                                               
                       call errorlog(lr_retorno.msg)                                                                         
                       error lr_retorno.msg                                                                                  
                       next field funmat                                                                                     
                    end if                                                                                                   
                    
                else
                     call cty14g00_popup_empresa()
                     returning lr_retorno.errocod ,
                               lr_retorno.empcod  ,
                               a_ctc62m00[arr_aux].empsgl   
                               
                     call ctc62m00_consulta_func(a_ctc62m00[arr_aux].funmat,
                                                 lr_retorno.empcod         )           
                     returning a_aux_ctc62m00[arr_aux].rhmfunnom ,                                                            
                               lr_retorno.errocod                                      
                                                                                       
                     if lr_retorno.errocod <> 0 then                                   
                          next field funmat                                            
                     end if                                                            
                               
                                                                                                                                                              
                end if                                          
                
                display a_ctc62m00[arr_aux].empsgl   to 
                        s_ctc62m00[scr_aux].empsgl   
                        
                call ctc62m00_display_nome(a_aux_ctc62m00[arr_aux].rhmfunnom) 
                                                 
         
         end if       
         
         next field emp1  
   
     
   #---------------------------------------------------
     before field emp1                                         
   #---------------------------------------------------                                                                 
        display a_ctc62m00[arr_aux].emp1   to                    
                s_ctc62m00[scr_aux].emp1   attribute (reverse)
        
        call cty14g00_empresa(1,a_titulo.tit1) 
        returning lr_retorno.errocod ,             
                  lr_retorno.msg     ,             
                  lr_retorno.empsgl       
        
        message lr_retorno.rodape clipped, " - ",lr_retorno.empsgl clipped            
   #---------------------------------------------------                    
     after field emp1                                                     
   #---------------------------------------------------                    
        display a_ctc62m00[arr_aux].emp1   to                              
                s_ctc62m00[scr_aux].emp1   
                
        if fgl_lastkey() = fgl_keyval("up")     or  
           fgl_lastkey() = fgl_keyval("left")   or
           fgl_lastkey() = fgl_keyval("down")   then     
              next field funmat
        end if 
        
             
        if a_ctc62m00[arr_aux].emp1 is not null and
           a_ctc62m00[arr_aux].emp1 <> "x"      then             
            error "Por favor Insira Somente x! " 
            next field emp1
        end if          
    
    #---------------------------------------------------        
      before field emp2                                         
    #---------------------------------------------------        
         display a_ctc62m00[arr_aux].emp2   to                  
                 s_ctc62m00[scr_aux].emp2   attribute (reverse) 
          
         call cty14g00_empresa(1,a_titulo.tit2) 
         returning lr_retorno.errocod ,         
                   lr_retorno.msg     ,         
                   lr_retorno.empsgl             
                                                 
         message lr_retorno.rodape clipped, " - ",lr_retorno.empsgl clipped        
                                                                
    #---------------------------------------------------        
      after field emp2                                          
    #---------------------------------------------------        
         display a_ctc62m00[arr_aux].emp2   to                  
                 s_ctc62m00[scr_aux].emp2                       
                                                                
         if fgl_lastkey() = fgl_keyval("up")     or             
            fgl_lastkey() = fgl_keyval("left")   or
            fgl_lastkey() = fgl_keyval("down")   then               
               next field emp1                               
         end if                                                 
                                                                
                                                                
         if a_ctc62m00[arr_aux].emp2 is not null and            
            a_ctc62m00[arr_aux].emp2 <> "x"      then           
             error "Por favor Insira Somente x! "               
             next field emp2                                    
         end if                                                 
      
      
     #---------------------------------------------------        
       before field emp3                                         
     #---------------------------------------------------        
          display a_ctc62m00[arr_aux].emp3   to                  
                  s_ctc62m00[scr_aux].emp3   attribute (reverse) 
          
          call cty14g00_empresa(1,a_titulo.tit3) 
          returning lr_retorno.errocod ,         
                    lr_retorno.msg     ,         
                    lr_retorno.empsgl            
                                                 
           message lr_retorno.rodape clipped, " - ",lr_retorno.empsgl clipped         
                                                                         
     #---------------------------------------------------        
       after field emp3                                          
     #---------------------------------------------------        
          display a_ctc62m00[arr_aux].emp3   to                  
                  s_ctc62m00[scr_aux].emp3                      
                                                                
          if fgl_lastkey() = fgl_keyval("up")     or            
             fgl_lastkey() = fgl_keyval("left")   or
             fgl_lastkey() = fgl_keyval("down")   then          
                next field emp2                               
          end if                                                
                                                                
                                                                
          if a_ctc62m00[arr_aux].emp3 is not null and           
             a_ctc62m00[arr_aux].emp3 <> "x"      then          
              error "Por favor Insira Somente x! "              
              next field emp3                                   
          end if                                                
     
     
     #---------------------------------------------------       
       before field emp4                                        
     #---------------------------------------------------       
          display a_ctc62m00[arr_aux].emp4   to                 
                  s_ctc62m00[scr_aux].emp4   attribute (reverse)
          
          call cty14g00_empresa(1,a_titulo.tit4) 
          returning lr_retorno.errocod ,         
                    lr_retorno.msg     ,         
                    lr_retorno.empsgl            
                                                 
           message lr_retorno.rodape clipped, " - ",lr_retorno.empsgl clipped            
          
                                                                       
     #---------------------------------------------------       
       after field emp4                                         
     #---------------------------------------------------       
          display a_ctc62m00[arr_aux].emp4   to                 
                  s_ctc62m00[scr_aux].emp4                      
                                                                
          if fgl_lastkey() = fgl_keyval("up")     or            
             fgl_lastkey() = fgl_keyval("left")   or
             fgl_lastkey() = fgl_keyval("down")   then        
                next field emp3                               
          end if                                                
                                                                
                                                                
          if a_ctc62m00[arr_aux].emp4 is not null and           
             a_ctc62m00[arr_aux].emp4 <> "x"      then          
              error "Por favor Insira Somente x! "              
              next field emp4                                   
          end if                                                
     
     
      #---------------------------------------------------       
        before field emp5                                        
      #---------------------------------------------------       
           display a_ctc62m00[arr_aux].emp5   to                 
                   s_ctc62m00[scr_aux].emp5   attribute (reverse)
           
           call cty14g00_empresa(1,a_titulo.tit5) 
           returning lr_retorno.errocod ,         
                     lr_retorno.msg     ,         
                     lr_retorno.empsgl            
                                                  
           message lr_retorno.rodape clipped, " - ",lr_retorno.empsgl clipped         
                                                                 
      #---------------------------------------------------       
        after field emp5                                         
      #---------------------------------------------------       
           display a_ctc62m00[arr_aux].emp5   to                 
                   s_ctc62m00[scr_aux].emp5                      
                                                                 
           if fgl_lastkey() = fgl_keyval("up")     or            
              fgl_lastkey() = fgl_keyval("left")   or
              fgl_lastkey() = fgl_keyval("down")   then               
                 next field emp4                               
           end if                                                
                                                                 
                                                                 
           if a_ctc62m00[arr_aux].emp5 is not null and           
              a_ctc62m00[arr_aux].emp5 <> "x"      then          
               error "Por favor Insira Somente x! "              
               next field emp5                                   
           end if                                                
       
      #---------------------------------------------------         
        before field emp6                                          
      #---------------------------------------------------         
           display a_ctc62m00[arr_aux].emp6   to                   
                   s_ctc62m00[scr_aux].emp6   attribute (reverse)  
            
           call cty14g00_empresa(1,a_titulo.tit6) 
           returning lr_retorno.errocod ,         
                     lr_retorno.msg     ,           
                     lr_retorno.empsgl             
                                                   
           message lr_retorno.rodape clipped, " - ",lr_retorno.empsgl clipped         
                                                                   
      #---------------------------------------------------         
        after field emp6                                           
      #---------------------------------------------------         
           display a_ctc62m00[arr_aux].emp6   to                   
                   s_ctc62m00[scr_aux].emp6                        
                                                                   
           if fgl_lastkey() = fgl_keyval("up")     or              
              fgl_lastkey() = fgl_keyval("left")   or
              fgl_lastkey() = fgl_keyval("down")   then                
                 next field emp5                                   
           end if                                                  
                                                                   
                                                                   
           if a_ctc62m00[arr_aux].emp6 is not null and             
              a_ctc62m00[arr_aux].emp6 <> "x"      then            
               error "Por favor Insira Somente x! "                
               next field emp6                                     
           end if                                                  
       
       
       #---------------------------------------------------         
         before field emp7                                         
       #---------------------------------------------------         
            display a_ctc62m00[arr_aux].emp7   to                   
                    s_ctc62m00[scr_aux].emp7   attribute (reverse)  
            
            call cty14g00_empresa(1,a_titulo.tit7) 
            returning lr_retorno.errocod ,         
                      lr_retorno.msg     ,         
                      lr_retorno.empsgl            
                                                   
            message lr_retorno.rodape clipped, " - ",lr_retorno.empsgl clipped        
                                                                     
       #---------------------------------------------------         
         after field emp7                                           
       #---------------------------------------------------         
            display a_ctc62m00[arr_aux].emp7   to                   
                    s_ctc62m00[scr_aux].emp7                        
                                                                    
            if fgl_lastkey() = fgl_keyval("up")     or              
               fgl_lastkey() = fgl_keyval("left")   or
               fgl_lastkey() = fgl_keyval("down")   then                 
                  next field emp6                                   
            end if                                                  
                                                                    
                                                                    
            if a_ctc62m00[arr_aux].emp7 is not null and             
               a_ctc62m00[arr_aux].emp7 <> "x"      then            
                error "Por favor Insira Somente x! "                
                next field emp7                                     
            end if                                                  
       
            if lr_retorno.operacao <> "i" then
               let lr_retorno.operacao = "a"     
            end if
       
       
                  
                           
     #--------------------------------------------------- 
      on key (interrupt)
     #---------------------------------------------------
         exit input
      
     #---------------------------------------------------
      before delete
     #---------------------------------------------------
         let lr_retorno.operacao = "d"
         if a_ctc62m00[arr_aux].funmat  is null   then
            continue input
         else
            if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
               exit input
            end if
      
              if not ctc62m00_exclui(a_ctc62m00[arr_aux].funmat,
                                   a_aux_ctc62m00[arr_aux].empcod) then
                 
                   error "Erro na Exclusão da Matricula! "
                   next field funmat
              end if
                                  
              initialize a_ctc62m00[arr_aux].* to null
              display    a_ctc62m00[scr_aux].* to s_ctc62m00[scr_aux].*
         end if

     #---------------------------------------------------
      after row
     #---------------------------------------------------        
                        
            case lr_retorno.operacao
               when "i"
                      
                 if not ctc62m00_inclui(a_ctc62m00[arr_aux].funmat,
                                        lr_retorno.empcod         ,
                                        arr_aux                   ) then
                 
                     next field funmat 
                 end if
                when "a"
                       
                  if  a_aux_ctc62m00[arr_aux].empcod is null then   
                      let a_aux_ctc62m00[arr_aux].empcod = lr_retorno.empcod  
                  end if    
                                                  
                 if ctc62m00_exclui(a_ctc62m00[arr_aux].funmat,        
                                      a_aux_ctc62m00[arr_aux].empcod)then    
                                                                         
                      if not ctc62m00_inclui(a_ctc62m00[arr_aux].funmat      ,
                                             a_aux_ctc62m00[arr_aux].empcod  ,
                                             arr_aux                   ) then                             
                          next field funmat  
                      end if  
                 else
                      error "Erro na Alteração da Matricula! "
                      next field funmat 
                     
                 end if                                                              
            end case
         

         let lr_retorno.operacao = " "

   end input

   if int_flag       then
      exit while
   end if

end while

close cctc62m00001
let int_flag = false

options delete key F40

close window w_ctc62m00

end function

#---------------------------------------------------                                                  
function ctc62m00_consulta()                                                                    
#---------------------------------------------------                                                  


define lr_retorno  record                               
  cpodes      like datkdominio.cpodes ,                                         
  errocod     smallint                ,          
  msg         char(300)               ,
  empcod      like gabkemp.empcod                  
end record 

define lr_aux array[7] of record
  cpodes      like datkdominio.cpodes
end record

define arr_aux  smallint 
define arr_aux2 smallint                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                            
initialize lr_retorno.* to null

for  arr_aux  =  1  to  7                     
   initialize  lr_aux[arr_aux].* to  null 
end  for                                          

let arr_aux   = 1                                                                                                                                                                           
let arr_aux2  = 0
                                           
        open cctc62m00007 using a_aux_ctc62m00[1].cponom               
        foreach cctc62m00007 into lr_retorno.cpodes                           
                                       
          let a_ctc62m00[arr_aux].funmat     = lr_retorno.cpodes[1,6]        
          let a_aux_ctc62m00[arr_aux].empcod = lr_retorno.cpodes[8,9]  
         
         
          call ctc62m00_consulta_func(a_ctc62m00[arr_aux].funmat    ,
                                      a_aux_ctc62m00[arr_aux].empcod)
          returning a_aux_ctc62m00[arr_aux].rhmfunnom ,                     
                    lr_retorno.errocod            
          
          let lr_aux[1].cpodes = lr_retorno.cpodes[11,12]
          let lr_aux[2].cpodes = lr_retorno.cpodes[14,15]
          let lr_aux[3].cpodes = lr_retorno.cpodes[17,18]
          let lr_aux[4].cpodes = lr_retorno.cpodes[20,21]
          let lr_aux[5].cpodes = lr_retorno.cpodes[23,24]
          let lr_aux[6].cpodes = lr_retorno.cpodes[26,27]
          let lr_aux[7].cpodes = lr_retorno.cpodes[29,30]      
                  
          call cty14g00_empresa(1,a_aux_ctc62m00[arr_aux].empcod)   
          returning lr_retorno.errocod ,               
                    lr_retorno.msg     ,               
                    a_ctc62m00[arr_aux].empsgl  
                    
          
          
          for arr_aux2  =  1  to  7 
          
               if lr_aux[arr_aux2].cpodes is not null then 
               
                   case lr_aux[arr_aux2].cpodes
                       when a_titulo.tit1
                            let a_ctc62m00[arr_aux].emp1 = "x"
                       when a_titulo.tit2                     
                            let a_ctc62m00[arr_aux].emp2 = "x"
                       when a_titulo.tit3                     
                            let a_ctc62m00[arr_aux].emp3 = "x"
                       when a_titulo.tit4                     
                            let a_ctc62m00[arr_aux].emp4 = "x"
                       when a_titulo.tit5                     
                            let a_ctc62m00[arr_aux].emp5 = "x"
                       when a_titulo.tit6                     
                            let a_ctc62m00[arr_aux].emp6 = "x"
                       when a_titulo.tit7                     
                            let a_ctc62m00[arr_aux].emp7 = "x"
                       
                   end case 
                   
               end if                      
                   
          end for                                             
                                   
          let  arr_aux = arr_aux + 1       
               
                
        end foreach         
         
        return arr_aux         
                                                                                                                                                                                                                                                                                                                                         
end function 

#---------------------------------------------------                     
function ctc62m00_titulo()                                             
#---------------------------------------------------                     
                                                                                                                                                
define lr_retorno  record                                                                                   
  cpodes      like datkdominio.cpodes                                                                                                   
end record                                                               
                                                                         
define arr_aux smallint                                                  
                                                                         
initialize lr_retorno.* to null                                          
                                                                         
let arr_aux = 1                                                          
                                                                         
                                                                         
        open cctc62m00007 using a_aux_ctc62m00[2].cponom                 
        foreach cctc62m00007 into lr_retorno.cpodes                      
                                                                         
            case arr_aux 
                 when 1
                      let a_titulo.tit1 = lr_retorno.cpodes
                 when 2                                    
                      let a_titulo.tit2 = lr_retorno.cpodes 
                 when 3                                         
                      let a_titulo.tit3 = lr_retorno.cpodes 
                 when 4                                    
                      let a_titulo.tit4 = lr_retorno.cpodes
                 when 5                                    
                      let a_titulo.tit5 = lr_retorno.cpodes   
                 when 6                                         
                      let a_titulo.tit6 = lr_retorno.cpodes      
                 when 7                                    
                      let a_titulo.tit7 = lr_retorno.cpodes          
           
            end case
                                                                         
          let  arr_aux = arr_aux + 1                                     
                                                                         
                                                                         
        end foreach                                                      
                                                                                                                                                                                                                   
                                                                         
end function         
                                                    
#---------------------------------------------------     
function ctc62m00_inclui(lr_param, arr_aux)
#---------------------------------------------------     

define lr_param record
  funmat like isskfunc.funmat,
  empcod like isskfunc.empcod
end record

define arr_aux smallint

define lr_retorno record
  cponom     like datkdominio.cponom ,
  cpocod     like datkdominio.cpocod ,    
  cpodes     like datkdominio.cpodes ,
  funmat     char(10)                 ,        
  cont       integer
end record

initialize lr_retorno.* to null
       
                                                
       let lr_retorno.funmat = lr_param.funmat using "&&&&&&" , "|", lr_param.empcod using "&&"   
                                                                                          
       whenever error stop                                                                
       open cctc62m00006 using a_aux_ctc62m00[1].cponom  ,                                
                               lr_retorno.funmat                                      
       fetch cctc62m00006 into lr_retorno.cont                                             
       whenever error continue                                                            
                                                                                          
       if lr_retorno.cont > 0 then                                                         
          error "Matricula já cadastrada!"                                                
          return false                                                               
       end if                                                                                
 
       let lr_retorno.cpodes = lr_param.funmat using "&&&&&&", "|", lr_param.empcod using "&&", "|"
         
       if a_ctc62m00[arr_aux].emp1 is not null then                           
          let lr_retorno.cpodes = lr_retorno.cpodes clipped , a_titulo.tit1 using "&&", "|"   
       end if                                                                   
                                                                                
       if a_ctc62m00[arr_aux].emp2 is not null then                                      
          let lr_retorno.cpodes = lr_retorno.cpodes clipped, a_titulo.tit2 using "&&", "|"  
       end if                                                                   
                                                                                
       if a_ctc62m00[arr_aux].emp3 is not null then                                      
          let lr_retorno.cpodes = lr_retorno.cpodes clipped, a_titulo.tit3 using "&&", "|"  
       end if                                                                   
                                                                                
       if a_ctc62m00[arr_aux].emp4 is not null then                                      
          let lr_retorno.cpodes = lr_retorno.cpodes clipped, a_titulo.tit4 using "&&", "|"  
       end if                                                                   
                                                                                
       if a_ctc62m00[arr_aux].emp5 is not null then                                      
          let lr_retorno.cpodes = lr_retorno.cpodes clipped, a_titulo.tit5 using "&&", "|"  
       end if                                                                   
                                                                                
       if a_ctc62m00[arr_aux].emp6 is not null then                                      
          let lr_retorno.cpodes = lr_retorno.cpodes clipped, a_titulo.tit6 using "&&", "|"  
       end if                                                                   
                                                                                
       if a_ctc62m00[arr_aux].emp7 is not null then                                      
          let lr_retorno.cpodes = lr_retorno.cpodes clipped, a_titulo.tit7 using "&&", "|"  
       end if                                                                        
       
       call ctc62m00_gera_cpocod()
       returning lr_retorno.cpocod         
       
       begin work  
                     
       whenever error continue
       execute pctc62m00003 using a_aux_ctc62m00[1].cponom,      
                                  lr_retorno.cpocod       ,  
                                  lr_retorno.cpodes  
       whenever error stop                                                                                 
                                                                                                     
       if sqlca.sqlcode <> 0 then                                                                                                                                  
          error "Erro <",sqlca.sqlcode ,"> ao inserir matricula ! Avise a informatica!" 
          rollback work
          return false                                                                 
       end if     
            
       commit work
       return true                                                                                         

end function

#---------------------------------------------------     
function ctc62m00_exclui(lr_param)
#---------------------------------------------------     

define lr_param record
  funmat like isskfunc.funmat,
  empcod like isskfunc.empcod
end record

define lr_retorno record
  cponom like datkdominio.cponom ,
  cpodes like datkdominio.cpodes        
end record

initialize lr_retorno.* to null
   
       let lr_retorno.cpodes = lr_param.funmat using "&&&&&&", "|", lr_param.empcod using "&&"
       
       whenever error continue
       execute pctc62m00004 using a_aux_ctc62m00[1].cponom,     
                                  lr_retorno.cpodes
       whenever error stop  
       
       if sqlca.sqlcode <> 0 then
          return false
       end if
       
       return true
                                                                                                                                                                                               
end function

#---------------------------------------------------  
function ctc62m00_gera_cpocod()                    
#---------------------------------------------------   

define lr_retorno record           
  cpocod     like datkdominio.cpocod, 
  cpocod_ant like datkdominio.cpocod
end record

initialize lr_retorno.* to null
  
  let lr_retorno.cpocod_ant = 0  
  let lr_retorno.cpocod     = 0  
  
                         
  open cctc62m00005 using a_aux_ctc62m00[1].cponom  
  foreach cctc62m00005 into lr_retorno.cpocod   
                    
                                              
     if lr_retorno.cpocod - 1 = lr_retorno.cpocod_ant then
        let lr_retorno.cpocod_ant = lr_retorno.cpocod
        continue foreach
     else
        let lr_retorno.cpocod = lr_retorno.cpocod_ant + 1   
        return lr_retorno.cpocod 
     end if   


  end foreach

  let lr_retorno.cpocod = lr_retorno.cpocod + 1

  return lr_retorno.cpocod 

end function

#---------------------------------------------------
function ctc62m00_consulta_func(lr_param)                     
#---------------------------------------------------

define lr_param record
   funmat      like isskfunc.funmat,
   empcod      like gabkemp.empcod    
end record

define lr_retorno record
   rhmfunnom   like isskfunc.rhmfunnom ,
   errocod     smallint
end record

initialize lr_retorno.* to null

     whenever error stop                                                                                     
     open  cctc62m00002 using lr_param.funmat,
                              lr_param.empcod                                                     
     fetch cctc62m00002 into lr_retorno.rhmfunnom                                                        
     whenever error continue                                                                                 
                                                                                                             
     if sqlca.sqlcode <> 0 then                                                                              
        let lr_retorno.errocod = sqlca.sqlcode                                                               
        error "Erro <",lr_retorno.errocod ,"> ao consultar a matricula! Avise a informatica!"                                                                                                                                                                   
     end if       
     
     return lr_retorno.rhmfunnom  ,
            lr_retorno.errocod
     
                                                                                               
end function

#---------------------------------------------------
function ctc62m00_display_nome(lr_param)           
#---------------------------------------------------

define lr_param record
    rhmfunnom like isskfunc.rhmfunnom
end record

 display by name lr_param.rhmfunnom

end function

#---------------------------------------------------
function ctc62m00_valida_func(lr_param)           
#---------------------------------------------------

define lr_param record
   funmat      like isskfunc.funmat 
end record

define lr_retorno record                  
   empcod      like gabkemp.empcod     ,   
   cont        smallint                
end record

initialize lr_retorno.* to null

       whenever error stop                                 
       open cctc62m00001 using lr_param.funmat  
       fetch cctc62m00001 into lr_retorno.cont             
       whenever error continue                             
       
       if lr_retorno.cont = 1 then 
           
          whenever error stop                                                                      
          open  cctc62m00008 using lr_param.funmat                                                 
          fetch cctc62m00008 into  lr_retorno.empcod                                                 
          whenever error continue                                                                   
                                                                                                    
          if sqlca.sqlcode <> 0 then                                                                                             
             let lr_retorno.cont = 0
          end if                                                                                    
       
       end if   
                                                                   
       return lr_retorno.cont   ,
              lr_retorno.empcod
         
end function

#--------------------------------------------------- 
function ctc62m00_acessa_menu(lr_param)              
#--------------------------------------------------- 

define lr_param record              
   funmat      like isskfunc.funmat,
   empcod      like gabkemp.empcod   
end record 

define lr_retorno record
   cpodes      like datkdominio.cpodes,
   cont        integer 
end record

initialize lr_retorno.* to null

   if m_prep = false or                                
      m_prep = " " then       
      call ctc62m00_prepare() 
   end if     
   
   let a_aux_ctc62m00[1].cponom = "CTC62M00_MATRIC"   
                
   let lr_retorno.cpodes = lr_param.funmat using "&&&&&&" , "|", lr_param.empcod using "&&" 
                                                                                            
   whenever error stop                                                                      
   open cctc62m00006 using a_aux_ctc62m00[1].cponom  ,                                      
                           lr_retorno.cpodes                                                
   fetch cctc62m00006 into lr_retorno.cont                                                  
   whenever error continue                                                                  
                                                                                            
   if lr_retorno.cont > 0 then                                                                                                            
      return true                                                                         
   else
      return false
   end if                                                                                   

end function

#---------------------------------------------------
function ctc62m00_recupera_empresa(lr_param)             
#---------------------------------------------------

define lr_param record                
   funmat      like isskfunc.funmat,  
   empcod      like gabkemp.empcod    
end record                            

define lr_retorno record                                                                                    
   cpodes      like datkdominio.cpodes,                                                                     
   acesso      smallint               ,
   ciaempcod   like datkdominio.cpodes,
   query       char(50)                                                                                     
end record 

define lr_aux array[7] of record    
  ciaempcod      like datkdominio.cpodes
end record  

define arr_aux  smallint                                       
                                            
initialize lr_retorno.* to null             
                                            
for  arr_aux  =  1  to  7                                           
   initialize  lr_aux[arr_aux].* to  null                                                                                                    
end  for                                                                                                                                                
                                                                            
                                                                                                            
   if m_prep = false or                                                                                     
      m_prep = " " then                                                                                     
      call ctc62m00_prepare()                                                                               
   end if 
   
   let lr_retorno.acesso = false                                                                                                  
                                                                                                            
   let a_aux_ctc62m00[1].cponom = "CTC62M00_MATRIC"                                                         
                                                                                                            
   let lr_retorno.cpodes = lr_param.funmat using "&&&&&&" , "|", lr_param.empcod using "&&"                 
                                                                                                            
   whenever error stop                                     
   open cctc62m00009 using a_aux_ctc62m00[1].cponom  ,     
                           lr_retorno.cpodes               
   fetch cctc62m00009 into lr_retorno.ciaempcod               
   whenever error continue                                 

   if sqlca.sqlcode = 0 then 
      
      let lr_aux[1].ciaempcod = lr_retorno.ciaempcod[11,12]
      let lr_aux[2].ciaempcod = lr_retorno.ciaempcod[14,15]
      let lr_aux[3].ciaempcod = lr_retorno.ciaempcod[17,18]
      let lr_aux[4].ciaempcod = lr_retorno.ciaempcod[20,21]
      let lr_aux[5].ciaempcod = lr_retorno.ciaempcod[23,24]
      let lr_aux[6].ciaempcod = lr_retorno.ciaempcod[26,27]
      let lr_aux[7].ciaempcod = lr_retorno.ciaempcod[29,30]
      
      let lr_retorno.query = "(", lr_param.empcod using "&&"
       
      for arr_aux  =  1  to  7                        
                                                        
           if lr_aux[arr_aux].ciaempcod is not null and
              lr_aux[arr_aux].ciaempcod <> " "      then 
  
              if lr_aux[arr_aux].ciaempcod = lr_param.empcod then
                 continue for
              end if
              
              let lr_retorno.query = lr_retorno.query clipped, "," ,lr_aux[arr_aux].ciaempcod using "&&"   
                    
           end if
       
      end for
      
      let lr_retorno.query  = lr_retorno.query clipped
      let lr_retorno.acesso = true    
   end if                     
   
   let lr_retorno.query = lr_retorno.query clipped, ")"  
   
   return lr_retorno.acesso,
          lr_retorno.query    
   
end function