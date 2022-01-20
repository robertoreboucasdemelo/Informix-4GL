###########################################################################
# Nome do Modulo: ctc63m02                               Helder Oliveira  #
#                                                        Humberto Santos  #
# Pesquisa de matricula                                          Jul/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


  define m_cod_menu        smallint
  define m_prep_ctc63m02   smallint
  define m_operacao        char(1)
  define m_errflg          char(1)
  define m_confirma        char(1)
  define m_data            date
  define m_aux_codigo      char(4)

  define a_ctc63m02 array[3000] of record
          marca            char(1)
         ,s_matricula      like isskfunc.funmat
         ,s_nome           like isskfunc.funnom
         ,s_depart         like isskfunc.dptsgl
         ,s_stt            like isskfunc.rhmfunsitcod
         ,s_emp            like isskfunc.empcod
  end record

  define r_ctc63m02 record
          matricula        like isskfunc.funmat
         ,nome             like isskfunc.funnom
         ,departamento     like isskfunc.dptsgl
         ,empresa          like isskfunc.empcod
  end record

#==============================================================================
function ctc63m02_prepare()
#==============================================================================
 define l_sql char(5000)

 let l_sql =  '  select mnucod     '
             ,'       , sisdes     '
             ,'       , prgnom     '
             ,'    from datkc24mnuacs    '
             ,'  order by mnucod   '

 prepare pctc63m02001 from l_sql
 declare cctc63m02001 cursor for pctc63m02001

 let l_sql = " SELECT  1           "
            ,"   FROM datrc24mnufun "
            ,"  WHERE funmat   = ? "
            ,"    AND empcod   = ?  "
            ,"    AND mnucod = ? "
            
 prepare pctc63m02002 from l_sql
 declare cctc63m02002 cursor for pctc63m02002

 let l_sql = " INSERT INTO datrc24mnufun (funmat,empcod,usrtip,mnucod,atlusrtip,atlemp,atlmat,atldat ) "
           , " VALUES (?,?,?,?,?,?,?,?) "
 prepare pctc63m02003 from l_sql

 let l_sql = " SELECT usrtip     "
           , "   FROM isskfunc   "
           , "  WHERE funmat = ? "
           , "    AND empcod = ? "
 prepare pctc63m02004 from l_sql
 declare cctc63m02004 cursor for pctc63m02004
 
 let l_sql = "delete from datrc24mnufun "
            ,"where funmat = ? "
              ,"and empcod = ? "
              ,"and mnucod = ? "
 prepare pctc63m02005 from l_sql
 

 let m_prep_ctc63m02 = 1

end function

#==============================================================================
function ctc63m02_prepare_pesquisa()
#==============================================================================
  define l_sql  char(32000) 
  define l_flag smallint
 
#----------Humberto---------------------
  define l_prifoncod   like isskfunc.prifoncod
  define l_segfoncod   like isskfunc.segfoncod
  define l_terfoncod   like isskfunc.terfoncod
#---------------------------------------------
#---------Humberto----------
initialize
      l_prifoncod
     ,l_segfoncod
     ,l_terfoncod
 to null
#---------------------------------
 let l_flag = 0
 
 let l_sql = " SELECT funmat "
                   ,",funnom "
                   ,",dptsgl "
                   ,",rhmfunsitcod"
                   ,",empcod"
            ,"   FROM isskfunc "

#-----------------Humberto---------------------------
 if r_ctc63m02.nome is not null then
      call ctc63m02_pesquisa_nome(r_ctc63m02.nome)
          returning l_prifoncod
                   ,l_segfoncod
                   ,l_terfoncod
          let l_sql = l_sql clipped , " WHERE ( prifoncod = '",l_prifoncod clipped,"'"
                                          ," OR segfoncod = '",l_segfoncod clipped,"'"
                                          ," OR terfoncod = '",l_terfoncod,"')"
          let l_flag = 1
 end if
#----------------------------------------------------
 if r_ctc63m02.matricula is not null then
     if l_flag = 0 then
         let l_sql = l_sql clipped,"  WHERE funmat = ",r_ctc63m02.matricula
         let l_flag = 1
     else
         let l_sql = l_sql clipped , "  AND funmat = ",r_ctc63m02.matricula
     end if
 end if
 
 if r_ctc63m02.departamento is not null then
    if l_flag = 0 then
       let l_sql = l_sql clipped , "  WHERE dptsgl = '",r_ctc63m02.departamento,"'"
       let l_flag = 1
    else
       let l_sql = l_sql clipped , "  AND dptsgl = '",r_ctc63m02.departamento,"'"
    end if
 end if
 
 if r_ctc63m02.empresa  is not null then
    if l_flag = 0 then
       let l_sql = l_sql clipped , "  WHERE empcod = ",r_ctc63m02.empresa
       let l_flag = 1
    else
       let l_sql = l_sql clipped , "  AND empcod = ",r_ctc63m02.empresa
    end if
 end if
 		 let l_sql = l_sql clipped ," AND rhmfunsitcod <> 'I' "
     let l_sql = l_sql clipped , " ORDER BY dptsgl"
 prepare pctc63m02_pesq from l_sql
 declare cctc63m02_pesq cursor for pctc63m02_pesq
  
 
end function

#==============================================================================
function ctc63m02(l_cod_menu)
#==============================================================================
  define l_cod_menu    smallint
  define l_index       smallint
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint
  define l_tamanho     smallint
  define i             smallint
  define l_flag        smallint   #verifica se existe letras no campo codigo
  define l_flg         smallint   #verifica se foi up down
  define l_descricao   char(50)
  define l_prox_arr    smallint
  define l_err         smallint
  define l_nome        char(100)
  
  initialize a_ctc63m02 to null
  initialize r_ctc63m02.* to null
  let l_err = 0
  let int_flag = false
  let l_flg = 0
  let m_data = today
  let m_cod_menu = l_cod_menu

  if m_prep_ctc63m02 <> 1 then
    call ctc63m02_prepare()
  end if

  open window w_ctc63m02 at 6,2 with form 'ctc63m02'
             attribute(form line first, message line last,comment line last - 1, border)
  
  display 'PESQUISA MATRICULA' at 1,28
  message '(F5) - Marcar Todos   (F6) - Desmarcar Todos   (F8) - Gravar   (F17)-Abandona'
  while true
  
  input by name r_ctc63m02.* without defaults
     
      #--------------------------------      
        before field matricula
      #--------------------------------      
          display r_ctc63m02.matricula to matricula attribute(reverse)
          
      #--------------------------------      
        after field matricula
      #-------------------------------- 
          display r_ctc63m02.matricula to matricula 
          
      #--------------------------------      
        before field nome        
      #--------------------------------      
          display r_ctc63m02.nome to nome attribute(reverse)
          
      #--------------------------------      
        after field nome        
      #--------------------------------     
          #-------------------------Humberto--------------------------------
          display r_ctc63m02.nome to nome 
           if r_ctc63m02.nome is not null then
               let l_nome = (length (r_ctc63m02.nome))
               if l_nome  < 11 then
                  error 'Complemente o nome do Funcionario (minimo 11 caracteres)!'
                  next field nome
               end if
           end if
      #--------------------------------
        before field departamento
      #--------------------------------
          display r_ctc63m02.departamento to departamento attribute(reverse)
          
      #--------------------------------
        after field departamento
      #--------------------------------
          display r_ctc63m02.departamento to departamento 
          
      #--------------------------------
        before field empresa
      #--------------------------------      
          display r_ctc63m02.empresa to empresa attribute(reverse)
          
       #--------------------------------
        after field empresa
      #--------------------------------   
          display r_ctc63m02.empresa to empresa 
          
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field departamento
          end if
          if r_ctc63m02.empresa   is null  and
             r_ctc63m02.matricula is null  and
             r_ctc63m02.departamento is null and
             r_ctc63m02.nome is null then
             error "Informe um campo para pesquisa!"
             next field matricula             
          else
            error 'Por favor Aguarde ...'
            call ctc63m02_reliza_pesquisa()          
            next field matricula
          end if
          
      #-------------------------------- 
        on key (interrupt, control-c)
      #--------------------------------
          let int_flag = true
          exit input

  end input

  if int_flag  then
     let int_flag = false
     exit while
  end if

  end while

  let int_flag = false

 close window w_ctc63m02
  
end function

#==============================================================================
function ctc63m02_reliza_pesquisa()
#==============================================================================
define l_index     smallint
define arr_aux     smallint
define scr_aux     smallint
define l_count_aux smallint
define i           smallint
define l_flag      smallint
define l_return    smallint

 if m_prep_ctc63m02 <> 1 then
   call ctc63m02_prepare()
 end if

  call ctc63m02_prepare_pesquisa()
 
  call ctc63m02_pega_dados()
     returning l_index

  let arr_aux = l_index

 error ' '

 while true

  call set_count(l_index - 1)
  input array a_ctc63m02 without defaults from sctc63m02.*
      #--------------------------------  
         before row
      #--------------------------------  
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         let l_count_aux = arr_count()
         
      #-------------------------------- 
        after row
      #-------------------------------- 
         if (fgl_lastkey() = fgl_keyval("down")    or
             fgl_lastkey() = fgl_keyval("right")   or
             fgl_lastkey() = fgl_keyval("tab")     or
             fgl_lastkey() = fgl_keyval("return")) and
             arr_aux = arr_count()                 then 
             next field marca
         end if
         
      #--------------------------------  
        before field marca
      #-------------------------------- 
        display a_ctc63m02[arr_aux].* to sctc63m02[scr_aux].* attribute(reverse)
      
      #-------------------------------- 
        after field marca  
      #-------------------------------- 
        display a_ctc63m02[arr_aux].* to sctc63m02[scr_aux].*
        
        if a_ctc63m02[arr_aux].marca <> 'X' and
           a_ctc63m02[arr_aux].marca <> ' ' then
           error 'Digite " " ou "X" para marcar este campo'
           let a_ctc63m02[arr_aux].marca = ' '
           next field marca     
        else
           open cctc63m02002 using a_ctc63m02[arr_aux].s_matricula
                                 , a_ctc63m02[arr_aux].s_emp
                                      , m_cod_menu
           fetch cctc63m02002
           
           if sqlca.sqlcode = 0 then
              let a_ctc63m02[arr_aux].marca = 'X'
              display a_ctc63m02[arr_aux].marca to sctc63m02[scr_aux].marca
           end if
        end if

      #--------------------------------
        on key (F5)
      #--------------------------------
        display a_ctc63m02[arr_aux].* to sctc63m02[scr_aux].* 
        let i = 1 
        let l_flag = 0
        error 'Por Favor Aguarde'
        for i = 1 to l_count_aux
            let a_ctc63m02[i].marca = 'X'
        end for
        call ctc63m02_grava(l_count_aux, arr_aux, scr_aux)  
          returning l_return
          
        if l_return = 1 then
          let l_flag = 1
        end if
      
        error ' '
        exit input
               
      #--------------------------------
        on key (F6)
      #--------------------------------
        display a_ctc63m02[arr_aux].* to sctc63m02[scr_aux].*
        call ctc63m02_exclui(l_count_aux, arr_aux, scr_aux)
          returning l_return
          
        if l_return = 1 then
          let l_flag = 1
       end if
          
        let i = 1 
        let l_flag = 0
#        error 'Por Favor Aguarde'
        for i = 1 to l_count_aux
            open cctc63m02002 using a_ctc63m02[i].s_matricula
                                  , a_ctc63m02[i].s_emp
                                    , m_cod_menu
            fetch cctc63m02002
        
            if sqlca.sqlcode = 0 then
               let a_ctc63m02[i].marca = 'X'
            else
               let a_ctc63m02[i].marca = ' '               
            end if
            
        end for
        error ' '
        exit input
      
      #--------------------------------
        on key (F8)
      #--------------------------------
       let a_ctc63m02[arr_aux].marca = get_fldbuf(marca)
       display a_ctc63m02[arr_aux].* to sctc63m02[scr_aux].*        
       call ctc63m02_grava(l_count_aux, arr_aux, scr_aux)  
          returning l_return
       
       if l_return = 1 then
          let l_flag = 1
       end if
       exit input       
      
      #-------------------------------- 
        on key (interrupt, control-c)
      #--------------------------------
        initialize a_ctc63m02 to null
        clear form
        let l_flag = 1
        exit input
       
    end input
 
  if l_flag then
     exit while
  end if 
 
 end while
 
end function

#==============================================================================
function ctc63m02_pega_dados()
#==============================================================================
define l_index smallint

 initialize a_ctc63m02 to null

 let l_index = 1
open cctc63m02_pesq
  foreach cctc63m02_pesq into a_ctc63m02[l_index].s_matricula
                               ,a_ctc63m02[l_index].s_nome    
                               ,a_ctc63m02[l_index].s_depart  
                               ,a_ctc63m02[l_index].s_stt     
                               ,a_ctc63m02[l_index].s_emp     
      
        open cctc63m02002 using a_ctc63m02[l_index].s_matricula
                              , a_ctc63m02[l_index].s_emp
                                , m_cod_menu
        fetch cctc63m02002
        
        if sqlca.sqlcode = 0 then
           let a_ctc63m02[l_index].marca = 'X'
        end if
      
      let a_ctc63m02[l_index].s_nome = upshift(a_ctc63m02[l_index].s_nome)    
      let l_index = l_index + 1                 

     if l_index > 3000 then
        error '  Pesquisa limitada a 3000 registros!  ' sleep 2
        exit foreach
     end if
                                    
  end foreach

return l_index

end function


#==============================================================================
function ctc63m02_grava(l_count_aux, arr_aux, scr_aux) 
#==============================================================================
define i           smallint
define l_count_aux smallint
define l_return    smallint
define arr_aux     smallint
define scr_aux     smallint
define l_usrtip    like isskfunc.usrtip
define l_error     smallint


 let m_data = today
 let l_error = 0
 let m_confirma = null
               
 call cts08g01("A"
              ,"S"
              ,"CONFIRMA A GRAVACAO"
              ,"DAS MATRICULAS ?"
              ," "
              ," " )
     returning m_confirma
 
 if m_confirma = "S"  then
     
     for i = 1 to l_count_aux 
       if a_ctc63m02[i].marca = 'X' then
       --> Verifica se existe  
          open cctc63m02002 using a_ctc63m02[i].s_matricula
                                , a_ctc63m02[i].s_emp
                                  , m_cod_menu
          fetch cctc63m02002
           
          if sqlca.sqlcode = 100 then
             --> Se nao existir insere os dados
             
             #pega usrtip
             whenever error continue
               open cctc63m02004 using a_ctc63m02[i].s_matricula
                                       , a_ctc63m02[i].s_emp
               fetch cctc63m02004 into l_usrtip
             whenever error stop
             if sqlca.sqlcode <> 0 and 
                sqlca.sqlcode <> 100 then
                error "Nao foi possivel recuperar usrtip em ctc63m02"
             else        
                begin work
                whenever error stop
                   execute pctc63m02003 using a_ctc63m02[i].s_matricula
                                              , a_ctc63m02[i].s_emp
                                              , l_usrtip
                                              , m_cod_menu
                                              , g_issk.usrtip
                                              , g_issk.empcod
                                              , g_issk.funmat
                                              , m_data
                whenever error continue
             
                if sqlca.sqlcode <> 0 then
                   error "Erro (",sqlca.sqlcode,") na insercao de dados da datrc24mnufun. Avise a Inf."
                   rollback work
                   let l_error = 1
                   exit for
                else
                   error "Efetuando gravacao. Por favor Aguarde... "
                   commit work
                   let l_error = 0
                end if
             end if 
          end if
       end if      
    end for
    if l_error <> 1 then
       error "Dados Gravados com Sucesso!"
    end if
    
    let l_return = 0
 else
    initialize a_ctc63m02 to null
    clear form 
    error "Gravacao cancelada!" 
    let l_return = 1
 end if

 return l_return

end function


#==============================================================================
function ctc63m02_pesquisa_nome(l_funnom)
#==============================================================================
 define l_funnom      like isskfunc.funnom
       ,l_entrada     char(51)
       ,l_saida       char(100)
       ,l_prifoncod   like isskfunc.prifoncod
       ,l_segfoncod   like isskfunc.segfoncod
       ,l_terfoncod   like isskfunc.terfoncod
 initialize
      l_entrada
     ,l_saida
     ,l_prifoncod
     ,l_segfoncod
     ,l_terfoncod
 to null
    let l_entrada = "1", l_funnom
    call fonetica2(l_entrada)
         returning l_saida
   if l_saida[1,3] = "100" then
      error   "Problema no servidor de fonetica, avisar o help desk"
      let l_saida = "################################################"
      let l_prifoncod = null
      let l_segfoncod = null
      let l_terfoncod = null
      return l_prifoncod
            ,l_segfoncod
            ,l_terfoncod
   end if
   let l_prifoncod = l_saida[01,15]
   let l_segfoncod = l_saida[17,31]
   if l_segfoncod is null or l_segfoncod = " " then
      let l_segfoncod = l_prifoncod
   end if
   let l_terfoncod = l_saida[33,47]
   if l_terfoncod is null or l_terfoncod = " " then
      let l_terfoncod = l_prifoncod
   end if
 return l_prifoncod
       ,l_segfoncod
       ,l_terfoncod
end function

#==============================================================================
function ctc63m02_exclui(l_count_aux, arr_aux, scr_aux) 
#==============================================================================
define i           smallint
define l_count_aux smallint
define l_return    smallint
define arr_aux     smallint
define scr_aux     smallint
define l_usrtip    like isskfunc.usrtip
define l_error     smallint


 let m_data = today
 let l_error = 0
 let m_confirma = null
               
 call cts08g01("A"
              ,"S"
              ,"CONFIRMA A EXCLUSÃO"
              ,"DAS MATRICULAS ?"
              ," "
              ," " )
     returning m_confirma
 
 if m_confirma = "S"  then
     
     for i = 1 to l_count_aux 
       if a_ctc63m02[i].marca = 'X' then
       --> Verifica se existe  
          open cctc63m02002 using a_ctc63m02[i].s_matricula
                                , a_ctc63m02[i].s_emp
                                  , m_cod_menu
          fetch cctc63m02002
                     
                begin work
                whenever error stop
                   execute pctc63m02005 using a_ctc63m02[i].s_matricula
                                              , a_ctc63m02[i].s_emp                                              
                                              , m_cod_menu
                                              
                whenever error continue
             
                if sqlca.sqlcode <> 0 then
                   error "Erro (",sqlca.sqlcode,") na exclusao de dados da datrc24mnufun. Avise a Inf."
                   rollback work
                   let l_error = 1
                   exit for
                else
                   error "Efetuando exclusao. Por favor Aguarde... "
                   commit work
                   let l_error = 0
                end if
             end if                
    end for
    if l_error <> 1 then
       error "Dados Excluidos com Sucesso!"
    end if
    
    let l_return = 0
 else
    initialize a_ctc63m02 to null
    clear form 
    error "Exclusão cancelada!" 
    let l_return = 1
 end if

 return l_return

end function
