###############################################################################
#Nome do Modulo: CTO00M09                                              Danilo #
#                                                                    Jun/2010 #
#Responsável por carregar os pop-ups do                                       #
#registro e atendimento da central de operações                               #
#PSI 257664                                                                   #
###############################################################################

database porto

define m_cto00m09_prep smallint
define like   char(40)

#-------------------------------------------------------------------------------
 function cto00m09_prepare()
#-------------------------------------------------------------------------------

  define l_sql  char(2000)
  #--seleciona codigo e descrição da tabela de dominios
    let l_sql = "select cpodes "
                     ,",cpocod "
               ,"from   datkdominio "
               ,"where  cponom = ? "
               ,"order by cpodes "
    prepare pcto00m09001 from l_sql
    declare ccto00m09001 cursor for pcto00m09001
  #--seleciona codigo e descrição dos assuntos
    let l_sql =  "select c24astdes "
                      ,",c24astcod "
                ,"from   datkassunto "
                ,"where  c24astagp = 'CO' "
                ,"order by c24astdes "
    prepare pcto00m09002 from l_sql
    declare ccto00m09002 cursor for pcto00m09002

  #--seleciona codigo e descrição dos motivos
    let l_sql =  "select rcuccsmtvdes "
                      ,",rcuccsmtvcod "
                ,"from   datkrcuccsmtv "
                ,"where  c24astcod = ? "
                ," order by rcuccsmtvdes "
    prepare pcto00m09003 from l_sql
    declare ccto00m09003 cursor for pcto00m09003
  #--seleciona dados dos funcionarios
    let l_sql =  "select funnom "
                      ,",funmat "
                      ,",empcod "
                      ,",usrtip "
                 ,"from  isskfunc "
                 ,"where funmat = ? "
                 ,"and   rhmfunsitcod = 'A' "
    prepare pcto00m09004 from l_sql
    declare ccto00m09004 cursor for pcto00m09004
  let m_cto00m09_prep = true

end function

#-------------------------------------------------------------------------------
 function cto00m09(tppopup,ws_cdassunto, ws_funmat, filtro, tpfiltro)
#-------------------------------------------------------------------------------

  #-------------------------Definição de variaveis------------------------------
 define tppopup      smallint                     #Tipo do pop-up
 define ws_cdassunto like datkrcuccsmtv.c24astcod #Código do Assunto
 define ws_funmat    like isskfunc.funmat         #Matricula do funcionário
 define filtro       char(100)                    #Paramentro do prepare
 define tpfiltro     char(3)                      #tipo de tratativa
 define arr_aux      smallint                     #Linha da tela
 define titulo       char(40)                     #Titulo do pop-up
 define ws_aux       char(20)                     #Variavel auxiliar geral
 define l_sql        char(2000)                   #Query SQL
 define a_dominios array[30] of record            #Lista de tipo de contato ou
    cpodes           like datkdominio.cpodes,     #tipo de cliente
    cpocod           like datkdominio.cpocod
 end record

 define ws_dominios     record                    #Tipo de contato ou tipo de
    cpodes         like datkdominio.cpodes,       #cliente que retorna
    cpocod         like datkdominio.cpocod
 end record
 define a_assuntos array[200] of record           #Lista de assuntos
    c24astdes      like datkassunto.c24astdes,
    c24astcod      like datkassunto.c24astcod
 end record
 define ws_assuntos        record                 #Assunto que retorna
    c24astdes      like datkassunto.c24astdes,
    c24astcod      like datkassunto.c24astcod
 end record
 define a_subassuntos  array[200] of record       #Lista de subassuntos
    rcuccsmtvdes   like datkrcuccsmtv.rcuccsmtvdes,
    rcuccsmtvcod   like datkrcuccsmtv.rcuccsmtvcod
 end record
 define ws_subassuntos       record               #Subassunto que retorna
    rcuccsmtvdes   like datkrcuccsmtv.rcuccsmtvdes,
    rcuccsmtvcod   like datkrcuccsmtv.rcuccsmtvcod
 end record
 define a_funcionarios  array[20] of record       #Lista de funcionários
    funnom         like isskfunc.funnom,
    funmat         like isskfunc.funmat
 end record
 define a_funcionarios_comp  array[20] of record  #Lista de funcionários
    empcod              like isskfunc.empcod,
    usrtip              like isskfunc.usrtip
 end record
 define ws_funcionarios        record             #Funcionário que retorna
    funnom              like isskfunc.funnom,
    funmat              like isskfunc.funmat,
    empcod              like isskfunc.empcod,
    usrtip              like isskfunc.usrtip
 end record
 define a_identificacao  array[300] of record     #Lista de identificação geral
    descricao                  char(100),
    cod            char(100)
 end record
 define ws_identificacao       record             #Identificação geral retorna
    descricao                   char(100),
    cod             char(100)
 end record
 #------------------------Inicialização das variaveis---------------------------
 let arr_aux  = 1
 initialize ws_dominios.*
           ,ws_assuntos.*
           ,ws_assuntos.*
           ,ws_subassuntos.*
           ,ws_subassuntos.*
           ,ws_funcionarios.*
           ,ws_identificacao.*
           ,a_dominios
           ,a_assuntos
           ,a_subassuntos
           ,a_funcionarios
           ,a_identificacao
           ,ws_aux to null
 if m_cto00m09_prep is null or
      m_cto00m09_prep <> true then
      call cto00m09_prepare()
 end if
 #-------------verifica qual tipo de pop-up carregar para o usuario-------------
 case tppopup
      #-------------------------------caso 1------------------------------------
      when 1
        #--Abre cursor enviando variaveis de tratamento
        let ws_aux = "psocor_TpContato"
        Open ccto00m09001 using ws_aux
        #--Percorre cursor trantando seus resultados
        foreach ccto00m09001 into a_dominios[arr_aux].cpodes
                                 ,a_dominios[arr_aux].cpocod
          let arr_aux = arr_aux + 1
          if arr_aux > 30  then
            error " Limite excedido. Foram encontrados mais de 30 tipos."
            exit foreach
          end if
        end foreach
        #--Abre pop-up e verifica valor selecionado.
        if arr_aux > 1  then
          if arr_aux = 2  then
            let ws_dominios.cpocod = a_dominios[arr_aux - 1].cpocod
          else
            open window cto00m09 at 12,52 with form "cto00m09"
            attribute(form line 1, border)
            let titulo = "Contato"
            display titulo to titulo
            message " (F8)Seleciona"
            call set_count(arr_aux-1)
            display array a_dominios to s_cto00m09.*
            on key (interrupt,control-c)
              initialize a_dominios     to null
              initialize ws_dominios.* to null
              exit display
            on key (F8)
              let arr_aux = arr_curr()
              let ws_dominios.cpocod = a_dominios[arr_aux].cpocod
              let ws_dominios.cpodes = a_dominios[arr_aux].cpodes
              exit display
            end display
            close window cto00m09
          end if
        else
          error " Nao foi encontrado nenhum registro!"
        end if
        #--retorna valor selecionado
        return ws_dominios.*
      #-------------------------------caso 2------------------------------------
      when 2
        #--Abre cursor enviando variaveis de tratamento
        let ws_aux = "psocor_TpCliente"
        Open ccto00m09001 using ws_aux
        #--Percorrer cursor trantando seus resultados
        foreach ccto00m09001 into a_dominios[arr_aux].cpodes
                                 ,a_dominios[arr_aux].cpocod
          let arr_aux = arr_aux + 1
          if arr_aux > 200  then
            error " Limite excedido. Foram encontrados mais de 200 tipos."
            exit foreach
          end if
        end foreach
        #--Abre pop-up e verifica valor selecionado.
        if arr_aux > 1  then
          if arr_aux = 2  then
            let ws_dominios.cpocod = a_dominios[arr_aux - 1].cpocod
          else
            open window cto00m09 at 12,52 with form "cto00m09"
            attribute(form line 1, border)
            let titulo = "Clientes"
            display titulo to titulo
            message " (F8)Seleciona"
            call set_count(arr_aux-1)
            display array a_dominios to s_cto00m09.*
            on key (interrupt,control-c)
            initialize a_dominios     to null
            initialize ws_dominios.* to null
            exit display
            on key (F8)
            let arr_aux = arr_curr()
            let ws_dominios.cpocod = a_dominios[arr_aux].cpocod
            let ws_dominios.cpodes = a_dominios[arr_aux].cpodes
            exit display
            end display
            close window cto00m09
          end if
        else
          error " Nao foi encontrado nenhum registro!"
        end if
        #--retorna valor selecionado
        return ws_dominios.*
      #-------------------------------caso 3------------------------------------
      when 3
        #--Abre cursor
        open ccto00m09002
        #--Percorrer cursor trantando seus resultados
        foreach ccto00m09002 into a_assuntos[arr_aux].c24astdes
                                 ,a_assuntos[arr_aux].c24astcod
          let arr_aux = arr_aux + 1
          if arr_aux > 200  then
            error " Limite excedido. Foram encontrados mais de 200 assuntos."
            exit foreach
          end if
        end foreach
        #--Abre pop-up e verifica valor selecionado.
        if arr_aux > 1  then
          if arr_aux = 2  then
            let ws_assuntos.c24astcod = a_assuntos[arr_aux - 1].c24astcod
          else
            open window cto00m09 at 12,17 with form "cto00m09a"
            attribute(form line 1, border)
            let titulo = "Tipos de Assunto"
            display titulo to titulo
            message " (F8)Seleciona"
            call set_count(arr_aux-1)
            display array a_assuntos to s_cto00m09.*
            on key (interrupt,control-c)
            initialize a_assuntos  to null
            initialize ws_assuntos.* to null
            exit display
            on key (F8)
            let arr_aux = arr_curr()
            let ws_assuntos.c24astcod = a_assuntos[arr_aux].c24astcod
            let ws_assuntos.c24astdes = a_assuntos[arr_aux].c24astdes
            exit display
            end display
            close window cto00m09
          end if
        else
          error " Nao foi encontrado nenhum registro!"
        end if
        #--retorna valor selecionado
        return ws_assuntos.*
      #-------------------------------caso 4------------------------------------
      when 4
        #--abre cursor
        open ccto00m09003 using ws_cdassunto
        #--Percorrer cursor trantando seus resultados
        foreach ccto00m09003 into a_subassuntos[arr_aux].rcuccsmtvdes
                                 ,a_subassuntos[arr_aux].rcuccsmtvcod
          let arr_aux = arr_aux + 1
          if arr_aux > 200  then
            error " Limite excedido. Foram encontrados mais de 200 Subassuntos."
            exit foreach
          end if
        end foreach
        #--Abre pop-up e verifica valor selecionado.
        if arr_aux > 1  then
          if arr_aux = 2  then
            let ws_subassuntos.rcuccsmtvcod = a_subassuntos[arr_aux - 1].rcuccsmtvcod
          else
            open window cto00m09 at 12,17 with form "cto00m09a"
                                            attribute(form line 1, border)
            let titulo = "Tipos de SubAssuntos"
            display titulo to titulo
            message " (F8)Seleciona"
            call set_count(arr_aux-1)
            display array a_subassuntos to s_cto00m09.*
            on key (interrupt,control-c)
            initialize a_subassuntos  to null
            initialize ws_subassuntos.* to null
            exit display
            on key (F8)
            let arr_aux = arr_curr()
            let ws_subassuntos.rcuccsmtvcod = a_subassuntos[arr_aux].rcuccsmtvcod
            let ws_subassuntos.rcuccsmtvdes = a_subassuntos[arr_aux].rcuccsmtvdes
            exit display
            end display
            close window cto00m09
          end if
        else
          error " Nao foi encontrado nenhum registro!"
        end if
        #--retorna valor selecionado
        return ws_subassuntos.*
      #-------------------------------caso 5------------------------------------
      when 5
        #--Abre cursor
        open ccto00m09004 using ws_funmat
        #--Percorrer cursor trantando seus resultados
        foreach ccto00m09004 into a_funcionarios[arr_aux].funnom
                                 ,a_funcionarios[arr_aux].funmat
                                 ,a_funcionarios_comp[arr_aux].empcod
                                 ,a_funcionarios_comp[arr_aux].usrtip
          let arr_aux = arr_aux + 1
          if arr_aux > 20  then
            error " Limite excedido. Foram encontrados mais de 200 Funcionários"
            exit foreach
          end if
        end foreach
        #--Abre pop-up e verifica valor selecionado.
        if arr_aux > 1  then
          if arr_aux = 2  then
            let ws_funcionarios.funmat  = a_funcionarios[arr_aux - 1].funmat
          else
            open window cto00m09 at 12,17 with form "cto00m09a"
                                            attribute(form line 1, border)
            let titulo = "Funcionários encontrados"
            display titulo to titulo
            message " (F8)Seleciona"
            call set_count(arr_aux-1)
            display array a_funcionarios to s_cto00m09.*
            on key (interrupt,control-c)
            initialize a_funcionarios  to null
            initialize ws_funcionarios.* to null
            exit display
            on key (F8)
            let arr_aux = arr_curr()
            let ws_funcionarios.funmat  = a_funcionarios[arr_aux].funmat
            let ws_funcionarios.funnom = a_funcionarios[arr_aux].funnom
            let ws_funcionarios.empcod =a_funcionarios_comp[arr_aux].empcod
            let ws_funcionarios.usrtip =a_funcionarios_comp[arr_aux].usrtip
            exit display
            end display
            close window cto00m09
          end if
        else
          error " Nao foi encontrado nenhum registro!"
        end if
        #--retorna valor selecionado
        return ws_funcionarios.*
      #-------------------------------caso 6------------------------------------
      when 6
        #--se tipo do filtro for 3(Clinica) ou 8 (Prestador) faça
        if tpfiltro = 3 or tpfiltro = 8 then
          #--seleciona dados do prestador / clinica veterinaria, busca por nome
          let l_sql =  "Select nomgrr, pstcoddig "
                      ,"from dpaksocor "
                      ,"where nomgrr matches '*"
                      ,filtro clipped
                      ,"*' order by nomgrr"
          prepare pcto00m09005 from l_sql
          declare ccto00m09005 cursor for pcto00m09005
          #--Percorrer cursor trantando seus resultados
          foreach ccto00m09005 into a_identificacao[arr_aux].descricao
                                   ,a_identificacao[arr_aux].cod
            let arr_aux = arr_aux + 1
            if arr_aux > 300  then
              error " Limite excedido. Foram encontrados mais de 300 identificações"
              exit foreach
            end if
          end foreach
        end if
        #--se tipo do filtro for 6(Locadora) faça
        if tpfiltro = 6 then
          #--seleciona dados da locadora, busca por nome
          let l_sql =  "Select lcvnom, lcvcod "
                      ,"from datklocadora "
                      ,"where lcvnom matches '*"
                      ,filtro clipped
                      ,"*' order by lcvnom"
          prepare pcto00m09006 from l_sql
          declare ccto00m09006 cursor for pcto00m09006
          #--Percorrer cursor trantando seus resultados
          foreach ccto00m09006 into a_identificacao[arr_aux].descricao
                                   ,a_identificacao[arr_aux].cod
            let arr_aux = arr_aux + 1
            if arr_aux > 300  then
              error " Limite excedido. Foram encontrados mais de 300 identificações"
              exit foreach
            end if
          end foreach
        end if
        #--se tipo do filtro for 12(Socorrista) faça
        if tpfiltro = 12 then
          #--seleciona dados do socorrista, busca por nome
          let l_sql =  "Select srrnom, srrcoddig "
                      ,"from   datksrr "
                      ,"where  srrnom matches '*"
                      ,filtro clipped
                     ,"*' order by srrnom"
          prepare pcto00m09007 from l_sql
          declare ccto00m09007 cursor for pcto00m09007
          #--Percorrer cursor trantando seus resultados
          foreach ccto00m09007 into a_identificacao[arr_aux].descricao
                                   ,a_identificacao[arr_aux].cod
            let arr_aux = arr_aux + 1
            if arr_aux > 300  then
              error " Limite excedido. Foram encontrados mais de 300 identificações"
              exit foreach
            end if
          end foreach
        end if

        #--Abre pop-up e verifica valor selecionado.
        if arr_aux > 1  then
          if arr_aux = 2  then
            let ws_identificacao.cod = a_identificacao[arr_aux - 1].cod
          else
            open window cto00m09 at 12,17 with form "cto00m09a"
                                            attribute(form line 1, border)
            let titulo = "Opções de seleção"
            display titulo to titulo
            message " (F8)Seleciona"
            call set_count(arr_aux-1)
            display array a_identificacao to s_cto00m09.*
            on key (interrupt,control-c)
            initialize a_identificacao  to null
            initialize ws_identificacao.* to null
            exit display
            on key (F8)
            let arr_aux = arr_curr()
            let ws_identificacao.cod  = a_identificacao[arr_aux].cod
            let ws_identificacao.descricao = a_identificacao[arr_aux].descricao
            exit display
            end display
            close window cto00m09
          end if
        else
          error " Nao foi encontrado nenhum registro!"
        end if
        #--retorna valor selecionado
        return ws_identificacao.*
      #----------------------------Outro Caso-----------------------------------
      otherwise
        error "teste"
 end case
end function

