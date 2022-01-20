#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctc98m00                                                    #
# Analista Resp.: Beatriz Araujo                                              #
# PSI...........: PSI-2012-00287/EV                                           #
# Objetivo......: Tela de cadastro do de/para de origens                      #
#.............................................................................#
# Desenvolvimento: Beatriz Araujo                                             #
# Liberacao......: 16/01/2012                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_ctc98m00_prep smallint
 define m_min_socntzcod like dpakpecrefvlr.socntzcod

#-------------------------#
function ctc98m00_prepare()
#-------------------------#

  define l_sql char(500)
  
  let l_sql = "select socntzdes ",      
              "  from datksocntz",      
              " where socntzcod = ?",
              "   and socntzstt = 'A'"     
  prepare pctc98m00001 from l_sql             
  declare cctc98m00001 cursor for pctc98m00001
  
  
   let l_sql = "select socntzcod  , ",
               "       empcod     , ",
               "       mobrefvlr  , ",   
               "       pecmaxvlr  , ",
               "       cadsttcod  , ",
               "       caddat     , ",   
               "       cadusrtip  , ",  
               "       cademp     , ",
               "       cadmat     , ",
               "       atldat     , ",
               "       atlusrtip  , ",
               "       atlemp     , ",
               "       atlmat       ",
               "  from dpakpecrefvlr",            
               " where socntzcod = ?",
               "   and empcod = ?"           
   prepare pctc98m00003 from l_sql              
   declare cctc98m00003 cursor for pctc98m00003 
   
   let l_sql = "select socntzcod ",            
               "  from dpakpecrefvlr",            
               " where socntzcod = ?",
               "   and empcod = ?"
   prepare pctc98m00004 from l_sql              
   declare cctc98m00004 cursor for pctc98m00004
   
   
   let l_sql = "select  empsgl ",            
               "  from gabkemp ",            
               " where empcod = ? "             
   prepare pctc98m00005 from l_sql              
   declare cctc98m00005 cursor for pctc98m00005
   
  let m_ctc98m00_prep = true

end function

#------------------------------------------------------------
 function ctc98m00()
#------------------------------------------------------------

 define d_ctc98m00 record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod, 
    caddat         like dpakpecrefvlr.caddat   , 
    atldat         like dpakpecrefvlr.atldat   , 
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record       
                                     
 
 initialize d_ctc98m00.*  to null
 display "g_issk.prgsgl: ",g_issk.prgsgl
  if not get_niv_mod(g_issk.prgsgl, "ctc96m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 else
    select min(socntzcod) into m_min_socntzcod  from dpakpecrefvlr
 end if
 
 
 open window ctc98m00 at 04,02 with form "ctc98m00"
 
 # display by name d_ctc98m00.*
  
 menu "Cadastro"
 
  before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo" , "Anterior", "Historico"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                     "Inclui" ,"Modifica" ,"Historico"
     end if
     
     show option "Encerra"

 
 command key ("S") "Seleciona"
                   "Seleciona Natureza X Empresa"
                   call ctc98m00_seleciona(d_ctc98m00.socntzcod,d_ctc98m00.empcod)  returning d_ctc98m00.*
                   if d_ctc98m00.socntzcod  is not null  then
                      message ""
                      next option "Proximo"
                   else
                      error " Nenhuma natureza selecionada!"
                      message ""
                      next option "Seleciona"
                   end if
                   
 command key ("P") "Proximo"
                   "Proximo Natureza X Empresa"
                   if d_ctc98m00.socntzcod is not null then
                      call ctc98m00_proximo(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
                           returning d_ctc98m00.*
                   else
                      error " Nenhuma natureza nesta direcao!"
                      message ""
                      next option "Seleciona"
                   end if
               
 
 command key ("A") "Anterior"
                   "Anterior Natureza X Empresa"
                   message " "
                   if d_ctc98m00.socntzcod is not null then
                      call ctc98m00_anterior(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
                           returning d_ctc98m00.*
                   else
                      error " Nenhuma natureza nesta direcao!"
                      message ""
                      next option "Seleciona"
                   end if
 command key ("I") "Inclui"
                   "Cadastra Natureza X Empresa"
                      message ""
                      clear form
                      initialize d_ctc98m00.*  to null
                      call ctc98m00_inclui(d_ctc98m00.*)
                      next option "Seleciona"
                  
 command key ("M") "Modifica"
                   "Modifica Natureza X Empresa"
                  if d_ctc98m00.socntzcod  is not null  then
                      call ctc98m00_modifica(d_ctc98m00.socntzcod, d_ctc98m00.*)
                           returning d_ctc98m00.*
                      next option "Seleciona"
                   else
                      error " Nenhuma natureza selecionada!"
                      message ""
                      next option "Seleciona"
                   end if
                   
 command key ("H") "Historico"
                   "Historico de modificacoes Natureza X Empresa"
                  if d_ctc98m00.socntzcod is not null then
                      call ctc98m01(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
                   else
                      error " Nenhuma natureza selecionada!"
                      message ""
                      next option "Seleciona"
                   end if
                   
   
 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc98m00

 end function  ###  ctc98m00
 
#------------------------------------------------------------
 function ctc98m00_seleciona(param)
#------------------------------------------------------------

 define param  record
    socntzcod  like dpakpecrefvlr.socntzcod,
    empcod     like dpakpecrefvlr.empcod
 end record
 
 define d_ctc98m00 record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod, 
    caddat         like dpakpecrefvlr.caddat   , 
    atldat         like dpakpecrefvlr.atldat   , 
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record      

 if m_ctc98m00_prep is null or
    m_ctc98m00_prep <> true then
    call ctc98m00_prepare()
 end if

 let int_flag = false
 initialize d_ctc98m00.*  to null
 clear form

 input by name d_ctc98m00.socntzcod,
               d_ctc98m00.empcod   without defaults

    before field socntzcod
        display by name d_ctc98m00.socntzcod attribute (reverse)

    after  field socntzcod
        display by name d_ctc98m00.socntzcod

        if d_ctc98m00.socntzcod  is null   then
           error " Natureza deve ser informada!"
           next field socntzcod
        end if

        open cctc98m00001 using d_ctc98m00.socntzcod
        
        fetch cctc98m00001 into d_ctc98m00.socntzdes
        
        if sqlca.sqlcode  =  notfound   then
           error " Natureza nao cadastrada ou cancelada no Porto Socorro!"
           next field socntzcod
        end if
        display by name d_ctc98m00.socntzdes
        
        
    before field empcod
       display by name d_ctc98m00.empcod attribute (reverse)           

    after  field empcod
        if fgl_lastkey() <> fgl_keyval("up")   and 
           fgl_lastkey() <> fgl_keyval("left") then 
           display by name d_ctc98m00.empcod
           
           if d_ctc98m00.empcod  is null   then
               error " Empresa deve ser informada!"
               next field empcod
           else
              open cctc98m00005 using d_ctc98m00.empcod
              fetch cctc98m00005 into d_ctc98m00.empsgl
              if sqlca.sqlcode  =  notfound   then
                 error 'Empresa informada nao esta cadastrado!' sleep 2
                 next field empcod
              end if
              close cctc98m00005
           end if
           display by name d_ctc98m00.empsgl   
        end if    
        
        call ctc98m00_ler(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
             returning d_ctc98m00.*
        
        if d_ctc98m00.socntzcod  is not null   then
           call ctc98m00_display(d_ctc98m00.*)
        else
           error " Parametrizacao nao cadastrada!"
           initialize d_ctc98m00.*    to null
           next field socntzcod
        end if
    
    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc98m00.*   to null
    call ctc98m00_display(d_ctc98m00.*)
    error " Operacao cancelada!"
    return d_ctc98m00.*
 end if

 return d_ctc98m00.*

end function  ###  ctc98m00_seleciona


#------------------------------------------------------------
 function ctc98m00_proximo(param)
#------------------------------------------------------------

 define param         record
    socntzcod         like dpakpecrefvlr.socntzcod,
    empcod            like dpakpecrefvlr.empcod
 end record

 define d_ctc98m00 record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod, 
    caddat         like dpakpecrefvlr.caddat   , 
    atldat         like dpakpecrefvlr.atldat   , 
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record    

 let int_flag = false
 initialize d_ctc98m00.*   to null


 if m_ctc98m00_prep is null or
    m_ctc98m00_prep <> true then
    call ctc98m00_prepare()
 end if
 
 
 if param.socntzcod  is null   then
    let param.socntzcod = 0
 end if
 
 select socntzcod,min(empcod)
   into d_ctc98m00.socntzcod,
        d_ctc98m00.empcod
   from dpakpecrefvlr
  where socntzcod  =  param.socntzcod
    and empcod  >  param.empcod
  group by socntzcod
  
 if d_ctc98m00.socntzcod  is not null   then

    call ctc98m00_ler(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
         returning d_ctc98m00.*

    if d_ctc98m00.socntzcod  is not null   then
       call ctc98m00_display(d_ctc98m00.*)
    else
       error " Nao ha' natureza nesta direcao!"
       initialize d_ctc98m00.*    to null
    end if
 else
    
    select min(socntzcod),min(empcod)   
       into d_ctc98m00.socntzcod, 
            d_ctc98m00.empcod  
      from dpakpecrefvlr
     where socntzcod  > param.socntzcod  
     
    if d_ctc98m00.socntzcod  is not null   then
    
       call ctc98m00_ler(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
            returning d_ctc98m00.*
    
       if d_ctc98m00.socntzcod  is not null   then
          call ctc98m00_display(d_ctc98m00.*)
       else
          error " Nao ha' natureza nesta direcao!"
          initialize d_ctc98m00.*    to null
       end if
    else
       error " Nao ha' natureza nesta direcao!"
       initialize d_ctc98m00.*    to null
    end if
 end if

 return d_ctc98m00.*

end function  ###  ctc98m00_proximo


#------------------------------------------------------------
 function ctc98m00_anterior(param)
#------------------------------------------------------------

 define param      record
    socntzcod      like dpakpecrefvlr.socntzcod,
    empcod         like dpakpecrefvlr.empcod  
 end record

define d_ctc98m00 record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod, 
    caddat         like dpakpecrefvlr.caddat   , 
    atldat         like dpakpecrefvlr.atldat   , 
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record    


 let int_flag = false
 initialize d_ctc98m00.*  to null

 if m_ctc98m00_prep is null or
    m_ctc98m00_prep <> true then
    call ctc98m00_prepare()
 end if


 if param.socntzcod  is null   then
    let param.socntzcod = 0
 end if

 select socntzcod,max(empcod)
   into d_ctc98m00.socntzcod,
        d_ctc98m00.empcod
   from dpakpecrefvlr
  where socntzcod  =  param.socntzcod
    and empcod  <  param.empcod
  group by socntzcod
       
 if d_ctc98m00.socntzcod  is not null   then
        
    call ctc98m00_ler(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
         returning d_ctc98m00.*

    if d_ctc98m00.socntzcod  is not null   then
       call ctc98m00_display(d_ctc98m00.*)
    else
       error " Nao ha' natureza nesta direcao!"
       initialize d_ctc98m00.*    to null
    end if
 else 
      
      select max(socntzcod)
       into d_ctc98m00.socntzcod
       from dpakpecrefvlr
      where socntzcod  < param.socntzcod
        
      select max(empcod)                   
        into d_ctc98m00.empcod             
        from dpakpecrefvlr                       
       where socntzcod  = d_ctc98m00.socntzcod
      
    if d_ctc98m00.empcod  is not null   then
       call ctc98m00_ler(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
            returning d_ctc98m00.*
    
       if d_ctc98m00.socntzcod  is not null   then
          call ctc98m00_display(d_ctc98m00.*)
       else
          error " Nao ha' natureza nesta direcao!"
          initialize d_ctc98m00.*    to null
       end if
    else       
       error " Nao ha' natureza nesta direcao!"
       initialize d_ctc98m00.*    to null
    end if
 end if

 return d_ctc98m00.*

end function  ###  ctc98m00_anterior


#------------------------------------------------------------
 function ctc98m00_modifica(param, d_ctc98m00_ant)
#------------------------------------------------------------

 define param         record
    socntzcod         smallint  
 end record

define d_ctc98m00_ant record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod, 
    caddat         like dpakpecrefvlr.caddat   , 
    atldat         like dpakpecrefvlr.atldat   , 
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record    
 
 define d_ctc98m00_dep record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod, 
    caddat         like dpakpecrefvlr.caddat   , 
    atldat         like dpakpecrefvlr.atldat   , 
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record                     
 
 initialize d_ctc98m00_dep.*  to null
 
 if m_ctc98m00_prep is null or
    m_ctc98m00_prep <> true then
    call ctc98m00_prepare()
 end if
 
 call ctc98m00_input("a", d_ctc98m00_ant.socntzcod, 
                          d_ctc98m00_ant.socntzdes,
                          d_ctc98m00_ant.empcod   ,
                          d_ctc98m00_ant.empsgl   ,
                          d_ctc98m00_ant.mobrefvlr,
                          d_ctc98m00_ant.pecmaxvlr,
                          d_ctc98m00_ant.cadsttcod)
     returning d_ctc98m00_dep.socntzcod, 
               d_ctc98m00_dep.socntzdes, 
               d_ctc98m00_dep.empcod   ,
               d_ctc98m00_dep.empsgl   ,
               d_ctc98m00_dep.mobrefvlr, 
               d_ctc98m00_dep.pecmaxvlr, 
               d_ctc98m00_dep.cadsttcod

 if int_flag  then
    let int_flag = false
    initialize d_ctc98m00_dep.*  to null
    call ctc98m00_display(d_ctc98m00_dep.*)
    error " Operacao cancelada!"
    return d_ctc98m00_dep.*
 end if

 begin work
 
 call ctc98m00_verifica_mod(d_ctc98m00_ant.socntzcod,
                            d_ctc98m00_ant.socntzdes,
                            d_ctc98m00_ant.empcod   ,
                            d_ctc98m00_ant.empsgl   ,
                            d_ctc98m00_ant.mobrefvlr,
                            d_ctc98m00_ant.pecmaxvlr,
                            d_ctc98m00_ant.cadsttcod,
                            d_ctc98m00_dep.socntzcod,
                            d_ctc98m00_dep.socntzdes,
                            d_ctc98m00_dep.empcod   ,
                            d_ctc98m00_dep.empsgl   ,
                            d_ctc98m00_dep.mobrefvlr,
                            d_ctc98m00_dep.pecmaxvlr,
                            d_ctc98m00_dep.cadsttcod)
  
  whenever error continue
    update dpakpecrefvlr set (mobrefvlr,
                              pecmaxvlr,
                              cadsttcod,
                              atldat   ,
                              atlusrtip,
                              atlemp   ,
                              atlmat   ) =
                             (d_ctc98m00_dep.mobrefvlr, 
                              d_ctc98m00_dep.pecmaxvlr, 
                              d_ctc98m00_dep.cadsttcod,
                              today        ,
                              g_issk.usrtip, 
                              g_issk.empcod, 
                              g_issk.funmat)
       where socntzcod = d_ctc98m00_dep.socntzcod
         and empcod    = d_ctc98m00_dep.empcod
       
    if sqlca.sqlcode <> 0 then
       rollback work
       error "Atualizacao nao realizada ERRO: ",sqlca.sqlcode
    else
       commit work
       error "Atualizacao efetuada com sucesso!"
    end if
 
 whenever error stop
 
 #initialize d_ctc98m00.*  to null
 call ctc98m00_ler(d_ctc98m00_dep.socntzcod,d_ctc98m00_dep.empcod)
         returning d_ctc98m00_dep.*
 
 call ctc98m00_display(d_ctc98m00_dep.*)
 message ""
 return d_ctc98m00_dep.*

end function  ###  ctc98m00_modifica


#------------------------------------------------------------
 function ctc98m00_inclui(d_ctc98m00)
#------------------------------------------------------------


 define d_ctc98m00 record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod, 
    caddat         like dpakpecrefvlr.caddat   , 
    atldat         like dpakpecrefvlr.atldat   , 
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record    
 
 define l_socntzcod like dpakpecrefvlr.socntzcod 
 
 initialize d_ctc98m00.*  to null

if m_ctc98m00_prep is null or
    m_ctc98m00_prep <> true then
    call ctc98m00_prepare()
 end if
 
 #call ctc98m00_display(d_ctc98m00.*)
 
  input by name   d_ctc98m00.socntzcod,
                  d_ctc98m00.socntzdes,
                  d_ctc98m00.empcod,
                  d_ctc98m00.empsgl without defaults
                 
          before field socntzcod                                         
            display by name d_ctc98m00.socntzcod attribute (reverse)     
                                                                      
          after  field socntzcod                                         
              display by name d_ctc98m00.socntzcod                         
                                                                      
              if d_ctc98m00.socntzcod  is null   then                      
                 error " Natureza deve ser informada!"                  
                 next field socntzcod                                    
              end if                                                  
                                                                      
              open cctc98m00001 using d_ctc98m00.socntzcod
        
              fetch cctc98m00001 into d_ctc98m00.socntzdes
        
              if sqlca.sqlcode  =  notfound   then                    
                 error " Natureza nao cadastrada ou cancelada no Porto Socorro!"                       
                 next field socntzcod                                    
              end if                                                  
              display by name d_ctc98m00.socntzdes 
                                                                      
          before field socntzdes                                       
              display by name d_ctc98m00.socntzdes attribute (reverse)   
                                                                      
          after  field socntzdes                                       
              display by name d_ctc98m00.socntzdes 
              
          before field empcod
              display by name d_ctc98m00.empcod attribute (reverse)           
           
           after  field empcod
              if fgl_lastkey() <> fgl_keyval("up")   and 
                 fgl_lastkey() <> fgl_keyval("left") then 
                 display by name d_ctc98m00.empcod
                 
                 if d_ctc98m00.empcod  is null   then
                     error " Empresa deve ser informada!"
                     next field empcod
                 else
                    open cctc98m00005 using d_ctc98m00.empcod
                    fetch cctc98m00005 into d_ctc98m00.empsgl
                    if sqlca.sqlcode  =  notfound   then
                       error 'Empresa informada nao esta cadastrado!' sleep 2
                       next field empcod
                    end if
                    close cctc98m00005
                 end if
                 display by name d_ctc98m00.empsgl   
              end if
               
              open cctc98m00004 using d_ctc98m00.socntzcod,d_ctc98m00.empcod
        
              fetch cctc98m00004 into l_socntzcod
               
              if sqlca.sqlcode  <>  notfound   then                    
                 error " Parametrizacao ja cadastrada para esta natureza!"                      
                 next field socntzcod                                    
              end if  
          
          before field empsgl                                                   
                        display by name d_ctc98m00.empsgl attribute (reverse)   
                                                                                      
          after  field empsgl                                              
              display by name d_ctc98m00.empsgl     
                                         
  end input 

   if int_flag  then                      
     let int_flag = false               
     initialize d_ctc98m00.*  to null   
     call ctc98m00_display(d_ctc98m00.*)
     error " Operacao cancelada!"       
     return                             
  end if  
  
  call ctc98m00_input("i", d_ctc98m00.socntzcod, 
                           d_ctc98m00.socntzdes,
                           d_ctc98m00.empcod   ,
                           d_ctc98m00.empsgl   ,
                           d_ctc98m00.mobrefvlr,
                           d_ctc98m00.pecmaxvlr,
                           d_ctc98m00.cadsttcod)
      returning d_ctc98m00.socntzcod, 
                d_ctc98m00.socntzdes, 
                d_ctc98m00.empcod   ,
                d_ctc98m00.empsgl   ,
                d_ctc98m00.mobrefvlr, 
                d_ctc98m00.pecmaxvlr, 
                d_ctc98m00.cadsttcod             
 
 whenever error continue
    insert into dpakpecrefvlr values(d_ctc98m00.socntzcod,
                                     d_ctc98m00.empcod,
                                     d_ctc98m00.mobrefvlr, 
                                     d_ctc98m00.pecmaxvlr, 
                                     d_ctc98m00.cadsttcod, 
                                     today               , 
                                     g_issk.usrtip       , 
                                     g_issk.empcod       , 
                                     g_issk.funmat       , 
                                     today               , 
                                     g_issk.usrtip       , 
                                     g_issk.empcod       , 
                                     g_issk.funmat       )
    if sqlca.sqlcode <> 0 then
       error "Inclusao nao realizada ERRO: ",sqlca.sqlcode
    else
       error "Inclusão efetuada com sucesso!"
    end if
 
 whenever error stop
 
 call ctc98m00_ler(d_ctc98m00.socntzcod,d_ctc98m00.empcod)
         returning d_ctc98m00.*
 
 call ctc98m00_display(d_ctc98m00.*)

end function  ###  ctc98m00_dinclui

#--------------------------------------------------------------------
 function ctc98m00_input(param, d_ctc98m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define d_ctc98m00 record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod
  end record    

define l_cponom like iddkdominio.cponom

if m_ctc98m00_prep is null or
    m_ctc98m00_prep <> true then
    call ctc98m00_prepare()
 end if
 
    input by name   d_ctc98m00.mobrefvlr,
                    d_ctc98m00.pecmaxvlr,
                    d_ctc98m00.cadsttcod   without defaults
              
       before field mobrefvlr                                       
          display by name d_ctc98m00.mobrefvlr attribute (reverse)   
                                                                  
      after  field mobrefvlr                                       
          display by name d_ctc98m00.mobrefvlr
          
          if d_ctc98m00.mobrefvlr  is null   then
              error " Valor referencia do servico deve ser informado!"
              next field mobrefvlr
           end if
           
      before field pecmaxvlr                                       
          display by name d_ctc98m00.pecmaxvlr attribute (reverse)   
                                                                  
      after  field pecmaxvlr                                       
          display by name d_ctc98m00.pecmaxvlr
          
          if d_ctc98m00.pecmaxvlr  is null   then
              error " Valor de pecas deve ser informado!"
              next field pecmaxvlr
           end if
           
      before field cadsttcod                                       
          error "Digite apenas (A)tivo ou (C)ancelado!"
          display by name d_ctc98m00.cadsttcod attribute (reverse)   
                                                                  
      after  field cadsttcod                                       
          display by name d_ctc98m00.cadsttcod 
          
          if d_ctc98m00.cadsttcod  is null   then
              error " Status do cadastro deve ser informado!"
              next field cadsttcod
          else
            if d_ctc98m00.cadsttcod <> 'A' and
               d_ctc98m00.cadsttcod <> 'C' then
               error "Digite apenas (A)tivo ou (C)ancelado!"
               next field cadsttcod
            end if
          end if
                                                                  
      on key (interrupt) 
        initialize d_ctc98m00.*  to null                                           
        exit input                                              
       
 end input

 #if int_flag then
 #   initialize d_ctc98m00.*  to null
 #end if

  return d_ctc98m00.*

end function  ###  ctc98m00_input


#---------------------------------------------------------
 function ctc98m00_ler(param)
#---------------------------------------------------------

 define param      record
    socntzcod      like dpakpecrefvlr.socntzcod, 
    empcod         like dpakpecrefvlr.empcod    
 end record

 define d_ctc98m00 record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod, 
    caddat         like dpakpecrefvlr.caddat   , 
    cadusrtip      like dpakpecrefvlr.cadusrtip, 
    cademp         like dpakpecrefvlr.cademp   , 
    cadmat         like dpakpecrefvlr.cadmat   , 
    atldat         like dpakpecrefvlr.atldat   , 
    atlusrtip      like dpakpecrefvlr.atlusrtip, 
    atlemp         like dpakpecrefvlr.atlemp   , 
    atlmat         like dpakpecrefvlr.atlmat   , 
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record                       
 
 define l_cponom like iddkdominio.cponom
 
 initialize d_ctc98m00.* to null
 
if m_ctc98m00_prep is null or
    m_ctc98m00_prep <> true then
    call ctc98m00_prepare()
 end if

 let d_ctc98m00.socntzcod = param.socntzcod
 
 let d_ctc98m00.empcod = param.empcod
 
 open cctc98m00003 using d_ctc98m00.socntzcod,d_ctc98m00.empcod
 
 fetch cctc98m00003 into d_ctc98m00.socntzcod,  
                         d_ctc98m00.empcod   ,  
                         d_ctc98m00.mobrefvlr,      
                         d_ctc98m00.pecmaxvlr,  
                         d_ctc98m00.cadsttcod,  
                         d_ctc98m00.caddat   ,  
                         d_ctc98m00.cadusrtip,  
                         d_ctc98m00.cademp   ,  
                         d_ctc98m00.cadmat   ,  
                         d_ctc98m00.atldat   ,  
                         d_ctc98m00.atlusrtip,  
                         d_ctc98m00.atlemp   ,
                         d_ctc98m00.atlmat     
                                     
   if sqlca.sqlcode  <> 0   then 
      initialize d_ctc98m00.* to null
      return d_ctc98m00.socntzcod,
             d_ctc98m00.socntzdes,
             d_ctc98m00.empcod   ,
             d_ctc98m00.empsgl   ,
             d_ctc98m00.mobrefvlr,
             d_ctc98m00.pecmaxvlr,
             d_ctc98m00.cadsttcod,
             d_ctc98m00.caddat   ,
             d_ctc98m00.atldat   ,
             d_ctc98m00.funcad   ,   
             d_ctc98m00.funatl      
   end if 
  close  cctc98m00003
 
   open cctc98m00001 using d_ctc98m00.socntzcod
 
   fetch cctc98m00001 into d_ctc98m00.socntzdes
   
   close  cctc98m00001
   
   
   open cctc98m00005 using d_ctc98m00.empcod
   
   fetch cctc98m00005 into d_ctc98m00.empsgl
   
   close cctc98m00005
   
   
   call ctc98m00_func(d_ctc98m00.cademp,d_ctc98m00.cadmat,d_ctc98m00.cadusrtip)
       returning d_ctc98m00.funcad
  
  call ctc98m00_func(d_ctc98m00.atlemp,d_ctc98m00.atlmat,d_ctc98m00.atlusrtip)
       returning d_ctc98m00.funatl
   
   
       
 return d_ctc98m00.socntzcod, 
        d_ctc98m00.socntzdes, 
        d_ctc98m00.empcod   , 
        d_ctc98m00.empsgl   , 
        d_ctc98m00.mobrefvlr, 
        d_ctc98m00.pecmaxvlr, 
        d_ctc98m00.cadsttcod, 
        d_ctc98m00.caddat   , 
        d_ctc98m00.atldat   , 
        d_ctc98m00.funcad   , 
        d_ctc98m00.funatl    
        

end function  ###  ctc98m00_ler


#---------------------------------------------------------
 function ctc98m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat,
    usrtip            like isskfunc.usrtip
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
    and isskfunc.usrtip = param.usrtip

 return ws.funnom

end function  ###  ctc98m00_func


#---------------------------------------------------------
 function ctc98m00_display(param)
#---------------------------------------------------------

 define param record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr,
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr,
    cadsttcod      like dpakpecrefvlr.cadsttcod,
    caddat         date   ,
    atldat         date   ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom         
 end record                                     
 
 if m_ctc98m00_prep is null or
    m_ctc98m00_prep <> true then
    call ctc98m00_prepare()
 end if
   
  display by name param.socntzcod     
  display by name param.socntzdes
  display by name param.empcod     
  display by name param.empsgl 
  display by name param.mobrefvlr  
  display by name param.pecmaxvlr
  display by name param.cadsttcod 
  display by name param.caddat  
  display by name param.atldat
  display by name param.funatl  
  display by name param.funcad
 

 
 if param.socntzcod is not null and param.socntzcod <> 0 then
       
    open cctc98m00001 using param.socntzcod
        
    fetch cctc98m00001 into param.socntzdes
    
    
      if sqlca.sqlcode  = 0   then      	
	      display by name  param.socntzdes attribute (reverse)	 
      else 
        let param.socntzdes = " "
	      display by name  param.socntzdes 
      end if	
    close cctc98m00001  
 end if 
 
 if param.empcod is not null and param.empcod <> 0 then
       
    open cctc98m00005 using param.empcod
        
    fetch cctc98m00005 into param.empsgl
    
    
      if sqlca.sqlcode  = 0   then      	
	      display by name  param.empsgl attribute (reverse)	 
      else 
        let param.empsgl = " "
	      display by name  param.empsgl 
      end if	
    close cctc98m00005  
 end if 
 
 
end function  ###  ctc98m00_display


#------------------------------------------------------------
function ctc98m00_grava_hist(lr_param)
#------------------------------------------------------------

   define lr_param record
          socntzcod  like dpakpecrefvlr.socntzcod
         ,empcod     like dpakpecrefvlr.empcod 
         ,mensagem   char(80)
         ,data       date
          end record

   
   define l_stt         smallint
         ,l_datatime    datetime year to fraction
         ,l_usrtip     char(1)
         ,l_empcod     decimal(2,0)
         ,l_funmat     decimal(6,0)
         ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint
         ,l_prshstdes2 char(3000)
         
   let l_stt  = true
   
   let l_length = length(lr_param.mensagem clipped)
   if  l_length mod 80 = 0 then
       let l_iter = l_length / 80
   else
       let l_iter = l_length / 80 + 1
   end if

   let l_length2     = 0
   
   for l_count = 1 to l_iter
       if  l_count = l_iter then
           let l_prshstdes2 = lr_param.mensagem[l_length2 + 1, l_length]
       else
           let l_length2 = l_length2 + 80
           let l_prshstdes2 = lr_param.mensagem[l_length2 - 79, l_length2]
       end if
    
       let l_datatime = current
       let l_usrtip = g_issk.usrtip
       let l_empcod = g_issk.empcod
       let l_funmat = g_issk.funmat
       display "lr_param.socntzcod:",lr_param.socntzcod     
       display "lr_param.empcod:",lr_param.empcod     
       display "lr_param.mensagem :",lr_param.mensagem   clipped     
       display "l_usrtip          :",l_usrtip    
       display "l_empcod          :",l_empcod    
       display "l_funmat          :",l_funmat
       display "l_datatime        :",l_datatime    
       
      whenever error continue  
       insert into dpampecrefvlrhst values (lr_param.socntzcod,
                                            lr_param.empcod,
                                            l_datatime,
                                            lr_param.mensagem,
                                            l_usrtip,   
                                            l_empcod,  
                                            l_funmat) 
       if sqlca.sqlcode = 0 then       
           let l_stt = true
        else
            error 'Erro na gravacao do historico: ',sqlca.sqlcode sleep 2
           let l_stt = false    
        end if  
       whenever error stop
   end for      
 return l_stt

end function

#---------------------------------------------------------
function ctc98m00_verifica_mod(lr_ctc98m00_ant,lr_ctc98m00)
#---------------------------------------------------------

 define lr_ctc98m00_ant record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod
 end record                      
                                
 define lr_ctc98m00 record
    socntzcod      like dpakpecrefvlr.socntzcod,
    socntzdes      like datksocntz.socntzdes   ,
    empcod         like dpakpecrefvlr.empcod   ,
    empsgl         like gabkemp.empsgl         ,
    mobrefvlr      like dpakpecrefvlr.mobrefvlr, 
    pecmaxvlr      like dpakpecrefvlr.pecmaxvlr, 
    cadsttcod      like dpakpecrefvlr.cadsttcod 
 end record                   

  define l_mesg char(78)
  define l_atldat date
  
  #let l_atldat = today
  
   if (lr_ctc98m00_ant.mobrefvlr is null     and lr_ctc98m00.mobrefvlr is not null) or
      (lr_ctc98m00_ant.mobrefvlr is not null and lr_ctc98m00.mobrefvlr is null)     or
      (lr_ctc98m00_ant.mobrefvlr              <> lr_ctc98m00.mobrefvlr)             then
      let l_mesg = 'Valor referencia do servico foi alterado de [',
      lr_ctc98m00_ant.mobrefvlr ,'] para [',lr_ctc98m00.mobrefvlr ,']'

      if not ctc98m00_grava_hist(lr_ctc98m00.socntzcod
                                ,lr_ctc98m00.empcod
                                ,l_mesg
                                ,l_atldat) then

         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

   if (lr_ctc98m00_ant.pecmaxvlr is null     and lr_ctc98m00.pecmaxvlr is not null) or
      (lr_ctc98m00_ant.pecmaxvlr is not null and lr_ctc98m00.pecmaxvlr is null)     or
      (lr_ctc98m00_ant.pecmaxvlr              <> lr_ctc98m00.pecmaxvlr)             then
      let l_mesg = "Valor de peca alterado de [",
      lr_ctc98m00_ant.pecmaxvlr ,"] para [",lr_ctc98m00.pecmaxvlr ,"]"

      if not ctc98m00_grava_hist(lr_ctc98m00.socntzcod
                                ,lr_ctc98m00.empcod 
                                ,l_mesg
                                ,l_atldat) then
         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

   if (lr_ctc98m00_ant.cadsttcod is null     and lr_ctc98m00.cadsttcod is not null) or
      (lr_ctc98m00_ant.cadsttcod is not null and lr_ctc98m00.cadsttcod is null)     or
      (lr_ctc98m00_ant.cadsttcod              <> lr_ctc98m00.cadsttcod)             then
      let l_mesg = "Status alterado de [ ",lr_ctc98m00_ant.cadsttcod, "] para [",lr_ctc98m00.cadsttcod,"]"
      
      if not ctc98m00_grava_hist(lr_ctc98m00.socntzcod  
                                ,lr_ctc98m00.empcod 
                                ,l_mesg
                                ,l_atldat) then

         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

end function

