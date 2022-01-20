###############################################################################
# Nome do Modulo: cts12g00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de naturezas de socorro/sinistro Ramos Elementares          Mai/1998 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 31/05/2002  PSI          Wagner       Incluir assunto como filtro parametro.#
###############################################################################
#..............................................................................#
#                     * * *  ALTERACOES  * * *                                 #
#                                                                              #
# Data        Autor Fabrica PSI       Alteracao                                #
# ----------  ------------- --------  -----------------------------------------#
# 24/10/2003  Alexson,Meta  168.890  Incluir os campos ramcod,rmemldcod,clscod #
#                      OSF  027.847  alterado a selecao dos campos socntzdes e #
#                                    socntzcod da tabela datksocntz.           #
# ----------  ------------- -------- ------------------------------------------#
# 14/12/2004  Bruno,Meta    188.239  Novo parametro 'socntzgrpcod'.            #
#------------------------------------------------------------------------------#
# 13/10/2006  Ruiz          202720   Alteracao no tamanho campo "clscod"       #
#                                    Saude+Casa.                               #
#------------------------------------------------------------------------------#
# 18/09/2008  Nilo          221635   Agendamento de Servicos a Residencia      #
#                                    Portal do Segurado                        #
#------------------------------------------------------------------------------#

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare smallint

function cts12g00_prepare()

  define l_sql char(300)

  let l_sql = "select socntzgrpcod " ,
              "from datrempgrp " ,
              "where empcod = ?" ,
              "and c24astcod = ?"
  prepare p_cts12g00_001 from l_sql
  declare c_cts12g00_001 cursor for p_cts12g00_001

  let m_prepare = true

end function


#---------------------------------------------------------------
 function cts12g00(param)
#---------------------------------------------------------------

 define param      record
    ntztip         smallint,
    c24astcod      like datmligacao.c24astcod,
    ramcod         smallint,                    ## PSI 168890 - Inicio
   #clscod         char(3),
    clscod         char(5),                     ## psi 202720 - saude
    rmemdlcod      decimal(3,0),
    prporg         like rsdmdocto.prporg,
    prpnumdig      like rsdmdocto.prpnumdig     ## PSI 168890 - Final
   ,socntzgrpcod   like datksocntz.socntzgrpcod
 end record

 define d_cts12g00 record
    ntztiptxt      char (08)
 end record

 define a_cts12g00 array[500] of record # Aumentando para 500 a pedido da Judite
    ntzdes         char (40),
    ntzcod         smallint
 end record
 define ws record
    socntzgrpcod   like datksocntz.socntzgrpcod
 end record
 define al_aux     array[500] of record     ## PSI 168890
    clscod         like rsdmclaus.clscod    ## PSI 168890
 end record                                 ## PSI 168890

  define l_socntzgrpcod like datksocntz.socntzgrpcod

 define arr_aux    smallint
 define scr_aux    smallint

 define sql        char (1000)   ## PSI 168890

	define	w_pf1	integer

 ---> PSI - 221635
 define l_cod_erro   smallint
       ,l_desc_erro  char(40)


	let	arr_aux  =  null
	let	scr_aux  =  null
	let	sql  =  null
	let     l_socntzgrpcod = null

        ---> PSI - 221635
        let l_cod_erro   = null
        let l_desc_erro  = null

        initialize al_aux     to null    ## PSI 168890
        initialize a_cts12g00 to null    ## PSI 168890

	initialize  d_cts12g00.*  to  null
        initialize ws to null

  if m_prepare is null or
     m_prepare <> true then
     call cts12g00_prepare()
  end if

 initialize a_cts12g00  to null
 let arr_aux = 1

 ---> PSI - 221635
 call cts12g03(param.*,'O')
    returning l_cod_erro ,l_desc_erro

 if l_cod_erro <> 0 then
    error l_desc_erro
    return a_cts12g00[arr_aux].ntzcod
         , al_aux[arr_aux].clscod
 end if

 let sql = "select ntzcod, ntzdes ,clscod ,socntzgrpcod ",
            " from cts12g03_natureza ",
           " order by ntzdes "
 prepare p_cts12g00_002 from sql
 declare c_cts12g00_002 cursor for p_cts12g00_002

 open window w_cts12g00 at 10,29 with form "cts12g00"
      attribute(form line first, border)

 display by name d_cts12g00.ntztiptxt

 open    c_cts12g00_002
 foreach c_cts12g00_002 into a_cts12g00[arr_aux].ntzcod,
                             a_cts12g00[arr_aux].ntzdes,
                             al_aux[arr_aux].clscod,        ## PSI 168890
                             ws.socntzgrpcod

    if cty31g00_nova_regra_clausula(param.c24astcod) then
       if not cty31g00_valida_natureza(param.c24astcod,a_cts12g00[arr_aux].ntzcod) then
          continue foreach
       end if
    else
    	 if cty31g00_valida_clausula() then
    	    if cty34g00_restringe_natureza(param.c24astcod,a_cts12g00[arr_aux].ntzcod) then
             continue foreach
          end if
    	 end if
    	 if cty34g00_valida_clausula(param.clscod) then
    	 	  if not cty34g00_valida_natureza(param.c24astcod,a_cts12g00[arr_aux].ntzcod) then
    	 	     continue foreach
    	 	  end if
       end if
    end if
    let arr_aux = arr_aux + 1

    if arr_aux > 500  then
       error " Limite excedido. Foram encontradas mais de 500 naturezas!"
       exit foreach
    end if
 end foreach

 message "(F17)Aband. (F8)Seleciona (F3)Prox. (F4)Ant."

 call set_count(arr_aux-1)

 display array a_cts12g00 to s_cts12g00.*
    on key (interrupt,control-c)
       initialize a_cts12g00   to null
       exit display

   on key (F8)
      let arr_aux = arr_curr()
      exit display
 end display

 close window  w_cts12g00
 let int_flag = false

 return a_cts12g00[arr_aux].ntzcod, al_aux[arr_aux].clscod    ## PSI 168890

end function  ###  cts12g00
