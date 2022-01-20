#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        : Central 24h                                  #
#  Modulo         : ctc70m02.4gl                                 #
#                   Cadastro de motivos de recusas (Internet)    #
#  Analista Resp. : Carlos Zyon                                  #
#  PSI            : 177903                                       #
#................................................................#
#................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE, Mariana Gimenez         #
#  Liberacao      : 03/02/2004                                   #
#................................................................................#
#                     * * *  ALTERACOES  * * *                                   #
#                                                                                #
# Data       Autor Fabrica   Origem        Alteracao                             #
# ---------- --------------  ----------    --------------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao "fun_dba_abre_banco"#
#                                          e troca da "systables" por "dual"     #
#--------------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'


define m_datksrvint             record
       etpmtvcod                like datksrvintmtv.etpmtvcod
      ,etpmtvdes                like datksrvintmtv.etpmtvdes
      ,atdetpcod                like datksrvintetp.atdetpcod
      ,atdetpdes                like datksrvintetp.atdetpdes
      ,etpmtvstt                like datksrvintmtv.etpmtvstt
      ,caddat                   like datksrvintmtv.caddat
      ,funnom                   char(20)
                                end record

define m_cadmat                 dec(06,0) 

define m_prepare                char(01) 
      ,m_comando                char(600)
      ,m_pagina                 smallint
{
main
let g_issk.empcod = 1
let g_issk.funmat = 603418
defer interrupt
call ctc70m02()
end main
}
#---------------------------#
function ctc70m02_prepare()
#---------------------------#



let m_comando = "select max(etpmtvcod)",
                "  from datksrvintmtv "

prepare pctc70m02001 from m_comando 
declare cctc70m02001 cursor for pctc70m02001

let m_comando = "select atdetpdes ",
                "  from datksrvintetp ",
                " where atdetpcod = ? "

prepare pctc70m02002 from m_comando 
declare cctc70m02002 cursor for pctc70m02002

let m_comando = " select funnom ",
                "   from isskfunc ",
                "  where funmat = ? " 

prepare pctc70m02003 from m_comando                
declare cctc70m02003 cursor for pctc70m02003

let m_comando = "select etpmtvcod,etpmtvdes,atdetpcod,",
                "       etpmtvstt,caddat,cadmat ",
                "  from datksrvintmtv ",
                " where etpmtvcod = ? "

prepare pctc70m02004 from m_comando
declare cctc70m02004 scroll cursor for pctc70m02004

let m_comando = "select rowid ",
                "  from datksrvintmtv ",    
                " where etpmtvcod  = ? " 

prepare pctc70m02005 from m_comando
declare cctc70m02005 cursor for pctc70m02005

let m_comando = "insert into datksrvintmtv ",
                "  values (?,?,?,?,?,?,?)"

prepare pctc70m02006 from m_comando 


let m_comando = "update datksrvintmtv ",
                "   set etpmtvdes  = ?, ",
                "       etpmtvstt  = ?, ",
                "       cademp     = ?, ",
                "       cadmat     = ?, ",
                "       caddat     = ?, ",
                "       atdetpcod  = ?  ",
                " where etpmtvcod  = ?  "

prepare pctc70m02007 from m_comando 

let m_comando = "select count(*)  ", 
                "  from datmsrvint ",  
                " where etpmtvcod = ? " 

prepare pctc70m02008 from m_comando
declare cctc70m02008 cursor for pctc70m02008

let m_comando = "delete from datksrvintmtv ",
                "  where etpmtvcod = ? "

prepare pctc70m02009 from m_comando

let m_comando = "select etpmtvcod,etpmtvdes,atdetpcod,",
                "       etpmtvstt,caddat,cadmat ",
                "  from datksrvintmtv ",
                "  order by 1 "

prepare pctc70m02010 from m_comando
declare cctc70m02010 scroll cursor  for pctc70m02010


end function 

#---------------------#
function ctc70m02()
#---------------------#


   if m_prepare is null then
      call ctc70m02_prepare()
      let m_prepare = "S"
   end if

   initialize m_datksrvint.* to null 

   open window w_ctc70m02 at 4,2 with form "ctc70m02" 
      attribute (prompt line last, comment line last)


   menu "RECUSAS:"


      command key ("S") "Seleciona" "Pesquisa motivo recusa conforme criterios"
         call ctc70m02_seleciona()

         if m_datksrvint.etpmtvcod is null then 
         else 
            next option "Proximo"
         end if 

      command key ("P") "Proximo"  "Seleciona proximo registro "
      
         if m_datksrvint.etpmtvcod is null then 
            error "Selecione o registro !"
            next option "Seleciona"
         else  
            if m_pagina = true then 
               call ctc70m02_pagina(1)
            else 
               error "Nao existem registros nesta direcao!!"
               next option "Seleciona"
            end if 
         end if 


      command key ("A") "Anterior" "Seleciona registro anterior "

         if m_datksrvint.etpmtvcod is null then 
            error "Selecione o registro !"
            next option "Seleciona"
         else   
            if m_pagina = true then 
               call ctc70m02_pagina(-1)
            else
               error "Nao existem registros nesta direcao !!"
               next option "Seleciona"
            end if 
         end if 

      command key ("M") "Modifica" "Modifica registro selecionado"

         if m_datksrvint.etpmtvcod is null then 
            error "Selecione o registro !"
            next option "Seleciona"
         else   
            call ctc70m02_input("M")
         end if 

      command key ("I") "Inclui"   "Inclui motivo recusa "
         call ctc70m02_input("I")

      command key ("X") "eXclui"  "Exclui registro selecionado"
         if m_datksrvint.etpmtvcod is null then 
            error "Selecione o registro antes da exclusao!"
            next option "Seleciona"
         else   
            call ctc70m02_exclui()
         end if 

      command key (interrupt,"E") "Encerra" "Retorna ao menu anterior "
         exit menu  
      
   end menu 

   close window w_ctc70m02

end function


#------------------------------#
function ctc70m02_input(l_acao)
#------------------------------# 

define l_acao          char(01) 
      ,l_erro          smallint
      ,l_ret           smallint


    let l_erro    = false
    let int_flag  = false 


    if l_acao = "I" then 
       initialize m_datksrvint.* to null
   end if

    display by name m_datksrvint.* 

    input by name m_datksrvint.*                
          without defaults

    
       before field etpmtvcod    
         if l_acao = "I" then 
        
            whenever error continue                
            open cctc70m02001 
            fetch cctc70m02001 into m_datksrvint.etpmtvcod   
            whenever error stop     

            if sqlca.sqlcode <> 0 then  
               if sqlca.sqlcode < 0 then 
                  error "Erro na selecao da tabela datksrvintmtv", 
                  sqlca.sqlcode
                  let l_erro = true 
                  exit input
                else  
                   if sqlca.sqlcode = 100 then
                      let m_datksrvint.etpmtvcod = 0
                   end if
                end if
            end if 
    
            let m_datksrvint.etpmtvcod = m_datksrvint.etpmtvcod + 1
    
            display by name m_datksrvint.*
            next field etpmtvdes
         else  
            next field etpmtvdes
         end if 
           
         after field etpmtvcod
           if m_datksrvint.etpmtvcod is null then
              error "Informe o codigo do motivo de recusa"
              next field etpmtvcod
           end if 

         after field etpmtvdes   
           if m_datksrvint.etpmtvdes is null or 
              m_datksrvint.etpmtvdes = " "   then 
              error "Informe a descricao do motivo"
              next field etpmtvdes
           end if 

         after field atdetpcod 
           if m_datksrvint.atdetpcod is not null then 

              whenever error continue
              open cctc70m02002 using m_datksrvint.atdetpcod
              fetch cctc70m02002 into m_datksrvint.atdetpdes
              whenever error stop 
           
              if sqlca.sqlcode <> 0 then 
                 if sqlca.sqlcode < 0 then 
                    error "Problemas ao acessar a tabela datksrvintetp(1) ",
                    sqlca.sqlcode 
                    let l_erro = true 
                    exit input
                 else
                    if sqlca.sqlcode = 100 then 
                       error "Codigo de etapa nao cadastrado !"
                       #sleep 1
                    end if 
                 end if 
              end if 
              display by name m_datksrvint.*
           else 
              let m_comando = "select atdetpcod, atdetpdes ",
                              "  from datksrvintetp  ",
                              "  order by 1 "
                  call ofgrc001_popup(08,10, 'Etapas', 'Cod.Etapa'
                                     ,'Descricao', 'A',
                                      m_comando, '','X')
                       returning l_ret
                                ,m_datksrvint.atdetpcod
                                ,m_datksrvint.atdetpdes

                  if m_datksrvint.atdetpcod is null then
                     error "Nenhum registro selecionado!"
                     next field atdetpcod
                  end if 
           end if 
                    

           after field etpmtvstt    
             if m_datksrvint.etpmtvstt is not null then
                if m_datksrvint.etpmtvstt <> "A" and 
                   m_datksrvint.etpmtvstt <> "C" then 
                   error "Status invalido! "          
                   next field etpmtvstt
                end if
             else
                if fgl_lastkey() <> fgl_keyval("up") then 
                   error "Informe o status !" 
                   next field etpmtvstt   
                end if
             end if 
         
         
           before field caddat
             let m_datksrvint.caddat = today 
             display by name m_datksrvint.caddat
             next field funnom 
 
           before field funnom 
             whenever error continue 
             open cctc70m02003 using g_issk.funmat
             fetch cctc70m02003 into m_datksrvint.funnom 
             whenever error stop 
             if sqlca.sqlcode < 0 then 
                error "Problemas no acesso a tabela isskfunc",
                       sqlca.sqlcode 
                let l_erro = true
                exit input
             end if 
             display by name m_datksrvint.funnom
             exit input        

          
             on key (control-c, interrupt)
                let int_flag = true 
                initialize m_datksrvint.* to null 
                clear form
                exit input  
   
    end input  

    if not l_erro    and 
       not int_flag  then 
       if l_acao = "I" then 
          call ctc70m02_inclui()
       else
          call ctc70m02_modifica()
       end if 
    end if 

end function 

#-------------------------#
function ctc70m02_inclui()
#-------------------------#



   begin work 

   whenever error continue 
   execute pctc70m02006 using m_datksrvint.etpmtvcod   
                             ,m_datksrvint.etpmtvdes          
                             ,m_datksrvint.etpmtvstt    
                             ,g_issk.empcod
                             ,g_issk.funmat
                             ,m_datksrvint.caddat
                             ,m_datksrvint.atdetpcod
   whenever error stop     
   if sqlca.sqlcode <> 0 then 
      error "Problemas ao inserir registro na tabela . Erro : ",
      sqlca.sqlcode
      rollback work
      return 
   else   
      error "Inclusao efetuada"
   end if 

   commit work

end function 

#--------------------------#
function ctc70m02_modifica()
#--------------------------#


   begin work

   whenever error continue 

   execute pctc70m02007 using m_datksrvint.etpmtvdes   
                             ,m_datksrvint.etpmtvstt   
                             ,g_issk.empcod          
                             ,g_issk.funmat           
                             ,m_datksrvint.caddat
                             ,m_datksrvint.atdetpcod    
                             ,m_datksrvint.etpmtvcod
   whenever error stop 

   if sqlca.sqlcode <> 0 then 
      error "Problemas ao modificar a tabela. Erro : ",
            sqlca.sqlcode 
      rollback work
      return 
   else
      error "Modificacao efetuada ! "
   end if 

   commit work

end function 
  

#----------------------------#
function ctc70m02_seleciona()
#----------------------------#

define l_rowid       integer

   clear form 


   let int_flag = false
   let m_pagina = false
   initialize m_datksrvint.* to null 

   input by name m_datksrvint.etpmtvcod     
         without defaults

      after field etpmtvcod    
        if m_datksrvint.etpmtvcod is not null then 
           whenever error continue
           open cctc70m02005 using m_datksrvint.etpmtvcod   
           fetch cctc70m02005 into l_rowid
           whenever error stop        

           if sqlca.sqlcode < 0 then 
              error "Problemas ao acessar a tabela datmsrvint(1)",
                     sqlca.sqlcode
              let int_flag = true 
              exit input 
           end if 
 
           if l_rowid is null  or 
              l_rowid = 0      then 
              error "Codigo do motivo inexistente!"
              next field etpmtvcod    
           end if 
        end if 

        on key (control-c, interrupt)
           let int_flag = true 
           exit input 
              
   end input 
           
   if not int_flag then      
      if m_datksrvint.etpmtvcod is not null then 
         whenever error continue 
         open cctc70m02004    using m_datksrvint.etpmtvcod    
         fetch  cctc70m02004   into m_datksrvint.etpmtvcod   
                                   ,m_datksrvint.etpmtvdes   
                                   ,m_datksrvint.atdetpcod
                                   ,m_datksrvint.etpmtvstt    
                                   ,m_datksrvint.caddat
                                   ,m_cadmat
 
         whenever error stop        
         if sqlca.sqlcode < 0 then 
            error "Problemas ao acessar a tabela datksrvintmtv(2)",
                  sqlca.sqlcode 
            return
         end if 
      else 
         let m_pagina = true 
         whenever error continue
         open cctc70m02010  
         fetch first cctc70m02010 into m_datksrvint.etpmtvcod
                                      ,m_datksrvint.etpmtvdes   
                                      ,m_datksrvint.atdetpcod 
                                      ,m_datksrvint.etpmtvstt   
                                      ,m_datksrvint.caddat
                                      ,m_cadmat
 
         whenever error stop        
         if sqlca.sqlcode < 0 then 
            error "Problemas ao acessar a tabela datksrvintmtv(2)",
                  sqlca.sqlcode 
            return
         end if
      end if  

      whenever error continue 
      open cctc70m02002 using m_datksrvint.atdetpcod 
      fetch cctc70m02002 into m_datksrvint.atdetpdes
      whenever error stop 

      if sqlca.sqlcode < 0 then 
         error "Problemas ao acessar a tabela datksrvintetp(2) ",
         sqlca.sqlcode 
         return 
      end if 

      whenever error continue 
      open cctc70m02003 using m_cadmat
      fetch cctc70m02003 into m_datksrvint.funnom
      whenever error stop

      if sqlca.sqlcode < 0 then
         error "Problemas ao acessar a tabela isskfunc(2) ",
               sqlca.sqlcode
         return
      end if 

     
      display by name m_datksrvint.*

   end if 
end function

#-------------------------------#
function ctc70m02_pagina(l_ind)
#-------------------------------#

define l_ind       integer


   whenever error continue 

      fetch relative l_ind  cctc70m02010  into m_datksrvint.etpmtvcod   
                                              ,m_datksrvint.etpmtvdes    
                                              ,m_datksrvint.atdetpcod 
                                              ,m_datksrvint.etpmtvstt   
                                              ,m_datksrvint.caddat
                                              ,m_cadmat
   whenever error stop 

   if sqlca.sqlcode = notfound then 
      error "Nao existem mais registros nessa direcao"
   else 

      whenever error continue 
      open cctc70m02002 using m_datksrvint.atdetpcod 
      fetch cctc70m02002 into m_datksrvint.atdetpdes
      whenever error stop 

      if sqlca.sqlcode < 0 then 
         error "Problemas ao acessar a tabela datksrvintetp (2) ",
         sqlca.sqlcode 
         return 
      end if 

      whenever error continue 
      open cctc70m02003 using m_cadmat
      fetch cctc70m02003 into m_datksrvint.funnom
      whenever error stop

      if sqlca.sqlcode < 0 then
         error "Problemas ao acessar a tabela isskfunc(2) ",
               sqlca.sqlcode
         return
      end if 

      display by name m_datksrvint.*

   end if 
end function

#------------------------#
function ctc70m02_exclui()
#------------------------#

define l_count    integer


   let l_count = 0

   whenever error continue
   open cctc70m02008 using m_datksrvint.etpmtvcod    
   fetch cctc70m02008 into l_count
   whenever error stop 


   if sqlca.sqlcode < 0 then 
      error "Erro de acesso a tabela datmsrvint . Erro : ",
      sqlca.sqlcode 
      return
   end if 


   if l_count > 0 then 
      error "Motivo relacionado a tabela de Etapas.Exclusao nao efetuada! "
      return 
   else
      begin work                 
      whenever error continue
      execute pctc70m02009 using m_datksrvint.etpmtvcod    
      whenever error stop

      if sqlca.sqlcode <> 0 then 
         error "Problemas ao excluir registro da tabela. Erro : ",
         sqlca.sqlcode
         rollback work
         return
      else  
         error "Exclusao efetuada!"
      end if 

      commit work
   end if   

end function 


 
