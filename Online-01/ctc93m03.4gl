#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctc93m03                                                    #
# Analista Resp.: Beatriz Araujo                                              #
# PSI...........: PSI-2012-00289/EV                                           #
# Objetivo......: Tela de cadastro do de/para de motivos                      #
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

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_ctc93m03_prep smallint

#-------------------------#
function ctc93m03_prepare()
#-------------------------#

  define l_sql char(3000)
   
  let l_sql = "select cpodes                      ",    
                 "  from iddkdominio                 ", 
                 " where cponom = 'avialgmtv_empresa'", 
                 "   and cpocod =? "                    
     prepare pctc93m03001 from l_sql                  
     declare cctc93m03001 cursor for pctc93m03001   
                                                        
     let l_sql = "select cpodes     ",                  
                 "  from iddkdominio",                  
                 " where cponom = ?",                   
                 "   and cpocod =? "                    
     prepare pctc93m03002 from l_sql                 
     declare cctc93m03002 cursor for pctc93m03002  
     
     let l_sql = "select srvtipabvdes ",               
                 "  from datksrvtip   ",                  
                 " where atdsrvorg = ?"         
     prepare pctc93m03003 from l_sql          
     declare cctc93m03003 cursor for pctc93m03003
    
    
     let l_sql = "select empsgl     ",           
                 "  from gabkemp    ",              
                 " where empcod = ? "
     prepare pctc93m03004 from l_sql          
     declare cctc93m03004 cursor for pctc93m03004
     
     
     let l_sql = "select atdsrvorg, ",
                 "       ciaempcod, ",   
                 "       avialgmtv, ",
                 "       srvdcrcod, ",
                 "       bemcod   , ",   
                 "       atoflg   , ",
                 "       cadusrtip, ",
                 "       cadempcod, ",
                 "       cadmat   , ",   
                 "       caddat   , ",
                 "       atlusrtip, ",
                 "       atlempcod, ", 
                 "       atlmat   , ",
                 "       atldat     ",
                 "  from datkalgmtv",            
                 " where atdsrvorg = ?",
                 "   and ciaempcod = ?",
                 "   and avialgmtv = ?"           
   prepare pctc93m03005 from l_sql              
   declare cctc93m03005 cursor for pctc93m03005 
   
   
     let l_sql = "select atdsrvorg ",
                 "  from datkalgmtv",            
                 " where atdsrvorg = ?",
                 "   and ciaempcod = ?",
                 "   and avialgmtv = ?"           
   prepare pctc93m03006 from l_sql              
   declare cctc93m03006 cursor for pctc93m03006 
   
   
   
     
   let m_ctc93m03_prep = true
                                                       
end function

#------------------------------------------------------------
 function ctc93m03()
#------------------------------------------------------------

 define d_ctc93m03 record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    caddat         like datkalgmtv.caddat,
    funcad         like isskfunc.funnom,  
    atldat         like datkalgmtv.atldat,
    funatl         like isskfunc.funnom  
end record                
                                     
 
 initialize d_ctc93m03.*  to null
 
  if not get_niv_mod(g_issk.prgsgl, "ctc93m03") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if
 
 
 open window ctc93m03 at 04,02 with form "ctc93m03"
 
 display by name d_ctc93m03.*
 
 menu "Motivo"
 
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
                   "Seleciona de/para de motivos"
                   call ctc93m03_seleciona(d_ctc93m03.atdsrvorg,
                                           d_ctc93m03.ciaempcod,
                                           d_ctc93m03.avialgmtv)  returning d_ctc93m03.*
                   if d_ctc93m03.avialgmtv  is not null  then
                      message ""
                      next option "Proximo"
                   else
                      error " Nenhum motivo selecionado!"
                      message ""
                      next option "Seleciona"
                   end if
                   
 command key ("P") "Proximo"
                   "Proximo de/para de motivos"
                   if d_ctc93m03.avialgmtv is not null then
                      call ctc93m03_proximo(d_ctc93m03.atdsrvorg,
                                           d_ctc93m03.ciaempcod,
                                           d_ctc93m03.avialgmtv)
                           returning d_ctc93m03.*
                   else
                      error " Nenhum motivo nesta direcao!"
                      message ""
                      next option "Seleciona"
                   end if
               
 
 command key ("A") "Anterior"
                   "Anterior de/para de motivos"
                   message " "
                   if d_ctc93m03.avialgmtv is not null then
                      call ctc93m03_anterior(d_ctc93m03.atdsrvorg,
                                             d_ctc93m03.ciaempcod,
                                             d_ctc93m03.avialgmtv)
                           returning d_ctc93m03.*
                   else
                      error " Nenhum motivo nesta direcao!"
                      message ""
                      next option "Seleciona"
                   end if
 command key ("I") "Inclui"
                   "Cadastra de/para de motivos"
                      message ""
                      clear form
                      initialize d_ctc93m03.*  to null
                      call ctc93m03_inclui(d_ctc93m03.*)
                      next option "Seleciona"
                  
 command key ("M") "Modifica"
                   "Modifica de/para de motivos"
                  if d_ctc93m03.avialgmtv  is not null  then
                      call ctc93m03_modifica(d_ctc93m03.atdsrvorg,
                                             d_ctc93m03.ciaempcod,
                                             d_ctc93m03.avialgmtv,
                                             d_ctc93m03.*)
                           returning d_ctc93m03.*
                      next option "Seleciona"
                   else
                      error " Nenhum motivo selecionado!"
                      message ""
                      next option "Seleciona"
                   end if
                   
 command key ("H") "Historico"
                   "Historico de modificacoes de/para de motivos"
                  if d_ctc93m03.avialgmtv is not null then
                     call ctc93m04(d_ctc93m03.atdsrvorg,    
                                   d_ctc93m03.srvtipabvdes,  
                                   d_ctc93m03.avialgmtv, 
                                   d_ctc93m03.avialgmtvdes,
                                   d_ctc93m03.ciaempcod,    
                                   d_ctc93m03.empsgl)
                   else
                      error " Nenhum motivo selecionada!"
                      message ""
                      next option "Seleciona"
                   end if
                   
   
 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc93m03

 end function  ###  ctc93m03
 
#------------------------------------------------------------
 function ctc93m03_seleciona(param)
#------------------------------------------------------------

 define param         record   
    atdsrvorg      like datkalgmtv.atdsrvorg,
    ciaempcod      like datkalgmtv.ciaempcod,
    avialgmtv      like datkalgmtv.avialgmtv
 end record
 
 define d_ctc93m03 record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    caddat         like datkalgmtv.caddat,
    funcad         like isskfunc.funnom,  
    atldat         like datkalgmtv.atldat,
    funatl         like isskfunc.funnom  
end record

define lr_retorno     record
        erro           smallint,
        ciaempcod      like datkalgmtv.ciaempcod,
        empnom         like gabkemp.empnom
 end record 
 
define l_cpodes_emp  like iddkdominio.cpodes 
define l_cpodes      like iddkdominio.cpodes

 let int_flag = false
 initialize d_ctc93m03.*  to null
 initialize lr_retorno.* to null
 initialize l_cpodes_emp to null  
 initialize l_cpodes to null  
 clear form

 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if



 input by name d_ctc93m03.atdsrvorg,
               d_ctc93m03.ciaempcod,
               d_ctc93m03.avialgmtv without defaults

    before field atdsrvorg
        display by name d_ctc93m03.atdsrvorg attribute (reverse)

    after  field atdsrvorg
        display by name d_ctc93m03.atdsrvorg
      if fgl_lastkey() <> fgl_keyval("up")   and 
         fgl_lastkey() <> fgl_keyval("left") then 
        if d_ctc93m03.atdsrvorg  is null   then
           error " Origem deve ser informada!"
        end if

        open cctc93m03003 using  d_ctc93m03.atdsrvorg
           
        fetch cctc93m03003 into d_ctc93m03.srvtipabvdes
        
        if sqlca.sqlcode  =  notfound   then
           error " Origem nao cadastrada!"
           next field atdsrvorg
        end if
        display by name d_ctc93m03.srvtipabvdes 
      end if   
                               
    before field ciaempcod
        display by name d_ctc93m03.ciaempcod attribute (reverse)

    after  field ciaempcod
        display by name d_ctc93m03.ciaempcod
      if fgl_lastkey() <> fgl_keyval("up")   and 
         fgl_lastkey() <> fgl_keyval("left") then 
        if d_ctc93m03.ciaempcod  is null   then
           error " Empresa deve ser informada!"
           call cty14g00_popup_empresa()  
            returning lr_retorno.erro, 
                      lr_retorno.ciaempcod, 
                      lr_retorno.empnom  
           let d_ctc93m03.ciaempcod =  lr_retorno.ciaempcod            
           next field ciaempcod
        end if
      
        display "d_ctc93m03.ciaempcod: ",d_ctc93m03.ciaempcod
        
        open cctc93m03004 using  d_ctc93m03.ciaempcod
           
        fetch cctc93m03004 into d_ctc93m03.empsgl
        
        if sqlca.sqlcode  =  notfound   then
           error " Empresa nao cadastrada!"
           next field ciaempcod
        end if
        display by name d_ctc93m03.empsgl
      end if  
            
    before field avialgmtv
        display by name d_ctc93m03.avialgmtv attribute (reverse)

    after  field avialgmtv
        display by name d_ctc93m03.avialgmtv
      if fgl_lastkey() <> fgl_keyval("up")   and 
         fgl_lastkey() <> fgl_keyval("left") then 
        if d_ctc93m03.avialgmtv  is null   then
           error " Motivo deve ser informado!"
           
           open cctc93m03001 using  d_ctc93m03.ciaempcod
           
           fetch cctc93m03001 into l_cpodes_emp
           
           call ctn36c00("Motivo Carro-Extra",l_cpodes_emp clipped )
                   returning  d_ctc93m03.avialgmtv
                   
              next field avialgmtv
        end if

        open cctc93m03001 using  d_ctc93m03.ciaempcod  
                                              
        fetch cctc93m03001 into l_cpodes_emp    
        
        
        open cctc93m03002 using  l_cpodes_emp,d_ctc93m03.avialgmtv
                                              
        fetch cctc93m03002 into l_cpodes     
              
        if sqlca.sqlcode  =  notfound   then
           error " Motivo nao cadastrado!"
           next field avialgmtv
        else
           let d_ctc93m03.avialgmtvdes = l_cpodes clipped
        end if
        display by name d_ctc93m03.avialgmtvdes
      end if 
    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc93m03.*   to null
    initialize lr_retorno.* to null
    initialize l_cpodes_emp to null
    call ctc93m03_display(d_ctc93m03.*)
    error " Operacao cancelada!"
    return d_ctc93m03.*
 end if

 call ctc93m03_ler(d_ctc93m03.atdsrvorg,
                   d_ctc93m03.ciaempcod,
                   d_ctc93m03.avialgmtv)
      returning d_ctc93m03.*
 
 if d_ctc93m03.avialgmtv  is not null   then
    call ctc93m03_display(d_ctc93m03.*)
 else
    error " Motivo nao cadastrado!"
    initialize d_ctc93m03.*    to null
 end if

 return d_ctc93m03.*

end function  ###  ctc93m03_seleciona


#------------------------------------------------------------
 function ctc93m03_proximo(param)
#------------------------------------------------------------

 define param         record   
    atdsrvorg      like datkalgmtv.atdsrvorg,
    ciaempcod      like datkalgmtv.ciaempcod,
    avialgmtv      like datkalgmtv.avialgmtv
 end record

 define d_ctc93m03 record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    caddat         like datkalgmtv.caddat,
    funcad         like isskfunc.funnom,  
    atldat         like datkalgmtv.atldat,
    funatl         like isskfunc.funnom  
end record 

define l_cpodes_emp  like iddkdominio.cpodes 
define l_cpodes      like iddkdominio.cpodes

 let int_flag = false
 initialize d_ctc93m03.*   to null
 initialize l_cpodes_emp to null
 initialize l_cpodes     to null

 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if

 if param.avialgmtv  is null   then
    let param.avialgmtv = 0
 end if

open cctc93m03001 using  param.ciaempcod  
                                              
 fetch cctc93m03001 into l_cpodes_emp  
       
 select min(avialgmtv)
   into d_ctc93m03.avialgmtv
   from datkalgmtv
  where ciaempcod = param.ciaempcod
    and atdsrvorg = param.atdsrvorg
    and avialgmtv > param.avialgmtv
    
  let d_ctc93m03.ciaempcod =  param.ciaempcod 
  let d_ctc93m03.atdsrvorg =  param.atdsrvorg 
    

 if d_ctc93m03.avialgmtv  is not null   then

    call ctc93m03_ler(d_ctc93m03.atdsrvorg,
                      d_ctc93m03.ciaempcod,
                      d_ctc93m03.avialgmtv)
         returning d_ctc93m03.*

    if d_ctc93m03.avialgmtv  is not null   then
       call ctc93m03_display(d_ctc93m03.*)
    else
       error " Nao ha' motivos nesta direcao!"
       initialize d_ctc93m03.*    to null
    end if
 else
    error " Nao ha' motivos nesta direcao!"
    initialize d_ctc93m03.*    to null
 end if

 return d_ctc93m03.*

end function  ###  ctc93m03_proximo


#------------------------------------------------------------
 function ctc93m03_anterior(param)
#------------------------------------------------------------

 define param         record   
    atdsrvorg      like datkalgmtv.atdsrvorg,
    ciaempcod      like datkalgmtv.ciaempcod,
    avialgmtv      like datkalgmtv.avialgmtv
 end record

 define d_ctc93m03 record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    caddat         like datkalgmtv.caddat,
    funcad         like isskfunc.funnom,  
    atldat         like datkalgmtv.atldat,
    funatl         like isskfunc.funnom  
end record 

define l_cpodes_emp  like iddkdominio.cpodes 
define l_cpodes      like iddkdominio.cpodes

 let int_flag = false
 initialize d_ctc93m03.*   to null
 initialize l_cpodes_emp to null
 initialize l_cpodes     to null

 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if
 
 if param.avialgmtv  is null   then
    let param.avialgmtv = 0
 end if

 open cctc93m03001 using  param.ciaempcod  
                                              
 fetch cctc93m03001 into l_cpodes_emp    
               
 select max(avialgmtv)
   into d_ctc93m03.avialgmtv
   from datkalgmtv
  where ciaempcod = param.ciaempcod
    and atdsrvorg = param.atdsrvorg
    and avialgmtv < param.avialgmtv
    
  let d_ctc93m03.ciaempcod =  param.ciaempcod 
  let d_ctc93m03.atdsrvorg =  param.atdsrvorg 
    

 if d_ctc93m03.avialgmtv  is not null   then

    call ctc93m03_ler(d_ctc93m03.atdsrvorg,
                      d_ctc93m03.ciaempcod,
                      d_ctc93m03.avialgmtv)
         returning d_ctc93m03.*

    if d_ctc93m03.avialgmtv  is not null   then
       call ctc93m03_display(d_ctc93m03.*)
    else
       error " Nao ha' avialgmtv nesta direcao!"
       initialize d_ctc93m03.*    to null
    end if
 else
    error " Nao ha' avialgmtv nesta direcao!"
    initialize d_ctc93m03.*    to null
 end if

 return d_ctc93m03.*

end function  ###  ctc93m03_anterior


#------------------------------------------------------------
 function ctc93m03_modifica(param, d_ctc93m03_ant)
#------------------------------------------------------------

define param         record   
    atdsrvorg      like datkalgmtv.atdsrvorg,
    ciaempcod      like datkalgmtv.ciaempcod,
    avialgmtv      like datkalgmtv.avialgmtv
 end record

 define d_ctc93m03_ant record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    caddat         like datkalgmtv.caddat,
    funcad         like isskfunc.funnom,  
    atldat         like datkalgmtv.atldat,
    funatl         like isskfunc.funnom  
end record  
 
 define d_ctc93m03_dep record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    caddat         like datkalgmtv.caddat,
    funcad         like isskfunc.funnom,  
    atldat         like datkalgmtv.atldat,
    funatl         like isskfunc.funnom  
end record                 
 
 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if
 
 
 
 call ctc93m03_input("a", d_ctc93m03_ant.atdsrvorg   ,
                          d_ctc93m03_ant.srvtipabvdes,
                          d_ctc93m03_ant.ciaempcod   ,
                          d_ctc93m03_ant.empsgl      ,
                          d_ctc93m03_ant.avialgmtv   ,
                          d_ctc93m03_ant.avialgmtvdes,
                          d_ctc93m03_ant.srvdcrcod   ,
                          d_ctc93m03_ant.srvdcrdes   ,
                          d_ctc93m03_ant.bemcod      ,
                          d_ctc93m03_ant.bemdes      ,
                          d_ctc93m03_ant.atoflg      ,
                          d_ctc93m03_ant.atoflgdes)
            returning d_ctc93m03_dep.atdsrvorg   ,
                      d_ctc93m03_dep.srvtipabvdes,
                      d_ctc93m03_dep.ciaempcod   ,
                      d_ctc93m03_dep.empsgl      ,
                      d_ctc93m03_dep.avialgmtv   ,
                      d_ctc93m03_dep.avialgmtvdes,
                      d_ctc93m03_dep.srvdcrcod   ,
                      d_ctc93m03_dep.srvdcrdes   ,
                      d_ctc93m03_dep.bemcod      ,
                      d_ctc93m03_dep.bemdes      ,
                      d_ctc93m03_dep.atoflg      ,
                      d_ctc93m03_dep.atoflgdes   
  
 if int_flag  then
    let int_flag = false
    initialize d_ctc93m03_dep.*  to null
    call ctc93m03_display(d_ctc93m03_dep.*)
    error " Operacao cancelada!"
    return d_ctc93m03_dep.*
 end if

 begin work

 call ctc93m03_verifica_mod(d_ctc93m03_ant.atdsrvorg   ,
                            d_ctc93m03_ant.srvtipabvdes,
                            d_ctc93m03_ant.ciaempcod   ,
                            d_ctc93m03_ant.empsgl      ,
                            d_ctc93m03_ant.avialgmtv   ,
                            d_ctc93m03_ant.avialgmtvdes,
                            d_ctc93m03_ant.srvdcrcod   ,
                            d_ctc93m03_ant.srvdcrdes   ,
                            d_ctc93m03_ant.bemcod      ,
                            d_ctc93m03_ant.bemdes      ,
                            d_ctc93m03_ant.atoflg      ,
                            d_ctc93m03_ant.atoflgdes   ,
                            d_ctc93m03_dep.atdsrvorg   ,
                            d_ctc93m03_dep.srvtipabvdes,
                            d_ctc93m03_dep.ciaempcod   ,
                            d_ctc93m03_dep.empsgl      ,
                            d_ctc93m03_dep.avialgmtv   ,
                            d_ctc93m03_dep.avialgmtvdes,
                            d_ctc93m03_dep.srvdcrcod   ,
                            d_ctc93m03_dep.srvdcrdes   ,
                            d_ctc93m03_dep.bemcod      ,
                            d_ctc93m03_dep.bemdes      ,
                            d_ctc93m03_dep.atoflg      ,
                            d_ctc93m03_dep.atoflgdes   )
  
  whenever error continue
    update datkalgmtv set (srvdcrcod,bemcod,atoflg,atlusrtip,
                           atlempcod,atlmat,atldat) =
                          (d_ctc93m03_dep.srvdcrcod, 
                           d_ctc93m03_dep.bemcod   , 
                           d_ctc93m03_dep.atoflg   , 
                           g_issk.usrtip       , 
                           g_issk.empcod       , 
                           g_issk.funmat       , 
                           today               )
       where atdsrvorg = d_ctc93m03_dep.atdsrvorg
         and ciaempcod = d_ctc93m03_dep.ciaempcod
         and avialgmtv = d_ctc93m03_dep.avialgmtv
    if sqlca.sqlcode <> 0 then
       rollback work
       error "Atualizacao nao realizada ERRO: ",sqlca.sqlcode
    else
       commit work
       error "Atualizacao efetuada com sucesso!"
    end if
 
 whenever error stop
  
 call ctc93m03_ler(d_ctc93m03_dep.atdsrvorg,
                   d_ctc93m03_dep.ciaempcod,
                   d_ctc93m03_dep.avialgmtv)
      returning d_ctc93m03_dep.* 
  
 #initialize d_ctc93m03.*  to null
 call ctc93m03_display(d_ctc93m03_dep.*)
 message ""
 return d_ctc93m03_dep.*

end function  ###  ctc93m03_modifica


#------------------------------------------------------------
 function ctc93m03_inclui(d_ctc93m03)
#------------------------------------------------------------


 define d_ctc93m03 record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    caddat         like datkalgmtv.caddat,
    funcad         like isskfunc.funnom,  
    atldat         like datkalgmtv.atldat,
    funatl         like isskfunc.funnom  
end record  

define lr_retorno     record
        erro           smallint,
        ciaempcod      like datkalgmtv.ciaempcod,
        empnom         like gabkemp.empnom
 end record 
 
define l_cpodes_emp  like iddkdominio.cpodes 
define l_cpodes      like iddkdominio.cpodes
define l_origem      like datkalgmtv.atdsrvorg

 let int_flag = false
 initialize d_ctc93m03.*  to null
 initialize lr_retorno.* to null
 initialize l_cpodes_emp to null  
 initialize l_cpodes to null  
 clear form

 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if

 call ctc93m03_display(d_ctc93m03.*)
 
  input by name d_ctc93m03.atdsrvorg,
                d_ctc93m03.ciaempcod,
                d_ctc93m03.avialgmtv without defaults

    before field atdsrvorg
        display by name d_ctc93m03.atdsrvorg attribute (reverse)

    after  field atdsrvorg
        display by name d_ctc93m03.atdsrvorg
      if fgl_lastkey() <> fgl_keyval("up")   and 
         fgl_lastkey() <> fgl_keyval("left") then 
        if d_ctc93m03.atdsrvorg  is null   then
           error " Origem deve ser informada!"
        end if

        open cctc93m03003 using  d_ctc93m03.atdsrvorg
           
        fetch cctc93m03003 into d_ctc93m03.srvtipabvdes
        
        if sqlca.sqlcode  =  notfound   then
           error " Origem nao cadastrada!"
           next field atdsrvorg
        end if
        display by name d_ctc93m03.srvtipabvdes 
      end if   
                               
    before field ciaempcod
        display by name d_ctc93m03.ciaempcod attribute (reverse)

    after  field ciaempcod
        display by name d_ctc93m03.ciaempcod
      if fgl_lastkey() <> fgl_keyval("up")   and 
         fgl_lastkey() <> fgl_keyval("left") then 
        if d_ctc93m03.ciaempcod  is null   then
           error " Empresa deve ser informada!"
           call cty14g00_popup_empresa()  
            returning lr_retorno.erro, 
                      lr_retorno.ciaempcod, 
                      lr_retorno.empnom  
           let d_ctc93m03.ciaempcod =  lr_retorno.ciaempcod            
           next field ciaempcod
        end if
       
        open cctc93m03004 using  d_ctc93m03.ciaempcod  
                                              
        fetch cctc93m03004 into d_ctc93m03.empsgl   
         
        if sqlca.sqlcode  =  notfound   then
           error " Empresa nao cadastrada!"
           next field ciaempcod
        end if
        display by name d_ctc93m03.empsgl
      end if  
            
    before field avialgmtv
        display by name d_ctc93m03.avialgmtv attribute (reverse)

    after  field avialgmtv
        display by name d_ctc93m03.avialgmtv
      if fgl_lastkey() <> fgl_keyval("up")   and 
         fgl_lastkey() <> fgl_keyval("left") then 
        if d_ctc93m03.avialgmtv  is null   then
           error " Motivo deve ser informado!"
           
           open cctc93m03001 using  d_ctc93m03.ciaempcod  
                                              
           fetch cctc93m03001 into l_cpodes_emp 
           
           call ctn36c00("Motivo Carro-Extra",l_cpodes_emp clipped )
                   returning  d_ctc93m03.avialgmtv
                   
              next field avialgmtv
        end if

        open cctc93m03001 using  d_ctc93m03.ciaempcod  
                                              
        fetch cctc93m03001 into l_cpodes_emp 
              
        open cctc93m03002 using  l_cpodes_emp,d_ctc93m03.avialgmtv
                                              
        fetch cctc93m03002 into l_cpodes  
        
        if sqlca.sqlcode  =  notfound   then
           error " Motivo nao cadastrado!"
           next field avialgmtv
        else
           let d_ctc93m03.avialgmtvdes = l_cpodes
        end if
        display by name d_ctc93m03.avialgmtvdes
        
        
        open cctc93m03006 using d_ctc93m03.atdsrvorg,
                                d_ctc93m03.ciaempcod,
                                d_ctc93m03.avialgmtv
        
        fetch cctc93m03006 into l_origem
         
        if sqlca.sqlcode  <>  notfound   then                    
           error " Parametrizacao ja cadastrada para o Motivo!"                      
           next field atdsrvorg                                    
        end if  
      
      end if 
    
    on key (interrupt)
        exit input
        
 end input
 
 if int_flag  then                      
     let int_flag = false               
     initialize d_ctc93m03.*  to null   
     call ctc93m03_display(d_ctc93m03.*)
     error " Operacao cancelada!"       
     return                             
  end if                                
 
  call ctc93m03_input("i", d_ctc93m03.atdsrvorg   ,
                           d_ctc93m03.srvtipabvdes,
                           d_ctc93m03.ciaempcod   ,
                           d_ctc93m03.empsgl      ,
                           d_ctc93m03.avialgmtv   ,
                           d_ctc93m03.avialgmtvdes,
                           d_ctc93m03.srvdcrcod   ,
                           d_ctc93m03.srvdcrdes   ,
                           d_ctc93m03.bemcod      ,
                           d_ctc93m03.bemdes      ,
                           d_ctc93m03.atoflg      ,
                           d_ctc93m03.atoflgdes)
            returning d_ctc93m03.atdsrvorg   ,
                      d_ctc93m03.srvtipabvdes,
                      d_ctc93m03.ciaempcod   ,
                      d_ctc93m03.empsgl      ,
                      d_ctc93m03.avialgmtv   ,
                      d_ctc93m03.avialgmtvdes,
                      d_ctc93m03.srvdcrcod   ,
                      d_ctc93m03.srvdcrdes   ,
                      d_ctc93m03.bemcod      ,
                      d_ctc93m03.bemdes      ,
                      d_ctc93m03.atoflg      ,
                      d_ctc93m03.atoflgdes  
 whenever error continue
    insert into datkalgmtv values(d_ctc93m03.atdsrvorg,
                                  d_ctc93m03.ciaempcod,     
                                  d_ctc93m03.avialgmtv,
                                  d_ctc93m03.srvdcrcod, 
                                  d_ctc93m03.bemcod   , 
                                  d_ctc93m03.atoflg   , 
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
 
 call ctc93m03_ler(d_ctc93m03.atdsrvorg,
                   d_ctc93m03.ciaempcod,
                   d_ctc93m03.avialgmtv)
         returning d_ctc93m03.*
 
 
 call ctc93m03_display(d_ctc93m03.*)

end function  ###  ctc93m03_dinclui

#--------------------------------------------------------------------
 function ctc93m03_input(param, d_ctc93m03)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define d_ctc93m03 record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes
end record

define l_cponom like iddkdominio.cponom

 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if

    input by name   d_ctc93m03.srvdcrcod,
                    d_ctc93m03.srvdcrdes,
                    d_ctc93m03.bemcod,
                    d_ctc93m03.bemdes,
                    d_ctc93m03.atoflg  ,
                    d_ctc93m03.atoflgdes     without defaults
              
       before field srvdcrcod                                       
          display by name d_ctc93m03.srvdcrcod attribute (reverse)   
                                                                  
      after  field srvdcrcod                                       
          display by name d_ctc93m03.srvdcrcod
          
          if d_ctc93m03.srvdcrcod  is null   then
              error " Decorrencia do Servico deve ser informada!"
              call ctn36c00("Decorrencia do Servico", "decservico")
                   returning  d_ctc93m03.srvdcrcod
              next field srvdcrcod
           end if
           
           let l_cponom = "decservico"
           
           open cctc93m03002 using  l_cponom,d_ctc93m03.srvdcrcod 
                                              
           fetch cctc93m03002 into d_ctc93m03.srvdcrdes 
            
           if sqlca.sqlcode  =  notfound   then
              error " Decorrencia do Servico nao cadastrada!"
              call ctn36c00("Decorrencia do Servico", "decservico")
                   returning  d_ctc93m03.srvdcrcod
              next field srvdcrcod
           end if
           display by name d_ctc93m03.srvdcrdes  
              
          
      before field srvdcrdes                                       
          display by name d_ctc93m03.srvdcrdes attribute (reverse)   
                                                                  
      after  field srvdcrdes                                       
          display by name d_ctc93m03.srvdcrdes  
          
      before field bemcod                                       
          display by name d_ctc93m03.bemcod attribute (reverse)   
                                                                  
      after  field bemcod                                       
          display by name d_ctc93m03.bemcod
          
          if d_ctc93m03.bemcod  is null   then
              error " Bem atendido deve ser informado!"
              call ctn36c00("Bem atendido", "bemAtendido")
                   returning  d_ctc93m03.bemcod
              next field bemcod
           end if

           let l_cponom = "bemAtendido"
           
           open cctc93m03002 using  l_cponom,d_ctc93m03.bemcod 
                                              
           fetch cctc93m03002 into d_ctc93m03.bemdes 
           
           if sqlca.sqlcode  =  notfound   then
              error " Bem atendido nao cadastrado!"
              call ctn36c00("Bem atendido", "bemAtendido")
                   returning  d_ctc93m03.bemcod
              next field bemcod
           end if
           display by name d_ctc93m03.bemdes  
          
          
          
      before field bemdes                                       
          display by name d_ctc93m03.bemdes attribute (reverse)   
                                                                  
      after  field bemdes                                       
          display by name d_ctc93m03.bemdes    
            
          
      before field atoflg                                       
          display by name d_ctc93m03.atoflg attribute (reverse)   
                                                                  
      after  field atoflg                                       
          display by name d_ctc93m03.atoflg 
          
          if d_ctc93m03.atoflg  is null   then
              error " Status de/para avialgmtv deve ser informado!"
              call ctn36c00("Status de/para avialgmtv", "De/Para_OrgMtv")
                   returning  d_ctc93m03.atoflg
              next field atoflg
           end if

           let l_cponom = "De/Para_OrgMtv"
           
           open cctc93m03002 using  l_cponom,d_ctc93m03.atoflg 
                                              
           fetch cctc93m03002 into d_ctc93m03.atoflgdes 
           
           if sqlca.sqlcode  =  notfound   then
              error " Status de/para avialgmtv nao cadastrado!"
              call ctn36c00("Status de/para avialgmtv", "De/Para_OrgMtv")
                   returning  d_ctc93m03.atoflg
              next field atoflg
           end if
           
           display by name d_ctc93m03.atoflgdes  
          
      before field atoflgdes                                       
          display by name d_ctc93m03.atoflgdes attribute (reverse)   
                                                                  
      after  field atoflgdes                                       
          display by name d_ctc93m03.atoflgdes                       
                                                                  
                                                                  
      on key (interrupt)                                          
        exit input                                              
            
 end input

 if int_flag   then
    initialize d_ctc93m03.*  to null
 end if

  return d_ctc93m03.*

end function  ###  ctc93m03_input


#---------------------------------------------------------
 function ctc93m03_ler(param)
#---------------------------------------------------------

 define param         record   
    atdsrvorg      like datkalgmtv.atdsrvorg,
    ciaempcod      like datkalgmtv.ciaempcod,
    avialgmtv      like datkalgmtv.avialgmtv
 end record

 define d_ctc93m03 record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    cadusrtip      like datkalgmtv.cadusrtip   ,
    cadempcod      like datkalgmtv.cadempcod   ,
    cadmat         like datkalgmtv.cadmat      ,
    caddat         like datkalgmtv.caddat      ,
    atlusrtip      like datkalgmtv.atlusrtip   ,
    atlempcod      like datkalgmtv.atlempcod   ,
    atlmat         like datkalgmtv.atlmat      ,
    atldat         like datkalgmtv.atldat      ,
    funcad         like isskfunc.funnom        ,
    funatl         like isskfunc.funnom
end record                 

define l_cpodes_emp  like iddkdominio.cpodes 
define l_cpodes      like iddkdominio.cpodes 
define l_cponom      like iddkdominio.cponom 

 initialize d_ctc93m03.*  to null   


 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if
 
     let d_ctc93m03.atdsrvorg = param.atdsrvorg
     let d_ctc93m03.ciaempcod = param.ciaempcod
     let d_ctc93m03.avialgmtv = param.avialgmtv
    
    open cctc93m03005 using  d_ctc93m03.atdsrvorg,  
                             d_ctc93m03.ciaempcod, 
                             d_ctc93m03.avialgmtv  
                             
    fetch cctc93m03005 into  d_ctc93m03.atdsrvorg,
                             d_ctc93m03.ciaempcod,
                             d_ctc93m03.avialgmtv,
                             d_ctc93m03.srvdcrcod,
                             d_ctc93m03.bemcod   ,
                             d_ctc93m03.atoflg   ,
                             d_ctc93m03.cadusrtip,
                             d_ctc93m03.cadempcod,
                             d_ctc93m03.cadmat   ,
                             d_ctc93m03.caddat   ,
                             d_ctc93m03.atlusrtip,
                             d_ctc93m03.atlempcod,
                             d_ctc93m03.atlmat   ,
                             d_ctc93m03.atldat   
    if sqlca.sqlcode  <> 0   then 
      initialize d_ctc93m03.* to null
      return d_ctc93m03.atdsrvorg   ,
             d_ctc93m03.srvtipabvdes,    
             d_ctc93m03.ciaempcod   ,
             d_ctc93m03.empsgl      ,
             d_ctc93m03.avialgmtv   ,
             d_ctc93m03.avialgmtvdes,
             d_ctc93m03.srvdcrcod   ,    
             d_ctc93m03.srvdcrdes   ,    
             d_ctc93m03.bemcod      ,    
             d_ctc93m03.bemdes      ,    
             d_ctc93m03.atoflg      ,    
             d_ctc93m03.atoflgdes   ,    
             d_ctc93m03.caddat      ,    
             d_ctc93m03.atldat      ,    
             d_ctc93m03.funcad      ,    
             d_ctc93m03.funatl        
   end if 
    call ctc93m01_func(d_ctc93m03.cadempcod,d_ctc93m03.cadmat,d_ctc93m03.cadusrtip)
     returning d_ctc93m03.funcad
  
    call ctc93m01_func(d_ctc93m03.atlempcod,d_ctc93m03.atlmat,d_ctc93m03.atlusrtip)
     returning d_ctc93m03.funatl
     
    open cctc93m03001 using  d_ctc93m03.ciaempcod  
    fetch cctc93m03001 into l_cpodes_emp 
          
    open cctc93m03002 using  l_cpodes_emp,d_ctc93m03.avialgmtv
    fetch cctc93m03002 into d_ctc93m03.avialgmtvdes
    
    open cctc93m03003 using  d_ctc93m03.atdsrvorg
    fetch cctc93m03003 into d_ctc93m03.srvtipabvdes    
    
    open cctc93m03004 using  d_ctc93m03.ciaempcod
    fetch cctc93m03004 into d_ctc93m03.empsgl 
    
    let l_cponom = "decservico"
    open cctc93m03002  using l_cponom,d_ctc93m03.srvdcrcod
    fetch cctc93m03002 into d_ctc93m03.srvdcrdes 
    close  cctc93m03002
          
    let l_cponom = "bemAtendido"
    open cctc93m03002  using l_cponom,d_ctc93m03.bemcod
    fetch cctc93m03002 into d_ctc93m03.bemdes 
    close  cctc93m03002
           
    let l_cponom = "De/Para_OrgMtv"
    open cctc93m03002  using l_cponom,d_ctc93m03.atoflg
    fetch cctc93m03002 into d_ctc93m03.atoflgdes  
    close  cctc93m03002
       
 return d_ctc93m03.atdsrvorg   ,
        d_ctc93m03.srvtipabvdes,    
        d_ctc93m03.ciaempcod   ,
        d_ctc93m03.empsgl      ,
        d_ctc93m03.avialgmtv   ,
        d_ctc93m03.avialgmtvdes,
        d_ctc93m03.srvdcrcod   ,    
        d_ctc93m03.srvdcrdes   ,    
        d_ctc93m03.bemcod      ,    
        d_ctc93m03.bemdes      ,    
        d_ctc93m03.atoflg      ,    
        d_ctc93m03.atoflgdes   ,    
        d_ctc93m03.caddat      ,    
        d_ctc93m03.funcad      ,    
        d_ctc93m03.atldat      ,    
        d_ctc93m03.funatl           


end function  ###  ctc93m03_ler


##---------------------------------------------------------
# function ctc93m03_func(param)
##---------------------------------------------------------
#
# define param         record
#    ciaempcod            like isskfunc.ciaempcod,
#    funmat            like isskfunc.funmat
# end record
#
# define ws            record
#    funnom            like isskfunc.funnom
# end record
#
#
# initialize ws.*    to null
#
# select funnom
#   into ws.funnom
#   from isskfunc
#  where isskfunc.ciaempcod = param.ciaempcod
#    and isskfunc.funmat = param.funmat
#
# return ws.funnom
#
#end function  ###  ctc93m03_func
#
#
#---------------------------------------------------------
 function ctc93m03_display(param)
#---------------------------------------------------------

 define param record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes,
    caddat         like datkalgmtv.caddat,
    funcad         like isskfunc.funnom,  
    atldat         like datkalgmtv.atldat,
    funatl         like isskfunc.funnom  
end record

 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if

  display by name param.atdsrvorg
  display by name param.srvtipabvdes
  display by name param.avialgmtv     
  display by name param.avialgmtvdes 
  display by name param.ciaempcod
  display by name param.empsgl
  display by name param.srvdcrcod  
  display by name param.srvdcrdes
  display by name param.bemcod
  display by name param.bemdes
  display by name param.atoflg  
  display by name param.atoflgdes
  display by name param.caddat 
  display by name param.funcad 
  display by name param.atldat
  display by name param.funatl  
  
 
# if param.avialgmtv is not null and param.avialgmtv <> 0 then
#       
#      whenever error continue  
#           	
#    select srvtipabvdes                 
#  	  into param.srvtipabvdes            
#      from datksrvtip                   
#     where atdsrvorg =  param.avialgmtv 
#     whenever error stop 	
#
#      if sqlca.sqlcode  = 0   then      	
#	      display by name  param.srvtipabvdes attribute (reverse)	 
#      else 
#        let param.srvtipabvdes = " "
#	      display by name  param.srvtipabvdes 
#      end if	
# end if 
 
end function  ###  ctc93m03_display


#------------------------------------------------------------
function ctc93m03_grava_hist(lr_param)
#------------------------------------------------------------

   define lr_param record
          atdsrvorg  like datkalgmtv.atdsrvorg
         ,ciaempcod  like datkalgmtv.ciaempcod
         ,avialgmtv  like datkalgmtv.avialgmtv
         ,mensagem   char(3000)
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
       display "lr_param.mensagem :",lr_param.mensagem   clipped     
       display "l_usrtip          :",l_usrtip    
       display "l_empcod          :",l_empcod    
       display "l_funmat          :",l_funmat
       display "l_datatime        :",l_datatime    
       
    whenever error continue  
       insert into datkalgmtvhst values (lr_param.atdsrvorg,
                                         lr_param.ciaempcod,
                                         lr_param.avialgmtv,
                                         l_datatime,
                                         lr_param.mensagem,
                                         l_usrtip,   
                                         l_empcod,  
                                         l_funmat) 
       if sqlca.sqlcode = 0 then       
           let l_stt = true
        else
            error 'Erro na gravacao do historico' sleep 2
           let l_stt = false    
        end if  
     whenever error stop
   end for      
 return l_stt

end function

#---------------------------------------------------------
function ctc93m03_verifica_mod(lr_ctc93m03_ant,lr_ctc93m03)
#---------------------------------------------------------

  define lr_ctc93m03_ant record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes
end record              
                                
  define lr_ctc93m03 record    
    atdsrvorg      like datkalgmtv.atdsrvorg,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    ciaempcod      like datkalgmtv.ciaempcod,
    empsgl         like gabkemp.empsgl,
    avialgmtv      like datkalgmtv.avialgmtv,
    avialgmtvdes   like iddkdominio.cpodes,
    srvdcrcod      like datkalgmtv.srvdcrcod,
    srvdcrdes      like iddkdominio.cpodes,
    bemcod         like datkalgmtv.bemcod,
    bemdes         like iddkdominio.cpodes,
    atoflg         like datkalgmtv.atoflg,
    atoflgdes      like iddkdominio.cpodes
end record               

  define l_mesg char(500)
  define l_atldat date

 if m_ctc93m03_prep is null or
    m_ctc93m03_prep <> true then
    call ctc93m03_prepare()
 end if
 
   
  #let l_atldat = today
  
   if (lr_ctc93m03_ant.srvdcrcod is null     and lr_ctc93m03.srvdcrcod is not null) or
      (lr_ctc93m03_ant.srvdcrcod is not null and lr_ctc93m03.srvdcrcod is null)     or
      (lr_ctc93m03_ant.srvdcrcod              <> lr_ctc93m03.srvdcrcod)             then
      let l_mesg = "Decorrencia do servico foi alterada de [",lr_ctc93m03_ant.srvdcrcod using '<<<',"-",
      lr_ctc93m03_ant.srvdcrdes clipped,"] para [",lr_ctc93m03.srvdcrcod using '<<<', "-",
      lr_ctc93m03.srvdcrdes clipped,"]"

      if not ctc93m03_grava_hist(lr_ctc93m03.atdsrvorg,
                                 lr_ctc93m03.ciaempcod,
                                 lr_ctc93m03.avialgmtv,
                                 l_mesg,
                                 l_atldat) then

         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

   if (lr_ctc93m03_ant.bemcod is null     and lr_ctc93m03.bemcod is not null) or
      (lr_ctc93m03_ant.bemcod is not null and lr_ctc93m03.bemcod is null)     or
      (lr_ctc93m03_ant.bemcod              <> lr_ctc93m03.bemcod)             then
      let l_mesg = "Bem atendido alterado de [",lr_ctc93m03_ant.bemcod using '<<<',"-",
      lr_ctc93m03_ant.bemdes clipped,"] para [",lr_ctc93m03.bemcod using '<<<', "-",
      lr_ctc93m03.bemdes clipped,"]"

     if not ctc93m03_grava_hist(lr_ctc93m03.atdsrvorg,
                                 lr_ctc93m03.ciaempcod,
                                 lr_ctc93m03.avialgmtv,
                                 l_mesg,
                                 l_atldat) then

         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

   if (lr_ctc93m03_ant.atoflg is null     and lr_ctc93m03.atoflg is not null) or
      (lr_ctc93m03_ant.atoflg is not null and lr_ctc93m03.atoflg is null)     or
      (lr_ctc93m03_ant.atoflg              <> lr_ctc93m03.atoflg)             then
      let l_mesg = "Situacao alterado de [",lr_ctc93m03_ant.atoflg using '<<<' ,"-",
          lr_ctc93m03_ant.atoflgdes clipped,"] para [",lr_ctc93m03.atoflg using '<<<',"-",
          lr_ctc93m03.atoflgdes clipped,"]"

      if not ctc93m03_grava_hist(lr_ctc93m03.atdsrvorg,
                                 lr_ctc93m03.ciaempcod,
                                 lr_ctc93m03.avialgmtv,
                                 l_mesg,
                                 l_atldat) then

         let l_mesg     = "Erro gravacao Historico "
      end if

   end if

end function
