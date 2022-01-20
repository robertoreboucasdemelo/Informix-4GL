###############################################################################
# Nome do Modulo: ctb83m02                                     Cristiane Silva#
#                                                                             #
# Pesquisa de Centro de Custo com Local                              Jul/2007 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
###############################################################################

database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint

  define am_ctb83m02  array[3000] of record
         navega    char(01),
         empcod    char(05),
         empnom    char(25)
  end record

  define m_contador smallint

#--------------#
function ctb83m02(l_param)
#--------------#
define l_param record
	empcod like gabkemp.empcod
end record

define l_sucesso     smallint

define l_operacao      char(01),
         l_arr           smallint,
         l_scr           smallint,
         l_codigo        smallint,
         l_resposta      char(01),
         l_situacao_ant  char(01),
         l_descricao_ant char(01),
         l_espcod	 smallint

  define l_empcod smallint
  define l_empnom char(50)

  let l_sucesso = true
  let l_arr           = null
  let l_situacao_ant  = null
  let l_descricao_ant = null
  let l_scr           = null
  let l_resposta      = null

  let int_flag = false

  let l_operacao = " "

if m_prep_sql is null or m_prep_sql <> true then
	call ctb83m02_prepare()
end if

  open window w_ctb83m02 at 8,5 with form "ctb83m02"
     attribute(form line 1, border)

  call ctb83m02_carrega_array(l_param.empcod)

  call set_count(m_contador)

  while true

     input array am_ctb83m02 without defaults from s_ctb83m02.*

        before row
           let l_arr = arr_curr()
           let l_scr = scr_line()

        before field navega
           if l_operacao = "I" then
              next field empcod
           end if

        after field navega

             if fgl_lastkey() = fgl_keyval('down') then
                 if am_ctb83m02[l_arr + 1].empcod is null then
                    next field navega
                 end if
              end if


        before field empcod
           display am_ctb83m02[l_arr].empcod to s_ctb83m02[l_scr].empcod attribute(reverse)

        after field empcod
           display am_ctb83m02[l_arr].empcod to s_ctb83m02[l_scr].empcod

           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = fgl_keyval('down') then
              next field empcod
           end if


        before field empnom
           display am_ctb83m02[l_arr].empnom to s_ctb83m02[l_scr].empnom attribute(reverse)

        after field empnom
           display am_ctb83m02[l_arr].empnom to s_ctb83m02[l_scr].empnom


           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = fgl_keyval('down') then
              next field empnom
           end if

           let l_operacao = " "

           next field navega

       on key (control-c, f17, interrupt)
          initialize am_ctb83m02[l_arr].* to null
          let int_flag = true
          let m_contador = 0
          exit input

      on  key(f8)
      	  let l_empcod = am_ctb83m02[l_arr].empcod
          let l_empnom = am_ctb83m02[l_arr].empnom
	  exit input

      on  key(insert,delete)
          exit input
     end input

     if int_flag then
     	let l_empcod = null
     	let l_empnom = null
    end if

  exit while

  end while

close window w_ctb83m02

return l_empcod, l_empnom

end function

#----------------------#
function ctb83m02_prepare()
#----------------------#

  define l_sql char(300)

  let m_prep_sql = false

  create temp table array_tmp (empcod       smallint,
                               empnom       char(25)) with no log

  let l_sql = " select empcod, empnom ",
              "  from gabkemp ",
              " where empcod <> 35 ",
              " order by 1 "

  prepare p_ctb83m02_001 from l_sql
  declare c_ctb83m02_001 cursor for p_ctb83m02_001


let m_prep_sql = true

end function

#----------------------------#
function ctb83m02_carrega_array(param)
#----------------------------#

define param record
	empcod like gabkemp.empcod
end record

define l_empcod smallint
define l_empnom char(25)


  initialize am_ctb83m02 to null

  let m_contador = 1


  open c_ctb83m02_001

  foreach c_ctb83m02_001 into l_empcod,
  			    l_empnom

let am_ctb83m02[m_contador].empcod = l_empcod #using "<", l_empcod using "<<<<"
let am_ctb83m02[m_contador].empnom = l_empnom



     let m_contador = m_contador + 1

     if m_contador = 3001 then
        error "O limite de 3000 registros foi ultrapassado" sleep 2
        exit foreach
     end if


  end foreach

  let m_contador = m_contador - 1


end function

