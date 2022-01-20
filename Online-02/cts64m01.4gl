#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cts64m01                                                  #
# Objetivo.......: Lista de Motivos de Carro Reserva Itau                    #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Roberto Melo                                              #
# Liberacao      : 04/05/2011                                                #
#............................................................................#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cts64m01_prep  smallint

define mr_retorno array[500] of record
   itarsrcaomtvcod   like datkitarsrcaomtv.itarsrcaomtvcod,
   itarsrcaomtvdes   like datkitarsrcaomtv.itarsrcaomtvdes,
   dialimqtd         like datkitarsrcaomtv.dialimqtd
end record

define mr_motivos array[500] of record
   itarsrcaomtvcod   like datkitarsrcaomtv.itarsrcaomtvcod,
   itarsrcaomtvdes   like datkitarsrcaomtv.itarsrcaomtvdes,
   dialimqtd         like datkitarsrcaomtv.dialimqtd
end record





#------------------------------------------------------------------------------
function cts64m01_prepare()
#------------------------------------------------------------------------------

define l_sql char(10000)

  let l_sql = "select itarsrcaomtvcod,   " ,
              "       itarsrcaomtvdes,   " ,
              "       dialimqtd          " ,
              " from datkitarsrcaomtv    " ,
              " order by itarsrcaomtvcod "
  prepare p_cts64m01_001  from l_sql
  declare c_cts64m01_001  cursor for p_cts64m01_001

  let l_sql = "select rsrprvdiaqtd,   " ,
              "       rsrutidiaqtd,   " ,
              "       rsrdialimqtd    " ,
              " from datrvcllocrsrcmp " ,
              " where atdsrvnum = ?   ",
              " and atdsrvano = ?     ",
              " and itarsrcaomtvcod = ? "
  prepare p_cts64m01_002  from l_sql
  declare c_cts64m01_002  cursor for p_cts64m01_002

  let l_sql = ' select a.itarsrcaomtvcod                        '
          ,  '      , a.itarsrcaomtvdes                         '
          ,  '      , b.rsrcaodiaqtd                            '
          ,  '   from datkitarsrcaomtv a   ,                    '
          ,  '        datrclisgmrsrcaomtv b                     '
          ,  '   where a.itarsrcaomtvcod = b.itarsrcaomtvcod    '
          ,  '   and   b.itaclisgmcod =  ?                      '
          ,  '   and   b.vigincdat   <=  ?                      '
          ,  '   and   b.vigfnldat   >=  ?                      '
          ,  '   order by a.itarsrcaomtvcod                     '
  prepare p_cts64m01_003  from l_sql
  declare c_cts64m01_003  cursor for p_cts64m01_003
  let m_cts64m01_prep = true

end function

#------------------------------------------------------------------------------
function cts64m01_rec_motivo_reserva()
#------------------------------------------------------------------------------


define l_index integer

for  l_index  =  1  to  500
   initialize  mr_retorno[l_index].* to  null
end  for

if m_cts64m01_prep is null or
   m_cts64m01_prep <> true then
   call cts64m01_prepare()
end if

   let l_index = 1

   if cts12g10_verifica_data_motivo(g_doc_itau[1].itaaplvigincdat,g_doc_itau[1].itaclisgmcod) then
   	   open c_cts64m01_003 using g_doc_itau[1].itaclisgmcod    ,
   	                             g_doc_itau[1].itaaplvigincdat ,
   	                             g_doc_itau[1].itaaplvigincdat
   	   foreach c_cts64m01_003 into mr_retorno[l_index].itarsrcaomtvcod  ,
   	                               mr_retorno[l_index].itarsrcaomtvdes  ,
   	                               mr_retorno[l_index].dialimqtd
   	   let l_index = l_index + 1
   	   end foreach
   else
       open c_cts64m01_001

       foreach c_cts64m01_001 into mr_retorno[l_index].itarsrcaomtvcod,
                                   mr_retorno[l_index].itarsrcaomtvdes,
                                   mr_retorno[l_index].dialimqtd


       let l_index = l_index + 1

       end foreach

   end if
   return l_index

end function

function cts64m01_carrega_array()

   define lr_retorno record
          coderro smallint
         ,mens    char(400)
   end record

   define lr_condicoes record
        correntista     smallint,
        garantia        smallint,
        arcondicionado  smallint
   end record

   define l_index integer,
          l_qtde  integer,
          l_index2 integer

   let l_qtde  = 0
   let l_index = 0
   let l_index2= 1

   # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_motivos[l_index].* to  null
   end for

   call cts64m01_rec_motivo_reserva()
   returning l_qtde

   call cts64m01_condicoes(1)
   returning lr_condicoes.correntista,
             lr_condicoes.garantia


   # Retira o ultimo indice devido ao foreach utilizado na função.
   let l_qtde = l_qtde - 1

   for l_index = 1 to l_qtde

       if mr_retorno[l_index].itarsrcaomtvcod is not null then
          if mr_retorno[l_index].itarsrcaomtvcod = 1 and
             lr_condicoes.correntista = false then
             #display "mr_plano.correntista = ",lr_condicoes.correntista
             continue for
          end if      
          
          if mr_retorno[l_index].itarsrcaomtvcod = 7 and                   
             lr_condicoes.correntista = true then                         
             #display "mr_plano.correntista = ",lr_condicoes.correntista   
             continue for                                                  
          end if                                                           

          if g_doc_itau[1].ubbcod = 0 then
             if ( mr_retorno[l_index].itarsrcaomtvcod = 2 or
                  mr_retorno[l_index].itarsrcaomtvcod = 3) and
                  lr_condicoes.garantia = false then
                  #display " mr_plano.garantia = ", lr_condicoes.garantia
                continue for
             end if
             #if  mr_retorno[l_index].itarsrcaomtvcod = 7 then
             #  continue for
             #end if
          else
             #display " mr_plano.garantia = ", lr_condicoes.garantia
             if lr_condicoes.garantia = false then
                if mr_retorno[l_index].itarsrcaomtvcod = 2  or
                   mr_retorno[l_index].itarsrcaomtvcod = 3  then
                     #mr_retorno[l_index].itarsrcaomtvcod = 7 then
                     continue for
                end if
             else
                if g_doc_itau[1].itarsrcaosrvcod = 502 or
                   g_doc_itau[1].itarsrcaosrvcod = 503 or
                   g_doc_itau[1].itarsrcaosrvcod = 504 then
                   if  mr_retorno[l_index].itarsrcaomtvcod = 2 or
                        mr_retorno[l_index].itarsrcaomtvcod = 3 then
                     continue for
                   end if
                else
                   #if  mr_retorno[l_index].itarsrcaomtvcod = 7 then
                   #  continue for
                   #end if
                end if
              end if
           end if
          let mr_motivos[l_index2].itarsrcaomtvcod = mr_retorno[l_index].itarsrcaomtvcod
          let mr_motivos[l_index2].itarsrcaomtvdes = mr_retorno[l_index].itarsrcaomtvdes
          let mr_motivos[l_index2].dialimqtd       = mr_retorno[l_index].dialimqtd
          let l_index2 = l_index2 + 1

       end if

   end for

   return l_index2

end function

#--------------------------------------------------------------------------
function cts64m01_motivos()
#--------------------------------------------------------------------------

   define lr_retorno       record
          itarsrcaomtvcod  like datkitarsrcaomtv.itarsrcaomtvcod
         ,itarsrcaomtvdes  like datkitarsrcaomtv.itarsrcaomtvdes
         ,dialimqtd        like datkitarsrcaomtv.dialimqtd
   end record

   define t_cts64m01    array[500] of record
         itarsrcaomtvcod   like datkitarsrcaomtv.itarsrcaomtvcod,
         itarsrcaomtvdes   like datkitarsrcaomtv.itarsrcaomtvdes,
         dialimqtd         like datkitarsrcaomtv.dialimqtd
   end record


   define l_index     integer
         ,l_qtde      smallint
         ,arr_aux     integer
         ,l_utiliz    smallint
   let l_qtde     = 0
   let arr_aux    = 0
   let l_utiliz   = 0



   # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_motivos[l_index].* to  null
   end for

   # inicializando array tela de naturezas
   for l_index  =  1  to  500
       initialize  t_cts64m01[l_index].* to  null
   end for


   #---------------
   # Busca naturezas
   #---------------
   call cts64m01_carrega_array()
        returning l_qtde

   #-----------------
   # Carrega array tela
   #-----------------
   # Retira o ultimo indice devido ao foreach utilizado na função.
   let l_qtde = l_qtde - 1
   for l_index = 1 to l_qtde

       let t_cts64m01[l_index].itarsrcaomtvcod = mr_motivos[l_index].itarsrcaomtvcod
       let t_cts64m01[l_index].itarsrcaomtvdes = mr_motivos[l_index].itarsrcaomtvdes
       call cts64m03_qtd_servico(g_documento.itaciacod               ,
                                 g_documento.ramcod                  ,
                                 g_documento.aplnumdig               ,
                                 g_documento.itmnumdig               ,
                                 mr_motivos[l_index].itarsrcaomtvcod )
       returning l_utiliz
       # Transforma o Limite no Saldo
       let mr_motivos[l_index].dialimqtd = mr_motivos[l_index].dialimqtd - l_utiliz
       # Se saldo for negativo seta para 0
       if mr_motivos[l_index].dialimqtd < 0 then
       	  let mr_motivos[l_index].dialimqtd = 0
       end if
       let t_cts64m01[l_index].dialimqtd       = mr_motivos[l_index].dialimqtd

   end for

   #--------------
   # Abre a tela
   #--------------
   open window w_cts64m01 at 07,4 with form "cts64m01"
              attribute(form line 1, border)

   let int_flag = false

   message "  (F8)Seleciona "

   call set_count(l_index)

   display array t_cts64m01 to s_cts64m01.*

      on key (F8)


         let arr_aux = arr_curr()

             let lr_retorno.itarsrcaomtvcod = t_cts64m01[arr_aux].itarsrcaomtvcod
             let lr_retorno.itarsrcaomtvdes = t_cts64m01[arr_aux].itarsrcaomtvdes
             let lr_retorno.dialimqtd       = t_cts64m01[arr_aux].dialimqtd

            exit display

      on key (interrupt,control-c,f17)
            error "ESCOLHA UM MOTIVO COM (F8) Selecione"
            #exit display

   end display

   close window  w_cts64m01

   let int_flag = false

   return lr_retorno.*

end function

function cts64m01_verifica_motivos(lr_param)


 define lr_param record
        itarsrcaomtvcod    like datkitarsrcaomtv.itarsrcaomtvcod
   end record


 define lr_retorno record
        flag    smallint,
        itarsrcaomtvdes    like datkitarsrcaomtv.itarsrcaomtvdes
 end record

 define l_index integer,
        l_qtde  integer

    # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_motivos[l_index].* to  null
   end for

   initialize lr_retorno.* to null
   let l_index = 0
   let l_qtde = 0
   let lr_retorno.flag = false

   call cts64m01_carrega_array()
        returning l_qtde

    for l_index = 1 to l_qtde

       if mr_motivos[l_index].itarsrcaomtvcod = lr_param.itarsrcaomtvcod then
          let lr_retorno.flag = true
          let lr_retorno.itarsrcaomtvdes = mr_motivos[l_index].itarsrcaomtvdes
          exit for
       end if
    end for

    return lr_retorno.*

end function

function cts64m01_condicoes(lr_param)


   define lr_param record
          tpretorno smallint
   end record


   define lr_retorno record
        correntista     smallint,
        garantia        smallint,
        arcondicionado  smallint
   end record


   initialize lr_retorno.* to null




      case g_doc_itau[1].rsrcaogrtcod

      when 1
          let lr_retorno.correntista = false
      when 2
           let lr_retorno.correntista = false
      when 3
           let lr_retorno.correntista = true
      when 4
          let lr_retorno.correntista = true
      otherwise
          let lr_retorno.correntista = false
      end case


     if g_doc_itau[1].ubbcod = 0 then

       case g_doc_itau[1].itarsrcaosrvcod
       when 0
          let lr_retorno.garantia    = false
          let lr_retorno.arcondicionado = false
       when 800
          let lr_retorno.garantia    = true
          let lr_retorno.arcondicionado = true
       when 801
          let lr_retorno.garantia    = true
          let lr_retorno.arcondicionado = false
       otherwise
           let lr_retorno.garantia    = false
           let lr_retorno.arcondicionado = false
       end case


       if g_doc_itau[1].itarsrcaosrvcod = 0 then
          let lr_retorno.garantia    = false
       else
          let lr_retorno.garantia    = true
      end if
     else
       if  g_doc_itau[1].ubbcod = 1 then

           case g_doc_itau[1].itaasisrvcod

           when 502
               let lr_retorno.garantia = true
               let lr_retorno.arcondicionado = false
           when 503
               let lr_retorno.garantia = true
               let lr_retorno.arcondicionado = true
           when 504
               let lr_retorno.garantia = true
               let lr_retorno.arcondicionado = true
           when 505
               let lr_retorno.garantia = true
               let lr_retorno.arcondicionado = false
           when 508
               let lr_retorno.garantia = true
               let lr_retorno.arcondicionado = true
           otherwise
              let lr_retorno.garantia = false
              let lr_retorno.arcondicionado = false
           end case
       else
         let lr_retorno.garantia = false
         let lr_retorno.arcondicionado = false
       end if
     end if

   if lr_param.tpretorno = 1 then
      return lr_retorno.correntista,
             lr_retorno.garantia
   end if

   if lr_param.tpretorno = 2 then
      return lr_retorno.arcondicionado
   end if


end function

#--------------------------------------------------------------------------
function cts64m01_motivos_multiplos(lr_param)
#--------------------------------------------------------------------------

   define lr_param record
          itarsrcaomtvcod    like datkitarsrcaomtv.itarsrcaomtvcod,
          atdsrvnum          like datmservico.atdsrvnum,
          atdsrvano          like datmservico.atdsrvano,
          tipo               char(1)
   end record

   define t_cts64m01a   array[500] of record
         marca             char(1),
         itarsrcaomtvcod   like datkitarsrcaomtv.itarsrcaomtvcod,
         itarsrcaomtvdes   like datkitarsrcaomtv.itarsrcaomtvdes,
         dialimqtd         like datkitarsrcaomtv.dialimqtd
   end record

   define am_retorno array[10] of record
          itarsrcaomtvcod  like datkitarsrcaomtv.itarsrcaomtvcod,
          itarsrcaomtvdes   like datkitarsrcaomtv.itarsrcaomtvdes,
          dialimqtd         like datkitarsrcaomtv.dialimqtd
   end record



   define l_index        integer
         ,l_qtde         smallint
         ,l_qtde_motivos smallint
         ,arr_aux        integer
         ,l_x            smallint
         ,l_arrc         smallint
         ,l_tela         smallint
         ,l_index1       smallint
         ,l_saldo        integer
         ,l_flag         smallint




   let l_qtde     = 0
   let arr_aux    = 0
   let l_index1   = 1
   let l_tela     = 0
   let l_qtde_motivos = 0
   let l_saldo = 0
   let l_flag = false



   # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_motivos[l_index].* to  null
   end for

   # inicializando array tela de naturezas
   for l_index  =  1  to  500
       initialize  t_cts64m01a[l_index].* to  null
   end for

   # inicializando array tela de naturezas
   for l_index  =  1  to  10
       initialize  am_retorno[l_index].* to  null
   end for

   #---------------
   # Busca Motivos
   #---------------
   call cts64m01_carrega_array()
        returning l_qtde

   if lr_param.tipo = "P" then
      #call cts64m01
   end if



   #-----------------
   # Carrega array tela
   #-----------------
   # Retira o ultimo indice devido ao foreach utilizado na função.
   let l_qtde = l_qtde - 1
   for l_index = 1 to l_qtde


       if lr_param.itarsrcaomtvcod = mr_motivos[l_index].itarsrcaomtvcod or
          mr_motivos[l_index].itarsrcaomtvcod = 6 then
          if lr_param.itarsrcaomtvcod <> 8 then 
             continue for
          end if
       end if

       if mr_motivos[l_index].itarsrcaomtvcod = 2 and
          lr_param.itarsrcaomtvcod = 3 then
          continue for
       end if

       if mr_motivos[l_index].itarsrcaomtvcod = 3 and
          lr_param.itarsrcaomtvcod = 2 then
          continue for
       end if

       if mr_motivos[l_index].itarsrcaomtvcod = 5 and
          lr_param.tipo <> "P"   then
          continue for
       end if


       if lr_param.tipo = "P" then
          call cts64m01_saldo(mr_motivos[l_index].itarsrcaomtvcod)
               returning l_flag,l_saldo
          if l_flag = true then
             if l_saldo <= 0 then
                continue for
             else
                let mr_motivos[l_index].dialimqtd = l_saldo
             end if
          end if
       end if

       let t_cts64m01a[l_index1].itarsrcaomtvcod = mr_motivos[l_index].itarsrcaomtvcod
       let t_cts64m01a[l_index1].itarsrcaomtvdes = mr_motivos[l_index].itarsrcaomtvdes
       let t_cts64m01a[l_index1].dialimqtd       = mr_motivos[l_index].dialimqtd
       let l_index1 = l_index1 + 1

   end for

   if l_index1 = 1 then
      error "Nao Existe Outros Motivos"
      return l_qtde_motivos,
          am_retorno[1].*,
          am_retorno[2].*,
          am_retorno[3].*,
          am_retorno[4].*,
          am_retorno[5].*,
          am_retorno[6].*,
          am_retorno[7].*,
          am_retorno[8].*,
          am_retorno[9].*
    end if



   #--------------
   # Abre a tela
   #--------------
   open window w_cts64m01a at 07,4 with form "cts64m01a"
              attribute(form line 1, border)

   let int_flag = false


   display "(F8) Confirma" to obs

   call set_count(l_index1 - 1)
   let l_arrc = arr_count()
   input array t_cts64m01a without defaults from s_cts64m01a.*

      #-----------------
        before row
      #-----------------
       let l_arrc = arr_curr()
       let l_tela = scr_line()


        if t_cts64m01a[l_arrc].itarsrcaomtvcod is null then
            next field marca
         end if

      #-----------------
        after row
      #-----------------
      if (fgl_lastkey() = fgl_keyval("down")    or
          fgl_lastkey() = fgl_keyval("right")   or
          fgl_lastkey() = fgl_keyval("return")) and
          l_arrc = arr_count()                  then


          next field marca
      end if




     #-------------------
     before field marca
     #-------------------
     if t_cts64m01a[l_arrc].marca = 'X' then

        for i = 0 to arr_count()

           if t_cts64m01a[i].marca = "X" then

              case t_cts64m01a[l_arrc].itarsrcaomtvcod

              when 2
                  if  t_cts64m01a[i].itarsrcaomtvcod = 3   then
                      error "Motivo 3 COBERTURA CONTRADA II já escolhido, escolha outro Motivo !"
                      next field marca
                  end if
                  if t_cts64m01a[i].itarsrcaomtvcod  = 5  then
                      error "Motivo 5 CENTRO DE CUSTO já escolhido, escolha outro Motivo !"
                      next field marca
                  end if
              when 3
                  if  t_cts64m01a[i].itarsrcaomtvcod = 2 then
                      error "Motivo 2 COBERTURA CONTRADA PP já escolhido, escolha outro Motivo !"
                      next field marca
                  end if
                  if t_cts64m01a[i].itarsrcaomtvcod  = 5  then
                     error "Motivo 5 CENTRO DE CUSTO já escolhido, escolha outro Motivo !"
                     next field marca
                  end if
              when 4
                  if  t_cts64m01a[i].itarsrcaomtvcod = 5 then
                      error "Motivo 5 CENTRO DE CUSTO já escolhido, escolha outro Motivo !"
                      next field marca
                  end if
              when 5
                  if  t_cts64m01a[i].itarsrcaomtvcod <> 5 then
                      error "Não é possivel escolher o Motivo 5 , escolha outro Motivo !"
                      next field marca
                  end if

             end case
           end if
        end for

      end if


      on key (F8)

         let t_cts64m01a[l_arrc].marca = get_fldbuf(marca)
         #display "t_cts64m01a[",l_arrc,"].marca = ",t_cts64m01a[l_arrc].marca

         for l_index = 1 to arr_count()

            #display "t_cts64m01a[",l_index,"].marca = ",t_cts64m01a[l_index].marca
            if t_cts64m01a[l_index].marca = 'X' then
               let am_retorno[l_index].itarsrcaomtvcod = t_cts64m01a[l_index].itarsrcaomtvcod
               let am_retorno[l_index].itarsrcaomtvdes = t_cts64m01a[l_index].itarsrcaomtvdes
               let am_retorno[l_index].dialimqtd = t_cts64m01a[l_index].dialimqtd
               let l_qtde_motivos = l_qtde_motivos + 1
             end if
         end for

         if l_qtde_motivos = 0 then
             error 'Selecione ao menos uma Motivo!'
         else
            exit input
         end if

      on key (interrupt,control-c,f17)
            error "SELECIONE O (F8)Confirma"

            #exit input

   end input

   close window  w_cts64m01a

   let int_flag = false

   return l_qtde_motivos,
          am_retorno[1].*,
          am_retorno[2].*,
          am_retorno[3].*,
          am_retorno[4].*,
          am_retorno[5].*,
          am_retorno[6].*,
          am_retorno[7].*,
          am_retorno[8].*,
          am_retorno[9].*



end function

function cts64m01_calcula_dias_motivo(lr_param)

define lr_param record
      itarsrcaomtvcod   like datkitarsrcaomtv.itarsrcaomtvcod,
      dialimqtd         like datkitarsrcaomtv.dialimqtd,
      totaldias         like datkitarsrcaomtv.dialimqtd
end record

define lr_retorno record
       dias_utilz integer,
       dias_prev  integer,
       saldo      integer
end record

 initialize lr_retorno.* to null

 if lr_param.totaldias < lr_param.dialimqtd then
    let lr_retorno.dias_utilz = lr_param.totaldias
    if (lr_param.dialimqtd - lr_param.totaldias) > 0 then
       let lr_retorno.saldo = lr_param.totaldias - lr_param.dialimqtd
    else
       let lr_retorno.saldo = 0
    end if
 else
    let lr_retorno.dias_utilz = lr_param.dialimqtd
    let lr_retorno.saldo = lr_param.totaldias  - lr_param.dialimqtd
 end if

 if lr_retorno.saldo >= lr_param.dialimqtd then
    let lr_retorno.dias_prev = lr_param.dialimqtd
 else
    let lr_retorno.dias_prev = lr_retorno.dias_utilz
 end if

return lr_retorno.*

end function

#==========================================
function cts64m01_saldo(lr_param)

define lr_param record
     itarsrcaomtvcod   like datkitarsrcaomtv.itarsrcaomtvcod
end record

define l_saldo  integer,
       l_prev   integer,
       l_limite integer,
       l_util   integer,
       l_flag   smallint


let l_saldo  = 0
let l_prev   = 0
let l_util   = 0
let l_limite = 0
let l_flag = false

if m_cts64m01_prep is null or
   m_cts64m01_prep = false then
   call cts64m01_prepare()
end if


whenever error continue
open c_cts64m01_002 using g_documento.atdsrvnum,
                          g_documento.atdsrvano,
                          lr_param.itarsrcaomtvcod
fetch c_cts64m01_002 into l_prev,
                          l_util,
                          l_limite
whenever error stop

if sqlca.sqlcode <> notfound then
   let l_saldo = l_limite - l_util
   let l_flag = true
end if

return l_flag,l_saldo

end function



