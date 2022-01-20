#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                    #
# Modulo.........: cts66m03                                                    #
# Objetivo.......: Pop-up de tipos de assistencia                              #
# Analista Resp. : Amilton Pinto                                               #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: Amilton Pinto                                               #
# Liberacao      : 31/07/2012                                                  #
#------------------------------------------------------------------------------#



database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts66m03(param)
#-----------------------------------------------------------

 define param      record
    atdsrvorg      like datksrvtip.atdsrvorg
 end record

 define a_cts66m03 array[100] of record    
    asitipcod      like datkasitip.asitipcod,
    asitipdes      like datkasitip.asitipdes
 end record  

 define arr_aux smallint

 define ws         record
    asitipcod      like datkasimtv.asimtvcod,
    sql            char (100)
 end record

 define l_asitipcod   like datkasitip.asitipcod
 define l_existe smallint

	define	w_pf1	integer
 
	let	arr_aux  =  null
	
	

	for	w_pf1  =  1  to  100
		initialize  a_cts66m03[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
        initialize l_asitipcod to  null
 let ws.sql = "select atdsrvorg from datrasitipsrv",
              " where atdsrvorg = ?  and       ",
              "       asitipcod = ?            "
 prepare p_cts66m03_001  from ws.sql
 declare c_cts66m03_001 cursor for p_cts66m03_001

 let int_flag = false

 initialize a_cts66m03   to null
 initialize ws.asitipcod to null

 let arr_aux  = 1

 declare c_cts66m03_002 cursor for
       select asitipdes, asitipcod
      from datkasitip
     where asitipstt = "A"
     order by asitipdes

 foreach c_cts66m03_002 into a_cts66m03[arr_aux].asitipdes,
                             a_cts66m03[arr_aux].asitipcod

    
    call cta00m06_verifica_tipo_assistencia(a_cts66m03[arr_aux].asitipcod)
         returning l_existe 
         
    if l_existe = false then        
       continue foreach 
    end if                 
    
    if param.atdsrvorg is not null  then
       open c_cts66m03_001 using param.atdsrvorg, a_cts66m03[arr_aux].asitipcod
       fetch c_cts66m03_001
       if sqlca.sqlcode = notfound  then
          continue foreach
       end if
       let l_asitipcod = a_cts66m03[arr_aux].asitipcod                  
       close c_cts66m03_001
    end if

    let arr_aux = arr_aux + 1

    if arr_aux  >  100   then
       error " Limite excedido. Existem mais de 100 motivos cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.asitipcod = a_cts66m03[arr_aux - 1].asitipcod
    else
       open window cts66m03 at 11,51 with form "cts66m03"
                            attribute(form line 1, border)

       message "(F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cts66m03 to s_cts66m03.*

          on key (interrupt,control-c)
             initialize ws.asitipcod to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.asitipcod = a_cts66m03[arr_aux].asitipcod
             exit display

       end display

       close window cts66m03
    end if
 else
    initialize ws.asitipcod  to null
    error " Nao existe nenhum Tipo de Assistencia cadastrado. AVISE A INFORMATICA!"
 end if

 let int_flag = false

 return ws.asitipcod

end function  ###  cts66m03
