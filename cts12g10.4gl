#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cts12g10                                                  #
# Objetivo.......: Lista de Motivos a Carro Reserva Plano Itau               #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: R.Fornax                                                  #
# Liberacao      : 06/08/2014                                                #
#............................................................................#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_prepare  smallint

define mr_retorno array[500] of record
    itarsrcaomtvcod   like  datkitarsrcaomtv.itarsrcaomtvcod        ,
    itarsrcaomtvdes   like  datkitarsrcaomtv.itarsrcaomtvdes        ,
    dialimqtd         like  datkitarsrcaomtv.dialimqtd
end record

define mr_servicos   array[500] of record
    itarsrcaomtvcod     like datkitarsrcaomtv.itarsrcaomtvcod
   ,itarsrcaomtvdes     like datkitarsrcaomtv.itarsrcaomtvdes
   ,dialimqtd           like datkitarsrcaomtv.dialimqtd
   ,utiliz              integer
   ,saldo               integer
end record


#------------------------------------------------------------------------------
function cts12g10_prepare()
#------------------------------------------------------------------------------

define l_sql char(10000)

 let l_sql = ' select a.itarsrcaomtvcod                     '
          ,  '      , a.itarsrcaomtvdes                     '
          ,  '      , a.dialimqtd                           '
          ,  '   from datkitarsrcaomtv a                    '
          ,  '  order by a.itarsrcaomtvcod                  '
 prepare p_cts12g10_001 from l_sql
 declare c_cts12g10_001 cursor for p_cts12g10_001


 let l_sql = ' select a.itarsrcaomtvcod                         '
          ,  '      , a.itarsrcaomtvdes                         '
          ,  '      , b.rsrcaodiaqtd                            '
          ,  '   from datkitarsrcaomtv a   ,                    '
          ,  '        datrclisgmrsrcaomtv b                     '
          ,  '   where a.itarsrcaomtvcod = b.itarsrcaomtvcod    '
          ,  '   and   b.itaclisgmcod = ?                       '
          ,  '   order by a.itarsrcaomtvcod                     '
 prepare p_cts12g10_002 from l_sql
 declare c_cts12g10_002 cursor for p_cts12g10_002

 let l_sql = ' select count(*)                   '
          ,  '   from datkitarsrcaomtv           '
          ,  '  where srvlimdat <= ?             '
 prepare p_cts12g10_003 from l_sql
 declare c_cts12g10_003 cursor for p_cts12g10_003

 let l_sql = ' select count(*)   '
          ,  ' from datkdominio  '
          ,  ' where cponom = ?  '
          ,  ' and cpodes = ?    '
 prepare p_cts12g10_004 from l_sql
 declare c_cts12g10_004 cursor for p_cts12g10_004
 let l_sql = '  select count(*)                  '
            ,'  from datrclisgmrsrcaomtv         '
            ,'  where  itaclisgmcod = ?          '
            ,'  and vigincdat <=  ?              '
            ,'  and vigfnldat >=  ?              '
 prepare p_cts12g10_005 from l_sql
 declare c_cts12g10_005 cursor for p_cts12g10_005
 let m_prepare	= true


end function

#------------------------------------------------------------------------------
function cts12g10_rec_motivo(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaclisgmcod    like datkitaclisgm.itaclisgmcod ,
   itaaplvigincdat like datmitaapl.itaaplvigincdat
end record

define l_index integer

for  l_index  =  1  to  500
   initialize  mr_retorno[l_index].* to  null
end  for

if m_prepare is null or
   m_prepare <> true then
   call cts12g10_prepare()
end if

   let l_index = 1

   if cts12g10_verifica_data(lr_param.itaaplvigincdat) then

   	   open c_cts12g10_002 using lr_param.itaclisgmcod
   	   foreach c_cts12g10_002 into mr_retorno[l_index].itarsrcaomtvcod  ,
   	                               mr_retorno[l_index].itarsrcaomtvdes  ,
   	                               mr_retorno[l_index].dialimqtd

   	   let l_index = l_index + 1

   	   end foreach



   else
      open c_cts12g10_001
      foreach c_cts12g10_001 into mr_retorno[l_index].itarsrcaomtvcod  ,
                                  mr_retorno[l_index].itarsrcaomtvdes  ,
                                  mr_retorno[l_index].dialimqtd

      let l_index = l_index + 1

      end foreach

   end if


   return l_index

end function

#--------------------------------------------------------------------------
function cts12g10(lr_param)
#--------------------------------------------------------------------------

   define lr_param record
          itaclisgmcod    like datkitaclisgm.itaclisgmcod ,
          itaaplvigincdat like datmitaapl.itaaplvigincdat
   end record

   define lr_retorno   record
          sqlcode          integer
         ,msgerro          char(500)
         ,itarsrcaomtvcod  like datkitarsrcaomtv.itarsrcaomtvcod
   end record

   define t_cts12g10    array[500] of record
          itarsrcaomtvcod     like datkitarsrcaomtv.itarsrcaomtvcod
         ,itarsrcaomtvdes     char(50)
         ,dialimqtd           smallint
         ,utiliz              smallint
         ,saldo               smallint
   end record



   define l_index        integer
         ,l_qtde         smallint
         ,arr_aux        integer


   let l_index       = 0
   let l_qtde        = 0
   let arr_aux       = 0




   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for


   for l_index  =  1  to  500
       initialize  t_cts12g10[l_index].* to  null
   end for


   #-------------------------------------
   #        Busca Motivos
   #-------------------------------------

   call cts12g10_carrega_array(lr_param.itaclisgmcod   ,
                               lr_param.itaaplvigincdat)
   returning l_qtde



   for l_index = 1 to l_qtde

       let t_cts12g10[l_index].itarsrcaomtvcod = mr_servicos[l_index].itarsrcaomtvcod
       let t_cts12g10[l_index].itarsrcaomtvdes = mr_servicos[l_index].itarsrcaomtvdes

       let t_cts12g10[l_index].dialimqtd = mr_servicos[l_index].dialimqtd
       let t_cts12g10[l_index].utiliz    = mr_servicos[l_index].utiliz
       let t_cts12g10[l_index].saldo     = mr_servicos[l_index].dialimqtd - mr_servicos[l_index].utiliz
   end for



   open window w_cts12g10 at 3,2 with form "cts12g10"
   attribute(form line 1)

   let int_flag = false

   message " (F17)Abandona "

   call set_count(l_index - 1)

   display array t_cts12g10 to s_cts12g10.*

      on key (interrupt,control-c,f17)
            exit display

   end display

   close window  w_cts12g10

   let int_flag = false


end function

#--------------------------------------------
function cts12g10_carrega_array(lr_param)
#--------------------------------------------

   define lr_param record
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

   call cts12g10_rec_motivo(lr_param.itaclisgmcod   ,
                            lr_param.itaaplvigincdat)
   returning l_qtde


   let l_qtde = l_qtde - 1

   for l_index = 1 to l_qtde

       let mr_servicos[l_index].itarsrcaomtvcod = mr_retorno[l_index].itarsrcaomtvcod
       let mr_servicos[l_index].itarsrcaomtvdes = mr_retorno[l_index].itarsrcaomtvdes

       call cts64m03_qtd_servico(g_documento.itaciacod               ,
                                 g_documento.ramcod                  ,
                                 g_documento.aplnumdig               ,
                                 g_documento.itmnumdig               ,
                                 mr_servicos[l_index].itarsrcaomtvcod)
       returning mr_servicos[l_index].utiliz

       let mr_servicos[l_index].dialimqtd  = mr_retorno[l_index].dialimqtd
       let mr_servicos[l_index].saldo      = mr_servicos[l_index].dialimqtd - mr_servicos[l_index].utiliz

   end for

   return l_qtde

end function



#---------------------------------------------------------
 function cts12g10_verifica_data(lr_param)
#---------------------------------------------------------

define lr_param  record
   itaaplvigincdat like datmitaapl.itaaplvigincdat
end record


define lr_retorno  record
   cont smallint
end record

initialize lr_retorno.* to null


        if m_prepare is null or
           m_prepare <> true then
           call cts12g10_prepare()
        end if

        let lr_retorno.cont = 0

        open c_cts12g10_003 using lr_param.itaaplvigincdat

        whenever error continue
        fetch c_cts12g10_003 into  lr_retorno.cont
        whenever error stop

        if lr_retorno.cont > 0 then
        	 return true
        else
        	 return false
        end if

end function

#---------------------------------------------------------
 function cts12g10_verifica_correntista(lr_param)
#---------------------------------------------------------

define lr_param  record
   rsrcaogrtcod like datkitarsrcaogar.rsrcaogrtcod
end record

define lr_retorno  record
	 chave char(20),
   cont  smallint
end record
initialize lr_retorno.* to null
        if m_prepare is null or
           m_prepare <> true then
           call cts12g10_prepare()
        end if
        let lr_retorno.cont = 0
        let lr_retorno.chave = "itau_corr"

        open c_cts12g10_004 using lr_retorno.chave      ,
                                  lr_param.rsrcaogrtcod
        whenever error continue
        fetch c_cts12g10_004 into  lr_retorno.cont
        whenever error stop

        if lr_retorno.cont > 0 then
        	 return true
        else
        	 return false
        end if
end function

#---------------------------------------------------------
 function cts12g10_verifica_segmento(lr_param)
#---------------------------------------------------------

define lr_param  record
   itaclisgmcod char(50)
end record


define lr_retorno  record
	 chave char(20),
   cont  smallint
end record
initialize lr_retorno.* to null
        if m_prepare is null or
           m_prepare <> true then
           call cts12g10_prepare()
        end if
        let lr_retorno.cont = 0
        let lr_retorno.chave = "seg_corr"
        open c_cts12g10_004 using lr_retorno.chave      ,
                                  lr_param.itaclisgmcod
        whenever error continue
        fetch c_cts12g10_004 into  lr_retorno.cont
        whenever error stop
        if lr_retorno.cont > 0 then
        	 return true
        else
        	 return false
        end if
end function


#---------------------------------------------------------
 function cts12g10_verifica_data_motivo(lr_param)
#---------------------------------------------------------

define lr_param  record
   itaaplvigincdat like datmitaapl.itaaplvigincdat    ,
   itaclisgmcod    like datkitaclisgm.itaclisgmcod
end record


define lr_retorno  record
   cont smallint
end record

initialize lr_retorno.* to null


        if m_prepare is null or
           m_prepare <> true then
           call cts12g10_prepare()
        end if
        let lr_retorno.cont = 0
        open c_cts12g10_005 using lr_param.itaclisgmcod    ,
                                  lr_param.itaaplvigincdat ,
                                  lr_param.itaaplvigincdat
        whenever error continue
        fetch c_cts12g10_005 into  lr_retorno.cont
        whenever error stop
        if lr_retorno.cont > 0 then
        	 return true
        else
        	 return false
        end if
end function
