###############################################################################
# Nome do Modulo: ctb83m01                                     Cristiane Silva#
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

  define am_ctb83m01  array[3000] of record
         navega    char(01),
         cctdptcod    char(05),
         cctdptnom    char(25)
  end record

  define m_contador smallint

#--------------#
function ctb83m01(l_param)
#--------------#
define l_param record
	succod like ctgrlcldpt.succod,
	empcod like ctgrlcldpt.empcod
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

  define l_cctdptcod smallint
  define l_cctdptnom char(50)
  define l_ccusto char(05)
  define l_cctlclcod smallint

  let l_sucesso = true
let l_arr           = null
  let l_situacao_ant  = null
  let l_descricao_ant = null
  let l_scr           = null
  let l_resposta      = null

  let int_flag = false

  let l_operacao = " "

if m_prep_sql is null or m_prep_sql <> true then
	call ctb83m01_prepare()
end if

  open window w_ctb83m01 at 8,5 with form "ctb83m01"
     attribute(form line 1, border)

  call ctb83m01_carrega_array(l_param.succod, l_param.empcod)

  call set_count(m_contador)

  while true

     input array am_ctb83m01 without defaults from s_ctb83m01.*

        before row
           let l_arr = arr_curr()
           let l_scr = scr_line()

        before field navega
           if l_operacao = "I" then
              next field cctlclcod
           end if

        after field navega

             if fgl_lastkey() = fgl_keyval('down') then
                 if am_ctb83m01[l_arr + 1].cctdptcod is null then
                    next field navega
                 end if
              end if



        before field cctdptcod
           display am_ctb83m01[l_arr].cctdptcod to s_ctb83m01[l_scr].cctdptcod attribute(reverse)

        after field cctdptcod
           display am_ctb83m01[l_arr].cctdptcod to s_ctb83m01[l_scr].cctdptcod

           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = fgl_keyval('down') then
              next field cctdptcod
           end if


        before field cctdptnom
           display am_ctb83m01[l_arr].cctdptnom to s_ctb83m01[l_scr].cctdptnom attribute(reverse)

        after field cctdptnom
           display am_ctb83m01[l_arr].cctdptnom to s_ctb83m01[l_scr].cctdptnom


           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = fgl_keyval('down') then
              next field cctdptnom
           end if

           let l_operacao = " "

           next field navega

       on key (control-c, f17, interrupt)
          initialize am_ctb83m01[l_arr].* to null
          let int_flag = true
          let m_contador = 0
          exit input

      on  key(f8)
      	  let l_cctdptcod = am_ctb83m01[l_arr].cctdptcod
          let l_cctdptnom = am_ctb83m01[l_arr].cctdptnom
	  exit input

      on  key(insert,delete)
          exit input
     end input

     if int_flag then
     	let l_cctdptcod = null
     	let l_cctdptnom = null
    end if

  exit while

  end while

close window w_ctb83m01


return l_cctdptcod, l_cctdptnom

end function

#----------------------#
function ctb83m01_prepare()
#----------------------#

  define l_sql char(300)

  let m_prep_sql = false

#  create temp table array_tmp (cctlclcod       smallint,
#                               cctdptcod       smallint,
#                               cctdptnom       char(25)) with no log

  let l_sql = " select distinct a.cctlclcod, a.cctdptcod, b.cctdptnom ",
              "  from ctgrlcldpt a,ctgkdpt b ",
              " where a.cctdptcod = b.cctdptcod ",
              " and a.empcod = ?",
              " and a.succod = ? "

  prepare p_ctb83m01_001 from l_sql
  declare c_ctb83m01_001 cursor for p_ctb83m01_001


let m_prep_sql = true

end function

#----------------------------#
function ctb83m01_carrega_array(param)
#----------------------------#

define param record
	succod like ctgrlcldpt.succod,
	empcod like ctgrlcldpt.empcod
end record

define l_cctlclcod smallint
define l_cctdptcod smallint
define l_cctdptnom char(50)

  initialize am_ctb83m01 to null

  let m_contador = 1


  open c_ctb83m01_001 using param.empcod, param.succod

  foreach c_ctb83m01_001 into l_cctlclcod,
  			    l_cctdptcod,
  			    l_cctdptnom

let am_ctb83m01[m_contador].cctdptcod = l_cctlclcod using "<", l_cctdptcod using "<<<<"
let am_ctb83m01[m_contador].cctdptnom = l_cctdptnom



     let m_contador = m_contador + 1

     if m_contador = 3001 then
        error "O limite de 3000 registros foi ultrapassado" sleep 2
        exit foreach
     end if


  end foreach

  let m_contador = m_contador - 1


end function

