###############################################################################
# Nome do Modulo: CTN25C00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de tipos de assistencia                                     Jul/1998 #
###############################################################################
#                                                                             #
# 07/06/2000     PSI  108669     Ruiz     Alteracao do campo atdtip para o    #
#                                         campo atdsrvorg.                    #
###############################################################################
#...........................................................................#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 27/01/2005 Daniel, Meta      PSI190489  Inclusao ctn25c00_descricao()     #
#                                         inclusao ctn25c00_prepare()       #
#---------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint

#------------------------------------------
function ctn25c00_prepare()
#------------------------------------------

 define l_sql char(200)
 let l_sql = " select asitipdes "
            ," from datkasitip "
            ," where asitipstt = 'A' "
            ," and asitipcod = ? "
 prepare pctn25c00001 from l_sql
 declare cctn25c00001 cursor for pctn25c00001
 let l_sql  = ' select 1 '
             ,'  from datrasitipsrv '
             ,' where asitipcod = ? '
 prepare pctn25c00002 from l_sql
 declare cctn25c00002 cursor for pctn25c00002

 let m_prep_sql = true

end function


#-----------------------------------------------------------
 function ctn25c00(param)
#-----------------------------------------------------------

 define param      record
    atdsrvorg      like datksrvtip.atdsrvorg
 end record

 define a_ctn25c00 array[50] of record
    asitipdes      like datkasitip.asitipdes,
    asitipcod      like datkasitip.asitipcod
 end record

 define arr_aux smallint

 define ws         record
    sql            char (100),
    atdsrvorg      like datksrvtip.atdsrvorg,
    asitipcod      like datkasitip.asitipcod
 end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn25c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let ws.sql = "select atdsrvorg from datrasitipsrv",
              " where atdsrvorg = ?  and       ",
              "       asitipcod = ?            "
 prepare p_ctn25c00_001 from ws.sql
 declare c_ctn25c00_001 cursor for p_ctn25c00_001

 let int_flag = false
 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctn25c00_prepare()
 end if

 let arr_aux  = 1
 initialize a_ctn25c00   to null

 declare c_ctn25c00 cursor for
    select asitipdes, asitipcod
      from datkasitip
     where asitipstt = "A"
     order by asitipdes

 foreach c_ctn25c00 into a_ctn25c00[arr_aux].asitipdes,
                         a_ctn25c00[arr_aux].asitipcod

    ------------[ para Azul nao tem estas assistencias ]--20/08/08----
    if g_documento.ciaempcod = 35 then  # Azul Seguros
       if a_ctn25c00[arr_aux].asitipcod = 11 or  # Remocao Hospitalar
          a_ctn25c00[arr_aux].asitipcod = 12 or  # Translado de Corpos
          a_ctn25c00[arr_aux].asitipcod = 63 then# Lei Seca
          continue foreach
       end if
    end if
    ------------------------------------------------------------------
    if param.atdsrvorg is not null  then
       if param.atdsrvorg <> 0 then
          open  c_ctn25c00_001 using param.atdsrvorg,
                                      a_ctn25c00[arr_aux].asitipcod
          fetch c_ctn25c00_001
          if sqlca.sqlcode = notfound  then
             continue foreach
          end if
          close c_ctn25c00_001
       else
          open cctn25c00002 using a_ctn25c00[arr_aux].asitipcod
          fetch cctn25c00002
          if sqlca.sqlcode = 100 then
             continue foreach
          end if
       end if
    end if

    let arr_aux = arr_aux + 1

    if arr_aux > 50  then
       error " Limite excedido. Foram encontrados mais de 50 tipos de assistencia!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.asitipcod = a_ctn25c00[arr_aux - 1].asitipcod
    else
       open window ctn25c00 at 12,52 with form "ctn25c00"
                            attribute(form line 1, border)

       message " (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_ctn25c00 to s_ctn25c00.*

          on key (interrupt,control-c)
             initialize a_ctn25c00     to null
             initialize ws.asitipcod to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.asitipcod = a_ctn25c00[arr_aux].asitipcod
             exit display

       end display

       let int_flag = false
       close window ctn25c00
    end if
 else
    initialize ws.asitipcod to null
    error " Nao foi encontrado nenhum tipo de assistencia!"
 end if

 return ws.asitipcod

end function  ###  ctn25c00

#-------------------------------------------------
function ctn25c00_descricao(l_asitipcod)
#-------------------------------------------------

 define l_asitipcod  like datkasitip.asitipcod
 define lr_ret       record
        resultado    smallint,  # 1 Obteve a descricao 2 Nao achou a descricao 3 Erro de banco
        mensagem     char(80),
        asitipdes    like datkasitip.asitipdes
 end record
 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctn25c00_prepare()
 end if
 initialize lr_ret.* to null
 open cctn25c00001 using l_asitipcod
 whenever error continue
 fetch cctn25c00001 into lr_ret.asitipdes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_ret.resultado = 2
       let lr_ret.mensagem = " Tipo de assistencia invalida "
    else
       let lr_ret.resultado = 3
       let lr_ret.mensagem = " Erro " ,sqlca.sqlcode, " em datkasitip "
    end if
 else
    let lr_ret.resultado = 1
    let lr_ret.mensagem = ""
 end if

 return lr_ret.*
end function
