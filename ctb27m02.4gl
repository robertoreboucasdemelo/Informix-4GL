###############################################################################
#                         PORTO SEGURO CIA DE SEGUROS GERAIS                  # 
#.............................................................................#
#  Sistema          : CENTRAL 24H                                             #
#  Modulo           : ctb27m02.4gl                                            #
#                     Pesquisa Mensagens para Prestadores                     #
#  Analista Resp.   : Carlos Zyon                                             #
#  PSI              : 187801                                                  #
#.............................................................................#
#  Desenvolvimento  : Helio (Meta)                                            #
#  Liberacao        :                                                         #
#.............................................................................#
#                     * * * A L T E R A C A O * * *                           #
#                                                                             #
#  Data       Autor Fabrica        PSI   Alteracao                            #
# ----------  ------------------- ------ -------------------------------------#
#                                                                             #
#                                                                             #
###############################################################################

database porto

 define m_data_inicial      char(19)
 define m_data_final        char(19)

#------------------------------------------------------------------------------
function ctb27m02_prepare(lr_ctb27m0201)
#------------------------------------------------------------------------------

define lr_ctb27m0201 record
   msgcod            smallint
  ,datainc           date
  ,datafnl           date
  ,prstcod           decimal(6,0)
  ,estsit            smallint
end record

define l_aux01     char(10)
define l_aux02     char(10)
define l_aux03     char(19)
define l_aux04     char(19)

define l_sql      char(1000)
define l_sqlaux   char(500)
   
   let l_aux01 = lr_ctb27m0201.datainc
   let l_aux02 = lr_ctb27m0201.datafnl
   
   let l_aux03 = l_aux01[7,10],'-',l_aux01[4,5],'-',l_aux01[1,2],' 00:00:00'
   let l_aux04 = l_aux02[7,10],'-',l_aux02[4,5],'-',l_aux02[1,2],' 23:59:59'
   
   let m_data_inicial = l_aux03
   let m_data_final   = l_aux04
   
   let l_sql = " select a.prsmsgcod, b.prsmsgtitdes, a.pstcoddig, c.nomgrr "
              ," ,a.prsmsgdstsit                                           "
              ," from dparprsmsgdst a, dpakprsmsg b, dpaksocor c           "
              ," where b.caddat >= '",m_data_inicial,"'"
              ," and b.caddat <= '",m_data_final,"'"
              ," and b.prsmsgcod = a.prsmsgcod "
              ," and a.pstcoddig = c.pstcoddig "

   if lr_ctb27m0201.msgcod is not null then
      let l_sqlaux = " and b.prsmsgcod = ",lr_ctb27m0201.msgcod clipped
      let l_sql = l_sql clipped, l_sqlaux clipped
   end if
   if lr_ctb27m0201.prstcod is not null then
      let l_sqlaux = " and a.pstcoddig = ",lr_ctb27m0201.prstcod clipped
      let l_sql = l_sql clipped, l_sqlaux clipped
   end if
   if lr_ctb27m0201.estsit is not null and
      lr_ctb27m0201.estsit <> 0        then
      let l_sqlaux = " and a.prsmsgdstsit = ",lr_ctb27m0201.estsit clipped
      let l_sql = l_sql clipped, l_sqlaux clipped
   end if
   prepare pctb27m0201 from l_sql
   declare cctb27m0201 cursor for pctb27m0201

end function #ctb27m02_prepare

#------------------------------------------------------------------------------
function ctb27m02()
#------------------------------------------------------------------------------

define lr_ctb27m0201 record
   msgcod            smallint
  ,datainc           date
  ,datafnl           date
  ,prstcod           decimal(6,0)
  ,estsit            smallint
end record

define al_cbt27m0201  array[1000] of record
   prsmsgcod            like dparprsmsgdst.prsmsgcod
  ,prsmsgtitdes         like dpakprsmsg.prsmsgtitdes
  ,pstcoddig            like dparprsmsgdst.pstcoddig
  ,nomgrr               like dpaksocor.nomgrr
  ,prsmsgdstsit         like dparprsmsgdst.prsmsgdstsit
  ,sitdes               char(10)
end record

define l_i              integer
define l_sai            char(01)

   initialize lr_ctb27m0201 to null
   initialize al_cbt27m0201 to null
   let l_i = 1
   let l_sai = "N"

   options message line last

   open window w_ctb27m02 at 6,2 with form "ctb27m02"
      attribute (form line 1)
      
      let int_flag = false
      
      clear form
      
      input by name lr_ctb27m0201.* without defaults
      
         #Codigo da Mensagem
         before field msgcod
            display by name lr_ctb27m0201.msgcod attribute(reverse)
         
         after field msgcod
            display by name lr_ctb27m0201.msgcod
            
            let lr_ctb27m0201.datainc = today - 30 units day
            let lr_ctb27m0201.datafnl = today
            next field datainc
         
         #Periodo Inicial
         before field datainc
            display by name lr_ctb27m0201.datainc attribute(reverse)
            
         after field datainc
            display by name lr_ctb27m0201.datainc
            
            if lr_ctb27m0201.datainc is null then
               error "Entre com o periodo inicial"
               next field datainc
            end if
            next field datafnl
         
         #Periodo Final
         before field datafnl
            display by name lr_ctb27m0201.datafnl attribute(reverse)

         after field datafnl
            display by name lr_ctb27m0201.datafnl
            
            if lr_ctb27m0201.datafnl is null then
               error "Entre com o periodo final"
               next field datafnl
            end if
            if lr_ctb27m0201.datafnl < lr_ctb27m0201.datainc then
               error "Periodo final deve ser maior que periodo inicial"
               let lr_ctb27m0201.datainc = ""
               let lr_ctb27m0201.datafnl = ""
               display by name lr_ctb27m0201.datainc
                              ,lr_ctb27m0201.datafnl
               next field datainc
            end if
            next field prstcod
         
         #Prestador
         before field prstcod
            display by name lr_ctb27m0201.prstcod attribute(reverse)
         
         after field prstcod
            display by name lr_ctb27m0201.prstcod
            next field estsit
         
         #Estado
         before field estsit
            display by name lr_ctb27m0201.estsit attribute(reverse)
         
         after field estsit
            display by name lr_ctb27m0201.estsit
            
            if lr_ctb27m0201.estsit <> 1        and
               lr_ctb27m0201.estsit <> 2        and
               lr_ctb27m0201.estsit <> 0        and
               lr_ctb27m0201.estsit is not null then 
               error "Entre com 1, 2, 0 ou branco"
               let lr_ctb27m0201.estsit = ""
               next field estsit
            end if

            message "                                           "

            call ctb27m02_prepare(lr_ctb27m0201.*)
            
            open cctb27m0201
            foreach cctb27m0201 into al_cbt27m0201[l_i].*
               case al_cbt27m0201[l_i].prsmsgdstsit
                  when 1
                     let al_cbt27m0201[l_i].sitdes = "Aguardando"
                  when 2
                     let al_cbt27m0201[l_i].sitdes = "Lida"
               end case
               
               let l_i = l_i + 1
               if l_i > 1000 then
                  error "Array ultrapassou tamanho maximo! Avise a informatica."
                  let l_sai = "S"
                  exit foreach
               end if
            end foreach

            if l_sai = "S" then
               exit input
            end if
         
            call set_count(l_i - 1)
      
            if l_i = 1 then
               error "Nao existem mensagens cadastradas"
               clear form
               initialize lr_ctb27m0201 to null
               next field msgcod
            else
               display array al_cbt27m0201 to s_ctb27m02.*
                  
                  on key(interrupt, control-c)
                     exit display
               end display
               clear form
               initialize lr_ctb27m0201 to null
               initialize al_cbt27m0201 to null
               let l_i = 1
               next field msgcod
            end if
            exit input

         on key (interrupt, control-c, f17)
            exit input
      end input

      if int_flag then
         let int_flag = false
         initialize lr_ctb27m0201 to null
         clear form
      end if

   close window w_ctb27m02

end function #ctb27m02

