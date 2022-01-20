################################################################################
# Nome do Modulo: CTB12M02                                            Gilberto #
#                                                                      Marcelo #
# Pesquisa prestador por Nome de Guerra, Razao social ou por O.S.     Fev/1997 #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
# 13/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.      #
#------------------------------------------------------------------------------#
# 28/03/2001  PSI 12758-2  Wagner       Incluir pesquisa por cidade/uf/situacao#
#------------------------------------------------------------------------------#
# 06/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador       #
#                                       B-Bloqueado.                           #
#------------------------------------------------------------------------------#
# 12/12/2006  PSI 205206   Priscila     Incluir empresa no filtro do prestador #
################################################################################

database porto

#------------------------------------------------------------------------
function ctb12m02(param)
#------------------------------------------------------------------------

 define param         record
    pstcoddig         like dbsmopg.pstcoddig
 end record

 define d_ctb12m02    record
    nomepsq           char(31),
    tipo              char(01),
    ciaempcod         like dparpstemp.ciaempcod,    #PSI 205206
    empsgl            like gabkemp.empsgl,          #PSI 205206
    pestipc           like dbsmopg.pestip,
    cgccpfnumc        like dbsmopg.cgccpfnum,
    cgcordc           like dbsmopg.cgcord,
    cgccpfdigc        like dbsmopg.cgccpfdig,
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like dbsmopgitm.atdsrvnum,
    atdsrvano         like dbsmopgitm.atdsrvano,
    endcid_d          like dpaksocor.endcid,
    endufd_d          like dpaksocor.endufd,
    prssitcod         like dpaksocor.prssitcod
 end record

 define a_ctb12m02 array[80] of record
    nomrazsoc         like dpaksocor.nomrazsoc   ,
    pstcoddig         like dpaksocor.pstcoddig   ,
    situacao          char (10)                  ,
    nomgrr            like dpaksocor.nomgrr      ,
    pestip            like dpaksocor.pestip      ,
    cgccpfnum         like dpaksocor.cgccpfnum   ,
    cgcord            like dpaksocor.cgcord      ,
    cgccpfdig         like dpaksocor.cgccpfdig   ,
    endlgd            like dpaksocor.endlgd      ,
    endbrr            like dpaksocor.endbrr      ,
    endcid            like dpaksocor.endcid      ,
    endufd            like dpaksocor.endufd      ,
    endcep            like dpaksocor.endcep      ,
    endcepcmp         like dpaksocor.endcepcmp   ,
    dddcod            like dpaksocor.dddcod      ,
    teltxt            like dpaksocor.teltxt
 end record

 define ws            record
    comando1          char(800)                  , #select
    comando2          char(100)                  , #from
    comando3          char(200)                  , #where    #PSI 205206
    nomepsq           char(36)                   ,
    tam_nomepsq       smallint                   ,
    prssitcod         like dpaksocor.prssitcod   ,
    atdprscod         like datmservico.atdprscod ,
    cgccpfdig         like dbsmopg.cgccpfdig     ,
    seleciona         char (01),
    prssitdes         char (10),
    mpacidcod         like datkmpacid.mpacidcod
 end record

 define arr_aux       smallint
 define aux_contpsq   smallint
 
 define l_ret         smallint,
        l_mensagem    char(50)

 initialize ws.*          to null
 initialize a_ctb12m02    to null
 initialize d_ctb12m02.*  to null
  
 open window w_ctb12m02 at 06,02 with form "ctb12m02"
             attribute(form line first)

 let aux_contpsq        = 0

 while true

    clear form
    initialize ws.*          to null
    initialize a_ctb12m02    to null
    initialize d_ctb12m02.ciaempcod , d_ctb12m02.empsgl,    #PSI 205206
               d_ctb12m02.tipo      , d_ctb12m02.pestipc,
               d_ctb12m02.cgccpfnumc, d_ctb12m02.cgcordc,
               d_ctb12m02.cgccpfdigc, d_ctb12m02.atdsrvnum,
               d_ctb12m02.atdsrvano , d_ctb12m02.atdsrvorg,
               d_ctb12m02.endcid_d  , d_ctb12m02.endufd_d ,
               d_ctb12m02.prssitcod  to null

    let int_flag = false
    let ws.tam_nomepsq  = 0
    let arr_aux  = 1

    input by name d_ctb12m02.*  without defaults

       before field nomepsq
          if param.pstcoddig   is not null   then     ## Quando for passado
             exit input                               ## parametro, mostra
          end if                                      ## dados p/ confirmacao
          display by name d_ctb12m02.nomepsq attribute (reverse)

       after  field nomepsq
          display by name d_ctb12m02.nomepsq
          #se nao informou nome prestador, solicita empresa
          if d_ctb12m02.nomepsq is null   then
             #next field pestipc
             next field ciaempcod
          end if

       before field tipo
          display by name d_ctb12m02.tipo       attribute (reverse)

       after  field tipo
          display by name d_ctb12m02.tipo

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field nomepsq
          end if

          #se chegou aqui é pq informou nome prestador, entao
          # tipo deve ser informado
          if d_ctb12m02.nomepsq is not null   and
             d_ctb12m02.tipo    is null       then
             error "Tipo de pesquisa e' item obrigatorio G, R ou P!"
             next field tipo
          end if

          if d_ctb12m02.nomepsq is null       and
             d_ctb12m02.tipo    is not null   then
             error "Nome para pesquisa e' item obrigatorio!"
             next field tipo
          end if

          if d_ctb12m02.tipo <> "G" and
             d_ctb12m02.tipo <> "R" and
             d_ctb12m02.tipo <> "P" then
             error "Tipo de pesquisa invalido - informe G, R ou P!"
             next field tipo
          end if

          if d_ctb12m02.tipo  is not null   then
             if d_ctb12m02.tipo = "P"       and
                aux_contpsq      <  1        then
                error "Deve pesquisar por Razao ou Guerra antes!"
                next field tipo
             else
                if d_ctb12m02.tipo = "P" then
                   let ws.tam_nomepsq = (length (d_ctb12m02.nomepsq))

                   if  ws.tam_nomepsq  < 4  then
                       error "Minimo de 4 letras para pesquisar!"
                       next field nomepsq
                   end if
                   let ws.nomepsq = "*", d_ctb12m02.nomepsq clipped, "*"
                else
                   let ws.nomepsq = d_ctb12m02.nomepsq clipped, "*"
                end if
             end if
             next field prssitcod
          end if

       before field ciaempcod
              display by name d_ctb12m02.ciaempcod   attribute(reverse)
                     
       after field ciaempcod
              display by name d_ctb12m02.ciaempcod
              
              if fgl_lastkey() = fgl_keyval ("up")     or
                 fgl_lastkey() = fgl_keyval ("left")   then
                 next field tipo
              end if              

              #se informou empresa
              if d_ctb12m02.ciaempcod is not null then  
                 #buscar descricao da empresa
                 call cty14g00_empresa(1, d_ctb12m02.ciaempcod)
                      returning l_ret,
                                l_mensagem,
                                d_ctb12m02.empsgl
                 if l_ret <> 1 then
                    error l_mensagem
                    next field ciaempcod
                 end if
              end if
              
              #se depois das tentativas para informar empresa, 
              # ela ainda não foi informada
              if d_ctb12m02.ciaempcod is null then
                 let d_ctb12m02.empsgl = "TODAS"
              end if
              display by name d_ctb12m02.empsgl attribute (reverse)
              
              #se informou empresa, solicita cidade
              if d_ctb12m02.ciaempcod is not null then
                 next field endcid_d
              end if

       before field pestipc
              display by name d_ctb12m02.pestipc   attribute(reverse)

       after  field pestipc
              display by name d_ctb12m02.pestipc

              if fgl_lastkey() = fgl_keyval ("up")     or
                 fgl_lastkey() = fgl_keyval ("left")   then
                 next field nomepsq
              end if
              #se nao informou tipo pessoa, solicita servico
              if d_ctb12m02.pestipc   is null   then
                 next field atdsrvnum
              end if

              if d_ctb12m02.pestipc  <>  "F"   and
                 d_ctb12m02.pestipc  <>  "J"   then
                 error " Tipo de pessoa invalido!"
                 next field pestipc
              end if

              if d_ctb12m02.pestipc  =  "F"   then
                 initialize d_ctb12m02.cgcordc  to null
                 display by name d_ctb12m02.cgcordc
              end if

       before field cgccpfnumc
              display by name d_ctb12m02.cgccpfnumc   attribute(reverse)

       after  field cgccpfnumc
              display by name d_ctb12m02.cgccpfnumc

              if fgl_lastkey() = fgl_keyval ("up")     or
                 fgl_lastkey() = fgl_keyval ("left")   then
                 initialize d_ctb12m02.cgccpfnumc  to null
                 initialize d_ctb12m02.cgcordc     to null
                 initialize d_ctb12m02.cgccpfdigc  to null
                 display by name d_ctb12m02.cgccpfnumc
                 display by name d_ctb12m02.cgcordc
                 display by name d_ctb12m02.cgccpfdigc
                 next field pestipc
              end if
              #se chegou aqui é pq informou tipo servico, entao
              # cgc/cpf deve ser informado
              if d_ctb12m02.cgccpfnumc   is null   or
                 d_ctb12m02.cgccpfnumc   =  0      then
                 error " Numero do Cgc/Cpf deve ser informado!"
                 next field cgccpfnumc
              end if

              if d_ctb12m02.pestipc  =  "F"   then
                 next field cgccpfdigc
              end if

       before field cgcordc
              display by name d_ctb12m02.cgcordc   attribute(reverse)

       after  field cgcordc
              display by name d_ctb12m02.cgcordc

              if fgl_lastkey() = fgl_keyval ("up")     or
                 fgl_lastkey() = fgl_keyval ("left")   then
                 next field cgccpfnumc
              end if

              #se chegou aqui é pq informou tipo de pessoa diferente de F
              # entao dado deve ser informado
              if d_ctb12m02.cgcordc   is null   or
                 d_ctb12m02.cgcordc   =  0      then
                 error " Filial do Cgc/Cpf deve ser informada!"
                 next field cgcordc
              end if

       before field cgccpfdigc
              display by name d_ctb12m02.cgccpfdigc  attribute(reverse)

       after  field cgccpfdigc
              display by name d_ctb12m02.cgccpfdigc

              if fgl_lastkey() = fgl_keyval ("up")     or
                 fgl_lastkey() = fgl_keyval ("left")   then
                 if d_ctb12m02.pestipc  =  "J"  then
                    next field cgcordc
                 else
                    next field cgccpfnumc
                 end if
              end if
              #se chegou aqui é pq informou tipo de pessoa
              # entao digito deve ser informado
              if d_ctb12m02.cgccpfdigc   is null   then
                 error " Digito do Cgc/Cpf deve ser informado!"
                 next field cgccpfdigc
              end if

              if d_ctb12m02.pestipc  =  "J"    then
                 call F_FUNDIGIT_DIGITOCGC(d_ctb12m02.cgccpfnumc,
                                           d_ctb12m02.cgcordc)
                      returning ws.cgccpfdig
              else
                 call F_FUNDIGIT_DIGITOCPF(d_ctb12m02.cgccpfnumc)
                      returning ws.cgccpfdig
              end if

              if ws.cgccpfdig          is null           or
                 d_ctb12m02.cgccpfdigc <> ws.cgccpfdig   then
                 error "Digito Cgc/Cpf incorreto!"
                 next field cgccpfnumc
              end if

              if d_ctb12m02.cgccpfnumc  is not null   then
                 exit input
              end if

      before field atdsrvnum
             display by name d_ctb12m02.atdsrvnum      attribute (reverse)

      after  field atdsrvnum
             display by name d_ctb12m02.atdsrvnum

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                initialize d_ctb12m02.atdsrvnum   to null
                initialize d_ctb12m02.atdsrvano   to null
                display by name d_ctb12m02.atdsrvnum
                display by name d_ctb12m02.atdsrvano
                next field pestipc
             end if
             #se nao informou nenhum dos dodos anterior
             # solicita servico, se não informar servico
             # solicita cidade
             if d_ctb12m02.atdsrvnum   is null   then
                next field endcid_d
             end if

             if d_ctb12m02.atdsrvnum  is null   then
                initialize d_ctb12m02.atdsrvano   to null
                display by name d_ctb12m02.atdsrvano
                next field cgccpfnumc
             end if

      before field atdsrvano
             display by name d_ctb12m02.atdsrvano attribute (reverse)

      after  field atdsrvano
             display by name d_ctb12m02.atdsrvano

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field atdsrvnum
             end if
             #se chegou aqui é pq informou numero do servico
             # entao deve ser informado o ano do servico
             if d_ctb12m02.atdsrvano  is null   then
                error " Ano da O.S. deve ser informado!"
                next field atdsrvano
             end if

             select atdprscod, atdsrvorg
               into ws.atdprscod, d_ctb12m02.atdsrvorg
               from datmservico
              where atdsrvnum = d_ctb12m02.atdsrvnum    and
                    atdsrvano = d_ctb12m02.atdsrvano

             if sqlca.sqlcode <> 0   then
                error " Numero de O.S. nao cadastrada !"
                next field atdsrvnum
             end if

             if ws.atdprscod  is null   then
                error " O.S. nao possui prestador cadastrado!"
                next field atdsrvnum
             end if

             display by name d_ctb12m02.atdsrvorg

             exit input

      before field endcid_d
             display by name d_ctb12m02.endcid_d    attribute(reverse)

      after  field endcid_d
             display by name d_ctb12m02.endcid_d

             if fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                initialize d_ctb12m02.endcid_d to null
                initialize d_ctb12m02.endufd_d to null
                display by name d_ctb12m02.endcid_d
                display by name d_ctb12m02.endufd_d
                #PSI 205206
                #se chegou aqui é pq nao informou nenhum dado anterior
                # ou informou a empresa
                if d_ctb12m02.ciaempcod is not null then
                    next field ciaempcod
                else
                    next field atdsrvnum
                end if    
             end if

             if d_ctb12m02.nomepsq    is null  and
                d_ctb12m02.ciaempcod  is null  and   #PSI 205206
                d_ctb12m02.cgccpfnumc is null  and
                d_ctb12m02.atdsrvnum  is null  and
                d_ctb12m02.endcid_d   is null  then
                error " Uma das chaves para pesquisa deve ser informada!"
                next field endcid_d
             end if   
             #PSI 205206    
             #se informou empresa e nao informou cidade, solicitar situação  
             if d_ctb12m02.ciaempcod is not null and 
                d_ctb12m02.endcid_d is null then
                next field prssitcod
             end if

      before field endufd_d
             display by name d_ctb12m02.endufd_d    attribute(reverse)

      after  field endufd_d
             display by name d_ctb12m02.endufd_d

             if fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                next field endcid_d
             end if

             if d_ctb12m02.endufd_d   is null    then
                error " Unidade federativa deve ser informada!"
                next field endufd_d
             end if

             select ufdcod from glakest
              where glakest.ufdcod = d_ctb12m02.endufd_d

             if sqlca.sqlcode = notfound   then
                error " Unidade federativa nao cadastrada!"
                next field endufd_d
             end if

             initialize ws.mpacidcod to null
             declare c_ctb12m02cid  cursor for
                select mpacidcod
                  from datkmpacid
                 where cidnom = d_ctb12m02.endcid_d
                   and ufdcod = d_ctb12m02.endufd_d

             foreach  c_ctb12m02cid  into  ws.mpacidcod
                exit foreach
             end foreach

             if ws.mpacidcod is null   then
                error " Cidade/U.F. nao cadastrada no MAPA!"
                next field endcid_d
             end if

      before field prssitcod
             display by name d_ctb12m02.prssitcod    attribute(reverse)

      after  field prssitcod
             display by name d_ctb12m02.prssitcod    attribute(reverse)

             if fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                initialize d_ctb12m02.prssitcod  to null
                initialize ws.prssitdes          to null
                display by name d_ctb12m02.prssitcod
                display ws.prssitdes to prssitdes
                if d_ctb12m02.endufd_d is not null then
                   next field endufd_d
                else
                   next field tipo
                end if
             end if

             case d_ctb12m02.prssitcod
                when "A"   let ws.prssitdes = "ATIVO"
                when "C"   let ws.prssitdes = "CANCELADO"
                when "P"   let ws.prssitdes = "PROPOSTA"
                when "B"   let ws.prssitdes = "BLOQUEADO"
                otherwise  let ws.prssitdes = "TODAS"
                           initialize d_ctb12m02.prssitcod to null
             end case
             display by name d_ctb12m02.prssitcod
             display ws.prssitdes to prssitdes
             exit input

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    # MONTA PESQUISA
    #----------------

    let ws.comando1 =
     " select",
     " dpaksocor.nomrazsoc,",
     " dpaksocor.pstcoddig,",
     " dpaksocor.prssitcod,",
     " dpaksocor.endlgd,",
     " dpaksocor.endbrr,",
     " dpaksocor.endcid,",
     " dpaksocor.endufd,",
     " dpaksocor.endcep,",
     " dpaksocor.endcepcmp,",
     " dpaksocor.dddcod,",
     " dpaksocor.teltxt,",
     " dpaksocor.nomgrr,",
     " dpaksocor.pestip,",
     " dpaksocor.cgccpfnum,",
     " dpaksocor.cgcord,",
     " dpaksocor.cgccpfdig "    
    
    let ws.comando2 = " from dpaksocor "
    
    #situações:
    # 1-recebeu código prestador como parametro
    # 2-informou nome
    # 3-informou cgc/cpf
    # 4-informou numero servico
    # 5-informou cidade/uf
    # 6-informou empresa e cidade/uf
    # 7-informou empresa

    ### 1-recebeu código prestador como parametro
    #--------------------------------------------
    # nao tenho mais nenhum dado preenchido, pois nao entro no input
    # qdo codigo do prestador é recebido como parametro
    if param.pstcoddig  is not null then
       let ws.comando3 = " where dpaksocor.pstcoddig = ", param.pstcoddig
    else
       ### 2-informou nome    
       #--------------------------------------------
       # nao informou mais nenhum outro dado, pois qdo informo nome prestador
       # solicito situação e saio do input
       if d_ctb12m02.nomepsq  is not null   then
          if d_ctb12m02.tipo  =  "G"   then
             let ws.comando3 = " where dpaksocor.nomgrr matches '", ws.nomepsq, "' "
       
          else
             let ws.comando3 = " where dpaksocor.nomrazsoc matches '", ws.nomepsq, "'"
       
          end if     
       else
          ### 3-informou cgc/cpf      
          #-------------------------------------------- 
          # nao informou mais nenhum outro dado, pois qdo informo cgc/cpf
          # saio do input
          if d_ctb12m02.cgccpfnumc  is not null   then
             let ws.comando3 = " where dpaksocor.cgccpfnum = ", d_ctb12m02.cgccpfnumc
          else
             ### 4-informou numero servico   
             #-------------------------------------------- 
             # nao informou nenhum outro dado, pois qdo informa numero servico 
             # busco prestador q atendeu o servico e saio do input
             if ws.atdprscod is not null then
                let ws.comando3 = " where dpaksocor.pstcoddig = ", ws.atdprscod    
             else
                ### 5-informou cidade/uf    
                #--------------------------------------------
                # nao informou nenhum dado anterior, mas pode ter informado a empresa
                if d_ctb12m02.endcid_d is not null  then
                   let ws.comando3 = " where dpaksocor.endcid = '", d_ctb12m02.endcid_d,"' ", 
                                     "   and dpaksocor.endufd = '", d_ctb12m02.endufd_d,"' "                   
                   ### 6-informou empresa e cidade/uf 
                   #--------------------------------------------
                   if d_ctb12m02.ciaempcod is not null then
                      let ws.comando2 = ws.comando2 clipped, ", dparpstemp "
                      let ws.comando3 = ws.comando3 clipped, 
                                        "  and dparpstemp.ciaempcod = ", d_ctb12m02.ciaempcod, 
                                        "  and dparpstemp.pstcoddig = dpaksocor.pstcoddig "
                   end if
                else
                   ### 7-informou empresa    
                   #--------------------------------------------
                   #para nao ter informado cidade/uf e nenhum outro dado
                   # deve ter informado a empresa
                   if d_ctb12m02.ciaempcod is not null then
                      let ws.comando2 = ws.comando2 clipped, ", dparpstemp "
                      let ws.comando3 = " where dparpstemp.ciaempcod = ", d_ctb12m02.ciaempcod,
                                        "   and dparpstemp.pstcoddig = dpaksocor.pstcoddig "          
                   end if
                end if                
             end if             
          end if          
       end if          
    end if

    if d_ctb12m02.tipo = "G" or
       d_ctb12m02.tipo = "R" then
       let aux_contpsq  = aux_contpsq + 1
    end if

    message " Aguarde, pesquisando..."  attribute(reverse)
    let ws.comando1 = ws.comando1 clipped," ", ws.comando2 clipped," ",
                      ws.comando3
                   
    prepare comando_aux from ws.comando1
    declare c_ctb12m02 cursor for comando_aux

    open  c_ctb12m02

    foreach c_ctb12m02 into a_ctb12m02[arr_aux].nomrazsoc   ,
                            a_ctb12m02[arr_aux].pstcoddig   ,
                            ws.prssitcod                    ,
                            a_ctb12m02[arr_aux].endlgd      ,
                            a_ctb12m02[arr_aux].endbrr      ,
                            a_ctb12m02[arr_aux].endcid      ,
                            a_ctb12m02[arr_aux].endufd      ,
                            a_ctb12m02[arr_aux].endcep      ,
                            a_ctb12m02[arr_aux].endcepcmp   ,
                            a_ctb12m02[arr_aux].dddcod      ,
                            a_ctb12m02[arr_aux].teltxt      ,
                            a_ctb12m02[arr_aux].nomgrr      ,
                            a_ctb12m02[arr_aux].pestip      ,
                            a_ctb12m02[arr_aux].cgccpfnum   ,
                            a_ctb12m02[arr_aux].cgcord      ,
                            a_ctb12m02[arr_aux].cgccpfdig

       if d_ctb12m02.prssitcod is not null then
          if d_ctb12m02.prssitcod <> ws.prssitcod then
             continue foreach
          end if
       end if

       case ws.prssitcod
         when "A" let a_ctb12m02[arr_aux].situacao = "ATIVO"
         when "C" let a_ctb12m02[arr_aux].situacao = "CANCELADO"
         when "P" let a_ctb12m02[arr_aux].situacao = "PROPOSTA"
       end case

       let arr_aux = arr_aux + 1
       if arr_aux  >  80    then
          error " Limite excedido, pesquisa com mais de 80 prestadores !"
          exit foreach
       end if

    end foreach

    message ""
    let ws.seleciona = "n"
    if arr_aux  >  1   then
       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array  a_ctb12m02 to s_ctb12m02.*
          on key(interrupt)
             for arr_aux = 1 to 2
                 clear s_ctb12m02[arr_aux].nomrazsoc
                 clear s_ctb12m02[arr_aux].pstcoddig
                 clear s_ctb12m02[arr_aux].situacao
                 clear s_ctb12m02[arr_aux].nomgrr
                 clear s_ctb12m02[arr_aux].pestip
                 clear s_ctb12m02[arr_aux].cgccpfnum
                 clear s_ctb12m02[arr_aux].cgcord
                 clear s_ctb12m02[arr_aux].cgccpfdig
                 clear s_ctb12m02[arr_aux].endlgd
                 clear s_ctb12m02[arr_aux].endbrr
                 clear s_ctb12m02[arr_aux].endcid
                 clear s_ctb12m02[arr_aux].endufd
                 clear s_ctb12m02[arr_aux].endcep
                 clear s_ctb12m02[arr_aux].endcepcmp
                 clear s_ctb12m02[arr_aux].dddcod
                 clear s_ctb12m02[arr_aux].teltxt
             end for
             initialize a_ctb12m02  to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.seleciona = "s"
             error "Prestador selecionado !!"
             exit display

       end display
    else
       error " Nao foi encontrado nenhum prestador para pesquisa!"
    end if

    if ws.seleciona     = "s"         or
       param.pstcoddig  is not null   then
       exit while
    end if

 end while

 let int_flag = false
 close window  w_ctb12m02

 return a_ctb12m02[arr_aux].pstcoddig,
        a_ctb12m02[arr_aux].pestip,
        a_ctb12m02[arr_aux].cgccpfnum,
        a_ctb12m02[arr_aux].cgcord,
        a_ctb12m02[arr_aux].cgccpfdig

end function  ###  ctb12m02
