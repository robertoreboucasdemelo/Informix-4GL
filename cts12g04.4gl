#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cts12g04                                                  #
# Objetivo.......: Lista de Naturezas a Residencia do Plano Itau             #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Roberto Melo                                              #
# Liberacao      : 03/05/2011                                                #
#............................................................................#
# 13/05/2015       Roberto           PJ                                      #
#............................................................................#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_prepare  smallint

define mr_retorno array[500] of record
    socntzcod   like  datksocntz.socntzcod        ,
    socntzdes   like  datksocntz.socntzdes        ,
    utzlmtqtd   like  datritaasiplnnat.utzlmtqtd
end record

define mr_servicos   array[500] of record
       socntzcod     like datksocntz.socntzcod
      ,socntzdes     char(50)
      ,utiliz        integer
      ,limite        like rgfrclsemrsrv.atdqtd
      ,saldo         integer
end record


#------------------------------------------------------------------------------
function cts12g04_prepare()
#------------------------------------------------------------------------------

define l_sql char(10000)

 let l_sql = ' select a.socntzcod                     '
          ,  '      , a.socntzdes                     '
          ,  '      , b.utzlmtqtd                     '
          ,  '   from datksocntz a                    '
          ,  '      , datritaasiplnnat b              '
          ,  '  where a.socntzcod    = b.socntzcod    '
          ,  '    and b.itaasiplncod = ?              '
          ,  '  order by a.socntzcod                  '
 prepare p_cts12g04_001 from l_sql
 declare c_cts12g04_001 cursor for p_cts12g04_001

end function

#------------------------------------------------------------------------------
function cts12g04_rec_natureza(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasiplncod like datkitaasipln.itaasiplncod
end record

define lr_retorno record
    socntzcod    like  datksocntz.socntzcod        ,
    socntzdes    like  datksocntz.socntzdes        ,
    utzlmtqtd    like  datritaasiplnnat.utzlmtqtd
end record      


define l_index integer

for  l_index  =  1  to  500
   initialize  mr_retorno[l_index].* to  null
end  for
	
initialize lr_retorno.* to null

if m_prepare is null or
   m_prepare <> true then
   call cts12g04_prepare()
end if

   let l_index = 1

   open c_cts12g04_001 using lr_param.itaasiplncod
   foreach c_cts12g04_001 into lr_retorno.socntzcod  ,
                               lr_retorno.socntzdes  ,
                               lr_retorno.utzlmtqtd

   
       #-----------------------------------------------------------------------
       # Valida se o Correntista e Não Correntista tem Direito a Natureza    
       #-----------------------------------------------------------------------
       
       if not cty22g00_valida_natureza_garantia(g_doc_itau[1].rsrcaogrtcod  ,
                                                lr_param.itaasiplncod       ,
                                                lr_retorno.socntzcod        ) then  
           continue foreach                                    
       end if                      
   
       let mr_retorno[l_index].socntzcod =  lr_retorno.socntzcod
       let mr_retorno[l_index].socntzdes =  lr_retorno.socntzdes
       let mr_retorno[l_index].utzlmtqtd =  lr_retorno.utzlmtqtd
   
   
       let l_index = l_index + 1

   end foreach

   return l_index

end function

#--------------------------------------------------------------------------
function cts12g04(lr_param)
#--------------------------------------------------------------------------

   define lr_param record
          itaasiplncod       like datkitaasipln.itaasiplncod
   end record

   define lr_retorno   record
          sqlcode      integer
         ,msgerro      char(500)
         ,socntzcod    like datksocntz.socntzcod
   end record

   define t_cts12g04    array[500] of record
          socntzcod     like datksocntz.socntzcod
         ,socntzdes     char(50)
         ,utiliz        smallint
         ,limite        smallint
         ,saldo         smallint
   end record



   define l_limite    decimal(15,5)
         ,l_saldo     integer
         ,l_util      decimal(15,5)
         ,l_index     integer
         ,l_null      char(1)
         ,l_flag      smallint
         ,l_qtde      smallint
         ,arr_aux     integer



   let l_limite   = 0
   let l_saldo    = 0
   let l_util     = 0
   let l_index    = 0
   let l_null     = null
   let l_qtde     = 0
   let arr_aux    = 0
   initialize lr_retorno.* to null


   # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for

   # inicializando array tela de naturezas
   for l_index  =  1  to  500
       initialize  t_cts12g04[l_index].* to  null
   end for


   #---------------
   # Busca naturezas
   #---------------
   call cts12g04_carrega_array(lr_param.itaasiplncod)
        returning l_qtde

   #-----------------
   # Carrega array tela
   #-----------------
   # Retira o ultimo indice devido ao foreach utilizado na função.
   for l_index = 1 to l_qtde

       let t_cts12g04[l_index].socntzcod = mr_servicos[l_index].socntzcod
       let t_cts12g04[l_index].socntzdes = mr_servicos[l_index].socntzdes

       let t_cts12g04[l_index].utiliz    = mr_servicos[l_index].utiliz
       let t_cts12g04[l_index].limite    = mr_servicos[l_index].limite
       let t_cts12g04[l_index].saldo     = mr_servicos[l_index].limite -
                                           mr_servicos[l_index].utiliz

   end for

   #--------------
   # Abre a tela
   #--------------
   open window w_cts12g04 at 07,4 with form "cts12g04"
              attribute(form line 1, border)

   let int_flag = false

   message "(F8)Seleciona                            "

   call set_count(l_index - 1)

   display array t_cts12g04 to s_cts12g04.*


      on key (F8)

         let arr_aux = arr_curr()

            if t_cts12g04[arr_aux].saldo > 0 then
               let lr_retorno.socntzcod = t_cts12g04[arr_aux].socntzcod
            else
               error "QUANTIDADE DE SERVICOS JA ESGOTADOS PARA A NATUREZA SELECIONADA" sleep 2
            end if
            exit display


      on key (interrupt,control-c,f17)
            exit display

   end display

   close window  w_cts12g04

   let int_flag = false

   return lr_retorno.socntzcod

end function


function cts12g04_carrega_array(lr_param)

   define lr_param record
          itaasiplncod       like datkitaasipln.itaasiplncod
   end record

   define l_index integer,
          l_qtde  integer

   let l_index = 0
   let l_qtde = 0

   # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for

   call cts12g04_rec_natureza(lr_param.itaasiplncod)
        returning l_qtde

   #-----------------
   # Carrega array tela
   #-----------------
   # Retira o ultimo indice devido ao foreach utilizado na função.
   let l_qtde = l_qtde - 1

   for l_index = 1 to l_qtde
   	
  
       let mr_servicos[l_index].socntzcod = mr_retorno[l_index].socntzcod
       let mr_servicos[l_index].socntzdes = mr_retorno[l_index].socntzdes

       call cts61m01_qtd_servico(g_documento.itaciacod           ,
                                 g_documento.ramcod              ,
                                 g_documento.aplnumdig           ,
                                 g_documento.itmnumdig           ,
                                 mr_servicos[l_index].socntzcod  ,
                                 g_documento.c24astcod           ,
                                 lr_param.itaasiplncod           )
             returning mr_servicos[l_index].utiliz
       
       let mr_servicos[l_index].limite    = mr_retorno[l_index].utzlmtqtd
       let mr_servicos[l_index].saldo     = mr_servicos[l_index].limite -
                                            mr_servicos[l_index].utiliz

   end for

   return l_qtde

end function

function cts12g04_verifica_saldo(lr_param)

 define lr_param record
          itaasiplncod       like datkitaasipln.itaasiplncod
 end record

 define lr_retorno record
        flag    smallint,
        sqlcode smallint,
        mens    char(500)
 end record

 define l_index integer,
        l_qtde  integer

    # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for

   initialize lr_retorno.* to null
   let l_index = 0
   let l_qtde = 0
   let lr_retorno.flag = false

   call cts12g04_carrega_array(lr_param.itaasiplncod)
        returning l_qtde

    for l_index = 1 to l_qtde

       if mr_servicos[l_index].saldo > 0 then
          let lr_retorno.flag = true
       end if
    end for

    return lr_retorno.flag

end function

function cts12g04_verifica_natureza(lr_param)

 define lr_param record
      itaasiplncod like datkitaasipln.itaasiplncod,
      socntzcod    like datksocntz.socntzcod
 end record

 define lr_retorno record
        flag    smallint,
        existe  smallint,
        sqlcode smallint,
        mens    char(500)
 end record

 define l_index integer,
        l_qtde  integer

    # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for
  
   initialize lr_retorno.* to null
   let l_index = 0
   let l_qtde = 0
   let lr_retorno.flag = false

   call cts12g04_carrega_array(lr_param.itaasiplncod)
        returning l_qtde

    for l_index = 1 to l_qtde
       if mr_servicos[l_index].socntzcod = lr_param.socntzcod then
          let lr_retorno.existe = true
          if mr_servicos[l_index].saldo > 0 then
             let lr_retorno.flag = true
          end if
       end if

    end for

    if lr_retorno.existe = true then
        if lr_retorno.flag = false then
           let lr_retorno.mens = 'Limite da Natureza excedido !'
        else
           let lr_retorno.mens = ' '
        end if
    else
       let lr_retorno.flag = false
       let lr_retorno.mens = 'Natureza nao permitida para esse Plano !'
    end if

    return lr_retorno.flag,lr_retorno.mens

end function

#------------------------------------------------------------------------------
function cts12g04_recupera_saldo(lr_param)
#------------------------------------------------------------------------------
define lr_param record
   itaasiplncod like datkitaasipln.itaasiplncod
end record
define lr_retorno  record
    socntzcod   like  datksocntz.socntzcod        ,
    socntzdes   like  datksocntz.socntzdes        ,
    utzlmtqtd   like  datritaasiplnnat.utzlmtqtd  ,
    utiliz      integer                           ,
    saldo       integer
end record
initialize  lr_retorno.* to  null
if m_prepare is null or
   m_prepare <> true then
   call cts12g04_prepare()
end if

   let lr_retorno.saldo = 0
   open c_cts12g04_001 using lr_param.itaasiplncod
   foreach c_cts12g04_001 into lr_retorno.socntzcod  ,
                               lr_retorno.socntzdes  ,
                               lr_retorno.utzlmtqtd
       call cts61m01_qtd_servico(g_documento.itaciacod ,
                                 g_documento.ramcod    ,
                                 g_documento.aplnumdig ,
                                 g_documento.itmnumdig ,
                                 lr_retorno.socntzcod  ,
                                 g_documento.c24astcod ,
                                 lr_param.itaasiplncod)
       returning lr_retorno.utiliz
       let lr_retorno.saldo =  lr_retorno.saldo + (lr_retorno.utzlmtqtd - lr_retorno.utiliz)
   end foreach
   return lr_retorno.saldo
end function
