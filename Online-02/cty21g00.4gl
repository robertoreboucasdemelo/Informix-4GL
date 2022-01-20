###############################################################################
# Nome do Modulo: cty21m00                                    Helder Oliveira #
#                                                                             #
# Comparacao de proposta                                             Jan/2011 #
###############################################################################
#                             ALTERACOES                                      #
#                             ----------                                      #
# Data         Autor         PSI             Descrição                        #
# -----------  ------------- -------------   -------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#
#                                                                             #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
  define w_data date
  define w_log     char(60)
end globals


define m_prep     smallint
define l_data     date

define r_cty21g00 record
       prporgpcp1  like  gppmppwtrxhst.prporg
     , prpnumpcp1  like  gppmppwtrxhst.ppwprpnum
     , prporgpcp2  like  gppmppwtrxhst.prporg
     , prpnumpcp2  like  gppmppwtrxhst.ppwprpnum
      end record
 

#============================
function cty21g00_prepare()
#============================
define l_sql char(500)

 let l_sql = ' select prporg         '
            ,'   from gppmppwtrxhst  '
            ,'  where prporg    = ?   '
            ,'    and prpnumdig = ?  '
 prepare pcty21g00001 from l_sql
 declare ccty21g00001 cursor for pcty21g00001

 let m_prep = 1

end function

#============================
function cty21g00_input()
#============================ 
define i          smallint
define l_tamanho  smallint
define l_prop1    char(100)
define l_prop2    char(100)
define l_flg      smallint
define l_confirma char(1)
define l_arr      smallint
define l_return   char(2)

  let l_return  = ''
  let l_tamanho = 0
  let i         = 0

  if m_prep <> 1 then
     call cty21g00_prepare()
  end if

  open window w_cty21g00 at 6,2 with form 'cty21g00'
             attribute(form line first, message line last , comment line last -1, border)

  display 'COMPARACAO DE PROPOSTA' at 1,29
  #message '  (F5) Confrontar Dados - (F6) Listar 1a Porposta - (F7) Listar 2a Porposta'
 
  input by name  r_cty21g00.prporgpcp1
               , r_cty21g00.prpnumpcp1
               , r_cty21g00.prporgpcp2
               , r_cty21g00.prpnumpcp2
               
     #-----------------------
      before field prporgpcp1
     #-----------------------
          display r_cty21g00.prporgpcp1 to prporgpcp1 attribute(reverse)

     #-----------------------
      after field prporgpcp1
     #-----------------------
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             display r_cty21g00.prporgpcp1 to prporgpcp1 
          else      
             if r_cty21g00.prporgpcp1 is null or
                r_cty21g00.prporgpcp1 = ' ' then
                error 'DIGITE A ORIGEM'
                next field prporgpcp1
             end if    
         end if
      
         display r_cty21g00.prporgpcp1 to prporgpcp1 

     #-----------------------      
      before field prpnumpcp1
     #-----------------------
          display r_cty21g00.prpnumpcp1 to prpnumpcp1 attribute(reverse)

     #-----------------------          
      after field prpnumpcp1 
     #-----------------------      
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             display r_cty21g00.prpnumpcp1 to prpnumpcp1 
          else
             if r_cty21g00.prpnumpcp1 is null or
                r_cty21g00.prpnumpcp1 = ' ' then
                error 'DIGITE O NUMERO DA PROPOSTA'
                next field prpnumpcp1
             end if
             
             display r_cty21g00.prpnumpcp1 to prpnumpcp1
             
             
             #verifica existencia da proposta
             open ccty21g00001 using r_cty21g00.prporgpcp1
                                   , r_cty21g00.prpnumpcp1                        
                        
             fetch ccty21g00001 into l_return
             if l_return is null then              
                error 'PROPOSTA 1 NAO ENCONTRADA!'  
                next field prporgpcp1
             else
                let l_return = ''
             end if                               
             #----
                                          
             call cty21g00_popup_pergunta("C"
                                         ,"S"
                                         ,"DESEJA DIGITAR A"
                                         ,"SEGUNDA PROPOSTA ?"
                                         ," " )
                  returning l_confirma
            
            if l_confirma = "S"  then
               next field prporgpcp2
            else
               call cty21g01_seleciona_dados(r_cty21g00.prporgpcp1,
                                             r_cty21g00.prpnumpcp1)
               next field prporgpcp1                              
            end if
         
          end if
             
          display r_cty21g00.prpnumpcp1 to prpnumpcp1

     #-----------------------        
      before field prporgpcp2
     #----------------------- 
          display r_cty21g00.prporgpcp2 to prporgpcp2 attribute(reverse)

     #-----------------------          
      after field prporgpcp2
     #-----------------------      
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             display r_cty21g00.prporgpcp2 to prporgpcp2 
          else
             if r_cty21g00.prporgpcp2 is null or
                r_cty21g00.prporgpcp2 = ' ' then
                error 'DIGITE A ORIGEM'
               next field prporgpcp2
             end if    
          end if
          
          display r_cty21g00.prporgpcp2 to prporgpcp2

     #-----------------------          
      before field prpnumpcp2
     #-----------------------
          display r_cty21g00.prpnumpcp2 to prpnumpcp2 attribute(reverse)    

     #-----------------------   
      after field prpnumpcp2 
     #-----------------------   
         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
             let l_flg = 1
             display r_cty21g00.prpnumpcp2 to prpnumpcp2 
        else
           if r_cty21g00.prpnumpcp2 is null or
             r_cty21g00.prpnumpcp2 = ' ' then
             error 'DIGITE O NUMERO DA PROPOSTA'
             next field prpnumpcp2
           end if
            
            
           if r_cty21g00.prporgpcp1 = r_cty21g00.prporgpcp2 and
              r_cty21g00.prpnumpcp1 = r_cty21g00.prpnumpcp2 then
              error 'PROPOSTA IGUAL!' sleep 1 
              
              call cty21g00_popup_pergunta("C"
                                         ,"N"
                                         ,"PROPOSTA IGUAL!"
                                         ,"DESEJA DIGITAR NOVAMENTE ?"
                                         ," " )
                  returning l_confirma
            
            if l_confirma = "S"  then
               next field prporgpcp2
            else
               call cty21g01_seleciona_dados(r_cty21g00.prporgpcp1,
                                             r_cty21g00.prpnumpcp1)
               next field prporgpcp1                              
            end if
                                          
          end if
            
           #verifica existencia da proposta
           open ccty21g00001 using r_cty21g00.prporgpcp2
                                 , r_cty21g00.prpnumpcp2
                        
           fetch ccty21g00001 into l_return
           if l_return is null then              
              error 'PROPOSTA 2 NAO ENCONTRADA!'  
              next field prporgpcp2
           else
              let l_return = ''
           end if                               
           #----            
                      
           #se algum campo estiver nulo :
           if r_cty21g00.prporgpcp1 is null and
              r_cty21g00.prpnumpcp1 is null and
              r_cty21g00.prporgpcp2 is null and
              r_cty21g00.prpnumpcp2 is null then
              
              error 'DIGITE ORIGENS E PROPOSTAS'
              display r_cty21g00.prpnumpcp2 to prpnumpcp2
              next field prporgpcp1
           else
             call cty21g00_popup_opcoes()           
                  returning l_arr
             
             if l_arr = 1 then       #confrontar
                display r_cty21g00.prpnumpcp2 to prpnumpcp2 
                if not cty21g02_entrada_dados ( r_cty21g00.prporgpcp1
                                               ,r_cty21g00.prpnumpcp1
                                               ,r_cty21g00.prporgpcp2
                                               ,r_cty21g00.prpnumpcp2 ) then
                   
                   next field prporgpcp1
                end if
            else
                if l_arr = 2 then    #listar 1a
                   display r_cty21g00.prpnumpcp2 to prpnumpcp2
                   
                   call cty21g01_seleciona_dados(r_cty21g00.prporgpcp1,
                                                 r_cty21g00.prpnumpcp1)
                   next field prporgpcp1            
                else                 #listar 2a
                   call cty21g01_seleciona_dados(r_cty21g00.prporgpcp2,
                                                 r_cty21g00.prpnumpcp2)
                end if
             end if
                  
           end if
        end if
         
         if l_flg <> 1 then
            next field prpnumpcp2
         end if
         
{    ON KEYS
     #----------------------
      on key(F5)  
     #----------------------
      
         if r_cty21g00.prporgpcp1 is not null and
            r_cty21g00.prpnumpcp1 is not null and
            r_cty21g00.prporgpcp2 is not null and
            r_cty21g00.prpnumpcp2 is not null then
   
                  
           let l_prop1 = r_cty21g00.prporgpcp1, r_cty21g00.prpnumpcp1
           let l_prop2 = r_cty21g00.prporgpcp2, r_cty21g00.prpnumpcp2 

           display l_prop1, l_prop2
         else
           error 'PARA CONFRONTAR OS DADOS, TODOS OS CAMPOS DEVEM ESTAR PREENCHIDOS!'         
           clear form
           display by name r_cty21g00.*
           next field prporgpcp1
         end if
         
         
     #----------------------
      on key(F6)  
     #----------------------
         #call cty21g02_listar_transmissao()
     
     #----------------------
      on key(F7)  
     #----------------------     }

  
  end input
  
  close window w_cty21g00             
  
end function

#====================================
 function cty21g00_center(param)
#====================================

 define param        record
    lintxt           char (40)
 end record

 define i            smallint
 define tamanho      dec (2,0)


        let     i  =  null
        let     tamanho  =  null

 let tamanho = (40 - length(param.lintxt))/2

 for i = 1 to tamanho
    let param.lintxt = " ", param.lintxt clipped
 end for

 return param.lintxt

end function  ###  cty21g00_center

#============================================
 function cty21g00_popup_pergunta(param)
#============================================

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40)
 end record

 define d_cty21g00   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01)
 end record

 initialize  d_cty21g00.*  to  null

 initialize  ws.*  to  null

 open window w_cty21g00b at 11,19 with form "cty21g00b"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cty21g00.cabtxt = "CONFIRME"
    when "I"  let  d_cty21g00.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cty21g00.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cty21g00.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cty21g00.cabtxt = "A T E N C A O"
    when "U"  let  d_cty21g00.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cty21g00.cabtxt = cty21g00_center(d_cty21g00.cabtxt)

 let param.linha1 = cty21g00_center(param.linha1)
 let param.linha2 = cty21g00_center(param.linha2)
 let param.linha3 = cty21g00_center(param.linha3)

 display by name d_cty21g00.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha3

 let ws.confirma = "N"

 if param.conflg = "S"  then
    open window w_cty21g00c at 17,32 with 02 rows, 20 columns

    
       menu ""
           command key ("N", interrupt) "NAO"
             exit menu
             
           command key ("S")            "SIM"
             let ws.confirma = "S"
             exit menu
             
       end menu
    
    close window w_cty21g00c
 end if
 if param.conflg = "N"  then
   open window w_cty21g00c at 17,32 with 02 rows, 20 columns

    
       menu ""
           command key ("S")            "SIM"
             let ws.confirma = "S"
             exit menu
             
           command key ("N", interrupt) "NAO"
             exit menu  
             
       end menu
    
    close window w_cty21g00c
 end if
 
 let int_flag = false
 close window w_cty21g00b

 return ws.confirma

end function  

#=====================================
 function cty21g00_popup_opcoes()   
#=====================================
 define la_opcao array[3] of char(50)
                
 define l_index      smallint
 define l_chk        smallint
 define arr_aux      smallint
 define scr_aux      smallint
 
  for l_index  =  1  to  3
    initialize  la_opcao[l_index] to  null
  end  for
  
  let la_opcao[1] = '• Confrontar Dados'
  let la_opcao[2] = '• Listar 1a Proposta'
  let la_opcao[3] = '• Listar 2a Proposta'
  
  open window w_cty21g00d at 11,19 with form "cty21g00d"
              attribute (border, form line 1)

  call set_count(3)

  let l_chk = false
  
 while l_chk = false

  display array la_opcao to as_cty21g00c.*         
         #------------------
          on key (interrupt)
         #------------------
             error "Escolha uma das opções" 
             let l_chk = false 
            exit display

         #------------------            
          on key(f8)
         #------------------
             let l_index = arr_curr() 
             let l_chk = true
             exit display 
             
  end display

 end while
 
  close window w_cty21g00d 
 
  if l_chk = true then
     return arr_curr()
  end if  
  
end function

