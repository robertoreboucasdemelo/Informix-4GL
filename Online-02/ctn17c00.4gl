#############################################################################
# Nome do Modulo: CTN17C00                                         Marcelo  #
#                                                                  Gilberto #
# Consulta veiculos disponiveis para locacao                       Ago/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 16/11/1998  PSI 7056-4   Gilberto     Alterar acessos as tabelas de cadas-#
#                                       tro do Carro Extra que tiveram suas #
#                                       chaves primarias alteradas.         #
#---------------------------------------------------------------------------#
# 17/02/2006  PSI 198390   Priscila     Melhoria Carro Extra - inclusao     #
#                                       campos de valores de franquia       #
#---------------------------------------------------------------------------#
# 02/03/2006  Zeladoria    Prisicla     Buscar data e hora do banco         #
#---------------------------------------------------------------------------#
# 28/11/2006  PSI 205206   Priscila     Receber empresa como parametro e    #
#                                       permitir input de ciaempcod         #
#---------------------------------------------------------------------------#
# 19/11/2015 PSI 2015-     ElianeK,     Adequação do sistema de atendimento #
#            15499/IN      Fornax       para conceder os novos serviços do  #
#            fase2 _v1.0                Produto Frota Itaú.                 #
#############################################################################

database porto

  define m_ctn17c00_prep smallint,
         m_qtd_veic      smallint

  define am_veiculos array[100] of record
     avivclmdl      like datkavisveic.avivclmdl,
     avivclgrp      smallint,
     grupo_original char(01),
     avivclcod      like datkavisveic.avivclcod,
     avivcldes      like datkavisveic.avivcldes,
     lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr,
     lcvvclsgrvlr   like datklocaldiaria.lcvvclsgrvlr,
     isnvlr         like datkavisveic.isnvlr,
     rduvlr         like datkavisveic.rduvlr,
     frqvlr         like datkavisveic.frqvlr,
     obs            like datkavisveic.obs
  end record

#-------------------------#
function ctn17c00_prepare()
#-------------------------#

  define l_sql char(500)

  let l_sql = " select a.lcvcod, ",
                     " a.avivclcod, ",
                     " a.avivclgrp, ",
                     " a.avivclmdl, ",
                     " a.avivcldes, ",
                     " a.avivclstt, ",
                     " a.frqvlr, ",
                     " a.rduvlr, ",
                     " a.isnvlr, ",
                     " a.obs, ",
                     " b.lcvlojtip, ",
                     " b.lcvregprccod, ",
                     " b.lcvvcldiavlr, ",
                     " b.lcvvclsgrvlr ",
                " from datkavisveic a, ",
                     " datklocaldiaria b ",
               " where a.lcvcod > 0 ",
                 " and a.avivclcod > 0 ",
                 " and b.lcvcod = a.lcvcod ",
                 " and b.avivclcod = a.avivclcod ",
                 " and ? between b.viginc ",
                 " and b.vigfnl ",
                 " and 1 between b.fxainc ",
                 " and b.fxafnl ",
               " order by avivclgrp, ",
                        " avivclcod "

  prepare p_ctn17c00_001 from l_sql
  declare c_ctn17c00_001 cursor for p_ctn17c00_001

  let l_sql = " select lcvnom ",
                " from datklocadora ",
               " where lcvcod = ? "

  prepare p_ctn17c00_002 from l_sql
  declare c_ctn17c00_002 cursor for p_ctn17c00_002

  let l_sql = " select lcvextcod, ",
                     " aviestnom, ",
                     " lcvlojtip, ",
                     " lcvregprccod ",
                " from datkavislocal ",
               " where lcvcod = ? ",
                 " and aviestcod = ? "

  prepare p_ctn17c00_003 from l_sql
  declare c_ctn17c00_003 cursor for p_ctn17c00_003
  
  let l_sql = " select a.lcvcod, ",
                     " a.avivclcod, ",
                     " a.avivclgrp, ",
                     " a.avivclmdl, ",
                     " a.avivcldes, ",
                     " a.avivclstt, ",
                     " a.frqvlr, ",
                     " a.rduvlr, ",
                     " a.isnvlr, ",
                     " a.obs, ",
                     " b.lcvlojtip, ",
                     " b.lcvregprccod, ",
                     " b.lcvvcldiavlr, ",
                     " b.lcvvclsgrvlr ",
                " from datkavisveic a, ",
                     " datklocaldiaria b ",
               " where a.lcvcod = 2 ",
                 " and a.avivclcod > 0 ",
                 " and a.avivclgrp = 'H' ",
                 " and a.avivclstt = 'A' ",
                 " and b.lcvcod = a.lcvcod ",
                 " and b.avivclcod = a.avivclcod ",
                 " and ? between b.viginc ",
                 " and b.vigfnl ",
                 " and 1 between b.fxainc ",
                 " and b.fxafnl ",
               " order by avivclgrp, ",
                        " avivclcod "

  prepare p_ctn17c00_004 from l_sql
  declare c_ctn17c00_004 cursor for p_ctn17c00_004
  
  let m_ctn17c00_prep = true

end function

#----------------------#
function ctn17c00(param)
#----------------------#

  define param      record
     lcvcod         like datklocadora.lcvcod,
     aviestcod      like datkavislocal.aviestcod,
     tipo_ordenacao char(01), # N -> ORDENACAO NORMAL
                              # A -> VEICULOS C/AR CONDICIONADO EM PRIMEIRO LUGAR
     ciaempcod      like datravsemp.ciaempcod,         #PSI 205206
     avialgmtv      like datmavisrent.avialgmtv,        #PSI 244.813 Cadastro Veiculo - Carro Extra
     clscod         like abbmclaus.clscod
  end record

  define k_ctn17c00 record
     lcvcod         like datklocadora.lcvcod    ,
     lcvnom         like datklocadora.lcvnom    ,
     lcvextcod      like datkavislocal.lcvextcod,
     aviestnom      like datkavislocal.aviestnom,
     lcvlojtip      like datkavislocal.lcvlojtip,
     lcvregprccod   like datkavislocal.lcvregprccod,
     ciaempcod      like datravsemp.ciaempcod,     #PSI 205206
     empsgl         like gabkemp.empsgl            #PSI 205206
  end record

  define a_ctn17c00 array[100] of record
     avivclmdl      like datkavisveic.avivclmdl,
     avivclgrp      like datkavisveic.avivclgrp,
     avivclcod      like datkavisveic.avivclcod,
     avivcldes      like datkavisveic.avivcldes,
     lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr,
     lcvvclsgrvlr   like datklocaldiaria.lcvvclsgrvlr,
     isnvlr         like datkavisveic.isnvlr,
     rduvlr         like datkavisveic.rduvlr,
     frqvlr         like datkavisveic.frqvlr,
     obs            like datkavisveic.obs
  end record

  define arr_aux    smallint
  define scr_aux    smallint,
         l_aux_seq  smallint,
         l_contador smallint,
         l_ret      smallint,          #PSI 205206
         l_mensagem char(60)           #PSI 205206

  define ws         record
     lcvcod         like datkavisveic.lcvcod     ,
     avivclstt      like datkavisveic.avivclstt  ,
     lcvlojtip      like datkavislocal.lcvlojtip ,
     lcvregprccod   like datkavislocal.lcvregprccod
  end record

  define l_data      date,
         l_hora2     datetime hour to minute

  initialize k_ctn17c00, ws, a_ctn17c00, am_veiculos to null

  let arr_aux = null
  let scr_aux = null
  let l_aux_seq  = null
  let l_contador = null
  let l_ret      = null
  let l_mensagem = null

  if m_ctn17c00_prep is null or
     m_ctn17c00_prep <> true then
     call ctn17c00_prepare()
  end if

  open window w_ctn17c00 at  04,02 with form "ctn17c00"
              attribute(form line first)

  let arr_aux    = 1
  let l_aux_seq  = 1
  let m_qtd_veic = 0
  let l_contador = 0
  let int_flag = false
  clear form

  if param.lcvcod    is not null   or
     param.aviestcod is not null   then
     let k_ctn17c00.lcvcod = param.lcvcod

     open c_ctn17c00_002 using k_ctn17c00.lcvcod
     whenever error continue
     fetch c_ctn17c00_002 into k_ctn17c00.lcvnom
     whenever error stop

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na localizacao da locadora. AVISE A INFORMATICA!"
        close c_ctn17c00_002
        return a_ctn17c00[arr_aux].avivclcod
     end if

     close c_ctn17c00_002

     display by name k_ctn17c00.lcvcod, k_ctn17c00.lcvnom

     open c_ctn17c00_003 using param.lcvcod, param.aviestcod
     whenever error continue
     fetch c_ctn17c00_003 into k_ctn17c00.lcvextcod,
                             k_ctn17c00.aviestnom,
                             k_ctn17c00.lcvlojtip,
                             k_ctn17c00.lcvregprccod
     whenever error stop

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na localizacao da loja. AVISE A INFORMATICA!"
        close c_ctn17c00_003
        return a_ctn17c00[arr_aux].avivclcod
     end if

     close c_ctn17c00_003

     display by name k_ctn17c00.lcvextcod,
                     k_ctn17c00.aviestnom
  else
     return a_ctn17c00[arr_aux].avivclcod
  end if
  #PSI 205206 - permitir alteração (input) do campo empresa
  # apenas quando ciaempcod não veio preenchido
  if param.ciaempcod is not null then
     let k_ctn17c00.ciaempcod = param.ciaempcod
     #Buscar descrição da empresa
     call cty14g00_empresa(1, k_ctn17c00.ciaempcod)
                 returning l_ret,
                           l_mensagem,
                           k_ctn17c00.empsgl
     display by name k_ctn17c00.ciaempcod,
                     k_ctn17c00.empsgl   attribute(reverse)
  end if
  input by name k_ctn17c00.ciaempcod without defaults
      before field ciaempcod
         if k_ctn17c00.ciaempcod is not null then
            exit input
         end if
         display by name k_ctn17c00.ciaempcod attribute(reverse)
      after field ciaempcod
         if k_ctn17c00.ciaempcod is not null then
            #caso altere empresa Buscar descricao da empresa
            call cty14g00_empresa(1, k_ctn17c00.ciaempcod)
                 returning l_ret,
                           l_mensagem,
                           k_ctn17c00.empsgl
            if l_ret <> 1 then
               #problemas ao buscar empresa
               let k_ctn17c00.ciaempcod = null
               error l_mensagem
               next field ciaempcod
            end if
         else
            let k_ctn17c00.empsgl = "TODAS"
         end if
         display by name k_ctn17c00.ciaempcod,
                         k_ctn17c00.empsgl   attribute(reverse)
      on key (interrupt)
         exit input
  end input

  call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2

  open c_ctn17c00_001 using l_data

  foreach c_ctn17c00_001 into ws.lcvcod,
                            a_ctn17c00[arr_aux].avivclcod,
                            a_ctn17c00[arr_aux].avivclgrp,
                            a_ctn17c00[arr_aux].avivclmdl,
                            a_ctn17c00[arr_aux].avivcldes,
                            ws.avivclstt,
                            a_ctn17c00[arr_aux].frqvlr,
                            a_ctn17c00[arr_aux].rduvlr,
                            a_ctn17c00[arr_aux].isnvlr,
                            a_ctn17c00[arr_aux].obs,
                            ws.lcvlojtip,
                            ws.lcvregprccod,
                            a_ctn17c00[arr_aux].lcvvcldiavlr,
                            a_ctn17c00[arr_aux].lcvvclsgrvlr
      if param.ciaempcod = 1 then
         if param.avialgmtv is not null or
            param.avialgmtv <> " " then
            if param.avialgmtv = 1 and
               (param.clscod = "26H" or
                param.clscod = "26I" or
                param.clscod = "26J" or
                param.clscod = "26K" or
                param.clscod = "26L" or
                param.clscod = "26M") then
               if a_ctn17c00[arr_aux].avivclgrp <> "F" and
                  a_ctn17c00[arr_aux].avivclgrp <> "M" then
                  continue foreach
               end if
            else
               if param.avialgmtv <> 4 and
	          param.avialgmtv <> 5 then  # Motivo <> 4-Departamento e 5-Particular
                  if a_ctn17c00[arr_aux].avivclgrp <> "A" and
                     a_ctn17c00[arr_aux].avivclgrp <> "B" then
                     continue foreach
                  end if
               end if
            end if
         end if
      end if
    if ws.avivclstt <> "A" then
       continue foreach
    end if


    if k_ctn17c00.lcvcod is not null  and
       ws.lcvcod <> k_ctn17c00.lcvcod then
       continue foreach
    end if

    if k_ctn17c00.lcvlojtip    <> ws.lcvlojtip    or
       k_ctn17c00.lcvregprccod <> ws.lcvregprccod then
       continue foreach
    end if

    #PSI 205206
    if k_ctn17c00.ciaempcod is not null then
       #verificar se empresa esta cadastrada para esse veiculo da locadora
       call ctd04g00_valida_emploc(k_ctn17c00.ciaempcod,
                                   ws.lcvcod,
                                   a_ctn17c00[arr_aux].avivclcod)
            returning l_ret,
                      l_mensagem
       if l_ret <> 1 then
          #veiculo/locadora nao vinculado a empresa
          continue foreach
       end if
    end if

    if param.tipo_ordenacao = "A" then # ---> MOSTRAR PRIMEIRAMENTE OS VEICULOS C/AR CONDICIONADO

       if a_ctn17c00[arr_aux].avivclgrp = "B" then
          let am_veiculos[arr_aux].avivclgrp = 0
       else
          let am_veiculos[arr_aux].avivclgrp = l_aux_seq
          let l_aux_seq = l_aux_seq + 1
       end if

       let am_veiculos[arr_aux].grupo_original = a_ctn17c00[arr_aux].avivclgrp
       let am_veiculos[arr_aux].avivclmdl      = a_ctn17c00[arr_aux].avivclmdl
       let am_veiculos[arr_aux].avivclcod      = a_ctn17c00[arr_aux].avivclcod
       let am_veiculos[arr_aux].avivcldes      = a_ctn17c00[arr_aux].avivcldes
       let am_veiculos[arr_aux].lcvvcldiavlr   = a_ctn17c00[arr_aux].lcvvcldiavlr
       let am_veiculos[arr_aux].lcvvclsgrvlr   = a_ctn17c00[arr_aux].lcvvclsgrvlr
       let am_veiculos[arr_aux].obs            = a_ctn17c00[arr_aux].obs

    end if

    let arr_aux = arr_aux + 1

    if arr_aux > 100 then
       error " Limite excedido, pesquisa com mais de 100 veiculos!"
       exit foreach
    end if

  end foreach

 if arr_aux = 1  then
    error " Nao foram cadastrados tipos de veiculo para locacao! "
 end if

 message " (F17)Abandona, (F8)Seleciona"

 let m_qtd_veic = (arr_aux -1)

 if m_qtd_veic > 0 then

    if param.tipo_ordenacao = "A" then
       call ctn17c00_ordena_array(m_qtd_veic)

       for l_contador = 1 to m_qtd_veic

          let a_ctn17c00[l_contador].avivclmdl    = am_veiculos[l_contador].avivclmdl
          let a_ctn17c00[l_contador].avivclgrp    = am_veiculos[l_contador].grupo_original
          let a_ctn17c00[l_contador].avivclcod    = am_veiculos[l_contador].avivclcod
          let a_ctn17c00[l_contador].avivcldes    = am_veiculos[l_contador].avivcldes
          let a_ctn17c00[l_contador].lcvvcldiavlr = am_veiculos[l_contador].lcvvcldiavlr
          let a_ctn17c00[l_contador].lcvvclsgrvlr = am_veiculos[l_contador].lcvvclsgrvlr
          let a_ctn17c00[l_contador].frqvlr       = am_veiculos[l_contador].frqvlr
          let a_ctn17c00[l_contador].rduvlr       = am_veiculos[l_contador].rduvlr
          let a_ctn17c00[l_contador].isnvlr       = am_veiculos[l_contador].isnvlr
          let a_ctn17c00[l_contador].obs          = am_veiculos[l_contador].obs

       end for

    end if

 end if

 call set_count(arr_aux-1)

 display array  a_ctn17c00 to s_ctn17c00.*
    on key (interrupt)
       initialize a_ctn17c00  to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 let int_flag = false
 close window  w_ctn17c00

 return a_ctn17c00[arr_aux].avivclcod

end function

#---------------------------------------#
function ctn17c00_ordena_array(l_tamanho)
#---------------------------------------#

  define l_tamanho   integer,
         l_contador1 integer,
         l_contador2 integer

  define lr_veiculos    record
         avivclmdl      like datkavisveic.avivclmdl,
         avivclgrp      smallint,
         grupo_original char(01),
         avivclcod      like datkavisveic.avivclcod,
         avivcldes      like datkavisveic.avivcldes,
         lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr,
         lcvvclsgrvlr   like datklocaldiaria.lcvvclsgrvlr,
         isnvlr         like datkavisveic.isnvlr,
         rduvlr         like datkavisveic.rduvlr,
         frqvlr         like datkavisveic.frqvlr,
         obs            like datkavisveic.obs
  end record

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_veiculos to null

  let l_contador1 = 0
  let l_contador2 = 0

   # --ORDENA O ARRAY POR ORDEM CRESCENTE DE DISTANCIA
   for l_contador1 = 1 to l_tamanho
      for l_contador2 = l_contador1 + 1 to l_tamanho
         if am_veiculos[l_contador1].avivclgrp > am_veiculos[l_contador2].avivclgrp then

            let lr_veiculos.avivclmdl      = am_veiculos[l_contador1].avivclmdl
            let lr_veiculos.avivclgrp      = am_veiculos[l_contador1].avivclgrp
            let lr_veiculos.grupo_original = am_veiculos[l_contador1].grupo_original
            let lr_veiculos.avivclcod      = am_veiculos[l_contador1].avivclcod
            let lr_veiculos.avivcldes      = am_veiculos[l_contador1].avivcldes
            let lr_veiculos.lcvvcldiavlr   = am_veiculos[l_contador1].lcvvcldiavlr
            let lr_veiculos.lcvvclsgrvlr   = am_veiculos[l_contador1].lcvvclsgrvlr
            let lr_veiculos.frqvlr         = am_veiculos[l_contador1].frqvlr
            let lr_veiculos.rduvlr         = am_veiculos[l_contador1].rduvlr
            let lr_veiculos.isnvlr         = am_veiculos[l_contador1].isnvlr
            let lr_veiculos.obs            = am_veiculos[l_contador1].obs

            let am_veiculos[l_contador1].avivclmdl      = am_veiculos[l_contador2].avivclmdl
            let am_veiculos[l_contador1].avivclgrp      = am_veiculos[l_contador2].avivclgrp
            let am_veiculos[l_contador1].grupo_original = am_veiculos[l_contador2].grupo_original
            let am_veiculos[l_contador1].avivclcod      = am_veiculos[l_contador2].avivclcod
            let am_veiculos[l_contador1].avivcldes      = am_veiculos[l_contador2].avivcldes
            let am_veiculos[l_contador1].lcvvcldiavlr   = am_veiculos[l_contador2].lcvvcldiavlr
            let am_veiculos[l_contador1].lcvvclsgrvlr   = am_veiculos[l_contador2].lcvvclsgrvlr
            let am_veiculos[l_contador1].frqvlr         = am_veiculos[l_contador2].frqvlr
            let am_veiculos[l_contador1].rduvlr         = am_veiculos[l_contador2].rduvlr
            let am_veiculos[l_contador1].isnvlr         = am_veiculos[l_contador2].isnvlr
            let am_veiculos[l_contador1].obs            = am_veiculos[l_contador2].obs

            let am_veiculos[l_contador2].avivclmdl      = lr_veiculos.avivclmdl
            let am_veiculos[l_contador2].avivclgrp      = lr_veiculos.avivclgrp
            let am_veiculos[l_contador2].grupo_original = lr_veiculos.grupo_original
            let am_veiculos[l_contador2].avivclcod      = lr_veiculos.avivclcod
            let am_veiculos[l_contador2].avivcldes      = lr_veiculos.avivcldes
            let am_veiculos[l_contador2].lcvvcldiavlr   = lr_veiculos.lcvvcldiavlr
            let am_veiculos[l_contador2].lcvvclsgrvlr   = lr_veiculos.lcvvclsgrvlr
            let am_veiculos[l_contador2].frqvlr         = lr_veiculos.frqvlr
            let am_veiculos[l_contador2].rduvlr         = lr_veiculos.rduvlr
            let am_veiculos[l_contador2].isnvlr         = lr_veiculos.isnvlr
            let am_veiculos[l_contador2].obs            = lr_veiculos.obs

         end if
      end for
   end for

end function

#--------------------------------#
function ctn17c00_delivery(param)
#--------------------------------#

  define param      record
     lcvcod         like datklocadora.lcvcod,
     aviestcod      like datkavislocal.aviestcod,
     tipo_ordenacao char(01), # N -> ORDENACAO NORMAL
                              # A -> VEICULOS C/AR CONDICIONADO EM PRIMEIRO LUGAR
     ciaempcod      like datravsemp.ciaempcod,         #PSI 205206
     avialgmtv      like datmavisrent.avialgmtv,        #PSI 244.813 Cadastro Veiculo - Carro Extra
     clscod         like abbmclaus.clscod
  end record

  define k_ctn17c00 record
     lcvcod         like datklocadora.lcvcod    ,
     lcvnom         like datklocadora.lcvnom    ,
     lcvextcod      like datkavislocal.lcvextcod,
     aviestnom      like datkavislocal.aviestnom,
     lcvlojtip      like datkavislocal.lcvlojtip,
     lcvregprccod   like datkavislocal.lcvregprccod,
     ciaempcod      like datravsemp.ciaempcod,     #PSI 205206
     empsgl         like gabkemp.empsgl            #PSI 205206
  end record

  define a_ctn17c00 array[100] of record
     avivclmdl      like datkavisveic.avivclmdl,
     avivclgrp      like datkavisveic.avivclgrp,
     avivclcod      like datkavisveic.avivclcod,
     avivcldes      like datkavisveic.avivcldes,
     lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr,
     lcvvclsgrvlr   like datklocaldiaria.lcvvclsgrvlr,
     isnvlr         like datkavisveic.isnvlr,
     rduvlr         like datkavisveic.rduvlr,
     frqvlr         like datkavisveic.frqvlr,
     obs            like datkavisveic.obs
  end record

  define arr_aux    smallint
  define scr_aux    smallint,
         l_aux_seq  smallint,
         l_contador smallint,
         l_ret      smallint,          #PSI 205206
         l_mensagem char(60)           #PSI 205206

  define ws         record
     lcvcod         like datkavisveic.lcvcod     ,
     avivclstt      like datkavisveic.avivclstt  ,
     lcvlojtip      like datkavislocal.lcvlojtip ,
     lcvregprccod   like datkavislocal.lcvregprccod
  end record

  define l_data      date,
         l_hora2     datetime hour to minute

  initialize k_ctn17c00, ws, a_ctn17c00, am_veiculos to null

  let arr_aux = null
  let scr_aux = null
  let l_aux_seq  = null
  let l_contador = null
  let l_ret      = null
  let l_mensagem = null

  if m_ctn17c00_prep is null or
     m_ctn17c00_prep <> true then
     call ctn17c00_prepare()
  end if

  open window w_ctn17c00 at  04,02 with form "ctn17c00"
              attribute(form line first)

  let arr_aux    = 1
  let l_aux_seq  = 1
  let m_qtd_veic = 0
  let l_contador = 0
  let int_flag = false
  clear form

  if param.lcvcod    is not null   or
     param.aviestcod is not null   then
     let k_ctn17c00.lcvcod = param.lcvcod

     open c_ctn17c00_002 using k_ctn17c00.lcvcod
     whenever error continue
     fetch c_ctn17c00_002 into k_ctn17c00.lcvnom
     whenever error stop

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na localizacao da locadora. AVISE A INFORMATICA!"
        close c_ctn17c00_002
        return a_ctn17c00[arr_aux].avivclcod
     end if

     close c_ctn17c00_002

     display by name k_ctn17c00.lcvcod, k_ctn17c00.lcvnom

     open c_ctn17c00_003 using param.lcvcod, param.aviestcod
     whenever error continue
     fetch c_ctn17c00_003 into k_ctn17c00.lcvextcod,
                             k_ctn17c00.aviestnom,
                             k_ctn17c00.lcvlojtip,
                             k_ctn17c00.lcvregprccod
     whenever error stop

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na localizacao da loja. AVISE A INFORMATICA!"
        close c_ctn17c00_003
        return a_ctn17c00[arr_aux].avivclcod
     end if

     close c_ctn17c00_003

     display by name k_ctn17c00.lcvextcod,
                     k_ctn17c00.aviestnom
  else
     return a_ctn17c00[arr_aux].avivclcod
  end if
  #PSI 205206 - permitir alteração (input) do campo empresa
  # apenas quando ciaempcod não veio preenchido
  if param.ciaempcod is not null then
     let k_ctn17c00.ciaempcod = param.ciaempcod
     #Buscar descrição da empresa
     call cty14g00_empresa(1, k_ctn17c00.ciaempcod)
                 returning l_ret,
                           l_mensagem,
                           k_ctn17c00.empsgl
     display by name k_ctn17c00.ciaempcod,
                     k_ctn17c00.empsgl   attribute(reverse)
  end if
  input by name k_ctn17c00.ciaempcod without defaults
      before field ciaempcod
         if k_ctn17c00.ciaempcod is not null then
            exit input
         end if
         display by name k_ctn17c00.ciaempcod attribute(reverse)
      after field ciaempcod
         if k_ctn17c00.ciaempcod is not null then
            #caso altere empresa Buscar descricao da empresa
            call cty14g00_empresa(1, k_ctn17c00.ciaempcod)
                 returning l_ret,
                           l_mensagem,
                           k_ctn17c00.empsgl
            if l_ret <> 1 then
               #problemas ao buscar empresa
               let k_ctn17c00.ciaempcod = null
               error l_mensagem
               next field ciaempcod
            end if
         else
            let k_ctn17c00.empsgl = "TODAS"
         end if
         display by name k_ctn17c00.ciaempcod,
                         k_ctn17c00.empsgl   attribute(reverse)
      on key (interrupt)
         exit input
  end input

  call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2

  open c_ctn17c00_004 using l_data

  foreach c_ctn17c00_004 into ws.lcvcod,
                            a_ctn17c00[arr_aux].avivclcod,
                            a_ctn17c00[arr_aux].avivclgrp,
                            a_ctn17c00[arr_aux].avivclmdl,
                            a_ctn17c00[arr_aux].avivcldes,
                            ws.avivclstt,
                            a_ctn17c00[arr_aux].frqvlr,
                            a_ctn17c00[arr_aux].rduvlr,
                            a_ctn17c00[arr_aux].isnvlr,
                            a_ctn17c00[arr_aux].obs,
                            ws.lcvlojtip,
                            ws.lcvregprccod,
                            a_ctn17c00[arr_aux].lcvvcldiavlr,
                            a_ctn17c00[arr_aux].lcvvclsgrvlr

    if ws.avivclstt <> "A" then
       continue foreach
    end if


    if k_ctn17c00.lcvcod is not null  and
       ws.lcvcod <> k_ctn17c00.lcvcod then
       continue foreach
    end if

    if k_ctn17c00.lcvlojtip    <> ws.lcvlojtip    or
       k_ctn17c00.lcvregprccod <> ws.lcvregprccod then
       continue foreach
    end if

    if param.tipo_ordenacao = "A" then # ---> MOSTRAR PRIMEIRAMENTE OS VEICULOS C/AR CONDICIONADO

       if a_ctn17c00[arr_aux].avivclgrp = "B" then
          let am_veiculos[arr_aux].avivclgrp = 0
       else
          let am_veiculos[arr_aux].avivclgrp = l_aux_seq
          let l_aux_seq = l_aux_seq + 1
       end if

       let am_veiculos[arr_aux].grupo_original = a_ctn17c00[arr_aux].avivclgrp
       let am_veiculos[arr_aux].avivclmdl      = a_ctn17c00[arr_aux].avivclmdl
       let am_veiculos[arr_aux].avivclcod      = a_ctn17c00[arr_aux].avivclcod
       let am_veiculos[arr_aux].avivcldes      = a_ctn17c00[arr_aux].avivcldes
       let am_veiculos[arr_aux].lcvvcldiavlr   = a_ctn17c00[arr_aux].lcvvcldiavlr
       let am_veiculos[arr_aux].lcvvclsgrvlr   = a_ctn17c00[arr_aux].lcvvclsgrvlr
       let am_veiculos[arr_aux].obs            = a_ctn17c00[arr_aux].obs

    end if

    let arr_aux = arr_aux + 1

    if arr_aux > 100 then
       error " Limite excedido, pesquisa com mais de 100 veiculos!"
       exit foreach
    end if

  end foreach

 if arr_aux = 1  then
    error " Nao foram cadastrados tipos de veiculo para locacao! "
 end if

 message " (F17)Abandona, (F8)Seleciona"

 let m_qtd_veic = (arr_aux -1)

 if m_qtd_veic > 0 then

    if param.tipo_ordenacao = "A" then
       call ctn17c00_ordena_array(m_qtd_veic)

       for l_contador = 1 to m_qtd_veic

          let a_ctn17c00[l_contador].avivclmdl    = am_veiculos[l_contador].avivclmdl
          let a_ctn17c00[l_contador].avivclgrp    = am_veiculos[l_contador].grupo_original
          let a_ctn17c00[l_contador].avivclcod    = am_veiculos[l_contador].avivclcod
          let a_ctn17c00[l_contador].avivcldes    = am_veiculos[l_contador].avivcldes
          let a_ctn17c00[l_contador].lcvvcldiavlr = am_veiculos[l_contador].lcvvcldiavlr
          let a_ctn17c00[l_contador].lcvvclsgrvlr = am_veiculos[l_contador].lcvvclsgrvlr
          let a_ctn17c00[l_contador].frqvlr       = am_veiculos[l_contador].frqvlr
          let a_ctn17c00[l_contador].rduvlr       = am_veiculos[l_contador].rduvlr
          let a_ctn17c00[l_contador].isnvlr       = am_veiculos[l_contador].isnvlr
          let a_ctn17c00[l_contador].obs          = am_veiculos[l_contador].obs

       end for

    end if

 end if

 call set_count(arr_aux-1)

 display array  a_ctn17c00 to s_ctn17c00.*
    on key (interrupt)
       initialize a_ctn17c00  to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 let int_flag = false
 close window  w_ctn17c00

 return a_ctn17c00[arr_aux].avivclcod

end function

#--------------------------------#
function ctn17c00_frota(param)
#--------------------------------#
#  PSI 2015-15499/IN             #
# Eliane K, Fornax - 19/11/2015  #
#--------------------------------#

  define param      record
     lcvcod         like datklocadora.lcvcod,
     aviestcod      like datkavislocal.aviestcod,
     tipo_ordenacao char(01), # N -> ORDENACAO NORMAL
                              # A -> VEICULOS C/AR CONDICIONADO EM PRIMEIRO LUGAR
     ciaempcod      like datravsemp.ciaempcod,         
     avialgmtv      like datmavisrent.avialgmtv,       
     clscod         like abbmclaus.clscod,
     tipo_veiculo   like datkitavclcrgtip.itavclcrgtipcod       
  end record

  define k_ctn17c00 record
     lcvcod         like datklocadora.lcvcod    ,
     lcvnom         like datklocadora.lcvnom    ,
     lcvextcod      like datkavislocal.lcvextcod,
     aviestnom      like datkavislocal.aviestnom,
     lcvlojtip      like datkavislocal.lcvlojtip,
     lcvregprccod   like datkavislocal.lcvregprccod,
     ciaempcod      like datravsemp.ciaempcod,     
     empsgl         like gabkemp.empsgl            
  end record

  define a_ctn17c00 array[100] of record
     avivclmdl      like datkavisveic.avivclmdl,
     avivclgrp      like datkavisveic.avivclgrp,
     avivclcod      like datkavisveic.avivclcod,
     avivcldes      like datkavisveic.avivcldes,
     lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr,
     lcvvclsgrvlr   like datklocaldiaria.lcvvclsgrvlr,
     isnvlr         like datkavisveic.isnvlr,
     rduvlr         like datkavisveic.rduvlr,
     frqvlr         like datkavisveic.frqvlr,
     obs            like datkavisveic.obs
  end record

  define arr_aux    smallint
  define scr_aux    smallint,
         l_aux_seq  smallint,
         l_contador smallint,
         l_ret      smallint,         
         l_mensagem char(60),
	 l_sql      char(2000)

  define ws         record
     lcvcod         like datkavisveic.lcvcod     ,
     avivclstt      like datkavisveic.avivclstt  ,
     lcvlojtip      like datkavislocal.lcvlojtip ,
     lcvregprccod   like datkavislocal.lcvregprccod
  end record

  define l_cponom    like   datkdominio.cponom 
  define l_cpodes     char (2)     #like   datkdominio.cpodes


  define l_data      date,
         l_hora2     datetime hour to minute

  define l_grupo     char(1000)

  initialize k_ctn17c00, ws, a_ctn17c00, am_veiculos to null
  

  let arr_aux = null
  let scr_aux = null
  let l_aux_seq  = null
  let l_contador = null
  let l_ret      = null
  let l_mensagem = null
  let l_grupo    = null
  let l_cponom   = null
  let l_cpodes   = null

  if m_ctn17c00_prep is null or
     m_ctn17c00_prep <> true then
     call ctn17c00_prepare()
  end if

  open window w_ctn17c00 at  04,02 with form "ctn17c00"
              attribute(form line first)

  let arr_aux    = 1
  let l_aux_seq  = 1
  let m_qtd_veic = 0
  let l_contador = 0
  let int_flag = false
  clear form

  if param.lcvcod    is not null   or
     param.aviestcod is not null   then
     let k_ctn17c00.lcvcod = param.lcvcod

     open c_ctn17c00_002 using k_ctn17c00.lcvcod
     whenever error continue
     fetch c_ctn17c00_002 into k_ctn17c00.lcvnom
     whenever error stop

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na localizacao da locadora. AVISE A INFORMATICA!"
        close c_ctn17c00_002
        return a_ctn17c00[arr_aux].avivclcod
     end if

     close c_ctn17c00_002

     display by name k_ctn17c00.lcvcod, k_ctn17c00.lcvnom

     open c_ctn17c00_003 using param.lcvcod, param.aviestcod
     whenever error continue
     fetch c_ctn17c00_003 into k_ctn17c00.lcvextcod,
                               k_ctn17c00.aviestnom,
                               k_ctn17c00.lcvlojtip,
                               k_ctn17c00.lcvregprccod
     whenever error stop

     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na localizacao da loja. AVISE A INFORMATICA!"
        close c_ctn17c00_003
        return a_ctn17c00[arr_aux].avivclcod
     end if

     close c_ctn17c00_003

     display by name k_ctn17c00.lcvextcod,
                     k_ctn17c00.aviestnom
  else
     return a_ctn17c00[arr_aux].avivclcod
  end if
  
  if param.ciaempcod is not null then
     let k_ctn17c00.ciaempcod = param.ciaempcod
     #Buscar descrição da empresa
     call cty14g00_empresa(1, k_ctn17c00.ciaempcod)
                 returning l_ret,
                           l_mensagem,
                           k_ctn17c00.empsgl
     display by name k_ctn17c00.ciaempcod,
                     k_ctn17c00.empsgl   attribute(reverse)
  end if
  input by name k_ctn17c00.ciaempcod without defaults
      before field ciaempcod
         if k_ctn17c00.ciaempcod is not null then
            exit input
         end if
         display by name k_ctn17c00.ciaempcod attribute(reverse)
      after field ciaempcod
         if k_ctn17c00.ciaempcod is not null then
            #caso altere empresa Buscar descricao da empresa
            call cty14g00_empresa(1, k_ctn17c00.ciaempcod)
                 returning l_ret,
                           l_mensagem,
                           k_ctn17c00.empsgl
            if l_ret <> 1 then
               #problemas ao buscar empresa
               let k_ctn17c00.ciaempcod = null
               error l_mensagem
               next field ciaempcod
            end if
         else
            let k_ctn17c00.empsgl = "TODAS"
         end if
         display by name k_ctn17c00.ciaempcod,
                         k_ctn17c00.empsgl   attribute(reverse)
      on key (interrupt)
         exit input
  end input

  let l_grupo = ''

  if param.tipo_veiculo <> '1' and
     param.tipo_veiculo <> '2' and
     param.tipo_veiculo <> '3' and
     param.tipo_veiculo <> '4' and
     param.tipo_veiculo <> '51' and
     param.tipo_veiculo <> '52' then

     let l_grupo = ''

  else


  if  param.tipo_veiculo = '1' then    #Carro Popular

          let l_cponom = ' '
	  let l_grupo = " and a.avivclgrp = 'B' "

  else    # Carro Medio, Esportivo, Luxo e Utilitario Leve e Pesado
          let l_cponom = 'FRTLOCADORA14'
	  let l_grupo =  " and a.avivclgrp in ( 'B', '"  

          let l_sql = ' select cpodes '
                     ,' from datkdominio '
	             ,' where cponom = ? '
	             ,' and  cpocod = ?'

          prepare p_ctn17c00_005 from l_sql
          declare c_ctn17c00_005 cursor for p_ctn17c00_005

          open c_ctn17c00_005 using l_cponom, k_ctn17c00.lcvcod
          fetch c_ctn17c00_005 into l_cpodes

	  if l_cpodes is not null then
	     let l_grupo = l_grupo clipped, l_cpodes clipped

            if param.tipo_veiculo = 51 or param.tipo_veiculo = 52 then #PICKUP
                let l_grupo = l_grupo clipped, "', '"
	        close c_ctn17c00_005
        
	        initialize l_cponom, l_cpodes to null
                let l_cponom = 'FRTLOCADORAPIC'
                open c_ctn17c00_005 using l_cponom, k_ctn17c00.lcvcod
	        fetch c_ctn17c00_005 into l_cpodes
                
		if l_cpodes is not null then
	           let l_grupo = l_grupo clipped, l_cpodes clipped, " ')"
                else
		   let l_grupo = ''
                end if
                close c_ctn17c00_005
            else
	        let l_grupo = l_grupo clipped, " ')"
	        close c_ctn17c00_005
            end if
          else
	   let l_grupo = ''
          end if
   end if
 end if

  let l_grupo = l_grupo clipped
display "l_grupo = ", l_grupo

  if l_grupo is not null then     

display " SQL"
   let l_sql = " select a.lcvcod, ",
                     " a.avivclcod, ",
                     " a.avivclgrp, ",
                     " a.avivclmdl, ",
                     " a.avivcldes, ",
                     " a.avivclstt, ",
                     " a.frqvlr, ",
                     " a.rduvlr, ",
                     " a.isnvlr, ",
                     " a.obs, ",
                     " b.lcvlojtip, ",
                     " b.lcvregprccod, ",
                     " b.lcvvcldiavlr, ",
                     " b.lcvvclsgrvlr ",
                " from datkavisveic a, ",
                     " datklocaldiaria b ",
               " where a.lcvcod = ? ",
                 " and a.avivclcod > 0 ",
	         " and a.avivclstt = 'A' ",
		 l_grupo clipped,
                 " and b.lcvcod = a.lcvcod ",
                 " and b.avivclcod = a.avivclcod ",
                 " and ? between b.viginc ",
                 " and b.vigfnl ",
                 " and 1 between b.fxainc ",
                 " and b.fxafnl ",
               " order by avivclgrp, ",
                        " avivclcod "
	
  prepare p_ctn17c00_006 from l_sql	
  declare c_ctn17c00_006 cursor for p_ctn17c00_006
 
  call cts40g03_data_hora_banco(2)
	returning l_data, l_hora2

  open c_ctn17c00_006 using k_ctn17c00.lcvcod, l_data 
  
  foreach c_ctn17c00_006 into ws.lcvcod,
                            a_ctn17c00[arr_aux].avivclcod,
                            a_ctn17c00[arr_aux].avivclgrp,
                            a_ctn17c00[arr_aux].avivclmdl,
                            a_ctn17c00[arr_aux].avivcldes,
                            ws.avivclstt,
                            a_ctn17c00[arr_aux].frqvlr,
                            a_ctn17c00[arr_aux].rduvlr,
                            a_ctn17c00[arr_aux].isnvlr,
                            a_ctn17c00[arr_aux].obs,
                            ws.lcvlojtip,
                            ws.lcvregprccod,
                            a_ctn17c00[arr_aux].lcvvcldiavlr,
                            a_ctn17c00[arr_aux].lcvvclsgrvlr

    if ws.avivclstt <> "A" then
       continue foreach
    end if

    if k_ctn17c00.lcvcod is not null  and
       ws.lcvcod <> k_ctn17c00.lcvcod then
       continue foreach
    end if


    if k_ctn17c00.lcvlojtip    <> ws.lcvlojtip    or
       k_ctn17c00.lcvregprccod <> ws.lcvregprccod then
       continue foreach
    end if

    if param.tipo_ordenacao = "A" then # ---> MOSTRAR PRIMEIRAMENTE OS VEICULOS C/AR CONDICIONADO

       if a_ctn17c00[arr_aux].avivclgrp = "B" then
          let am_veiculos[arr_aux].avivclgrp = 0
       else
          let am_veiculos[arr_aux].avivclgrp = l_aux_seq
          let l_aux_seq = l_aux_seq + 1
       end if

       let am_veiculos[arr_aux].grupo_original = a_ctn17c00[arr_aux].avivclgrp
       let am_veiculos[arr_aux].avivclmdl      = a_ctn17c00[arr_aux].avivclmdl
       let am_veiculos[arr_aux].avivclcod      = a_ctn17c00[arr_aux].avivclcod
       let am_veiculos[arr_aux].avivcldes      = a_ctn17c00[arr_aux].avivcldes
       let am_veiculos[arr_aux].lcvvcldiavlr   = a_ctn17c00[arr_aux].lcvvcldiavlr
       let am_veiculos[arr_aux].lcvvclsgrvlr   = a_ctn17c00[arr_aux].lcvvclsgrvlr
       let am_veiculos[arr_aux].obs            = a_ctn17c00[arr_aux].obs

    end if
	
    let arr_aux = arr_aux + 1

    if arr_aux > 100 then
       error " Limite excedido, pesquisa com mais de 100 veiculos!"
       exit foreach
    end if


  end foreach

  end if       # l_grupo vazio

 if arr_aux = 1  then
    error " Nao foram cadastrados tipos de veiculo para locacao! "
 end if

 message " (F17)Abandona, (F8)Seleciona"

 let m_qtd_veic = (arr_aux -1)

 if m_qtd_veic > 0 then

    if param.tipo_ordenacao = "A" then
       call ctn17c00_ordena_array(m_qtd_veic)

       for l_contador = 1 to m_qtd_veic

          let a_ctn17c00[l_contador].avivclmdl    = am_veiculos[l_contador].avivclmdl
          let a_ctn17c00[l_contador].avivclgrp    = am_veiculos[l_contador].grupo_original
          let a_ctn17c00[l_contador].avivclcod    = am_veiculos[l_contador].avivclcod
          let a_ctn17c00[l_contador].avivcldes    = am_veiculos[l_contador].avivcldes
          let a_ctn17c00[l_contador].lcvvcldiavlr = am_veiculos[l_contador].lcvvcldiavlr
          let a_ctn17c00[l_contador].lcvvclsgrvlr = am_veiculos[l_contador].lcvvclsgrvlr
          let a_ctn17c00[l_contador].frqvlr       = am_veiculos[l_contador].frqvlr
          let a_ctn17c00[l_contador].rduvlr       = am_veiculos[l_contador].rduvlr
          let a_ctn17c00[l_contador].isnvlr       = am_veiculos[l_contador].isnvlr
          let a_ctn17c00[l_contador].obs          = am_veiculos[l_contador].obs


       end for

    end if

 end if

 call set_count(arr_aux-1)

 display array  a_ctn17c00 to s_ctn17c00.*
    on key (interrupt)
       initialize a_ctn17c00  to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 let int_flag = false
 close window  w_ctn17c00

 return a_ctn17c00[arr_aux].avivclcod

end function

