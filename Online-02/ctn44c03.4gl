#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA DE SEGUROS GERAIS                    #
#.............................................................................#
#  Sistema        : Central 24h                                               #
#  Modulo         : ctn44c03.4gl                                              #
#  Objetivo       : Formata mensagem de servico para MDT/WVT                  #
#  Analista Resp. : Raji Jahchan                                              #
#  PSI/OSF        : 186520/38253                                              #
#.............................................................................#
#  Desenvolvimento: Meta, Mariana Gimenez                                     #
#  Liberacao      : 09/08/2004                                                #
#.............................................................................#
#                     * * * A L T E R A C A O * * *                           #
#                                                                             #
#  Autor       Data        Observacao                                         #
#  ----------  ----------  ---------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# 13/07/2007 Ligia Mattge PSI 2108383 retorno param de ctn44c02               #
###############################################################################


database porto

define m_path    char(100)
define w_log     char(60) 

main
   call fun_dba_abre_banco("CT24HS") 

   defer interrupt

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctn44c03.log"

   call startlog(w_log)
   
   call ctn44c03()
   
end main   
   

function ctn44c03()

 define lr_coordenadas  record
        dirltt1         char(1),
        graltt1         decimal(2),
        minltt1         decimal(2),
        decltt1         decimal(3),
        dirlgt1         char(1),
        gralgt1         decimal(3),
        minlgt1         decimal(3),
        declgt1         decimal(3),
        dirltt2         char(1),
        graltt2         decimal(3),
        minltt2         decimal(3),
        decltt2         decimal(3),
        dirlgt2         char(1),
        gralgt2         decimal(3),
        minlgt2         decimal(3),
        declgt2         decimal(3)
                        end record

 define l_84ltt         decimal(9,6),
        l_84lgt         decimal(9,6)
        
 define l_data          date,
        l_resp          char(1)

 define l_msg  record
        msg1   char(40),
        msg2   char(40),
        msg3   char(40),
        msg4   char(40)
        end record 

 let l_resp = null
 initialize l_msg.* to null
 initialize lr_coordenadas.* to null

 open window WIN_CAB at 2,2 with 22 rows,78 columns
    attribute (border)
  
    let l_data = today 
    display "GPS" at 01,01
    display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
    display l_data       at 01,69

    display "Pesquisa o logradouro mais proximo de uma coordenada" AT 02,01
   

 open window w_ctn44c03 at 4,2 with form "ctn44c03"

 
 let lr_coordenadas.dirltt1 = "S"
 let lr_coordenadas.dirlgt1 = "O"
 let lr_coordenadas.dirltt2 = "S"
 let lr_coordenadas.dirlgt2 = "O"

 let int_flag = false

 input by name lr_coordenadas.dirltt1,
               lr_coordenadas.graltt1,
               lr_coordenadas.minltt1,
               lr_coordenadas.decltt1,
               lr_coordenadas.dirlgt1,
               lr_coordenadas.gralgt1,
               lr_coordenadas.minlgt1,
               lr_coordenadas.declgt1,
               lr_coordenadas.dirltt2,
               lr_coordenadas.graltt2,
               lr_coordenadas.minltt2,
               lr_coordenadas.decltt2,
               lr_coordenadas.dirlgt2,
               lr_coordenadas.gralgt2,
               lr_coordenadas.minlgt2,
	       lr_coordenadas.declgt2 without defaults
	       

         after field dirltt1	       
            if lr_coordenadas.dirltt1 is not null then 
               if lr_coordenadas.dirltt1 <> "S" and
                  lr_coordenadas.dirltt1 <> "N" then 
                  error "Valor invalido. Digite S(Sul/South) ou N(Norte/North) "
                  next field dirltt1
               end if 
            else
               initialize lr_coordenadas.* to null
               display by name lr_coordenadas.*
               next field dirltt2
            end if 
            
         after field graltt1      
            if lr_coordenadas.graltt1 is not null then 
               if lr_coordenadas.graltt1 < 0  or 
                  lr_coordenadas.graltt1 > 99 then 
                  error "Grau de latitude deve estar entre 0 e 99"
                  next field graltt1
               end if 
            else
               if fgl_lastkey() <> fgl_keyval("left") then 
                  error "Informe o grau de latitude" 
                  next field graltt1 
               end if
            end if 
               
         after field minltt1
            if lr_coordenadas.minltt1 is not null then 
               if lr_coordenadas.minltt1 < 0  or
                  lr_coordenadas.minltt1 > 60 then 
                  error "Minutos de latitude deve estar entre 0 e 60 "
                  next field minltt1
               end if
            else
               if fgl_lastkey() <> fgl_keyval("left") then
                  error "Informe os minutos de latitude"
                  next field minltt1
               end if
            end if 
            
         after field decltt1 
            if lr_coordenadas.decltt1 is not null then 
               if lr_coordenadas.decltt1 < 0  or
                  lr_coordenadas.decltt1 > 60 then  
                  error "Segundos da latitude deve estar entre 0 e 60 "
                  next field decltt1   
               end if 
            else
               if fgl_lastkey() <> fgl_keyval("left") then
                  error "Informe os segundos de latitude "
                  next field decltt1
               end if
            end if  
            
         after field dirlgt1
            if lr_coordenadas.dirlgt1 is not null then 
               if lr_coordenadas.dirlgt1 <> "O" and
                  lr_coordenadas.dirlgt1 <> "W" and
                  lr_coordenadas.dirlgt1 <> "L" and
                  lr_coordenadas.dirlgt1 <> "E" then
                  error "Valor invalido. Digite O/W(Oeste/West) ou E/L(East/Leste)"
                  next field dirlgt1
               end if 
            else
               if fgl_lastkey() <> fgl_keyval("left") and
                  fgl_lastkey() <> fgl_keyval("up")   then
                  error "Informe a direcao da latitude"
                  next field dirlgt1
               end if
            end if 
         
         after field gralgt1
            if lr_coordenadas.gralgt1 is not null then 
               if lr_coordenadas.gralgt1 < 0   or
                  lr_coordenadas.gralgt1 > 999 then
                  error "Graus de longitude deve estar entre 0 e 999"
                  next field gralgt1
               end if 
            else
               if fgl_lastkey() <> fgl_keyval("left") and
                  fgl_lastkey() <> fgl_keyval("up")   then
                  error "Informe o grau de longitude "
                  next field gralgt1
               end if
            end if
            
            
         after field minlgt1
            if lr_coordenadas.minlgt1 is not null then 
               if lr_coordenadas.minlgt1 < 0  or
                  lr_coordenadas.minlgt1 > 60 then 
                  error "Minutos de latitude deve estar entre 0 e 60"
                  next field minlgt1
               end if 
            else
               if fgl_lastkey() <> fgl_keyval("left") and
                  fgl_lastkey() <> fgl_keyval("up")   then
                  error "Informe os minutos da latitude "
                  next field minlgt1
               end if
            end if 
            
         after field declgt1                     
            if lr_coordenadas.declgt1 is not null then 
               if lr_coordenadas.declgt1 < 0  or
                  lr_coordenadas.declgt1 > 60 then 
                  error "Segundos de latitude deve estar entre 0 e 60"
                  next field declgt1
               end if 
            else
               if fgl_lastkey() <> fgl_keyval("left") and
                  fgl_lastkey() <> fgl_keyval("up")   then
                  error "Informe os segundos de latitude"
                  next field declgt1
               end if
            end if  
            exit input      

         after field dirltt2
            if fgl_lastkey() <> fgl_keyval("up") then 
               if lr_coordenadas.dirltt2 is not null then 
                  if lr_coordenadas.dirltt2 <> "S" and
                     lr_coordenadas.dirltt2 <> "N" then 
                     error "Valor invalido. Digite S(Sul/South) ou N(Norte/North) "
                     next field dirltt2
                  end if
               else
                  initialize lr_coordenadas.* to null
                  display by name lr_coordenadas.*
                  next field dirltt1
               end if 
            else   
               next field dirltt1
            end if 
            
         after field graltt2
            if lr_coordenadas.graltt2 is not null then 
               if lr_coordenadas.graltt2 < 0  or
                  lr_coordenadas.graltt2 > 99 then 
                  error "Graus de latitude deve estar entre 0 e 99 "
                  next field graltt2
               end if                   
            else
               if fgl_lastkey() <> fgl_keyval("left") then
                  error "Informe o grau de latitude "
                  next field graltt2
               end if
            end if 
            
         after field minltt2
            if lr_coordenadas.minltt2 is not null then 
               if lr_coordenadas.minltt2 < 0  or
                  lr_coordenadas.minltt2 > 60 then 
                  error "Minutos de latitude deve estar entre 0 e 60 "
                  next field minltt2
               end if
            else
               if fgl_lastkey() <> fgl_keyval("left") then
                  error "Informe os minutos de latitude "
                  next field minltt2
               end if
            end if 
         
        
         after field decltt2
            if lr_coordenadas.decltt2 is not null then 
               if lr_coordenadas.decltt2 < 0   or
                  lr_coordenadas.decltt2 > 999 then
                  error "Decimos de minutos de latitude deve estar entre 0 e 999"
                  next field decltt2
               end if         
            else 
               if fgl_lastkey() <> fgl_keyval("left") then
                  error "Informe os decimos de minutos da latitude"
                  next field decltt2
               end if
            end if 
           
        after field dirlgt2
           if lr_coordenadas.dirlgt2 is not null then 
              if lr_coordenadas.dirlgt2 <> "O" and
                 lr_coordenadas.dirlgt2 <> "W" and
                 lr_coordenadas.dirlgt2 <> "L" and
                 lr_coordenadas.dirlgt2 <> "E" then
                 error "Valor invalido. Digite O/W(Oeste/West) ou E/L(East/Leste)"
                 next field dirlgt2
              end if         
           else
              if fgl_lastkey() <> fgl_keyval("left") and
                 fgl_lastkey() <> fgl_keyval("up")   then
                 error "Informe a direcao da longitude"
                 next field dirlgt2
              end if
           end if 

        after field gralgt2
           if lr_coordenadas.gralgt2 is not null then 
              if lr_coordenadas.gralgt2 < 0   or
                 lr_coordenadas.gralgt2 > 999 then
                 error "Graus de longitude deve estar entre 0 e 999"
                 next field gralgt2
              end if               
           else
              if fgl_lastkey() <> fgl_keyval("left") and
                 fgl_lastkey() <> fgl_keyval("up")   then
                 error "Informe o grau de longitude "
                 next field gralgt2
              end if
           end if 

        after field minlgt2
           if lr_coordenadas.minlgt2 is not null then 
              if lr_coordenadas.minlgt2 < 0  or
                 lr_coordenadas.minlgt2 > 60 then              
                 error "Minutos de longitude deve estar entre 0 e 60 "
                 next field minlgt2
              end if
           else
              if fgl_lastkey() <> fgl_keyval("left") and
                 fgl_lastkey() <> fgl_keyval("up")   then
                 error "Informe os minutos de longitude"
                 next field minlgt2
              end if
           end if 
           
        after field declgt2
           if lr_coordenadas.declgt2 is not null then 
              if lr_coordenadas.declgt2 < 0   or
                 lr_coordenadas.declgt2 > 999 then            
                 error "Decimos de minuto da longitude deve estar entre 0 e 999"
                 next field declgt2
              end if
           else
              if fgl_lastkey() <> fgl_keyval("left") and
                 fgl_lastkey() <> fgl_keyval("up")   then
                 error "Informe os decimos de minutos "
                 next field declgt2
              end if
           end if 
           
           
    on key (f17, interrupt)
       let int_flag = true
	  exit input

 end input
 
 if not int_flag then 
   if lr_coordenadas.graltt1 <> 0 and 
      lr_coordenadas.gralgt1 <> 0 then 
      let l_84ltt = lr_coordenadas.graltt1 + ((lr_coordenadas.minltt1 + 
	    				      (lr_coordenadas.decltt1 /60)) /60)
      if lr_coordenadas.dirltt1 = "S" then 
         let l_84ltt = l_84ltt * -1
      end if 

      let l_84lgt = lr_coordenadas.gralgt1 + ((lr_coordenadas.minlgt1 +
	   				     (lr_coordenadas.declgt1 /60)) /60)

      if lr_coordenadas.dirlgt1 = "O" or 
         lr_coordenadas.dirlgt1 = "W" then 
         let l_84lgt = l_84lgt * -1
      end if
   end if

   if lr_coordenadas.graltt2 <> 0 and 
      lr_coordenadas.gralgt2 <> 0 then
      let l_84ltt = lr_coordenadas.graltt2 + ((lr_coordenadas.minltt2 + 
                                              (lr_coordenadas.decltt2 / 1000)) / 60)
      if lr_coordenadas.dirltt2 = "S" then
         let l_84ltt = l_84ltt * -1
      end if
      let l_84lgt = lr_coordenadas.gralgt2 + ((lr_coordenadas.minlgt2 +
                                              (lr_coordenadas.declgt2 / 1000)) / 60)
                                            
      if lr_coordenadas.dirlgt2 = "O" or  lr_coordenadas.dirlgt2 = "W" then
         let l_84lgt = l_84lgt * -1
      end if
   end if
 
   if l_84ltt <> 0 and l_84lgt <> 0 then

      call ctn44c02 (l_84ltt, l_84lgt)
           returning l_msg.*

      if l_msg.msg1 is not null then
         call cts08g01("A", "", l_msg.msg1, l_msg.msg2, l_msg.msg3, l_msg.msg4)
              returning l_resp
      end if

   end if
 else
    let int_flag = false
    error "Operacao cancelada"
    close window w_ctn44c03
    close window WIN_CAB
    return
 end if 
 
 close window w_ctn44c03
 close window WIN_CAB
 
end function

