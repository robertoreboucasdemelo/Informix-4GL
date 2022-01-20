###############################################################################
# Nome do Modulo: ctc77m00                                           Cristiane#
#                                                                    Silva    #
# Pop-up de numeracao final servicos ao prestadores		     Nov/2005 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint

define am_ctc77m00  array[50] of record
	 navega		char(01),
         atdfnlnum	smallint
 end record

define m_contador smallint

define m_sair smallint

define atdfnlnum_ant like dpakdtbpst.atdfnlnum

#--------------#
function ctc77m00(param)
#--------------#
define param       record
    pstcoddig       like dpaksocor.pstcoddig,
    nomrazsoc	    like dpaksocor.nomrazsoc
end record

define ws record
	soccntdes like datksocntz.socntzdes,
	codigo    like datksocntz.socntzgrpcod,
	erro	  smallint
end record

define l_sucesso     smallint

let l_sucesso = true

options
    prompt line last,
    insert key f1,
    delete key control-y

open window w_ctc77m00 at 05,02 with form "ctc77m00"

display by name param.pstcoddig
display by name param.nomrazsoc

call ctc77m00_prepare()

while true
 	call ctc77m00_carrega_array(param.pstcoddig, param.nomrazsoc)
	call ctc77m00_entra_dados(param.pstcoddig, param.nomrazsoc)
	if m_sair = true then
		exit while
	end if
end while

options
delete key f2

close window w_ctc77m00

let int_flag = false

end function

#----------------------#
function ctc77m00_prepare()
#----------------------#

  define l_sql char(600)

#Seleção principal
let l_sql = 'select atdfnlnum from dpakdtbpst where pstcoddig = ?',
	    ' order by 1'
prepare pctc77m00001 from l_sql
declare cctc77m00001 cursor for pctc77m00001


#Inserção do registro
  let l_sql = " insert into dpakdtbpst (pstcoddig, atdfnlnum, atldat, atlmat, atlemp) values (?,?,today,?,? ) "
  prepare pctc77m00002 from l_sql

#Deleção de registro
  let l_sql = ' delete from  dpakdtbpst where pstcoddig = ? and atdfnlnum = ?'
  prepare pctc77m00003 from l_sql

#Verificação se registro já existe
let l_sql = ' select atdfnlnum from dpakdtbpst where pstcoddig = ? and atdfnlnum = ?'
prepare pctc77m00004 from l_sql
declare cctc77m00004 cursor for pctc77m00004

end function

#----------------------------#
function ctc77m00_carrega_array(param)
#----------------------------#
define param       record
    pstcoddig       like dpaksocor.pstcoddig,
    nomrazsoc	    like dpaksocor.nomrazsoc
end record

initialize am_ctc77m00 to null

let m_contador = 1

open cctc77m00001 using param.pstcoddig
	foreach cctc77m00001 into  am_ctc77m00[m_contador].atdfnlnum
		let m_contador = m_contador + 1
		if m_contador = 51 then
        		error "O limite de 50 registros foi ultrapassado" sleep 2
        		exit foreach
     		end if
	end foreach

let m_contador = m_contador - 1

end function

#--------------------------#
function ctc77m00_entra_dados(param)
#--------------------------#
define param       record
    pstcoddig       like dpaksocor.pstcoddig,
    nomrazsoc	    like dpaksocor.nomrazsoc
end record

define ws record
	atdfnlnum smallint,
	sta       smallint,
	mensagem  char(100),
	codigo    like datksocntzgrp.socntzgrpcod,
	erro	  smallint,
	funnom    char(100)
end record

define l_operacao      char(01),
        l_arr           smallint,
        l_scr           smallint,
        l_codigo        smallint,
        l_resposta      char(01),
        l_situacao_ant  char(01),
        l_descricao_ant char(01),
        l_cod_ant	 smallint,
        l_espcod	 smallint,
        l_nulo		 char(004),
        l_espdes	 char(50),
        l_socntzdes	 char(50),
        l_data		 date,
        l_resultado	 smallint,
        l_mensagem	 char(50),
        l_descricao	 char(30)

define l_sucesso     smallint

let l_arr           = null
let l_situacao_ant  = null
let l_descricao_ant = null
let l_scr           = null
let l_resposta      = null
let l_nulo          = null
let l_data	      = today
let l_sucesso = true
let int_flag = false
let l_operacao = " "
let m_sair = false
let atdfnlnum_ant = null
let ws.atdfnlnum = null

call set_count(m_contador)

while true

     input array am_ctc77m00 without defaults from s_ctc77m00.*

         before row
           let l_arr = arr_curr()
           let l_scr = scr_line()

        before field navega
           if l_operacao = "I" then
              next field atdfnlnum
           end if

        after field navega
            if fgl_lastkey() = 2014 then
              let l_operacao = "I"
            else
              if fgl_lastkey() = fgl_keyval('down') then
                 if am_ctc77m00[l_arr + 1].atdfnlnum is null then
                    next field navega
                 else
                    continue input
                 end if
              end if
              if fgl_lastkey() = 2005 or    ## f3
                 fgl_lastkey() = 2006 then  ## f4
                 continue input
              end if
              if fgl_lastkey() = fgl_keyval('up') then
                 continue input
              else
                 next field navega
              end if
           end if


        before field atdfnlnum
        display by name am_ctc77m00[l_arr].atdfnlnum attribute(reverse)


        after field atdfnlnum
        display by name am_ctc77m00[l_arr].atdfnlnum

	if l_operacao = "I" then
		if am_ctc77m00[l_arr].atdfnlnum is not null then
			if am_ctc77m00[l_arr].atdfnlnum >= 0 and am_ctc77m00[l_arr].atdfnlnum <= 9 then
	 			open cctc77m00004 using param.pstcoddig, am_ctc77m00[l_arr].atdfnlnum
	 			fetch cctc77m00004 into ws.atdfnlnum
	 			if ws.atdfnlnum is not null then
	 				error "Numero já existente"
	 				next field atdfnlnum
	 			end if
			else
				error "Numero invalido. Informe de 0 a 9"
				next field atdfnlnum
			end if
		end if
	end if

        while true

              if l_operacao = "I" then
                 prompt 'Confirma inclusao do registro? (S/N)' for l_resposta
              end if

              if l_operacao = "A" then
                 prompt 'Confirma alteracao do registro? (S/N)' for l_resposta
              end if

	      let l_resposta = upshift(l_resposta)

              if l_resposta = 'S' or l_resposta = 'N' or int_flag then
                 exit while
              end if
       end while

       if int_flag then
       		let int_flag = true
       		let l_resposta = "N"
       end if

       if l_resposta = "S" then
		if l_operacao = "I" then
              		if ctc77m00_executa_operacao("I",
                                           param.pstcoddig,
                                           am_ctc77m00[l_arr].atdfnlnum,
                                           g_issk.funmat, g_issk.empcod, atdfnlnum_ant) then
                    		error "Registro incluido com sucesso" sleep 2
                 	else
                    		let int_flag = true
                    		exit input
                 	end if
		end if
	        if l_operacao = "A" then
                	if ctc77m00_executa_operacao("A",
                                           param.pstcoddig,
                                           am_ctc77m00[l_arr].atdfnlnum,
                                           g_issk.funmat, g_issk.empcod, atdfnlnum_ant) then
                    		error "Registro alterado com sucesso" sleep 2
                 	else
                    		let int_flag = true
                    		exit input
                 	end if
                end if
	else
                if l_operacao = "I" then
                	let am_ctc77m00[l_arr].atdfnlnum = atdfnlnum_ant
                	call ctc77m00_deleta_linha(l_arr, l_scr)
              	else
        		let am_ctc77m00[l_arr].atdfnlnum = atdfnlnum_ant
        		call ctc77m00_deleta_linha(l_arr, l_scr)
                end if
	end if
           let l_operacao = " "
           next field navega

	on key(f2)

          while true
             prompt "Confirma a exclusao? (S/N) " for l_resposta

             let l_resposta = upshift(l_resposta)

            if l_resposta = 'S' or l_resposta = 'N' or int_flag then
               exit while
             else
                error "Digite somente S ou N" sleep 2
             end if
          end while

          if int_flag then
             let l_resposta = "N"
             let int_flag = false
          end if

         if upshift(l_resposta) = "S" then
             if ctc77m00_executa_operacao("E",
                                           param.pstcoddig,
                                           am_ctc77m00[l_arr].atdfnlnum,
                                           g_issk.funmat, g_issk.empcod, atdfnlnum_ant) then
                error "Registro excluido com sucesso" sleep 2
                call ctc77m00_deleta_linha(l_arr,l_scr)
		exit input
             end if
             let m_contador = arr_count()
             exit input
          else
             error "Delecao cancelada" sleep 2
          end if



       on key(f6)
          if l_operacao = "I" or
             l_operacao = "A" or
             l_operacao = "E" then
             error "F6 nao pode ser teclada neste momento "
          else
             let l_operacao = "A"
             let atdfnlnum_ant = am_ctc77m00[l_arr].atdfnlnum
             let am_ctc77m00[l_arr].atdfnlnum = null
             display am_ctc77m00[l_arr].atdfnlnum to s_ctc77m00[l_scr].atdfnlnum
             next field atdfnlnum
          end if

       on key (control-c, f17, interrupt)
          initialize am_ctc77m00[l_arr].* to null
          let int_flag = true
          let m_sair = true
          let m_contador = 0
          exit input

     end input
     if int_flag then
        exit while
     end if

  end while

end function

#---------------------------------------#
function ctc77m00_deleta_linha(l_arr, l_scr)
#---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint
  for l_cont = l_arr to 49
     if am_ctc77m00[l_arr].atdfnlnum is not null then
        let am_ctc77m00[l_cont].* = am_ctc77m00[l_cont + 1].*
     else
        initialize am_ctc77m00[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 8
     display am_ctc77m00[l_arr].atdfnlnum    to s_ctc77m00[l_cont].atdfnlnum
     let l_arr = l_arr + 1
  end for

end function

#-------------------------------------------#
function ctc77m00_executa_operacao(lr_parametro)
#-------------------------------------------#

  define lr_parametro  record
         tipo_operacao 	char(01),
         pstcoddig		smallint,
	     atdfnlnum 		smallint,
         funmat      	smallint,
         empcod	     	smallint,
         atdfnlnum_ant	smallint
  end record

  define l_sucesso      smallint
  define l_atdfnlnum    smallint

  define l_prshstdes    char(500)

  let l_sucesso = true


  case lr_parametro.tipo_operacao

     when "A" # --ALTERACAO

        whenever error continue

        execute pctc77m00003 using  lr_parametro.pstcoddig,
        			lr_parametro.atdfnlnum_ant
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro Delete pctc77m00003 " sleep 3
           let l_sucesso = false
        end if

        whenever error continue

        execute pctc77m00002 using  lr_parametro.pstcoddig,
                                lr_parametro.atdfnlnum,
                                g_issk.funmat, g_issk.empcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro Insert pctc77m00002 " sleep 3
           let l_sucesso = false
        end if

        let l_prshstdes = "Parametro [",
            lr_parametro.atdfnlnum_ant using "<<<<&", "] alterado para [",
            lr_parametro.atdfnlnum using "<<<<&", "]."

     when "I" # --INCLUSAO

	whenever error continue
		execute pctc77m00002 using lr_parametro.pstcoddig,
                                lr_parametro.atdfnlnum,
                                g_issk.funmat, g_issk.empcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           display "ocorreu erro"
           error "Erro INSERT pctc77m00002 " sleep 3
           let l_sucesso = false
        end if

        let l_prshstdes = "Parametro [",
            lr_parametro.atdfnlnum using "<<<<&", "] incluido!"

    when "E" # --INCLUSAO

	whenever error continue
		execute pctc77m00003 using lr_parametro.pstcoddig,
                                lr_parametro.atdfnlnum
        whenever error stop

        if sqlca.sqlcode <> 0 then
           display "ocorreu erro"
           error "Erro Delete pctc77m00003 " sleep 3
           let l_sucesso = false
        end if

        let l_prshstdes = "Parametro [",
            lr_parametro.atdfnlnum using "<<<<&", "] excluido!"

  end case

  call ctc00m02_grava_hist(lr_parametro.pstcoddig,
                           l_prshstdes,lr_parametro.tipo_operacao)

  return l_sucesso

end function

