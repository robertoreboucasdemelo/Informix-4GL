{--------------------------------------------------------------------    
Porto Seguro Cia Seguros Gerais                                          
....................................................................     
Sistema       : Central 24h                                              
Modulo        : ctc15m07                                                 
Analista Resp.: Roberto Melo                                             
PSI           :                                                          
Objetivo      : Manutencao do Relacionamento origem/limite          
....................................................................     
Desenvolvimento: Amilton , META                                          
Liberacao      :                                                         
....................................................................     
                                                                         
                 * * * Alteracoes * * *                                  
                                                                         
Data        Autor Fabrica  Origem    Alteracao                           
----------  -------------- --------- ------------------------------      
----------------------------------------------------------------------}
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep smallint


function ctc15m07_prepare()

   define l_sql char(500)
   
   let l_sql = "select srvtipdes,atlemp,atldat,atlmat,agdlimqtd ",
               " from datksrvtip     ",            
               " where atdsrvorg = ? " 
   prepare pctc15m07001 from l_sql                         
   declare cctc15m07001 cursor for pctc15m07001
   
   let l_sql = "select 30     ",        
               " from datksrvtip     ",        
               " where atdsrvorg = ? "         
   prepare pctc15m07002 from l_sql             
   declare cctc15m07002 cursor for pctc15m07002
   
   
   let l_sql = "update datksrvtip set ",        
               " ( agdlimqtd,atldat,atlemp,atlmat) = ",        
               " ( ?,?,?,? ) ",
               " where atdsrvorg = ? "               
   prepare pctc15m07003 from l_sql          
   
   let l_sql = "select funnom     ",        
               " from isskfunc    ",        
               " where empcod = ? ",
               " and funmat = ?   "         
   prepare pctc15m07004 from l_sql             
   declare cctc15m07004 cursor for pctc15m07004
   
   
   
   let m_prep = true
      
end function 


#------------------------------------------------------------------
 function ctc15m07(param)
#------------------------------------------------------------------

 define param         record
    atdsrvorg         like datksrvtip.atdsrvorg
 end record

 define d_ctc15m07    record
    atdsrvorg         like datksrvtip.atdsrvorg,    
    srvtipdes         like datksrvtip.srvtipdes,
    atldat            like datksrvtip.atldat,    
    atlfunnom         like isskfunc.funnom ,
    agdlimqtd            like datksrvtip.agdlimqtd
 end record
 
 define lr_func record 
      atlmat  like datksrvtip.atlmat,
      atlemp  like datksrvtip.atlmat
 end record      
              
 define lr_erro record 
     coderro  smallint,
     msg   char(300)
 end record   
 
 define l_lim_ant char(3)
 define l_confirma char(1)
   
  
 initialize lr_erro.* to null 
 initialize d_ctc15m07.* to null  
 initialize lr_func.* to null 
 let l_lim_ant = null 
 let l_confirma = null 
 
 if m_prep = false or 
    m_prep = " "   then 
    call ctc15m07_prepare() 
 end if 
    
 whenever error continue 
 
 open cctc15m07001 using param.atdsrvorg 
 fetch cctc15m07001 into d_ctc15m07.srvtipdes,
                         lr_func.atlemp,
                         d_ctc15m07.atldat,
                         lr_func.atlmat,
                         d_ctc15m07.agdlimqtd
 
 whenever error stop 
 
 if sqlca.sqlcode <> 0 then 
    if sqlca.sqlcode = 100 then 
       let lr_erro.coderro = sqlca.sqlcode
       let lr_erro.msg = "Erro <",lr_erro.coderro clipped ,"> ao buscar a origem, AVISE A INFORMATICA !"
       error lr_erro.msg
    else     
       let lr_erro.coderro = sqlca.sqlcode
       let lr_erro.msg = "Erro <",lr_erro.coderro clipped ,"> ao buscar a origem, AVISE A INFORMATICA !"
       error lr_erro.msg
    end if    
 end if       
  
 let l_lim_ant = d_ctc15m07.agdlimqtd
 
 display "d_ctc15m07.agdlimqtd = ",d_ctc15m07.agdlimqtd

 open window w_ctc15m07 at 06,06 with form "ctc15m07"
                        attribute(border,form line first, comment line last - 1)

 message " (F17)Abandona"

    let d_ctc15m07.atdsrvorg = param.atdsrvorg
   
    let d_ctc15m07.atlfunnom = "*** NAO CADASTRADO ***"

    whenever error continue 
    open cctc15m07004 using lr_func.atlemp,
                            lr_func.atlmat
    
    fetch cctc15m07004 into d_ctc15m07.atlfunnom
    whenever error stop 
    
    if sqlca.sqlcode <> 0 then 
       if sqlca.sqlcode = 100 then 
          let lr_erro.coderro = sqlca.sqlcode 
          let lr_erro.msg = "Erro <",sqlca.sqlcode, "> ao buscar matricula, Avise a informatica !"
          error lr_erro.msg
       else
         let lr_erro.coderro = sqlca.sqlcode 
         let lr_erro.msg = "Erro <",sqlca.sqlcode, "> ao buscar matricula, Avise a informatica !"
          error lr_erro.msg
       end if 
    end if       
    close cctc15m07004
       
    let d_ctc15m07.atlfunnom = upshift(d_ctc15m07.atlfunnom)
    
    display "<157> d_ctc15m07.agdlimqtd = ",d_ctc15m07.agdlimqtd
    display by name d_ctc15m07.* attribute(reverse)
    
    call ctc15m07_input(d_ctc15m07.agdlimqtd) 
         returning d_ctc15m07.agdlimqtd

    if l_lim_ant <> d_ctc15m07.agdlimqtd or 
       l_lim_ant is null              then         
        call cts08g01 ("A","S",""
                         ,"DESEJA ALTERAR O LIMITE ? ","","")
                returning l_confirma
        
        if l_confirma = 'S' then 
        
         let d_ctc15m07.atldat = today
         whenever error continue
         
         execute pctc15m07003 using d_ctc15m07.agdlimqtd,
                                    d_ctc15m07.atldat,
                                    g_issk.empcod,
                                    g_issk.funmat,
                                    d_ctc15m07.atdsrvorg  
        
         whenever error stop
        
         if sqlca.sqlcode <> 0  then
            error " Erro (", sqlca.sqlcode, ") na alteracao do limite de Agendamento!"
            initialize d_ctc15m07.*   to null
            return d_ctc15m07.*
         else
            error " Alteracao de limite efetuada com sucesso!"  
         end if
        end if 
      end if   
 
 close window w_ctc15m07
 

 end function  ###  ctc15m00_modifica


function ctc15m07_input(lr_param)

 
 define lr_param record 
        agdlimqtd   like datksrvtip.agdlimqtd
 end record       
  
 define d_ctc15m07    record    
        agdlimqtd   like datksrvtip.agdlimqtd
 end record
   
 
    let d_ctc15m07.agdlimqtd = lr_param.agdlimqtd
     
    input by name d_ctc15m07.agdlimqtd without defaults

    before field agdlimqtd                      
           display by name d_ctc15m07.agdlimqtd
           
                      
    after  field agdlimqtd           
           display by name d_ctc15m07.agdlimqtd
                      
           if d_ctc15m07.agdlimqtd is null then 
              error "Limite deve ser informado "
           end if    
           

    on key (interrupt)
       exit input

 end input


 return d_ctc15m07.agdlimqtd 

end function 