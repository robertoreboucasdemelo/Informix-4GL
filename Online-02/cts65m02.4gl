#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cts65m02                                                  #
# Objetivo.......: Lista naturezas do mesmo grupo                            #
# Analista Resp. : Amilton Pinto                                             #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Amilton Pinto                                              #
# Liberacao      : 04/05/2011                                                #
#............................................................................#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cts65m02_prep  smallint






#------------------------------------------------------------------------------
function cts65m02_prepare()
#------------------------------------------------------------------------------

define l_sql char(10000)

  let l_sql =  ' select grpcod '
             ,' from datrntzasipln '
             ,' where  '
             ,' socntzcod = ? '
             ,' and asiplncod = ? '
  prepare p_cts65m02_001 from l_sql
  declare c_cts65m02_001 cursor for p_cts65m02_001

  let l_sql = ' select launumflg  '
             ,'  from datkresitagrp '
             ,'  where  '
             ,'  grpcod = ? '
  prepare p_cts65m02_002 from l_sql
  declare c_cts65m02_002 cursor for p_cts65m02_002


  let l_sql = ' select a.socntzcod               '
          ,  '       , a.socntzdes               '
          ,  '   from datksocntz a               '
          ,  '      , datrntzasipln b            '
          ,  '  where a.socntzcod  = b.socntzcod '
          ,  '    and grpcod = ?                 '
          ,  '    and b.asiplncod = ?            '
          ,  '  order by b.grpcod,a.socntzcod    '
 prepare p_cts65m02_003 from l_sql
 declare c_cts65m02_003 cursor for p_cts65m02_003


  let m_cts65m02_prep = true

end function


#--------------------------------------------------------------------------
function cts65m02_naturezas_conjuntas(lr_param)
#--------------------------------------------------------------------------

   define lr_param record
          socntzcod      like datksocntz.socntzcod
   end record

   define t_cts65m02   array[500] of record
         marca          char(1)
        ,socntzcod      like datksocntz.socntzcod
        ,socntzdes      like datksocntz.socntzdes
   end record

   define am_retorno array[10] of record
           socntzcod      like datksocntz.socntzcod
          ,socntzdes      like datksocntz.socntzdes
          ,espcod         like datmsrvre.espcod
          ,espdes         like dbskesp.espdes
          ,c24pbmcod      like datkpbm.c24pbmcod
          ,atddfttxt      like datmservico.atddfttxt
   end record

    define am_naturezas array[10] of record
            socntzcod      like datksocntz.socntzcod
    end record


   define l_index        integer
         ,l_qtde         smallint
         ,arr_aux        integer
         ,l_x            smallint
         ,l_arrc         smallint
         ,l_tela         smallint
         ,l_index1       smallint
         ,l_socntzcod    like datksocntz.socntzcod
         ,l_socntzdes    like datksocntz.socntzdes
         ,l_laudo        char(1)
         ,l_grpcod       like datkresitagrp.grpcod
         ,l_null         char(1)
         ,l_status       smallint
         ,l_mens         char(1000)


   let l_qtde      = 0
   let arr_aux     = 0
   let l_index     = 0
   let l_index1    = 0
   let l_tela      = 0
   let l_socntzcod = null
   let l_socntzdes = null
   let l_laudo     = null
   let l_grpcod    = null
   let l_null      = null
   let l_mens      = null




   # inicializando array tela de naturezas
   for l_index  =  1  to  500
       initialize  t_cts65m02[l_index].* to  null
   end for

   # inicializando array tela de naturezas
   for l_index  =  1  to  10
       initialize  am_retorno[l_index].* to  null
   end for

   # inicializando array tela de naturezas
   for l_index  =  1  to  10
       initialize  am_naturezas[l_index].* to  null
   end for


   if m_cts65m02_prep <> true or
      m_cts65m02_prep is not null then
      call cts65m02_prepare()
   end if



  #---------------
  # Busca naturezas
  #---------------
  whenever error continue
  open c_cts65m02_001 using lr_param.socntzcod,g_doc_itau[1].itaasisrvcod
  fetch c_cts65m02_001 into l_grpcod
  whenever error stop


  whenever error continue
      open c_cts65m02_002 using l_grpcod
      fetch c_cts65m02_002 into l_laudo
  whenever error stop


  if l_laudo = "S" then

     let l_index = 0
     whenever error continue
     open c_cts65m02_003 using l_grpcod,
                               g_doc_itau[1].itaasisrvcod
     whenever error stop

     foreach c_cts65m02_003 into l_socntzcod,
                                 l_socntzdes

      if l_socntzcod = lr_param.socntzcod then
         continue foreach
      else
         let l_index = l_index + 1
         let t_cts65m02[l_index].socntzcod = l_socntzcod
         let t_cts65m02[l_index].socntzdes = l_socntzdes
         #display " t_cts65m02[l_index].socntzcod = ",t_cts65m02[l_index].socntzcod
         #display " t_cts65m02[l_index].socntzdes = ",t_cts65m02[l_index].socntzdes
      end if

     end foreach
  end if


   if l_index = 0 then
      error "não existe outras naturezas"
      return am_retorno[1].*,
          am_retorno[2].*,
          am_retorno[3].*,
          am_retorno[4].*,
          am_retorno[5].*,
          am_retorno[6].*,
          am_retorno[7].*,
          am_retorno[8].*,
          am_retorno[9].*,
          am_retorno[10].*
    end if



   #--------------
   # Abre a tela
   #--------------
   open window w_cts65m02 at 07,4 with form "cts65m02"
              attribute(form line 1, border)

   let int_flag = false


   display "(F8) Confirma" to obs

   call set_count(l_index)
   let l_arrc = arr_count()
   input array t_cts65m02 without defaults from s_cts65m02.*

      #-----------------
        before row
      #-----------------
       let l_arrc = arr_curr()
       let l_tela = scr_line()


        if t_cts65m02[l_arrc].socntzcod is null then
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
     if t_cts65m02[l_arrc].marca = 'X' then

        let l_index1 = l_index1 + 1
        let am_retorno[l_index1].socntzcod = t_cts65m02[l_arrc].socntzcod
        let am_retorno[l_index1].socntzdes = t_cts65m02[l_arrc].socntzdes






        #for i = 0 to arr_count()
        #
        #   if t_cts65m02a[i].marca = "X" then
        #
        #      case t_cts65m02a[l_arrc].itarsrcaomtvcod
        #
        #      when 2
        #          if  t_cts65m02a[i].itarsrcaomtvcod = 3   then
        #              error "Motivo 3 COBERTURA CONTRADA II já escolhido, escolha outro Motivo !"
        #              next field marca
        #          end if
        #          if t_cts65m02a[i].itarsrcaomtvcod  = 5  then
        #              error "Motivo 5 CENTRO DE CUSTO já escolhido, escolha outro Motivo !"
        #              next field marca
        #          end if
        #      when 3
        #          if  t_cts65m02a[i].itarsrcaomtvcod = 2 then
        #              error "Motivo 2 COBERTURA CONTRADA PP já escolhido, escolha outro Motivo !"
        #              next field marca
        #          end if
        #          if t_cts65m02a[i].itarsrcaomtvcod  = 5  then
        #             error "Motivo 5 CENTRO DE CUSTO já escolhido, escolha outro Motivo !"
        #             next field marca
        #          end if
        #      when 4
        #          if  t_cts65m02a[i].itarsrcaomtvcod = 5 then
        #              error "Motivo 5 CENTRO DE CUSTO já escolhido, escolha outro Motivo !"
        #              next field marca
        #          end if
        #      when 5
        #          if  t_cts65m02a[i].itarsrcaomtvcod <> 5 then
        #              error "Não é possivel escolher o Motivo 5 , escolha outro Motivo !"
        #              next field marca
        #          end if
        #
        #     end case
        #   end if
        #end for

      end if

      #after field marca
      #
      #if t_cts65m02[l_arrc].marca = 'X' then
      #
      #   display "ABRE PROBLEMA"
      #
      #end if




      on key (F8)

         #let t_cts65m02[l_arrc].marca = get_fldbuf(marca)


         for l_index1 = 1 to arr_count()
            #let t_cts65m02[l_index1].marca = get_fldbuf(marca)
            #display "t_cts65m02[l_index1].marca = ",t_cts65m02[l_index1].marca
            #prompt "teste"
            if t_cts65m02[l_index1].socntzcod is not null then
               #let am_retorno[l_index1].socntzcod = t_cts65m02[l_index1].socntzcod
               #let am_retorno[l_index1].socntzdes = t_cts65m02[l_index1].socntzdes

               #display "am_retorno[l_index1].socntzcod = ",am_retorno[l_index1].socntzcod
               call cts17m07_problema(g_documento.aplnumdig
                                     ,g_documento.c24astcod
                                     ,g_documento.atdsrvorg
                                     ,l_null
                                     ,am_retorno[l_index1].socntzcod
                                     ,l_null
                                     ,l_null
                                     ,l_null
                                     ,g_documento.ramcod
                                     ,g_documento.crtsaunum )
                            returning l_status
                                     ,l_mens
                                     ,am_retorno[l_index1].c24pbmcod
                                     ,am_retorno[l_index1].atddfttxt
                   #display "am_retorno[l_index1].c24pbmcod = ",am_retorno[l_index1].c24pbmcod

               let l_qtde = l_qtde + 1
             end if
         end for

         if l_qtde = 0 then
             error 'Selecione ao menos uma natureza!'
         else
           exit input
         end if

      on key (interrupt,control-c,f17)
            error "SELECIONE O (F8)Confirma"


   end input

   close window  w_cts65m02

   let int_flag = false

   return am_retorno[1].*,
          am_retorno[2].*,
          am_retorno[3].*,
          am_retorno[4].*,
          am_retorno[5].*,
          am_retorno[6].*,
          am_retorno[7].*,
          am_retorno[8].*,
          am_retorno[9].*,
          am_retorno[10].*

end function

