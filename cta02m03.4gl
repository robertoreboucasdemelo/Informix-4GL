###############################################################################
# Nome do Modulo: CTA02M03                                           Pedro    #
#                                                                    Marcelo  #
# Mostra agrupamentos de assuntos                                    Dez/1994 #
###############################################################################
# Alteracoes:                                                                 #
# DATA        SOLICITACAO  RESPONSAVEL DESCRICAO                              #
#-----------------------------------------------------------------------------#
# 06/07/2006  PSI 199850   Priscila    Inclusao do campo departamento como    #
#                                      parametro. Criacao da funcao           #
#                                      cta02m03_assunto_depto                 #
#-----------------------------------------------------------------------------#
# 17/11/2006  PSI 205206   Priscila    Validar empresa                        #
#-----------------------------------------------------------------------------#
# 10/11/2008  PSI 230650   Carla       Mostra o Codigo do Agrupamento e filtra#
#                                      a selecao conforme a letra informada na#
#                                      tela de assunto. Se o resultado for de #
#                                      apenas 1 Agrup. abre pop-up de Assuntos#
#-----------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS              #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

#-----------------------------------------------------------
 function cta02m03(param)
#-----------------------------------------------------------

   #PSI 199850
   define param       record
       dptsgl         like datkastagp.dptsgl
      ,c24astagp      like datkastagp.c24astagp
   end record

   define a_cta02m03 array[150] of record
      c24astagp      like datkastagp.c24astagp,
      c24astagpdes   like datkastagp.c24astagpdes
   end record

   #PSI 199850
   define a2_cta02m03 array[150] of record
      dptsgl         like datkastagp.dptsgl,
      ciaempcod      like datkastagp.ciaempcod       #PSI 205206
   end record

   define d_cta02m03    record
      c24astcod    like datkassunto.c24astcod,
      c24astdes    char (72)
   end record

   define scr_aux  smallint
   define arr_aux  smallint

   define sql_comando char(300)
   define l_ciaempcod like datkastagp.ciaempcod      #PSI 205206
   define l_cont      smallint

	define	w_pf1	integer

	let	l_cont   =  0
	let	scr_aux  =  null
	let	arr_aux  =  null
	let	sql_comando  =  null

	for	w_pf1  =  1  to  150
		initialize  a_cta02m03[w_pf1].*  to  null
	end	for

	initialize  d_cta02m03.*  to  null

   #PSI 205206
   #Como essa funcao tb e chamada pelo RE a global com a empresa
   # podera estar nula ou com sujeira (diferente de 1 ou 35 ou 40),
   # caso esteja assim, assumir que a empresa é 1-Porto Seguro
   # qdo o RE tb trabalhar com a Azul, devemos receber a empresa como
   # parametro
   if g_documento.ciaempcod is null or
      (g_documento.ciaempcod <> 1  and
       g_documento.ciaempcod <> 35 and
       g_documento.ciaempcod <> 40 and
       g_documento.ciaempcod <> 50 and
       g_documento.ciaempcod <> 27 and
       g_documento.ciaempcod <> 84 and
       g_documento.ciaempcod <> 43) then
      let l_ciaempcod = 1
   else
      let l_ciaempcod = g_documento.ciaempcod
   end if
   ---> Quando Documento for da Empresa 50-Saude mudar p/ Empresa 1 pois os
   ---> agrupamentos/assuntos nao permitem duplicar o codigo para outra empresa
   if g_documento.ciaempcod = 50 then
      let l_ciaempcod = 1
   end if

   open window cta02m03 at 06,02 with form "cta02m03"
                        attribute(form line 1)

   let int_flag = false
   initialize a_cta02m03    to null
   initialize d_cta02m03.*  to null

   let sql_comando = "select c24astcod          ",
                     "  from datkassunto        ",
                     " where c24astagp = ?  and ",
                     "       c24aststt = 'A'    "
   prepare sql_select from sql_comando
   declare c_assunto  cursor for sql_select


   if param.c24astagp is not null and
      param.c24astagp <> " "      then

      let sql_comando = "select c24astagp    "
                            ,", c24astagpdes "
                            ,", dptsgl       "
                            ,", ciaempcod    "
                       ,"  from datkastagp        "
                       ," where c24astagp matches '"
                               ,param.c24astagp clipped,"*' "
                       ," order by c24astagpdes "
   else
      let sql_comando = "select c24astagp    "
                            ,", c24astagpdes "
                            ,", dptsgl       "
                            ,", ciaempcod    "
                       ,"  from datkastagp   "
                       ," order by c24astagpdes  "
   end if
   prepare sql_select02 from sql_comando
   declare c_assunto02  cursor for sql_select02

   let arr_aux  =  1

   ---> Cursor Principal - Le Agrupamento de Assuntos
   open c_assunto02
   foreach c_assunto02 into a_cta02m03[arr_aux].c24astagp,
                            a_cta02m03[arr_aux].c24astagpdes,
                            a2_cta02m03[arr_aux].dptsgl,         #PSI 199850
                            a2_cta02m03[arr_aux].ciaempcod       #PSI 205206
      #PSI 199850
      #Listar apenas os agrupamentos do departamento recebido como parametro.
      #se recebeu departamento com parametro
      #se agrupamento tem departamento cadastrado
      # e se eles sao diferentes, entao despreza
      if param.dptsgl is not null and
         a2_cta02m03[arr_aux].dptsgl is not null and
         a2_cta02m03[arr_aux].dptsgl <> param.dptsgl then
         continue foreach
      end if

      #PSI 205206
      #Listar apenas os agrupamentos pertencentes a empresa da ligacao
      if a2_cta02m03[arr_aux].ciaempcod is not null and
         a2_cta02m03[arr_aux].ciaempcod <> l_ciaempcod then
         continue foreach
      end if
      open  c_assunto using a_cta02m03[arr_aux].c24astagp
      fetch c_assunto
      if sqlca.sqlcode = notfound  then
         continue foreach
      end if
      close c_assunto

      if arr_aux  >=  150   then
         error " Limite excedido. Tabela de agrupamentos com mais de 50 itens!"
         exit foreach
      end if

      let arr_aux = arr_aux + 1
      let l_cont  = l_cont  + 1

   end foreach

   call set_count(arr_aux-1)


   if  l_cont  =  1 then
      ---> Pop-up de Assuntos
      call cta02m04(a_cta02m03[1].c24astagp)
           returning d_cta02m03.c24astcod, d_cta02m03.c24astdes

   else

      display array a_cta02m03 to s_cta02m03.*

         on key (interrupt, control-c)
            initialize a_cta02m03   to null
            exit display

         on key (F8)
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            display a_cta02m03[arr_aux].c24astagpdes to
                    s_cta02m03[scr_aux].c24astagpdes attribute(reverse)

            display a_cta02m03[arr_aux].c24astagp to
                    s_cta02m03[scr_aux].c24astagp attribute(reverse)

            call cta02m04(a_cta02m03[arr_aux].c24astagp)
                 returning d_cta02m03.c24astcod, d_cta02m03.c24astdes

            display a_cta02m03[arr_aux].c24astagpdes to
                    s_cta02m03[scr_aux].c24astagpdes

            display a_cta02m03[arr_aux].c24astagp to
                    s_cta02m03[scr_aux].c24astagp

            if d_cta02m03.c24astcod is not null  then
               exit display
            end if

      end display
   end if

   close window cta02m03
   let int_flag = false

   let d_cta02m03.c24astdes = a_cta02m03[arr_aux].c24astagpdes clipped, " ",
                              d_cta02m03.c24astdes

   return d_cta02m03.c24astcod, d_cta02m03.c24astdes

end function  ###  cta02m03



#PSI 199850 - Funcao para validar se assunto informado pelo usuario pertence
# ao departamento dele
#-----------------------------------------------------------
function cta02m03_assunto_depto(param)
#-----------------------------------------------------------
   define param record
     c24astcod  like datkassunto.c24astcod,
     dptsgl     like datkastagp.dptsgl
   end record

   define l_sql    char(150)
   define l_dptsgl like datkastagp.dptsgl

   let l_sql = null
   let l_dptsgl = null

   let l_sql = "select a.dptsgl "
              ," from datkastagp a, datkassunto b "
              ," where b.c24astcod = ?            "
              ,"   and b.c24astagp = a.c24astagp  "
   prepare p_cta02m03_001 from l_sql
   declare c_cta02m03_001 cursor for p_cta02m03_001


   open c_cta02m03_001 using param.c24astcod
   fetch c_cta02m03_001 into l_dptsgl
   close c_cta02m03_001

   if l_dptsgl is not null and
      l_dptsgl <> param.dptsgl then
      #Assunto pertence a um grupo que nao pertence ao
      # departamento do usuario
      return false
   end if

   return true

end function
