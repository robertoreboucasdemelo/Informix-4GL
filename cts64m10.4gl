#----------------------------------------------------------------------------#   
# Porto Seguro Cia Seguros Gerais                                            #   
#............................................................................#   
# Sistema........: Auto e RE - Itau Seguros                                  #   
# Modulo.........: cts64m10                                                  #   
# Objetivo.......: Lista de Motivos de Carro Reserva Itau                    #   
# Analista Resp. : Amilton Pinto                                             #   
# PSI            :                                                           #   
#............................................................................#   
# Desenvolvimento: Amilton Pinto                                             #   
# Liberacao      : 04/05/2011                                                #   
#............................................................................#   
                                                                                 
database porto                                                                   
                                                                                 
globals "/homedsa/projetos/geral/globals/glct.4gl"                              
                                                                                 
define m_cts64m10_prep  smallint    

define mr_retorno array[500] of record               
       atdsrvorg        like datmservico.atdsrvorg,
       atdsrvnum        like datmservico.atdsrvnum,
       atdsrvano        like datmservico.atdsrvano,
       atddat           like datmservico.atddat,
       atdhor           like datmservico.atdhor,
       aviretdat        like datmavisrent.aviretdat,
       avirethor        like datmavisrent.avirethor,
       aviprvent        like datmavisrent.aviprvent,
       locetpcod        like datmavisrent.locetpcod,
       avialgmtv        like datmavisrent.avialgmtv
end record                                           


 

#------------------------------------------------------------------------------  
function cts64m10_prepare()                                                      
#------------------------------------------------------------------------------  

define l_sql char(10000)

  let l_sql = " select a.atdsrvorg,a.atdsrvnum, ",
              " a.atdsrvano,a.atddat,a.atdhor,  ",
              " b.aviretdat,b.avirethor,b.aviprvent,b.locetpcod,b.avialgmtv ",
              " from datmservico a,datmavisrent b, datrvcllocrsrcmp c  ",
              " where  ",
              " a.atdsrvnum = b.atdsrvnum and  ",              
              " a.atdsrvano = b.atdsrvano and  ",
              " a.atdsrvnum = c.atdsrvnum and  ",
              " a.atdsrvano = c.atdsrvano and  ",
              " b.avialgmtv = c.itarsrcaomtvcod and ",               
              #" b.avialgmtv in (3,6)      and  ",
              #" c.itarsrcaomtvcod in (3,6) and ",                                          
              " b.avialgmtv in (1,2,3,4,5,6)      and  ",
              " c.itarsrcaomtvcod in (1,2,3,4,5,6) and ",
              " a.atdsrvorg = 8 and a.ciaempcod = 84 ",
              " and b.locetpcod = 1 "
  prepare p_cts64m10_001  from l_sql                 
  declare c_cts64m10_001  cursor for p_cts64m10_001  
  
   let l_sql = ' select funnom ',
                  ' from isskfunc ',
                 ' where funmat = ? ',
                   ' and empcod = 1 ',
                   ' and usrtip = "F" '

   prepare p_cts64m10_002 from l_sql
   declare c_cts64m10_002 cursor for p_cts64m10_002  
   
   
   let l_sql = "update datmavisrent set locetpcod = 2",             
               " where atdsrvnum = ? ",
                   "and atdsrvano = ? "                   
                                                     
   prepare p_cts64m10_003 from l_sql 
   
   let l_sql = "select itarsrcaomtvdes from datkitarsrcaomtv ",
               " where itarsrcaomtvcod = ? "                                                               
                                                                        
   prepare p_cts64m10_004 from l_sql       
   declare c_cts64m10_004 cursor for p_cts64m10_004
   
   let l_sql = "select nvl(sum(aviprodiaqtd),0) from datmprorrog ",
               " where atdsrvnum = ? ",
               " and atdsrvano = ? ",
               " and aviprostt = 'A'"
                                                                        
   prepare p_cts64m10_005 from l_sql       
   declare c_cts64m10_005 cursor for p_cts64m10_005
   
   
   
   
   let m_cts64m10_prep = true

end function   

#------------------------------------------------------------------------------  
function cts64m10_rec_reserva()                                         
#------------------------------------------------------------------------------  
                                                                                                   
                                                                                 
define l_index integer

define mr_reservas record        
       atdsrvorg  like datmservico.atdsrvorg, 
       atdsrvnum  like datmservico.atdsrvnum, 
       atdsrvano  like datmservico.atdsrvano, 
       atddat     like datmservico.atddat,    
       atdhor     like datmservico.atdhor,    
       aviretdat  like datmavisrent.aviretdat,
       avirethor  like datmavisrent.avirethor,
       aviprvent  like datmavisrent.aviprvent,
       locetpcod  like datmavisrent.locetpcod, 
       avialgmtv  like datmavisrent.avialgmtv
end record   

define l_exibe     smallint,
       l_prorrog   integer,
       l_total     integer
                                                                                 
for  l_index  =  1  to  500                                                      
   initialize  mr_retorno[l_index].* to  null                                    
end  for                                                                         
                                                                                 
if m_cts64m10_prep is null or                                                          
   m_cts64m10_prep <> true then                                                        
   call cts64m10_prepare()                                                       
end if                              

   let l_exibe = false                                                                                                                               
   let l_index = 1                                                               
                                                                                 
   whenever error continue 
   open c_cts64m10_001 
                       
   foreach c_cts64m10_001 into mr_reservas.atdsrvorg
                              ,mr_reservas.atdsrvnum
                              ,mr_reservas.atdsrvano
                              ,mr_reservas.atddat   
                              ,mr_reservas.atdhor   
                              ,mr_reservas.aviretdat
                              ,mr_reservas.avirethor
                              ,mr_reservas.aviprvent
                              ,mr_reservas.locetpcod
                              ,mr_reservas.avialgmtv                                                                                                                                  
   
   whenever error stop 
   open c_cts64m10_005 using mr_reservas.atdsrvnum,
                             mr_reservas.atdsrvano
   
   
   fetch c_cts64m10_005 into l_prorrog 
   whenever error continue 
   
   if sqlca.sqlcode = 100 then 
      let l_prorrog = 0 
   end if    
   
   #display "l_prorrog = ",l_prorrog
   #display " mr_reservas.aviprvent ",mr_reservas.aviprvent
   
   
   let l_total = mr_reservas.aviprvent + l_prorrog 
   #display "l_total = ",l_total
   
   let l_exibe = cts64m10_calcula_exibicao(mr_reservas.aviretdat,
                                           l_total)
      
   if l_exibe = true then 
        
       let mr_retorno[l_index].atdsrvorg  = mr_reservas.atdsrvorg
       let mr_retorno[l_index].atdsrvnum  = mr_reservas.atdsrvnum
       let mr_retorno[l_index].atdsrvano  = mr_reservas.atdsrvano                            
       let mr_retorno[l_index].atddat     = mr_reservas.atddat   
       let mr_retorno[l_index].atdhor     = mr_reservas.atdhor                         
       let mr_retorno[l_index].aviretdat  = mr_reservas.aviretdat                                
       let mr_retorno[l_index].avirethor  = mr_reservas.avirethor                      
       let mr_retorno[l_index].aviprvent  = mr_reservas.aviprvent    
       let mr_retorno[l_index].locetpcod  = mr_reservas.locetpcod    
       let mr_retorno[l_index].avialgmtv  = mr_reservas.avialgmtv
                
       let l_index = l_index + 1                                                                                        
       continue foreach
   end if     
                                                                                 
   end foreach     
   whenever error stop                                                               
                                                                                 
   return l_index                                                                
                                                                                 
end function                                  

#--------------------------------------------------------------------------
function cts64m10()
#--------------------------------------------------------------------------

   define t_cts64m10 array[500] of record               
       servico         char(13),
       atddat          char(5),
       atdhor          like datmservico.atdhor,
       aviretdat       char(5),
       avirethor       like datmavisrent.avirethor,
       aviprvent       like datmavisrent.aviprvent,
       itarsrcaomtvdes like datkitarsrcaomtv.itarsrcaomtvdes,
       situacao        char(1)      
end record   

define lr_retorno record 
       erro smallint,
       mensagem char(500)
end record        

 define l_em_uso     smallint,
        l_nome       like isskfunc.funnom,
        l_msgmat     char(40),
        l_c24opemat  like datmservico.c24opemat,
        l_msg        char(40),
        l_index      integer ,
        l_qtde       smallint,
        arr_aux      integer ,
        l_confirma   char(1) ,
        l_atddat     char (10),
        l_aviretdat  char (10),
        l_data       date,
        l_hora2      datetime hour to minute,
        cabec        char(66),
        horaatu      char(8),
        l_sai        smallint,
        l_lignum     like datmligacao.lignum,
        qtde         smallint
                                            
   
   
   let l_em_uso    = false                 
   let l_nome      = null
   let l_msgmat    = null
   let l_sai       = false
   let l_c24opemat = null
   let l_msg       = null
   let l_index     = 0
   let l_qtde      = 0 
   let arr_aux     = 0 
   let l_confirma  = 'N'
   let l_lignum    = null
   let qtde        = 0 
   
   initialize lr_retorno.* to null 
   
   if m_cts64m10_prep is null or                                                          
      m_cts64m10_prep <> true then                                                        
      call cts64m10_prepare()                                                       
   end if  
   
   let g_documento.ciaempcod = 84 
   let g_documento.acao = "ALT"
   
   call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2               
   
   while true 
   
      for  l_index  =  1  to  500                                                      
           initialize  t_cts64m10[l_index].* to  null                                    
      end  for  
   
   
       call cts64m10_rec_reserva()
            returning l_qtde
   
   #-----------------
   # Carrega array tela  
   #-----------------
   #display "l_qtde = ",l_qtde
   let l_qtde = l_qtde - 1
   for l_index = 1 to l_qtde                     
                     
       let t_cts64m10[l_index].servico =  F_FUNDIGIT_INTTOSTR(mr_retorno[l_index].atdsrvorg,2), 
                                 "/"    , F_FUNDIGIT_INTTOSTR(mr_retorno[l_index].atdsrvnum,7), 
                                 "-", F_FUNDIGIT_INTTOSTR(mr_retorno[l_index].atdsrvano,2) 
                                        
       let l_atddat = mr_retorno[l_index].atddat
       let l_aviretdat = mr_retorno[l_index].aviretdat 
       
       let t_cts64m10[l_index].atddat    = l_atddat[1,5]
       let t_cts64m10[l_index].atdhor    = mr_retorno[l_index].atdhor                          
       let t_cts64m10[l_index].aviretdat = l_aviretdat[1,5]
       let t_cts64m10[l_index].avirethor = mr_retorno[l_index].avirethor                       
       let t_cts64m10[l_index].aviprvent = mr_retorno[l_index].aviprvent 
       
       #display "mr_retorno[",l_index,"].avialgmtv = ", mr_retorno[l_index].avialgmtv
       call cts64m10_busca_descricao(mr_retorno[l_index].avialgmtv)
            returning t_cts64m10[l_index].itarsrcaomtvdes
       
       
       if mr_retorno[l_index].locetpcod = 1 then                                                    
          let t_cts64m10[l_index].situacao  = "P"
       end if                  
             
   end for   
   
   #--------------
   # Abre a tela 
   #--------------
   open window w_cts64m10 at 04,2 with form "cts64m10"
              attribute(form line 1, border)                    
                                                            
   let int_flag = false                                    
                                                            
   let cabec = "Gestão de Reservas Itau Auto"
   let horaatu = l_hora2
   let qtde    = l_index
   
   display by name  cabec
   display by name  horaatu 
   display by name  qtde
   
   
   message "(F8)Laudo  (F9) Conclui          "
     
   call set_count(l_index)

   display array t_cts64m10 to s_cts64m10.* 
              
      
      on key (F8)                  
         
         let arr_aux = arr_curr()

         if t_cts64m10[arr_aux].servico is null  then
            exit display
         end if

         let g_documento.atdsrvnum = t_cts64m10[arr_aux].servico[4,10]
         let g_documento.atdsrvano = t_cts64m10[arr_aux].servico[12,13]
         
         let l_lignum =
            cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

          call cts20g01_docto(l_lignum)
               returning g_documento.succod,
                         g_documento.ramcod,
                         g_documento.aplnumdig,
                         g_documento.itmnumdig,
                         g_documento.edsnumref,
                         g_documento.prporg,
                         g_documento.prpnumdig,
                         g_documento.fcapacorg,
                         g_documento.fcapacnum,
                         g_documento.itaciacod   
                         
          call cty22g00_rec_dados_itau(,g_documento.itaciacod    
                                       ,g_documento.ramcod
                                       ,g_documento.aplnumdig   
                                       ,g_documento.edsnumref
                                       ,g_documento.itmnumdig)
              returning lr_retorno.erro,
                        lr_retorno.mensagem
           
           
           
            #Caso o servico nao foi acionado/concluido

            #Verifica se o servico esta em uso
            call cts40g18_srv_em_uso(g_documento.atdsrvnum,
                                     g_documento.atdsrvano)
                 returning l_em_uso,
                           l_c24opemat

            if l_em_uso then
               # Se o servico estiver em acionamento, Exibe mensagem de critica
               open c_cts64m10_002 using l_c24opemat
               fetch c_cts64m10_002 into l_nome
               close c_cts64m10_002

               let l_msgmat = "Nome: ", l_nome clipped
               let l_msg    = "Matricula: ", l_c24opemat using "<<<<<&"

               call cts08g01("A", "",
                             "Servico em uso",
                             l_msg,
                             l_msgmat,
                             "")
                 returning l_confirma
            end if         
            
            
         if l_em_uso = false then            
             if cts04g00('cts00m01') = true  then                
                exit display 
             end if
         end if         
        
         on key (F9)                 
                                      
            let arr_aux = arr_curr()  
            
             if t_cts64m10[arr_aux].servico is null  then                  
                error "Nenhuma Reserva selecionada"
                exit display                                               
             end if                                                        
                                                                           
             let g_documento.atdsrvnum = t_cts64m10[arr_aux].servico[4,10] 
             let g_documento.atdsrvano = t_cts64m10[arr_aux].servico[12,13]
             
             whenever error continue 
             execute p_cts64m10_003 using g_documento.atdsrvnum, 
                                          g_documento.atdsrvano
             whenever error stop 
             
             #display "sqlcode = ",sqlca.sqlcode
                                          
             
             call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano, 
                           g_issk.funmat, l_data, l_hora2)         
             
             exit display  
                      
               
      on key (interrupt,control-c,f17)                
            let l_sai = true 
            exit display                             
            
            
         
   end display    
        
   close window  w_cts64m10   
   
   if l_sai = true then       
      exit while       
   end if            
   
      
   end while 
   
   #close window  w_cts64m10
   let g_documento.acao = null  
   let int_flag = false        
   
end function 

#=============================================
function cts64m10_calcula_exibicao(lr_param)
#=============================================

define lr_param record 
       aviretdat  like datmavisrent.aviretdat,
       aviprvent  like datmavisrent.aviprvent
end record 

define lr_retorno record 
       exibe  smallint 
end record 

define l_data_calc  date,
       l_data       date,
       l_hora2      datetime hour to minute,
       l_dias       integer,
       l_index      integer 

initialize lr_retorno.* to null 

let l_data_calc = null 
let l_data      = null
let l_hora2     = null
let l_dias      = 7
let l_index     = 0 

call cts40g03_data_hora_banco(2)
      returning l_data,
                l_hora2

let lr_retorno.exibe = false 



    let l_data_calc = lr_param.aviretdat + 7 units day        
    if l_data  <= lr_param.aviretdat + lr_param.aviprvent units day then
       if l_data_calc <= l_data then
          let lr_retorno.exibe = true 
 
       end if 
    end if 


return lr_retorno.exibe        

end function     

#---------------------------------#
 function cta64m10_opcao()
#---------------------------------#
 
 define l_popup           char(200)
       ,l_par1            char(10)
       ,l_par2            char(09)
       ,l_par3            char(04)
       ,l_par4            char(01)
       ,l_opcao           smallint
       ,l_descricao       char(20)
       ,l_nulo            smallint
       ,l_flag            smallint
       ,l_zero            smallint
       ,l_resultado       smallint
       ,l_mensagem        char(60)       
       ,w_ret             integer
       
  
 ###  Montar popup com as opcoes 

 
  let l_popup  = "Motivos|Filtro Data"
   

 let l_par1   = "FUNCOES" 
 let l_nulo   = null
 
 while true
    
    ### Montar a popup na tela  para a escolha da opcao
    call ctx14g01(l_par1, l_popup)
         returning l_opcao, l_descricao

    if l_opcao = 0 then
       exit while
    end if

    ### Tratamento para cada opcao
    
    if l_opcao =  1 then  # motivos
       #call cts64m10_motivos()       
    end if

    if l_opcao =  2 then  # filtro
       
    end if
        
 end while

end function

function cts64m10_busca_descricao(lr_param)

   define lr_param record 
         avialgmtv like datmavisrent.avialgmtv 
   end record 
   
   define lr_retorno record 
          itarsrcaomtvdes  like datkitarsrcaomtv.itarsrcaomtvdes                
   end record 
   
   
   initialize lr_retorno.* to null   
   let lr_retorno.itarsrcaomtvdes = "Nao encontrado"
   
   
   if m_cts64m10_prep is null or 
      m_cts64m10_prep = false then 
      call cts64m10_prepare()
   end if 
   
   whenever error continue 
   open c_cts64m10_004 using lr_param.avialgmtv 
   fetch c_cts64m10_004 into lr_retorno.itarsrcaomtvdes
   whenever error stop 
   
   
   return lr_retorno.itarsrcaomtvdes
   
end function 
   
          

