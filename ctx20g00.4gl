#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : ctx20g00.4gl                                              #
#                  Identificar a quantidade de servicos de vidros realizados #
#                  pelo segurado.                                            #
# Analista Resp. : Ruiz                                                      #
# OSF            : 21580 -                                                   #
#............................................................................#
# Desenvolvimento: Fabrica de Software - Ronaldo Marques                     #
# Liberacao      : 12/06/2003                                                #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data        Autor Fabrica  Data   Alteracao                                #
# ----------  -------------  ------ -----------------------------------------#
#----------------------------------------------------------------------------#
database porto
--------------------------------------------------------------------------------
function ctx20g00(l_entrada)
--------------------------------------------------------------------------------
 define	l_entrada	record
	forcodtip	char(01),
	vigini		date,
	vigfnl		date,
	vclchsfnl	like adimvdrrpr.vclchsfnl,
	vcllicnum	like adimvdrrpr.vcllicnum
 end	record
 define	l_ret		record
	reparos		integer,
	trocas		integer,
	retrovisores	integer
 end	record	

 initialize l_ret.* to null

 if l_entrada.forcodtip is null or
    l_entrada.forcodtip not matches "[T,C]" or
    l_entrada.vigini is null or
    l_entrada.vigini = "01/12/1899" or
    l_entrada.vigfnl is null or
    l_entrada.vigfnl = "01/12/1899"  or
    l_entrada.vigini > l_entrada.vigfnl or
    l_entrada.vclchsfnl is null or
    l_entrada.vclchsfnl = " " then
    error "Erro nos parametros recebidos. Codigo ctx20g00."
    if l_entrada.forcodtip = "C" then
       return l_ret.*
    else
       return
    end if
 end if

 case l_entrada.forcodtip
     when "C"
          call ctx20g00_consulta(l_entrada.*)
               returning l_ret.*
          return l_ret.*
     when "T"
          call ctx20g00_tela(l_entrada.*)
          return
 end case
end function
----------------------------------------------------------------------
function ctx20g00_consulta(l_param)
----------------------------------------------------------------------
 define	l_param	record
	forcodtip	char(01),
	vigini		date,
	vigfnl		date,
	vclchsfnl	like adimvdrrpr.vclchsfnl,
	vcllicnum	like adimvdrrpr.vcllicnum
 end	record

 define	l_ret		record
	reparos		integer,
	trocas		integer,
	retrovisores	integer
 end	record	
 define	l_loop		record
	vdrrprsrvcod	like adimvdrrpr.vdrrprsrvcod,
	vclvdrcod	like adimvdrrpr.vclvdrcod	
 end	record

 define	l_sql		char(1000)
 initialize l_ret.* to null

 let l_sql = "select vdrrprsrvcod,              ",
             "       vclvdrcod                  ",
             "  from adimvdrrpr                 ",
             " where vdrrprdat >= '", l_param.vigini , "'",
             "   and vdrrprdat <= '", l_param.vigfnl , "'",
             "   and vclchsfnl = '", l_param.vclchsfnl, "'"
 if l_param.vcllicnum is not null and
    l_param.vcllicnum <> " "      then
    let l_sql = l_sql clipped,
             "   and vcllicnum = '", l_param.vcllicnum , "'"
 end if
 whenever error continue
 prepare pctx20g00001 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Erro ", sqlca.sqlcode using "<<<<<&",
          " no prepare da tabela adimvdrrpr."
    return l_ret.*
 end if
 declare cctx20g00001 cursor for pctx20g00001

 let l_ret.reparos      = 0
 let l_ret.trocas       = 0
 let l_ret.retrovisores = 0

 foreach cctx20g00001 into l_loop.*


     case l_loop.vdrrprsrvcod
          when 2
              let l_ret.reparos = l_ret.reparos + 1
          when 1
              if l_loop.vclvdrcod = 6 then
                 let l_ret.retrovisores = l_ret.retrovisores + 1
              else
                 let l_ret.trocas = l_ret.trocas + 1
              end if
     end case

 end foreach

 return l_ret.*

end function
----------------------------------------------------------------------
function ctx20g00_tela(l_param)
----------------------------------------------------------------------
 define	l_param	record
	forcodtip	char(01),
	vigini		date,
	vigfnl		date,
	vclchsfnl	like adimvdrrpr.vclchsfnl,
	vcllicnum	like adimvdrrpr.vcllicnum
 end	record
 define	l_loop		record
	vdrrprdat	like adimvdrrpr.vdrrprdat,
	vdrrprsrvcod	like adimvdrrpr.vdrrprsrvcod,
	vclvdrcod	like adimvdrrpr.vclvdrcod,
	vdrrprempnom	like adikvdrrpremp.vdrrprempnom
 end	record
 define	al_arr	array[500] of record
	vdrrprdat	like adimvdrrpr.vdrrprdat,
	vdrrprempnom	like adikvdrrpremp.vdrrprempnom,
	vidro		char(50),
	servico		char(50),
	casper		char(01)
 end	record
 define	l_ind		smallint,
	l_curarr	smallint,
	l_curscr	smallint,
	l_cursCr2	smallint,
	l_sql		char(1000)

 initialize al_arr to null

 open window w_ctx20g00
   at 8,2
      with form 'ctx20g00'
       attribute (form line first, border)

 error "Carregando os dados, por favor aguarde..."

 let l_sql = "select a.vdrrprdat,                     ",
             "       a.vdrrprsrvcod,                  ",
             "       a.vclvdrcod,                     ",
             "       b.vdrrprempnom                   ",
             "  from adimvdrrpr a, adikvdrrpremp b    ",
             " where a.vdrrprempcod = b.vdrrprempcod  ",
             "   and a.vdrrprdat   >= '", l_param.vigini, "'",
             "   and a.vdrrprdat   <= '", l_param.vigfnl, "'",
             "   and a.vclchsfnl    = '", l_param.vclchsfnl, "'"

 if l_param.vcllicnum is not null and
    l_param.vcllicnum <> " "      then
    let l_sql = l_sql clipped,
             "   and a.vcllicnum    = '", l_param.vcllicnum , "'"
 end if

 whenever error continue
 prepare p_ctx20g00_001 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Erro ", sqlca.sqlcode using "<<<<<&",
          " no prepare da tabela adimvdrrpr+adikvdrrpremp."
    close window w_ctx20g00
    return
 end if
 declare c_ctx20g00_001 cursor for p_ctx20g00_001

 let l_ind = 0
 foreach c_ctx20g00_001 into l_loop.*

     if l_ind > 50 then
        error "A consulta superou o limite. ",
              "Serao mostrados somente os 50 primeiros registros."
        exit foreach
     end if

     let l_ind = l_ind + 1

     let al_arr[l_ind].vdrrprdat    = l_loop.vdrrprdat
     let al_arr[l_ind].vdrrprempnom = l_loop.vdrrprempnom

     case l_loop.vclvdrcod
          when 1
               let al_arr[l_ind].vidro = "Para-brisa"
          when 2
               let al_arr[l_ind].vidro = "Vigia"
          when 3
               let al_arr[l_ind].vidro = "Lateral"
          when 4
               let al_arr[l_ind].vidro = "Oculo"
          when 5
               let al_arr[l_ind].vidro = "Quebra-vento"
          when 6
               let al_arr[l_ind].vidro = "Retrovisor"
          otherwise
               let al_arr[l_ind].vidro = "Cadastro Invalido"
     end case

     case l_loop.vdrrprsrvcod
          when 1
               let al_arr[l_ind].servico = "Troca"
          when 2
               let al_arr[l_ind].servico = "Reparo"
          otherwise
               let al_arr[l_ind].servico = "Cad Inv"
     end case
 end foreach

 call set_count(l_ind)

 if l_ind = 0 then
    error "Nenhum registro foi encontrado."
    sleep 2
    close window w_ctx20g00
    return
 end if

 error ""

 input array al_arr without defaults from s_ctx20g00.*
       before row
            let l_curarr = arr_curr()
            let l_curscr = scr_line()

            let l_curscr2 = l_curscr + 2

            display "                                                                             "  at l_curscr2, 2
                              attribute (reverse)
            display al_arr[l_curarr].* to s_ctx20g00[l_curscr].*
                                                 attribute (reverse)
       after row
            if fgl_lastkey() <> fgl_keyval("up")   and
               fgl_lastkey() <> fgl_keyval("left") and
               al_arr[l_curarr+1].vdrrprdat is null then
               error " There are no more rows in the direction you are going "
               next field casper
            end if
            display "                                                                             "  at l_curscr2, 2
            display al_arr[l_curarr].* to s_ctx20g00[l_curscr].*
       after field casper
            let al_arr[l_curarr].casper = ""
            display al_arr[l_curarr].casper to s_ctx20g00[l_curscr].casper

       on key (f17, interrupt)
            exit input
 end input

 close window w_ctx20g00

 let int_flag = false

end function
