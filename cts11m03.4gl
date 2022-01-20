###############################################################################
# Nome do Modulo: CTS11M03                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up para exibir todos os motivos para assistencia a passageiro  Jun/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 15/04/1999  PSI 7547-7   Wagner       Permitir que a funcao seje solicitada #
#                                       por parametro e tambem passar a ler   #
#                                       a tabela DATKASIMTV .                 #
###############################################################################



database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts11m03(param)
#-----------------------------------------------------------

 define param      record
    asitipcod      like datrmtvasitip.asitipcod
 end record

 define a_cts11m03 array[100] of record
    asimtvcod      like datkasimtv.asimtvcod,
    asimtvdes      like datkasimtv.asimtvdes
 end record

 define arr_aux smallint

 define ws         record
    asimtvcod      like datkasimtv.asimtvcod,
    sql            char (100)
 end record

 define l_asimtvcod like datkasimtv.asimtvcod

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_cts11m03[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
        initialize l_asimtvcod to  null
 let ws.sql = "select asitipcod     ",
              "  from datrmtvasitip ",
              " where asitipcod = ? ",
              "   and asimtvcod = ? "
 prepare p_cts11m03_001  from ws.sql
 declare c_cts11m03_001 cursor for p_cts11m03_001

 let int_flag = false

 initialize a_cts11m03   to null
 initialize ws.asimtvcod to null

 let arr_aux  = 1

 declare c_cts11m03_002 cursor for
    select asimtvdes, asimtvcod
      from datkasimtv
     where asimtvsit = "A"
     order by asimtvcod

 foreach c_cts11m03_002 into a_cts11m03[arr_aux].asimtvdes,
                           a_cts11m03[arr_aux].asimtvcod

    if param.asitipcod is not null  then
       open c_cts11m03_001 using param.asitipcod, a_cts11m03[arr_aux].asimtvcod
       fetch c_cts11m03_001
       if sqlca.sqlcode = notfound  then
          continue foreach
       end if
       let l_asimtvcod = a_cts11m03[arr_aux].asimtvcod
       if l_asimtvcod >= 10 then 
	  if g_documento.ciaempcod = 35 then 
	     continue foreach
          end if 
       end if    
           
       close c_cts11m03_001
    end if

    let arr_aux = arr_aux + 1

    if arr_aux  >  100   then
       error " Limite excedido. Existem mais de 100 motivos cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.asimtvcod = a_cts11m03[arr_aux - 1].asimtvcod
    else
       open window cts11m03 at 11,51 with form "cts11m03"
                            attribute(form line 1, border)

       message "(F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cts11m03 to s_cts11m03.*

          on key (interrupt,control-c)
             initialize ws.asimtvcod to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.asimtvcod = a_cts11m03[arr_aux].asimtvcod
             exit display

       end display

       close window cts11m03
    end if
 else
    initialize ws.asimtvcod  to null
    error " Nao existe nenhum motivo cadastrado. AVISE A INFORMATICA!"
 end if

 let int_flag = false

 return ws.asimtvcod

end function  ###  cts11m03
