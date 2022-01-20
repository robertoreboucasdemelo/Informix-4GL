#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts64m00                                                   #
#Analista Resp : Amilton Pinto                                              #  
#                Tela de Carro reserva Itau                                 #
#...........................................................................#
#Desenvolvimento: Amilton Pinto                                             #
#Liberacao      : 07/05/2011                                                #
#---------------------------------------------------------------------------#
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
#Data       Autor Fabrica  Origem     Alteracao                             #
#---------- -------------- ---------- --------------------------------------#

database porto
 globals "/homedsa/projetos/geral/globals/glct.4gl"

 
#--------------------------------------------------------------
 function cts64m02(d_cts64m02)
#--------------------------------------------------------------

 define d_cts64m02    record
    sindat            like datmavisrent.sindat,   
    prcnum            like datmavisrent.prcnum,
    prccnddes         like datmavisrent.prccnddes,   
    itaofinom         like datmavisrent.itaofinom  
 end record

 define l_data       date,                           
        l_hora2      datetime hour to minute     

 initialize d_cts64m02.*  to null 

 let int_flag  =  false
 
 
     

 open window wcts64m02 at 07,14 with form "cts64m02"
                         attribute (form line 1, border)

 
 message "  (F8)Confirma "
 
 input by name d_cts64m02.sindat,
               d_cts64m02.prcnum,
               d_cts64m02.prccnddes,
               d_cts64m02.itaofinom                    
       without defaults

   before field sindat
          display by name d_cts64m02.sindat    attribute (reverse)

   after  field sindat
          display by name d_cts64m02.sindat

          call cts40g03_data_hora_banco(2)  
              returning l_data, l_hora2     
          
          if d_cts64m02.sindat is null  then
             error " Data do sinistro deve ser informada!"
             next field sindat
          end if

          if d_cts64m02.sindat > l_data   then
             error " Data do sinistro nao deve ser maior que hoje!"
             next field sindat
          end if
          

   before field prcnum
          display by name d_cts64m02.prcnum    attribute (reverse)

   after  field prcnum
          display by name d_cts64m02.prcnum

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field sindat
          end if
          
          if d_cts64m02.prcnum is null then 
             error " Numero de processo deve ser informada!"
          end if    
                              
          
   before field prccnddes        
        display by name d_cts64m02.prccnddes attribute (reverse)

             if fgl_lastkey() = fgl_keyval("up")     or
                fgl_lastkey() = fgl_keyval("left")   then
                next field prcnum             
             end if

   after  field prccnddes
          display by name d_cts64m02.prccnddes

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field prcnum
          end if
          
          if d_cts64m02.prccnddes is null   then
             error " Condicao do processo deve ser informada!"
             next field prccnddes
          end if


   before field itaofinom
          display by name d_cts64m02.itaofinom attribute (reverse)

   after  field itaofinom
          display by name d_cts64m02.itaofinom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then                          
             next field prccnddes                          
          end if          
          
          #if d_cts64m02.itaofinom is null then
          #      error " Oficina deve ser informada!"
          #      next field itaofinom
          #end if
          
          exit input
   
   on key (F8)
      exit input
   
   
   on key (interrupt)
      if d_cts64m02.sindat is null then 
          error " Data do sinistro deve ser informada!"  
          next field sindat                              
      end if       
      if d_cts64m02.prcnum is null then 
             error " Numero de processo deve ser informada!"
             next field prcnum              
      end if    
      
      if  d_cts64m02.prccnddes is null then      
          error " Condicao do processo deve ser informada!"
          next field prccnddes
      end if   
      
      exit input

 end input

 close window wcts64m02
 
 let int_flag = false
 
 return d_cts64m02.sindat,
        d_cts64m02.prcnum,
        d_cts64m02.prccnddes, 
        d_cts64m02.itaofinom

end function  
