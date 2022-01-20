#------------------------------------------------------------------------------#
# Sistema.: Porto Socorro                                                      #
# Modulo..: ctc00m26 - Manter Campanha                                         #
# Analista: Fabio Lamartine                                                    #
# PSI.....:                                                                    #
#............................................................................. #
#                                                                              #
# Desenvolvimento: Vinicius Morais - 10/13                                     #
#                                                                              #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glseg.4gl"

function ctc00m26_prepare()

   define l_sql char(200)
   
   let l_sql = null
   
   let l_sql = "select prsatlcphnum, prsatlcphinidat, " 
                     ,"prsatlcphfimdat, atlemp, atlusrtip, atlmat, atldat "
                     ,"from datkprsatlcph "
                     ,"order by prsatlcphnum desc"
   prepare pctc00m26001 from l_sql
   declare cctc00m26001 cursor for pctc00m26001

   let l_sql = "select funnom from isskfunc "
                     ,"where empcod = ?"
                     ,"  and usrtip = ?"
                     ,"  and funmat = ?"
   prepare pctc00m26002 from l_sql
   declare cctc00m26002 cursor for pctc00m26002 


   let l_sql = "update datkprsatlcph "
                 ,"set prsatlcphinidat = ? , prsatlcphfimdat = ?, " 
                     ,"atlemp = ?, atlusrtip = ?, atlmat = ?, " 
                     ,"atldat = current "
               ,"where prsatlcphnum = ?"
   prepare pctc00m26003 from l_sql
   
   let l_sql = "insert into datkprsatlcph" 
             ,"(prsatlcphinidat, prsatlcphfimdat, " 
              ,"atlemp, atlusrtip, atlmat, atldat)"
              ,"values (?, ?, ?, ?, ?, current)" 
   prepare pctc00m26004 from l_sql

   let l_sql = "select 1 from datkprsatlcph "
               ,"where prsatlcphinidat >= ? "
                 ,"or prsatlcphfimdat >= ? "                
               

   prepare pctc00m26005 from l_sql
   declare cctc00m26005 cursor for pctc00m26005 
   
   
   let l_sql = "select 1 from datkprsatlcph "
               ,"where prsatlcphinidat >= ? "
                 ,"and prsatlcphfimdat <= ?"
               

   prepare pctc00m26006 from l_sql
   declare cctc00m26006 cursor for pctc00m26006  
   
   
   let l_sql = "delete from  datkprsatlcph" 
             ," where  prsatlcphnum = ?"          
   prepare pctc00m26007 from l_sql       
   
                   

end function

function ctc00m26()


   define rctc00m26001 array[10] of record
          ghost           smallint
         ,prsatlcphnum    like datkprsatlcph.prsatlcphnum
         ,prsatlcphinidat like datkprsatlcph.prsatlcphinidat
         ,prsatlcphfimdat like datkprsatlcph.prsatlcphfimdat
    
   end record      
   
   define rctc00m26002 array[10] of record
          atlemp       like datkprsatlcph.atlemp
         ,atlusrtip    like datkprsatlcph.atlusrtip
         ,atlmat       like datkprsatlcph.atlmat
         ,atldat       like datkprsatlcph.atldat
         ,atldatfmt    like datkprsatlcph.prsatlcphfimdat
         ,funnom       like isskfunc.funnom
   end record
   
   define i    smallint
   define ap   smallint
   define l_as smallint
   define l_datflg smallint
   define l_retmsg char(100)
   define l_resp char(1)
   define l_respflg smallint
   define l_cmpcodcomp like datkprsatlcph.prsatlcphnum
   define l_edicao smallint
   define l_tela smallint
   define l_cod smallint  
   define l_datainiant like datkprsatlcph.atldat    
   
   let int_flag =   false
   let l_cod = false
   let l_tela = true
   initialize rctc00m26001 to null
   initialize rctc00m26002 to null
   
   call ctc00m26_prepare()

   open window wctc00m26 at 4,2 with form "ctc00m26"
      options prompt line last
      
   while l_tela = true
   
      let i = 1
      whenever error continue
      foreach cctc00m26001 into rctc00m26001[i].prsatlcphnum,
                                rctc00m26001[i].prsatlcphinidat,
                                rctc00m26001[i].prsatlcphfimdat,
                                rctc00m26002[i].atlemp,
                                rctc00m26002[i].atlusrtip,
                                rctc00m26002[i].atlmat,
                                rctc00m26002[i].atldat
       whenever error stop
       if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
         error "Erro no acesso ao Banco de Dados (0)"
       end if
         
       whenever error continue                       
         open cctc00m26002 using rctc00m26002[i].atlemp,
                                 rctc00m26002[i].atlusrtip,
                                 rctc00m26002[i].atlmat              
         
         fetch cctc00m26002 into rctc00m26002[i].funnom
         close cctc00m26002
      whenever error stop
      if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
         error "Erro no acesso ao Banco de Dados (1)"
      end if   
         let rctc00m26002[i].atldatfmt = rctc00m26002[i].atldat
         
         if i > 10 then
            exit foreach
         end if
         
         let i = i+1                            
      end foreach
      close cctc00m26001
      
         call set_count(i-1)
         
      options delete key control-y        # off 
      let l_edicao = false
      
      input array rctc00m26001 without defaults
             from s_ctc00m26.*
      
         before row
            let ap = arr_curr()
            let l_as = scr_line()
            display rctc00m26001[ap].* to s_ctc00m26[l_as].* attribute (reverse)
      
            display rctc00m26002[ap].funnom    to funnom
            display rctc00m26002[ap].atldatfmt to atldat 
            
            let l_datainiant = rctc00m26001[ap].prsatlcphinidat 
            
            next field ghost
            
         after row
            display rctc00m26001[ap].* to s_ctc00m26[l_as].*
            if (fgl_lastkey() = fgl_keyval("down"))    or
               (fgl_lastkey() = fgl_keyval("right"))   or
               (fgl_lastkey() = fgl_keyval("return"))  then
               if rctc00m26001[ap+1].prsatlcphnum is null then
                  error "Nao ha mais linha abaixo!!"
                  next field ghost
               end if
              
            end if
         
        
         before insert
            let ap = arr_curr()
            let l_as = scr_line()
            display rctc00m26001[ap].prsatlcphinidat to 
                    s_ctc00m26[l_as].prsatlcphinidat attribute (reverse)
            display rctc00m26001[ap].prsatlcphfimdat to 
                    s_ctc00m26[l_as].prsatlcphfimdat attribute (reverse)
                    
            let l_datainiant = rctc00m26001[ap].prsatlcphinidat         
            
            next field prsatlcphinidat
            next field prsatlcphinidat
            
         before field prsatlcphinidat
         if(l_as <> 1) then
               error "ERRO: Campanha nao liberada para edicao"
               next field ghost
         end if        
         
                  
         after field prsatlcphinidat
         
            if rctc00m26001[ap].prsatlcphinidat is null then 
               error "Data Inicial nao pode ser nulo"
               next field prsatlcphinidat
            end if
            
            if rctc00m26001[ap].prsatlcphnum is null then            
                           
               if rctc00m26001[ap].prsatlcphinidat <= current then 
                  error "A data inicial nao pode ser menor ou igual a data corrente"
                  next field prsatlcphinidat
               end if
            end if
             
            if l_datainiant is null or l_datainiant != rctc00m26001[ap].prsatlcphinidat then   
            
               display "rctc00m26001[ap].prsatlcphinidat", rctc00m26001[ap].prsatlcphinidat
               let l_cod = 0
               #verifica se data inicial já esta em outro periodo   
               whenever error continue
               open cctc00m26005 using rctc00m26001[ap].prsatlcphinidat, rctc00m26001[ap].prsatlcphinidat
               fetch cctc00m26005 into l_cod
               close cctc00m26005
               
               if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
                  error "Erro no acesso ao Banco de Dados (4)"
               end if
               
               if l_cod = true then                
                   error "Data Inicial de campanha ja foi gravado anteriormente"                    
                   next field prsatlcphinidat  
               end if
               
               whenever error stop
            end if            
            
            
            
         on key (F2)
            let l_edicao = true
            if(l_as <> 1) then
               error "ERRO: Campanha nao liberada para edicao"
               next field ghost
            end if
            next field prsatlcphinidat
            
        on key (F6)
            let l_edicao = true
            if(l_as <> 1) then
               error "ERRO: Campanha nao liberada para edicao"
               next field ghost
            end if
            
            display "rctc00m26001[ap].prsatlcphinidat", rctc00m26001[ap].prsatlcphinidat
            if rctc00m26001[ap].prsatlcphinidat <= current then
               error "ERRO: Campanha nao pode ser deletada"
            else 
                whenever error continue
                  display "rctc00m26001[ap].prsatlcphnum", rctc00m26001[ap].prsatlcphnum 
                  execute pctc00m26007 using rctc00m26001[ap].prsatlcphnum                                           
                
                  if sqlca.sqlcode <> 0 then
                     error "Erro ao deletar registro (2)"
                  end if
                  
                whenever error stop             
            end if
            
            exit input            
            
         
         on key (F8,interrupt)
            if l_edicao = true then
               let l_edicao = false
               next field ghost
               
            else
               let l_tela = false
               exit input   
            end if 
                 
         after field prsatlcphfimdat
            
            if rctc00m26001[ap].prsatlcphfimdat is null then 
               error "Data Final nao pode ser nulo"
               next field prsatlcphfimdat
            end if         
            
            if rctc00m26001[ap].prsatlcphfimdat < rctc00m26001[ap].prsatlcphinidat then 
               error "A data final nao pode ser menor que a data inicial"
               next field prsatlcphfimdat         
            end if
            
            if rctc00m26001[ap].prsatlcphfimdat <= current then 
               error "A data Final nao pode ser menor ou igual a data corrente"
               next field prsatlcphfimdat
            end if               
              
            
            let l_respflg = 0
            while l_respflg = 0
               prompt "Confirma Gravacao? (S/N)" FOR CHAR l_resp
               if upshift(l_resp) = "S" or
                  upshift(l_resp) = "N" then
                  let l_respflg = 1
               else
                  error "Digite apenas S ou N"                             
               end if
               
            end while
            
            if upshift(l_resp) = "S" then
               #Valida Data
               call ctc00m26_validacao(rctc00m26001[ap].prsatlcphinidat 
                                      ,rctc00m26001[ap].prsatlcphfimdat
                                      ,rctc00m26001[ap].prsatlcphnum)
                                      returning l_datflg, l_retmsg
                                      
            
            
               if l_datflg = false then
                  error "ERRO: ", l_retmsg clipped
                  next field prsatlcphinidat
             
               else
                  if rctc00m26001[ap].prsatlcphnum is null then
                   #INSERT
                   whenever error continue
                   execute pctc00m26004 using rctc00m26001[ap].prsatlcphinidat 
                                             ,rctc00m26001[ap].prsatlcphfimdat
                                             ,g_issk.empcod
                                             ,g_issk.usrtip
                                             ,g_issk.funmat
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     error "Erro ao gravar registro (2)"
                  end if
                  else 
                     #UPDATE
                     whenever error continue
                     execute pctc00m26003 using rctc00m26001[ap].prsatlcphinidat 
                                               ,rctc00m26001[ap].prsatlcphfimdat
                                               ,g_issk.empcod
                                               ,g_issk.usrtip
                                               ,g_issk.funmat
                                               ,rctc00m26001[ap].prsatlcphnum 
                     whenever error stop
                     if sqlca.sqlcode <> 0 then
                        error "Erro ao gravar registro (3)"
                     end if
      
                  end if
               end if
              
              error "Registro gravado com sucesso"
              sleep 2
              exit input
              #close window wctc00m26 
              return
               
            else
               next field prsatlcphinidat
            end if
      
      end input      
      
   end while 
   
   
   close window wctc00m26
         
end function

function ctc00m26_validacao(l_datini, l_datfim, l_cmpcod)

   define l_datini like datkprsatlcph.prsatlcphinidat
   define l_datfim like datkprsatlcph.prsatlcphfimdat
   define l_cmpcod like datkprsatlcph.prsatlcphnum
   define l_datflg smallint
   define l_retmsg char(100)
   define l_cod smallint

   
   let l_datflg = true
   let l_cod = false

   if l_datini is null then
      let l_datflg = false
      let l_retmsg = "Campos nao podem ser nulos"
   end if
   
   if l_datfim is null then
      let l_datflg = false
      let l_retmsg = "Campos nao podem ser nulos"
   end if

   if l_cmpcod is null then
      if l_datini <= current then
         let l_datflg = false
         let l_retmsg = "A data inicial nao pode ser menor "
                       ,"ou igual a data corrente"
      end if
   end if 
   
   if l_datini > l_datfim then
      let l_datflg = false
      let l_retmsg = "A data final nao pode ser menor que a data inicial"
   end if
   
   if l_datflg = true and l_cmpcod is null then            
      whenever error continue
      open cctc00m26005 using l_datini, l_datini, l_datfim, l_datfim  
      fetch cctc00m26005 into l_cod
      close cctc00m26005
      whenever error stop
      if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
         error "Erro no acesso ao Banco de Dados (4)"
      end if
      if l_cod = true then
             let l_datflg = false
             let l_retmsg = "Este periodo de campanha ja foi gravado anteriormente"
      end if
      
   end if
   
   return l_datflg, l_retmsg
   
end function
