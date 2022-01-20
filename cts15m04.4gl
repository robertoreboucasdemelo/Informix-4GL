#---------------------------------------------------------------------------#
# Nome do Modulo: CTS15M04                                         Pedro    #
#                                                                  Marcelo  #
# Informa data/hora para retirada do veiculo e dias de utilizacao  Ago/1995 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 11/11/1998  PSI 7055-6   Gilberto     Alterar acesso a tabela de lojas,   #
#                                       que teve chave primaria alterada.   #
#---------------------------------------------------------------------------#
# 11/03/1999  PSI 7954-5   Wagner       Criticar bloqueio da loja apos a    #
#                                       input da data de retirada.          #
#---------------------------------------------------------------------------#
# 23/03/1999  PSI 7671-6   Wagner       Criar modulo para pesquisa de data  #
#                                       entrega quando operacao = (R)eserva #
#---------------------------------------------------------------------------#
# 08/12/2000  PSI 10631-3  Wagner       Incluir centro de custo p/prorrog.  #
#---------------------------------------------------------------------------#
# 06/07/2001  PSI 13448-1  Wagner       Criar operacao (A)= Alteracao da    #
#                                       previsao dentro do servico.         #
#---------------------------------------------------------------------------#
# 04/03/2004  OSF 32875    Helio        Informar data/hora para retirada do #
#                                       veiculo                             #
#---------------------------------------------------------------------------#
#                                                                           #
#                       * * * Alteracoes * * *                              #
#                                                                           #
# Data        Autor Fabrica  Origem      Alteracao                          #
# ----------  -------------- ---------  ----------------------------------  #
# 23/08/2003  Meta,Bruno     PSI176532   Chamar popup para consultar o      #
#                            OSF25887    o Centro Custo.                    #
#---------------------------------------------------------------------------#
# 02/04/2004 Fabrica S.      Teresinha Silva CT 176540                      #
#                            Inibir tratamentos de erro                     #
#---------------------------------------------------------------------------#
# 22/06/2004 Fabrica S.     Teresinha Silva  OSF 37184                      #
#                           Alterar chamada funcao ctn18c00 passando zero   #
#                           como cod mot. locacao, inves da flag de oficinas#
#---------------------------------------------------------------------------#
# 10/12/2004  Katiucia      CT 268615 Ajustes verificacao horario das lojas #
#---------------------------------------------------------------------------#
# 14/06/2005 Fabrica S.     JUNIOR, Meta     PSI 192341                     #
#                           Unificacao de Centro de Custo                   #
#                                                                           #
#---------------------------------------------------------------------------#
# 21/02/2006  Priscila     PSI 198390     Alteracao chamada funcao ctn18c00 #
#                                         passar parametro cidcep           #
#---------------------------------------------------------------------------#
# 28/11/2006 Priscila          PSI205206  Passar empresa para ctn18c00      #
#---------------------------------------------------------------------------#
# 10/01/2008 Ligia Mattge      PSI217956  Abrir reserva p/ramos do RE       #
#---------------------------------------------------------------------------#
# 10/12/2009 Amilton, Meta     PSI251429  Limitar a vinte dias os assuntos  #
#                                         H12 e H13 PAS                     #
#-----------------------------------------------------------------------------#
#############################################################################
 database porto
globals "/homedsa/projetos/geral/globals/glct.4gl"


#----------------------------------------------------------------------
 function cts15m04(d_cts15m04)
#----------------------------------------------------------------------

 define d_cts15m04     record
    operacao           char (01),
                       {(P)rorrog./(R)eserva/(F)ormulario/(C)onsulta/(A)lter.}
    avialgmtv          like datmavisrent.avialgmtv,
    aviestcod          like datmavisrent.aviestcod,
    aviretdat          like datmavisrent.aviretdat,
    avirethor          like datmavisrent.avirethor,
    aviprvent          like datmavisrent.aviprvent,
    lcvcod             like datklocadora.lcvcod,
    endcep             like datkavislocal.endcep,
    dtentvcl           date                            #OSF 32875
 end record

 define lr_param       record
         empcod         like ctgklcl.empcod,
        succod         like ctgklcl.succod,
        cctlclcod      like ctgklcl.cctlclcod,
        cctdptcod      like ctgrlcldpt.cctdptcod,
        cctdptnom      like ctgkdpt.cctdptnom  ## enviar "" ou nome parcial do departamento
 end record

 define lr_ret         record
        cctlclcod      like ctgklcl.cctlclcod,
        cctlclnom      like ctgklcl.cctlclnom,
        cctdptcod      like ctgrlcldpt.cctdptcod,
        cctdptnom      like ctgkdpt.cctdptnom,
        cctdptlclsit   like ctgrlcldpt.cctdptlclsit
 end record

 define lr_param_a     record
        empcod         like ctgklcl.empcod,       #--Empresa
        succod         like ctgklcl.succod,       #--Sucursal
        cctlclcod      like ctgklcl.cctlclcod,    #--Local
        cctdptcod      like ctgrlcldpt.cctdptcod  #--Departamento
 end record

 define lr_ret_a       record
        erro           smallint, ## 0-Ok,1-erro
        mens           char(40),
        cctlclnom      like ctgklcl.cctlclnom,       #--Nome do local
        cctdptnom      like ctgkdpt.cctdptnom,       #--Nome do departamento (antigo cctnom)
        cctdptrspnom   like ctgrlcldpt.cctdptrspnom, #--Responsavel pelo  departamento
        cctdptlclsit   like ctgrlcldpt.cctdptlclsit, #--Situagco do depto (A)tivo ou (I)nativo
        cctdpttip      like ctgkdpt.cctdpttip        #-- Tipo de departamento
 end record

 define ws             record
    diasem             smallint,
    atdofnflg          smallint,
    vcldevdat          date,
    utlretdat          date,
    lcvcod             like datklocadora.lcvcod,
    aviestcod          like datmavisrent.aviestcod,
    vclpsqflg          char (01),
    endcep             like datkavislocal.endcep,
    endcepcmp          like datkavislocal.endcepcmp,
    horsegsexinc       like datkavislocal.horsegsexinc,
    horsegsexfnl       like datkavislocal.horsegsexfnl,
    horsabinc          like datkavislocal.horsabinc,
    horsabfnl          like datkavislocal.horsabfnl,
    hordominc          like datkavislocal.hordominc,
    hordomfnl          like datkavislocal.hordomfnl,
    viginc             like datklcvsit.viginc,
    vigfnl             like datklcvsit.vigfnl,
    cctempcod          like datmprorrog.cctempcod,
    cctsuccod          like datmprorrog.cctsuccod,
    cctcod             like datmprorrog.cctcod,
    cctnom             like ctokcentrosuc.cctnom,
    confirma           char (01)
 end record

 define salva          record
    aviretdat          like datmavisrent.aviretdat,
    avirethor          like datmavisrent.avirethor,
    aviprvent          like datmavisrent.aviprvent
 end record

# PSI 176532 - Inicio

 define l_dpt_pop    record
    lin              smallint,
    col              smallint,
    title            char(054),
    col_tit_1        char(012),
    col_tit_2        char(040),
    tipcod           char(001),
    cmd_sql          char(600),
    comp_sql         char(200),
    tipo             char(001)
 end record

 define l_dias       smallint
       ,l_achou      smallint
       ,l_avidiaqtd  smallint
       ,l_confirma   char(1)
       ,l_dif        smallint



 define l_data       date,
        l_hora2      datetime hour to minute,
        l_tot        integer

 define l_new record
        range    smallint ,
        data     smallint
end record

define l_count       smallint
define l_dias_limite char(3)
define l_error       char(200)
define l_reserva     char(2)
define l_limite      smallint
define l_autilizar  integer
define l_msg1 char(25)
define l_msg2 char(25)
define l_msg3 char(25)

let g_fatura_usr  = 0
let g_fatura_emp  = 0
let l_dif  = 0

let l_autilizar =  0

let l_msg1 = null
let l_msg2 = null
let l_msg3 = null

# PSI 176532 - Final

	initialize  ws.*  to  null

	initialize  salva.*  to  null

	initialize  l_new.*  to  null

 initialize ws.*          to null
 initialize l_dpt_pop     to null

 let l_achou = 0
 let l_dias_limite = null
 let l_avidiaqtd = null
 let l_error = null
 let l_reserva = null
 let l_limite = 0

 let int_flag =  false

 let salva.aviretdat = d_cts15m04.aviretdat
 let salva.avirethor = d_cts15m04.avirethor
 let salva.aviprvent = d_cts15m04.aviprvent

 if g_documento.ciaempcod = 84 then     
 	
 	  let l_limite = d_cts15m04.aviprvent    
 	  
 	  if d_cts15m04.avialgmtv = 8 then
 	  	  let d_cts15m04.aviprvent = null
 	  end if		
    
 end if


 if d_cts15m04.operacao = "M" then
    let l_tot = 0
    call ctd33g00_tot_resumo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)
         returning l_tot
    let salva.aviprvent = l_tot
 end if

 if d_cts15m04.lcvcod = -1 then
     let d_cts15m04.lcvcod = ""
     let l_new.range = 1
     let l_new.data = 7
 end if
 call cta00m06_carro_extra()
      returning l_dias_limite


-- Fabrica de Software - OSF 37184 - Teresinha Silva --
#if d_cts15m04.avialgmtv = 3  or
#   d_cts15m04.avialgmtv = 6  then    #OSF 32875
#   let ws.atdofnflg = true
#else
#   let ws.atdofnflg = false
#end if
-- OSF 37184 --

 if d_cts15m04.operacao <> "R" and
    d_cts15m04.operacao <> "A" then
    select horsegsexinc, horsegsexfnl,
           horsabinc   , horsabfnl   ,
           hordominc   , hordomfnl   ,
           endcep
      into ws.horsegsexinc, ws.horsegsexfnl,
           ws.horsabinc   , ws.horsabfnl   ,
           ws.hordominc   , ws.hordomfnl   ,
           ws.endcep
      from datkavislocal
     where lcvcod    = d_cts15m04.lcvcod  and
           aviestcod = d_cts15m04.aviestcod
 end if

  let l_dpt_pop.lin         = 6
  let l_dpt_pop.col         = 2
  let l_dpt_pop.title       = 'Centro de Custo'
  let l_dpt_pop.col_tit_1   = 'Codigo'
  let l_dpt_pop.col_tit_2   = 'Descricao'
  let l_dpt_pop.tipcod      = 'N'
  let l_dpt_pop.tipo        = 'D'

 open window cts15m04 at 08,40 with form "cts15m04"
                         attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona"

 input by name d_cts15m04.aviretdat,
               d_cts15m04.avirethor,
               d_cts15m04.aviprvent,
               ws.cctempcod,
               ws.cctsuccod,
               ws.cctcod     without defaults

   before field aviretdat
          #if d_cts15m04.operacao = "A"  then
          #   next field aviprvent
          #end if
          if d_cts15m04.operacao = "C"  then
             display by name d_cts15m04.aviretdat
          else
             display by name d_cts15m04.aviretdat  attribute (reverse)
          end if
	  display by name d_cts15m04.dtentvcl #OSF 32875

   after  field aviretdat
          display by name d_cts15m04.aviretdat

          if d_cts15m04.operacao = "C"  then
             error " Nao e' possivel fazer alteracoes na consulta!"
             let d_cts15m04.aviretdat = salva.aviretdat
             next field aviretdat
          end if

          if d_cts15m04.aviretdat  is null    or
             d_cts15m04.aviretdat  = "   "    then
             error " Informe a data de retirada do veiculo na loja!"
             next field aviretdat
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2

          #ligia - 13/06/11 - permitir data retroativa
          if d_cts15m04.operacao   =  "R"   and
             d_cts15m04.aviretdat  <  l_data then
             if salva.aviretdat       is  null             or
                d_cts15m04.aviretdat  <>  salva.aviretdat  then
                error " Data de retirada nao deve ser menor que data atual!"
                next field aviretdat
             end if
          end if


-- #CT 176540
#  if d_cts15m04.operacao = "R" and     # OSF 32875
#     d_cts15m04.aviretdat > d_cts15m04.dtentvcl then
#     error " Data de retirada maior que Data limite da Locacao!"
#     next field aviretdat
#  end if

          if d_cts15m04.operacao   = "F"   and
             d_cts15m04.aviretdat  < l_data - 90 units day  then
             error " Data de retirada do veiculo nao deve ser anterior a TRES meses!"
             next field aviretdat
          end if

          if d_cts15m04.operacao   = "P"   and
             d_cts15m04.aviretdat  < l_data - 5 units day then
             error " Data de prorrogacao invalida!"
             next field aviretdat
          end if

          if d_cts15m04.aviretdat  > l_data + 30 units day   then
             error " Data de retirada do veiculo nao deve ser maior que 30 dias!"
             next field aviretdat
          end if

          initialize ws.utlretdat to null

          call c24geral9(d_cts15m04.aviretdat, 0, ws.endcep, "S", "N")
               returning ws.utlretdat

          if ws.utlretdat is not null  and
             d_cts15m04.aviretdat <> ws.utlretdat  then
             call cts08g01("A","N","","DATA DE RETIRADA DO VEICULO",
                                      "OCORRERA' NUM FERIADO!","")
                  returning ws.confirma
          end if

          if d_cts15m04.operacao   =  "R" then
             call cts08g01("A","N","","AS LOJAS SERAO SELECIONADAS",
                                      "DE ACORDO COM A DATA DE",
                                      "RETIRADA INFORMADA.")
                  returning ws.confirma
          end if

   before field avirethor
          display by name d_cts15m04.avirethor  attribute (reverse)

   after  field avirethor
          display by name d_cts15m04.avirethor

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field aviretdat
          end if

          if d_cts15m04.avirethor  is null  or
             d_cts15m04.avirethor  = "   "  then
             error " Informe a hora de retirada do veiculo na loja !!"
             next field avirethor
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          if (d_cts15m04.operacao    =  "R"    or
              d_cts15m04.operacao    =  "A")   and
             d_cts15m04.aviretdat   =  l_data   and
             d_cts15m04.avirethor  <=  l_hora2  then


                error " Hora de retirada nao deve ser menor que hora atual!"
                next field avirethor

          end if

          let ws.diasem = weekday(d_cts15m04.aviretdat)

          if d_cts15m04.operacao <> "P"  and
             d_cts15m04.operacao <> "R"  and 
             d_cts15m04.operacao <> "A"  then
             if ws.diasem = 0 then
                if ws.hordominc is null  then
                   error " Esta loja nao funciona aos domingos!"
                   next field aviretdat
                end if

                if d_cts15m04.avirethor < ws.hordominc  then
                   error " Veiculo so' deve ser retirado a partir das ", ws.hordominc, " nesta loja!"
                   next field avirethor
                end if

                if d_cts15m04.avirethor > ws.hordomfnl  then
                   error " Veiculo so' deve ser retirado ate' as ", ws.hordomfnl, " nesta loja!"
                   next field avirethor
                end if
             end if

             if ws.diasem = 6 then
                if ws.horsabinc is null  then
                   error " Esta loja nao funciona aos sabados!"
                   next field aviretdat
                end if

                if d_cts15m04.avirethor < ws.horsabinc  then
                   error " Veiculo so' deve ser retirado a partir das ", ws.horsabinc, " nesta loja!"
                   next field avirethor
                end if

                if d_cts15m04.avirethor > ws.horsabfnl  then
                   error " Veiculo so' deve ser retirado ate' as ", ws.horsabfnl, " nesta loja!"
                   next field avirethor
                end if
             else
                if d_cts15m04.avirethor < ws.horsegsexinc  then
                   error " Veiculo so' deve ser retirado a partir das ", ws.horsegsexinc, " nesta loja!"
                   next field avirethor
                end if

                if d_cts15m04.avirethor > ws.horsegsexfnl then
                   error " Veiculo so' deve ser retirado ate' as ", ws.horsegsexfnl, " nesta loja!"
                   next field avirethor
                end if
             end if
          end if
          initialize ws.diasem to null

   before field aviprvent
          -- CT 176540
	  # let l_dias = (d_cts15m04.dtentvcl -     #OSF 32875
	  #	        d_cts15m04.aviretdat)
	  #let d_cts15m04.aviprvent = l_dias
          display by name d_cts15m04.aviprvent  attribute (reverse)


   after  field aviprvent
          display by name d_cts15m04.aviprvent

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_cts15m04.operacao = "A"  then
                next field aviprvent
             end if
             next field avirethor
          end if

          if d_cts15m04.aviprvent  is null  or
             d_cts15m04.aviprvent  = "   "  or
             d_cts15m04.aviprvent  = 0      then
             error " Informe a previsao de dias de utilizacao do veiculo!"
             next field aviprvent
          end if

          ##psi 217956
          if g_documento.ramcod = 31 or g_documento.ramcod = 531 then

{ #### ligia - fornax - 07/06/2011
             let l_count = 0
             select count(*) into l_count
                 from abbmclaus
                where succod    = g_documento.succod
                  and aplnumdig = g_documento.aplnumdig
                  and itmnumdig = g_documento.itmnumdig
                  and clscod   in('033','33R','044','046','46R','047','47R')

            if d_cts15m04.operacao  <> "P" and
               d_cts15m04.avialgmtv = 2    and
               d_cts15m04.aviprvent > 7    and
               l_count > 0 then
                 error "Limitado a 7 dias de utilizacao"
                 next field aviprvent
            end if

            if d_cts15m04.operacao  <> "P" and
               d_cts15m04.avialgmtv = 7    or
               d_cts15m04.avialgmtv = 8    or
               d_cts15m04.avialgmtv = 9    then
               if d_cts15m04.aviprvent > 7    then
                  error "Limitado a 7 dias de utilizacao"
                  next field aviprvent
               end if
            end if
} #### ligia - fornax - 07/06/2011

            if d_cts15m04.operacao  <> "P" and
               d_cts15m04.avialgmtv = 0    then
               if g_documento.c24astcod = "H10" or
                  g_documento.c24astcod = "H12" then
                  if d_cts15m04.aviprvent > l_dias_limite  then
                     let l_error = "Primeira reserva por ",l_dias_limite, "dias; Demais Diárias efetuar prorrogação"
                     error l_error
                     next field aviprvent
                  end if
               else
                 if d_cts15m04.aviprvent > 7 then
                     error "Primeira reserva por 07 dias; Demais Diárias efetuar prorrogação"
                     next field aviprvent
                 end if
               end if
            end if

{ #ligia 18/05/11
            if d_cts15m04.operacao  = "P" and
               d_cts15m04.avialgmtv = 0  then
               if g_documento.c24astcod = "H10" then
                  if d_cts15m04.aviprvent > l_dias_limite  then
                     let l_error = "Primeira reserva por ",l_dias_limite, "dias; Demais Diárias efetuar prorrogação"
                     error l_error
                     next field aviprvent
                  end if
               else
                 if d_cts15m04.aviprvent > 7    then
                    error "Prorrogar por 07 Dias; Demais Diárias efetuar Nova prorrogação"
                    next field aviprvent
                 end if
               end if
            end if
} #### ligia
            if d_cts15m04.operacao  = "P" then

               call ctx01g00_saldo_novo
                    (g_documento.succod   , g_documento.aplnumdig,
                     g_documento.itmnumdig, g_documento.atdsrvnum,
                     g_documento.atdsrvano, l_data ,
                     1, true, g_documento.ciaempcod, d_cts15m04.avialgmtv,
                     g_documento.c24astcod)
                     returning g_lim_diaria, l_avidiaqtd
            else

{ ### ligia - fornax - 07/06/2011
              # Psi-251429
              if g_documento.c24astcod = 'H12' and
               (d_cts15m04.avialgmtv = 3 or
               d_cts15m04.avialgmtv = 5 ) then
               if d_cts15m04.aviprvent > 20    then
                  error "Limitado a 20 dias de utilizacao"
                  next field aviprvent
               end if
              end if

              if g_documento.c24astcod = 'H12' and
                 d_cts15m04.avialgmtv = 0 then
               if d_cts15m04.aviprvent > l_dias_limite  then
                  let l_error = "Limitado a ",l_dias_limite, "dias de utilizacao"
                  error l_error
                  next field aviprvent
               end if
              end if
               if g_documento.c24astcod = 'H13' and
                  (d_cts15m04.avialgmtv = 6 or
                  d_cts15m04.avialgmtv = 5   ) then
                  if d_cts15m04.aviprvent > 20    then
                     error "Limitado a 20 dias de utilizacao"
                     next field aviprvent
                  end if
               end if

               if g_documento.c24astcod = 'H10' or
                  g_documento.c24astcod = 'H12' then

                  if d_cts15m04.avialgmtv = 13 or
                     d_cts15m04.avialgmtv = 14 then
                     if d_cts15m04.aviprvent > 15    then
                        error "Primeira reserva por 15 dias; Demais Diárias efetuar prorrogação"
                        next field aviprvent
                     end if
                  end if
               end if

} ### ligia - fornax - 07/06/2011

               #if  g_documento.c24astcod = "KA1" and
               #    g_documento.ciaempcod = 35 then
               #    d_cts15m04.avialgmtv = 1 then
               #    call cts15m04_verifica_saldo(d_cts15m04.avialgmtv)
               #         returning l_avidiaqtd
               #    if l_avidiaqtd < d_cts15m04.aviprvent then
               #       let l_error = "Limitado a ",l_avidiaqtd clipped, " dias de utilizacao"
               #       error l_error
               #       next field aviprvent
               #    end if
               #end if

               #if  g_documento.c24astcod = "KA1" and
               #    g_documento.ciaempcod = 35 and
               #    d_cts15m04.avialgmtv = 3 then
               #
               #    #if d_cts15m04.aviprvent > 8  then
               #    #   let l_error = "Limitado a 8 dias de utilizacao"
               #    #   error l_error
               #    #   next field aviprvent
               #    #end if
               #end if

                # ligia - fornax - retirado, confirmar - 08/06/11
                #if  ( g_documento.c24astcod = "H10" or
                #      g_documento.c24astcod = "H12") and
                #      d_cts15m04.avialgmtv = 1  then

                #    select count(*) into l_count
                #    from abbmclaus
                #    where succod    = g_documento.succod
                #    and aplnumdig = g_documento.aplnumdig
                #    and itmnumdig = g_documento.itmnumdig
                ##    and clscod   like "26%"
                #
                #    if l_count > 0 then
                #       call cts40g03_data_hora_banco(2)
                #            returning l_data, l_hora2

                       ## ligia - fornax - 06/06/11 de ctx01g00_saldo para
                       ## ctx01g00_saldo_novo
                   if g_documento.ciaempcod <> 84 then


                       call ctx01g00_saldo_novo(g_documento.succod   , g_documento.aplnumdig,
                            g_documento.itmnumdig, g_documento.atdsrvnum,
                            g_documento.atdsrvano, l_data ,
                            1, true, g_documento.ciaempcod, d_cts15m04.avialgmtv, g_documento.c24astcod)
                       returning g_lim_diaria, l_avidiaqtd

                       if d_cts15m04.operacao = "M" then
                          #let l_dif = salva.aviprvent - d_cts15m04.aviprvent
                          #let l_avidiaqtd = l_avidiaqtd + l_dif
                          let l_avidiaqtd = l_avidiaqtd + salva.aviprvent
                       end if

                       if d_cts15m04.operacao = "A" then
                          let l_avidiaqtd = l_avidiaqtd + salva.aviprvent
                       end if

                       if (d_cts15m04.operacao = "R" or
                           d_cts15m04.operacao = "A") and
                          l_avidiaqtd < d_cts15m04.aviprvent then
                         let l_reserva = l_avidiaqtd
                         let l_error = "Limitado a ",l_reserva clipped, " dias de utilizacao"
                         error l_error
                         next field aviprvent
                       end if
                   end if

                #end if
                if  ( g_documento.c24astcod = "I07" or
                      g_documento.c24astcod = "I08" or
                      g_documento.c24astcod = "I20") and
                      g_documento.ciaempcod = 84 then

                     if d_cts15m04.aviprvent > l_limite  then
                        let l_error = "Limitado a ",l_limite clipped, " dias de utilizacao"
                        error l_error
                        next field aviprvent
                     end if
               end if
            end if

          else ## se nao for Auto
            if d_cts15m04.aviprvent > 7 then
               error "Limitado a 7 dias de utilizacao"
               let g_lim_diaria = 7 ##ligia
               next field aviprvent
            end if
          end if

          if d_cts15m04.aviprvent > 99  then    #OSF 32875
             error " Dias de utilizacao nao deve ser maior que 99 !"
             next field aviprvent
          end if

          if l_new.range = 1                   and
             d_cts15m04.aviprvent > l_new.data then
                error " Dias de utilizacao nao deve ser maior que " ,l_new.data," !"
                next field aviprvent
          end if

          if d_cts15m04.operacao = "A"  then
             if d_cts15m04.aviprvent = 0   then
                next field aviprvent
             end if
             exit input
          end if

          let ws.vcldevdat = d_cts15m04.aviretdat + d_cts15m04.aviprvent units day

          initialize ws.utlretdat to null

          call c24geral9(ws.vcldevdat, 0, ws.endcep, "S", "N")
               returning ws.utlretdat

          if ws.utlretdat is not null      and
             ws.vcldevdat <> ws.utlretdat  then
             call cts08g01("A","N","DATA DE DEVOLUCAO DO VEICULO","",
                                   "OCORRERA' NUM FERIADO!","")
                  returning ws.confirma
          end if


          if d_cts15m04.operacao <> "R"  then

             let ws.diasem = weekday(ws.vcldevdat)

             if (ws.diasem = 6  and  ws.horsabinc is null)  or
                (ws.diasem = 0  and  ws.hordominc is null)  then
                if ws.diasem = 0  then
                   call cts08g01("I","N","INFORME AS LOJAS DISPONIVEIS","",
                                         "PARA DEVOLUCAO NO DOMINGO!","")
                        returning ws.confirma
                end if

                if ws.diasem = 6  then
                   call cts08g01("I","N","INFORME AS LOJAS DISPONIVEIS","",
                                         "PARA DEVOLUCAO NO SABADO!","")
                        returning ws.confirma
                end if

                if d_cts15m04.endcep is null  then
                   error " Informe a localizacao do segurado!"
                   call ctn00c02 ("SP","SAO PAULO"," "," ")
                        returning d_cts15m04.endcep, ws.endcepcmp
                end if

               #call ctn18c00(d_cts15m04.lcvcod, d_cts15m04.endcep, "", ws.diasem, 0, ws.atdofnflg)          -- OSF 37184
               #call ctn18c00(d_cts15m04.lcvcod, d_cts15m04.endcep, "", ws.diasem, 0, d_cts15m04.avialgmtv)  -- OSF 37184
               #call ctn18c00(d_cts15m04.lcvcod, d_cts15m04.endcep, ws.endcepcmp, "", ws.diasem, 0, d_cts15m04.avialgmtv)  -- PSI 198390
               call ctn18c00(d_cts15m04.lcvcod, d_cts15m04.endcep, ws.endcepcmp, "",
                             ws.diasem, 0, d_cts15m04.avialgmtv, g_documento.ciaempcod)  # PSI 205206
                returning ws.lcvcod, ws.aviestcod, ws.vclpsqflg

             end if

          end if

          if d_cts15m04.operacao = "R"  then
             call cts08g01("I","N","","RESERVA GARANTIDA ATE 1:30h APOS",
                                      "A DATA E HORA INFORMADAS","")
                  returning ws.confirma
          end if

          if (d_cts15m04.operacao = "P" or d_cts15m04.operacao = "M") and
             g_documento.ciaempcod <> 84 then
             let l_autilizar = l_avidiaqtd
             if d_cts15m04.aviprvent > l_autilizar then
                let g_fatura_usr = d_cts15m04.aviprvent - l_autilizar
                let g_fatura_emp = d_cts15m04.aviprvent - g_fatura_usr
             else
                let g_fatura_emp = d_cts15m04.aviprvent
             end if

             if d_cts15m04.avialgmtv = 4 or
                d_cts15m04.avialgmtv = 5 then
                let g_fatura_emp = 0
                let g_fatura_usr = d_cts15m04.aviprvent
             end if

             let l_msg1 = null
             let l_msg2 = null

             if g_fatura_usr >  0 then
                let l_msg1 = g_fatura_usr using "<&&", ' DIARIA(S): USUARIO'
             end if

             if g_fatura_emp >  0 then
                let l_msg2 = g_fatura_emp using "<&&", ' DIARIA(S): CIA'
             end if

             call cts08g01("C","S","FATURAMENTO",
                           l_msg1, l_msg2,"CONFIRMA PRORROGACAO ?")
                  returning ws.confirma

             if ws.confirma = "N" then
                let g_fatura_usr = 0
                let g_fatura_emp = 0
                let g_lim_diaria = 0
                let l_avidiaqtd  = 0
                let d_cts15m04.aviprvent = null
                next field aviprvent
             end if
          end if

   before field cctempcod
          if d_cts15m04.operacao <> "P"  then
             exit input
          end if
          display by name ws.cctempcod attribute (reverse)

   after  field cctempcod
          display by name ws.cctempcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field aviprvent
          end if

          if ws.cctempcod is null  then
             #if d_cts15m04.avialgmtv = 4  and
             #   g_documento.ciaempcod <> 84  then
             #   #error " Campo obrigatorio, reserva por departamento!"
             #   #next field cctempcod
             #else
                initialize ws.cctempcod, ws.cctsuccod, ws.cctcod to null
                exit input
             #end if
          else

             select empcod
               from gabkemp
              where empcod = ws.cctempcod

             if sqlca.sqlcode <> 0  then
                error " Empresa nao cadastrada!"
                next field cctempcod
             end if
          end if

   before field cctsuccod
          if ws.cctempcod is null then
             exit input
          end if
          display by name ws.cctsuccod  attribute (reverse)

   after  field cctsuccod
          display by name ws.cctsuccod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field cctempcod
          end if

          if ws.cctsuccod is null    or
             ws.cctsuccod =  "  "    then
             error " Informe codigo da sucursal!"
             next field cctsuccod
          end if

          select succod
            from gabksuc
           where succod = ws.cctsuccod

          if sqlca.sqlcode <> 0 then
             error " Codigo da Sucursal nao existe!"
             next field cctsuccod
          end if

   before field cctcod
          display by name ws.cctcod  attribute (reverse)

   after  field cctcod
          display by name ws.cctcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field cctsuccod
          end if
          if ws.cctcod is null  then
             error " Informe centro de custo!"
   # PSI 176532 - Inicio
             let lr_param.empcod    = ws.cctempcod
             let lr_param.succod    = ws.cctsuccod
             let lr_param.cctlclcod = null
             let lr_param.cctdptcod = null
             let lr_param.cctdptnom = null

             let l_dpt_pop.cmd_sql  =  'select a.cctdptcod,b.cctdptnom  '
                                      ,'  from ctgrlcldpt a,ctgkdpt b '
                                      ,' where a.cctdptcod = b.cctdptcod '
                                      ,'   and a.empcod = ',ws.cctempcod
                                      ,'   and a.succod = ',ws.cctsuccod

	     call ofgrc001_popup(l_dpt_pop.*) returning l_achou,
	                                                ws.cctcod,
	                                                ws.cctnom

             if l_achou <> 0 then
                next field cctcod
             end if

             display by name ws.cctcod
             display by name ws.cctnom

   # PSI 176532 - Final

          end if

    let lr_param_a.empcod    = 1
	  let lr_param_a.succod    = 1
	  let lr_param_a.cctlclcod = (ws.cctcod / 10000)
	  let lr_param_a.cctdptcod = (ws.cctcod mod 10000)
	  call fctgc102_vld_dep(lr_param_a.*)
	       returning lr_ret_a.*
	  let ws.cctnom = lr_ret_a.cctdptnom

          display by name ws.cctnom

          if d_cts15m04.avialgmtv = 4 and
             g_documento.ciaempcod <> 84 then

             let g_fatura_emp = g_fatura_usr
             let g_fatura_usr = 0

                let l_msg1 = null
                let l_msg2 = null
                let l_msg3 = null

                let l_msg1 = 'DIARIAS DO USUARIO'
                let l_msg2 = 'CONVERTIDAS PARA CIA'
                let l_msg3 = 'TOTAL DE DIARIAS CIA: ',(g_fatura_emp)
                                                       using "<&&"
                call cts08g01("I","N","FATURAMENTO",
                              l_msg1, l_msg2, l_msg3)
                     returning ws.confirma

          else

             if g_fatura_emp > 0 and
                g_fatura_usr > 0 then

                let l_msg1 = null
                let l_msg2 = null
                let l_msg3 = null

                let l_msg1 = 'DIARIAS DO USUARIO'
                let l_msg2 = 'CONVERTIDAS PARA CIA'
                let l_msg3 = 'TOTAL DE DIARIAS CIA: ',(g_fatura_emp + g_fatura_usr)
                                                       using "<&&"
                call cts08g01("I","N","FATURAMENTO",
                              l_msg1, l_msg2, l_msg3)
                     returning ws.confirma
             end if
          end if

      on key (interrupt)
      # Problema P14010009
      if d_cts15m04.aviretdat < l_data then
               error " Data de retirada nao deve ser menor que data atual!"
                next field aviretdat
      end if
      if d_cts15m04.operacao = "R"  then
          if d_cts15m04.aviretdat  is null    or
             d_cts15m04.aviretdat  = "   "    then
             error " Informe a data de retirada do veiculo na loja!"
             next field aviretdat
          end if
          if d_cts15m04.avirethor  is null  or
             d_cts15m04.avirethor  = "   "  then
             error " Informe a hora de retirada do veiculo na loja !!"
             next field avirethor
          end if
          if d_cts15m04.aviprvent  is null  or
             d_cts15m04.aviprvent  = "   "  or
             d_cts15m04.aviprvent  = 0      then
             error " Informe a previsao de dias de utilizacao do veiculo!"
             next field aviprvent
          end if
      else
        if d_cts15m04.operacao = "P"  then

          call cts08g01("A","S","",
                        "Tem Certeza que deseja Abandonar a  ",
                        "Prorrogacao ? ",
                        " ")
              returning l_confirma

          if l_confirma = "S" then
             let d_cts15m04.aviretdat = null
             let d_cts15m04.avirethor = null
             let d_cts15m04.aviprvent = null
          else
             next field aviretdat
          end if
        end if
      end if
      exit input

 end input


 close window cts15m04
 let int_flag = false

 return d_cts15m04.aviretdat, d_cts15m04.avirethor,
        d_cts15m04.aviprvent, ws.cctempcod        ,
        ws.cctsuccod        , ws.cctcod

end function  ###  cts15m04


#----------------------------------------------------------------------
 function cts15m04_valloja(d_cts15m04)   # validacao datas da Loja
#----------------------------------------------------------------------

 define d_cts15m04     record
    avialgmtv          like datmavisrent.avialgmtv,
    aviestcod          like datmavisrent.aviestcod,
    aviretdat          like datmavisrent.aviretdat,
    avirethor          like datmavisrent.avirethor,
    aviprvent          like datmavisrent.aviprvent,
    lcvcod             like datklocadora.lcvcod,
    endcep             like datkavislocal.endcep
 end record

 define ws             record
    linha1             char(40),
    linha2             char(40),
    diasem             smallint,
    atdofnflg          smallint,
    lcvcod             like datklocadora.lcvcod,
    aviestcod          like datmavisrent.aviestcod,
    vclpsqflg          char (01),
    endcep             like datkavislocal.endcep,
    endcepcmp          like datkavislocal.endcepcmp,
    horsegsexinc       like datkavislocal.horsegsexinc,
    horsegsexfnl       like datkavislocal.horsegsexfnl,
    horsabinc          like datkavislocal.horsabinc,
    horsabfnl          like datkavislocal.horsabfnl,
    hordominc          like datkavislocal.hordominc,
    hordomfnl          like datkavislocal.hordomfnl,
    viginc             like datklcvsit.viginc,
    vigfnl             like datklcvsit.vigfnl,
    confirma           char (01)
 end record




	initialize  ws.*  to  null

 initialize ws.*    to null
 let int_flag =  false

-- Fabrica de Software - OSF 37184 - Teresinha Silva --
#if d_cts15m04.avialgmtv = 3  or     #OSF 32875
#   d_cts15m04.avialgmtv = 6  then
#   let ws.atdofnflg = true
# else
#   let ws.atdofnflg = false
#end if
-- OSF 37184 --

 select horsegsexinc, horsegsexfnl,
        horsabinc   , horsabfnl   ,
        hordominc   , hordomfnl   ,
        endcep
   into ws.horsegsexinc, ws.horsegsexfnl,
        ws.horsabinc   , ws.horsabfnl   ,
        ws.hordominc   , ws.hordomfnl   ,
        ws.endcep
   from datkavislocal
  where lcvcod    = d_cts15m04.lcvcod  and
        aviestcod = d_cts15m04.aviestcod

 let ws.diasem = weekday(d_cts15m04.aviretdat)

 if ws.diasem = 0 then
    # -- CT 268615 - Katiucia -- #
    ## if ws.hordominc is null  then
    if ws.hordominc = "00:00" and
       ws.hordomfnl = "00:00" then
       let ws.linha1 = "ESTA LOJA NAO FUNCIONA AOS DOMINGOS!"
    else
       if d_cts15m04.avirethor < ws.hordominc  then
          let ws.linha1 = "VEICULO SO' DEVE SER RETIRADO A PARTIR"
          let ws.linha2 = " DAS ", ws.hordominc, " NESTA LOJA!"
       end if

       if d_cts15m04.avirethor > ws.hordomfnl  then
          let ws.linha1 = "VEICULO SO' DEVE SER RETIRADO ATE'"
          let ws.linha2 = " AS ", ws.hordomfnl, " NESTA LOJA!"
       end if
    end if
  else
    if ws.diasem = 6 then
       # -- CT 268615 - Katiucia -- #
       ## if ws.horsabinc is null  then
       if ws.horsabinc = "00:00" and
          ws.horsabfnl = "00:00" then
          let ws.linha1 = "ESTA LOJA NAO FUNCIONA AOS SABADOS!"
       else
          if d_cts15m04.avirethor < ws.horsabinc  then
             let ws.linha1 = "VEICULO SO' DEVE SER RETIRADO A PARTIR"
             let ws.linha2 = " DAS ", ws.horsabinc, " NESTA LOJA!"
          end if

          if d_cts15m04.avirethor > ws.horsabfnl  then
             let ws.linha1 = "VEICULO SO' DEVE SER RETIRADO ATE'"
             let ws.linha2 = " AS ", ws.horsabfnl, " NESTA LOJA!"
          end if
       end if
     else
       if d_cts15m04.avirethor < ws.horsegsexinc  then
          let ws.linha1 = "VEICULO SO' DEVE SER RETIRADO A PARTIR"
          let ws.linha2 = " DAS ", ws.horsegsexinc, " NESTA LOJA!"
       end if

       if d_cts15m04.avirethor > ws.horsegsexfnl then
          let ws.linha1 = "VEICULO SO' DEVE SER RETIRADO ATE'"
          let ws.linha2 = " AS ", ws.horsegsexfnl, " NESTA LOJA!"
       end if
    end if
 end if

 if ws.linha1 is not null then
     call cts08g01("A","N",ws.linha1,"",ws.linha2,"")
          returning ws.confirma
     let ws.confirma  =  "N"
  else
    let ws.diasem = weekday(d_cts15m04.aviretdat + d_cts15m04.aviprvent units day)
    if (ws.diasem    = 6        and
        ws.horsabinc = "00:00"  and
        ws.horsabfnl = "00:00") or
       (ws.diasem    = 0        and
        ws.hordominc = "00:00"  and
        ws.hordomfnl = "00:00") then
       if ws.diasem = 0  then
          call cts08g01("I","N","INFORME AS LOJAS DISPONIVEIS","",
                                  "PARA DEVOLUCAO NO DOMINGO!","")
               returning ws.confirma
       end if

       if ws.diasem = 6  then
          call cts08g01("I","N","INFORME AS LOJAS DISPONIVEIS","",
                                 "PARA DEVOLUCAO NO SABADO!","")
               returning ws.confirma
       end if

       if d_cts15m04.endcep is null  then
          error " Informe a localizacao do segurado!"
          call ctn00c02 ("SP","SAO PAULO"," "," ")
               returning d_cts15m04.endcep, ws.endcepcmp
       end if

       call ctn18c00(d_cts15m04.lcvcod, d_cts15m04.endcep, ws.endcepcmp, "",
                     ws.diasem, 0, d_cts15m04.avialgmtv, g_documento.ciaempcod)  #PSI 205206
       returning ws.lcvcod, ws.aviestcod, ws.vclpsqflg

       let ws.confirma = "S"
    end if
 end if

 return ws.confirma

end function  # cts15m04_valloja

#============================================
function cts15m04_verifica_saldo(l_avialgmtv)
#============================================

define l_avialgmtv          like datmavisrent.avialgmtv

define lr_ctx01g01 record
       clscod     like abbmclaus.clscod,
       temcls     smallint
end record

define lr_retorno record
       avioccdat  like datmavisrent.avioccdat,
       avidiaqtd  smallint
end record

 define l_data      date,
        l_hora2     datetime hour to minute

initialize lr_ctx01g01.* to null
initialize lr_retorno.* to null

call cts44g01_claus_azul(g_documento.succod,
                              531,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig)
returning lr_ctx01g01.temcls,lr_ctx01g01.clscod


     call cts40g03_data_hora_banco(2)
          returning l_data, l_hora2
     let lr_retorno.avioccdat = l_data


# ligia chamando ctx01g00_saldo_novo - 27/05/11
call ctx01g00_saldo_novo(g_documento.succod
                        ,g_documento.aplnumdig
                        ,g_documento.itmnumdig
                        ,''
                        ,''
                        ,lr_retorno.avioccdat
                        ,1,true
                        ,35
                        ,l_avialgmtv
                        ,g_documento.c24astcod)
    returning g_lim_diaria, lr_retorno.avidiaqtd

{
if lr_retorno.avidiaqtd is null or
   lr_retorno.avidiaqtd = 0 then
     case lr_ctx01g01.clscod

        when '58A'
           let lr_retorno.avidiaqtd = 5
           #   'CLAUSULA 58B - FATURAR DIARIAS P/ AZUL '
           #                   ,'SEGUROS ATE O LIMITE 5 DIARIAS '
        when '58B'
           let lr_retorno.avidiaqtd = 10
        #   'CLAUSULA 58B - FATURAR DIARIAS P/ AZUL '
        #                   ,'SEGUROS ATE O LIMITE 10 DIARIAS '
        when '58C'
           let lr_retorno.avidiaqtd =  15
           #'CLAUSULA 58C - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
        when '58D'
           let lr_retorno.avidiaqtd =  30
           #'CLAUSULA 58D - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
        when '58E'
           let lr_retorno.avidiaqtd =  5
           #'CLAUSULA 58E FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 05 DIARIAS '
        when '58F'
           let lr_retorno.avidiaqtd =  10
           #'CLAUSULA 58F - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 10 DIARIAS '
        when '58G'
           let lr_retorno.avidiaqtd =  15
           #'CLAUSULA 58G - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
        when '58H'
           let lr_retorno.avidiaqtd =  30
           #'CLAUSULA 58H - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
        when '58I'
           let lr_retorno.avidiaqtd =  7
           #'CLAUSULA 58I - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 07 DIARIAS '
        when '58J'
           let lr_retorno.avidiaqtd =  15
           #'CLAUSULA 58J - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
        when '58K'
           let lr_retorno.avidiaqtd =  30
           #'CLAUSULA 58K - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
        when '58L'
           let lr_retorno.avidiaqtd =  7
           #'CLAUSULA 58L - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 07 DIARIAS '
        when '58M'
           let lr_retorno.avidiaqtd =  15
           #'CLAUSULA 58M - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
        when '58N'
           let lr_retorno.avidiaqtd =  30
           #'CLAUSULA 58N - FATURAR DIARIAS P/ AZUL '
           #                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
        end case
end if
}

return lr_retorno.avidiaqtd

end function

