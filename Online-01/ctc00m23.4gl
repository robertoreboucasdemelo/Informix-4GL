#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : ctc00m23                                                       #
# Programa   : Manutenção do cad de Config Gerenciamento de especialidades    #
#                          - Porto Socorro -                                  #
#-----------------------------------------------------------------------------#
# anlnom Resp.   : Robert Lima                                                #
# PSI            : PSI03339EV                                                 #
#                                                                             #
# Desenvolvedor  : Robert Lima                                                #
# DATA           : 20/12/2010                                                 #
#.............................................................................#
# Data        Autor        Alteracao                                          #
#                                                                             #
# ----------  -----------  ---------------------------------------------------#
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_ctc00m23 record
     espcnfcod    like datkesp.espcnfcod   ,
     vcldtbgrpcod like datkesp.vcldtbgrpcod,
     socvcltip    like datkesp.socvcltip   ,
     asitipcod    like datkesp.asitipcod   ,
     caddat       like datkesp.caddat      ,
     cadhor       like datkesp.cadhor      ,
     cadmat       like datkesp.cadmat      ,
     cademp       like datkesp.cademp      ,
     cadusrtip    like datkesp.cadusrtip   ,
     atlmat       like datkesp.atlmat      ,
     atldat       like datkesp.atldat      ,
     atlhor       like datkesp.atlhor      ,
     atlemp       like datkesp.atlemp      ,
     atlusrtip    like datkesp.atlusrtip
end record

define m_ctc00m23_prep smallint

#----------------------------------------------
function ctc00m23()
#----------------------------------------------

 open window w_ctc00m23 AT 4,2 with form "ctc00m23"
              attribute (border)

 menu "Gerenciamento especialidades"

    command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
          call ctc00m23_seleciona()
          next option "Proximo"	

    command key ("P") "Proximo" "Mostra proximo registro selecionado"
          message ""
          if m_ctc00m23.espcnfcod is not null then
             call ctc00m23_proximo()
          else
             error "NAO HA' MAIS REGISTROS NESTA DIRECAO!"
             next option "Seleciona"
          end if

    command key ("A") "Anterior" "Mostra registro anterior selecionado"
          message ""
          if m_ctc00m23.espcnfcod is not null then
             call ctc00m23_anterior()
          else
             error "NAO HA' MAIS REGISTROS NESTA DIRECAO!"
             next option "Seleciona"
          end if

    command key ("I") "Inclui" "Inclui Registro na Tabela"
          call ctc00m23_inclui()

    command key ("M") "Modifica" "Modifica registro corrente selecionado"
          if m_ctc00m23.espcnfcod is null then
             error "NENHUM CADASTRO SELECIONADO"
             next option "Seleciona"
          else
             call ctc00m23_modifica()
          end if

    command key ("X") "eXclui" "Exclui registro corrente selecionado"
          if m_ctc00m23.espcnfcod is null then
             error "NENHUM CADASTRO SELECIONADO"
             next option "Seleciona"
          else
             call ctc00m23_exclui()
          end if

    command key ("E",interrupt)"Encerra" "Retorna ao menu anterior"
          exit menu
 end menu

 close window w_ctc00m23

end function

#----------------------------------------------
function ctc00m23_prepare()
#----------------------------------------------

 define l_sql char(500)
 
 #------[BUSCA OS DADOS DA TABELA PRINCIPAL]----
 let l_sql = "select espcnfcod     ,",
             "       vcldtbgrpcod  ,",
             "       socvcltip     ,",
             "       asitipcod     ,",
             "       caddat        ,",
             "       cadhor        ,",
             "       cadmat        ,",
             "       cademp        ,",
             "       cadusrtip     ,",
             "       atlmat        ,",
             "       atldat        ,",
             "       atlhor        ,",
             "       atlemp        ,",
             "       atlusrtip      ",
             "  from datkesp        ",
             " where espcnfcod = ? "
 prepare pctc00m23001 from l_sql
 declare cctc00m23001 cursor for pctc00m23001
 
 #------[BUSCA O GRUPO DE DISTRIBUIÇÃO]---
 let l_sql = "select vcldtbgrpdes    ",
             "  from datkvcldtbgrp   ",
             " where vcldtbgrpcod = ?"
 prepare pctc00m23002 from l_sql
 declare cctc00m23002 cursor for pctc00m23002
 
 #------[BUSCA TIPO DE ASSISTÊNCIA]----
 let l_sql = "select asitipdes    ",
             "  from datkasitip   ",
             " where asitipcod = ?"
 prepare pctc00m23003 from l_sql
 declare cctc00m23003 cursor for pctc00m23003

 #------[BUSCA TIPO DO VEICULO DO SOCRRISTA]---- 
 let l_sql = "select cpodes               ",
             "  from iddkdominio          ",
             " where cponom = 'socvcltip' ",
             "   and cpocod = ?           "
 prepare pctc00m23004 from l_sql
 declare cctc00m23004 cursor for pctc00m23004

 #------[BUSCA ULTIMO SEQUENCIAL E A FLAG PARA O ACIONAMENTO AUTOMATICO]----
 let l_sql = "select hstseq,atmacnflg                    ",
             "  from datmespctrhst                       ",
             " where espcnfcod = ?                       ",
             "   and hstseq =(select max(hstseq)         ",
             "                        from datmespctrhst ",
             "                       where espcnfcod = ?)"
 prepare pctc00m23005 from l_sql
 declare cctc00m23005 cursor for pctc00m23005

 #------[BUSCA CONFIGURACAO DA ESPECIALIDADE PELO GRP_ACN, VCLTIP e ASISTENCIA]----
 let l_sql = "select espcnfcod from datkesp ",
             " where vcldtbgrpcod = ? ",
             "   and socvcltip    = ? ",
             "   and asitipcod    = ? "
 prepare pctc00m23006 from l_sql
 declare cctc00m23006 cursor for pctc00m23006

 #------[BUSCA FLAG DE ACN AUTOMATICO DA CONFIGURACAO DA ESPECIALIDADE]----
 let l_sql = "select hst.atmacnflg ",
              " from datmespctrhst hst ",
             " where hst.espcnfcod = ? ", 
               " and hstseq = (select max(ult.hstseq) ",
                               " from datmespctrhst ult ",
                               " where ult.espcnfcod = hst.espcnfcod)"
 prepare pctc00m23007 from l_sql
 declare cctc00m23007 cursor for pctc00m23007

 let m_ctc00m23_prep = true

end function

#----------------------------------------------
function ctc00m23_seleciona()
#----------------------------------------------

 define l_cadfunnom     like isskfunc.funnom,
        l_vcldtbgrpdes  like datkvcldtbgrp.vcldtbgrpdes,
        l_cpodes        like iddkdominio.cpodes,
        l_asitipdes     like datkasitip.asitipdes,
        l_resultado     smallint

 clear form
 let int_flag = false

 if m_ctc00m23_prep <> true then
    call ctc00m23_prepare()
 end if

 initialize m_ctc00m23.*   to null
 initialize l_cadfunnom    to null
 initialize l_vcldtbgrpdes to null
 initialize l_cpodes       to null
 initialize l_asitipdes    to null

 input by name m_ctc00m23.espcnfcod

       before field espcnfcod
          display by name m_ctc00m23.espcnfcod attribute(reverse)

       after field espcnfcod
          display by name m_ctc00m23.espcnfcod

          if m_ctc00m23.espcnfcod is null or m_ctc00m23.espcnfcod = "" then
             let m_ctc00m23.espcnfcod = 1
          end if

       whenever error continue

       open cctc00m23001 using m_ctc00m23.espcnfcod

       fetch cctc00m23001 into m_ctc00m23.espcnfcod,
                               m_ctc00m23.vcldtbgrpcod,
                               m_ctc00m23.socvcltip   ,
                               m_ctc00m23.asitipcod   ,
                               m_ctc00m23.caddat      ,
                               m_ctc00m23.cadhor      ,
                               m_ctc00m23.cadmat      ,
                               m_ctc00m23.cademp      ,
                               m_ctc00m23.cadusrtip   ,
                               m_ctc00m23.atlmat      ,
                               m_ctc00m23.atldat      ,
                               m_ctc00m23.atlhor      ,
                               m_ctc00m23.atlemp      ,
                               m_ctc00m23.atlusrtip
       
       if sqlca.sqlcode  =  notfound then
         error "NENHUM CADASTRO ENCONTRADO"
         initialize m_ctc00m23.* to null
         close cctc00m23001
         return
       end if
       
       close cctc00m23001
       whenever error stop

       on key (interrupt)
             exit input

 end input

 if int_flag  then
    let int_flag = false
    initialize m_ctc00m23.*   to null
    error "OPERACAO CANCELADA!"
    return
 end if

 display by name  m_ctc00m23.espcnfcod,
                  m_ctc00m23.vcldtbgrpcod,
                  m_ctc00m23.socvcltip   ,
                  m_ctc00m23.asitipcod   ,
                  m_ctc00m23.caddat      ,
                  m_ctc00m23.cadhor      ,
                  m_ctc00m23.atldat      ,
                  m_ctc00m23.atlhor

 call ctc00m22_func(m_ctc00m23.cademp, m_ctc00m23.cadmat)
      returning l_cadfunnom 
 display l_cadfunnom to cadmat
 
 call ctc00m22_func(m_ctc00m23.atlemp, m_ctc00m23.atlmat)
      returning l_cadfunnom 
 display l_cadfunnom to atlmat 
 
 whenever error continue
   call ctc00m23_obter_des_ges_espe(m_ctc00m23.vcldtbgrpcod,
                                    m_ctc00m23.asitipcod,
                                    m_ctc00m23.socvcltip)
        returning l_resultado,
                  l_vcldtbgrpdes,
                  l_cpodes,
                  l_asitipdes
                  
 whenever error stop
 
 if l_resultado = 0 then
    display l_vcldtbgrpdes to vcldtbgrpdes
    display l_asitipdes    to asitipdes
    display l_cpodes       to cpodes 
 else
    initialize m_ctc00m23.* to null
    error "ERRO AO BUSCAR DADOS"
    clear form
 end if

end function

#-----------------------------------------------------------
function ctc00m23_proximo()
#-----------------------------------------------------------

  define l_espcnfcod decimal(2,0)
  define l_cadfunnom     like isskfunc.funnom,
         l_vcldtbgrpdes  like datkvcldtbgrp.vcldtbgrpdes,
         l_cpodes        like iddkdominio.cpodes,
         l_asitipdes     like datkasitip.asitipdes,
         l_resultado     smallint 

  let l_espcnfcod = m_ctc00m23.espcnfcod

  if m_ctc00m23_prep <> true then
     call ctc00m23_prepare()     
  end if                 
          
  whenever error continue
  
  select min (espcnfcod)
    into l_espcnfcod
    from datkesp  
   where espcnfcod > m_ctc00m23.espcnfcod

  if l_espcnfcod is not null then
     open cctc00m23001 using l_espcnfcod
       
     fetch cctc00m23001 into m_ctc00m23.espcnfcod   ,
                             m_ctc00m23.vcldtbgrpcod,
                             m_ctc00m23.socvcltip   ,
                             m_ctc00m23.asitipcod   ,
                             m_ctc00m23.caddat      ,
                             m_ctc00m23.cadhor      ,
                             m_ctc00m23.cadmat      ,
                             m_ctc00m23.cademp      ,
                             m_ctc00m23.cadusrtip   ,
                             m_ctc00m23.atlmat      ,
                             m_ctc00m23.atldat      ,
                             m_ctc00m23.atlhor      ,
                             m_ctc00m23.atlemp      ,
                             m_ctc00m23.atlusrtip
     close cctc00m23001
     
     display by name  m_ctc00m23.espcnfcod   ,
                      m_ctc00m23.vcldtbgrpcod,
                      m_ctc00m23.socvcltip   ,
                      m_ctc00m23.asitipcod   ,
                      m_ctc00m23.caddat      ,
                      m_ctc00m23.cadhor      ,
                      m_ctc00m23.atldat      ,
                      m_ctc00m23.atlhor       
                            
                             
  end if

  if l_espcnfcod  is null   or
     sqlca.sqlcode  =  notfound      then
     error "NAO HA' MAIS REGISTROS NESTA DIRECAO!"
     return
  end if
  
  whenever error stop
  
  call ctc00m22_func(m_ctc00m23.cademp, m_ctc00m23.cadmat)
     returning l_cadfunnom 
  display l_cadfunnom to cadmat
 
  call ctc00m22_func(m_ctc00m23.atlemp, m_ctc00m23.atlmat)
     returning l_cadfunnom 
  display l_cadfunnom to atlmat 
 
 whenever error continue
   call ctc00m23_obter_des_ges_espe(m_ctc00m23.vcldtbgrpcod,
                                    m_ctc00m23.asitipcod,
                                    m_ctc00m23.socvcltip)
     returning l_resultado,
               l_vcldtbgrpdes,
               l_asitipdes,
               l_cpodes
 whenever error stop
 
 if l_resultado = 0 then
    display l_vcldtbgrpdes to vcldtbgrpdes
    display l_asitipdes    to asitipdes
    display l_cpodes       to cpodes 
 else
    initialize m_ctc00m23.* to null
    error "ERRO AO BUSCAR DADOS"
    clear form
 end if 
  
end function

#-----------------------------------------------------------
function ctc00m23_anterior()
#-----------------------------------------------------------                            
                            
 define l_espcnfcod     like dpakprsgstcdi.gstcdicod
 define l_cadfunnom     like isskfunc.funnom,
        l_vcldtbgrpdes  like datkvcldtbgrp.vcldtbgrpdes,
        l_cpodes        like iddkdominio.cpodes,
        l_asitipdes     like datkasitip.asitipdes,
        l_resultado     smallint 

 let l_espcnfcod = m_ctc00m23.espcnfcod

  if m_ctc00m23_prep <> true then
     call ctc00m23_prepare()     
  end if                         

  whenever error continue
  select max (espcnfcod)
    into l_espcnfcod
    from datkesp  
   where espcnfcod < m_ctc00m23.espcnfcod
   
  if l_espcnfcod is not null then
     open cctc00m23001 using l_espcnfcod
       
     fetch cctc00m23001 into m_ctc00m23.espcnfcod   ,
                             m_ctc00m23.vcldtbgrpcod,
                             m_ctc00m23.socvcltip   ,
                             m_ctc00m23.asitipcod   ,
                             m_ctc00m23.caddat      ,
                             m_ctc00m23.cadhor      ,
                             m_ctc00m23.cadmat      ,
                             m_ctc00m23.cademp      ,
                             m_ctc00m23.cadusrtip   ,
                             m_ctc00m23.atlmat      ,
                             m_ctc00m23.atldat      ,
                             m_ctc00m23.atlhor      ,
                             m_ctc00m23.atlemp      ,
                             m_ctc00m23.atlusrtip
     close cctc00m23001
     
     display by name  m_ctc00m23.espcnfcod   ,
                      m_ctc00m23.vcldtbgrpcod,
                      m_ctc00m23.socvcltip   ,
                      m_ctc00m23.asitipcod   ,
                      m_ctc00m23.caddat      ,
                      m_ctc00m23.cadhor      ,
                      m_ctc00m23.atldat      ,
                      m_ctc00m23.atlhor       
                            
                             
  end if

  if l_espcnfcod  is null   or
     sqlca.sqlcode  =  notfound      then
     error "NAO HA' MAIS REGISTROS NESTA DIRECAO!"
  end if
  
  whenever error stop
  
  call ctc00m22_func(m_ctc00m23.cademp, m_ctc00m23.cadmat)
     returning l_cadfunnom 
  display l_cadfunnom to cadmat
 
  call ctc00m22_func(m_ctc00m23.atlemp, m_ctc00m23.atlmat)
     returning l_cadfunnom 
  display l_cadfunnom to atlmat 
 
 whenever error continue
    call ctc00m23_obter_des_ges_espe(m_ctc00m23.vcldtbgrpcod,
                                     m_ctc00m23.asitipcod,
                                     m_ctc00m23.socvcltip)
        returning l_resultado,
                  l_vcldtbgrpdes,
                  l_asitipdes,
                  l_cpodes
 whenever error stop
 
 if l_resultado = 0 then
    display l_vcldtbgrpdes to vcldtbgrpdes
    display l_asitipdes    to asitipdes
    display l_cpodes       to cpodes 
 else
    initialize m_ctc00m23.* to null
    error "ERRO AO BUSCAR DADOS"
    clear form
 end if
  
end function

#-----------------------------------------------------------
function ctc00m23_input()
#-----------------------------------------------------------

 define l_cadfunnom     like isskfunc.funnom,
        l_vcldtbgrpdes  like datkvcldtbgrp.vcldtbgrpdes,
        l_cpodes        like iddkdominio.cpodes,
        l_asitipdes     like datkasitip.asitipdes,
        l_sql           char(100),
        vl_result       smallint

   input by name m_ctc00m23.vcldtbgrpcod,
                 m_ctc00m23.socvcltip      ,
                 m_ctc00m23.asitipcod without defaults
                 
         before field vcldtbgrpcod
             display by name m_ctc00m23.vcldtbgrpcod attribute(reverse)

         after field vcldtbgrpcod
             display by name m_ctc00m23.vcldtbgrpcod
                                                                              
             if m_ctc00m23.vcldtbgrpcod is null or m_ctc00m23.vcldtbgrpcod = "" then
                error "CAMPO GRP DE DISTRINUICAO E' OBRIGATORIO"
                call ctn39c00()
                  returning m_ctc00m23.vcldtbgrpcod
                  
                open cctc00m23002 using m_ctc00m23.vcldtbgrpcod  
                fetch cctc00m23002 into l_vcldtbgrpdes 
                close cctc00m23002                     
                
                next field vcldtbgrpcod
             else
                whenever error continue 
                open cctc00m23002 using m_ctc00m23.vcldtbgrpcod
                fetch cctc00m23002 into l_vcldtbgrpdes   
                
                
                if sqlca.sqlcode = notfound then   
                   error "GRUPO DE DISTRINUICAO NAO ENCONTRADO" 
                   display "" to vcldtbgrpdes
                   next field vcldtbgrpcod	
                end if
                close cctc00m23002
                whenever error stop
                display l_vcldtbgrpdes to vcldtbgrpdes          
             end if
             
         before field socvcltip
             display by name m_ctc00m23.socvcltip attribute(reverse)
         
         after field socvcltip
             display by name m_ctc00m23.socvcltip
             
             if fgl_lastkey() = fgl_keyval("up")    or 
                fgl_lastkey() = fgl_keyval("left") then
                next field vcldtbgrpcod                      
             end if                                    
             
             if m_ctc00m23.socvcltip is null or m_ctc00m23.socvcltip = "" then
                error "CAMPO TIPO DE VIATURA E' OBRIGATORIO"
                
                
                let l_sql = " select cpocod, cpodes from iddkdominio ",
                            " where cponom = 'socvcltip' "

                call ofgrc001_popup ( 8
                                    ,12
                                    ,"CONSULTA TIPO VEICULO"
                                    ,"Codigo"
                                    ,"Descricao"
                                    ,"N"
                                    ,l_sql
                                    ,""
                                    ,"D" )
                   returning vl_result
                            ,m_ctc00m23.socvcltip
                            ,l_cpodes

                if vl_result = 1 then
                   error "NENHUM TIPO EQUIPAMENTO SELECIONADO!"
                   next field socvcltip
                end if
             else
                whenever error continue
                open cctc00m23004 using m_ctc00m23.socvcltip
                fetch cctc00m23004 into l_cpodes
                
                if sqlca.sqlcode = notfound then
                   error "TIPO DE EQUIPAMENTO NAO ENCONTRADO!"
                   display "" to cpodes 
                   next field socvcltip
                end if
                
                close cctc00m23004
                whenever error stop
             end if
             
             display l_cpodes to cpodes   
       
         before field asitipcod                                     
             display by name m_ctc00m23.asitipcod attribute(reverse)
                                                                 
         after field asitipcod                                      
             display by name m_ctc00m23.asitipcod
             
             if fgl_lastkey() = fgl_keyval("up")    or 
                fgl_lastkey() = fgl_keyval("left") then
                next field socvcltip                      
             end if               
             
             if m_ctc00m23.asitipcod is null or m_ctc00m23.asitipcod = "" then             
                error "CAMPO ASSISTENCIA E' OBRIGATORIO"
                
                call ctn25c00("")
                  returning m_ctc00m23.asitipcod
                  
                open cctc00m23003 using m_ctc00m23.asitipcod
                fetch cctc00m23003 into l_asitipdes
                close cctc00m23003
                
                next field asitipcod
             else 
                whenever error continue
                open cctc00m23003 using m_ctc00m23.asitipcod
                fetch cctc00m23003 into l_asitipdes
                
                if sqlca.sqlcode = notfound then
                   error "ASSISTENCIA NAO CADASTRADA!"
                   display "" to asitipdes
                   next field asitipcod
                end if
                
                close cctc00m23003
                whenever error continue
                display l_asitipdes to asitipdes  
             end if  
             
         on key(f17,interrupt)               
            exit input 
   end input
end function

#-----------------------------------------------------------
function ctc00m23_inclui()
#-----------------------------------------------------------

 define l_cadfunnom like isskfunc.funnom
 define l_data      date
 define l_hora      datetime hour to second
 
 clear form
 initialize m_ctc00m23.* to null
 let l_cadfunnom = null
 
 if m_ctc00m23_prep <> true then
    call ctc00m23_prepare()     
 end if
 
 call ctc00m23_input()
 
 if int_flag then
  let int_flag = false
  initialize m_ctc00m23.* to null
  error "OPERACAO CANCELADA!"
  clear form                  
  return
 end if
 
 whenever error continue
 
 select max(espcnfcod)
   into m_ctc00m23.espcnfcod
   from datkesp
   
  if m_ctc00m23.espcnfcod is null or
     m_ctc00m23.espcnfcod = " "   then
     let m_ctc00m23.espcnfcod = 1
  else
     let m_ctc00m23.espcnfcod = m_ctc00m23.espcnfcod + 1
  end if
  
  begin work

     insert 
       into datkesp(espcnfcod,
                    vcldtbgrpcod,
                    socvcltip      ,
                    asitipcod   ,
                    caddat      ,
                    cadhor      ,
                    cadmat      ,
                    cademp      ,
                    cadusrtip   ,
                    atlmat      ,
                    atldat      ,
                    atlhor      ,
                    atlemp      ,
                    atlusrtip)
            values (m_ctc00m23.espcnfcod,
                    m_ctc00m23.vcldtbgrpcod,
                    m_ctc00m23.socvcltip   ,
                    m_ctc00m23.asitipcod   ,
                    today,
                    current,
                    g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip,
                    g_issk.funmat,
                    today,
                    current,
                    g_issk.empcod,
                    g_issk.usrtip)
       
     if sqlca.sqlcode <> 0 then                                   
      error 'Erro INSERT / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5] 
      sleep 2                                                     
      error 'CTC00M23 / ctc00m23_inclui() '  sleep 2
      display "erro"
      rollback work
      return
     end if 
     
     insert 
       into datmespctrhst(espcnfcod,
                               hstseq,
                               atlmat,
                               atlemp,
                               atlusrtip   ,
                               atldat      ,
                               atlhor      ,
                               atmacnflg)
                       values (m_ctc00m23.espcnfcod,
                               1,
                               g_issk.funmat,
                               g_issk.empcod,
                               g_issk.usrtip,
                               today,
                               current,
                               'S')
                               
     if sqlca.sqlcode <> 0 then                                   
      error 'Erro INSERT / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5] 
      sleep 2                                                     
      error 'CTC00M23 / ctc00m23_inclui() '  sleep 2
      display "erro 2"
      rollback work
      return
     else
      error 'CONFIGURACAO CADASTRADA COM SUCESSO'
      display by name m_ctc00m23.espcnfcod
     end if
                   
  commit work 
  
  call ctc00m22_func(g_issk.empcod, g_issk.funmat)
       returning l_cadfunnom
          
  display l_cadfunnom to cadmat
  display l_cadfunnom to atlmat
  let l_data = today  
  let l_hora = current
  display l_data to caddat 
  display l_data to atldat
  display l_hora to cadhor
  display l_hora to atlhor 
  
 whenever error stop                 
 
end function

#-----------------------------------------------------------
function ctc00m23_modifica()
#-----------------------------------------------------------

 define l_cadfunnom like isskfunc.funnom
 define l_data      date
 define l_hora      datetime hour to second
 
 let l_cadfunnom = null
 
 if m_ctc00m23_prep <> true then
    call ctc00m23_prepare()     
 end if
 
 call ctc00m23_input()
 
 if int_flag then
  let int_flag = false
  initialize m_ctc00m23.* to null
  error "OPERACAO CANCELADA!"
  clear form                  
  return
 end if
 
 whenever error continue
  
  begin work

     update datkesp
            set (vcldtbgrpcod,
                 socvcltip      ,
                 asitipcod   ,
                 atlmat      ,
                 atldat      ,
                 atlhor      ,
                 atlemp      ,
                 atlusrtip)
             =       
                (m_ctc00m23.vcldtbgrpcod,
                 m_ctc00m23.socvcltip      ,
                 m_ctc00m23.asitipcod   ,
                 g_issk.funmat,
                 today,
                 current,
                 g_issk.empcod,
                 g_issk.usrtip)
      where espcnfcod = m_ctc00m23.espcnfcod

     if sqlca.sqlcode <> 0 then                                   
      error 'Erro UPDATE / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5] 
      sleep 2                                                     
      error 'CTC00M23 / ctc00m23_modifica() '  sleep 2
      rollback work
      return
     else
      error 'CONFIGURACAO ALTERADA COM SUCESSO'
     end if                           
                   
  commit work 
  
  call ctc00m22_func(g_issk.empcod, g_issk.funmat)
       returning l_cadfunnom
          
  display l_cadfunnom to atlmat
  let l_data = today  
  let l_hora = current
  display l_data to atldat
  display l_hora to atlhor 
  
 whenever error stop                 
 
end function

#---------------------------------------------- 
function ctc00m23_exclui()                             
#----------------------------------------------                         

 define l_confirmacao char(1)

 call cts08g01('C','S',"","CONFIRMA A EXCLUSAO DESTA","CONFIGURACAO DE ","GESTAO DE ESPECIALIDADES?")
      returning l_confirmacao
 
 if l_confirmacao = 'S' then
    whenever error continue
    clear form
    
     begin work
     
        delete from datkesp
         where espcnfcod = m_ctc00m23.espcnfcod
                         
        if sqlca.sqlcode <> 0 then                                   
         error 'Erro DELETE / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5] 
         sleep 2                                                     
         error 'CTC00M23 / ctc00m23_exclui() '  sleep 2
         rollback work
         return
        end if 
        
        delete from datmespctrhst
         where espcnfcod = m_ctc00m23.espcnfcod
         
        if sqlca.sqlcode <> 0 then                                   
         error 'Erro DELETE / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5] 
         sleep 2                                                     
         error 'CTC00M23 / ctc00m23_exclui() '  sleep 2
         rollback work
         return
        else
         error 'CONFIGURACAO DELETADA COM SUCESSO'
        end if 
                                                            
     commit work
     initialize m_ctc00m23.* to null 
     
    whenever error stop
 else
    error "OPERACAO CANCELADA!"
 end if
 
end function

#----------------------------------------------   
function ctc00m23_obter_des_ges_espe(param)                        
#----------------------------------------------  

 define param record
    vcldtbgrpcod like datkvcldtbgrp.vcldtbgrpcod,
    asitipcod    like datkasitip.asitipcod,
    socvcltip    like datkesp.socvcltip
 end record
 
 define l_vcldtbgrpdes  like datkvcldtbgrp.vcldtbgrpdes,
        l_cpodes        like iddkdominio.cpodes,
        l_asitipdes     like datkasitip.asitipdes,
        l_result        smallint,
        l_sql char(500)
 
 initialize l_vcldtbgrpdes to null
 initialize l_cpodes       to null      
 initialize l_asitipdes    to null 
 let l_result = 0
 
 if m_ctc00m23_prep <> true then
    call ctc00m23_prepare()     
 end if  
 
  whenever error continue                          
    open cctc00m23002 using param.vcldtbgrpcod
    fetch cctc00m23002 into l_vcldtbgrpdes         
    close cctc00m23002
    if sqlca.sqlcode = notfound then
       let l_result = 1
    end if 
    
    open cctc00m23003 using param.asitipcod
    fetch cctc00m23003 into l_asitipdes
    close cctc00m23003
    if sqlca.sqlcode = notfound then
       let l_result = 1
    end if
                                                   
    open cctc00m23004 using param.socvcltip
    fetch cctc00m23004 into l_cpodes
    close cctc00m23004
    
    if sqlca.sqlcode = notfound then
       let l_result = 1
    end if 
  whenever error stop                              

 return l_result,
        l_vcldtbgrpdes,
        l_cpodes,
        l_asitipdes  

end function 
  
#----------------------------------------------
function ctc00m23_altera_chave(param)
#----------------------------------------------
  
  define param record
    espcnfcod   like datkesp.espcnfcod,
    hstseq   like datmespctrhst.hstseq,
    atmacnflg     char(3)
  end record
  
  define l_flag     char(3)
  define l_confirmacao char(50)
  define l_msg char(50)
  
  
  let l_flag = param.atmacnflg
  if param.atmacnflg = "OFF" then
     let param.atmacnflg = 'S'
     let l_confirmacao = "CONFIRMA A ATIVACAO DO ACIONAMENTO"
  else
     let param.atmacnflg = 'N'
     let l_confirmacao = "CONFIRMA A DESATIVACAO DO ACIONAMENTO"
  end if
  
  let param.hstseq = param.hstseq + 1
  
  call cts08g01('C','S',"",l_confirmacao clipped,"AUTOMATICO DESTA CONFIGURACAO? ","")
      returning l_confirmacao
 
  if l_confirmacao = 'S' then

     begin work
       insert 
            into datmespctrhst(espcnfcod,
                               hstseq,
                               atlmat,
                               atlemp,
                               atlusrtip   ,
                               atldat      ,
                               atlhor      ,
                               atmacnflg)
                       values (param.espcnfcod,
                               param.hstseq,
                               g_issk.funmat,
                               g_issk.empcod,
                               g_issk.usrtip,
                               today,
                               current,
                               param.atmacnflg)
     
        if sqlca.sqlcode <> 0 then
           error 'Erro INSERT / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[5]
           sleep 2
           error ' CTC00M23 / ctc00m23_altera_chave() '  sleep 2
           rollback work
           return 1,l_flag,param.hstseq
        else
           error 'CHAVE ALTERADA COM SUCESSO'
        end if
        
     commit work 
     
     if param.atmacnflg = 'N' then
        let param.atmacnflg = 'OFF'
     else
        let param.atmacnflg = 'ON'
     end if 
     
     return 0,param.atmacnflg,param.hstseq
  else
     return 1,l_flag,param.hstseq   
  end if

end function

#----------------------------------------------
function ctc00m23_acionamento_auto(param)          
#----------------------------------------------

 define param record
    vcldtbgrpcod like datkesp.vcldtbgrpcod,
    socvcltip    like datkesp.socvcltip   ,
    asitipcod    like datkesp.asitipcod   
 end record
 
 define l_msg char(200)
 define l_flg char(1)
 define l_espcnfcod like datkesp.espcnfcod
 
 initialize l_msg, l_flg, l_espcnfcod to null
 
  if(param.vcldtbgrpcod is null or 
    param.vcldtbgrpcod = ' ')  or
   (param.socvcltip is null    or 
    param.socvcltip = ' ')     or
   (param.asitipcod is null    or 
    param.asitipcod = ' ')     then
   let l_msg = "CAMPOS EM BRANCO, NAO FOI POSSIVEL EFETUAR A CONSULTA"
   return l_msg,'S'
 end if
 
 if m_ctc00m23_prep <> true then
    call ctc00m23_prepare()
 end if
 
 whenever error continue
 
    open cctc00m23006 using param.vcldtbgrpcod,
                           param.socvcltip,
                           param.asitipcod
    fetch cctc00m23006 into l_espcnfcod
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          let l_msg = "ERRO NA CONSULTA DA CONFIG. ERRO [",sqlca.sqlcode,"],ctc00m23_acionamento_auto()"
       end if
       return l_msg,'S'
    end if
    close cctc00m23006

    open cctc00m23007 using l_espcnfcod
    fetch cctc00m23007 into l_flg
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          let l_msg = "ERRO NA CONSULTA DA FLAG. ERRO [",sqlca.sqlcode,"],ctc00m23_acionamento_auto()"
       end if
       return l_msg,'S'
    end if
    close cctc00m23007
    
 whenever error stop 
 
 return l_msg, l_flg
 
end function