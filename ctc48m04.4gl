###############################################################################
# Nome do Modulo: ctc48m04                                                    #
#                                                                             #
# Mostra o cadastro de problemas por agrupamento                     Set/2008 #
###############################################################################
#-----------------------------------------------------------------------------#
# 18/09/2008  Nilo          221635   Agendamento de Servicos a Residencia     #
#                                    Portal do Segurado                       #
#                                    Programa derivado da função ctc48m01     #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
database porto

#-----------------------------------------------------------
 function ctc48m04(ws_codagrup,ws_pgm)
#-----------------------------------------------------------

 define ws_codagrup  like datkpbm.c24pbmgrpcod
 define ws_pgm       char (08)

 define lr_ctc48m04  record
        c24pbmcod    like datkpbm.c24pbmcod,
        c24pbmdes    like datkpbm.c24pbmdes,
        c24pbmgrpcod like datkpbm.c24pbmgrpcod,
        webpbmdes    like datkpbm.webpbmdes
 end record

 define arr_aux    smallint


	define	w_pf1	integer

        define  l_qtd   smallint
        define  l_sql   char(300)

        let l_qtd = null
        let l_sql = null

	let	arr_aux  =  null
	let	arr_aux  =  null

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------
   initialize arr_aux     to null

 initialize lr_ctc48m04.*  to null

 let l_qtd = 1

 while true

    whenever error continue
       drop table ctc48m04_problema
    whenever error stop

    whenever error continue
       create temp table ctc48m04_problema(c24pbmcod    smallint     ,
                                           c24pbmdes    char (40)    ,
                                           c24pbmgrpcod smallint     )
                                 with no log

    create unique index idx_tmpctc48m04 on ctc48m04_problema (c24pbmcod,c24pbmgrpcod)
    whenever error stop

    if sqlca.sqlcode <> 0  then
       if sqlca.sqlcode = -310 or
          sqlca.sqlcode = -958 then
          if l_qtd > 10 then
             exit while
          end if
          let l_qtd = l_qtd + 1
          continue while
       end if
    end if

    exit while
 end while

 if l_qtd > 10 then
    return 8 ,"Problema na criacao da tabela temporaria. Erro: " ,sqlca.sqlcode
 clipped
 end if

 let l_sql = 'insert into ctc48m04_problema'
           , ' values(?,?,?)'
 prepare pctc48m04001 from l_sql

 let arr_aux = 1

 if ws_codagrup is null then
    let ws_codagrup = 0
    declare c_ctc48m04 cursor for
       select c24pbmcod,c24pbmdes,c24pbmgrpcod,webpbmdes
         from datkpbm
         where c24pbmgrpcod >  ws_codagrup
           and c24pbmstt <> 'C'
         order by c24pbmdes

    foreach c_ctc48m04  into  lr_ctc48m04.c24pbmcod,
                              lr_ctc48m04.c24pbmdes,
                              lr_ctc48m04.c24pbmgrpcod,
                              lr_ctc48m04.webpbmdes

       if g_origem = "WEB" then
          if length(lr_ctc48m04.webpbmdes) > 0 then
             let lr_ctc48m04.c24pbmdes = null
             let lr_ctc48m04.c24pbmdes = lr_ctc48m04.webpbmdes
          end if
       end if

       ---> Insere Tabela Temporaria - Problema
       whenever error continue
          execute pctc48m04001 using lr_ctc48m04.c24pbmcod,
                                     lr_ctc48m04.c24pbmdes,
                                     lr_ctc48m04.c24pbmgrpcod
       whenever error stop

    end foreach
 else
    declare c_ctc48m04a cursor for
       select c24pbmcod,c24pbmdes,c24pbmgrpcod,webpbmdes
         from datkpbm
         where c24pbmgrpcod = ws_codagrup
           and c24pbmstt <> 'C'
         order by c24pbmdes

    foreach c_ctc48m04a into  lr_ctc48m04.c24pbmcod,
                              lr_ctc48m04.c24pbmdes,
                              lr_ctc48m04.c24pbmgrpcod,
                              lr_ctc48m04.webpbmdes
       if g_origem = "WEB" then
          if length(lr_ctc48m04.webpbmdes) > 0 then
             let lr_ctc48m04.c24pbmdes = null
             let lr_ctc48m04.c24pbmdes = lr_ctc48m04.webpbmdes
          end if
       end if

       ---> Insere Tabela Temporaria - Problema
       whenever error continue
          execute pctc48m04001 using lr_ctc48m04.c24pbmcod,
                                     lr_ctc48m04.c24pbmdes,
                                     lr_ctc48m04.c24pbmgrpcod
       whenever error stop

    end foreach
 end if

 ##################################################
 # Adiciona o codigo 999 OUTROS no final da lista
 ##################################################
 #let a_ctc48m04[arr_aux].c24pbmcod = 999
 #let a_ctc48m04[arr_aux].c24pbmdes = "OUTROS"
 #let arr_aux = arr_aux + 1

  #if a_ctc48m04[arr_aux].c24pbmcod = 999 then
  #   let a_ctc48m04[arr_aux].c24pbmdes = ""
  #end if
  #
  return 0 ,"OK"

end function  ###  ctc48m04
