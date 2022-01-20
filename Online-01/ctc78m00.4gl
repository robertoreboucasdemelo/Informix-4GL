#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTC78M00                                                   #
# ANALISTA RESP..: CARLOS ALBERTO RODRIGUES                                   #
# PSI/OSF........: 198714 - CADASTRO DE CATEGORIAS TARIFARIAS POR GUINCHO     #
#                  MANUTENCAO DO CADASTRO DE CATEGORIAS TARIFARIAS            #
# ........................................................................... #
# DESENVOLVIMENTO: ALBERTO RODRIGUES / LUCAS SCHEID                           #
# LIBERACAO......:                                                            #
# ........................................................................... #
#.............................................................................# 
#                  * * *  ALTERACOES  * * *                                   # 
#                                                                             # 
# Data       Autor Fabrica PSI       Alteracao                                # 
# --------   ------------- --------  -----------------------------------------# 
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.               # 
#-----------------------------------------------------------------------------# 

globals '/homedsa/projetos/geral/globals/glct.4gl'

 define am_array     array[100] of record
        ctgtrfcod    like agekcateg.ctgtrfcod ,
        ctgtrfdes    like agekcateg.ctgtrfdes ,
        caddat       like datrctggch.caddat    ,
        cadmat       like datrctggch.cadmat    ,
        funnom_cad   char(20)
 end record

 define m_prep_sql      smallint
 define m_arr           smallint
 define m_cont          smallint
 define m_sql          char(500)
 define m_retorno   smallint

#=============================================================================
 function ctc78m00_prepare()
#=============================================================================

 define l_sql           char(500)

    let l_sql = " select ctgtrfdes "
           ,"   from agekcateg "
           ,"  where tabnum    = ( select max(tabnum) from agekcateg "
           ,"                      where  ramcod    = 531 "
           ,"                        and    ctgtrfcod = ? )"
           ,"  and   ramcod    = 531 "
           ,"  and   ctgtrfcod = ?  "
    prepare pctc78m00001 from l_sql
    declare cctc78m00001 cursor for pctc78m00001

    #let l_sql =  " select datrctggch.soceqpcod, "
    #           , " datkvcleqp.soceqpdes       , "
    #           , " datrctggch.caddat          , "
    #           , " datrctggch.cademp          , "
    #           , " datrctggch.usrtip          , "
    #           , " datrctggch.cadmat            "
    #           , "from   datrctggch ,  "
    #           , "       datkvcleqp    "
    #           , "where  datrctggch.ctgtrfcod = ? "
    #           , "and    datrctggch.soceqpcod = datkvcleqp.soceqpcod "
    #           , "and    datkvcleqp.soceqpstt = 'A' "
    
    let l_sql =  " select datrctggch.ctgtrfcod, ",
                        " datrctggch.caddat, ",
                        " datrctggch.cadmat, ",
                        " datrctggch.usrtip, ",
                        " datrctggch.cademp ",
                   " from datrctggch, ",
                        " datkvcleqp ",
                  " where datkvcleqp.soceqpcod = ? ",
                    " and datrctggch.soceqpcod = datkvcleqp.soceqpcod ",
                    " and datkvcleqp.soceqpstt = 'A' ",
                    " order by ctgtrfcod "

    prepare pctc78m00002 from l_sql
    declare cctc78m00002 cursor for pctc78m00002

    let l_sql =  "select datkvcleqp.soceqpdes  "
               , "from   datkvcleqp    "
               , "where  datkvcleqp.soceqpcod = ? "
               , "and    datkvcleqp.soceqpstt = 'A' "
    prepare pctc78m00003 from l_sql
    declare cctc78m00003 cursor for pctc78m00003

    let l_sql =  "select datrctggch.soceqpcod "
               , "from   datrctggch ,  "
               , "       datkvcleqp    "
               , "where  datrctggch.ctgtrfcod = ? "
               , "and    datrctggch.soceqpcod = ? "
               , "and    datrctggch.soceqpcod = datkvcleqp.soceqpcod "
            #   , "and    datkvcleqp.soceqpstt = 'A' "
    prepare pctc78m00004 from l_sql
    declare cctc78m00004 cursor for pctc78m00004

    let l_sql = " delete from datrctggch "
               , "where  datrctggch.ctgtrfcod = ? "
               , "and    datrctggch.soceqpcod = ? "
    prepare pctc78m00005 from l_sql

 let m_prep_sql = true

 end function

#=============================================================================
 function ctc78m00()
#=============================================================================

 define lr_ctc78m00 record
   soceqpcod like datkvcleqp.soceqpcod,
   soceqpdes like datkvcleqp.soceqpdes,
   eqpacndst like datkvcleqp.eqpacndst,
   eqpimsvlr like datkvcleqp.eqpimsvlr
 end record

 define l_chave     char(10)

 define ml_sql           char(500)

 initialize lr_ctc78m00.* to null

 let m_arr  = 1

 if m_prep_sql <> true or m_prep_sql is null then
    call ctc78m00_prepare()
 end if

 open window w_ctc78m00 at 7,2 with form "ctc78m00"
    attribute(prompt line last,border, form line 1)

 while true

  clear form
  
  let lr_ctc78m00.soceqpcod = null   
  let lr_ctc78m00.soceqpdes = null
  
  input by name lr_ctc78m00.soceqpcod,
                lr_ctc78m00.soceqpdes without defaults

     before field soceqpcod
       display by name lr_ctc78m00.soceqpcod attribute(reverse)

     after field soceqpcod
       display by name lr_ctc78m00.soceqpcod
       let int_flag = false

       #let ml_sql = " select ctgtrfcod ,ctgtrfdes "
       #            ," from   agekcateg "
       #            ," where  tabnum    = ( select max(tabnum) from agekcateg "
       #            ,"                      where  ramcod    = 531 )"
       #            ," and    ramcod    = 531 "

       let ml_sql = "select soceqpcod, ",      
                          " soceqpdes ",       
                     " from datkvcleqp ",      
                    " where soceqpstt = 'A' "      

       if lr_ctc78m00.soceqpcod is null then
          call ofgrc001_popup(3,
                              3,
                              "EQUIPAMENTOS ",
                              "CODIGO",
                              "DESCRICAO",
                              "N",
                              ml_sql,
                              "",
                              "X")
          returning m_retorno,
                    lr_ctc78m00.soceqpcod,
                    lr_ctc78m00.soceqpdes

          if lr_ctc78m00.soceqpdes is null or
             lr_ctc78m00.soceqpdes = " " then
             error "Informe o Codigo Tarifario "
             next field soceqpcod
          end if
       #else
       #    open cctc78m00001 using lr_ctc78m00.ctgtrfcod,
       #                            lr_ctc78m00.ctgtrfcod
       #    fetch cctc78m00001 into lr_ctc78m00.ctgtrfdes
       #    if sqlca.sqlcode = 100 then
       #       error 'Codigo da Categoria Tarifaria nao encontrado !'
       #       next field ctgtrfcod
       #    end if
       #    close cctc78m00001
       else
           open cctc78m00003 using lr_ctc78m00.soceqpcod
           fetch cctc78m00003 into lr_ctc78m00.soceqpdes
           
           if  sqlca.sqlcode <> 0 then
               error 'Equipamento nao cadastrado.'
               next field soceqpcod
           end if
       end if

       display by name lr_ctc78m00.soceqpcod
       display by name lr_ctc78m00.soceqpdes

   on key(F17,control-c,interrupt)
      let int_flag = true
      exit input
   end input

   if int_flag = false then
      
      whenever error continue
      select eqpacndst,
             eqpimsvlr
        into lr_ctc78m00.eqpacndst,
             lr_ctc78m00.eqpimsvlr 
        from datkvcleqp
       where soceqpcod = lr_ctc78m00.soceqpcod
      whenever error stop
      
      input by name lr_ctc78m00.eqpimsvlr,
                    lr_ctc78m00.eqpacndst without defaults
      
      if int_flag = false then
      
         whenever error continue
         update datkvcleqp
            set eqpacndst = lr_ctc78m00.eqpacndst,
                eqpimsvlr = lr_ctc78m00.eqpimsvlr
          where soceqpcod = lr_ctc78m00.soceqpcod 
         whenever error stop
         
         call ctc78m00_input_array(lr_ctc78m00.soceqpcod)
      end if
   else
      exit while
   end if

  options
    delete key F2

 end while

 close window w_ctc78m00

 let int_flag = false

 end function

#=============================================================================
 function ctc78m00_input_array(l_par_soceqpcod)
#=============================================================================

 define l_par_soceqpcod like datrctggch.soceqpcod

 define l_cont    smallint
 define l_arr     smallint
 define l_scr     smallint
 define l_aux     like agekcateg.ctgtrfcod

 define ws record
        mensagem  char(100),
        erro      smallint ,
        funnom    char(100)
 end record
 
 define ctc78m00 record 
                     ctgtrfcod    like agekcateg.ctgtrfcod ,
                     ctgtrfdes    like agekcateg.ctgtrfdes ,
                     caddat       like datrctggch.caddat   ,
                     cadmat       like datrctggch.cadmat   ,
                     funnom_cad   char(20)
                 end record

 define l_resp char(01)

 define l_data    date,
 l_cod smallint
 
 define ml_sql           char(500) 

 define l_alt_soceqpcod like datrctggch.soceqpcod

 define l_inserir smallint

 let l_cont      = 1
 let l_data      = today
 let l_alt_soceqpcod = null

 let l_inserir = false

  options
    delete key control-p,
    prompt line last,
    insert key f1

  initialize ctc78m00.* to null
  
  while true

   call ctc78m00_carga_array( l_par_soceqpcod )
   call set_count(m_cont)

   input array am_array without defaults from s_ctc78m00.*

     before row
       let l_arr  = arr_curr()
       let l_scr  = scr_line()
       let l_inserir = false
       let ctc78m00.* = am_array[l_arr].*

     before field ctgtrfcod
        display am_array[l_arr].ctgtrfcod to s_ctc78m00[l_scr].ctgtrfcod attribute(reverse)
        display am_array[l_arr].caddat    to s_ctc78m00[l_scr].caddat
     
     after field ctgtrfcod
     
       display am_array[l_arr].ctgtrfcod to s_ctc78m00[l_scr].ctgtrfcod
       #if fgl_lastkey() = 2014 then              
       #   let am_array[l_arr].ctgtrfcod = null   
       #   let l_inserir = true                   
       #end if                                    
       #                                          
       #if fgl_lastkey() = 2005 or    ## f3       
       #   fgl_lastkey() = 2006 then  ## f4       
       #   continue input                         
       #end if                                           

       let ml_sql = " select ctgtrfcod ,ctgtrfdes "
                   ," from   agekcateg "
                   ," where  tabnum    = ( select max(tabnum) from agekcateg "
                   ,"                      where  ramcod    = 531 )"
                   ," and    ramcod    = 531 "

       if am_array[l_arr].ctgtrfcod is null then
          call ofgrc001_popup(3,
                              3,
                              "CATEGORIA TARIFARIA ",
                              "CODIGO",
                              "DESCRICAO",
                              "N",
                              ml_sql,
                              "",
                              "X")
          returning m_retorno,
                    am_array[l_arr].ctgtrfcod,
                    am_array[l_arr].ctgtrfdes

          if am_array[l_arr].ctgtrfdes is null or
             am_array[l_arr].ctgtrfdes = " " then
             error "Informe o Codigo Tarifario "
             next field ctgtrfcod
          end if
       else
           open cctc78m00001 using am_array[l_arr].ctgtrfcod,
                                   am_array[l_arr].ctgtrfcod
           fetch cctc78m00001 into am_array[l_arr].ctgtrfdes
           if sqlca.sqlcode = 100 then
              error 'Codigo da Categoria Tarifaria nao encontrado !'
              next field ctgtrfcod
           end if
           close cctc78m00001
           display am_array[l_arr].ctgtrfdes  to s_ctc78m00[l_scr].ctgtrfdes
       end if  
       
       #if l_inserir = true then                                            
       #   if ctc78m00_f1( am_array[l_arr].ctgtrfcod, l_par_soceqpcod )then 
       #      let l_inserir = false                                         
       #      continue input                                                
       #   end if                                                           
       #end if                                                              
       
       display 'ANTES DA VALIDACAO: '
       
       display 'ctc78m00.ctgtrfcod = ', ctc78m00.ctgtrfcod
       let l_aux    = am_array[l_arr].ctgtrfcod
       
       display 'am_array[l_arr].ctgtrfcod = ', l_aux
       
       if  ctc78m00.ctgtrfcod is null or ctc78m00.ctgtrfcod = " " and
           am_array[l_arr].ctgtrfcod is not null and am_array[l_arr].ctgtrfcod <> " " then
           
           display 'ENTROU NA VALIDACAO 2'
           
           if ctc78m00_verifica(am_array[l_arr].ctgtrfcod, l_par_soceqpcod ) then                                                                                                                                                                  
              begin work                                                                      
              let am_array[l_arr].caddat = today
              
              let l_cod =  ctc78m00_gravar( am_array[l_arr].ctgtrfcod  ,                                
                                            l_par_soceqpcod            ,                                
                                            am_array[l_arr].caddat     ,                                
                                            g_issk.empcod              ,                                
                                            g_issk.usrtip              ,                                
                                            g_issk.funmat)                                                        
                 
                 
              if l_cod = 1 then   
                 commit work 
                 display am_array[l_arr].caddat  to s_ctc78m00[l_scr].caddat                                                                
              else                                                                            
                 if  l_cod = 2 then
                     error 'Codigo já cadastrado.'
                     let am_array[l_arr].ctgtrfcod = null
                     let am_array[l_arr].ctgtrfdes = null
                     next field ctgtrfcod
                     rollback work
                 else
                    error 'Erro INSERT datrctggch ',sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 2    
                    rollback work                                                                
                    next field ctgtrfcod                                                         
                 end if
              end if  
              
              display 'SQLCA>SQLCODE = ', sqlca.sqlcode
                                                                                      
           else
               error 'Codigo já cadastrado.'
               let am_array[l_arr].ctgtrfcod = null        
               let am_array[l_arr].ctgtrfdes = null 
               display am_array[l_arr].ctgtrfcod  to s_ctc78m00[l_scr].ctgtrfcod
               display am_array[l_arr].ctgtrfdes  to s_ctc78m00[l_scr].ctgtrfdes
               next field ctgtrfcod
           end if
        end if                                                                            

       if am_array[l_arr].funnom_cad is null then                              
          call cty08g00_nome_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)
          ## call cty08g00_nome_func (1, 3627, "F")                            
          returning ws.erro, ws.mensagem, ws.funnom                            
          let am_array[l_arr].funnom_cad = ws.funnom                           
          let am_array[l_arr].cadmat     = g_issk.funmat                       
          display am_array[l_arr].funnom_cad to s_ctc78m00[l_scr].funnom_cad   
          display am_array[l_arr].cadmat     to s_ctc78m00[l_scr].cadmat       
       end if                                                                  

     on key(F2)                                                                            
                                                                                           
      let l_resp = "N"                                                                     
                                                                                           
      if am_array[l_arr].ctgtrfcod is not null then                                        
         prompt "Confirma remocao da linha ? (S/N) " for l_resp                            
         if upshift(l_resp) = 'S' then                                                     
            whenever error continue                                                        
            execute pctc78m00005  using am_array[l_arr].ctgtrfcod                                    
                                       ,l_par_soceqpcod                          
            whenever error stop                                                            
            if sqlca.sqlcode <> 0 then                                                     
               error 'Erro DELETE datrctggch ',sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 2 
               error 'ctc78m00_array()/',l_par_soceqpcod sleep 2                 
               exit input                                                                  
            end if                                                                         
            call ctc78m00_dellinha(l_arr, l_scr)                                           
            exit input                                                                     
         end if                                                                            
      end if                                                                               
                                                               
      display am_array[l_arr].ctgtrfcod  to s_ctc78m00[l_scr].ctgtrfcod 
      display am_array[l_arr].ctgtrfdes  to s_ctc78m00[l_scr].ctgtrfdes 
      display am_array[l_arr].caddat     to s_ctc78m00[l_scr].caddat    
      display am_array[l_arr].cadmat     to s_ctc78m00[l_scr].cadmat    
      display am_array[l_arr].funnom_cad to s_ctc78m00[l_scr].funnom_cad

         on key(F17,control-c,interrupt)
            let int_flag = true
            exit input
   end input

   if int_flag = true then
      exit while
   end if

  end while

  end function

#==============================================================================
 function ctc78m00_dellinha(l_arr, l_scr)
#==============================================================================

 define l_arr        smallint
 define l_scr        smallint
 define l_cont       smallint

   for l_cont = l_arr to 99
      if am_array[l_arr].ctgtrfcod is not null then
         let am_array[l_cont].* = am_array[l_cont + 1].*
      else
         initialize am_array[l_cont].* to null
      end if
   end for

   for l_cont = l_scr to 3
       display am_array[l_arr].ctgtrfcod  to s_ctc78m00[l_scr].ctgtrfcod 
       display am_array[l_arr].ctgtrfdes  to s_ctc78m00[l_scr].ctgtrfdes 
       display am_array[l_arr].caddat     to s_ctc78m00[l_scr].caddat    
       display am_array[l_arr].cadmat     to s_ctc78m00[l_scr].cadmat    
       display am_array[l_arr].funnom_cad to s_ctc78m00[l_scr].funnom_cad
       let l_arr = l_arr + 1
   end for

   let l_arr = l_arr - 1

 end function ## ctc78m00_dellinha

#=============================================================================
 function ctc78m00_carga_array(l_soceqpcod)
#=============================================================================

 define l_soceqpcod like datrctggch.soceqpcod

 define l_cademp    like datrctggch.cademp
 define l_usrtip    like datrctggch.usrtip

 define l_erro     smallint
 define l_mensagem char(50)

 initialize am_array to null

 let l_erro     = null
 let l_mensagem = null

 let m_cont      = 1

 open cctc78m00002 using l_soceqpcod

 foreach cctc78m00002 into am_array[m_cont].ctgtrfcod                                                           
                          ,am_array[m_cont].caddat                                                            
                          ,am_array[m_cont].cadmat                                                            
                          ,l_usrtip                                              
                          ,l_cademp                                              
                                               
     call cty08g00_nome_func (l_cademp, am_array[m_cont].cadmat,l_usrtip )

     returning l_erro, l_mensagem, am_array[m_cont].funnom_cad
     
     open cctc78m00001 using am_array[m_cont].ctgtrfcod,           
                             am_array[m_cont].ctgtrfcod            
     fetch cctc78m00001 into am_array[m_cont].ctgtrfdes            
     #if sqlca.sqlcode = 100 then                              
     #   error 'Codigo da Categoria Tarifaria nao encontrado !'
     #   next field ctgtrfcod                                  
     #end if                                                   

     let m_cont = m_cont + 1

     if m_cont > 100 then
        error 'Limite de Array excedido !!' sleep 2
        exit foreach
     end if

 end foreach

 let m_cont = m_cont -1

end function ## ctc78m00_carga_array

#=============================================================================
 function ctc78m00_gravar(lr_param)
#=============================================================================

 define lr_param record
        ctgtrfcod    like datrctggch.ctgtrfcod ,
        soceqpcod    like datrctggch.soceqpcod ,
        caddat       like datrctggch.caddat    ,
        cademp       like datrctggch.cademp    ,
        usrtip       like datrctggch.usrtip    ,
        cadmat       like datrctggch.cadmat
 end record

 display 'ctgtrfcod = ', lr_param.ctgtrfcod
 display 'soceqpcod = ', lr_param.soceqpcod
 display 'cademp    = ', lr_param.cademp   
 display 'usrtip    = ', lr_param.usrtip   
 display 'cadmat    = ', lr_param.cadmat   

 whenever error continue
 insert into datrctggch ( ctgtrfcod            ,
                          soceqpcod            ,
                          caddat               ,
                          cademp               ,
                          usrtip               ,
                          cadmat
                        )
                 values ( lr_param.ctgtrfcod   ,
                          lr_param.soceqpcod   ,
                          lr_param.caddat      ,
                          lr_param.cademp      ,
                          lr_param.usrtip      ,
                          lr_param.cadmat
                        )
                        
 display 'sqlca.sqlcode = ', sqlca.sqlcode
 
 
 if sqlca.sqlcode = 0 then
    return 1
 else
    if  sqlca.sqlcode = -268 then
        return 2
    else
        return 0 
    end if
 end if

 end function ##  ctc78m00_gravar

#=============================================================================
 function ctc78m00_verifica(lr_param)
#=============================================================================

  define lr_param record
         ctgtrfcod    like datrctggch.ctgtrfcod,
         soceqpcod    like datrctggch.soceqpcod
  end record

  define l_ctgtrfcod  like datrctggch.ctgtrfcod

  let l_ctgtrfcod = null

  ## Verificar se guincho já esta cadastrado

  open cctc78m00004 using lr_param.ctgtrfcod,
                          lr_param.soceqpcod

  fetch cctc78m00004 into l_ctgtrfcod

  display 'SQLCA.sqlcode = ', sqlca.sqlcode
  
  if  sqlca.sqlcode = 100 then
      return 1
  else    
      return 0
  end if
  
  #if l_ctgtrfcod is not null then
  #   return 1
  #end if
  close cctc78m00004

  

 end function ## ctc78m00_verifica

#=============================================================================
 function ctc78m00_f1(lr_param)
#=============================================================================

  define lr_param record
         ctgtrfcod    like datrctggch.ctgtrfcod,
         soceqpcod    like datrctggch.soceqpcod
  end record

  define l_ctgtrfcod  like datrctggch.ctgtrfcod

  let l_ctgtrfcod = null

  ## Verificar se guincho já esta cadastrado
  open cctc78m00004 using lr_param.ctgtrfcod,
                          lr_param.soceqpcod

  fetch cctc78m00004 into l_ctgtrfcod

  if l_ctgtrfcod is not null then
     return 1
  end if
  close cctc78m00004

  return 0

 end function ## ctc78m00_f1
 