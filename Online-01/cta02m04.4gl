###############################################################################
# Nome do Modulo: CTA02M04                                           Pedro    #
#                                                                    Marcelo  #
# Mostra todos os Assuntos                                           Dez/1994 #
###############################################################################
# Alteracoes:                                                                 #
# DATA        SOLICITACAO  RESPONSAVEL DESCRICAO                              #
#-----------------------------------------------------------------------------#
# 10/11/2008  PSI 230650   Carla       Mostra o Codigo do Assunto             #
###############################################################################


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cta02m04(par_c24astagp)
#-----------------------------------------------------------

 define par_c24astagp like datkassunto.c24astagp

 define a_cta02m04 array[100] of record
    c24astcod  like datkassunto.c24astcod,
    c24astdes  like datkassunto.c24astdes
 end record

 define ws         record
    c24aststt  like datkassunto.c24aststt
 end record

 define arr_aux    smallint
 define scr_aux    smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_cta02m04[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 open window cta02m04 at 06,33 with form "cta02m04"
                      attribute(border, form line 1)

   let int_flag = false
   initialize  a_cta02m04    to null
   initialize  ws.*          to null

   declare c_cta02m04_001    cursor for
      select c24astcod, c24astdes, c24aststt
        from datkassunto
       where c24astagp  =  par_c24astagp
       order by c24astdes

   let arr_aux = 1

   foreach c_cta02m04_001 into a_cta02m04[arr_aux].c24astcod,
                           a_cta02m04[arr_aux].c24astdes,
                           ws.c24aststt

      if ws.c24aststt <> "A"  then
         continue foreach
      end if

      if arr_aux  >  100   then
         error "Limite excedido. Tabela de assuntos com mais de 100 itens!"
         exit foreach
      end if

      let arr_aux = arr_aux + 1

   end foreach

   call set_count(arr_aux-1)

   display array a_cta02m04 to s_cta02m04.*

      on key (interrupt,control-c)
         initialize a_cta02m04   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         exit display

   end display

   close window  cta02m04
   let int_flag = false

   return a_cta02m04[arr_aux].c24astcod, a_cta02m04[arr_aux].c24astdes

end function  #  cta02m04
