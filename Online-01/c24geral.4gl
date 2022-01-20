##########################################################################
#                                                                        #
# Funcoes gerais do sistema CENTRAL 24 HORAS                             #
#                                                                        #
##########################################################################
#........................................................................#
#                                                                        #
#                  * * *  ALTERACOES  * * *                              #
#                                                                        #
# Data        Autor Fabrica  Data   Alteracao                            #
# ----------  -------------  ------ ------------------------------------ #
# 15/04/2004  Cesar Lucca           CT 200840                            #
#                                   Na função 'c24geral10()' alterar o   #
#                                   array a_c24geral10 para 300 posições #
# ---------------------------------------------------------------------- #
# 30/04/2008 Norton Nery            psi221112 - Mudanca no nome da       #
#                                               Tabela gtakram          #
# ---------------------------------------------------------------------- #

##globals  "/homedsa/fontes/ct24h/producao/glct.4gl"
globals  "/homedsa/projetos/geral/globals/glct.4gl"
#----------------------------------------
 function C24GERAL_TRATSTR(g_nome,g_compr)
#----------------------------------------
# Recebe : String e Comprimento da String
# Retorna: String apos o primeiro branco encontrado

   define g_nome    char (40)
   define g_retnome char (40)
   define g_compr   smallint
   define i         smallint


	let	g_retnome  =  null
	let	i  =  null

   let i = 1

   if (g_nome is null  or  g_nome = " ")  then
      initialize g_retnome to null
      return g_retnome
   end if

   for i = 1 to g_compr step 1
       if (g_nome[i,i] is null   or  g_nome[i,i] = " ")  then
           let g_retnome = g_nome[i + 1, g_compr]
           exit for
       end if
   end for

   return g_retnome

end function

#----------------------------------------
 function C24GERAL_TRATBRC(g_nome)
#----------------------------------------
# Recebe : String
# Retorna: String ATE' o primeiro branco encontrado

   define g_nome    char (40)
   define g_retnome char (40)
   define g_compr   smallint
   define i         smallint


	let	g_retnome  =  null
	let	g_compr  =  null
	let	i  =  null

   let i = 1
   let g_compr = length(g_nome)

   if (g_nome is null  or  g_nome = " ")  then
      initialize g_retnome to null
      return g_retnome
   end if

   for i = 1 to g_compr step 1
       if g_nome[i,i] = " "  then
          exit for
       else
          let g_retnome = g_retnome clipped, g_nome[i,i]
       end if
   end for

   return g_retnome

end function

#-----------------------------------------------------------------------------
 function c24geral4()
#-----------------------------------------------------------------------------
# Objetivo..: Pop-up de cores de veiculo
# Parametros: Nenhum
# Retorno...: CPOCOD    - Codigo da Cor
#             CPODES    - Descricao da Cor
# Alteracao.: 18/03/1998
#-----------------------------------------------------------------------------

 define a_cor array[30] of record
    cpodes    like iddkdominio.cpodes,
    cpocod    like iddkdominio.cpocod
 end record

 define arr_aux      smallint

 define w_cpocod     like iddkdominio.cpocod
 define w_cpodes     like iddkdominio.cpodes


	define	w_pf1	integer

	let	arr_aux  =  null
	let	w_cpocod  =  null
	let	w_cpodes  =  null

	for	w_pf1  =  1  to  30
		initialize  a_cor[w_pf1].*  to  null
	end	for

open window W_COR at 08,40 with form "C24geral4"
     attribute(border, form line first)

let int_flag = false

let arr_aux  = 1

declare c_c24geral_001 cursor for
 select cpodes, cpocod
   from iddkdominio
  where cponom = "vclcorcod"
  order by cpodes

foreach c_c24geral_001 into a_cor[arr_aux].*
   let arr_aux = arr_aux + 1
   if arr_aux > 30  then
      message "Limite excedido! Foram encontradas mais de 30 cores!"
      exit foreach
   end if
end foreach

call set_count(arr_aux - 1)
message " (F17)Abandona, (F8)Seleciona"

display array a_cor to s_c24geral4.*
   on key (interrupt)
        exit display

   on key (F8)
      let arr_aux = arr_curr()
      exit display
end display

if int_flag then
   let int_flag = false
else
   let w_cpocod = a_cor[arr_aux].cpocod
   let w_cpodes = a_cor[arr_aux].cpodes
end if

close window w_cor

return w_cpocod, w_cpodes

end function  ###  c24geral4

#-----------------------------------------------------------------------------
 function c24geral5(par_prpnum)         # CALCULA DIGITO PROPOSTA/CARTAO
#-----------------------------------------------------------------------------
define par_prpnum     dec (7,0)

define w_tamanho      decimal(2,0)
define w_prpcalculado decimal(16)
define w_prpnum       dec (15,0)
define w_prpcmp       dec (7,1)
define w_numero       integer
define w_resp         char(1)



	let	w_tamanho  =  null
	let	w_prpcalculado  =  null
	let	w_prpnum  =  null
	let	w_prpcmp  =  null
	let	w_numero  =  null
	let	w_resp  =  null

let w_tamanho  =  15
let w_prpnum   =  391000000000000.0
let w_resp     =  "s"
let w_prpcmp   = par_prpnum / 10
let w_numero   = w_prpcmp
let w_prpnum   = w_prpnum + w_numero

call f_fundigit_mod10(w_prpnum, w_tamanho)
                      returning w_prpcalculado
let w_prpcalculado = w_prpcalculado - 3910000000000000.0

if par_prpnum  <>  w_prpcalculado   then
   let w_resp  =  "n"
end if

return w_resp

end function  # c24geral5

#-----------------------------------------------------------------------------
 function c24geral8(param)
#-----------------------------------------------------------------------------
# Objetivo..: Monta descricao do assunto
# Parametros: C24ASTCOD - Codigo do assunto
# Retorno...: ASTDES    - Descricao do assunto
# Alteracao.: 18/03/1998
#-----------------------------------------------------------------------------

 define param         record
    c24astcod         like datkassunto.c24astcod
 end record

 define ws            record
    c24astcod         like datkassunto.c24astcod,
    c24astagp         like datkassunto.c24astagp,
    c24agpdes         like datkastagp.c24astagpdes ,
    c24astdes         like datkassunto.c24astdes,
    astdes            char (72)
 end record



	initialize  ws.*  to  null

 initialize ws.*  to null

 select c24astdes, c24astagp
   into ws.c24astdes, ws.c24astagp
   from datkassunto
  where c24astcod = param.c24astcod

 if sqlca.sqlcode = notfound  then
    let ws.astdes = "ASSUNTO NAO CADASTRADO"
 else
    select c24astagpdes
      into ws.c24agpdes
      from datkastagp
     where c24astagp = ws.c24astagp

    let ws.astdes = ws.c24agpdes clipped, " ", ws.c24astdes
 end if

 return ws.astdes

end function  ###  c24geral8

#-----------------------------------------------------------------------------
 function c24geral9 (param)
#-----------------------------------------------------------------------------
# Objetivo..: Obtem proxima data que nao seja feriado
# Parametros: INCDAT    - Data Inicial
#             DIAQTD    - Quant. de Dias
#             ENDCEP    - CEP
#             FERBCOFLG - Flag: Feriado Bancario
#             FEREMPFLG - Flag: Feriado na Empresa (Porto Seguro)
# Retorno...: RETDAT    - Data em que nao seja feriado
# Alteracao.: 18/03/1998
#-----------------------------------------------------------------------------

 define param        record
    incdat           date     ,
    diaqtd           smallint ,
    endcep           char (05),
    ferbcoflg        char (01),
    ferempflg        char (01)
 end record

 define ws           record
    retdat           date,
    contador         smallint
 end record

 define i            smallint

 define sql_comando  char (200)


	let	i  =  null
	let	sql_comando  =  null

	initialize  ws.*  to  null

 initialize ws.* to null

 if param.incdat is null        or
    param.incdat < "01/01/1990" or
    param.diaqtd is null        or
    param.diaqtd > 1000         then
    initialize ws.retdat  to null
    return ws.retdat
 end if

 let i = 1
 let ws.contador = 1

 let ws.retdat = param.incdat

 if param.diaqtd <> 0  then
    if param.diaqtd < 0 then
       let i = -1
    end if
    let ws.retdat = ws.retdat + i units day
 end if

 let sql_comando = "select distinct(ferdia) from igfkferiado",
                   " where ferdia = ? and (fertip = 'N' "

 if param.ferbcoflg = 'S'  then
    let sql_comando = sql_comando clipped, " or fertip = 'B' "
 end if
 if param.ferempflg = 'S' then
    let sql_comando = sql_comando clipped, " or fertip = 'P' "
 end if
 let sql_comando = sql_comando clipped, " ) "

 prepare p_c24geral_001 from sql_comando
 declare c_c24geral_002 cursor for p_c24geral_001

 while true
    open  c_c24geral_002 using ws.retdat
    fetch c_c24geral_002
    if sqlca.sqlcode <> 0  and  param.endcep is not null  then
       select ferdia from igfkferlocal
        where ferdia = ws.retdat     and
              cepinc <= param.endcep and
              cepfnl >= param.endcep
    end if
    if sqlca.sqlcode = 0  then
       let ws.retdat = ws.retdat + i units day
    else
       if ws.contador >= param.diaqtd * i then
          exit while
       end if
       let ws.contador = ws.contador + 1
       let ws.retdat = ws.retdat + i units day
    end if
    close c_c24geral_002
 end while

return ws.retdat

end function  ###  c24geral9

#-----------------------------------------------------------------------------
 function c24geral10()                   ####  RAMOS DE SEGURO
#-----------------------------------------------------------------------------

define a_c24geral10 array[300] of record #-- CT 200840
   ramcod like gtakram.ramcod,
   ramnom like gtakram.ramnom
end record

define arr_aux  smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  300 #-- CT 200840
		initialize  a_c24geral10[w_pf1].*  to  null
	end	for

open window w_c24geral10 at 10,27 with form "C24geral10"
   attribute (border,form line 1)

initialize a_c24geral10   to null

declare c_c24geral_003 cursor for
  select ramcod, ramnom
    from gtakram
   order by ramnom

   let arr_aux = 1
   foreach c_c24geral_003 into a_c24geral10[arr_aux].*
      let arr_aux = arr_aux + 1
      #-- CT 200840
      if arr_aux > 300 then
         message "Limite excedido. Foram encontrados mais de 300 ramos!"
         exit foreach
      end if
      #--
   end foreach

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_c24geral10 to gtakram.*
      on key (interrupt,control-c)
         initialize a_c24geral10 to null
         let arr_aux = 1
         exit display

      on key (f8)
         let arr_aux = arr_curr()
         exit display
   end display

close window w_c24geral10
let int_flag = false
return a_c24geral10[arr_aux].ramcod, a_c24geral10[arr_aux].ramnom

end function  #  c24geral10

#-----------------------------------------------------------------------------
 function c24geral11()                   ####  SUCURSAIS
#-----------------------------------------------------------------------------

define a_c24geral11 array[50] of record
   succod like gabksuc.succod,
   sucnom like gabksuc.sucnom
end record

define arr_aux  smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_c24geral11[w_pf1].*  to  null
	end	for

open window w_c24geral11 at 10,27 with form "C24geral11"
   attribute (border,form line 1)

initialize a_c24geral11   to null

declare c_c24geral_004 cursor for
  select succod, sucnom
    from gabksuc
   order by sucnom

let arr_aux = 1
foreach c_c24geral_004 into a_c24geral11[arr_aux].*
   let arr_aux = arr_aux + 1
   if arr_aux > 50  then
      message "Limite excedido. Existem mais de 50 sucursais!"
      exit foreach
   end if
end foreach

message " (F17)Abandona, (F8)Seleciona"
call set_count(arr_aux-1)

display array a_c24geral11 to gabksuc.*
   on key (interrupt,control-c)
      initialize a_c24geral11 to null
      let arr_aux = 1
      exit display

   on key (f8)
      let arr_aux = arr_curr()
      exit display
end display

close window w_c24geral11
let int_flag = false
return a_c24geral11[arr_aux].succod, a_c24geral11[arr_aux].sucnom

end function  #  c24geral11

#-----------------------------------------------------------------------------
 function c24geral12(par_data)
#-----------------------------------------------------------------------------

 define par_data    date

 define ws          record
    dia             smallint,
    diasem          char(07)
 end record



	initialize  ws.*  to  null

 initialize ws.* to null

 if par_data is null  then
    return ws.diasem
 end if

 let ws.dia = weekday(par_data)

 case ws.dia
    when  0   let ws.diasem = "DOMINGO"
    when  1   let ws.diasem = "SEGUNDA"
    when  2   let ws.diasem = "TERCA"
    when  3   let ws.diasem = "QUARTA"
    when  4   let ws.diasem = "QUINTA"
    when  5   let ws.diasem = "SEXTA"
    when  6   let ws.diasem = "SABADO"
    otherwise initialize ws.diasem to null
 end case

 return ws.diasem

end function  #  c24geral12

#-----------------------------------------------------------------------------
function c24geral13()                      # MUNICIPIOS DA GRANDE SAO PAULO
#-----------------------------------------------------------------------------

 define a_cid array[21] of record
        ciddes   char(25)
 end record

 define arr_aux      smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  21
		initialize  a_cid[w_pf1].*  to  null
	end	for

 open window w_c24geral13 at 11,51 with form "C24geral13"
             attribute(border, form line first)

 let int_flag = false
 let a_cid[01].ciddes = "BARUERI"
 let a_cid[02].ciddes = "CAIEIRAS"
 let a_cid[03].ciddes = "CARAPICUIBA"
 let a_cid[04].ciddes = "COTIA"
 let a_cid[05].ciddes = "DIADEMA"
 let a_cid[06].ciddes = "EMBU"
 let a_cid[07].ciddes = "FRANCISCO MORATO"
 let a_cid[08].ciddes = "FRANCO DA ROCHA"
 let a_cid[09].ciddes = "GUARULHOS"
 let a_cid[10].ciddes = "ITAPECERICA DA SERRA"
 let a_cid[11].ciddes = "ITAPEVI"
 let a_cid[12].ciddes = "JANDIRA"
 let a_cid[13].ciddes = "MAUA"
 let a_cid[14].ciddes = "OSASCO"
 let a_cid[15].ciddes = "PERUS"
 let a_cid[16].ciddes = "RIBEIRAO PIRES"
 let a_cid[17].ciddes = "SANTO ANDRE"
 let a_cid[18].ciddes = "SAO BERNARDO DO CAMPO"
 let a_cid[19].ciddes = "SAO CAETANO"
 let a_cid[20].ciddes = "TABOAO DA SERRA"
 let a_cid[21].ciddes = "VARGEM GRANDE PAULISTA"

 let arr_aux = 21
 call set_count(arr_aux)
 message " (F17)Abandona"

 display array a_cid to s_c24geral13.*
      on key (interrupt)
         initialize a_cid   to null
         exit display
 end display

 let int_flag = false

 close window w_c24geral13

end function   # c24geral3

function c24geral_mes(l_data)

   define l_data date,
          l_mes  integer,
          l_mes_extenso char(20)

   let l_mes_extenso = null
   let l_mes = month(l_data)

   case l_mes
      when 01 let l_mes_extenso = 'Janeiro'
      when 02 let l_mes_extenso = 'Fevereiro'
      when 03 let l_mes_extenso = 'Marco'
      when 04 let l_mes_extenso = 'Abril'
      when 05 let l_mes_extenso = 'Maio'
      when 06 let l_mes_extenso = 'Junho'
      when 07 let l_mes_extenso = 'Julho'
      when 08 let l_mes_extenso = 'Agosto'
      when 09 let l_mes_extenso = 'Setembro'
      when 10 let l_mes_extenso = 'Outubro'
      when 11 let l_mes_extenso = 'Novembro'
      when 12 let l_mes_extenso = 'Dezembro'
   end case

   return l_mes_extenso

end function
