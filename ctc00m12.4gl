#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24H                                #
# MODULO.........: CTC00M12                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: 197858 - Melhorias no Portal de negocios.                  #
#                  Lista os prestadores conforme situação.                    #
# ........................................................................... #
# DESENVOLVIMENTO: PRISCILA STAINGEL                               21/06/2006 # 
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_contador      smallint

  define d_ctc00m12  record
         prssitcod       like dpaksocor.prssitcod,
         prssitdes       char(10),
         ordem           smallint,
         ordemdes        char(21)
  end record

  define am_prestador array[8000] of record
         pstcoddig    like dpaksocor.pstcoddig,
         nomgrr       like dpaksocor.nomgrr
  end record

#-----------------#
function ctc00m12()
#-----------------#

  define l_pstcoddig  like dpaksocor.pstcoddig

  open window w_ctc00m12 at 6,2 with form "ctc00m12"
     attributes(form line 1, message line last - 1)

  message "(F8)Seleciona  (F17)Encerra "
  
  #função para informar o filtro utilizado para pesquisa
  call ctc00m12_input()
  if d_ctc00m12.prssitcod is not null and
     d_ctc00m12.ordem is not null then

     # FUNCAO UTILIZADA PARA CARREGAR OS REGISTROS NO ARRAY
     call ctc00m12_carga_array()

     # EXIBE O ARRAY EM TELA
     call ctc00m12_exibe_array()
          returning l_pstcoddig
 
  end if   

  close window w_ctc00m12
  
  return l_pstcoddig

end function

#-----------------------------#
function ctc00m12_input()
#-----------------------------#
    initialize d_ctc00m12.* to null

    clear form

    input by name d_ctc00m12.prssitcod,
                  d_ctc00m12.ordem  
                 without defaults
                 
       before field prssitcod
          display by name d_ctc00m12.prssitcod attribute(reverse)

       after  field prssitcod
          display by name d_ctc00m12.prssitcod
          if d_ctc00m12.prssitcod is null then
             #caso nao informe a situação a ser pesquisada
             # utilizamos o padrão A - Ativos
             let d_ctc00m12.prssitcod = 'A'
             let d_ctc00m12.prssitdes = "ATIVO"
          else
             #validar situação prestador informada
             case d_ctc00m12.prssitcod
                  when "A"  let d_ctc00m12.prssitdes = "ATIVO"
                  when "B"  let d_ctc00m12.prssitdes = "BLOQUEADO"
                  when "C"  let d_ctc00m12.prssitdes = "CANCELADO"
                  when "P"  let d_ctc00m12.prssitdes = "PROPOSTA"
                  when "T"  let d_ctc00m12.prssitdes = "TODOS"
                  otherwise
                     error " Situacao do prestador invalida!"
                     next field prssitcod
             end case
          end if
          display by name d_ctc00m12.prssitcod
          display by name d_ctc00m12.prssitdes
          
          
       before field ordem
          display by name d_ctc00m12.ordem attribute(reverse)

       after  field ordem
          display by name d_ctc00m12.ordem
          if d_ctc00m12.ordem is null then
             #caso nao informe a ordem a ser listada
             # utilizamos o padrão 1 - Codigo Prestador
             let d_ctc00m12.ordem = 1
             let d_ctc00m12.ordemdes = "Codigo Prestador"
          else
             #validar situação prestador informada
             if d_ctc00m12.ordem = 1 or
                d_ctc00m12.ordem = 2 then
                if d_ctc00m12.ordem = 1 then
                   let d_ctc00m12.ordemdes = "Codigo Prestador"
                else
                   let d_ctc00m12.ordemdes = "Nome Prestador"
                end if
             else
                error " Codigo para ordenar prestador invalido!"
                next field ordem
             end if
          end if  
          display by name d_ctc00m12.ordem
          display by name d_ctc00m12.ordemdes        

       on key (interrupt)
          initialize d_ctc00m12.* to null
          exit input

    end input

end function



#-----------------------------#
function ctc00m12_carga_array()
#-----------------------------#
  define l_sql    char(200)
  
  initialize l_sql to null
  initialize am_prestador to null

  let m_contador = 1
  display m_contador to total

  error "Favor aguardar, pesquisando prestadores..." 

  set isolation to dirty read;

  #Buscar prestadores conforme a situação informada em prssitcod
  # e ordenar conforme a ordem informada em d_ctc00m12.ordem
  # 1 ordena por codigo(pstcoddig) e 2 ordena por nome (nomgrr)

  let l_sql = "select pstcoddig, nomgrr ",
              " from dpaksocor "
  if d_ctc00m12.prssitcod <> 'T' then
     let l_sql = l_sql clipped, " where prssitcod = '", d_ctc00m12.prssitcod,"' "
  end if   
  let l_sql = l_sql clipped, " order by ", d_ctc00m12.ordem
  prepare pctc00m12001 from l_sql
  declare cctc00m12001 cursor for pctc00m12001

  foreach cctc00m12001 into am_prestador[m_contador].pstcoddig,
                            am_prestador[m_contador].nomgrr

     let m_contador = (m_contador + 1)

     if m_contador >= 8000 then
        error "A quantidade de registros superou o limite do array. ctc00m12.4GL " sleep 4
        exit foreach
     end if

  end foreach
  close cctc00m12001

  if m_contador < 8000 then
     error ""
  end if
  
  #iniciou com 1, entao para ter a qtde real subtrai 1
  let m_contador = m_contador - 1

  display m_contador to total

end function

#-----------------------------#
function ctc00m12_exibe_array()
#-----------------------------#

  define l_pos_corrente smallint,
         l_pos_tela     smallint

  define l_pstcoddig    like dpaksocor.pstcoddig

  let l_pos_corrente = null
  let l_pos_tela     = null
  let l_pstcoddig    = null

  if m_contador = 0 then
     error "Nao existe prestador com situacao ", d_ctc00m12.prssitdes sleep 3
  else
     call set_count(m_contador)

     display array am_prestador to s_ctc00m12.*

        on key(f8)
           let l_pos_corrente = arr_curr()
           let l_pos_tela     = scr_line()
           let l_pstcoddig = am_prestador[l_pos_corrente].pstcoddig
           exit display

        on key(f17,control-c,interrupt)
           initialize am_prestador to null
           exit display

     end display

  end if
  
  return l_pstcoddig

end function

