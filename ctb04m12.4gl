#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : PORTO SOCORRO                                               #
# Modulo         : ctb04m12                                                    #
#                  Tela para informar e gravar  o rateio das despesas dos      #
#                  servicos por centro de custo.                               #
# Analista Resp. : Carlos Zyon                                                 #
#..............................................................................#
# Desenvolvimento: Fabrica de Software, JUNIOR                                 #
# OSF            : 35050                                                       #
# PSI            : 182516                                                      #
# Liberacao      :                                                             #
#..............................................................................#
#                           * * *  ALTERACOES  * * *                           #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 12/04/2005 Adriana, Meta     PSI191167  Unificacao do acesso as tabelas de   #
#                                         centro de custos                     #
################################################################################
database porto

define m_ctb04m12 record
  empcod     like dbsmcctrat.empcod,
  succod     like dbsmcctrat.succod
end record

define a_ctb04m12 array[08] of record
  cctcod      like dbsmcctrat.cctcod   ,
  cctnom      like ctokcentrosuc.cctnom,
  cctratvlr   like dbsmcctrat.cctratvlr
end record

define arr_aux   integer
define scr_aux   integer
define vr_total  dec(15,5)
define w_log     char(60)

#--------------------------------------------------------------------------#
{
main

defer interrupt
call ctb04m12(04,1000715,04,2350.00)

end main
}

#--------------------------------------------------------------------------#
#------------   P R E P A R A N D O   C U R S O R E S  --------------------#
#--------------------------------------------------------------------------#
function ctb04m12_seleciona_sql()
#--------------------------------------------------------------------------#
define l_cmd char(800)

    ### // Monta cursor principal para input dos campos abaixo //

    let l_cmd = " select cctcod, cctratvlr   "
               ,"   from dbsmcctrat  "
               ," where  atdsrvnum = ? "
               ,"   and  atdsrvano = ? "

    prepare pctb04m12001 from l_cmd
    declare cctb04m12001 cursor for pctb04m12001


    ### // Inclui registro na tabela dbsmcctrat //

    let l_cmd = " insert into dbsmcctrat "
               ," values(?,?,1,1,?,?) "
    prepare ictb04m12001 from l_cmd


    let l_cmd = "update dbsmcctrat set cctratvlr  = ? "
           ," where atdsrvnum = ? "
           ,"   and atdsrvano = ? "
           ,"   and empcod    = 1 "
           ,"   and succod    = 1 "
           ,"   and cctcod    = ? "

    prepare uctb04m12001 from l_cmd

    ### // Monta cursor para verificacao de registro ja existente //

    let l_cmd = " select * from dbsmcctrat   "
               ," where atdsrvnum = ? "
               ,"   and atdsrvano = ? "
               #,"   and empcod    = 1 "
               #,"   and succod    = 1 "
               ,"   and cctcod    = ? "

    prepare pctb04m12003 from l_cmd
    declare cctb04m12003 cursor for pctb04m12003

    let l_cmd = " select cctcod from dbscadtippgt ",
                " where  nrosrv = ? ",
                " and  anosrv = ? ",
                " and pgttipcodps = 3"

    prepare pctb04m12004 from l_cmd
    declare cctb04m12004 cursor for pctb04m12004


end function
#--------------------------------------------------------------------------#
function ctb04m12(l_param)
#--------------------------------------------------------------------------#

define l_param record
  atdsrvorg      like datmservico.atdsrvorg,
  atdsrvnum      like dbsmcctrat.atdsrvnum,
  atdsrvano      like dbsmcctrat.atdsrvano,
  valortotal     dec (15,5)
end record

define i          smallint
define p          smallint
define l_pos      smallint

define l_aux record
  atdsrvnum  like dbsmcctrat.atdsrvnum,
  atdsrvano  like dbsmcctrat.atdsrvano,
  empcod     like dbsmcctrat.empcod   ,
  succod     like dbsmcctrat.succod   ,
  cctcod     like dbsmcctrat.cctcod   ,
  cctratvlr  like dbsmcctrat.cctratvlr
end record

 define lr_param record
        empcod    like ctgklcl.empcod,       --Empresa
        succod    like ctgklcl.succod,       --Sucursal
        cctlclcod like ctgklcl.cctlclcod,    --Local
        cctdptcod like ctgrlcldpt.cctdptcod  --Departamento
 end record

 define lr_ret record
        erro          smallint, ## 0-Ok,1-erro
        mens          char(40),
        cctlclnom     like ctgklcl.cctlclnom,       ##Nome do local
        cctdptnom     like ctgkdpt.cctdptnom,       ##Nome do departamento (antigo cctnom)
        cctdptrspnom  like ctgrlcldpt.cctdptrspnom, ##Responsavel pelo  departamento
        cctdptlclsit  like ctgrlcldpt.cctdptlclsit, ##Situagco do depto (A)tivo ou (I)nativo
        cctdpttip     like ctgkdpt.cctdpttip        ##Tipo de departamento
end record


define ws record
	cctcod like dbscadtippgt.cctcod
end record

initialize a_ctb04m12 to null
initialize ws.* to null
initialize l_aux.* to null
initialize lr_ret.* to null


let w_log = f_path("ONLTEL","LOG")
if w_log is null then
   let w_log = "."
end if
let w_log = w_log clipped,"/dbs_ctb04m12.log"

call startlog(w_log)
call ctb04m12_seleciona_sql()

open window w_ctb04m12 at 4,2 with form "ctb04m12"
     attribute(message line last,prompt line last)
     display by name l_param.*
     let arr_aux = 1

     open cctb04m12001 using l_param.atdsrvnum,
                             l_param.atdsrvano
     foreach cctb04m12001 into a_ctb04m12[arr_aux].cctcod,
               	               a_ctb04m12[arr_aux].cctratvlr

		if a_ctb04m12[arr_aux].cctcod is null or a_ctb04m12[arr_aux].cctcod = 0 then
			initialize a_ctb04m12[arr_aux].* to null
			exit foreach
		else
     			let lr_param.empcod    = 1
        		let lr_param.succod    = 1
        		let lr_param.cctlclcod = (a_ctb04m12[arr_aux].cctcod / 10000)
        		let lr_param.cctdptcod = (a_ctb04m12[arr_aux].cctcod mod 10000)
        		call fctgc102_vld_dep(lr_param.*) returning lr_ret.*
        		if lr_ret.erro <> 0 then
           			error "Nome do CENTRO DE CUSTO nao encontrado !!!"
           			continue foreach
        		end if
        		let a_ctb04m12[arr_aux].cctnom = lr_ret.cctdptnom
		end if
        ## Fim


        let arr_aux = arr_aux + 1

     end foreach

     if a_ctb04m12[arr_aux].cctcod is null or a_ctb04m12[arr_aux].cctcod = 0 then
	let arr_aux = 1

     	open cctb04m12004 using l_param.atdsrvnum, l_param.atdsrvano
     	fetch cctb04m12004 into ws.cctcod
     	close cctb04m12004
     	if ws.cctcod is not null and ws.cctcod <> 0 then
     			let a_ctb04m12[arr_aux].cctcod = ws.cctcod
     			let lr_param.empcod    = 1
        		let lr_param.succod    = 1
        		let lr_param.cctlclcod = (a_ctb04m12[arr_aux].cctcod / 10000)
        		let lr_param.cctdptcod = (a_ctb04m12[arr_aux].cctcod mod 10000)
        		call fctgc102_vld_dep(lr_param.*) returning lr_ret.*
        		if lr_ret.erro <> 0 then
	           		error "Nome do CENTRO DE CUSTO nao encontrado !!!"
        		end if
        		let a_ctb04m12[arr_aux].cctnom = lr_ret.cctdptnom

      	end if

	let arr_aux = arr_aux + 1

     end if

     call set_count(arr_aux-1)

   options
      insert key f25,
      delete key f2

   input array a_ctb04m12 without defaults from s_ctb04m12.*

     before row
        let arr_aux = arr_curr()
        let Scr_aux = scr_line()

     before field cctcod
     	if ws.cctcod is not null and ws.cctcod <> 0 then
     		next field cctratvlr
     	end if

     after field cctcod

           if a_ctb04m12[arr_aux].cctcod is null and ws.cctcod is null then
              if fgl_lastkey() = fgl_keyval("down")    or
                 fgl_lastkey() = fgl_keyval("right")  or
                 fgl_lastkey() = fgl_keyval("return") then
                 error "Campo deve ser preenchido !!! "
                 next field cctcod
              end if
           else
		let lr_param.empcod    = 1
             	let lr_param.succod    = 1
             	let lr_param.cctlclcod = (a_ctb04m12[arr_aux].cctcod / 10000)
             	let lr_param.cctdptcod = (a_ctb04m12[arr_aux].cctcod mod 10000)
             	call fctgc102_vld_dep(lr_param.*)returning lr_ret.*
             	if lr_ret.erro <> 0 then
                	error "Nome do CENTRO DE CUSTO nao encontrado !!!"
                	sleep 2
                	next field cctcod
             	end if

             	let a_ctb04m12[arr_aux].cctnom = lr_ret.cctdptnom
           end if

           display a_ctb04m12[arr_aux].cctnom to s_ctb04m12[scr_aux].cctnom
           if ws.cctcod is not null and ws.cctcod <> 0 then
           	next field cctratvlr
           end if


     after field cctratvlr

           if a_ctb04m12[arr_aux].cctratvlr is null or
              a_ctb04m12[arr_aux].cctratvlr < 0 then
              error "Valor invalido !!! "
              next field cctratvlr
          end if


     before delete

		if ws.cctcod is null or ws.cctcod = 0 then
			let l_pos = arr_curr()
         		let scr_aux = scr_line()

         		delete from dbsmcctrat
           		where atdsrvnum = l_param.atdsrvnum
             		and atdsrvano = l_param.atdsrvano
             		and empcod    = 1
             		and succod    = 1
             		and cctcod    = a_ctb04m12[l_pos].cctcod
             		and cctratvlr = a_ctb04m12[l_pos].cctratvlr
         		error "linha excluida ....  "
      		else
      			error "Delecao nao permitida"
      			display a_ctb04m12[arr_aux].cctcod to s_ctb04m12[scr_aux].cctcod
         		display a_ctb04m12[arr_aux].cctnom to s_ctb04m12[scr_aux].cctnom
         		display a_ctb04m12[arr_aux].cctratvlr to s_ctb04m12[scr_aux].cctratvlr
      		end if

     on key (f8)

     let vr_total = 0

     for i = 1 to 8

         if a_ctb04m12[i].cctcod is null or
            a_ctb04m12[i].cctcod = 0     or
            a_ctb04m12[i].cctratvlr is null or
            a_ctb04m12[i].cctratvlr = 0     then
            exit for
         end if

         let vr_total = vr_total + a_ctb04m12[i].cctratvlr

     end for


     if vr_total <> l_param.valortotal then
        error "Valor incorreto !!! "
        next field cctratvlr
     end if

     for p = 1 to 8
         if a_ctb04m12[p].cctcod is null or
            a_ctb04m12[p].cctcod = 0     then
            exit for
         end if

       whenever error continue
       open cctb04m12003 using l_param.atdsrvnum,
                               l_param.atdsrvano,
                               a_ctb04m12[p].cctcod
       fetch cctb04m12003 into l_aux.atdsrvnum,
                               l_aux.atdsrvano,
                               l_aux.empcod   ,
                               l_aux.succod   ,
                               l_aux.cctcod   ,
                               l_aux.cctratvlr

           whenever error stop
           if sqlca.sqlcode = 0 then
              whenever error continue
              execute uctb04m12001 using a_ctb04m12[p].cctratvlr,
                                         l_param.atdsrvnum,
                                         l_param.atdsrvano,
                                         a_ctb04m12[p].cctcod
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "OCORREU UM ERRO EM uctb04m12001 , ", sqlca.sqlcode
                 exit input
              end if
           else
              whenever error continue
              execute ictb04m12001 using l_param.atdsrvnum,
                                         l_param.atdsrvano,
                                         a_ctb04m12[p].cctcod,
                                         a_ctb04m12[p].cctratvlr
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "OCORREU UM ERRO EM ictb04m12001 , ", sqlca.sqlcode
                 sleep 2
                 exit input
              end if
           end if
     end for
     exit input

     on key (f17,interrupt)

     let vr_total = 0

     for i = 1 to 8

         if a_ctb04m12[i].cctcod is null or
            a_ctb04m12[i].cctcod = 0     or
            a_ctb04m12[i].cctratvlr is null or
            a_ctb04m12[i].cctratvlr = 0     then
            exit for
         end if

         let vr_total = vr_total + a_ctb04m12[i].cctratvlr

     end for


     if a_ctb04m12[i].cctcod is null then
        if vr_total <> 0 then
           if vr_total <> l_param.valortotal then
              error "Valor incorreto !!! "
              let int_flag = false
              next field cctratvlr
           end if
        else
           exit input
        end if
     end if

   end input

  close window w_ctb04m12

end function

