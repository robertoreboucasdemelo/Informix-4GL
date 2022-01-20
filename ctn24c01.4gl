###############################################################################
# Modulo.........: ctn24c01                                                   #
# OSF............: 8508                                                       #
# Objetivo.......: Pesquisar Prestadores/Socorristas                          #
# Analista Resp..: Wagner Agostinho                                           #
# Desenvolvimento: Leandro - Fabrica de Software                              #
# Data...........: 30/10/2002                                                 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 20/11/2002  PSI 151734   Wagner       Inclusao novo tipo de pesquisa        #
###############################################################################


database porto

#-----------------------------------------------------------------------------#
function ctn24c01()
#-----------------------------------------------------------------------------#

 define d_ctn24c01   record
        nomepsq      char(40),
        tipo         char(01),
        sglveiculo   char(05),
        nomveiculo   char(40),
        socorcod     like dattfrotalocal.srrcoddig,
        socornom     char(40),
        pstcoddig    like dpaksocor.pstcoddig
 end record

 define a_ctn24c01   array[200] of record
        atdprscod    like datmservico.atdprscod,
        nomgrr       char(40),
        qualid       char(12),
        atdvclsgl    like datkveiculo.atdvclsgl,
        vcldes       char(40),
        c24atvcod    like dattfrotalocal.c24atvcod,
        srrcoddig    like dattfrotalocal.srrcoddig,
        srrabvnom    char(40),
        socvclcod    like datkveiculo.socvclcod
 end record

 define l_sql        char(1000),
        l_pstcoddig  like datkveiculo.pstcoddig,
        l_vclcoddig  like datkveiculo.vclcoddig,
        l_atdvclsgl  like datkveiculo.atdvclsgl,
        l_srrcoddig  decimal(8,0),
        l_socvclcod  like datkveiculo.socvclcod,
        l_arr        smallint,
        l_flag       smallint

 define ws            record
        qldgracod     like dpaksocor.qldgracod,
        qualid        char(12),
        nomepsq       char(36),
        varia_int           smallint
 end record

 define arr_aux       smallint
 define aux_contpsq   smallint


	define	w_pf1	integer

	let	l_sql  =  null
	let	l_pstcoddig  =  null
	let	l_vclcoddig  =  null
	let	l_atdvclsgl  =  null
	let	l_srrcoddig  =  null
	let	l_socvclcod  =  null
	let	l_arr  =  null
	let	l_flag  =  null
	let	arr_aux  =  null
	let	aux_contpsq  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctn24c01[w_pf1].*  to  null
	end	for

	initialize  d_ctn24c01.*  to  null

	initialize  ws.*  to  null

 let aux_contpsq        = 0

 open window w_ctn24c01 at 09,07 with form "ctn24c01"
      attribute(border, form line first)

     while true

       initialize d_ctn24c01.* to null
       initialize a_ctn24c01 to null
       clear form
       let int_flag    = false
       let l_arr       = 1
       let l_pstcoddig = 0
       let ws.varia_int      = 0

       input by name d_ctn24c01.*  without defaults

          before field nomepsq
             display by name d_ctn24c01.nomepsq

          after  field nomepsq
             if d_ctn24c01.nomepsq is null then
                next field sglveiculo
             end if

          before field tipo
             display by name d_ctn24c01.tipo

          after  field tipo
             display by name d_ctn24c01.tipo

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field nomepsq
             end if

             if d_ctn24c01.nomepsq is not null   and
                d_ctn24c01.tipo    is null       then
                error "Tipo de pesquisa e' item obrigatorio G, R ou P !"
                next field tipo
             end if

             if d_ctn24c01.tipo <> "G" and
                d_ctn24c01.tipo <> "R" and
                d_ctn24c01.tipo <> "P" then
                error "Tipo de pesquisa invalido - informe G, R ou P !"
                next field tipo
             end if

             if d_ctn24c01.tipo  is not null   then
                if d_ctn24c01.tipo = "P"       and
                   aux_contpsq      <  1        then
                   error "Deve pesquisar por Razao ou Guerra antes!"
                   next field tipo
                else
                   if d_ctn24c01.tipo = "P" then
                      let ws.varia_int      = (length (d_ctn24c01.nomepsq))
                      if  ws.varia_int      < 4  then
                          error "Minimo de 4 letras para pesquisar!"
                          next field nomepsq
                      end if
                      let ws.nomepsq = "*", d_ctn24c01.nomepsq clipped, "*"
                   else
                      let ws.nomepsq = d_ctn24c01.nomepsq clipped, "*"
                   end if
                end if
                exit input
             end if

          before field sglveiculo
             display by name d_ctn24c01.sglveiculo

          after  field sglveiculo
             display by name d_ctn24c01.sglveiculo

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                if d_ctn24c01.tipo  is not null  then
                   next field tipo
                else
                   next field nomepsq
                end if
             end if

             if d_ctn24c01.sglveiculo is not null then
                select vclcoddig, socvclcod, pstcoddig
                  into l_vclcoddig, l_socvclcod, l_pstcoddig
                  from datkveiculo
                 where atdvclsgl = d_ctn24c01.sglveiculo

                if sqlca.sqlcode = 0 then
                   if l_vclcoddig is not null then
                      call cts15g00(l_vclcoddig)
                          returning d_ctn24c01.nomveiculo
                   end if

                   select srrcoddig
                     into d_ctn24c01.socorcod
                     from dattfrotalocal
                    where socvclcod = l_socvclcod

                   select srrabvnom
                     into d_ctn24c01.socornom
                     from datksrr
                    where srrcoddig = d_ctn24c01.socorcod

                   if l_pstcoddig is not null then
                      select nomrazsoc, pstcoddig
                        into d_ctn24c01.nomepsq, d_ctn24c01.pstcoddig
                        from dpaksocor
                       where pstcoddig =  l_pstcoddig
                   end if

                   display by name d_ctn24c01.nomepsq
                   display by name d_ctn24c01.sglveiculo
                   display by name d_ctn24c01.nomveiculo
                   display by name d_ctn24c01.socorcod
                   display by name d_ctn24c01.socornom
                   display by name d_ctn24c01.pstcoddig
                   exit input
                else
                   error "Sigla do veiculo nao existe !"
                   next field sglveiculo
                end if
             end if

          before field socorcod
             display by name d_ctn24c01.socorcod

          after  field socorcod
             display by name d_ctn24c01.socorcod

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                 next field sglveiculo
             end if

             if d_ctn24c01.socorcod is not null then
                select srrabvnom
                  into d_ctn24c01.socornom
                  from datksrr
                 where srrcoddig = d_ctn24c01.socorcod

                if sqlca.sqlcode = 0 then
                   declare c_ctn24c01_001 cursor for
                    select socvclcod
                      from dattfrotalocal
                     where srrcoddig = d_ctn24c01.socorcod

                   foreach c_ctn24c01_001 into l_socvclcod
                      select atdvclsgl , vclcoddig, pstcoddig
                        into d_ctn24c01.sglveiculo,  l_vclcoddig, l_pstcoddig
                        from datkveiculo
                       where socvclcod = l_socvclcod
                      exit foreach
                   end foreach

                   if l_vclcoddig is not null then
                      call cts15g00(l_vclcoddig)
                          returning d_ctn24c01.nomveiculo
                   end if

                   if l_pstcoddig is not null then
                      select nomrazsoc, pstcoddig
                        into d_ctn24c01.nomepsq, d_ctn24c01.pstcoddig
                        from dpaksocor
                       where pstcoddig =  l_pstcoddig
                   end if

                   display by name d_ctn24c01.nomepsq
                   display by name d_ctn24c01.sglveiculo
                   display by name d_ctn24c01.nomveiculo
                   display by name d_ctn24c01.socorcod
                   display by name d_ctn24c01.socornom
                   display by name d_ctn24c01.pstcoddig
                   exit input
                else
                   error "Socorrista nao existe !"
                   next field socorcod
                end if
             end if

          before field pstcoddig
             display by name d_ctn24c01.pstcoddig

          after  field pstcoddig
             display by name d_ctn24c01.pstcoddig

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field socorcod
             end if

             if d_ctn24c01.pstcoddig is  not null then
                select nomrazsoc, pstcoddig
                  into d_ctn24c01.nomepsq, l_pstcoddig
                  from dpaksocor
                 where pstcoddig =  d_ctn24c01.pstcoddig

                if sqlca.sqlcode = 0 then
                   display by name d_ctn24c01.nomepsq
                   display by name d_ctn24c01.sglveiculo
                   display by name d_ctn24c01.nomveiculo
                   display by name d_ctn24c01.socorcod
                   display by name d_ctn24c01.socornom
                   display by name d_ctn24c01.pstcoddig
                   exit input
                else
                   error " Prestador nao existe !"
                   next field pstcoddig
                end if
             else
                error " Favor selecionar no minimo um item para pesquisa!"
                next field nomepsq
             end if

          on key (interrupt)
             exit input

       end input

       if int_flag   then
          exit while
       end if

       display by name d_ctn24c01.*

       #------------------
       # MONTA PESQUISA
       #------------------
       if d_ctn24c01.sglveiculo <> ' ' then
          let l_sql = " select a.socvclcod, a.atdvclsgl, b.pstcoddig, ",
                             " a.vclcoddig, b.nomrazsoc  ",
                      " from  dpaksocor b, datkveiculo a ",
                      " where a.pstcoddig = b.pstcoddig "
       else
          let l_sql = " select a.socvclcod, a.atdvclsgl, b.pstcoddig, ",
                             " a.vclcoddig, b.nomrazsoc  ",
                      " from  dpaksocor b, outer datkveiculo a ",
                      " where a.pstcoddig = b.pstcoddig "
       end if

       if l_pstcoddig > 0 then
          let l_sql = l_sql clipped, " and b.pstcoddig = ", l_pstcoddig
       else
          if d_ctn24c01.nomepsq is not null then
             if d_ctn24c01.tipo = "G" then
                let  l_sql = l_sql clipped, " and b.nomgrr matches '*",
                                              d_ctn24c01.nomepsq clipped, "*'"
             else
                let  l_sql = l_sql clipped, " and b.nomrazsoc matches '*",
                                              d_ctn24c01.nomepsq clipped, "*'"
             end  if
          end  if
       end if

       if d_ctn24c01.sglveiculo is not null then
          let l_sql = l_sql clipped," and a.atdvclsgl = '",
                                      d_ctn24c01.sglveiculo clipped, "'"
       end if

       message " Aguarde, pesquisando..."  attribute(reverse)
       prepare p_ctn24c01_001 from l_sql
       declare c_ctn24c01_002 cursor for p_ctn24c01_001


       let l_sql = " select pstcoddig, qldgracod ",
                   " from dpaksocor ",
                   " where nomrazsoc = ? "
       prepare p_ctn24c01_002 from l_sql
       declare c_ctn24c01_003 cursor for p_ctn24c01_002


       let l_sql = " select srrcoddig, c24atvcod ",
                   " from dattfrotalocal ",
                   " where socvclcod = ? "
       prepare p_ctn24c01_003 from l_sql
       declare c_ctn24c01_004 cursor for p_ctn24c01_003


       let l_sql = " select srrabvnom ",
                   " from datksrr ",
                   " where srrcoddig = ? "
       prepare p_ctn24c01_004 from l_sql
       declare c_ctn24c01_005 cursor for p_ctn24c01_004

       open  c_ctn24c01_003 using d_ctn24c01.nomepsq
       fetch c_ctn24c01_003 into  a_ctn24c01[l_arr].atdprscod, ws.qldgracod
       close c_ctn24c01_003

       select cpodes
         into ws.qualid
         from iddkdominio
        where iddkdominio.cponom = "qldgracod"
          and iddkdominio.cpocod = ws.qldgracod

       initialize a_ctn24c01 to null
       let l_arr = 1

       open    c_ctn24c01_002
       foreach c_ctn24c01_002 into  a_ctn24c01[l_arr].socvclcod,
                                   a_ctn24c01[l_arr].atdvclsgl,
                                   a_ctn24c01[l_arr].atdprscod,
                                   l_vclcoddig,
                                   a_ctn24c01[l_arr].nomgrr

          if a_ctn24c01[l_arr].nomgrr is null or
             a_ctn24c01[l_arr].nomgrr = ""    then
             continue foreach
          end if

          if a_ctn24c01[l_arr].atdvclsgl is null or
             a_ctn24c01[l_arr].atdvclsgl = ""    then
          else
             call cts15g00(l_vclcoddig) returning a_ctn24c01[l_arr].vcldes
          end if

          open  c_ctn24c01_004 using a_ctn24c01[l_arr].socvclcod
          fetch c_ctn24c01_004 into  a_ctn24c01[l_arr].srrcoddig,
                                    a_ctn24c01[l_arr].c24atvcod
          close c_ctn24c01_004


          open  c_ctn24c01_005 using a_ctn24c01[l_arr].srrcoddig
          fetch c_ctn24c01_005 into  a_ctn24c01[l_arr].srrabvnom
          close c_ctn24c01_005

          let a_ctn24c01[l_arr].qualid = ws.qualid

          let l_arr = l_arr + 1
          if l_arr  >  200    then
             error " Limite excedido, pesquisa com mais de 200 prestadores !"
             exit foreach
          end if

       end foreach

       message ""
       if l_arr > 1 then
          message " (F17)Abandona, (F8)Seleciona "
          call set_count(l_arr - 1)

          let l_flag = false
          display array  a_ctn24c01 to s_ctn24c01.*

             on key(f8)
                let l_flag = true
                let l_arr = arr_curr()
                exit display

          end display
          if l_flag then
             close window  w_ctn24c01
             return a_ctn24c01[l_arr].atdprscod,
                    a_ctn24c01[l_arr].srrcoddig,
                    a_ctn24c01[l_arr].atdvclsgl,
                    a_ctn24c01[l_arr].socvclcod
          end if
       else
          error " Nao foi encontrado nenhum prestador para pesquisa!"
       end if

    end while

    let int_flag = false

 close window  w_ctn24c01

 return a_ctn24c01[l_arr].atdprscod,
        a_ctn24c01[l_arr].srrcoddig,
        a_ctn24c01[l_arr].atdvclsgl,
        a_ctn24c01[l_arr].socvclcod

end function  ###  ctn24c01

