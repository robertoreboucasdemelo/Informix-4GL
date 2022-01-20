#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctc93m01                                                    #
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

 define m_ctc93m01_prep smallint
 define m_min_atdsrvorg like datkdcrorg.atdsrvorg

#-------------------------#
function ctc93m01_prepare()
#-------------------------#

  define l_sql char(300)
  
  let l_sql = "select srvtipabvdes ",      
              "  from datksrvtip   ",      
              " where atdsrvorg = ?"       
  prepare pctc93m01001 from l_sql             
  declare cctc93m01001 cursor for pctc93m01001
  
  
   let l_sql = "Select cpodes     ",                  
               "  from iddkdominio",                  
               " where cponom = ?",                   
               "   and cpocod =? "                    
   prepare pctc93m01002 from l_sql                 
   declare cctc93m01002 cursor for pctc93m01002 
   
   
   let l_sql = "select atdsrvorg, ",
               "       c24astcod, ",
               "       srvdcrcod, ",   
               "       bemcod   , ",
               "       atoflg   , ",
               "       cadusrtip, ",   
               "       cademp   , ",
               "       cadmat   , ",
               "       caddat   , ",
               "       atlusrtip, ",   
               "       atlemp   , ",
               "       atlmat   , ",
               "       atldat     ",            
               "  from datkdcrorg",            
               " where atdsrvorg = ?",
               "   and c24astcod = ?"           
   prepare pctc93m01003 from l_sql              
   declare cctc93m01003 cursor for pctc93m01003 
   
   let l_sql = "select atdsrvorg ",            
               "  from datkdcrorg",            
               " where atdsrvorg = ?",
               "   and c24astcod = ?"
   prepare pctc93m01004 from l_sql              
   declare cctc93m01004 cursor for pctc93m01004
   
   
   let l_sql = "select c24astdes ",            
               "  from datkassunto ",            
               " where c24astcod = ? "             
   prepare pctc93m01005 from l_sql              
   declare cctc93m01005 cursor for pctc93m01005
   
   
   
   
  
  let m_ctc93m01_prep = true

end function

#------------------------------------------------------------
 function ctc93m01()
#------------------------------------------------------------

 define d_ctc93m01 record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    caddat         like datkdcrorg.caddat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record       
                                     
 
 initialize d_ctc93m01.*  to null
 
  if not get_niv_mod(g_issk.prgsgl, "ctc93m01") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 else
    select min(atdsrvorg) into m_min_atdsrvorg  from datkdcrorg
 end if
 
 
 open window ctc93m01 at 04,02 with form "ctc93m01"
 
  display by name d_ctc93m01.*
  
 menu "Origens"
 
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
                   "Seleciona de/para de origens"
                   call ctc93m01_seleciona(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)  returning d_ctc93m01.*
                   if d_ctc93m01.atdsrvorg  is not null  then
                      message ""
                      next option "Proximo"
                   else
                      error " Nenhuma origem selecionada!"
                      message ""
                      next option "Seleciona"
                   end if
                   
 command key ("P") "Proximo"
                   "Proximo de/para de origens"
                   if d_ctc93m01.atdsrvorg is not null then
                      call ctc93m01_proximo(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
                           returning d_ctc93m01.*
                   else
                      error " Nenhum origem nesta direcao!"
                      message ""
                      next option "Seleciona"
                   end if
               
 
 command key ("A") "Anterior"
                   "Anterior de/para de origens"
                   message " "
                   if d_ctc93m01.atdsrvorg is not null then
                      call ctc93m01_anterior(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
                           returning d_ctc93m01.*
                   else
                      error " Nenhum origem nesta direcao!"
                      message ""
                      next option "Seleciona"
                   end if
 command key ("I") "Inclui"
                   "Cadastra de/para de origens"
                      message ""
                      clear form
                      initialize d_ctc93m01.*  to null
                      call ctc93m01_inclui(d_ctc93m01.*)
                      next option "Seleciona"
                  
 command key ("M") "Modifica"
                   "Modifica de/para de origens"
                  if d_ctc93m01.atdsrvorg  is not null  then
                      call ctc93m01_modifica(d_ctc93m01.atdsrvorg, d_ctc93m01.*)
                           returning d_ctc93m01.*
                      next option "Seleciona"
                   else
                      error " Nenhuma origem selecionada!"
                      message ""
                      next option "Seleciona"
                   end if
                   
 command key ("H") "Historico"
                   "Historico de modificacoes de/para de origens"
                  if d_ctc93m01.atdsrvorg is not null then
                      call ctc93m02(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
                   else
                      error " Nenhum origem selecionada!"
                      message ""
                      next option "Seleciona"
                   end if
                   
   
 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc93m01

 end function  ###  ctc93m01
 
#------------------------------------------------------------
 function ctc93m01_seleciona(param)
#------------------------------------------------------------

 define param         record
    atdsrvorg         like datkdcrorg.atdsrvorg,
    c24astcod         like datkdcrorg.c24astcod
 end record
 
 define d_ctc93m01 record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    caddat         like datkdcrorg.caddat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record   

 if m_ctc93m01_prep is null or
    m_ctc93m01_prep <> true then
    call ctc93m01_prepare()
 end if

 let int_flag = false
 initialize d_ctc93m01.*  to null
 clear form

 input by name d_ctc93m01.atdsrvorg,
               d_ctc93m01.c24astcod   without defaults

    before field atdsrvorg
        display by name d_ctc93m01.atdsrvorg attribute (reverse)

    after  field atdsrvorg
        display by name d_ctc93m01.atdsrvorg

        if d_ctc93m01.atdsrvorg  is null   then
           error " Origem deve ser informada!"
           next field atdsrvorg
        end if

        open cctc93m01001 using d_ctc93m01.atdsrvorg
        
        fetch cctc93m01001 into d_ctc93m01.srvtipabvdes
        
        if sqlca.sqlcode  =  notfound   then
           error " Origem nao cadastrada!"
           next field atdsrvorg
        end if
        display by name d_ctc93m01.srvtipabvdes
        
        
    before field c24astcod
       error " Caso o assunto nao seja necessario coloque 'ZZZ'" 
       display by name d_ctc93m01.c24astcod attribute (reverse)           

    after  field c24astcod
        if fgl_lastkey() <> fgl_keyval("up")   and 
           fgl_lastkey() <> fgl_keyval("left") then 
           display by name d_ctc93m01.c24astcod
           
           if d_ctc93m01.c24astcod  is null   then
               error " Caso o assunto nao seja necessario coloque 'ZZZ'"
               next field c24astcod
           else
              if d_ctc93m01.c24astcod = 'ZZZ' then
                 let d_ctc93m01.c24astdes = "Indiferende"
              else
                 open cctc93m01005 using d_ctc93m01.c24astcod
                 fetch cctc93m01005 into d_ctc93m01.c24astdes
                 if sqlca.sqlcode  =  notfound   then
                    error 'Assunto informado nao esta cadastrado!' sleep 2
                    next field c24astcod
                 end if
                 close cctc93m01005
              end if 
           end if
           display by name d_ctc93m01.c24astdes   
        end if    
        
        call ctc93m01_ler(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
             returning d_ctc93m01.*
        
        if d_ctc93m01.atdsrvorg  is not null   then
           call ctc93m01_display(d_ctc93m01.*)
        else
           error " Parametrizacao nao cadastrada!"
           initialize d_ctc93m01.*    to null
           next field atdsrvorg
        end if
    
    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc93m01.*   to null
    call ctc93m01_display(d_ctc93m01.*)
    error " Operacao cancelada!"
    return d_ctc93m01.*
 end if

 return d_ctc93m01.*

end function  ###  ctc93m01_seleciona


#------------------------------------------------------------
 function ctc93m01_proximo(param)
#------------------------------------------------------------

 define param         record
    atdsrvorg         smallint,
    c24astcod         like datkdcrorg.c24astcod
 end record

 define d_ctc93m01 record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    caddat         like datkdcrorg.caddat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record 

 let int_flag = false
 initialize d_ctc93m01.*   to null


 if m_ctc93m01_prep is null or
    m_ctc93m01_prep <> true then
    call ctc93m01_prepare()
 end if
 
 
 if param.atdsrvorg  is null   then
    let param.atdsrvorg = 0
 end if
 
 select atdsrvorg,min(c24astcod)
   into d_ctc93m01.atdsrvorg,
        d_ctc93m01.c24astcod
   from datkdcrorg
  where atdsrvorg  =  param.atdsrvorg
    and c24astcod  >  param.c24astcod
  group by atdsrvorg
  
 if d_ctc93m01.atdsrvorg  is not null   then

    call ctc93m01_ler(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
         returning d_ctc93m01.*

    if d_ctc93m01.atdsrvorg  is not null   then
       call ctc93m01_display(d_ctc93m01.*)
    else
       error " Nao ha' origem nesta direcao!"
       initialize d_ctc93m01.*    to null
    end if
 else
    
    select min(atdsrvorg),min(c24astcod)   
       into d_ctc93m01.atdsrvorg, 
            d_ctc93m01.c24astcod  
      from datkdcrorg
     where atdsrvorg  > param.atdsrvorg  
     
    if d_ctc93m01.atdsrvorg  is not null   then
    
       call ctc93m01_ler(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
            returning d_ctc93m01.*
    
       if d_ctc93m01.atdsrvorg  is not null   then
          call ctc93m01_display(d_ctc93m01.*)
       else
          error " Nao ha' origem nesta direcao!"
          initialize d_ctc93m01.*    to null
       end if
    else
       error " Nao ha' origem nesta direcao!"
       initialize d_ctc93m01.*    to null
    end if
 end if

 return d_ctc93m01.*

end function  ###  ctc93m01_proximo


#------------------------------------------------------------
 function ctc93m01_anterior(param)
#------------------------------------------------------------

 define param         record
    atdsrvorg         smallint,
    c24astcod         like datkdcrorg.c24astcod  
 end record

define d_ctc93m01 record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    caddat         like datkdcrorg.caddat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record 


 let int_flag = false
 initialize d_ctc93m01.*  to null

 if m_ctc93m01_prep is null or
    m_ctc93m01_prep <> true then
    call ctc93m01_prepare()
 end if


 if param.atdsrvorg  is null   then
    let param.atdsrvorg = 0
 end if

 select atdsrvorg,max(c24astcod)
   into d_ctc93m01.atdsrvorg,
        d_ctc93m01.c24astcod
   from datkdcrorg
  where atdsrvorg  =  param.atdsrvorg
    and c24astcod  <  param.c24astcod
  group by atdsrvorg
  
 if d_ctc93m01.atdsrvorg  is not null   then

    call ctc93m01_ler(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
         returning d_ctc93m01.*

    if d_ctc93m01.atdsrvorg  is not null   then
       call ctc93m01_display(d_ctc93m01.*)
    else
       error " Nao ha' origem nesta direcao!"
       initialize d_ctc93m01.*    to null
    end if
 else
    
      
      
      select max(atdsrvorg)
       into d_ctc93m01.atdsrvorg
       from datkdcrorg
      where atdsrvorg  < param.atdsrvorg
     
     if m_min_atdsrvorg = d_ctc93m01.atdsrvorg then
        
        select max(c24astcod)                   
          into d_ctc93m01.c24astcod             
          from datkdcrorg                       
         where atdsrvorg  = d_ctc93m01.atdsrvorg
     else
     
        select max(c24astcod)
          into d_ctc93m01.c24astcod
          from datkdcrorg
         where atdsrvorg  < d_ctc93m01.atdsrvorg 
     end if 
      
      
      
      
      
      
      
    if d_ctc93m01.c24astcod  is not null   then
    
       call ctc93m01_ler(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
            returning d_ctc93m01.*
    
       if d_ctc93m01.atdsrvorg  is not null   then
          call ctc93m01_display(d_ctc93m01.*)
       else
          error " Nao ha' origem nesta direcao!"
          initialize d_ctc93m01.*    to null
       end if
    else
       
       
       error " Nao ha' origem nesta direcao!"
       initialize d_ctc93m01.*    to null
    end if
 end if

 return d_ctc93m01.*

end function  ###  ctc93m01_anterior


#------------------------------------------------------------
 function ctc93m01_modifica(param, d_ctc93m01_ant)
#------------------------------------------------------------

 define param         record
    atdsrvorg         smallint  
 end record

define d_ctc93m01_ant record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    caddat         like datkdcrorg.caddat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record
 
 define d_ctc93m01_dep record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    caddat         like datkdcrorg.caddat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record                 
 
 initialize d_ctc93m01_dep.*  to null
 
 if m_ctc93m01_prep is null or
    m_ctc93m01_prep <> true then
    call ctc93m01_prepare()
 end if
 
 call ctc93m01_input("a", d_ctc93m01_ant.atdsrvorg   , 
                          d_ctc93m01_ant.srvtipabvdes,
                          d_ctc93m01_ant.c24astcod   ,
                          d_ctc93m01_ant.c24astdes   ,
                          d_ctc93m01_ant.srvdcrcod   ,
                          d_ctc93m01_ant.srvdcrdes   ,
                          d_ctc93m01_ant.bemcod      ,
                          d_ctc93m01_ant.bemdes      ,
                          d_ctc93m01_ant.atoflg      ,
                          d_ctc93m01_ant.atoflgdes) 
     returning d_ctc93m01_dep.atdsrvorg   , 
               d_ctc93m01_dep.srvtipabvdes, 
               d_ctc93m01_dep.c24astcod   ,
               d_ctc93m01_dep.c24astdes   ,
               d_ctc93m01_dep.srvdcrcod   ,
               d_ctc93m01_dep.srvdcrdes   ,
               d_ctc93m01_dep.bemcod      ,
               d_ctc93m01_dep.bemdes      ,
               d_ctc93m01_dep.atoflg      ,
               d_ctc93m01_dep.atoflgdes

 if int_flag  then
    let int_flag = false
    initialize d_ctc93m01_dep.*  to null
    call ctc93m01_display(d_ctc93m01_dep.*)
    error " Operacao cancelada!"
    return d_ctc93m01_dep.*
 end if

 begin work
 
 call ctc93m01_verifica_mod(d_ctc93m01_ant.atdsrvorg   ,
                            d_ctc93m01_ant.srvtipabvdes,
                            d_ctc93m01_ant.c24astcod   ,
                            d_ctc93m01_ant.c24astdes   ,
                            d_ctc93m01_ant.srvdcrcod   ,
                            d_ctc93m01_ant.srvdcrdes   ,
                            d_ctc93m01_ant.bemcod      ,
                            d_ctc93m01_ant.bemdes      ,
                            d_ctc93m01_ant.atoflg      ,
                            d_ctc93m01_ant.atoflgdes   ,
                            d_ctc93m01_dep.atdsrvorg   ,
                            d_ctc93m01_dep.srvtipabvdes, 
                            d_ctc93m01_dep.c24astcod   ,
                            d_ctc93m01_dep.c24astdes   ,
                            d_ctc93m01_dep.srvdcrcod   ,
                            d_ctc93m01_dep.srvdcrdes   ,
                            d_ctc93m01_dep.bemcod      ,
                            d_ctc93m01_dep.bemdes      ,
                            d_ctc93m01_dep.atoflg      ,
                            d_ctc93m01_dep.atoflgdes)
  
  whenever error continue
    update datkdcrorg set (srvdcrcod,bemcod,atoflg,atlusrtip,atlemp,atlmat,atldat) =
                          (d_ctc93m01_dep.srvdcrcod, 
                           d_ctc93m01_dep.bemcod   , 
                           d_ctc93m01_dep.atoflg   , 
                           g_issk.usrtip       , 
                           g_issk.empcod       , 
                           g_issk.funmat       , 
                           today               )
       where atdsrvorg = d_ctc93m01_dep.atdsrvorg
         and c24astcod = d_ctc93m01_dep.c24astcod
       
    if sqlca.sqlcode <> 0 then
       rollback work
       error "Atualizacao nao realizada ERRO: ",sqlca.sqlcode
    else
       commit work
       error "Atualizacao efetuada com sucesso!"
    end if
 
 whenever error stop
 
 #initialize d_ctc93m01.*  to null
 call ctc93m01_ler(d_ctc93m01_dep.atdsrvorg,d_ctc93m01_dep.c24astcod)
         returning d_ctc93m01_dep.*
 
 call ctc93m01_display(d_ctc93m01_dep.*)
 message ""
 return d_ctc93m01_dep.*

end function  ###  ctc93m01_modifica


#------------------------------------------------------------
 function ctc93m01_inclui(d_ctc93m01)
#------------------------------------------------------------


 define d_ctc93m01 record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    caddat         like datkdcrorg.caddat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record
 
 define l_origem like datmservico.atdsrvorg 
 
 initialize d_ctc93m01.*  to null

if m_ctc93m01_prep is null or
    m_ctc93m01_prep <> true then
    call ctc93m01_prepare()
 end if
 
 #call ctc93m01_display(d_ctc93m01.*)
 
  input by name   d_ctc93m01.atdsrvorg,
                  d_ctc93m01.srvtipabvdes,
                  d_ctc93m01.c24astcod,
                  d_ctc93m01.c24astdes without defaults
                 
          before field atdsrvorg                                         
            display by name d_ctc93m01.atdsrvorg attribute (reverse)     
                                                                      
          after  field atdsrvorg                                         
              display by name d_ctc93m01.atdsrvorg                         
                                                                      
              if d_ctc93m01.atdsrvorg  is null   then                      
                 error " Origem deve ser informada!"                  
                 next field atdsrvorg                                    
              end if                                                  
                                                                      
              open cctc93m01001 using d_ctc93m01.atdsrvorg
        
              fetch cctc93m01001 into d_ctc93m01.srvtipabvdes
        
              if sqlca.sqlcode  =  notfound   then                    
                 error " Origem nao cadastrada!"                      
                 next field atdsrvorg                                    
              end if                                                  
              display by name d_ctc93m01.srvtipabvdes 
                                                                      
          before field srvtipabvdes                                       
              display by name d_ctc93m01.srvtipabvdes attribute (reverse)   
                                                                      
          after  field srvtipabvdes                                       
              display by name d_ctc93m01.srvtipabvdes 
              
          before field c24astcod
              error " Caso o assunto nao seja necessario coloque 'ZZZ'" 
              display by name d_ctc93m01.c24astcod attribute (reverse)           
           
           after  field c24astcod
              if fgl_lastkey() <> fgl_keyval("up")   and 
                 fgl_lastkey() <> fgl_keyval("left") then 
                 display by name d_ctc93m01.c24astcod
                 
                 if d_ctc93m01.c24astcod  is null   then
                     error " Caso o assunto nao seja necessario coloque 'ZZZ'"
                     next field c24astcod
                 else
                    if d_ctc93m01.c24astcod = 'ZZZ' then
                       let d_ctc93m01.c24astdes = "Indiferende"
                    else
                       open cctc93m01005 using d_ctc93m01.c24astcod
                       fetch cctc93m01005 into d_ctc93m01.c24astdes
                       if sqlca.sqlcode  =  notfound   then
                          error 'Assunto informado nao esta cadastrado!' sleep 2
                          next field c24astcod
                       end if
                       close cctc93m01005
                    end if 
                 end if
                 display by name d_ctc93m01.c24astdes   
              end if
               
              open cctc93m01004 using d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod
        
              fetch cctc93m01004 into l_origem
               
              if sqlca.sqlcode  <>  notfound   then                    
                 error " Parametrizacao ja cadastrada para esta origem!"                      
                 next field atdsrvorg                                    
              end if  
          
          before field c24astdes                                                   
                        display by name d_ctc93m01.c24astdes attribute (reverse)   
                                                                                      
          after  field c24astdes                                              
              display by name d_ctc93m01.c24astdes     
                                         
  end input 

   if int_flag  then                      
     let int_flag = false               
     initialize d_ctc93m01.*  to null   
     call ctc93m01_display(d_ctc93m01.*)
     error " Operacao cancelada!"       
     return                             
  end if  
  
  call ctc93m01_input("i", d_ctc93m01.atdsrvorg   , 
                           d_ctc93m01.srvtipabvdes,
                           d_ctc93m01.c24astcod   ,
                           d_ctc93m01.c24astdes   ,
                           d_ctc93m01.srvdcrcod   , 
                           d_ctc93m01.srvdcrdes   , 
                           d_ctc93m01.bemcod      , 
                           d_ctc93m01.bemdes      , 
                           d_ctc93m01.atoflg      , 
                           d_ctc93m01.atoflgdes)    
      returning d_ctc93m01.atdsrvorg   ,            
                d_ctc93m01.srvtipabvdes,
                d_ctc93m01.c24astcod   ,
                d_ctc93m01.c24astdes   ,            
                d_ctc93m01.srvdcrcod   ,            
                d_ctc93m01.srvdcrdes   ,            
                d_ctc93m01.bemcod      ,            
                d_ctc93m01.bemdes      ,            
                d_ctc93m01.atoflg      ,            
                d_ctc93m01.atoflgdes                
 
 whenever error continue
    insert into datkdcrorg values(d_ctc93m01.atdsrvorg,
                                  d_ctc93m01.c24astcod,
                                  d_ctc93m01.srvdcrcod, 
                                  d_ctc93m01.bemcod   , 
                                  d_ctc93m01.atoflg   , 
                                  g_issk.usrtip       , 
                                  g_issk.empcod       , 
                                  g_issk.funmat       , 
                                  today               , 
                                  g_issk.usrtip       , 
                                  g_issk.empcod       , 
                                  g_issk.funmat       , 
                                  today               )
    if sqlca.sqlcode <> 0 then
       error "Inclusao nao realizada ERRO: ",sqlca.sqlcode
    else
       error "Inclusão efetuada com sucesso!"
    end if
 
 whenever error stop
 
 call ctc93m01_ler(d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod)
         returning d_ctc93m01.*
 
 call ctc93m01_display(d_ctc93m01.*)

end function  ###  ctc93m01_dinclui

#--------------------------------------------------------------------
 function ctc93m01_input(param, d_ctc93m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define d_ctc93m01 record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes   
 end record

define l_cponom like iddkdominio.cponom

if m_ctc93m01_prep is null or
    m_ctc93m01_prep <> true then
    call ctc93m01_prepare()
 end if
 
    input by name   d_ctc93m01.srvdcrcod,
                    d_ctc93m01.srvdcrdes,
                    d_ctc93m01.bemcod,
                    d_ctc93m01.bemdes,
                    d_ctc93m01.atoflg  ,
                    d_ctc93m01.atoflgdes     without defaults
              
       before field srvdcrcod                                       
          display by name d_ctc93m01.srvdcrcod attribute (reverse)   
                                                                  
      after  field srvdcrcod                                       
          display by name d_ctc93m01.srvdcrcod
          
          if d_ctc93m01.srvdcrcod  is null   then
              error " Decorrencia do Servico deve ser informada!"
              call ctn36c00("Decorrencia do Servico", "decservico")
                   returning  d_ctc93m01.srvdcrcod
              next field srvdcrcod
           end if
           
           let l_cponom = "decservico"
             
           open cctc93m01002  using l_cponom,d_ctc93m01.srvdcrcod
           fetch cctc93m01002 into d_ctc93m01.srvdcrdes 
           
           if sqlca.sqlcode  =  notfound   then
              error " Decorrencia do Servico nao cadastrada!"
              call ctn36c00("Decorrencia do Servico", "decservico")
                   returning  d_ctc93m01.srvdcrcod
              next field srvdcrcod
           end if
           display by name d_ctc93m01.srvdcrdes  
              
          
      before field srvdcrdes                                       
          display by name d_ctc93m01.srvdcrdes attribute (reverse)   
                                                                  
      after  field srvdcrdes                                       
          display by name d_ctc93m01.srvdcrdes  
          
      before field bemcod                                       
          display by name d_ctc93m01.bemcod attribute (reverse)   
                                                                  
      after  field bemcod                                       
          display by name d_ctc93m01.bemcod
          
          if d_ctc93m01.bemcod  is null   then
              error " Bem atendido deve ser informado!"
              call ctn36c00("Bem atendido", "bemAtendido")
                   returning  d_ctc93m01.bemcod
              next field bemcod
           end if
           
           let l_cponom = "bemAtendido"
             
           open cctc93m01002  using l_cponom,d_ctc93m01.bemcod
           fetch cctc93m01002 into d_ctc93m01.bemdes 
           
           
           if sqlca.sqlcode  =  notfound   then
              error " Bem atendido nao cadastrado!"
              call ctn36c00("Bem atendido", "bemAtendido")
                   returning  d_ctc93m01.bemcod
              next field bemcod
           end if
           display by name d_ctc93m01.bemdes  
          
          
          
      before field bemdes                                       
          display by name d_ctc93m01.bemdes attribute (reverse)   
                                                                  
      after  field bemdes                                       
          display by name d_ctc93m01.bemdes    
            
          
      before field atoflg                                       
          display by name d_ctc93m01.atoflg attribute (reverse)   
                                                                  
      after  field atoflg                                       
          display by name d_ctc93m01.atoflg 
          
          if d_ctc93m01.atoflg  is null   then
              error " Status de/para origem deve ser informado!"
              call ctn36c00("Status de/para origem", "De/Para_OrgMtv")
                   returning  d_ctc93m01.atoflg
              next field atoflg
           end if

           let l_cponom = "De/Para_OrgMtv"
             
           open cctc93m01002  using l_cponom,d_ctc93m01.atoflg
           fetch cctc93m01002 into d_ctc93m01.atoflgdes 
           
           
           if sqlca.sqlcode  =  notfound   then
              error " Status de/para origem nao cadastrado!"
              call ctn36c00("Status de/para origem", "De/Para_OrgMtv")
                   returning  d_ctc93m01.atoflg
              next field atoflg
           end if
           display by name d_ctc93m01.atoflgdes  
          
      before field atoflgdes                                       
          display by name d_ctc93m01.atoflgdes attribute (reverse)   
                                                                  
      after  field atoflgdes                                       
          display by name d_ctc93m01.atoflgdes                       
                                                                  
                                                                  
      on key (interrupt) 
        initialize d_ctc93m01.*  to null                                           
        exit input                                              
       
 end input

 #if int_flag then
 #   initialize d_ctc93m01.*  to null
 #end if

  return d_ctc93m01.*

end function  ###  ctc93m01_input


#---------------------------------------------------------
 function ctc93m01_ler(param)
#---------------------------------------------------------

 define param         record
    atdsrvorg         like datkdcrorg.atdsrvorg, 
    c24astcod         like datkdcrorg.c24astcod    
 end record

 define d_ctc93m01 record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    cadusrtip      like datkdcrorg.cadusrtip   ,
    cademp         like datkdcrorg.cademp      ,
    cadmat         like datkdcrorg.cadmat      ,
    caddat         like datkdcrorg.caddat      ,
    atlusrtip      like datkdcrorg.atlusrtip   ,
    atlemp         like datkdcrorg.atlemp      ,
    atlmat         like datkdcrorg.atlmat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record                    
 
 define l_cponom like iddkdominio.cponom
 
 initialize d_ctc93m01.* to null
 
if m_ctc93m01_prep is null or
    m_ctc93m01_prep <> true then
    call ctc93m01_prepare()
 end if

 let d_ctc93m01.atdsrvorg = param.atdsrvorg
 
 let d_ctc93m01.c24astcod = param.c24astcod
 
 open cctc93m01003 using d_ctc93m01.atdsrvorg,d_ctc93m01.c24astcod
 
 fetch cctc93m01003 into d_ctc93m01.atdsrvorg,
                         d_ctc93m01.c24astcod,
                         d_ctc93m01.srvdcrcod,
                         d_ctc93m01.bemcod   ,
                         d_ctc93m01.atoflg   ,
                         d_ctc93m01.cadusrtip,
                         d_ctc93m01.cademp   ,
                         d_ctc93m01.cadmat   ,
                         d_ctc93m01.caddat   ,
                         d_ctc93m01.atlusrtip,
                         d_ctc93m01.atlemp   ,
                         d_ctc93m01.atlmat   ,
                         d_ctc93m01.atldat   
   if sqlca.sqlcode  <> 0   then 
      initialize d_ctc93m01.* to null
      return d_ctc93m01.atdsrvorg   ,
             d_ctc93m01.srvtipabvdes,
             d_ctc93m01.c24astcod   ,
             d_ctc93m01.c24astdes   ,
             d_ctc93m01.srvdcrcod   ,
             d_ctc93m01.srvdcrdes   ,
             d_ctc93m01.bemcod      ,
             d_ctc93m01.bemdes      ,
             d_ctc93m01.atoflg      ,
             d_ctc93m01.atoflgdes   ,
             d_ctc93m01.caddat      ,
             d_ctc93m01.atldat      ,
             d_ctc93m01.funcad      ,
             d_ctc93m01.funatl      
   end if 
  close  cctc93m01003
 
   open cctc93m01001 using d_ctc93m01.atdsrvorg
 
   fetch cctc93m01001 into d_ctc93m01.srvtipabvdes
   
   close  cctc93m01001
   
   
   if d_ctc93m01.c24astcod = 'ZZZ' then
      let d_ctc93m01.c24astdes = "Indiferende"
   else 
      open cctc93m01005 using d_ctc93m01.c24astcod
      
      fetch cctc93m01005 into d_ctc93m01.c24astdes
      
      close cctc93m01005
   end if 
   
   
   let l_cponom = "decservico"
   open cctc93m01002  using l_cponom,d_ctc93m01.srvdcrcod
   fetch cctc93m01002 into d_ctc93m01.srvdcrdes 
   close  cctc93m01002
         
   let l_cponom = "bemAtendido"
   open cctc93m01002  using l_cponom,d_ctc93m01.bemcod
   fetch cctc93m01002 into d_ctc93m01.bemdes 
   close  cctc93m01002
          
   let l_cponom = "De/Para_OrgMtv"
   open cctc93m01002  using l_cponom,d_ctc93m01.atoflg
   fetch cctc93m01002 into d_ctc93m01.atoflgdes  
   close  cctc93m01002
   
   call ctc93m01_func(d_ctc93m01.cademp,d_ctc93m01.cadmat,d_ctc93m01.cadusrtip)
       returning d_ctc93m01.funcad
  
  call ctc93m01_func(d_ctc93m01.atlemp,d_ctc93m01.atlmat,d_ctc93m01.atlusrtip)
       returning d_ctc93m01.funatl
   
   
       
 return d_ctc93m01.atdsrvorg   ,
        d_ctc93m01.srvtipabvdes,
        d_ctc93m01.c24astcod   ,
        d_ctc93m01.c24astdes   ,
        d_ctc93m01.srvdcrcod   ,
        d_ctc93m01.srvdcrdes   ,
        d_ctc93m01.bemcod      ,
        d_ctc93m01.bemdes      ,
        d_ctc93m01.atoflg      ,
        d_ctc93m01.atoflgdes   ,
        d_ctc93m01.caddat      ,
        d_ctc93m01.atldat      ,
        d_ctc93m01.funcad      ,
        d_ctc93m01.funatl      

end function  ###  ctc93m01_ler


#---------------------------------------------------------
 function ctc93m01_func(param)
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

end function  ###  ctc93m01_func


#---------------------------------------------------------
 function ctc93m01_display(param)
#---------------------------------------------------------

 define param record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes     ,
    caddat         like datkdcrorg.caddat      ,
    atldat         like datkdcrorg.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
 end record     
 
 if m_ctc93m01_prep is null or
    m_ctc93m01_prep <> true then
    call ctc93m01_prepare()
 end if
 
  display by name param.atdsrvorg     
  display by name param.srvtipabvdes
  display by name param.c24astcod     
  display by name param.c24astdes 
  display by name param.srvdcrcod  
  display by name param.srvdcrdes
  display by name param.bemcod
  display by name param.bemdes
  display by name param.atoflg  
  display by name param.atoflgdes
  display by name param.caddat  
  display by name param.atldat
  display by name param.funatl  
  display by name param.funcad
 

 
 if param.atdsrvorg is not null and param.atdsrvorg <> 0 then
       
    open cctc93m01001 using param.atdsrvorg
        
    fetch cctc93m01001 into param.srvtipabvdes
    
    
      if sqlca.sqlcode  = 0   then      	
	      display by name  param.srvtipabvdes attribute (reverse)	 
      else 
        let param.srvtipabvdes = " "
	      display by name  param.srvtipabvdes 
      end if	
    close cctc93m01001  
 end if 
 
 if param.c24astcod is not null and param.c24astcod <> 0 then
       
    open cctc93m01005 using param.c24astcod
        
    fetch cctc93m01005 into param.c24astdes
    
    
      if sqlca.sqlcode  = 0   then      	
	      display by name  param.c24astdes attribute (reverse)	 
      else 
        let param.c24astdes = " "
	      display by name  param.c24astdes 
      end if	
    close cctc93m01005  
 end if 
 
 
end function  ###  ctc93m01_display


#------------------------------------------------------------
function ctc93m01_grava_hist(lr_param)
#------------------------------------------------------------

   define lr_param record
          atdsrvorg  like datkdcrorg.atdsrvorg
         ,c24astcod  like datkdcrorg.c24astcod 
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
       display "lr_param.atdsrvorg:",lr_param.atdsrvorg     
       display "lr_param.c24astcod:",lr_param.c24astcod     
       display "lr_param.mensagem :",lr_param.mensagem   clipped     
       display "l_usrtip          :",l_usrtip    
       display "l_empcod          :",l_empcod    
       display "l_funmat          :",l_funmat
       display "l_datatime        :",l_datatime    
       
      whenever error continue  
       insert into datkdcrorghst values (lr_param.atdsrvorg,
                                         lr_param.c24astcod,
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
function ctc93m01_verifica_mod(lr_ctc93m01_ant,lr_ctc93m01)
#---------------------------------------------------------

 define lr_ctc93m01_ant record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes   
 end record                   
                                
 define lr_ctc93m01 record
    atdsrvorg      like datkdcrorg.atdsrvorg   ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    c24astcod      like datkdcrorg.c24astcod   ,
    c24astdes      like datkassunto.c24astdes  ,
    srvdcrcod      like datkdcrorg.srvdcrcod   ,
    srvdcrdes      like iddkdominio.cpodes     ,
    bemcod         like datkdcrorg.bemcod      ,
    bemdes         like iddkdominio.cpodes     ,
    atoflg         like datkdcrorg.atoflg      ,
    atoflgdes      like iddkdominio.cpodes   
 end record                

  define l_mesg char(78)
  define l_atldat date
  
  #let l_atldat = today
  
   if (lr_ctc93m01_ant.srvdcrcod is null     and lr_ctc93m01.srvdcrcod is not null) or
      (lr_ctc93m01_ant.srvdcrcod is not null and lr_ctc93m01.srvdcrcod is null)     or
      (lr_ctc93m01_ant.srvdcrcod              <> lr_ctc93m01.srvdcrcod)             then
      let l_mesg = 'Decorrencia do servico foi alterada de [',lr_ctc93m01_ant.srvdcrcod using '<<<','-',
      lr_ctc93m01_ant.srvdcrdes clipped,'] para [',lr_ctc93m01.srvdcrcod using '<<<', '-',
      lr_ctc93m01.srvdcrdes clipped,']'

      if not ctc93m01_grava_hist(lr_ctc93m01.atdsrvorg
                                ,lr_ctc93m01.c24astcod
                                ,l_mesg
                                ,l_atldat) then

         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

   if (lr_ctc93m01_ant.bemcod is null     and lr_ctc93m01.bemcod is not null) or
      (lr_ctc93m01_ant.bemcod is not null and lr_ctc93m01.bemcod is null)     or
      (lr_ctc93m01_ant.bemcod              <> lr_ctc93m01.bemcod)             then
      let l_mesg = "Bem atendido alterado de [",lr_ctc93m01_ant.bemcod using '<<<',"-",
      lr_ctc93m01_ant.bemdes clipped,"] para [",lr_ctc93m01.bemcod using '<<<', "-",
      lr_ctc93m01.bemdes clipped,"]"

      if not ctc93m01_grava_hist(lr_ctc93m01.atdsrvorg
                                ,lr_ctc93m01.c24astcod 
                                ,l_mesg
                                ,l_atldat) then
         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

   if (lr_ctc93m01_ant.atoflg is null     and lr_ctc93m01.atoflg is not null) or
      (lr_ctc93m01_ant.atoflg is not null and lr_ctc93m01.atoflg is null)     or
      (lr_ctc93m01_ant.atoflg              <> lr_ctc93m01.atoflg)             then
      let l_mesg = "Situacao alterado de [",lr_ctc93m01_ant.atoflg using '<<<' ,"-",
          lr_ctc93m01_ant.atoflgdes clipped,"] para [",lr_ctc93m01.atoflg using '<<<',"-",
          lr_ctc93m01.atoflgdes  clipped,"]"

      if not ctc93m01_grava_hist(lr_ctc93m01.atdsrvorg  
                                ,lr_ctc93m01.c24astcod 
                                ,l_mesg
                                ,l_atldat) then

         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

end function

