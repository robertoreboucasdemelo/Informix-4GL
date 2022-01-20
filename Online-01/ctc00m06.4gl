###########################################################################
# Nome do Modulo: CTC00M06                                       Marcelo  #
#                                                                Gilberto #
# Mostra os prestadores cadastrados com o CGC informado          Jan/1997 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 06/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador  #
#                                       B-Bloqueado.                      #
# 14/09/2010  PSI 00009EV  Robert Lima  Colocada a função favorecido      #
###########################################################################

 database porto

#------------------------------------------------------------
 function ctc00m06(param)
#------------------------------------------------------------

 define param      record
    psqtip         dec(1,0),
    pestip         like dpaksocor.pestip,
    pstcoddig      like dpaksocor.pstcoddig,
    cgccpfnum      like dpaksocor.cgccpfnum
 end record

 define a_ctc00m06 array[15] of record
    cgcord         like dpaksocor.cgcord,
    pstcoddig      like dpaksocor.pstcoddig,
    nomrazsoc      like dpaksocor.nomrazsoc,
    prssitdes      char (09)
 end record

 define ws         record
    comando        char (400),
    prssitcod      char (01)
 end record

 define arr_aux        smallint
 define scr_aux        smallint
 define confirma       char(1)
 define l_confpstprinc char(60)
 define l_pcpprscod    like dpaksocor.pcpprscod
 define l_pcpprscodaux like dpaksocor.pcpprscod
 define prompt_key     char(1)


 initialize  a_ctc00m06   to null
 initialize  ws.*         to null
 let arr_aux = 1

 if param.psqtip  =   1   then
    let ws.comando = "select pstcoddig,   ",
                     "       nomrazsoc,   ",
                     "       cgcord,      ",
                     "       prssitcod    ",
                     "  from dpaksocor    ",
                     " where cgccpfnum = ?",
                     "   and pestip    = ?",
                     " order by cmtdat, pstcoddig "
 else
    let ws.comando = "select dpaksocor.pstcoddig,  ",
                     "       dpaksocor.nomrazsoc,  ",
                     "       dpaksocor.cgcord,     ",
                     "       dpaksocor.prssitcod   ",
                     "  from dpaksocorfav, dpaksocor",
                     " where dpaksocorfav.cgccpfnum  = ?",
                     "   and dpaksocorfav.pestip     = ?",
                     "   and dpaksocor.pstcoddig = dpaksocorfav.pstcoddig ",
                     " order by dpaksocor.cmtdat, dpaksocor.pstcoddig "
 end if

 prepare sel_cgccpf        from  ws.comando
 declare c_ctc00m06  cursor for  sel_cgccpf


 open  c_ctc00m06   using  param.cgccpfnum,
                           param.pestip

 foreach c_ctc00m06 into   a_ctc00m06[arr_aux].pstcoddig,
                           a_ctc00m06[arr_aux].nomrazsoc,
                           a_ctc00m06[arr_aux].cgcord,
                           ws.prssitcod

    if a_ctc00m06[arr_aux].pstcoddig = param.pstcoddig  then
       continue foreach
    end if

    case ws.prssitcod
         when  "A"   let a_ctc00m06[arr_aux].prssitdes = "ATIVO"
         when  "C"   let a_ctc00m06[arr_aux].prssitdes = "CANCELADO"
         when  "P"   let a_ctc00m06[arr_aux].prssitdes = "PROPOSTA"
         when  "B"   let a_ctc00m06[arr_aux].prssitdes = "BLOQUEADO"
    end case

    let arr_aux = arr_aux + 1
    if arr_aux > 15   then
       error "Limite excedido. Existem mais de 15 prestadores com este CGC/CPF!"
       exit foreach
    end if
 end foreach

 if arr_aux  >  1   then

    open window w_ctc00m06 at 10,06  with form  "ctc00m06"
        attribute(form line first, border)

    display param.cgccpfnum  to  cgccpfnum   attribute(reverse)

    if param.psqtip  =  1    then
       display "    Prestadores cadastrados com mesmo CGC/CPF "
               to cabec   attribute(reverse)
    else
       display "   Prestadores com mesmo CGC/CPF de favorecido"
               to cabec   attribute(reverse)
    end if

    if param.pestip  = "J"   then
       display "CGC:"    to  tipo   attribute(reverse)
       display "Filial"  to  filial
    else
       display "CPF:"    to  tipo   attribute(reverse)
    end if

    message " (F17)Abandona  (F8)Selecionar"
    call set_count(arr_aux-1)
    let l_pcpprscod = null

    display array  a_ctc00m06 to s_ctc00m06.*
       on key(interrupt)
          let arr_aux = null
          let l_pcpprscod = null
          
          call cts08g01('C','S',"","ESTE PRESTADOR FAZ PARTE DE ALGUM GRUPO","LISTADO?","")
       		returning prompt_key
       		
          if prompt_key <> 'S' then
             exit display
          else
             let int_flag = false                
          end if
       
       on key(f8)
          let arr_aux = arr_curr()
          let l_pcpprscod = a_ctc00m06[arr_aux].pstcoddig
          let l_confpstprinc = l_pcpprscod clipped
          
          while true
             select pcpprscod 
               into l_pcpprscodaux
               from dpaksocor
              where pstcoddig = l_pcpprscod
             
             if l_pcpprscodaux is not null and l_pcpprscodaux <> l_pcpprscod then
                let l_pcpprscod = l_pcpprscodaux
             else
                exit while
             end if
          end while
             
          exit display
    end display
    
    let l_confpstprinc = "DESEJA VINCULAR O PRESTADOR ",l_confpstprinc clipped," COMO PRINCIPAL ?" clipped

    display l_confpstprinc to confpstprinc attribute(reverse)
        
    if l_pcpprscod is not null then
       while true
           input by name confirma
               before field confirma                      
                 display by name confirma attribute(reverse)
                
               after field confirma
                 display by name confirma
                 
                 if confirma is not null then
                    if confirma = 'S' then
                       let int_flag = true                       
                       exit input
                    else
                       if confirma = 'N' then
                          let l_pcpprscod = 0 
                          let int_flag = true
                          exit input
                       else
                          error "DIGITE A OPCAO (S)SIM OU (N)NAO"
                       end if
                    end if
                 else
                    error "DIGITE A OPCAO (S)SIM OU (N)NAO"
                    next field confirma
                 end if
               
               on key(interrupt)
                  if confirma is null then
                     let int_flag = false
                  else
                     if confirma = 'S' then
                       let int_flag = true
                       exit input
                     else
                       if confirma = 'N' then
                          let int_flag = true
                          let l_pcpprscod = 0
                          exit input
                       else
                          let int_flag = false
                       end if
                     end if
                  end if
               
           end input
           
           if int_flag then
              exit while
           end if
       end while                    
    end if

    close window  w_ctc00m06
    close c_ctc00m06
    let int_flag = false

 end if

 close c_ctc00m06
 
 return l_pcpprscod

end function   ##-- ctc00m06

#------------------------------------------------------------
 function ctc00m06_favorecido(param)
#------------------------------------------------------------

 define param      record
    psqtip         dec(1,0),
    pestip         like dpaksocor.pestip,
    pstcoddig      like dpaksocor.pstcoddig,
    cgccpfnum      like dpaksocor.cgccpfnum
 end record

 define a_ctc00m06 array[15] of record
    cgcord         like dpaksocor.cgcord,
    pstcoddig      like dpaksocor.pstcoddig,
    nomrazsoc      like dpaksocor.nomrazsoc,
    prssitdes      char (09)
 end record

 define ws         record
    comando        char (400),
    prssitcod      char (01)
 end record

 define arr_aux  smallint
 define scr_aux  smallint


 initialize  a_ctc00m06   to null
 initialize  ws.*         to null
 let arr_aux = 1

 if param.psqtip  =   1   then
    let ws.comando = "select pstcoddig,   ",
                     "       nomrazsoc,   ",
                     "       cgcord,      ",
                     "       prssitcod    ",
                     "  from dpaksocor    ",
                     " where cgccpfnum = ?",
                     "   and pestip    = ?",
                     " order by pstcoddig "
 else
    let ws.comando = "select dpaksocor.pstcoddig,  ",
                     "       dpaksocor.nomrazsoc,  ",
                     "       dpaksocor.cgcord,     ",
                     "       dpaksocor.prssitcod   ",
                     "  from dpaksocorfav, dpaksocor",
                     " where dpaksocorfav.cgccpfnum  = ?",
                     "   and dpaksocorfav.pestip     = ?",
                     "   and dpaksocor.pstcoddig = dpaksocorfav.pstcoddig ",
                     " order by dpaksocor.pstcoddig "
 end if

 prepare sel_cgccpf01        from  ws.comando
 declare c_ctc00m0601  cursor for  sel_cgccpf01


 open  c_ctc00m0601 using  param.cgccpfnum,
                           param.pestip

 foreach c_ctc00m0601 into a_ctc00m06[arr_aux].pstcoddig,
                           a_ctc00m06[arr_aux].nomrazsoc,
                           a_ctc00m06[arr_aux].cgcord,
                           ws.prssitcod

    if a_ctc00m06[arr_aux].pstcoddig = param.pstcoddig  then
       continue foreach
    end if

    case ws.prssitcod
         when  "A"   let a_ctc00m06[arr_aux].prssitdes = "ATIVO"
         when  "C"   let a_ctc00m06[arr_aux].prssitdes = "CANCELADO"
         when  "P"   let a_ctc00m06[arr_aux].prssitdes = "PROPOSTA"
         when  "B"   let a_ctc00m06[arr_aux].prssitdes = "BLOQUEADO"
    end case

    let arr_aux = arr_aux + 1
    if arr_aux > 15   then
       error "Limite excedido. Existem mais de 15 prestadores com este CGC/CPF!"
       exit foreach
    end if
 end foreach


 if arr_aux  >  1   then

    open window w_ctc00m0601 at 10,06  with form  "ctc00m06a"
        attribute(form line first, border)

    display param.cgccpfnum  to  cgccpfnum   attribute(reverse)

    if param.psqtip  =  1    then
       display "    Prestadores cadastrados com mesmo CGC/CPF "
               to cabec   attribute(reverse)
    else
       display "   Prestadores com mesmo CGC/CPF de favorecido"
               to cabec   attribute(reverse)
    end if

    if param.pestip  = "J"   then
       display "CGC:"    to  tipo   attribute(reverse)
       display "Filial"  to  filial
    else
       display "CPF:"    to  tipo   attribute(reverse)
    end if

    message " (F17)Abandona"
    call set_count(arr_aux-1)

    display array  a_ctc00m06 to s_ctc00m06.*
       on key(interrupt)
          exit display
    end display

    close window  w_ctc00m0601
    close c_ctc00m0601
    let int_flag = false

 end if

 close c_ctc00m0601

end function   ##-- ctc00m06
