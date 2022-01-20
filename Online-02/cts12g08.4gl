#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cts12g08                                                  #
# Objetivo.......: Lista de Naturezas a Residencia do Plano Itau             #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: R.Fornax                                                  #
# Liberacao      : 05/08/2014                                                #
#............................................................................#
# 13/05/2015       Roberto    PJ                                             #
#............................................................................#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_prepare  smallint

define mr_retorno array[500] of record
    socntzcod   like  datksocntz.socntzcod        ,
    socntzdes   like  datksocntz.socntzdes
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
function cts12g08_prepare()
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
 prepare p_cts12g08_001 from l_sql
 declare c_cts12g08_001 cursor for p_cts12g08_001

 let l_sql = ' select srvlimdat                       '
          ,  '   from datkitaasipln                   '
          ,  '  where itaasiplncod = ?                '
 prepare p_cts12g08_002 from l_sql
 declare c_cts12g08_002 cursor for p_cts12g08_002

 let l_sql = ' select ressrvlimqtd                    '
          ,  '   from datkitaasipln                   '
          ,  '  where itaasiplncod = ?                '
 prepare p_cts12g08_003 from l_sql
 declare c_cts12g08_003 cursor for p_cts12g08_003

 let l_sql =  ' select count(*)                         '
             ,' from datrclisgmasiplnntz a,             '
             ,'          datkitaasipln b                '
             ,' where a.itaasiplncod  = b.itaasiplncod  '
             ,' and a.itaasiplncod = ?                  '
             ,' and a.itaclisgmcod = ?                  '
             ,' and a.vigincdat <=  ?                   '
             ,' and a.vigfnldat >=  ?                   '
 prepare p_cts12g08_004 from l_sql
 declare c_cts12g08_004 cursor for p_cts12g08_004

end function

#------------------------------------------------------------------------------
function cts12g08_rec_natureza(lr_param)
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
   call cts12g08_prepare()
end if

   let l_index = 1

   open c_cts12g08_001 using lr_param.itaasiplncod    ,
                             lr_param.itaclisgmcod    ,
                             lr_param.itaaplvigincdat ,
                             lr_param.itaaplvigincdat
   foreach c_cts12g08_001 into lr_retorno.socntzcod  ,
                               lr_retorno.socntzdes

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
        
       let l_index = l_index + 1

   end foreach

   return l_index

end function

#--------------------------------------------------------------------------
function cts12g08(lr_param)
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

   define t_cts12g08    array[500] of record
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




   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for


   for l_index  =  1  to  500
       initialize  t_cts12g08[l_index].* to  null
   end for


   #---------------------------
   # Busca Naturezas
   #---------------------------
   call cts12g08_carrega_array(lr_param.itaasiplncod   ,
                               lr_param.itaclisgmcod   ,
                               lr_param.itaaplvigincdat)
   returning l_qtde



   for l_index = 1 to l_qtde

       let t_cts12g08[l_index].socntzcod = mr_servicos[l_index].socntzcod
       let t_cts12g08[l_index].socntzdes = mr_servicos[l_index].socntzdes

       let t_cts12g08[l_index].utiliz    = mr_servicos[l_index].utiliz

       let mr_param.saldo = mr_param.saldo + mr_servicos[l_index].utiliz

   end for


   call cts12g08_recupera_limite(lr_param.itaasiplncod)
   returning mr_param.limite

   let mr_param.saldo = mr_param.limite - mr_param.saldo


   open window w_cts12g08 at 3,2 with form "cts12g08"
   attribute(form line 1)

   let int_flag = false



   input by name mr_param.* without defaults

   		before field limite
   			display by name mr_param.limite
   			display by name mr_param.saldo

   end input

   message "       (F17)Abandona (F7) Extrato Auto (F8) Extrato Carro Reserva"

   call set_count(l_index - 1)

   display array t_cts12g08 to s_cts12g08.*


      on key (interrupt,control-c,f17)
            exit display

     on key (F7)
          if cts12g10_verifica_correntista(g_doc_itau[1].rsrcaogrtcod) then
              call cts12g09()
          else
          	  error "Extrato Liberado Somente para Correntista"
          end if

      on key (F8)
          call cts12g10(lr_param.itaclisgmcod   ,
                        lr_param.itaaplvigincdat)


   end display

   close window  w_cts12g08

   let int_flag = false


end function

#--------------------------------------------
function cts12g08_carrega_array(lr_param)
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

   call cts12g08_rec_natureza(lr_param.itaasiplncod   ,
                              lr_param.itaclisgmcod   ,
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
function cts12g08_valida_data_limite(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasiplncod    like datkitaasipln.itaasiplncod   ,
   itaaplvigincdat like datmitaapl.itaaplvigincdat
end record

define lr_retorno record
	 srvlimdat like datkitaasipln.srvlimdat
end record

initialize lr_retorno.* to null


if m_prepare is null or
   m_prepare <> true then
   call cts12g08_prepare()
end if


   open c_cts12g08_002 using lr_param.itaasiplncod
   whenever error continue
   fetch c_cts12g08_002 into lr_retorno.srvlimdat
   whenever error stop

   close c_cts12g08_002

   if lr_param.itaaplvigincdat >= lr_retorno.srvlimdat then
      return true
   else
   	  return false
   end if


end function

#------------------------------------------------------------------------------
function cts12g08_recupera_limite(lr_param)
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
   call cts12g08_prepare()
end if


   open c_cts12g08_003 using lr_param.itaasiplncod
   whenever error continue
   fetch c_cts12g08_003 into lr_retorno.ressrvlimqtd
   whenever error stop

   close c_cts12g08_003


   return lr_retorno.ressrvlimqtd


end function

#------------------------------------------------------------------------------
function cts12g08_valida_data_vigencia(lr_param)
#------------------------------------------------------------------------------
define lr_param record
   itaasiplncod    like datkitaasipln.itaasiplncod   ,
   itaclisgmcod    like datkitaclisgm.itaclisgmcod   ,
   itaaplvigincdat like datmitaapl.itaaplvigincdat
end record

define lr_retorno record
	 cont integer
end record

initialize lr_retorno.* to null
if m_prepare is null or
   m_prepare <> true then
   call cts12g08_prepare()
end if
   
   open c_cts12g08_004 using lr_param.itaasiplncod     ,
                             lr_param.itaclisgmcod     ,
                             lr_param.itaaplvigincdat  ,
                             lr_param.itaaplvigincdat
   whenever error continue
   fetch c_cts12g08_004 into lr_retorno.cont
   whenever error stop
   close c_cts12g08_004
   if lr_retorno.cont > 0 then
      return true
   else
   	  return false
   end if

end function