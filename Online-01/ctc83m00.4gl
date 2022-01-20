#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24 Horas/Porto Socorro                            #
# Modulo.........: ctc83m00                                                  #
# Objetivo.......: Cadastro de Grupos de Atendimento                         #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Roberto Melo                                              #
# Liberacao      : 19/02/2008                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica  PSI         Alteracao                            #
# --------   -------------  ------      -------------------------------------#
# 11/11/2008 Carla Rampazzo PSI 230650  Tratar 1a. posigco do Assunto para   #
#                                       carregar pop-up com esta inicial     #
#----------------------------------------------------------------------------#
                                                              
globals "/homedsa/projetos/geral/globals/glct.4gl"  

define mr_tela record  
   grupo   char(13),
   assunto char(7) ,
   atd     char(3) ,
   obs     char(70)
end record

define m_prepare smallint
define m_acesso  char(6)
define m_f5      smallint
define m_sair    smallint

#------------------------------------------------------#        
function  ctc83m00_prepare()
#------------------------------------------------------#        

define l_sql char(500) 

  let l_sql = " select count(*)  ",
              " from igbmparam   ",
              " where relsgl = ? "
  prepare pctc83m00001  from l_sql              
  declare cctc83m00001  cursor for pctc83m00001
  
  let l_sql = " select relpamtxt[1,6]   ",             
              " from igbmparam          ",             
              " where relsgl = ?        ", 
              " and relpamseq > 0       ",
              " order by relpamtxt[1,6] "          
  prepare pctc83m00002  from l_sql              
  declare cctc83m00002  cursor for pctc83m00002
  
  let l_sql = " select a.funnom,          ", 
              "        b.dptnom           ",
              " from isskfunc a,          ", 
              "      isskdepto b          ",
              " where a.dptsgl = b.dptsgl ",                             
              " and a.funmat   = ?         "                                   
  prepare pctc83m00003  from l_sql             
  declare cctc83m00003  cursor for pctc83m00003
  
  let l_sql = " select max(relpamseq) + 1 ", 
              " from igbmparam            ", 
              " where relsgl = ?          "                                                   
  prepare pctc83m00004  from l_sql             
  declare cctc83m00004  cursor for pctc83m00004
  
  let l_sql = " select count(*)       ",
              " from igbmparam        ",
              " where relsgl = ?      ",
              " and relpamtxt[1,6] = ?",
              " and relpamseq > 0     "  
  prepare pctc83m00005  from l_sql                
  declare cctc83m00005  cursor for pctc83m00005  
  
  let l_sql = " select relpamtxt[1,6], ", 
              "        relpamtxt[8,17] ",          
              " from igbmparam         ",           
              " where relsgl = ?       ",           
              " and relpamseq = 0      "            
  prepare pctc83m00006  from l_sql                 
  declare cctc83m00006  cursor for pctc83m00006 
  
  let l_sql = " select relpamtxt[8,13], ",       
              "        relpamtxt[15,24] ",       
              " from igbmparam          ",       
              " where relsgl = ?        ",       
              " and relpamtxt[1,6] = ?  ",
              " and relpamseq > 0       "        
  prepare pctc83m00007  from l_sql              
  declare cctc83m00007  cursor for pctc83m00007 
  
  let l_sql = " select min(relsgl[7,18])     ",    
              " from igbmparam               ",   
              " where relsgl[1,6] = ?        ",
              " and relpamseq = 0            ",   
              " and relsgl[7,18] > ?         ",
              " and relsgl <> 'ct24hsassunto'",
              " and relsgl <> 'ct24hsatd'    "    
  prepare pctc83m00008  from l_sql                   
  declare cctc83m00008  cursor for pctc83m00008   
  
  let l_sql = " select max(relsgl[7,18])     ",        
              " from igbmparam               ",        
              " where relsgl[1,6] = ?        ",        
              " and relpamseq = 0            ",        
              " and relsgl[7,18] < ?         ",
              " and relsgl <> 'ct24hsassunto'",
              " and relsgl <> 'ct24hsatd'     "              
  prepare pctc83m00009  from l_sql                 
  declare cctc83m00009  cursor for pctc83m00009   
  
  let l_sql = " select relpamtxt[1,3]   ",            
              " from igbmparam          ",            
              " where relsgl = ?        ",            
              " order by relpamtxt[1,3] "             
  prepare pctc83m00010  from l_sql                    
  declare cctc83m00010  cursor for pctc83m00010  
  
  let l_sql = " select relpamtxt[5,10], ", 
              "        relpamtxt[12,21] ",          
              " from igbmparam          ",           
              " where relsgl = ?        ",
              " and relpamtxt[1,3] = ?  "                         
  prepare pctc83m00011  from l_sql                 
  declare cctc83m00011  cursor for pctc83m00011 
  
  let l_sql = " select count(*)       ",
              " from igbmparam        ",
              " where relsgl = ?      ",
              " and relpamtxt[1,3] = ?" 
  prepare pctc83m00012  from l_sql                
  declare cctc83m00012  cursor for pctc83m00012
  
  let l_sql = " select c24astdes       ",   
              " from datkassunto       ",  
              " where c24astcod   = ?  "   
  prepare pctc83m00013  from l_sql             
  declare cctc83m00013  cursor for pctc83m00013
  
  let l_sql = " select relsgl[7,18]          ", 
              " from igbmparam               ", 
              " where relsgl[1,6] = ?        ", 
              " and relpamseq = 0            ", 
              " and relsgl <> 'ct24hsassunto'", 
              " and relsgl <> 'ct24hsatd'    "   
  prepare pctc83m00014 from l_sql              
  declare cctc83m00014 cursor for pctc83m00014
  
  let l_sql = " select relpamtxt[1,13] ,   ",  
              "        relpamtxt[22,31],   ",
              "        relpamtxt[33,40]    ",
              " from igbmparam             ",     
              " where relsgl = ?           ",
              " order by 2 desc,3 desc     "      
  prepare pctc83m00015  from l_sql             
  declare cctc83m00015  cursor for pctc83m00015 
  
  let l_sql = " select count(*)         ",
              " from igbmparam          ",
              " where relsgl = ?        ",
              " and relpamtxt[1,13] = ? " 
  prepare pctc83m00016  from l_sql              
  declare cctc83m00016  cursor for pctc83m00016  
  
  let l_sql = " select relpamtxt[15,20], ",      
              "        relpamtxt[22,31] ",      
              " from igbmparam          ",      
              " where relsgl = ?        ",      
              " and relpamtxt[1,13] = ?  "       
  prepare pctc83m00017  from l_sql              
  declare cctc83m00017  cursor for pctc83m00017 
   
     
  let l_sql = " insert into igbmparam ",
              " values (?,?,?,?) " 
  prepare p_insert01 from l_sql 
  
  let l_sql = " delete from igbmparam ",  
              " where relsgl = ?      ",  
              " and relpamtxt[1,6] = ?"   
  prepare p_delete01 from l_sql 
  
  let l_sql = " delete from igbmparam ",  
              " where relsgl = ?      ",  
              " and relpamtxt[1,3] = ?"   
  prepare p_delete02 from l_sql 
  
  let l_sql = " delete from igbmparam ",  
              " where relsgl = ?      ",  
              " and relpamtxt[1,13] = ?"   
  prepare p_delete03 from l_sql 
  
  let l_sql = " delete from igbmparam ",  
              " where relsgl = ?      "
  prepare p_delete04 from l_sql 
  
  let m_prepare = true    
  

end function 



#------------------------------------------------------#                                                                                                                                                   
 function ctc83m00()                                                               
#------------------------------------------------------#                                                              
                                                                                   
   if m_prepare is null or                                                   
      m_prepare <> true then                                                 
      call ctc83m00_prepare()                                                      
   end if 
   
   let m_acesso = "ct24hs"  
   
   initialize mr_tela.* to null                                                                       
                                                                                   
   open window ctc83m00 at 4,2 with form "ctc83m00" 
                                                                          
   menu 'GRUPOS'                                                                
                                                                                   
      before menu                                                                  
          hide option 'Proximo'                                                    
          hide option 'Anterior'
          hide option 'Modifica'                                                   
                                                                                   
      command key('S') 'Seleciona' 'Selecionar Grupos de Atendimento'               
          call ctc83m00_input()                                                 
                                                                              
          if mr_tela.grupo is not null then                                             
             show option 'Proximo'                                                 
             show option 'Anterior'
             show option 'Modifica'                                                   
          else                                                                     
             hide option 'Proximo'                                                 
             hide option 'Anterior' 
             hide option 'Modifica'                                                 
          end if                                                                   
                                                                                   
      command key('P') 'Proximo' 'Proximo Grupo de Atendimento'                     
          call ctc83m00_posicao('P')                                               
                                                                                   
      command key('A') 'Anterior' 'Grupo Anterior de Atendimento'                   
          call ctc83m00_posicao('A')                                               
                                                                                                 
      command key('M') 'Modifica' 'Modifica Usuarios'                                          
          call ctc83m00_input_array()                                                                                          
                                             
      command key('R') 'Relaciona' 'Relaciona Grupos de Atendimento'              
          call ctc83m00_relaciona() 
          
      command key('T') 'Assunto' 'Cadastra Assuntos para Atendimento'       
          call ctc83m00_assunto()                                      
                                                                                         
      command key('E') 'Encerrar' 'Sair do menu'                                   
         exit menu                                                                 
                                                                                   
   end menu                                                                        
                                                                                   
   close window ctc83m00                                                         
                                                                                   
   let int_flag = false                                                            
                                                                                   
 end function 

#------------------------------------------------------#         
function ctc83m00_input()
#------------------------------------------------------#         

define lr_retorno record
   chave char(18),
   cont integer  ,
   erro integer
end record

initialize lr_retorno.* to null 

   let mr_tela.obs = " <F1> - Inclui <F2> - Exclui <F5> - Exclui Grupo Ctrl<C> - Abandona" 
                                            
 
   input by name mr_tela.grupo without defaults
   
   before field grupo
      display by name mr_tela.grupo attribute (reverse)       
      display by name mr_tela.obs
       
   after field grupo
     display by name mr_tela.grupo  
     
     if mr_tela.grupo is not null then
        
        let lr_retorno.chave = m_acesso, mr_tela.grupo
      
        open cctc83m00001 using lr_retorno.chave
        
        fetch cctc83m00001 into lr_retorno.cont
        
        close cctc83m00001 
        
        if lr_retorno.cont = 0 then
        
             if cts08g01("C","S","NAO FOI ENCONTRADO NENHUM GRUPO ", 
                         "PARA CHAVE INFORMADA!","", 
                         "INCLUI UM NOVO GRUPO?") = "S"  then
                  
                  
                  let lr_retorno.erro = ctc83m00_insere_grupo(lr_retorno.chave)       
                  
                  if lr_retorno.erro <> 0 then
                    next field grupo
                  end if
                  
                  call ctc83m00_rec_inc_grupo(lr_retorno.chave) 
             
             else
                  next field grupo
             end if   
        else
            call ctc83m00_input_array()                                                                                                          
        end if        
        
     else
        
        let mr_tela.grupo = ctc83m00_popup()
        display by name mr_tela.grupo
        next field grupo
        
     end if
     
     on key (interrupt)   
         exit input             
  
     
   end input
 
end function

#------------------------------------------------------#        
function ctc83m00_posicao(lr_param)    
#------------------------------------------------------#  

define lr_param record
  posicao char(1)
end record

define l_grupo char(18)

let l_grupo = null
  
  case lr_param.posicao
     when "P" 
     
        open cctc83m00008 using m_acesso      ,
                                mr_tela.grupo
        
        whenever error continue                            
        fetch  cctc83m00008 into l_grupo        
        whenever error stop
     
        if sqlca.sqlcode <> 0 then                                                                                                                                                                                                                                              
              error "Erro SELECT cctc83m00008: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na selecao da tabela igbmparam "                                                                                                                                                                                                                                                                                                                                                                                                                          
        end if
        
     when "A"
         
         open cctc83m00009 using m_acesso      ,                                                                                                                                         
                                 mr_tela.grupo                                                                                                                                           
                                                                                                                                                                                         
         whenever error continue                                                                                                                                                         
         fetch  cctc83m00009 into l_grupo                                                                                                                                          
         whenever error stop                                                                                                                                                             
                                                                                                                                                                                         
         if sqlca.sqlcode <> 0 then                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
               error "Erro SELECT cctc83m00009: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na selecao da tabela igbmparam "                                                                                                                                                                                                                                       
         end if                                                                                                                                                                          
              
   end case
   
   
   if l_grupo is null then
       error 'Nao Existem mais Registros nesta Direcao!'  
   else
       let mr_tela.grupo = l_grupo
   end if                                                                            
        
   call ctc83m00_display_grupo()
   call ctc83m00_consulta_array()
                                                                                                      
end function 

#------------------------------------------------------#         
function ctc83m00_consulta_array()                                  
#------------------------------------------------------# 

define a_ctc83m00 array[500] of record  
  seta   char(1)               ,      
  funmat like isskfunc.funmat  ,      
  funnom like isskfunc.funnom  ,      
  dptnom like isskdepto.dptnom        
end record  


define lr_retorno record           
   funmat like isskfunc.funmat ,   
   funnom like isskfunc.funnom ,   
   dptnom like isskdepto.dptnom,   
   erro   smallint             ,   
   chave  char(18)                 
end record                         
                                   
define arr_aux  integer            
define scr_aux  integer 
define l_exit   smallint

   
 
  for  arr_aux  =  1  to  500                         
     initialize  a_ctc83m00[arr_aux].* to  null     
  end  for                                          
    

  let lr_retorno.chave = m_acesso, mr_tela.grupo        
                                                        
  let arr_aux  = 0   
  let l_exit   = 0                                                               
                                                        
  call ctc83m00_rec_inc_grupo(lr_retorno.chave)          
                                                        
                                                        
  open cctc83m00002 using lr_retorno.chave              
                                                        
  foreach cctc83m00002 into lr_retorno.funmat           
                                                        
    call ctc83m00_rec_dados(lr_retorno.funmat,0)        
    returning lr_retorno.erro   ,                       
              lr_retorno.funnom ,                       
              lr_retorno.dptnom                         
                                                        
    let arr_aux = arr_aux + 1                           
                                                        
    let a_ctc83m00[arr_aux].funmat = lr_retorno.funmat  
    let a_ctc83m00[arr_aux].funnom = lr_retorno.funnom  
    let a_ctc83m00[arr_aux].dptnom = lr_retorno.dptnom  
    
                                                           
  end foreach                                           
                                                        
  call set_count(arr_aux)                                                     
                                                             
  input array a_ctc83m00 without defaults from s_ctc83m00.*   
 
   before row
     call ctc83m00_rec_atualizado(lr_retorno.chave         ,     
                                  a_ctc83m00[1].funmat)        
     exit input
    
  end input
 
 

end function
      
#------------------------------------------------------#        
function ctc83m00_input_array()        
#------------------------------------------------------#  


define a_ctc83m00 array[500] of record                                            
  seta   char(1)               ,                                                  
  funmat like isskfunc.funmat  ,                                                  
  funnom like isskfunc.funnom  ,                                                  
  dptnom like isskdepto.dptnom                                                    
end record                                                                        
                                                                                  
define lr_retorno record                                                          
   funmat like isskfunc.funmat ,                                                  
   funnom like isskfunc.funnom ,                                                  
   dptnom like isskdepto.dptnom,                                                  
   erro   smallint             ,                                                  
   chave  char(18)             ,
   cont   integer                                                                
end record                                                                        
                                                                                  
define arr_aux  integer                                                           
define scr_aux  integer                                                           
define l_troca  smallint                                                          
define l_delete smallint                                                          
                                                                                  
initialize lr_retorno.* to null                                                   
                                                                                  
for  arr_aux  =  1  to  500                                                       
   initialize  a_ctc83m00[arr_aux].* to  null                                     
end  for 

   if mr_tela.grupo is null then
      return
   end if                                                                        
                                                                                  
   let lr_retorno.chave = m_acesso, mr_tela.grupo                                 
                                                                                  
   let arr_aux  = 0                                                               
   let l_delete = null                                                            
                                                                                  
   call ctc83m00_rec_inc_grupo(lr_retorno.chave)                                   
                                                                                  
                                                                                  
   open cctc83m00002 using lr_retorno.chave                                       
                                                                                  
   foreach cctc83m00002 into lr_retorno.funmat                                    
                                                                                  
     call ctc83m00_rec_dados(lr_retorno.funmat,0)                                 
     returning lr_retorno.erro   ,                                                
               lr_retorno.funnom ,                                                
               lr_retorno.dptnom                                                  
                                                                                  
     let arr_aux = arr_aux + 1                                                    
                                                                                  
     let a_ctc83m00[arr_aux].funmat = lr_retorno.funmat                           
     let a_ctc83m00[arr_aux].funnom = lr_retorno.funnom                           
     let a_ctc83m00[arr_aux].dptnom = lr_retorno.dptnom                           
                                                                                  
                                                                                  
   end foreach 
   
   options insert   key F1  
   options delete   key F2                                                                     
                                                                                  
   call set_count(arr_aux)                                                        
                                                                                  
   input array a_ctc83m00 without defaults from s_ctc83m00.*                      
                                                                                  
     before row                                                                   
         let arr_aux  = arr_curr()                                                
         let scr_aux  = scr_line()                                                
                                                                                  
     before insert                                                                
         if l_delete = 1              and
            arr_curr() = arr_count() then                                                     
              let l_delete = 0                                                    
              next field seta                                                     
         end if                                                                   
                                                                                  
         let l_troca = 1                                                          
         next field funmat                                                        
                                                                                  
     before field seta                                                            
         call ctc83m00_rec_atualizado(lr_retorno.chave         ,                  
                                      a_ctc83m00[arr_aux].funmat)                 
                                                                                  
     after field seta                                                             
                                                                                  
      if  fgl_lastkey() = fgl_keyval("down") then                                 
          if arr_curr() = arr_count() then                                        
              next field seta                                                     
          end if                                                                            
      end if                                                                      
                                                                                  
      if  fgl_lastkey() = fgl_keyval("right") then                                
              next field seta                                                                                               
      end if                                                                      
                                                                                  
     before field funmat                                                          
       if l_troca = 0 then                                                        
          next field seta                                                         
       end if                                                                     
                                                                                  
       display  a_ctc83m00[arr_aux].funmat to s_ctc83m00[scr_aux].funmat attribute (reverse)    
                                                                                  
     after field funmat                                                           
       display  a_ctc83m00[arr_aux].funmat to s_ctc83m00[scr_aux].funmat          
                                                                                  
       if  fgl_lastkey() = fgl_keyval("down") or                                  
           fgl_lastkey() = fgl_keyval("up")   or                                  
           fgl_lastkey() = fgl_keyval("left") or                                  
           fgl_lastkey() = fgl_keyval("right")then                                
               error "Cadastre a Matricula ou tecle F2 para sair"                 
               next field funmat                                                           
       end if                                                                     
                                                                                  
                                                                                  
                                                                                  
       if a_ctc83m00[arr_aux].funmat is null then                                 
           error "Matricula do Funcionario deve ser Informada!"                   
       else                                                                       
                                                                                  
           call ctc83m00_ver_exist_grupo(a_ctc83m00[arr_aux].funmat,               
                                         lr_retorno.chave          )               
           returning lr_retorno.erro                                              
                                                                                  
           if lr_retorno.erro <> 0 then                                           
              error "Matricula ja Cadastrada para esse Grupo!"                    
              next field funmat                                                   
           end if                                                                 
                                                                                  
           call ctc83m00_rec_dados(a_ctc83m00[arr_aux].funmat,1)                  
           returning lr_retorno.erro   ,                                          
                     lr_retorno.funnom ,                                          
                     lr_retorno.dptnom                                            
                                                                                  
           if lr_retorno.erro <> 0 then                                           
              next field funmat                                                   
           else                                                                   
                                                                                  
              let a_ctc83m00[arr_aux].funnom = lr_retorno.funnom                  
              let a_ctc83m00[arr_aux].dptnom = lr_retorno.dptnom                  
                                                                                  
              display a_ctc83m00[arr_aux].funmat to s_ctc83m00[scr_aux].funmat    
              display a_ctc83m00[arr_aux].funnom to s_ctc83m00[scr_aux].funnom    
              display a_ctc83m00[arr_aux].dptnom to s_ctc83m00[scr_aux].dptnom    
                                                                                  
              let lr_retorno.erro = ctc83m00_insere_matricula(lr_retorno.chave,
                                                              a_ctc83m00[arr_aux].funmat)
              
              if lr_retorno.erro <> 0 then      
                 next field funmat              
              end if 
              
              call ctc83m00_rec_atualizado(lr_retorno.chave         ,           
                                           a_ctc83m00[arr_aux].funmat)
                                           
           end if
       end if 
              
       before delete
          call ctc83m00_ver_exist_grupo(a_ctc83m00[arr_aux].funmat,  
                                        lr_retorno.chave          )  
          returning lr_retorno.erro
              
          if lr_retorno.erro <> 0 then  
                                       
             call ctc83m00_deleta_matricula(a_ctc83m00[arr_aux].funmat,
                                            lr_retorno.chave          ) 
             returning lr_retorno.erro
              
             if lr_retorno.erro <> 0 then                       
                next field funmat
             end if                     
              
          end if
               
          let l_troca  = 0
              
      after delete
          let l_delete = 1
                                
              
     on key (interrupt)   
       display  a_ctc83m00[arr_aux].funmat to s_ctc83m00[scr_aux].funmat    
         exit input
         
     on key (f5) 
     
         if mr_tela.grupo is not null then
                    
             let lr_retorno.erro = ctc83m00_ver_exist_atd(mr_tela.grupo,
                                                          "ct24hsatd")
                                                        
                                                          
             if lr_retorno.erro = 1 then
                  error "Erro: Grupo Relacionado para Atendimento, Desrelacione esse Grupo"
             else                 
                                                            
                  let lr_retorno.chave = m_acesso, mr_tela.grupo  
                                                                  
                  open cctc83m00001 using lr_retorno.chave        
                                                                  
                  fetch cctc83m00001 into lr_retorno.cont         
                                                                  
                  close cctc83m00001                              
                                                                  
                  if cts08g01("C","S","DESEJA EXCLUIR ",  
                              lr_retorno.cont-1,
                              " MATRICULA(S) DESSE GRUPO?",                  
                              "") = "S"  then  
                              
                        let lr_retorno.erro = ctc83m00_deleta_grupo(lr_retorno.chave)
                        
                        if lr_retorno.erro = 0 then
                            let mr_tela.grupo = null
                            clear form
                            exit input
                        end if                                
                  
                  end if 
              end if
          end if
                              
   end input                              
                                                
              
end function  
              
#------------------------------------------------------#        
function ctc83m00_relaciona()                    
#------------------------------------------------------#  

  let m_sair = false
  let m_f5   = false  
                                                                            
  open window ctc83m00b at 7,2 with form "ctc83m00b"   
  
  let mr_tela.obs = "<F1> - Inclui  <F2> - Exclui  <F5> - Troca Menu  Ctrl<C> - Abandona " 
  display by name mr_tela.obs                                             
                       
  call ctc83m00_array_atendimento(1)
  call ctc83m00_array_existente(0)

  close window ctc83m00b                                  
              
end function 


#------------------------------------------------------#    
function ctc83m00_array_existente(lr_param)                               
#------------------------------------------------------#    

define lr_param record
  consulta smallint
end record

define a_ctc83m00b1 array[500] of record 
     seta1  char(1)  ,       
     grpexi char(13)               
end record 

define lr_retorno record
     chave char(18) ,
     erro  integer
end record

define arr_aux integer 

initialize lr_retorno.* to null

for  arr_aux  =  1  to  500                               
   initialize  a_ctc83m00b1[arr_aux].* to  null    
end  for                                                                     
            
    
    let mr_tela.atd = "atd"
    
    let lr_retorno.chave = m_acesso, mr_tela.atd 
        
    let arr_aux = 1
    
    open cctc83m00014 using m_acesso
    
    foreach cctc83m00014 into a_ctc83m00b1[arr_aux].grpexi 
    
      let arr_aux = arr_aux + 1
      
    end foreach
    
    options insert   key F40  
    options delete   key F35  
    options next     key F30  
    options previous key F25  
       
    call set_count(arr_aux-1) 
    input array a_ctc83m00b1 without defaults from s_ctc83m00b1.*  
    
     before row                    
         let arr_aux  = arr_curr() 
         
         call ctc83m00_rec_rel_atd(lr_retorno.chave            , 
                                   a_ctc83m00b1[arr_aux].grpexi) 
    
     after field seta1     
         
         if  fgl_lastkey() = fgl_keyval("down") then        
             if arr_curr() = arr_count() then               
                 next field seta1                            
             end if                                         
         end if 
         
     on key(f1)
     
         if a_ctc83m00b1[arr_aux].grpexi is not null then 
     
                call ctc83m00_ver_exist_atd(a_ctc83m00b1[arr_aux].grpexi,   
                                            lr_retorno.chave             )   
                returning lr_retorno.erro                                        
                                                                                 
                if lr_retorno.erro <> 0 then                                     
                   error "Grupo ja Relacionado!"                                
                   next field seta1                                         
                end if                                                           
                
                call ctc83m00_insere_atd(lr_retorno.chave            ,
                                         a_ctc83m00b1[arr_aux].grpexi)
                returning lr_retorno.erro
                
                if lr_retorno.erro <> 0 then
                   next field seta1
                end if  
                
                call ctc83m00_array_atendimento(1)
          end if
         
      on key(f5) 
         let m_f5 = true
         call ctc83m00_array_atendimento(0)
         
         if m_sair = true then
            exit input
         end if 
                                                      
      on key (interrupt)
          if m_f5 = true then
             let m_sair = true
          end if
                                                                             
          exit input 
        
    end input                                     
                        
                        
end function  

#------------------------------------------------------#                               
function ctc83m00_array_atendimento(lr_param)                                            
#------------------------------------------------------#                               
                                                                                       
define lr_param record                                                                 
  consulta smallint                                                                             
end record                                                                             
                                                                                       
define a_ctc83m00b2 array[500] of record                                               
     seta2  char(1)  ,                                                                 
     grpatd char(13)                                                                   
end record                                                                             
                                                                                       
define lr_retorno record                                                               
     chave char(18) ,                                                                  
     erro  integer  ,
     data  date     ,
     hora  char(7)                                                                      
end record                                                                             
                                                                                       
define arr_aux integer                                                                 
                                                                                       
initialize lr_retorno.* to null                                                        
                                                                                       
for  arr_aux  =  1  to  500                                                            
   initialize  a_ctc83m00b2[arr_aux].* to  null                                        
end  for                                                                               
                                                                                       
                                                                                       
    let mr_tela.atd = "atd"                                                            
                                                                                       
    let lr_retorno.chave = m_acesso, mr_tela.atd                                       
                                                                                                                                                                             
    let arr_aux = 1                                                                    
                                                                                       
    open cctc83m00015  using lr_retorno.chave                                                  
                                                                                       
    foreach cctc83m00015 into a_ctc83m00b2[arr_aux].grpatd,
                              lr_retorno.data             ,
                              lr_retorno.hora                             
                                                                                       
      let arr_aux = arr_aux + 1                                                        
                                                                                       
    end foreach                                                                        
                                                                                       
    options insert   key F40                                                           
    options delete   key F35                                                           
    options next     key F30                                                           
    options previous key F25                                                           
                                                                                       
    call set_count(arr_aux-1)                                                          
    input array a_ctc83m00b2 without defaults from s_ctc83m00b2.*                      
                                                                                       
     before row                                                                        
         let arr_aux  = arr_curr()
         
         if lr_param.consulta = 1 then
            exit input
         end if   
         
         call ctc83m00_rec_rel_atd(lr_retorno.chave            ,
                                   a_ctc83m00b2[arr_aux].grpatd)
                                                           
                                                                                       
     after field seta2                                                                 
                                                                                       
         if  fgl_lastkey() = fgl_keyval("down") then                                   
             if arr_curr() = arr_count() then                                          
                 next field seta2                                                      
             end if                                                                    
         end if
                                                                                 
                                                                                       
     on key(f2)    
     
         if a_ctc83m00b2[arr_aux].grpatd is not null then
                                                                                                                                                         
              call ctc83m00_deleta_atd(a_ctc83m00b2[arr_aux].grpatd,
                                       lr_retorno.chave            )                        
              returning lr_retorno.erro                                                     
                                                                                            
              if lr_retorno.erro <> 0 then                                                  
                 next field seta2
              else
                   initialize a_ctc83m00b2[arr_aux].*    to  null
                   display a_ctc83m00b2[arr_aux].grpatd  to  s_ctc83m00b2[arr_aux].grpatd                                                            
              end if
         
         end if
         
     on key(f5)                            
                                           
        call ctc83m00_array_existente(1) 
        
        if m_sair = true then
           exit input                                                                             
        end if                                                                                              
      
     on key (interrupt) 
        if m_f5 = true then   
           let m_sair = true  
        end if                                                                          
        
        exit input                                                                   
                                                                                       
    end input                                                                          
                                                                                       
                                                                                       
end function                                                                           
  
              
#------------------------------------------------------#         
function ctc83m00_insere_grupo(lr_param)
#------------------------------------------------------#        
              
define lr_param record
   chave char(18)
end record    
              
define lr_retorno record
    erro integer,
    seq  smallint,
    txt  char(50)
end record    
              
initialize lr_retorno.* to null
              
let lr_retorno.erro = 0    
let lr_retorno.seq  = 0
              
              
     let lr_retorno.txt = g_issk.funmat   using "&&&&&&","|",       
                          today,"|",current hour to minute        
              
     whenever error continue                       
     execute p_insert01 using lr_param.chave    
                             ,lr_retorno.seq    
                             ,""  
                             ,lr_retorno.txt                                  
     whenever error stop 
              
      if sqlca.sqlcode <> 0  then
        error "Erro INSERT p_insert01: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na insercao da tabela igbmparam "                                                         
        let lr_retorno.erro = 1
      else    
        error "Grupo Cadastrado com Sucesso" 
      end if  
              
     return lr_retorno.erro
              
end function  
              
#------------------------------------------------------#                                                                                                                                                                        
function ctc83m00_insere_matricula(lr_param)                                                                                                                                                                                        
#------------------------------------------------------#                                                                                                                                                                        
                                                                                                                                                                                                                                
define lr_param record                                                                                                                                                                                                          
   chave  char(18)        ,
   funmat like isskfunc.funmat                                                                                                                                                                                                                
end record                                                                                                                                                                                                                      
                                                                                                                                                                                                                                
define lr_retorno record                                                                                                                                                                                                        
    erro integer  ,                                                                                                                                                                                                               
    seq  integer  ,
    txt  char(50)                                                                                                                                                                                                              
end record                                                                                                                                                                                                                      
                                                                                                                                                                                                                                
initialize lr_retorno.* to null                                                                                                                                                                                                 
                                                                                                                                                                                                                                
let lr_retorno.erro = 0                                                                                                                                                                                                         
              
              
     open cctc83m00004 using lr_param.chave
              
     fetch cctc83m00004 into lr_retorno.seq 
              
     close  cctc83m00004 
              
     let lr_retorno.txt = lr_param.funmat using "&&&&&&","|",
                          g_issk.funmat   using "&&&&&&","|",
                          today,"|",current hour to minute                                                                                                                                                                                              
                                                                                                                                                                                                                              
     whenever error continue                                                                                                                                                                                                    
     execute p_insert01 using lr_param.chave                                                                                                                                                                                    
                             ,lr_retorno.seq                                                                                                                                                                                    
                             ,""                                                                                                                                                                                                
                             ,lr_retorno.txt                                                                                                                                                                                                
     whenever error stop                                                                                                                                                                                                        
                                                                                                                                                                                                                                
      if sqlca.sqlcode <> 0  then                                                                                                                                                                                               
        error "Erro INSERT p_insert01: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na insercao da tabela igbmparam "                                                                                                             
        let lr_retorno.erro = 1                                                                                                                                                                                                 
      else                                                                                                                                                                                                                      
        error "Matricula Cadastrada com Sucesso"                                                                                                                                                                            
      end if                                                                                                                                                                                                                    
                                                                                                                                                                                                                                
     return lr_retorno.erro                                                                                                                                                                                                     
                                                                                                                                                                                                                                
end function   

#------------------------------------------------------#      
function ctc83m00_insere_atd(lr_param)                      
#------------------------------------------------------#  

define lr_param record              
   chave  char(18)        ,      
   grupo  char(13)   
end record 

define lr_retorno record
   erro integer ,
   seq  integer ,
   txt  char(50)
end record

     let lr_retorno.erro = 0

     open cctc83m00004 using lr_param.chave     
                                                
     fetch cctc83m00004 into lr_retorno.seq     
                                                
     close  cctc83m00004                        
                                                                      
     if lr_retorno.seq is null then             
        let lr_retorno.seq = 0                  
     end if 
     
     let lr_retorno.txt = lr_param.grupo ,"|",                                                                                                                     
                          g_issk.funmat   using "&&&&&&","|",                                                                                                          
                          today,"|",current hour to minute                                                                                                             
                                                                                                                                                                       
     whenever error continue                                                                                                                                           
     execute p_insert01 using lr_param.chave                                                                                                                           
                             ,lr_retorno.seq                                                                                                                           
                             ,""                                                                                                                                       
                             ,lr_retorno.txt                                                                                                                           
     whenever error stop                                                                                                                                               
                                                                                                                                                                       
      if sqlca.sqlcode <> 0  then                                                                                                                                      
        error "Erro INSERT p_insert01: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na insercao da tabela igbmparam "                                                    
        let lr_retorno.erro = 1                                                                                                                                        
      else                                                                                                                                                             
        error "Grupo de Atendimento Cadastrado com Sucesso"                                                                                                                         
      end if                                                                                                                                                           
                                                                                                                                                                       
     return lr_retorno.erro                                                                                                                                            
     
                                        
end function


#------------------------------------------------------#                                                                                        
function ctc83m00_insere_assunto(lr_param)                                                                                                    
#------------------------------------------------------#                                                                                        
                                                                                                                                                
define lr_param record                                                                                                                          
   chave     char(18)                   ,                                                                                                                     
   c24astcod like datkassunto.c24astcod                                                                                                                 
end record                                                                                                                                      
                                                                                                                                                
define lr_retorno record                                                                                                                        
    erro integer  ,                                                                                                                             
    seq  smallint ,                                                                                                                             
    txt  char(50)                                                                                                                               
end record                                                                                                                                      
                                                                                                                                                
initialize lr_retorno.* to null                                                                                                                 
                                                                                                                                                
let lr_retorno.erro = 0                                                                                                                         
                                                                                                                                                
                                                                                                                                                
     open cctc83m00004 using lr_param.chave                                                                                                     
                                                                                                                                                
     fetch cctc83m00004 into lr_retorno.seq                                                                                                     
                                                                                                                                                
     close  cctc83m00004    
     
     if lr_retorno.seq is null then
        let lr_retorno.seq = 0
     end if 
            
                                                                                                                                                                                                                                                                       
     let lr_retorno.txt = lr_param.c24astcod ,"|",                                                                                   
                          g_issk.funmat   using "&&&&&&","|",                                                                                   
                          today,"|",current hour to minute                                                                                      
                                                                                                                                                
     whenever error continue                                                                                                                    
     execute p_insert01 using lr_param.chave                                                                                                    
                             ,lr_retorno.seq                                                                                                    
                             ,""                                                                                                                
                             ,lr_retorno.txt                                                                                                    
     whenever error stop                                                                                                                        
                                                                                                                                                
      if sqlca.sqlcode <> 0  then                                                                                                               
        error "Erro INSERT p_insert01: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na insercao da tabela igbmparam "                             
        let lr_retorno.erro = 1                                                                                                                 
      else                                                                                                                                      
        error "Assunto Cadastrado com Sucesso"                                                                                                
      end if                                                                                                                                    
                                                                                                                                                
     return lr_retorno.erro                                                                                                                     
                                                                                                                                                
end function                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                  

#------------------------------------------------------# 
function ctc83m00_rec_dados(lr_param)                      
#------------------------------------------------------#

define lr_param record
   funmat  like isskfunc.funmat,
   critica smallint  
end record

define lr_retorno record
   funnom like isskfunc.funnom,   
   dptnom like isskdepto.dptnom,
   erro   smallint   
end record


initialize lr_retorno.* to null 

let lr_retorno.erro = 0

   open cctc83m00003 using lr_param.funmat
   
   fetch cctc83m00003 into lr_retorno.funnom,
                           lr_retorno.dptnom
                           
   
   if lr_param.critica = 1 then  
       if sqlca.sqlcode <> 0  then                                                                                                                                                                                                                     
          if sqlca.sqlcode = notfound then
            error "Matricula Inexistente!"
          else 
            error "Erro SELECT cctc83m00003: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na insercao da tabela isskfunc "                                                                                                                                    
          end if
          let lr_retorno.erro = 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
       end if   
   end if
   
   return lr_retorno.erro   ,
          lr_retorno.funnom ,
          lr_retorno.dptnom

end function 

#------------------------------------------------------#                                                                                                                                                                                                                                                                                                                            
function ctc83m00_rec_assunto(lr_param)                                                                                                                                                                                                                                                                                                                                               
#------------------------------------------------------#                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                    
define lr_param record                                                                                                                                                                                                                                                                                                                                                              
   c24astcod like datkassunto.c24astcod ,                                                                                                                                                                                                                                                                                                                                                    
   critica   smallint                                                                                                                                                                                                                                                                                                                                                                 
end record                                                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                    
define lr_retorno record                                                                                                                                                                                                                                                                                                                                                            
   c24astdes like datkassunto.c24astdes ,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
   erro   smallint                                                                                                                                                                                                                                                                                                                                                                  
end record                                                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                    
initialize lr_retorno.* to null                                                                                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                                                                                    
let lr_retorno.erro = 0                                                                                                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                                                                                    
   open cctc83m00013 using lr_param.c24astcod                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                    
   fetch cctc83m00013 into lr_retorno.c24astdes                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                                    
   if lr_param.critica = 1 then                                                                                                                                                                                                                                                                                                                                                     
       if sqlca.sqlcode <> 0  then                                                                                                                                                                                                                                                                                                                                                  
          if sqlca.sqlcode = notfound then                                                                                                                                                                                                                                                                                                                                          
            error "Assunto Inexistente!"                                                                                                                                                                                                                                                                                                                                          
          else                                                                                                                                                                                                                                                                                                                                                                      
            error "Erro SELECT cctc83m00013: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na insercao da tabela datkassunto "                                                                                                                                                                                                                                                            
          end if                                                                                                                                                                                                                                                                                                                                                                    
          let lr_retorno.erro = 1                                                                                                                                                                                                                                                                                                                                                   
       end if                                                                                                                                                                                                                                                                                                                                                                       
   end if                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                                    
   return lr_retorno.erro    ,                                                                                                                                                                                                                                                                                                                                                       
          lr_retorno.c24astdes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                    
end function                                                                                                                                                                                                                                                                                                                                                                        


#------------------------------------------------------# 
function ctc83m00_ver_exist_grupo(lr_param)                    
#------------------------------------------------------# 

define lr_param record                   
   funmat char(6),
   chave  char(18)                           
end record                               
                                         
define lr_retorno record                          
   erro   smallint ,
   cont   integer                       
end record                                    

 
initialize lr_retorno.* to null 

let lr_retorno.erro = 0 
   
   let lr_param.funmat = lr_param.funmat using "&&&&&&"
   
   open cctc83m00005 using lr_param.chave ,
                           lr_param.funmat 
   
   fetch cctc83m00005 into lr_retorno.cont
   
   close cctc83m00005
   
   if lr_retorno.cont > 0 then
      let lr_retorno.erro = 1
   else
      let lr_retorno.erro = 0
   end if
   
   return lr_retorno.erro
   
end function

#------------------------------------------------------#                                                 
function ctc83m00_ver_exist_assunto(lr_param)                                                              
#------------------------------------------------------#                                                 
                                                                                                         
define lr_param record                                                                                   
   c24astcod like datkassunto.c24astcod ,                                                                                     
   chave     char(18)                                                                                       
end record                                                                                               
                                                                                                         
define lr_retorno record                                                                                 
   erro   smallint ,                                                                                     
   cont   integer                                                                                        
end record                                                                                               
                                                                                                         
                                                                                                         
initialize lr_retorno.* to null                                                                          
                                                                                                         
let lr_retorno.erro = 0                                                                                  
                                                                                                                                                                                                                                                                    
   open cctc83m00012 using lr_param.chave ,                                                              
                           lr_param.c24astcod                                                               
                                                                                                         
   fetch cctc83m00012 into lr_retorno.cont                                                               
                                                                                                         
   close cctc83m00012                                                                                    
                                                                                                         
   if lr_retorno.cont > 0 then                                                                           
      let lr_retorno.erro = 1                                                                            
   else                                                                                                  
      let lr_retorno.erro = 0                                                                            
   end if                                                                                                
                                                                                                         
   return lr_retorno.erro                                                                                
                                                                                                         
end function

#------------------------------------------------------#              
function ctc83m00_ver_exist_atd(lr_param)                         
#------------------------------------------------------#              
                                                                      
define lr_param record                                                
   grupo  char(13) ,                            
   chave  char(18)                                                 
end record                                                            
                                                                      
define lr_retorno record                                              
   erro   smallint ,                                                  
   cont   integer                                                     
end record                                                            
                                                                      
                                                                      
initialize lr_retorno.* to null                                       
                                                                      
let lr_retorno.erro = 0                                               
                                                                      
   open cctc83m00016 using lr_param.chave ,                           
                           lr_param.grupo                         
                                                                      
   fetch cctc83m00016 into lr_retorno.cont                            
                                                                      
   close cctc83m00016                                                 
                                                                      
   if lr_retorno.cont > 0 then                                        
      let lr_retorno.erro = 1                                         
   else                                                               
      let lr_retorno.erro = 0                                         
   end if                                                             
                                                                      
   return lr_retorno.erro                                             
                                                                      
end function                                                          
                                                                                             
                                                                                                           
#------------------------------------------------------#   
function ctc83m00_deleta_matricula(lr_param)
#------------------------------------------------------#   

define lr_param record    
   funmat char(6),           
   chave  char(18)                                                                                                                                                                                                               
end record                
                          
define lr_retorno record  
   erro   smallint        
end record    

initialize lr_retorno.* to null

   let lr_retorno.erro = 0              

   let lr_param.funmat = lr_param.funmat using "&&&&&&" 

   whenever error continue                                                                                                                                                                                                                                                                                             
   execute p_delete01 using lr_param.chave                                                                                                                                                                                                                                                                             
                           ,lr_param.funmat                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
   whenever error stop                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                       
    if sqlca.sqlcode <> 0  then                                                                                                                                                                                                                                                                                        
      error "Erro DELETE p_delete01: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na delecao da tabela igbmparam "                                                                                                                                                                                                      
      let lr_retorno.erro = 1                                                                                                                                                                                                                                                                                          
    else                                                                                                                                                                                                                                                                                                               
      error "Matricula Deletada com Sucesso"                                                                                                                                                                                                                                                                  
    end if 
    
    return lr_retorno.erro
    
end function  

#------------------------------------------------------#   
function ctc83m00_deleta_assunto(lr_param)
#------------------------------------------------------#   

define lr_param record    
   c24astcod like datkassunto.c24astcod ,          
   chave  char(18)                                                                                                                                                                                                               
end record                
                          
define lr_retorno record  
   erro   smallint        
end record    

initialize lr_retorno.* to null

   let lr_retorno.erro = 0              

   whenever error continue                                                                                                                                                                                                                                                                                             
   execute p_delete02 using lr_param.chave                                                                                                                                                                                                                                                                             
                           ,lr_param.c24astcod                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
   whenever error stop                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                       
    if sqlca.sqlcode <> 0  then                                                                                                                                                                                                                                                                                        
      error "Erro DELETE p_delete02: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na delecao da tabela igbmparam "                                                                                                                                                                                                      
      let lr_retorno.erro = 1                                                                                                                                                                                                                                                                                          
    else                                                                                                                                                                                                                                                                                                               
      error "Assunto Deletado com Sucesso"                                                                                                                                                                                                                                                                  
    end if 
    
    return lr_retorno.erro
    
end function  

#------------------------------------------------------#                                                                                                                                                                                             
function ctc83m00_deleta_atd(lr_param)                                                                                                                                                                                                           
#------------------------------------------------------#                                                                                                                                                                                             
                                                                                                                                                                                                                                                     
define lr_param record                                                                                                                                                                                                                               
   grupo  char(13),                                                                                                                                                                                                            
   chave  char(18)                                                                                                                                                                                                                                   
end record                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                     
define lr_retorno record                                                                                                                                                                                                                             
   erro   smallint                                                                                                                                                                                                                                   
end record                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                     
initialize lr_retorno.* to null  

   let lr_retorno.erro = 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
   whenever error continue                                                                                                                                                                                                                           
   execute p_delete03 using lr_param.chave                                                                                                                                                                                                           
                           ,lr_param.grupo                                                                                                                                                                                                       
                                                                                                                                                                                                                                                     
   whenever error stop                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                     
    if sqlca.sqlcode <> 0  then                                                                                                                                                                                                                      
      error "Erro DELETE p_delete03: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na delecao da tabela igbmparam "                                                                                                                                     
      let lr_retorno.erro = 1                                                                                                                                                                                                                        
    else                                                                                                                                                                                                                                             
      error "Grupo Desrelacionado com Sucesso"                                                                                                                                                                                                           
    end if                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                     
    return lr_retorno.erro                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                     
end function 

#------------------------------------------------------#                                                                                                                                          
function ctc83m00_deleta_grupo(lr_param)                                                                                                                                                            
#------------------------------------------------------#                                                                                                                                          
                                                                                                                                                                                                  
define lr_param record                                                                                                                                                                                                                                                                                                                                            
   chave  char(18)                                                                                                                                                                                
end record                                                                                                                                                                                        
                                                                                                                                                                                                  
define lr_retorno record                                                                                                                                                                          
   erro   smallint                                                                                                                                                                                
end record                                                                                                                                                                                        
                                                                                                                                                                                                  
initialize lr_retorno.* to null  

   let lr_retorno.erro = 0                                                                                                                                                                               
                                                                                                                                                                                                  
   whenever error continue                                                                                                                                                                        
   execute p_delete04 using lr_param.chave                                                                                                                                                        
                                                                                                                                                                                
                                                                                                                                                                                                  
   whenever error stop                                                                                                                                                                            
                                                                                                                                                                                                  
    if sqlca.sqlcode <> 0  then                                                                                                                                                                   
      error "Erro DELETE p_delete04: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," na delecao da tabela igbmparam "                                                                                  
      let lr_retorno.erro = 1                                                                                                                                                                     
    else                                                                                                                                                                                          
      error "Grupo Deletado com Sucesso"                                                                                                                                                    
    end if                                                                                                                                                                                        
                                                                                                                                                                                                  
    return lr_retorno.erro                                                                                                                                                                        
                                                                                                                                                                                                  
end function                                                                                                                                                                                                                                                                                                                                                                                                                             

#------------------------------------------------------#                                                                                                                                                                                                                                                                                                           
function ctc83m00_rec_inc_grupo(lr_param)               
#------------------------------------------------------# 

define lr_param record        
   chave  char(18)        
end record 

define lr_retorno record
   funmat  like isskfunc.funmat ,
   dptnom  like isskdepto.dptnom,
   caddat  date                 ,
   funnom1 char(30) 
end record

initialize lr_retorno.* to null


  open cctc83m00006 using lr_param.chave
  
  fetch cctc83m00006 into lr_retorno.funmat,
                          lr_retorno.caddat
                         
  close cctc83m00006
  
  open cctc83m00003 using lr_retorno.funmat 
  
  fetch cctc83m00003 into lr_retorno.funnom1,
                          lr_retorno.dptnom
  
  close cctc83m00003
  
  display by name lr_retorno.caddat 
  display by name lr_retorno.funnom1
  
end function

#------------------------------------------------------#                     
function ctc83m00_rec_inc_assunto(lr_param)                                    
#------------------------------------------------------#                     
                                                                             
define lr_param record                                                       
   chave     char(18)                    ,
   c24astcod like datkassunto.c24astcod                                                           
end record                                                                   
                                                                             
define lr_retorno record                                                     
   funmat  like isskfunc.funmat  ,  
   dptnom  like isskdepto.dptnom ,                                                                            
   caddat  date                  ,                                            
   funnom  char(30)                                                          
end record                                                                   
                                                                             
initialize lr_retorno.* to null                                              
                                                                             
                                                                             
  open  cctc83m00011 using lr_param.chave,
                           lr_param.c24astcod                                     
                                                                             
  fetch cctc83m00011 into lr_retorno.funmat,                                 
                          lr_retorno.caddat                                  
                                                                             
  close cctc83m00011                                                         
                                                                             
  open cctc83m00003 using lr_retorno.funmat                                  
                                                                             
  fetch cctc83m00003 into lr_retorno.funnom,                                
                          lr_retorno.dptnom                                  
                                                                             
  close cctc83m00003                                                         
                                                                             
  display by name lr_retorno.caddat                                          
  display by name lr_retorno.funnom                                         
                                                                             
end function   

#------------------------------------------------------#         
function ctc83m00_rec_rel_atd(lr_param)                      
#------------------------------------------------------#         
                                                                 
define lr_param record                                           
   chave     char(18)  ,                       
   grupo     char(13)                      
end record                                                       
                                                                 
define lr_retorno record                                         
   funmat  like isskfunc.funmat  ,                               
   dptnom  like isskdepto.dptnom ,                               
   caddat  date                  ,                               
   funnom  char(30)                                              
end record                                                       
                                                                 
initialize lr_retorno.* to null                                  
                                                                 
                                                                 
  open  cctc83m00017 using lr_param.chave,                       
                           lr_param.grupo                    
                                                                 
  fetch cctc83m00017 into lr_retorno.funmat,                     
                          lr_retorno.caddat                      
                                                                 
  close cctc83m00017                                             
                                                                 
  open cctc83m00003 using lr_retorno.funmat                      
                                                                 
  fetch cctc83m00003 into lr_retorno.funnom,                     
                          lr_retorno.dptnom                      
                                                                 
  close cctc83m00003                                             
                                                                 
  display by name lr_retorno.caddat                              
  display by name lr_retorno.funnom                              
                                                                 
end function                                                     
                                                              
#------------------------------------------------------#         
function ctc83m00_rec_atualizado(lr_param)                           
#------------------------------------------------------#                         
                                                                 
define lr_param record                                           
   chave  char(18)  ,
   funmat char(6)                                               
end record                                                       
                                                                 
define lr_retorno record 
   funmat2 like isskfunc.funmat ,                                                                       
   dptnom  like isskdepto.dptnom,                                
   atldat  date                 ,                                
   funnom2 char(30)                                              
end record                                                       
                                                                 
initialize lr_retorno.* to null                                  
  
  let lr_param.funmat = lr_param.funmat using "&&&&&&"                                                                   
                                                                 
  open cctc83m00007 using lr_param.chave,
                          lr_param.funmat                        
                                                                 
  fetch cctc83m00007 into lr_retorno.funmat2,                     
                          lr_retorno.atldat                      
                                                                 
  close cctc83m00007                                             
                                                                 
  open cctc83m00003 using lr_retorno.funmat2                      
                                                                 
  fetch cctc83m00003 into lr_retorno.funnom2,                    
                          lr_retorno.dptnom                      
                                                                 
  close cctc83m00003                                             
                                                                 
  display by name lr_retorno.atldat                              
  display by name lr_retorno.funnom2                             
                                                                 
end function

#------------------------------------------------------# 
function ctc83m00_display_grupo()                                                     
#------------------------------------------------------#          

   display by name mr_tela.grupo

end function 

#------------------------------------------------------#                                                                   
function ctc83m00_assunto()                                   
#------------------------------------------------------# 

   
define a_ctc83m00 array[50] of record                                                         
  seta      char(1)                      ,                                                               
  c24astcod like datkassunto.c24astcod   ,                                                          
  c24astdes like datkassunto.c24astdes                                                                                                                          
end record                                                                                     
                                                                                               
define lr_retorno record                                                                       
  c24astcod like datkassunto.c24astcod   ,                                                              
  c24astdes like datkassunto.c24astdes   ,                                                                                                              
  erro      smallint                     ,                                                                    
  chave     char(18)                                                                                                                                           
end record                                                                                                                                      
                                                                                               
define arr_aux  integer                                                                        
define scr_aux  integer                                                                        
define l_troca  smallint                                                                       
define l_delete smallint                                                                       
                                                                                               
initialize lr_retorno.* to null                                                                
                                                                                               
for  arr_aux  =  1  to  50                                                                    
   initialize  a_ctc83m00[arr_aux].* to  null                                                  
end  for 

   let mr_tela.assunto = "assunto"
   
   let mr_tela.obs = " <F1> - Inclui  <F2> - Exclui  Ctrl<C> - Abandona " 

   open window ctc83m00a at 7,2 with form "ctc83m00a" 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
   let lr_retorno.chave = m_acesso, mr_tela.assunto   
   display by name mr_tela.obs                                            
                                                                                               
   let arr_aux  = 0                                                                            
   let l_delete = null                                                                         
                                                                                                                                           
                                                                                                                                                                                              
   open cctc83m00010  using lr_retorno.chave                                                    
                                                                                               
   foreach cctc83m00010 into lr_retorno.c24astcod                                                 
                                                                                               
     call ctc83m00_rec_assunto(lr_retorno.c24astcod,0)                                              
     returning lr_retorno.erro      ,                                                             
               lr_retorno.c24astdes                                                            
                                                                            
                                                                                               
     let arr_aux = arr_aux + 1                                                                 
                                                                                               
     let a_ctc83m00[arr_aux].c24astcod = lr_retorno.c24astcod                                       
     let a_ctc83m00[arr_aux].c24astdes = lr_retorno.c24astdes                                                                           
                                                                                               
                                                                                               
   end foreach 
   
   options insert   key F1                                                                                  
   options delete   key F2
                                                                                                 
   call set_count(arr_aux)                                                                     
                                                                                               
   input array a_ctc83m00 without defaults from s_ctc83m00a.*                                   
                                                                                               
     before row                                                                                
         let arr_aux  = arr_curr()                                                             
         let scr_aux  = scr_line()                                                             
                                                                                               
     before insert                                                                             
         if l_delete = 1 and
            arr_curr() = arr_count() then                                                                
              let l_delete = 0                                                                 
              next field seta                                                                  
         end if                                                                                
                                                                                               
         let l_troca = 1                                                                       
         next field c24astcod                                                                     
                                                                                               
     before field seta                                                                         
          call ctc83m00_rec_inc_assunto(lr_retorno.chave,
                                        a_ctc83m00[arr_aux].c24astcod )                                
                                     
                                                                                               
     after field seta                                                                          
                                                                                               
      if  fgl_lastkey() = fgl_keyval("down") then                                              
          if arr_curr() = arr_count() then                                                     
              next field seta                                                                  
          end if                                                                               
      end if                                                                                   
                                                                                               
      if  fgl_lastkey() = fgl_keyval("right") then                                             
              next field seta                                                                  
      end if                                                                                   
                                                                                               
     before field c24astcod                                                                   
       if l_troca = 0 then                                                                     
          next field seta                                                                      
       end if                                                                                  
                                                                                               
       display  a_ctc83m00[arr_aux].c24astcod   to s_ctc83m00a[scr_aux].c24astcod   attribute (reverse)   
                                                                                               
     after field c24astcod                                                                          
       display  a_ctc83m00[arr_aux].c24astcod   to s_ctc83m00a[scr_aux].c24astcod                         
                                                                                               
       if  fgl_lastkey() = fgl_keyval("down") or                                               
           fgl_lastkey() = fgl_keyval("up")   or                                               
           fgl_lastkey() = fgl_keyval("left") or                                               
           fgl_lastkey() = fgl_keyval("right")then                                             
               error "Cadastre o Assunto ou tecle F2 para sair"                              
               next field c24astcod                                                                 
       end if  
                                                                                               
       if a_ctc83m00[arr_aux].c24astcod   is null then                                              
        
          call cta02m03(g_issk.dptsgl         
                       ,a_ctc83m00[arr_aux].c24astcod )
             returning a_ctc83m00[arr_aux].c24astcod     
                      ,a_ctc83m00[arr_aux].c24astdes     
         
          display a_ctc83m00[arr_aux].c24astcod to s_ctc83m00a[scr_aux].c24astcod  
          display a_ctc83m00[arr_aux].c24astdes to s_ctc83m00a[scr_aux].c24astdes
          
          if a_ctc83m00[arr_aux].c24astcod is not null and
             a_ctc83m00[arr_aux].c24astdes is not null then
                  
                  
                  call ctc83m00_ver_exist_assunto(a_ctc83m00[arr_aux].c24astcod,         
                                                  lr_retorno.chave             )         
                  returning lr_retorno.erro                                              
                                                                                         
                  if lr_retorno.erro <> 0 then                                           
                     error "Assunto ja Cadastrado!"                                      
                     next field c24astcod                                                
                  end if 
                  
                  let lr_retorno.erro = ctc83m00_insere_assunto(lr_retorno.chave,                
                                                                a_ctc83m00[arr_aux].c24astcod )  
                                                                                                 
                  if lr_retorno.erro <> 0 then                                                   
                     next field c24astcod                                                        
                  end if                                                                         
                                                                                                 
                  call ctc83m00_rec_inc_assunto(lr_retorno.chave,                                
                                                a_ctc83m00[arr_aux].c24astcod )                  
                                                                                                 
           end if          
                                     
       else                                                                                    
                                                                                               
           call ctc83m00_ver_exist_assunto(a_ctc83m00[arr_aux].c24astcod,                            
                                           lr_retorno.chave             )                                                                    
           returning lr_retorno.erro                                                           
                                                                                               
           if lr_retorno.erro <> 0 then                                                        
              error "Assunto ja Cadastrado!"                                 
              next field c24astcod                                                                
           end if                                                                              
                                                                                               
           call ctc83m00_rec_assunto(a_ctc83m00[arr_aux].c24astcod,1)                               
           returning lr_retorno.erro   ,                                                       
                     lr_retorno.c24astdes                                                     
                                                                                                                                                                    
           if lr_retorno.erro <> 0 then                                                        
              next field c24astcod                                                                
           else                                                                                
                                                                                               
              let a_ctc83m00[arr_aux].c24astdes = lr_retorno.c24astdes                               
                                      
                                                                                               
              display a_ctc83m00[arr_aux].c24astcod to s_ctc83m00a[scr_aux].c24astcod                 
              display a_ctc83m00[arr_aux].c24astdes to s_ctc83m00a[scr_aux].c24astdes                               
                                                                                               
              let lr_retorno.erro = ctc83m00_insere_assunto(lr_retorno.chave,                
                                                            a_ctc83m00[arr_aux].c24astcod )      
                                                                                               
              if lr_retorno.erro <> 0 then                                                     
                 next field c24astcod                                                              
              end if                                                                           
                                                                                               
              call ctc83m00_rec_inc_assunto(lr_retorno.chave,                                     
                                            a_ctc83m00[arr_aux].c24astcod )                       
                                                                                               
           end if                                                                              
       end if                                                                                  
                                                                                               
       before delete                                                                           
          call ctc83m00_ver_exist_assunto(a_ctc83m00[arr_aux].c24astcod,                           
                                          lr_retorno.chave             )                           
          returning lr_retorno.erro                                                                
                                                                                               
          if lr_retorno.erro <> 0 then                                                         
                                                                                               
             call ctc83m00_deleta_assunto(a_ctc83m00[arr_aux].c24astcod,                        
                                          lr_retorno.chave          )                        
             returning lr_retorno.erro                                                         
                                                                                               
             if lr_retorno.erro <> 0 then                                                      
                next field c24astcod                                                              
             end if                                                                            
                                                                                               
          end if                                                                               
                                                                                               
          let l_troca  = 0                                                                     
                                                                                               
      after delete                                                                             
          let l_delete = 1                                                                     
                                                                                               
                                                                                               
     on key (interrupt)                                                                        
       display  a_ctc83m00[arr_aux].c24astcod to s_ctc83m00a[scr_aux].c24astcod                       
         exit input                                                                            
                                                                                               
                                                                                               
   end input                                                                                   
                                                                                               
   close window ctc83m00a                                                                                             
                                                                                               
end function 

#------------------------------------------------------#                                                                                  
function ctc83m00_popup()                       
#------------------------------------------------------#
                                                                                 
define a_ctc83m00 array[500] of record                                                                                                   
     grupo char(13)                                                             
end record                                                                       
                                                                                 
define lr_retorno record                                                         
     chave char(18),
     grupo char(13)                                                                                                                       
end record                                                                       
                                                                                 
define arr_aux integer                                                           
                                                                                 
initialize lr_retorno.* to null                                                  
                                                                                 
for  arr_aux  =  1  to  500                                                      
   initialize  a_ctc83m00[arr_aux].* to  null                                  
end  for

    open window ctc83m00c at 7,50 with form "ctc83m00c"                                                                          
                      attribute(form line 1, border)
    message " <F8>-Seleciona"
                                                                                                                                                                
    let mr_tela.atd = "atd"                                                      
                                                                                 
    let lr_retorno.chave = m_acesso, mr_tela.atd                                 
                                                                                 
    let arr_aux = 1                                                              
                                                                                 
    open cctc83m00014 using m_acesso                                             
                                                                                 
    foreach cctc83m00014 into a_ctc83m00[arr_aux].grupo                       
                                                                                 
      let arr_aux = arr_aux + 1                                                  
                                                                                 
    end foreach                                                                  
                                                                                                                                                                  
    call set_count(arr_aux-1)                                                    
    display array a_ctc83m00 to s_ctc83m00c.*  
    
    on key (interrupt)       
       exit display
       
    on key (f8)
    
       let arr_aux  = arr_curr() 
       let lr_retorno.grupo = a_ctc83m00[arr_aux].grupo 
      
       exit display
       
    
    end display
    
    close window ctc83m00c
    
    return lr_retorno.grupo
    
end function
                      
        
        
