#############################################################################
# Nome do Modulo: CTX00G00                                         Marcelo  #
#                                                                  Gilberto #
# Funcao para retornar tributacao/descontos -  Porto Socorro       Fev/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 18/03/1999  PSI 7885-9   Gilberto     Inclusao do campo VALOR INSS no re- #
#                                       torno da funcao.                    #
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -------------------------------------#
# 23/01/2003  Gustavo, Meta  PSI182133 Retornar os impostos PIS, COFINS e   #
#                            OSF 30449 CSLL.                                #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

#------------------------------------------------------------------
 function ctx00g00(param)
#------------------------------------------------------------------

 define param           record
    socopgnum           like dbsmopgtrb.socopgnum,
    privez              smallint
 end record

 define d_ctx00g00      record
    sqlcode             integer,
    socirfvlr           like dbsmopgtrb.socirfvlr,
    socissvlr           like dbsmopgtrb.socissvlr,
    insretvlr           like dbsmopgtrb.insretvlr,
    socopgdscvlr        like dbsmopg.socopgdscvlr,
    pisretvlr           like dbsmopgtrb.pisretvlr,  ###
    cofretvlr           like dbsmopgtrb.cofretvlr,  ### PSI182133
    cslretvlr           like dbsmopgtrb.cslretvlr   ###
 end record




	initialize  d_ctx00g00.*  to  null

 initialize d_ctx00g00.*  to null

 if param.socopgnum is null  then
    return d_ctx00g00.*
 end if

 if param.privez = true  then
    call ctx00g00_prepare()
 end if

 call ctx00g00_select(param.socopgnum) returning d_ctx00g00.*

 return d_ctx00g00.*

end function  ###  ctx00g00


#------------------------------------------------------------------
 function ctx00g00_prepare()
#------------------------------------------------------------------

 define sql  char (200)


	let	sql  =  null

 ### Inicio PSI182133
 let sql = "select socirfvlr,   ",
           "       socissvlr,   ",
           "       insretvlr,   ",
           "       pisretvlr,   ", 
           "       cofretvlr,   ", 
           "       cslretvlr    ",  
           "  from dbsmopgtrb   ",
           " where socopgnum = ?"

 prepare pctx00g00001 from sql
 declare cctx00g00001 cursor for pctx00g00001
 ### Final PSI182133

 let sql = "select socopgdscvlr ",
           "  from dbsmopg      ",
           " where socopgnum = ?"

 prepare sel_opg    from sql
 declare c_opg    cursor with hold for sel_opg

end function  ###  ctx00g00_prepare


#------------------------------------------------------------------
 function ctx00g00_select(param)
#------------------------------------------------------------------

 define param           record
    socopgnum           like dbsmopgtrb.socopgnum
 end record

 define d_ctx00g00      record
    sqlcode             integer,
    socirfvlr           like dbsmopgtrb.socirfvlr,
    socissvlr           like dbsmopgtrb.socissvlr,
    insretvlr           like dbsmopgtrb.insretvlr,
    socopgdscvlr        like dbsmopg.socopgdscvlr,
    pisretvlr           like dbsmopgtrb.pisretvlr,  ###
    cofretvlr           like dbsmopgtrb.cofretvlr,  ### PSI182133
    cslretvlr           like dbsmopgtrb.cslretvlr   ###
 end record



	initialize  d_ctx00g00.*  to  null

 initialize d_ctx00g00.*  to null

 open  c_opg     using param.socopgnum
 fetch c_opg     into  d_ctx00g00.socopgdscvlr
    if sqlca.sqlcode <> 0  then
       let d_ctx00g00.sqlcode = sqlca.sqlcode
       return d_ctx00g00.*
    end if
 close c_opg

 ### Inicio PSI182133
 open  cctx00g00001  using param.socopgnum
 whenever error continue
 fetch cctx00g00001  into  d_ctx00g00.socirfvlr,
                           d_ctx00g00.socissvlr,
                           d_ctx00g00.insretvlr,
                           d_ctx00g00.pisretvlr,
                           d_ctx00g00.cofretvlr,
                           d_ctx00g00.cslretvlr
 whenever error stop
 if sqlca.sqlcode < 0 then
    display 'Erro SELECT cctx00g00001:' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] 
    display ' CTX00G00/ ctx00g00()/ ', param.socopgnum  
    initialize d_ctx00g00 to null
 end if      
 ### Inicio PSI182133

 return d_ctx00g00.*

end function  ###  ctx00g00_select
