#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cts12g11                                                  #
# Objetivo.......: Lista de Naturezas a Residencia do Plano Itau             #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: R.Fornax                                                  #
# Liberacao      : 05/08/2014                                                #
#............................................................................#
# 13/05/2015       Roberto       PJ                                          #
#............................................................................#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_prepare  smallint

define mr_retorno array[500] of record
    socntzcod    like  datksocntz.socntzcod        ,
    socntzdes    like  datksocntz.socntzdes
end record

define mr_servicos   array[500] of record
    socntzcod     like datksocntz.socntzcod
   ,socntzdes     char(50)
   ,utiliz        integer
end record

define mr_param record
	limite  smallint,
  saldo   smallint
end record


#------------------------------------------------------------------------------
function cts12g11_prepare()
#------------------------------------------------------------------------------

define l_sql char(10000)

 let l_sql =  ' select a.socntzcod     ,           '
             ,'        b.socntzdes                 '
             ,' from datrclisgmasiplnntz a,        '
             ,'          datksocntz b              '
             ,' where a.socntzcod  = b.socntzcod   '
             ,' and a.itaasiplncod = ?             '
             ,' and a.itaclisgmcod = ?             '
             ,' and a.vigincdat <=  ?              '
             ,' and a.vigfnldat >=  ?              '
             ,' order by a.socntzcod               '
 prepare p_cts12g11_001 from l_sql
 declare c_cts12g11_001 cursor for p_cts12g11_001

 let l_sql = ' select srvlimdat                       '
          ,  '   from datkitaasipln                   '
          ,  '  where itaasiplncod = ?                '
 prepare p_cts12g11_002 from l_sql
 declare c_cts12g11_002 cursor for p_cts12g11_002

 let l_sql = ' select ressrvlimqtd                    '
          ,  '   from datkitaasipln                   '
          ,  '  where itaasiplncod = ?                '
 prepare p_cts12g11_003 from l_sql
 declare c_cts12g11_003 cursor for p_cts12g11_003


end function

#------------------------------------------------------------------------------
function cts12g11_rec_natureza(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasiplncod    like datkitaasipln.itaasiplncod ,
   itaclisgmcod    like datkitaclisgm.itaclisgmcod ,
   itaaplvigincdat like datmitaapl.itaaplvigincdat
end record

define lr_retorno record
    socntzcod    like  datksocntz.socntzcod        ,
    socntzdes    like  datksocntz.socntzdes
end record                            
                    

define l_index integer

for  l_index  =  1  to  500
   initialize  mr_retorno[l_index].* to  null  
end  for
	
initialize lr_retorno.* to null

if m_prepare is null or
   m_prepare <> true then
   call cts12g11_prepare()
end if


   let l_index = 1

   open c_cts12g11_001 using lr_param.itaasiplncod    ,
                             lr_param.itaclisgmcod    ,
                             lr_param.itaaplvigincdat ,
                             lr_param.itaaplvigincdat
   foreach c_cts12g11_001 into lr_retorno.socntzcod  ,
                               lr_retorno.socntzdes
     
       #-----------------------------------------------------------------------
       # Valida se o Correntista e Não Correntista tem Direito a Natureza    
       #-----------------------------------------------------------------------
       
       if not cty22g00_valida_natureza_garantia(g_doc_itau[1].rsrcaogrtcod  ,
                                                lr_param.itaasiplncod       ,
                                                lr_retorno.socntzcod        ) then  
           continue foreach                                    
       end if                      
     
     
       let mr_retorno[l_index].socntzcod = lr_retorno.socntzcod 
       let mr_retorno[l_index].socntzdes = lr_retorno.socntzdes 
                                        
       let l_index = l_index + 1

   end foreach

   return l_index

end function

#--------------------------------------------------------------------------
function cts12g11(lr_param)
#--------------------------------------------------------------------------

   define lr_param record
          itaasiplncod    like datkitaasipln.itaasiplncod ,
          itaclisgmcod    like datkitaclisgm.itaclisgmcod ,
          itaaplvigincdat like datmitaapl.itaaplvigincdat
   end record

   define lr_retorno   record
          sqlcode      integer
         ,msgerro      char(500)
         ,socntzcod    like datksocntz.socntzcod
   end record

   define t_cts12g11    array[500] of record
          socntzcod     like datksocntz.socntzcod
         ,socntzdes     char(50)
         ,utiliz        smallint
   end record



   define l_index     integer
         ,l_null      char(1)
         ,l_flag      smallint
         ,l_qtde      smallint
         ,arr_aux     integer



   let mr_param.limite   = 0
   let mr_param.saldo    = 0
   let l_index           = 0
   let l_null            = null
   let l_qtde            = 0
   let arr_aux           = 0

   initialize lr_retorno.* to null


   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for


   for l_index  =  1  to  500
       initialize  t_cts12g11[l_index].* to  null
   end for


   #---------------------------
   # Busca Naturezas
   #---------------------------
   call cts12g11_carrega_array(lr_param.itaasiplncod,
                               lr_param.itaclisgmcod,
                               lr_param.itaaplvigincdat)
   returning l_qtde



   for l_index = 1 to l_qtde

       let t_cts12g11[l_index].socntzcod = mr_servicos[l_index].socntzcod
       let t_cts12g11[l_index].socntzdes = mr_servicos[l_index].socntzdes

       let t_cts12g11[l_index].utiliz    = mr_servicos[l_index].utiliz

       let mr_param.saldo = mr_param.saldo + mr_servicos[l_index].utiliz

   end for


   call cts12g11_recupera_limite(lr_param.itaasiplncod)
   returning mr_param.limite

   let mr_param.saldo = mr_param.limite - mr_param.saldo


   open window w_cts12g11 at 7,4 with form "cts12g11"
   attribute(form line 1, border)

   let int_flag = false



   input by name mr_param.* without defaults

   		before field limite
   			display by name mr_param.limite
   			display by name mr_param.saldo

   end input

   message "       (F8) Seleciona"

   call set_count(l_index - 1)

   display array t_cts12g11 to s_cts12g11.*


      on key (interrupt,control-c,f17)
            exit display


      on key (F8)

      	let arr_aux = arr_curr()

      	   if mr_param.saldo > 0 then
      	      let lr_retorno.socntzcod = t_cts12g11[arr_aux].socntzcod
      	   else
      	      error "QUANTIDADE DE SERVICOS JA ESGOTADOS!" sleep 2
      	   end if

           exit display



   end display

   close window  w_cts12g11

   let int_flag = false

   return lr_retorno.socntzcod

end function

#--------------------------------------------
function cts12g11_carrega_array(lr_param)
#--------------------------------------------

   define lr_param record
      itaasiplncod    like datkitaasipln.itaasiplncod ,
      itaclisgmcod    like datkitaclisgm.itaclisgmcod ,
      itaaplvigincdat like datmitaapl.itaaplvigincdat
   end record

   define l_index integer,
          l_qtde  integer

   let l_index = 0
   let l_qtde  = 0


   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for

   call cts12g11_rec_natureza(lr_param.itaasiplncod,
                              lr_param.itaclisgmcod,
                              lr_param.itaaplvigincdat )
   returning l_qtde


   let l_qtde = l_qtde - 1

   for l_index = 1 to l_qtde
                   
                                                
       let mr_servicos[l_index].socntzcod = mr_retorno[l_index].socntzcod
       let mr_servicos[l_index].socntzdes = mr_retorno[l_index].socntzdes

       call cts61m02_qtd_servico(g_documento.itaciacod           ,
                                 g_documento.ramcod              ,
                                 g_documento.aplnumdig           ,
                                 g_documento.itmnumdig           ,
                                 mr_servicos[l_index].socntzcod  ,
                                 lr_param.itaasiplncod           )
       returning mr_servicos[l_index].utiliz


   end for

   return l_qtde

end function



#------------------------------------------------------------------------------
function cts12g11_recupera_limite(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasiplncod    like datkitaasipln.itaasiplncod
end record

define lr_retorno record
	 ressrvlimqtd like datkitaasipln.ressrvlimqtd
end record

initialize lr_retorno.* to null


if m_prepare is null or
   m_prepare <> true then
   call cts12g11_prepare()
end if


   open c_cts12g11_003 using lr_param.itaasiplncod
   whenever error continue
   fetch c_cts12g11_003 into lr_retorno.ressrvlimqtd
   whenever error stop

   close c_cts12g11_003


   return lr_retorno.ressrvlimqtd


end function

#------------------------------------------------------------------------------
function cts12g11_verifica_natureza(lr_param)
#------------------------------------------------------------------------------

 define lr_param record
      itaasiplncod    like datkitaasipln.itaasiplncod ,
      socntzcod       like datksocntz.socntzcod       ,
      itaclisgmcod    like datkitaclisgm.itaclisgmcod ,
      itaaplvigincdat like datmitaapl.itaaplvigincdat
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

   let mr_param.saldo    = 0

   let l_index = 0
   let l_qtde  = 0
   let lr_retorno.flag = false
   

   call cts12g11_carrega_array(lr_param.itaasiplncod   ,
                               lr_param.itaclisgmcod   ,
                               lr_param.itaaplvigincdat)
   returning l_qtde


   call cts12g11_recupera_limite(lr_param.itaasiplncod)
   returning mr_param.limite
   let mr_param.saldo = mr_param.limite - mr_param.saldo

   for l_index = 1 to l_qtde
      if mr_servicos[l_index].socntzcod = lr_param.socntzcod then
         let lr_retorno.existe = true
         if mr_param.saldo > 0 then
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
function cts12g11_verifica_saldo(lr_param)
#------------------------------------------------------------------------------

 define lr_param record
      itaasiplncod    like datkitaasipln.itaasiplncod ,
      itaclisgmcod    like datkitaclisgm.itaclisgmcod ,
      itaaplvigincdat like datmitaapl.itaaplvigincdat
 end record
 define l_index integer,
        l_qtde  integer

   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for
   let mr_param.saldo    = 0
   let l_index = 0
   let l_qtde  = 0
   call cts12g11_carrega_array(lr_param.itaasiplncod,
                               lr_param.itaclisgmcod,
                               lr_param.itaaplvigincdat)
   returning l_qtde
   for l_index = 1 to l_qtde
       let mr_param.saldo = mr_param.saldo + mr_servicos[l_index].utiliz
   end for
   call cts12g11_recupera_limite(lr_param.itaasiplncod)
   returning mr_param.limite
   let mr_param.saldo = mr_param.limite - mr_param.saldo
   return mr_param.saldo
end function
