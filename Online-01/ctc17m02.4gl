#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema........: Central 24 Horas                                          #
# Modulo.........: ctc17m02                                                  #
# Analista Resp..: Ligia Mattge                                              #
# PSI/OSF........: 191108                                                    #
#                  PopUp de Vias emergenciais por departamento               #
# ...........................................................................#
# Desenvolvimento: Coutelle, Meta                                            #
# Liberacao......: 18/05/2005                                                #
# ...........................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica   Origem     Alteracao                            #
# ---------- --------------  ---------- -------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#
database porto

 define m_prep_sql  smallint

#-----------------------------
function ctc17m02_prepare()
#-----------------------------
 define l_sql        char(500)
       
 let l_sql = 'select t1.emeviades, t1.emeviapri, t1.emeviacod '
            ,'  from datkemevia t1, datmemeviadpt t2 '
            ,' where t1.emeviacod = t2.emeviacod '
              ,' and t2.dptcod    = ? '
              ,' and t1.emeviasit = "A" '
              ,' and t2.dptsit    = "A" '
            ,' order by t1.emeviades '

 prepare pctc17m02001 from l_sql
 declare cctc17m02001 cursor for pctc17m02001

 let l_sql = 'select 1 '
            ,'  from datmemeviadpt '
            ,' where dptcod = ? '
            ,'   and dptsit = "A" '
            ,'   and emeviacod in (select emeviacod from datkemevia '
            ,'   where emeviasit = "A" ) ' 

 prepare pctc17m02002 from l_sql
 declare cctc17m02002 cursor for pctc17m02002
 

 let l_sql = 'select dptsit '
            ,'  from datmemeviadpt '
            ,' where dptcod    = ? '
              ,' and emeviacod = ? '

 prepare pctc17m02003 from l_sql
 declare cctc17m02003 cursor for pctc17m02003
  
 
 let l_sql = 'select emeviades, emeviapri, emeviasit  '
            ,'  from datkemevia '
            ,' where emeviacod = ? '

 prepare pctc17m02004 from l_sql
 declare cctc17m02004 cursor for pctc17m02004
 
 let l_sql = 'select t1.emeviacod '
            ,'  from datkemevia t1, datmemeviadpt t2 '
            ,' where t1.emeviacod = t2.emeviacod '
              ,' and t1.emeviades = ? '
              ,' and t2.dptcod    = ? '
              ,' and t1.emeviasit = "A" '
              ,' and t2.dptsit    = "A" '

 prepare pctc17m02005 from l_sql
 declare cctc17m02005 cursor for pctc17m02005

 let m_prep_sql = true

end function

#----------------------------------------
function ctc17m02_popup_via(l_dptsgl)
#----------------------------------------
   define l_dptsgl     like datmemeviadpt.dptcod
         ,l_counter    smallint
         ,l_prior      like datkemevia.emeviapri
         ,l_result     smallint
         ,l_emeviacod  like datkemevia.emeviacod 
         ,l_emeviades  like datkemevia.emeviades
         ,l_priority   char(6)
         
   define al_grid      array[200] of record
                                        emeviades  like datkemevia.emeviades
                                       ,emeviapri  char(06)
                                     end record       

   define al_cod       array[200] of like datkemevia.emeviacod

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc17m02_prepare()
   end if

   let l_emeviacod = null
   let l_emeviades = null
   let l_priority = null

   initialize al_grid, al_cod  to null

   let l_counter = 1

   open cctc17m02001 using l_dptsgl

   foreach cctc17m02001 into al_grid[l_counter].emeviades, l_prior, al_cod[l_counter]

      case l_prior
         when 1
            let al_grid[l_counter].emeviapri = 'ALTA'
         when 2
            let al_grid[l_counter].emeviapri = 'MEDIA'
         when 3
            let al_grid[l_counter].emeviapri = 'BAIXA'
      end case

      let l_counter = l_counter + 1

      if l_counter > 200 then
         error 'Limite do array foi excedido'  sleep 2
         exit foreach
      end if

   end foreach 

   let l_counter = l_counter -1
   
   if l_counter = 0 then
      let l_result = 3
      error 'Nao existem vias emergenciais cadastradas para seu departamento'  sleep 2
   else
      open window w_ctc17m02 at 10, 50 with form "ctc17m02"
         attribute (border, form line 1)

      call set_count(l_counter)
      
      display array al_grid to s_ctc17m02.*
         
         on key (f8)
            let l_result = 1
            let l_counter = arr_curr()
            let l_emeviacod = al_cod[l_counter]
            let l_emeviades = al_grid[l_counter].emeviades
            let l_priority  = al_grid[l_counter].emeviapri
            
            exit display
         
         on key (control-c, f17, interrupt)
            let l_result = 2
            exit display

      end display
   
      let int_flag = false
      close window w_ctc17m02
   end if

   return l_result, l_emeviacod, l_emeviades, l_priority
   
end function

#----------------------------------------------------
function ctc17m02_obter_via(l_emeviacod, l_dptcod)
#----------------------------------------------------
   define l_emeviacod  like datmemeviadpt.emeviacod
         ,l_dptcod     like datmemeviadpt.dptcod
         ,l_dptsit     like datmemeviadpt.dptsit
         ,l_result     smallint
         ,l_message    char(80)
         ,l_emeviades  like datkemevia.emeviades
         ,l_emeviapri  like datkemevia.emeviapri
         ,l_emeviasit  like datkemevia.emeviasit
        
   let l_result = 1
   let l_message = null
   let l_emeviades = null
   let l_emeviapri = null
   let l_emeviasit = null
   let l_dptsit = null 

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc17m02_prepare()
   end if

   if l_dptcod is not null then
      open cctc17m02003 using l_dptcod, l_emeviacod

      whenever error continue
      fetch cctc17m02003  into l_dptsit
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let l_result = 2
            let l_message = "Via emergencial nao cadastrada para o departamento."
         else
            let l_result = 3
            let l_message = 'Erro SELECT cctc17m02003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
         end if
      else
         if l_dptsit = "C" then
            let l_result = 2
            let l_message = 'Departamento cancelado para informar via emergencial'
         end if 
      end if
   end if

   if l_result = 1 then
      open cctc17m02004 using l_emeviacod

      whenever error continue
      fetch cctc17m02004 into l_emeviades, l_emeviapri, l_emeviasit 
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let l_result = 2
            let l_message = "Via emergencial nao cadastrada."         
         else
            let l_result = 3
            let l_message = 'Erro SELECT cctc17m02004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
         end if
      else
         if l_emeviasit = "C" then
            let l_result= 2
            let l_message = 'Via emergencial cancelada'
         end if 
      end if
   end if

   return l_result, l_message, l_emeviades, l_emeviapri

end function

#-----------------------------------------------
function ctc17m02_consiste_depto_via(l_dptcod)
#-----------------------------------------------
 define l_dptcod   like datmemeviadpt.dptcod
       ,l_result   smallint
       ,l_message  char(80)

   let l_result = 1
   let l_message = null
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc17m02_prepare()
   end if
      
   open cctc17m02002 using l_dptcod
   whenever error continue
   fetch cctc17m02002
   whenever error stop   
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_result = 2
         let l_message = "Nao existe via emergencial cadastrada para o departamento."
      else
         let l_result = 3
         let l_message = "Erro SELECT cctc17m02002 / ", sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
      end if
   end if

   return l_result, l_message

end function


#----------------------------------------
function ctc17m02_obter_emeviacod(l_emeviades, l_dptsgl)
#----------------------------------------
   define l_emeviades  like datkemevia.emeviades
         ,l_dptsgl     like datmemeviadpt.dptcod
         ,l_emeviacod  like datkemevia.emeviacod 
         ,l_result     smallint
         ,l_message    char(80)
         
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc17m02_prepare()
   end if

   let l_emeviacod = null
   let l_result = 1

   open cctc17m02005 using l_emeviades, l_dptsgl

   whenever error continue
   fetch cctc17m02005 into l_emeviacod       
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_result = 2
         let l_message = "Nao existe essa via emergencial cadastrada para o departamento."
      else
         let l_result = 3
         let l_message = "Erro SELECT cctc17m02005 / ", sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
      end if
   end if

   return l_result, l_message, l_emeviacod
   
end function
