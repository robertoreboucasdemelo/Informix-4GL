###############################################################################
# Nome do Modulo: ctc48m02                                           Raji     #
#                                                                             #
# Mostra o cadastro de agrupamentos                                  Dez/2000 #
###############################################################################

database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc48m02(p_ctc48m02)
#-----------------------------------------------------------

 define p_ctc48m02 record
     atdsrvorg      like datksrvtip.atdsrvorg
 end record

 define a_ctc48m02 array[500] of record
    c24pbmgrpcod   like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes   like datkpbmgrp.c24pbmgrpdes,
    srvtipabvdes   like datkpbmgrp.c24pbmgrpdes
 end record

 define ws_sql         char(200)
 define arr_aux        smallint
 define	w_pf1	         integer
 define l_carrega      smallint
 define l_acesso       smallint
 define l_c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod


 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------

	let	ws_sql         =  null
	let	arr_aux        =  null
	let l_carrega      =  false
	let l_c24pbmgrpcod =  null
	let l_acesso       =  null

	for	w_pf1  =  1  to  500
		initialize  a_ctc48m02[w_pf1].*  to  null
	end	for

   initialize a_ctc48m02,
              arr_aux,
              ws_sql      to null

 open window ctc48m02 at 3,24 with form "ctc48m02"
                     attribute(form line 1, border)

 let int_flag = false
 initialize a_ctc48m02  to null

 let arr_aux = 1
 call cts00m42_recupera_agrupamento(g_documento.c24astcod)
 returning l_c24pbmgrpcod,
           l_acesso

 if p_ctc48m02.atdsrvorg is null then
     let ws_sql = "select c24pbmgrpcod,c24pbmgrpdes,srvtipabvdes ",
                  "  from datkpbmgrp, datksrvtip ",
                  " where datkpbmgrp.atdsrvorg = datksrvtip.atdsrvorg ",
                  "   and datkpbmgrp.c24pbmgrpstt <> 'C' ",
                  "order by c24pbmgrpdes"
 else
     let ws_sql = "select c24pbmgrpcod,c24pbmgrpdes, '' ",
                  "  from datkpbmgrp ",
                  " where atdsrvorg = ", p_ctc48m02.atdsrvorg,
                  "   and datkpbmgrp.c24pbmgrpstt <> 'C' ",
                  "  order by c24pbmgrpdes"
 end if
 prepare sel_ctc48m02 from ws_sql
 declare c_ctc48m02 cursor for sel_ctc48m02

 foreach c_ctc48m02  into  a_ctc48m02[arr_aux].c24pbmgrpcod,
                           a_ctc48m02[arr_aux].c24pbmgrpdes,
                           a_ctc48m02[arr_aux].srvtipabvdes

    call ctc48m02_verifica_assunto(a_ctc48m02[arr_aux].c24pbmgrpcod)
         returning l_carrega

    if l_carrega = false then
        continue foreach
    end if

    if l_c24pbmgrpcod is not null then
    	 if l_acesso = 0 then
    	 	  if l_c24pbmgrpcod = a_ctc48m02[arr_aux].c24pbmgrpcod then
    	 	       continue foreach
    	 	  end if
    	 else
          if l_c24pbmgrpcod <> a_ctc48m02[arr_aux].c24pbmgrpcod then
               continue foreach
          end if
       end if
    end if
    if cty31g00_valida_clausula() then
       if not cty34g00_valida_grupo_problema(g_documento.c24astcod,a_ctc48m02[arr_aux].c24pbmgrpcod) then
          continue foreach
       end if
    end if
    if g_documento.c24astcod = 'S85' then
       call cta00m06_exibe_problema(a_ctc48m02[arr_aux].c24pbmgrpcod,
                                       g_documento.ramcod,
                                       g_documento.succod,
                                       g_documento.aplnumdig,
                                       g_documento.itmnumdig )
            returning l_carrega
       if l_carrega = false then
          continue foreach
       end if
    end if
    let arr_aux = arr_aux + 1
 end foreach

 #if p_ctc48m02.atdsrvorg is not null then
 #   let a_ctc48m02[arr_aux].c24pbmgrpcod = 999
 #   let a_ctc48m02[arr_aux].c24pbmgrpdes = "OUTROS"
 #   let a_ctc48m02[arr_aux].srvtipabvdes = ''
 #   let arr_aux = arr_aux + 1
 #end if

 message "(F17)Abandona  (F8)Seleciona  (F3)Proximo  (F4)Anterior"
 call set_count(arr_aux - 1)

 display array a_ctc48m02 to s_ctc48m02.*

    on key (interrupt,control-c)
       initialize a_ctc48m02   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

   end display

   let int_flag = false

   close window  ctc48m02

   return a_ctc48m02[arr_aux].c24pbmgrpcod,
          a_ctc48m02[arr_aux].c24pbmgrpdes

end function  ###  ctc48m02

#----------------------------------------------
function ctc48m02_descricao(l_c24pbmgrpcod)
#----------------------------------------------

 define l_c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod

 define lr_ret   record
    resultado    smallint   # 1 Obteve a descricao 2 Nao achou a descricao 3 Erro de banco
   ,mensagem     char(80)
   ,c24pbmgrpdes like datkpbmgrp.c24pbmgrpdes
 end record

 initialize lr_ret.* to null

 whenever error continue
 select c24pbmgrpdes into lr_ret.c24pbmgrpdes from datkpbmgrp
        where c24pbmgrpcod = l_c24pbmgrpcod
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_ret.resultado = 2
       let lr_ret.mensagem = " Grupo invalido "
    else
       let lr_ret.resultado = 3
       let lr_ret.mensagem = " Erro ",sqlca.sqlcode," em datkpbmgrp "
    end if
 else
    let lr_ret.resultado = 1
    let lr_ret.mensagem = ""
 end if

 return lr_ret.*

end function

function ctc48m02_verifica_assunto(lr_param)

 define lr_param record
     c24pbmgrpcod   like datkpbmgrp.c24pbmgrpcod
 end record

 define l_retorno smallint

 let l_retorno = true

 if g_documento.c24astcod = "KMP " then
    if lr_param.c24pbmgrpcod <> 239 then
    let l_retorno = false
    end if
 end if
 if g_documento.c24astcod = 'SAP' or
    g_documento.c24astcod = 'KAP' or
    g_documento.c24astcod = 'IAP' or
    g_documento.c24astcod = 'PSP' then
   if lr_param.c24pbmgrpcod <> 20  then
      let l_retorno = false
   end if
 else
     if lr_param.c24pbmgrpcod = 20  then
        let l_retorno = false
   end if
 end if


 return l_retorno

end function

