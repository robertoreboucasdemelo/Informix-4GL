###############################################################################
# Nome do Modulo: cta02m10                                           Gilberto #
#                                                                     Marcelo #
# Exibe matriculas com permissao de liberacao (assuntos/bloqueios)   Mar/1998 #
###############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 12/07/2002  PSI 15424-5  Ruiz         Retorna a matricula que autorizou   #
#                                       a utilizacao do assunto.            #
#---------------------------------------------------------------------------#

# ...............................................................................#
#                                                                                #
#                           * * * Alteracoes * * *                               #
#                                                                                #
# Data       Autor Fabrica   Origem        Alteracao                             #
# ---------- --------------  ----------    --------------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao "fun_dba_abre_banco"#
#                                          e troca da "systables" por "dual"     #
#--------------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

#-----------------------------------------------------------
 function cta02m10(param)
#-----------------------------------------------------------

 define param       record
    c24astcod       like datrastfun.c24astcod,
    blqnum          like datkblq.blqnum
 end record

 define a_cta02m10  array[200]  of record
    empcod          like datrastfun.empcod,
    funmat          like datrastfun.funmat,
    funnom          like isskfunc.funnom,
    funsnh          like datkfun.funsnh,
    funsnhcad       like datkfun.funsnh
 end record

 define ws          record
    senhaok         char (01),
    cabec           char (66),
    comando         char (400),
    libtipdes       char (08),
    confirma        char (01),
    funnom          like isskfunc.funnom,
    c24atrflg       like datkassunto.c24atrflg
 end record

 define arr_aux    smallint
 define scr_aux    smallint



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cta02m10[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*        to null
 initialize a_cta02m10  to null
 let int_flag   =  false
 let arr_aux    =  1
 let ws.senhaok = "n"

 if param.c24astcod   is null    and
    param.blqnum      is null    then
    error " Nenhum parametro informado para CTA02M10, AVISE INFORMATICA!"
    return ws.senhaok, ws.funnom
 end if

 if param.c24astcod   is not null    and
    param.blqnum      is not null    then
    error " Mais de um parametro informado para CTA02M10, AVISE INFORMATICA!"
    return ws.senhaok, ws.funnom
 end if

 if param.c24astcod  is not null   then
    let ws.libtipdes = "ASSUNTO"
    let ws.cabec  = "   Funcionarios com permissao de liberacao para o ",
                    ws.libtipdes, " ", param.c24astcod

    let ws.comando = "select datrastfun.empcod,",
                     "       datrastfun.funmat,",
                     "       isskfunc.funnom,",
                     "       datkfun.funsnh",
                     "  from datrastfun, isskfunc, datkfun",
                     " where datrastfun.c24astcod  =  ?              ",
                     "   and isskfunc.empcod       =  datrastfun.empcod",
                     "   and isskfunc.funmat       =  datrastfun.funmat",
                     "   and datkfun.empcod        =  isskfunc.empcod",
                     "   and datkfun.funmat        =  isskfunc.funmat"
 else
    let ws.libtipdes = "BLOQUEIO"
    let ws.cabec  = "   Funcionarios com permissao de liberacao para o ",
                    ws.libtipdes, " ", param.blqnum  using "<<<&&&"

    let ws.comando = "select datrfunblqlib.empcod,",
                     "       datrfunblqlib.funmat,",
                     "       isskfunc.funnom,",
                     "       datkfun.funsnh",
                     "  from datrfunblqlib, isskfunc, datkfun",
                     " where datrfunblqlib.blqnum  =  ? ",
                     "   and isskfunc.empcod       =  datrfunblqlib.empcod",
                     "   and isskfunc.funmat       =  datrfunblqlib.funmat",
                     "   and datkfun.empcod        =  isskfunc.empcod",
                     "   and datkfun.funmat        =  isskfunc.funmat"
 end if

 #---------------------------------------------------------------------
 # Verifica se existem matriculas cadastradas para o codigo de assunto
 #---------------------------------------------------------------------
 prepare p_cta02m10_001 from       ws.comando
 declare c_cta02m10_001  cursor for p_cta02m10_001

 if param.c24astcod  is not null   then
    select c24atrflg
         into ws.c24atrflg
         from datkassunto
        where c24astcod = param.c24astcod
    open c_cta02m10_001  using  param.c24astcod
 else
    open c_cta02m10_001  using  param.blqnum
 end if

 foreach c_cta02m10_001  into  a_cta02m10[arr_aux].empcod,
                           a_cta02m10[arr_aux].funmat,
                           a_cta02m10[arr_aux].funnom,
                           a_cta02m10[arr_aux].funsnhcad

    if a_cta02m10[arr_aux].funmat  =   g_issk.funmat  then
       let ws.senhaok = "s"
       exit foreach
    end if

    let arr_aux  =  arr_aux + 1
    if arr_aux  >  200   then
       error " Limite excedido, ", ws.libtipdes," c/ mais de 200 matriculas cadastradas!"
       exit foreach
    end if
 end foreach
 #------------------------------------------------------------------
 # Se matricula cadastrada, abrir tela para digitacao de senha
 #------------------------------------------------------------------
 call set_count(arr_aux-1)

 if ws.senhaok  =  "n"  and
    arr_aux     >  1    then

    open window w_cta02m10 at 07,07 with form "cta02m10"
         attribute(form line 1, border, message line last - 1)

    options insert key F40,
            delete key F50

    display by name ws.cabec  attribute(reverse)

    error ws.libtipdes, " necessita de permissao para atendimento!"
    message " (F17)Abandona"

    input array a_cta02m10 without defaults from s_cta02m10.*

       before row
          let arr_aux    = arr_curr()
          let scr_aux    = scr_line()
          let ws.senhaok = "n"

          display a_cta02m10[arr_aux].empcod  to
                  s_cta02m10[scr_aux].empcod  attribute(reverse)
          display a_cta02m10[arr_aux].funmat  to
                  s_cta02m10[scr_aux].funmat  attribute(reverse)
          display a_cta02m10[arr_aux].funnom  to
                  s_cta02m10[scr_aux].funnom  attribute(reverse)

       after row
          display a_cta02m10[arr_aux].empcod  to
                  s_cta02m10[scr_aux].empcod
          display a_cta02m10[arr_aux].funmat  to
                  s_cta02m10[scr_aux].funmat
          display a_cta02m10[arr_aux].funnom  to
                  s_cta02m10[scr_aux].funnom

       before field funsnh
          display a_cta02m10[arr_aux].funsnh to
                  s_cta02m10[scr_aux].funsnh attribute (reverse)

       after field funsnh
          display a_cta02m10[arr_aux].funsnh to
                  s_cta02m10[scr_aux].funsnh

          if fgl_lastkey() <> fgl_keyval ("up")     and
             fgl_lastkey() <> fgl_keyval ("down")   and
             fgl_lastkey() <> fgl_keyval ("left")   then

             if a_cta02m10[arr_aux].funsnh  is null   then
                error " Senha para liberacao do codigo deve ser informada!"
                next field funsnh
             end if

             if a_cta02m10[arr_aux].funsnh <> a_cta02m10[arr_aux].funsnhcad then
                error " Senha para liberacao nao confere!"
                next field funsnh
             end if

             let ws.senhaok = "s"
             let ws.funnom  =  a_cta02m10[arr_aux].funnom
             if ws.c24atrflg <> "S" then
                call cts08g01("A","N","",
                              "REGISTRE NO HISTORICO O NOME",
                              "DO RESPONSAVEL PELA LIBERACAO",
                              "DESTE ATENDIMENTO")
                  returning ws.confirma
             end if
             exit input
          end if
          if fgl_lastkey() <> fgl_keyval ("up")    and
             fgl_lastkey() <> fgl_keyval ("left")  then
             if a_cta02m10[arr_aux+1].funmat  is null   then
                error " Nao existem mais linhas nesta direcao!"
                next field funsnh
             end if
          end if

          on key (interrupt)
             exit input

    end input

    options insert key F1,
            delete key F2

    close window  w_cta02m10

 else
    let ws.senhaok = "s"

 end if

 return ws.senhaok,ws.funnom

end function   ##--  cta02m10
