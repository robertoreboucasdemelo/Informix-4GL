#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : ctc00m20                                                       #
# Programa   : Manutenção do cadastro complemntode informações do prestador   #
#                           - Circular 380 -                                  #
#-----------------------------------------------------------------------------#
# Analista Resp. : Robert Lima                                                #
# PSI            : 259136                                                     #
#                                                                             #
# Desenvolvedor  : Robert Lima                                                #
# DATA           : 20/07/2010                                                 #
#.............................................................................#
# Data        Autor        Alteracao                                          #
#                                                                             #
# ----------  -----------  ---------------------------------------------------#
# 18/11/2010  Robert Lima  Retirado os controles de transação, e colocado     #
#                          return para no cadastro de prestador efetuar o     #
#                          controle                                           #
#-----------------------------------------------------------------------------#

database porto

#Array dados dos Controladores
define ctc00m20_Contr array[10] of record
    nomeC   char(50), 
    cpfC    decimal(14,0),            
    PEPC    char(1)
end record

define m_ctc00m20 array[10] of record
    ctdcod like dpakctd.ctdcod
end record


#----------------------------------------------
function ctc00m20_prepare()                    
#----------------------------------------------

 define l_sql    char(5000)
 
 
 let l_sql = "select a.ctdcod,                     ",
             "       a.ctdnom,                     ",
             "       a.cgccpfnumdig,               ",
             "       a.pepindcod                   ",
             "  from dpakctd a, dparpstctd b       ",
             " where a.ctdcod = b.ctdcod           ",
             "   and b.pstcoddig =  ?              ",
             "   and a.ctdtip = ?                  "

 prepare pctc00m20001 from l_sql                            
 declare cctc00m20001 cursor for pctc00m20001               
 
 let l_sql = "select a.ctdcod,                     ",
             "       a.ctdnom,                     ",
             "       a.cgccpfnumdig,               ",
             "       a.pepindcod                   ",
             "  from dpakctd a, dparavictd b       ",
             " where a.ctdcod = b.ctdcod           ",
             "   and (                             ",
             "		 b.lcvcod =  ?             ",
             "       and                           ",
             "           b.aviestcod =  ?          ",             
             "       )                             ",
             "   and a.ctdtip = ?                  " 
                                                    
prepare pctc00m20002 from l_sql                     
declare cctc00m20002 cursor for pctc00m20002        

 
end function


#-------------------------------------------------------
function ctc00m20(param) #[Função principal aciona as telas por tipo de responsavel]
#-------------------------------------------------------

define param record
    operacao   char(1),         #[Operação a ser realizada.(I)Inclusao ou (A)Alteração]
    codpstlja  decimal(6,0),    #[Codigo do prestador ou o codigo na loja]
    lcvcod     smallint         #[Codigo da locadora]
end record
       
initialize ctc00m20_Contr to null 

######[Abre a tela para a inserção dos dados dos Controladores]
    call ctc00m20_input("    Controladores","(F1)Inclui (F2)Deleta (F6)Ajuda (F8)Altera (F17)Sair",
    			"Para prestadores PJ: Nome, CPF e Enquadramento como PEP dos Controladores",
    			param.*,'C')
         returning ctc00m20_Contr[1].*
                 , ctc00m20_Contr[2].*
                 , ctc00m20_Contr[3].*
                 , ctc00m20_Contr[4].*
                 , ctc00m20_Contr[5].*
                 , ctc00m20_Contr[6].*
                 , ctc00m20_Contr[7].*
                 , ctc00m20_Contr[8].*
                 , ctc00m20_Contr[9].*
                 , ctc00m20_Contr[10].*
                 , m_ctc00m20[1].* 
                 , m_ctc00m20[2].* 
                 , m_ctc00m20[3].* 
                 , m_ctc00m20[4].* 
                 , m_ctc00m20[5].* 
                 , m_ctc00m20[6].* 
                 , m_ctc00m20[7].* 
                 , m_ctc00m20[8].* 
                 , m_ctc00m20[9].* 
                 , m_ctc00m20[10].*
                 
######[Abre a tela para a inserção dos dados dos Administradores]    
    call ctc00m20_input("   Administradores","(F1)Inclui (F2)Deleta (F5)Copia dados dos Cont. (F6)Ajuda (F8)Alterar (F17)Sair",
                        "Para prestadores PJ: Nome, CPF e Enquadramento como PEP dos Principais Administradores",
                        param.*,'A')
         returning ctc00m20_Contr[1].*
                 , ctc00m20_Contr[2].*
                 , ctc00m20_Contr[3].*
                 , ctc00m20_Contr[4].*
                 , ctc00m20_Contr[5].*
                 , ctc00m20_Contr[6].*
                 , ctc00m20_Contr[7].*
                 , ctc00m20_Contr[8].*
                 , ctc00m20_Contr[9].*
                 , ctc00m20_Contr[10].*
                 , m_ctc00m20[1].* 
                 , m_ctc00m20[2].* 
                 , m_ctc00m20[3].* 
                 , m_ctc00m20[4].* 
                 , m_ctc00m20[5].* 
                 , m_ctc00m20[6].* 
                 , m_ctc00m20[7].* 
                 , m_ctc00m20[8].* 
                 , m_ctc00m20[9].* 
                 , m_ctc00m20[10].*

######[Abre a tela para a inserção dos dados dos Procuradores]    
    call ctc00m20_input("     Procuradores","(F1)Inclui (F2)Deleta (F5)Copia dados dos Adms (F6)Ajuda (F8)Alterar (F17)Sair",
                        "Para prestadores PJ: Nome, CPF e Enquadramento como PEP dos Procuradores",
                        param.*,'P')
         returning ctc00m20_Contr[1].*
                 , ctc00m20_Contr[2].*
                 , ctc00m20_Contr[3].*
                 , ctc00m20_Contr[4].*
                 , ctc00m20_Contr[5].*
                 , ctc00m20_Contr[6].*
                 , ctc00m20_Contr[7].*
                 , ctc00m20_Contr[8].*
                 , ctc00m20_Contr[9].*
                 , ctc00m20_Contr[10].*
                 , m_ctc00m20[1].* 
                 , m_ctc00m20[2].* 
                 , m_ctc00m20[3].* 
                 , m_ctc00m20[4].* 
                 , m_ctc00m20[5].* 
                 , m_ctc00m20[6].* 
                 , m_ctc00m20[7].* 
                 , m_ctc00m20[8].* 
                 , m_ctc00m20[9].* 
                 , m_ctc00m20[10].*               

end function

#---------------------------------------------------------------------
function ctc00m20_dados(ctc00m20_campos,param,l_tipoPrest,l_opcao,textos) #[Função para a entrada de dados para inclusão e alteração]       
#---------------------------------------------------------------------

define ctc00m20_campos  record                   
    ctdcod like dpakctd.ctdcod,           
    nome   char(50),                      
    cpf    decimal(14,0),                 
    PEP    char(1)                        
end record      

define param record
    operacao   char(1),         
    codpstlja  decimal(6,0),    
    lcvcod     smallint
end record

define ctc00m20_cpf record
    cgc     char(14),
    cgcNum  char(12),
    cgcDig  char(2)
end record

define textos record
    texto  char(20)
end record
    
define l_opcao     char(1),
       l_tipoPrest char(1),
       l_aux        smallint,
       l_count      smallint
          
open window w_ctc00m20a at 12,10 with form "ctc00m20a"                                
          attribute (form line 1, border)

if l_opcao = 'I' then #[Caso a opção seja de inclusão ele limpa o record]
  initialize ctc00m20_campos.* to null
  initialize ctc00m20_cpf.* to null
else
  let ctc00m20_cpf.cgc = ctc00m20_campos.cpf                                   
  let ctc00m20_cpf.cgc = ctc00m20_cpf.cgc clipped                                      
  let l_count = length(ctc00m20_cpf.cgc)                                       
                                                                       
  let ctc00m20_cpf.cgcNum = null                                               
  let ctc00m20_cpf.cgcDig = null                                               
                                                                       
  while(l_count <> 0)                                                  
     if l_count > length(ctc00m20_cpf.cgc)-2 then                              
        let ctc00m20_cpf.cgcDig = ctc00m20_cpf.cgc[l_count] clipped,ctc00m20_cpf.cgcDig clipped
     else                                                              
        let ctc00m20_cpf.cgcNum = ctc00m20_cpf.cgc[l_count] clipped,ctc00m20_cpf.cgcNum clipped
     end if                                                            
                                                                       
     let l_count = l_count - 1                                         
                                                                       
  end while  
end if

display by name textos.texto
          
input by name ctc00m20_campos.nome,
              ctc00m20_cpf.cgcNum,
              ctc00m20_cpf.cgcDig,
              ctc00m20_campos.PEP without defaults

      before field nome                      
         display by name ctc00m20_campos.nome attribute(reverse)
         
      after field nome
         display by name ctc00m20_campos.nome 
         
         if ctc00m20_campos.nome is null or ctc00m20_campos.nome = "" then
            error "CAMPO NOME E' OBRIGATORIO"
            next field nome
         end if
#---------------------------------------------------------------------
      before field cgcNum                                                                     
         display by name ctc00m20_cpf.cgcNum  attribute(reverse)
                                                                                           
      after field cgcNum                                                                      
         display by name ctc00m20_cpf.cgcNum                  
         if fgl_lastkey() = fgl_keyval("up")    or                                         
            fgl_lastkey() = fgl_keyval("left")  then                                       
            next field nome                                                                
         end if   
         if ctc00m20_cpf.cgcNum is null or ctc00m20_cpf.cgcNum = '' then
            error "CAMPO CPF E' OBRIGATORIO"
            next field cgcNum
         end if
#---------------------------------------------------------------------
      before field cgcDig                                                                     
         display by name ctc00m20_cpf.cgcDig  attribute(reverse)
                                                                                           
      after field cgcDig                                                                      
         display by name ctc00m20_cpf.cgcDig  
         
         if fgl_lastkey() = fgl_keyval("up")    or                                         
            fgl_lastkey() = fgl_keyval("left")  then                                       
            next field cgcNum                                                                
         end if
         
         if ctc00m20_cpf.cgcDig is null or ctc00m20_cpf.cgcDig = '' then
            error "CAMPO CPF E' OBRIGATORIO"
            next field cgcDig
         else
            call F_FUNDIGIT_DIGITOCPF(ctc00m20_cpf.cgcNum)
                returning l_aux       
            if l_aux is null or ctc00m20_cpf.cgcDig <> l_aux  then
               error " Digito do Cgc/Cpf incorreto!"      
               next field cgcNum                 
            end if 
            let ctc00m20_cpf.cgc = ctc00m20_cpf.cgcNum clipped,ctc00m20_cpf.cgcDig clipped
            let ctc00m20_campos.cpf = ctc00m20_cpf.cgc clipped
         end if                                                                
#---------------------------------------------------------------------
      before field PEP                                                                     
         display by name ctc00m20_campos.PEP attribute(reverse)
                                                       
      after field PEP                                  
         display by name ctc00m20_campos.PEP                   
                                                                                           
         if fgl_lastkey() = fgl_keyval("up")    or                                         
            fgl_lastkey() = fgl_keyval("left") then                                        
            next field cgcDig                                                          
         end if                                                                            
                                                                                           
         if ctc00m20_campos.PEP is null then                                      
            call ctc00m18_pep()                                                                
                 returning ctc00m20_campos.PEP                                    
            next field PEP              
         else
            if ctc00m20_campos.PEP <> 'S' and ctc00m20_campos.PEP <> 'N' and ctc00m20_campos.PEP <> 'R' then
                 call ctc00m18_pep()                                                                
                     returning ctc00m20_campos.PEP                                    
                 next field PEP
            end if                                                
         end if

#---------------------------------------------------------------------         
         if l_opcao = 'I' then #[É verificado qual a opção e direciona para a função correta]
            call ctc00m20_insere(ctc00m20_campos.*,param.codpstlja,param.lcvcod,l_tipoPrest)                                                          
         else
            call ctc00m20_alterar(ctc00m20_campos.*)
         end if  
         
         on key(f17,interrupt)
            exit input        
         
         on key(f6)                        
            call ctc00m20_help(l_tipoPrest)
         
#      exit input
         
end input

close window w_ctc00m20a

end function

#---------------------------------------------------------------------
function ctc00m20_seleciona(param)        
#---------------------------------------------------------------------

define param record
   codpstlja  decimal(6,0),
   lcvcod     smallint, 
   tipo     char(1)    
end record

define ctc00m20_campos array[10] of record
    nome   char(50), 
    cpf    decimal(14,0),
    PEP    char(1)
end record

define ctc00m20 array[10] of record
    ctdcod like dpakctd.ctdcod
end record

define l_indice,l_aux smallint
       
initialize ctc00m20_campos to null
  
call ctc00m20_prepare()

if param.lcvcod = 0 then
####[CARREGA OS DADOS DOS CONTROLADORES]
   let l_indice = 1
   open cctc00m20001 using param.codpstlja,
                           param.tipo
   foreach cctc00m20001 into ctc00m20[l_indice].ctdcod,
                             ctc00m20_campos[l_indice].nome,
                             ctc00m20_campos[l_indice].cpf, 
                             ctc00m20_campos[l_indice].PEP                               
        let l_indice = l_indice + 1
   end foreach
   
#-----------------------------------------------------------------     
else
#-----------------------------------------------------------------
####[CARREGA OS DADOS DOS CONTROLADORES LOJA?LOCADORA]                    
   let l_indice = 1                                       
   open cctc00m20002 using param.lcvcod,
                           param.codpstlja,                       
                           param.tipo                            
   foreach cctc00m20002 into ctc00m20[l_indice].ctdcod,
   			     ctc00m20_campos[l_indice].nome,
                             ctc00m20_campos[l_indice].cpf, 
                             ctc00m20_campos[l_indice].PEP                                   
        let l_indice = l_indice + 1                             
   end foreach   
   close cctc00m20002                                                  
end if

let l_aux = 1                                      
while l_aux <= 10                                  
    #carrega array                                 
    if ctc00m20_campos[l_aux].nome is not null then
       let l_aux = l_aux + 1                       
    else                                           
       exit while                                  
    end if                                         
end while                                          
                                                   
call set_count(l_aux-1)                              
                             
return ctc00m20_campos[1].*
     , ctc00m20_campos[2].*
     , ctc00m20_campos[3].*
     , ctc00m20_campos[4].*
     , ctc00m20_campos[5].*
     , ctc00m20_campos[6].*
     , ctc00m20_campos[7].*
     , ctc00m20_campos[8].*
     , ctc00m20_campos[9].*
     , ctc00m20_campos[10].*
     , ctc00m20[1].*
     , ctc00m20[2].*
     , ctc00m20[3].*
     , ctc00m20[4].*
     , ctc00m20[5].*
     , ctc00m20[6].*
     , ctc00m20[7].*
     , ctc00m20[8].*
     , ctc00m20[9].*
     , ctc00m20[10].*
     

end function

#---------------------------------------------------------------------       
function ctc00m20_insere(param,l_codpstlja,l_lcvcod,l_tipoPst)
#---------------------------------------------------------------------   
define param record
    ctdcod like dpakctd.ctdcod,
    nome   char(40), 
    cpf    decimal(14,0),
    PEP    char(1)       
end record

define l_codpstlja  decimal(6,0),
       l_lcvcod     smallint,    
       l_tipoPst    char(1),
       l_ctdcod    like dpakctd.ctdcod
whenever error continue

    select max(ctdcod) + 1
      into l_ctdcod
      from dpakctd
      
    if l_ctdcod is null or l_ctdcod = "" then
       let l_ctdcod = 1
    end if

  begin work
   
    insert into dpakctd(ctdcod,
                        ctdnom,
                        cgccpfnumdig,
                        ctdtip,
                        pepindcod)
                values(l_ctdcod,
                       param.nome,
                       param.cpf,
                       l_tipoPst,
                       param.PEP)
                       
    if sqlca.sqlcode <> 0 then
     error 'Erro INSERT / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
     sleep 2
     error 'CTC00M20 / ctc00m20_insere() '  sleep 2
     rollback work
     return
    end if
    
    if l_lcvcod = 0 then
       insert into dparpstctd(pstcoddig,ctdcod)
            values (l_codpstlja,l_ctdcod)
    else
       insert into dparavictd(lcvcod,aviestcod,ctdcod)
            values (l_lcvcod,l_codpstlja,l_ctdcod)
    
    end if
    
    if sqlca.sqlcode <> 0 then
     error 'Erro INSERT / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
     sleep 2
     error 'CTC00M20 / ctc00m20_insere() '  sleep 2
     rollback work
     return
    end if

  commit work
whenever error stop

end function

#---------------------------------------------------------------------       
function ctc00m20_alterar(param)
#---------------------------------------------------------------------   
define param record   
    ctdcod like dpakctd.ctdcod,
    nome   char(50), 
    cpf    decimal(14,0),
    PEP    char(1)       
end record
    	
whenever error continue

 begin work

    update dpakctd set (ctdnom,
                        cgccpfnumdig,
                        pepindcod)
                      =
                       (param.nome,
                        param.cpf,
                        param.PEP)
    where ctdcod = param.ctdcod
                       
    if sqlca.sqlcode <> 0 then
     error 'Erro Update / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
     sleep 2
     error 'CTC00M20 / ctc00m20_insere() '  sleep 2
     rollback work
     return
    end if
    
 commit work
whenever error stop
       
return   
            
end function

#---------------------------------------------------------------------   
function ctc00m20_deleta_linha(param,l_codpstlja,l_lcvcod)
#---------------------------------------------------------------------    

define param record
    ctdcod like dpakctd.ctdcod,
    nome   char(50), 
    cpf    decimal(14,0),
    PEP    char(1)       
end record

define l_codpstlja    decimal(6,0),
       l_lcvcod       smallint,
       prompt_key     char(1)

whenever error continue

  call cts08g01('C','S',"","   Confirma a exclusao?","","")
       returning prompt_key
  if prompt_key = 'N' then
     return 1
  end if
 
  begin work
    
    delete from dpakctd
    where ctdcod = param.ctdcod
    
    if sqlca.sqlcode <> 0 then                                  
     error 'Erro Delete / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
     sleep 2                                                    
     error 'CTC00M20 / ctc00m20_deleta_linha() '  sleep 2   
     rollback work
     return 1                                                   
    end if
    
    if l_lcvcod = 0 then
      delete from dparpstctd
      where pstcoddig = l_codpstlja
        and ctdcod    = param.ctdcod
    else
     delete from dparavictd        
      where aviestcod = l_codpstlja 
        and lcvcod    = l_lcvcod
        and ctdcod    = param.ctdcod
    end if
    
    if sqlca.sqlcode <> 0 then                                  
     error 'Erro Delete / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
     sleep 2                                                    
     error 'CTC00M20 / ctc00m20_deleta_linha() '  sleep 2    
     rollback work
     return 1                                                   
    end if 
    
  commit work
    
whenever error stop

return 0
          
end function

#---------------------------------------------------------------------      
function ctc00m20_input(textos,param,l_tipoPrest)
#---------------------------------------------------------------------   
define textos record
    texto  char(20),
    texto2 char(100),
    texto3 char(200)
end record

define ctc00m20_campos array[10] of record
    nome   char(50), 
    cpf    decimal(14,0),
    PEP    char(1)
end record

define ctc00m20 array[10] of record
    ctdcod like dpakctd.ctdcod
end record

define param record
    operacao   char(1),         #[Operação a ser realizada.(I)Inclusao ou (A)Alteração]
    codpstlja  decimal(6,0),    #[Codigo do prestador ou o codigo na loja]
    lcvcod     smallint         #[Codigo da locadora]
end record

define l_tipoPrest    char(1),
       l_textoHelp    char(5000),
       l_ret          smallint,
       scr_aux        smallint,
       arr_aux        smallint,
       l_aux          smallint
       
open window w_ctc00m20 AT 7,2 with form "ctc00m20"
             attribute (border, form line first)       

display textos.texto  to texto 
display textos.texto2 to texto2 
display textos.texto3 to texto3 

initialize ctc00m20_campos to null

while true

    if param.operacao = 'I' then
       call ctc00m20_dados(ctc00m20[1].ctdcod,ctc00m20_campos[1].*,param.*,l_tipoPrest,'I',textos.texto)
       let  param.operacao = 'A'
    end if 

    call ctc00m20_seleciona(param.codpstlja,param.lcvcod,l_tipoPrest)
            returning  ctc00m20_campos[1].*
                     , ctc00m20_campos[2].*
                     , ctc00m20_campos[3].*
                     , ctc00m20_campos[4].*
                     , ctc00m20_campos[5].*
                     , ctc00m20_campos[6].*
                     , ctc00m20_campos[7].*
                     , ctc00m20_campos[8].*
                     , ctc00m20_campos[9].*
                     , ctc00m20_campos[10].*
                     , ctc00m20[1].* 
                     , ctc00m20[2].* 
                     , ctc00m20[3].* 
                     , ctc00m20[4].* 
                     , ctc00m20[5].* 
                     , ctc00m20[6].* 
                     , ctc00m20[7].* 
                     , ctc00m20[8].* 
                     , ctc00m20[9].* 
                     , ctc00m20[10].*
                     
    
    let int_flag = false   
                 
    display array ctc00m20_campos to s_ctc00m20.*
                
                  
             on key(f17, control-c, interrupt)
                exit display
             
             on key(f6)
                call ctc00m20_help(l_tipoPrest)
             
             on key(f8)
                let arr_aux = arr_curr()
                call ctc00m20_dados(ctc00m20[arr_aux].ctdcod,ctc00m20_campos[arr_aux].*,param.*,
                                    l_tipoPrest,'A',textos.texto)
                let int_flag = false
                exit display

             on key(f1)          
                call ctc00m20_dados(ctc00m20[1].ctdcod,ctc00m20_campos[1].*,param.*,
                                    l_tipoPrest,'I',textos.texto)
                let int_flag = false      
                exit display
                 
             on key(f5)
                call ctc00m20_copia_dados(l_tipoPrest,param.codpstlja,param.lcvcod)    
                     returning  ctc00m20_campos[1].*
                              , ctc00m20_campos[2].*
                              , ctc00m20_campos[3].*
                              , ctc00m20_campos[4].*
                              , ctc00m20_campos[5].*
                              , ctc00m20_campos[6].*
                              , ctc00m20_campos[7].*
                              , ctc00m20_campos[8].*
                              , ctc00m20_campos[9].*
                              , ctc00m20_campos[10].*
                              , ctc00m20[1].* 
                              , ctc00m20[2].* 
                              , ctc00m20[3].* 
                              , ctc00m20[4].* 
                              , ctc00m20[5].* 
                              , ctc00m20[6].* 
                              , ctc00m20[7].* 
                              , ctc00m20[8].* 
                              , ctc00m20[9].* 
                              , ctc00m20[10].*
                              
                exit display
                
             on key(f2)     
                let arr_aux = arr_curr()
                call ctc00m20_deleta_linha(ctc00m20[arr_aux].ctdcod,ctc00m20_campos[arr_aux].*,
                                           param.codpstlja,param.lcvcod)
                     returning l_ret
                if l_ret == 0 then
                   call ctc00m20_seleciona(param.codpstlja,param.lcvcod,l_tipoPrest)
                        returning  ctc00m20_campos[1].*
                                 , ctc00m20_campos[2].*
                                 , ctc00m20_campos[3].*
                                 , ctc00m20_campos[4].*
                                 , ctc00m20_campos[5].*
                                 , ctc00m20_campos[6].*
                                 , ctc00m20_campos[7].*
                                 , ctc00m20_campos[8].*
                                 , ctc00m20_campos[9].*
                                 , ctc00m20_campos[10].*
                                 , ctc00m20[1].* 
                                 , ctc00m20[2].* 
                                 , ctc00m20[3].* 
                                 , ctc00m20[4].* 
                                 , ctc00m20[5].* 
                                 , ctc00m20[6].* 
                                 , ctc00m20[7].* 
                                 , ctc00m20[8].* 
                                 , ctc00m20[9].* 
                                 , ctc00m20[10].*
                   exit display                                 
                else
                  error "Nao foi possivel deletar o registro. Acione a Informatica"
                end if                                                                          
       end display
       
       if  int_flag then
           if ctc00m20_campos[1].nome is null or ctc00m20_campos[1].nome = '' then
              error "E' OBRIGATORIO INFORMAR PELO MENOS UM RESPONSAVEL"
              let int_flag = false
           else 
              exit while
           end if    
       end if
       
end while         
         
close window w_ctc00m20                              
    
return ctc00m20_campos[1].*
     , ctc00m20_campos[2].*
     , ctc00m20_campos[3].*
     , ctc00m20_campos[4].*
     , ctc00m20_campos[5].*
     , ctc00m20_campos[6].*
     , ctc00m20_campos[7].*
     , ctc00m20_campos[8].*
     , ctc00m20_campos[9].*
     , ctc00m20_campos[10].*
     , ctc00m20[1].* 
     , ctc00m20[2].* 
     , ctc00m20[3].* 
     , ctc00m20[4].* 
     , ctc00m20[5].* 
     , ctc00m20[6].* 
     , ctc00m20[7].* 
     , ctc00m20[8].* 
     , ctc00m20[9].* 
     , ctc00m20[10].*
              
     
end function
     
     
#---------------------------------------------------------------------   
function ctc00m20_help(l_tipoPrest)
#---------------------------------------------------------------------    
     
 define l_tipoPrest    char(1),   
        l_textoHelp    char(5000),
        l_textoHelp2   char(50)
 
 case l_tipoPrest
   when 'C'
        let l_textoHelp = "PEP - Pessoa Exposta Politicamente                                       ",
                          "Desempenha ou tenha desempenhado, nos últimos cinco anos, cargos,        ",
                          "empregos ou funções públicas relevantes, no Brasil ou em outros países.  ",
                          "Enquadra-se nessa categoria qualquer cargo, emprego ou função pública    ",
                          "relevante, exercido por chefes de estado e de governo, políticos de alto ",
                          "nível, altos servidores dos poderes públicos, magistrados ou militares de",
                          " alto nível, dirigentes de empresas públicas ou dirigentes de partidos ",  
                          "políticos.                                                               ",
                          "PEP - Relacionamento próximo                                             ",
                          "Parentes, na linha direta, até o primeiro grau – pais, irmãos, e filhos, ",
                          "assim como cônjuge, companheiro e enteado.                               ",
                          "Sócio que detém a maioria das ações da empresa."                   
        let l_textoHelp2 ="Controlador"        
   when 'A'
        let l_textoHelp = "PEP - Pessoa Exposta Politicamente                                       ", 
                          "Desempenha ou tenha desempenhado, nos últimos cinco anos, cargos,        ", 
                          "empregos ou funções públicas relevantes, no Brasil ou em outros países.  ", 
                          "Enquadra-se nessa categoria qualquer cargo, emprego ou função pública    ", 
                          "relevante, exercido por chefes de estado e de governo, políticos de alto ", 
                          "nível, altos servidores dos poderes públicos, magistrados ou militares de", 
                          " alto nível, dirigentes de empresas públicas ou dirigentes de partidos ",   
                          "políticos.                                                               ", 
                          "PEP - Relacionamento próximo                                             ", 
                          "Parentes, na linha direta, até o primeiro grau – pais, irmãos, e filhos, ", 
                          "assim como cônjuge, companheiro e enteado.                               ",
                          "Administradores são os responsáveis por administrar e gerir os negócios  ",
                          "da pessoa jurídica (informação disponível no contrato social da empresa)."
        let l_textoHelp2 ="Principais Administradores"                           
                           
   when 'P'                
        let l_textoHelp = "PEP - Pessoa Exposta Politicamente                                       ", 
                          "Desempenha ou tenha desempenhado, nos últimos cinco anos, cargos,        ", 
                          "empregos ou funções públicas relevantes, no Brasil ou em outros países.  ", 
                          "Enquadra-se nessa categoria qualquer cargo, emprego ou função pública    ", 
                          "relevante, exercido por chefes de estado e de governo, políticos de alto ", 
                          "nível, altos servidores dos poderes públicos, magistrados ou militares de", 
                          " alto nível, dirigentes de empresas públicas ou dirigentes de partidos ",   
                          "políticos.                                                               ", 
                          "PEP - Relacionamento próximo                                             ", 
                          "Parentes, na linha direta, até o primeiro grau – pais, irmãos, e filhos, ", 
                          "assim como cônjuge, companheiro e enteado.                               ", 
	                  "Pessoas que recebem poderes da pessoa jurídica, para, em seu nome,       ",
	                  "praticar atos ou administrar interesses ou seja, em termos populares, ",
	                  "assinam pela empresa (em alguns casos, essa informação estará disponível ",
	                  "no contrato social da empresa)."
        let l_textoHelp2 ="Procuradores"	                  

 end case
 
 call ctc00m19(l_textoHelp,l_textoHelp2)    
 
 end function        
 
#---------------------------------------------------------------------
function ctc00m20_copia_dados(l_tipoPrest,l_codpstlja,l_lcvcod)                                                                                           
#---------------------------------------------------------------------
 
 define l_tipoPrest char(1),
        l_codpstlja decimal(6,0),
        l_indice smallint,
        l_count  smallint,
        l_ret    smallint,
        l_lcvcod    smallint          
 
 define ctc00m20_copia array[10] of record        
        nome   char(50),            
        cpf    decimal(14,0),        
        PEP    char(1)
 end record
 
 define ctc00m20 array[10] of record
    ctdcod like dpakctd.ctdcod
 end record
 
 whenever error continue                        

 call ctc00m20_seleciona(l_codpstlja,l_lcvcod,l_tipoPrest)
            returning  ctc00m20_copia[1].*
                     , ctc00m20_copia[2].*
                     , ctc00m20_copia[3].*
                     , ctc00m20_copia[4].*
                     , ctc00m20_copia[5].*
                     , ctc00m20_copia[6].*
                     , ctc00m20_copia[7].*
                     , ctc00m20_copia[8].*
                     , ctc00m20_copia[9].*
                     , ctc00m20_copia[10].*
                     , ctc00m20[1].*
                     , ctc00m20[2].*
                     , ctc00m20[3].*
                     , ctc00m20[4].*
                     , ctc00m20[5].*
                     , ctc00m20[6].*
                     , ctc00m20[7].*
                     , ctc00m20[8].*
                     , ctc00m20[9].*
                     , ctc00m20[10].*

 #if l_tipoPrest = 'A' then
    for l_indice = 1 to 10
       for l_count = 1 to 10
           if ctc00m20_copia[l_count].cpf = ctc00m20_Contr[l_indice].cpfC then
              let l_ret = 0
              exit for
           else
              if ctc00m20_Contr[l_indice].cpfC is not null or ctc00m20_Contr[l_indice].cpfC <> "" then
                 let l_ret = l_indice   
              end if
           end if
       end for
       
       if l_ret <> 0 then
          call ctc00m20_insere(ctc00m20[l_indice].*,ctc00m20_Contr[l_indice].*,
                               l_codpstlja,l_lcvcod,l_tipoPrest)
       end if
       
       let l_ret = 0
       
    end for

 
return   ctc00m20_copia[1].* 
       , ctc00m20_copia[2].*   
       , ctc00m20_copia[3].* 
       , ctc00m20_copia[4].* 
       , ctc00m20_copia[5].* 
       , ctc00m20_copia[6].* 
       , ctc00m20_copia[7].* 
       , ctc00m20_copia[8].* 
       , ctc00m20_copia[9].* 
       , ctc00m20_copia[10].*
       , ctc00m20[1].*
       , ctc00m20[2].*
       , ctc00m20[3].*
       , ctc00m20[4].*
       , ctc00m20[5].*
       , ctc00m20[6].*
       , ctc00m20[7].*
       , ctc00m20[8].*
       , ctc00m20[9].*
       , ctc00m20[10].*

end function     