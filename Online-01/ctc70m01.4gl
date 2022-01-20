#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        : Central 24h                                  #
#  Modulo         : ctc70m01.4gl                                 #
#                   Cadastro de motivos de recusas (Outros)      #
#  Analista Resp. : Carlos Zyon                                  #
#  PSI            : 177903                                       #
#................................................................#
#................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE, Mariana Gimenez         #
#  Liberacao      : 28/01/2004                                   #
#................................................................#
#                     * * *  ALTERACOES  * * *                   #
#                                                                #
#  Data         Autor Fabrica  Data   Alteracao                  #
#  ----------   -------------  ------ -------------------------- #
#                                                                #
#----------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"


define m_datksrvr               record
       srvrcumtvcod             like datksrvrcumtv.srvrcumtvcod
      ,srvrcumtvdes             like datksrvrcumtv.srvrcumtvdes
      ,atdsrvorg                like datksrvrcumtv.atdsrvorg
      ,srvtipdes                like datksrvtip.srvtipdes
      ,srvrcumtvstt             like datksrvrcumtv.srvrcumtvstt
      ,caddat                   like datksrvrcumtv.caddat
      ,funnom                   char(20)
      ,atldat                   like datksrvrcumtv.atldat
      ,funnom2                  char(20)
                                end record

define m_cadmat                 dec(06,0) 
      ,m_atlmat                 dec(06,0)

define m_prepare                char(01) 
      ,m_comando                char(600)
      ,m_consulta               smallint
      ,m_pagina                 smallint
       
#---------------------------#
function ctc70m01_prepare()
#---------------------------#



let m_comando = "select max(srvrcumtvcod)",
                "  from datksrvrcumtv "

prepare pctc70m01001 from m_comando 
declare cctc70m01001 cursor for pctc70m01001

let m_comando = "select srvtipdes ",
                "  from datksrvtip ",
                " where atdsrvorg = ? "

prepare pctc70m01002 from m_comando 
declare cctc70m01002 cursor for pctc70m01002

let m_comando = " select funnom ",
                "   from isskfunc ",
                "  where funmat = ? " 

prepare pctc70m01003 from m_comando                
declare cctc70m01003 cursor for pctc70m01003

let m_comando = "select srvrcumtvcod,srvrcumtvdes,atdsrvorg,srvrcumtvstt,",
                "       caddat,cadmat,atldat,atlmat ",
                "  from datksrvrcumtv ",
                " where srvrcumtvcod = ? "

prepare pctc70m01004 from m_comando
declare cctc70m01004 scroll cursor for pctc70m01004

let m_comando = "select rowid ",
                "  from datksrvrcumtv ",    
                " where srvrcumtvcod = ? " 

prepare pctc70m01005 from m_comando
declare cctc70m01005 cursor for pctc70m01005

let m_comando = "insert into datksrvrcumtv ",
                "  values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)"

prepare pctc70m01006 from m_comando 


let m_comando = "update datksrvrcumtv ",
                "   set srvrcumtvdes = ?, ",
                "       atdsrvorg    = ?, ",
                "       srvrcumtvstt = ?, ",
                "       atldat       = ?, ",
                "       atlhor       = ?, ",
                "       atlemp       = ?, ",
                "       atlmat       = ?, ",
                "       atlusrtip    = ?  ",
                " where srvrcumtvcod = ?  "

prepare pctc70m01007 from m_comando 

let m_comando = "select count(*)  ", 
                "  from datmsrvacp ",  
                " where srvrcumtvcod = ? " 

prepare pctc70m01008 from m_comando
declare cctc70m01008 cursor for pctc70m01008

let m_comando = "delete from datksrvrcumtv ",
                "  where srvrcumtvcod = ? "

prepare pctc70m01009 from m_comando

let m_comando = "select srvrcumtvcod,srvrcumtvdes,atdsrvorg,srvrcumtvstt,",
                "       caddat,cadmat,atldat,atlmat ",
                "  from datksrvrcumtv "

prepare pctc70m01010 from m_comando
declare cctc70m01010 scroll cursor  for pctc70m01010


end function 

#---------------------#
function ctc70m01()
#---------------------#


   if m_prepare is null then
      call ctc70m01_prepare()
      let m_prepare = "S"
   end if

   initialize m_datksrvr.* to null 

   open window w_ctc70m01 at 4,2 with form "ctc70m01" 
      attribute (prompt line last, comment line last)


   menu "RECUSAS:"


      command key ("S") "Seleciona" "Pesquisa motivo recusa conforme criterios"
         call ctc70m01_seleciona()

         if m_datksrvr.srvrcumtvcod is null then 
         else 
            next option "Proximo"
         end if 

      command key ("P") "Proximo"  "Seleciona proximo registro "
      
         if m_datksrvr.srvrcumtvcod is null then 
            error "Selecione o registro !"
            next option "Seleciona"
         else  
            if m_pagina = true then 
               call ctc70m01_pagina(1)
            else 
               error "Nao existem registros nesta direcao!!"
               next option "Seleciona"
            end if 
         end if 


      command key ("A") "Anterior" "Seleciona registro anterior "

         if m_datksrvr.srvrcumtvcod is null then 
            error "Selecione o registro !"
            next option "Seleciona"
         else   
            if m_pagina = true then 
               call ctc70m01_pagina(-1)
            else
               error "Nao existem registros nesta direcao !!"
               next option "Seleciona"
            end if 
         end if 

      command key ("M") "Modifica" "Modifica registro selecionado"

         if m_datksrvr.srvrcumtvcod is null then 
            error "Selecione o registro !"
            next option "Seleciona"
         else   
            call ctc70m01_input("M")
         end if 

      command key ("I") "Inclui"   "Inclui motivo recusa "
         call ctc70m01_input("I")

      command key ("X") "eXclui"  "Exclui registro selecionado"
         if m_datksrvr.srvrcumtvcod is null then 
            error "Selecione o registro antes da exclusao!"
            next option "Seleciona"
         else   
            call ctc70m01_exclui()
         end if 

      command key (interrupt,"E") "Encerra" "Retorna ao menu anterior "
         exit menu  
      
   end menu 

   close window w_ctc70m01

end function


#------------------------------#
function ctc70m01_input(l_acao)
#------------------------------# 

define l_acao          char(01) 
      ,l_erro          smallint
      ,l_ret           smallint


    let l_erro    = false
    let int_flag  = false 


    if l_acao = "I" then 
       initialize m_datksrvr.* to null
   end if

    display by name m_datksrvr.* 

    input by name m_datksrvr.*                
          without defaults

    
       before field srvrcumtvcod 
         if l_acao = "I" then 
        
            whenever error continue                
            open cctc70m01001 
            fetch cctc70m01001 into m_datksrvr.srvrcumtvcod
            whenever error stop     

            if sqlca.sqlcode <> 0 then  
               if sqlca.sqlcode < 0 then 
                  error "Erro na selecao da tabela datksrvrcumtv", 
                  sqlca.sqlcode
                  let l_erro = true 
                  exit input
                else  
                   if sqlca.sqlcode = 100 then
                      let m_datksrvr.srvrcumtvcod = 0
                   end if
                end if
            end if 
    
            let m_datksrvr.srvrcumtvcod = m_datksrvr.srvrcumtvcod + 1
    
            display by name m_datksrvr.*
            next field srvrcumtvdes
         else  
            next field srvrcumtvdes
         end if 
           
         after field srvrcumtvcod
           if m_datksrvr.srvrcumtvcod is null then
              error "Informe o codigo do motivo de recusa"
              next field srvrcumtvcod
           end if 

         after field srvrcumtvdes
           if m_datksrvr.srvrcumtvdes is null or 
              m_datksrvr.srvrcumtvdes = " "   then 
              error "Informe a descricao do motivo"
              next field srvrcumtvdes
           end if 

         after field atdsrvorg 
           if m_datksrvr.atdsrvorg is not null then 

              whenever error continue
              open cctc70m01002 using m_datksrvr.atdsrvorg
              fetch cctc70m01002 into m_datksrvr.srvtipdes
              whenever error stop 
           
              if sqlca.sqlcode <> 0 then 
                 if sqlca.sqlcode < 0 then 
                    error "Problemas ao acessar a tabela datksrvtip(1) ",
                    sqlca.sqlcode 
                    let l_erro = true 
                    exit input
                 else
                    if sqlca.sqlcode = 100 then 
                       error "Origem de servico nao cadastrado !"
                       #sleep 1
                    end if 
                 end if 
              end if 
              display by name m_datksrvr.*
           else 
              let m_comando = "select atdsrvorg, srvtipdes ",
                              "  from datksrvtip ",
                              "  order by 1 "
                  call ofgrc001_popup(08,10, 'Servicos', 'Orig.Servico'
                                     ,'Descricao', 'A',
                                      m_comando, '','X')
                       returning l_ret
                                ,m_datksrvr.atdsrvorg
                                ,m_datksrvr.srvtipdes

                  if m_datksrvr.atdsrvorg is null then
                     error "Nenhum registro selecionado!"
                  end if 
           end if 
                    

           after field srvrcumtvstt 
             if m_datksrvr.srvrcumtvstt is not null then
                if m_datksrvr.srvrcumtvstt <> "A" and 
                   m_datksrvr.srvrcumtvstt <> "C" then 
                   error "Status invalido! "          
                   next field srvrcumtvstt
                end if
             else
                if fgl_lastkey() <> fgl_keyval("up") then 
                   error "Informe o status !" 
                   next field srvrcumtvstt
                end if
             end if 
         
         
           before field caddat
             if l_acao = "M" then 
                next field atldat
             else
                let m_datksrvr.caddat = today 
                display by name m_datksrvr.caddat
                next field funnom 
             end if 
 
           before field funnom 
             whenever error continue 
             open cctc70m01003 using g_issk.funmat
             fetch cctc70m01003 into m_datksrvr.funnom 
             whenever error stop 
             if sqlca.sqlcode < 0 then 
                error "Problemas no acesso a tabela isskfunc",
                       sqlca.sqlcode 
                let l_erro = true
                exit input
             end if 
             display by name m_datksrvr.funnom
             next field atldat

           before field atldat
             let m_datksrvr.atldat = today 
             display by name m_datksrvr.atldat           
             next field funnom2

           before field funnom2
             whenever error continue 
             open cctc70m01003 using g_issk.funmat
             fetch cctc70m01003 into m_datksrvr.funnom2
             whenever error stop 
             if sqlca.sqlcode < 0 then
                error "Problemas no acesso a tabela isskfunc",
                       sqlca.sqlcode
                let l_erro = true
                exit input
             end if 
             display by name m_datksrvr.funnom2
             exit input
          
             on key (control-c, interrupt)
                let int_flag = true 
                exit input  
   
    end input  

    if not l_erro    and 
       not int_flag  then 
       if l_acao = "I" then 
          call ctc70m01_inclui()
       else
          call ctc70m01_modifica()
       end if 
    end if 

end function 

#-------------------------#
function ctc70m01_inclui()
#-------------------------#

 define l_cadhor        datetime hour to second

   let l_cadhor = time    

   begin work 

   whenever error continue 
   execute pctc70m01006 using m_datksrvr.srvrcumtvcod
                             ,m_datksrvr.srvrcumtvdes
                             ,m_datksrvr.srvrcumtvstt
                             ,m_datksrvr.atdsrvorg
                             ,m_datksrvr.caddat
                             ,l_cadhor
                             ,g_issk.empcod 
                             ,g_issk.funmat  
                             ,g_issk.usrtip
                             ,m_datksrvr.atldat 
                             ,l_cadhor
                             ,g_issk.empcod
                             ,g_issk.funmat 
                             ,g_issk.usrtip
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
function ctc70m01_modifica()
#--------------------------#

define l_atlhor        datetime hour to second

   let l_atlhor = time

   begin work

   whenever error continue 

   execute pctc70m01007 using m_datksrvr.srvrcumtvdes
                             ,m_datksrvr.atdsrvorg
                             ,m_datksrvr.srvrcumtvstt
                             ,m_datksrvr.atldat
                             ,l_atlhor
                             ,g_issk.empcod
                             ,g_issk.funmat
                             ,g_issk.usrtip
                             ,m_datksrvr.srvrcumtvcod
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
function ctc70m01_seleciona()
#----------------------------#

define l_rowid       integer

   clear form 


   let int_flag = false
   let m_pagina = false
   initialize m_datksrvr.* to null 

   input by name m_datksrvr.srvrcumtvcod  
         without defaults

      after field srvrcumtvcod 
        if m_datksrvr.srvrcumtvcod is not null then 
           whenever error continue
           open cctc70m01005 using m_datksrvr.srvrcumtvcod
           fetch cctc70m01005 into l_rowid
           whenever error stop        

           if sqlca.sqlcode < 0 then 
              error "Problemas ao acessar a tabela datksrvrcumtv(1)",
                     sqlca.sqlcode
              let int_flag = true 
              exit input 
           end if 
 
           if l_rowid is null  or 
              l_rowid = 0      then 
              error "Codigo do motivo inexistente!"
              next field srvrcumtvcod 
           end if 
        end if 

        on key (control-c, interrupt)
           let int_flag = true 
           exit input 
              
   end input 
           
   if not int_flag then      
      if m_datksrvr.srvrcumtvcod is not null then 
         whenever error continue 
         open cctc70m01004    using m_datksrvr.srvrcumtvcod 
         fetch  cctc70m01004  into m_datksrvr.srvrcumtvcod
                                  ,m_datksrvr.srvrcumtvdes
                                  ,m_datksrvr.atdsrvorg
                                  ,m_datksrvr.srvrcumtvstt
                                  ,m_datksrvr.caddat
                                  ,m_cadmat
                                  ,m_datksrvr.atldat
                                  ,m_atlmat
 
         whenever error stop        
         if sqlca.sqlcode < 0 then 
            error "Problemas ao acessar a tabela datksrvrcumtv(2)",
                  sqlca.sqlcode 
            return
         end if 
      else 
         let m_pagina = true 
         whenever error continue
         open cctc70m01010  
         fetch first cctc70m01010 into m_datksrvr.srvrcumtvcod
                                      ,m_datksrvr.srvrcumtvdes
                                      ,m_datksrvr.atdsrvorg
                                      ,m_datksrvr.srvrcumtvstt
                                      ,m_datksrvr.caddat
                                      ,m_cadmat
                                      ,m_datksrvr.atldat
                                      ,m_atlmat
 
         whenever error stop        
         if sqlca.sqlcode < 0 then 
            error "Problemas ao acessar a tabela datksrvrcumtv(2)",
                  sqlca.sqlcode 
            return
         end if
      end if  

      whenever error continue 
      open cctc70m01002 using m_datksrvr.atdsrvorg 
      fetch cctc70m01002 into m_datksrvr.srvtipdes
      whenever error stop 

      if sqlca.sqlcode < 0 then 
         error "Problemas ao acessar a tabela datksrvtip(2) ",
         sqlca.sqlcode 
         return 
      end if 

      whenever error continue 
      open cctc70m01003 using m_cadmat
      fetch cctc70m01003 into m_datksrvr.funnom
      whenever error stop

      if sqlca.sqlcode < 0 then
         error "Problemas ao acessar a tabela isskfunc(2) ",
               sqlca.sqlcode
         return
      end if 

      whenever error continue 
      open cctc70m01003 using m_atlmat
      fetch cctc70m01003 into m_datksrvr.funnom2
      whenever error stop

      if sqlca.sqlcode < 0 then
         error "Problemas ao acessar a tabela isskfunc(2) ",
         sqlca.sqlcode
         return 
      end if 
     
      display by name m_datksrvr.*

   end if 
end function

#-------------------------------#
function ctc70m01_pagina(l_ind)
#-------------------------------#

define l_ind       integer


   whenever error continue 

      fetch relative l_ind  cctc70m01010  into m_datksrvr.srvrcumtvcod
                                              ,m_datksrvr.srvrcumtvdes
                                              ,m_datksrvr.atdsrvorg
                                              ,m_datksrvr.srvrcumtvstt
                                              ,m_datksrvr.caddat
                                              ,m_cadmat
                                              ,m_datksrvr.atldat
                                              ,m_atlmat
   whenever error stop 

   if sqlca.sqlcode = notfound then 
      error "Nao existem mais registros nessa direcao"
   else 

      whenever error continue 
      open cctc70m01002 using m_datksrvr.atdsrvorg 
      fetch cctc70m01002 into m_datksrvr.srvtipdes
      whenever error stop 

      if sqlca.sqlcode < 0 then 
         error "Problemas ao acessar a tabela datksrvtip(2) ",
         sqlca.sqlcode 
         return 
      end if 

      whenever error continue 
      open cctc70m01003 using m_cadmat
      fetch cctc70m01003 into m_datksrvr.funnom
      whenever error stop

      if sqlca.sqlcode < 0 then
         error "Problemas ao acessar a tabela isskfunc(2) ",
               sqlca.sqlcode
         return
      end if 

      whenever error continue 
      open cctc70m01003 using m_atlmat
      fetch cctc70m01003 into m_datksrvr.funnom2
      whenever error stop

      if sqlca.sqlcode < 0 then
         error "Problemas ao acessar a tabela isskfunc(2) ",
         sqlca.sqlcode
         return 
      end if 
     
      display by name m_datksrvr.*

   end if 
end function

#------------------------#
function ctc70m01_exclui()
#------------------------#

define l_count    integer


   let l_count = 0

   whenever error continue
   open cctc70m01008 using m_datksrvr.srvrcumtvcod
   fetch cctc70m01008 into l_count
   whenever error stop 


   if sqlca.sqlcode < 0 then 
      error "Erro de acesso a tabela datmsrvacp . Erro : ",
      sqlca.sqlcode 
      return
   end if 


   if l_count > 0 then 
      error "Motivo relacionado a tabela de Etapas.Exclusao nao efetuada! "
      return 
   else
      begin work                 
      whenever error continue
      execute pctc70m01009 using m_datksrvr.srvrcumtvcod
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


 
