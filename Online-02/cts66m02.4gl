#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                    #
# Modulo.........: cts66m02                                                    #
# Objetivo.......: Pop-up para exibir os motivos para assistencia a passageiro #
# Analista Resp. : Amilton Pinto                                               #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: Hamilton - Fornax                                           #
# Liberacao      : 31/07/2012                                                  #
#------------------------------------------------------------------------------#



database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"







#-----------------------------------------------------------
 function cts66m02(param)
#-----------------------------------------------------------

 define param      record
    asitipcod      like datrmtvasitip.asitipcod
 end record

 define a_cts66m02 array[100] of record
    asimtvcod      like datkasimtv.asimtvcod,
    asimtvdes      like datkasimtv.asimtvdes
 end record

 define arr_aux smallint

 define ws         record
    asimtvcod      like datkasimtv.asimtvcod,
    sql            char (100)
 end record

 define l_asimtvcod like datkasimtv.asimtvcod
 define l_existe smallint

	define	w_pf1	integer

	let	arr_aux  =  null
	
	

	for	w_pf1  =  1  to  100
		initialize  a_cts66m02[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
        initialize l_asimtvcod to  null
 let ws.sql = "select asitipcod     ",
              "  from datrmtvasitip ",
              " where asitipcod = ? ",
              "   and asimtvcod = ? "
 prepare p_cts66m02_001  from ws.sql
 declare c_cts66m02_001 cursor for p_cts66m02_001

 let int_flag = false

 initialize a_cts66m02   to null
 initialize ws.asimtvcod to null

 let arr_aux  = 1

 declare c_cts66m02_002 cursor for
    select asimtvdes, asimtvcod
      from datkasimtv
     where asimtvsit = "A"     
     order by asimtvcod

 foreach c_cts66m02_002 into a_cts66m02[arr_aux].asimtvdes,
                             a_cts66m02[arr_aux].asimtvcod

    
    call cta00m06_verifica_mtvassistencia(a_cts66m02[arr_aux].asimtvcod)
         returning l_existe 
         
    if l_existe = false then 
       continue foreach 
    end if                 
    
    if param.asitipcod is not null  then
       open c_cts66m02_001 using param.asitipcod, a_cts66m02[arr_aux].asimtvcod
       fetch c_cts66m02_001
       if sqlca.sqlcode = notfound  then
          continue foreach
       end if
       let l_asimtvcod = a_cts66m02[arr_aux].asimtvcod
       if l_asimtvcod >= 10 then 
	  if g_documento.ciaempcod = 35 then 
	     continue foreach
          end if 
       end if    
           
       close c_cts66m02_001
    end if

    let arr_aux = arr_aux + 1

    if arr_aux  >  100   then
       error " Limite excedido. Existem mais de 100 motivos cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.asimtvcod = a_cts66m02[arr_aux - 1].asimtvcod
    else
       open window cts66m02 at 11,51 with form "cts66m02"
                            attribute(form line 1, border)

       message "(F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cts66m02 to s_cts66m02.*

          on key (interrupt,control-c)
             initialize ws.asimtvcod to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.asimtvcod = a_cts66m02[arr_aux].asimtvcod
             exit display

       end display

       close window cts66m02
    end if
 else
    initialize ws.asimtvcod  to null
    error " Nao existe nenhum motivo cadastrado. AVISE A INFORMATICA!"
 end if

 let int_flag = false

 return ws.asimtvcod

end function  ###  cts66m02
