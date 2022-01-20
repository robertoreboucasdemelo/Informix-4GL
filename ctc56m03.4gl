############################################################################
# Menu de Modulo: CTC56M03                                           Raji  #
#                                                                          #
# Consulta textos para clausulas                                  Mar/2002 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#--------------------------------------------------------------------------#
# 31/12/2004  Katiucia            CT 275247  Ajuste selecao texto clausula #
# 25/09/06   Ligia Mattge  PSI 202720 Implementando grupo/cartao saude     # 
############################################################################
globals  "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc56m03(par_ctc56m03)
#---------------------------------------------------------------
  define par_ctc56m03 record
         ciaempcod    like datkclstxt.ciaempcod,
         ramcod       like datkclstxt.ramcod,
         rmemdlcod    like datkclstxt.rmemdlcod,
         clscod       like datkclstxt.clscod
  end    record

  define d_ctc56m03   record
         clsdes       like agfkclaus.clsdes,
         ramnom       like gtakram.ramnom
  end    record

  define ws           record
         tabnum       like aackcls.tabnum,
         viginc       like abbmitem.viginc,
         clslinseq    like datkclstxt.clslinseq
  end    record

  define a_ctc56m03 array[300] of record
         clstxt    like datkclstxt.clstxt ,
         clslin    like datkclstxt.clslin
  end    record

  define arr_aux      smallint
  define scr_aux      smallint

  define l_ramgrpcod     like gtakram.ramgrpcod,
         l_status        smallint,
         l_msg           char(20)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  300
		initialize  a_ctc56m03[w_pf1].*  to  null
	end	for

	initialize  d_ctc56m03.*  to  null

	initialize  ws.*  to  null

  let l_ramgrpcod  = null
  let l_status     = null
  let l_msg        = null

  
  if g_documento.ciaempcod = 35 then 
     if par_ctc56m03.clscod = "37A" then
        let par_ctc56m03.clscod = "03B" 
     end if                    
     if par_ctc56m03.clscod = "37B" then
        let par_ctc56m03.clscod = "03C" 
     end if                    
     if par_ctc56m03.clscod = "37C" then
        let par_ctc56m03.clscod = "03D"
     end if 
  end if    
  
  
  
  ### PSI 202720 #####
  call cty10g00_grupo_ramo(1,par_ctc56m03.ramcod)
               returning l_status, l_msg, l_ramgrpcod 

  call ctc56m06_clsdes(par_ctc56m03.ciaempcod, l_ramgrpcod, 
                       par_ctc56m03.ramcod,
                       par_ctc56m03.clscod, par_ctc56m03.rmemdlcod)
       returning d_ctc56m03.clsdes  

  select ramnom
    into d_ctc56m03.ramnom
    from gtakram
   where ramcod = par_ctc56m03.ramcod
     and empcod = 1

  open window ctc56m03 at 07,02 with form "ctc56m03"
                       attribute(form line 1, border)

  display par_ctc56m03.ramcod    to ramcod
  display d_ctc56m03.ramnom      to ramnom
  display par_ctc56m03.rmemdlcod to rmemdlcod
  display par_ctc56m03.clscod    to clscod
  display d_ctc56m03.clsdes      to clsdes

  while true
     let int_flag = false

     # -- CT 275247 - Katiucia -- #
     declare c_ctc56m03 cursor for
        select clstxt    ,
               clslin
          from datkclstxt
         where clscod    = par_ctc56m03.clscod
           and ramcod    = par_ctc56m03.ramcod
           and rmemdlcod = par_ctc56m03.rmemdlcod
           and ciaempcod = par_ctc56m03.ciaempcod
           and clslinseq = ( select max(clslinseq)
                               from datkclstxt
                              where clscod    = par_ctc56m03.clscod
                                and ramcod    = par_ctc56m03.ramcod
                                and ciaempcod = par_ctc56m03.ciaempcod
                                and rmemdlcod = par_ctc56m03.rmemdlcod )
         order by clslin

     let arr_aux = 1

     initialize a_ctc56m03  to null

     foreach c_ctc56m03 into a_ctc56m03[arr_aux].*
        let arr_aux  = arr_aux  + 1
        if arr_aux > 300  then
           error " Limite excedido. Foram encontradas mais de 300 linhas de Texto!"
           exit foreach
        end if
     end foreach

     if  arr_aux  >  1  then
         message " (F17)Abandona"
         call set_count(arr_aux-1)
         display array a_ctc56m03 to s_ctc56m03.*
            on key (interrupt,control-c)
               exit display
         end display
     else
         error "Nenhum texto cadastrado para esta clausula!"
         let int_flag =  true
     end if

     if int_flag  then
        exit while
     end if

  end while

  let int_flag = false
  close window ctc56m03

end function  ###  ctc56m03
