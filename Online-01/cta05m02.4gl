###############################################################################
# Nome do Modulo: CTA05M02                                           Marcelo  #
#                                                                    Gilberto #
# Consulta etapas de apuracao de reclamacoes                         Jul/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 27/03/2001  Psi 12768-0  Wagner       Incluir no display tela o assunto.    #
###############################################################################

database porto

#-----------------------------------------------------------
 function cta05m02(param)
#-----------------------------------------------------------

 define param       record
    lignum          like datmsitrecl.lignum
 end record

 define d_cta05m02  record
    c24astcod       like datmligacao.c24astcod,
    c24astdes       like datkassunto.c24astdes
 end record

 define a_cta05m02  array[10] of record
    rclsitdes       char (30),
    c24astcod       like datmsitrecl.c24astcod,
    rclrlzdat       like datmsitrecl.rclrlzdat,
    rclrlzhor       like datmsitrecl.rclrlzhor,
    funnom          like isskfunc.funnom
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 define ws          record
    funmat          like isskfunc.funmat,
    rclsitcod       like datmsitrecl.c24rclsitcod
 end record

 define sql_comando char (200)

 let sql_comando = "select funnom    ",
                   "  from isskfunc  ",
                   " where funmat = ?"

 prepare sel_funnom  from  sql_comando
 declare c_funnom  cursor  for sel_funnom

 let sql_comando = "select cpodes from iddkdominio ",
                   " where cponom = 'c24rclsitcod' and",
                   "       cpocod = ? "

 prepare sel_dominio  from  sql_comando
 declare c_dominio  cursor  for sel_dominio

 initialize a_cta05m02     to null
 initialize ws.*           to null

 select c24astcod
   into d_cta05m02.c24astcod
   from datmligacao
  where lignum = param.lignum

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na localizacao da ligacao. AVISE A INFORMATICA!"
    return
 else
    let d_cta05m02.c24astdes = "*** NAO CADASTRADO! ***"

    select c24astdes
      into d_cta05m02.c24astdes
      from datkassunto
     where c24astcod = d_cta05m02.c24astcod
 end if

 open window cta05m02 at 06,02 with form "cta05m02"
             attribute (form line first)

 display by name param.lignum
 display by name d_cta05m02.*

 declare  c_cta05m02  cursor for
    select c24rclsitcod, rclrlzdat, rclrlzhor, funmat, c24astcod
      from datmsitrecl
     where lignum = param.lignum

 let arr_aux = 1

 foreach  c_cta05m02  into  ws.rclsitcod,
                            a_cta05m02[arr_aux].rclrlzdat,
                            a_cta05m02[arr_aux].rclrlzhor,
                            ws.funmat,
                            a_cta05m02[arr_aux].c24astcod

      let a_cta05m02[arr_aux].funnom = "*** NAO CADASTRADO! ***"

      open  c_funnom using ws.funmat
      fetch c_funnom into  a_cta05m02[arr_aux].funnom
      close c_funnom

      let a_cta05m02[arr_aux].rclsitdes = "*** NAO CADASTRADA! ***"

      open  c_dominio using ws.rclsitcod
      fetch c_dominio into  a_cta05m02[arr_aux].rclsitdes
      close c_dominio

      let arr_aux = arr_aux + 1
      if arr_aux > 10  then
         error " Limite excedido. Reclamacao com mais de 10 etapas!"
         exit foreach
      end if
 end foreach

 if arr_aux > 1  then
    message " (F17)Abandona"
    call set_count(arr_aux-1)

    display array  a_cta05m02 to s_cta05m02.*
      on key(interrupt)
         exit display
    end display
 else
    error " Nao existem etapas cadastradas para esta reclamacao!"
 end if

let int_flag = false
close window cta05m02

end function  ###  cta05m02
