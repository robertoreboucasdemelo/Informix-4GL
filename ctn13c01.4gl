############################################################################
# Menu de Modulo: CTN13C01                                        Marcelo  #
#                                                                 Gilberto #
# Consulta procedimentos operacionais de determinado topico       Mar/1996 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 17/04/2000  Correio      Akio         Array aumentado p/ 300 ocorrencias #
############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctn13c01(par_ctn13c01)
#---------------------------------------------------------------

  define par_ctn13c01 record
         cvnnum       like datkdestopcvn.cvnnum ,
         cvntopcod    like datkdestopcvn.cvntopcod
  end    record

  define d_ctn13c01   record
         cvndes       like datkdominio.cpodes ,
         cvntopnom    like datktopcvn.cvntopnom
  end    record

  define a_ctn13c01 array[500] of record
         cvntopdes       like datkdestopcvn.cvntopdes ,
         cvntopdesseq    like datkdestopcvn.cvntopdesseq
  end    record

  define arr_aux      smallint
  define scr_aux      smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  500
		initialize  a_ctn13c01[w_pf1].*  to  null
	end	for

	initialize  d_ctn13c01.*  to  null

  whenever error continue

  select cpodes
    into d_ctn13c01.cvndes
    from datkdominio
   where cponom = "ligcvntip" and
         cpocod = par_ctn13c01.cvnnum

  if sqlca.sqlcode <> 0 then
     error "Erro (", sqlca.sqlcode, ") durante a localizacao do convenio ",
           par_ctn13c01.cvnnum, ". AVISE A INFORMATICA!"
     let d_ctn13c01.cvndes = "**********"
  end if

  select cvntopnom
    into d_ctn13c01.cvntopnom
    from datktopcvn
   where cvnnum    = par_ctn13c01.cvnnum    and
         cvntopcod = par_ctn13c01.cvntopcod

  if sqlca.sqlcode <> 0 then
     error "Erro (", sqlca.sqlcode, ") durante a localizacao do topico. ",
           "AVISE A INFORMATICA!"
     return
  end if

  whenever error stop

  open window ctn13c01 at 07,02 with form "ctn13c01"
                       attribute(form line 1, border)

  display by name d_ctn13c01.*

  while true
     let int_flag = false

     declare c_ctn13c01_001 cursor for
        select cvntopdes    ,
               cvntopdesseq
          from datkdestopcvn
         where datkdestopcvn.cvnnum    = par_ctn13c01.cvnnum and
               datkdestopcvn.cvntopcod = par_ctn13c01.cvntopcod
         order by cvntopdesseq

     let arr_aux = 1

     initialize a_ctn13c01  to null

     foreach c_ctn13c01_001 into a_ctn13c01[arr_aux].*
        let arr_aux  = arr_aux  + 1
        if arr_aux > 500  then
           error " Limite excedido. Foram encontradas mais de 500 linhas de procedimentos!"
           exit foreach
        end if
     end foreach

     if  arr_aux  >  1  then
         message " (F17)Abandona"
         call set_count(arr_aux-1)
         display array a_ctn13c01 to s_ctn13c01.*
            on key (interrupt,control-c)
               exit display
         end display
     else
         error "Nenhum procedimento foi cadastrado para este topico!"
         let int_flag =  true
     end if

     if int_flag  then
        exit while
     end if

  end while

  let int_flag = false
  close window ctn13c01

end function  ###  ctn13c01
