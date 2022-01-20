#############################################################################
# Nome do Modulo: CTC19M00                                            Pedro #
#                                                                   Marcelo #
# CARRO EXTRA - Manutencao no cadastro de veiculos                 Ago/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/11/1998  PSI 7056-4   Gilberto     Gravar informacoes referentes ao    #
#                                       cadastramento e atualizacao.        #
#---------------------------------------------------------------------------#
# 13/02/2006  PSI 198390   Priscila     Inclusao dos valores de franquia,   #
#                                       taxa de isencao e reducao           #
#---------------------------------------------------------------------------#
# 02/03/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
#---------------------------------------------------------------------------#
# 21/11/2006  PSI 205206   Priscila     incluir menu "Empresa"              #
#############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc19m00()
#------------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,      
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

   if not get_niv_mod(g_issk.prgsgl, "ctc19m00") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctc19m00.*   to  null
   initialize k_ctc19m00.* to  null

   open window ctc19m00 at 04,02 with form "ctc19m00"

   menu "VEICULOS"
       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Inclui", "Valores", "Empresa"
          end if

          show option "Encerra"

   command "Seleciona" "Pesquisa tabela conforme criterios"
            call seleciona_ctc19m00() returning k_ctc19m00.*
            if k_ctc19m00.lcvcod    is not null  and
               k_ctc19m00.avivclcod is not null  then
               next option "Proximo"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo registro selecionado"
            if k_ctc19m00.lcvcod    is not null  and
               k_ctc19m00.avivclcod is not null  then
               call proximo_ctc19m00(k_ctc19m00.*)
                    returning k_ctc19m00.*
            else
               error " Nao ha' mais registros nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra registro anterior selecionado"
            if k_ctc19m00.lcvcod    is not null  and
               k_ctc19m00.avivclcod is not null  then
               call anterior_ctc19m00(k_ctc19m00.*)
                    returning k_ctc19m00.*
            else
               error " Nao ha' mais registros nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica registro corrente selecionado"
            if k_ctc19m00.lcvcod    is not null  and
               k_ctc19m00.avivclcod is not null  then
               call modifica_ctc19m00(k_ctc19m00.*)
                    returning k_ctc19m00.*
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove registro corrente selecionado"
            if k_ctc19m00.lcvcod    is not null  and
               k_ctc19m00.avivclcod is not null  then
               call remove_ctc19m00(k_ctc19m00.*)
                    returning k_ctc19m00.*
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui registro na tabela"
            call inclui_ctc19m00()
            next option "Seleciona"

   command "Valores" "Valores da diaria e seguro"
            if k_ctc19m00.lcvcod    is not null  and
               k_ctc19m00.avivclcod is not null  then
               call ctc19m01(k_ctc19m00.*)
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Empresa" "Mantem o cadastro das empresas atendidas pela locadora/veiculo"
           if k_ctc19m00.lcvcod    is not null  and
              k_ctc19m00.avivclcod is not null  then
              call ctc19m00_empresa(k_ctc19m00.lcvcod,
                                    k_ctc19m00.avivclcod)
              next option "Seleciona"
           else
              error " Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key (interrupt) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc19m00

end function  ###  ctc19m00

#------------------------------------------------------------
 function seleciona_ctc19m00()
#------------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

   clear form

   let int_flag = false

   input by name k_ctc19m00.lcvcod thru k_ctc19m00.avivclcod

      before field lcvcod
         display by name k_ctc19m00.lcvcod    attribute (reverse)

      after  field lcvcod
         display by name k_ctc19m00.lcvcod

         if k_ctc19m00.lcvcod is null then
            error " Codigo da Locadora deve ser informado!"
            call ctc30m01() returning k_ctc19m00.lcvcod
            next field lcvcod
         end if

         initialize ctc19m00.lcvnom to null

         select lcvnom into ctc19m00.lcvnom
           from datklocadora
          where lcvcod = k_ctc19m00.lcvcod

         if sqlca.sqlcode <> 0  then
            error " Locadora nao cadastrada!"
            next field lcvcod
         else
            display by name ctc19m00.lcvnom
         end if

      before field avivclcod
         display by name k_ctc19m00.avivclcod attribute (reverse)

      after  field avivclcod
         display by name k_ctc19m00.avivclcod

         if k_ctc19m00.avivclcod is not null  and
            k_ctc19m00.avivclcod <> 0         then
            select lcvcod, avivclcod
              from datkavisveic
             where lcvcod    = k_ctc19m00.lcvcod     and
                   avivclcod = k_ctc19m00.avivclcod

            if sqlca.sqlcode = notfound  then
               error " Veiculo nao cadastrado!"
               next field avivclcod
            end if
         else
            select min(avivclcod)
              into k_ctc19m00.avivclcod
              from datkavisveic
             where lcvcod    = k_ctc19m00.lcvcod  and
                   avivclcod > 0

            if k_ctc19m00.avivclcod is null  then
               error " Nenhum veiculo foi cadastrado para esta locadora!"
               next field lcvcod
            end if
         end if

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc19m00.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctc19m00.*
   end if

   call sel_ctc19m00(k_ctc19m00.*) returning ctc19m00.*

   if ctc19m00.avivclcod is not null  then
      display by name ctc19m00.avivclcod thru ctc19m00.atlnom
   else
      error " Registro nao cadastrado!"
      initialize ctc19m00.*    to null
      initialize k_ctc19m00.*  to null
   end if

   return k_ctc19m00.*

end function  ###  seleciona_ctc19m00

#------------------------------------------------------------
 function proximo_ctc19m00(k_ctc19m00)
#------------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

 select min (avivclcod)
   into ctc19m00.avivclcod
   from datkavisveic
  where lcvcod    = k_ctc19m00.lcvcod     and
        avivclcod > k_ctc19m00.avivclcod

 let ctc19m00.lcvcod = k_ctc19m00.lcvcod

 if ctc19m00.lcvcod    is null  or
    ctc19m00.avivclcod is null  then
    error " Nao ha' mais registros nesta direcao!"
 else
    let k_ctc19m00.avivclcod = ctc19m00.avivclcod

    call sel_ctc19m00(k_ctc19m00.*) returning ctc19m00.*

    if ctc19m00.lcvcod    is not null  and
       ctc19m00.avivclcod is not null  then
       display by name ctc19m00.avivclcod thru ctc19m00.atlnom
    else
       initialize ctc19m00.*    to null
    end if
 end if

 return k_ctc19m00.*

end function  ###  proximo_ctc19m00

#------------------------------------------------------------
 function anterior_ctc19m00(k_ctc19m00)
#------------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

 let int_flag = false

 select max(avivclcod)
   into ctc19m00.avivclcod
   from datkavisveic
  where lcvcod    = k_ctc19m00.lcvcod     and
        avivclcod < k_ctc19m00.avivclcod

 let ctc19m00.lcvcod = k_ctc19m00.lcvcod

 if ctc19m00.lcvcod    is null  or
    ctc19m00.avivclcod is null  then
    error " Nao ha' mais registros nesta direcao!"
 else
    let k_ctc19m00.avivclcod = ctc19m00.avivclcod

    call sel_ctc19m00(k_ctc19m00.*) returning ctc19m00.*

    if ctc19m00.avivclcod is not null  then
       display by name ctc19m00.avivclcod thru ctc19m00.atlnom
    else
       initialize ctc19m00.* to null
    end if
 end if

 return k_ctc19m00.*

end function  ###  anterior_ctc19m00

#------------------------------------------------------------
 function modifica_ctc19m00(k_ctc19m00)
#------------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

 define l_data      date,
        l_hora2     datetime hour to minute

 call sel_ctc19m00(k_ctc19m00.*) returning ctc19m00.*

 if ctc19m00.lcvcod    is not null  and
    ctc19m00.avivclcod is not null  then
    call input_ctc19m00("a", k_ctc19m00.* , ctc19m00.*) returning ctc19m00.*

    if int_flag  then
       let int_flag = false
       initialize ctc19m00.*  to null
       error " Operacao cancelada!"
       clear form
       return k_ctc19m00.*
    end if

    call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2
    
    call ctc30m00_remove_caracteres(ctc19m00.avivclmdl)
            returning ctc19m00.avivclmdl 
   
   call ctc30m00_remove_caracteres(ctc19m00.avivcldes)
            returning ctc19m00.avivcldes
   
   call ctc30m00_remove_caracteres(ctc19m00.obs)
            returning ctc19m00.obs
    
    update datkavisveic set (avivclgrp, avivclmdl,
                             avivcldes, frqvlr,
                             rduvlr, isnvlr,
                             avivclstt,
                             obs      , atldat   ,
                             atlemp   , atlmat   )
                          = (ctc19m00.avivclgrp  ,
                             ctc19m00.avivclmdl  ,
                             ctc19m00.avivcldes  ,
                             ctc19m00.frqvlr     ,
                             ctc19m00.rduvlr     ,
                             ctc19m00.isnvlr     ,
                             ctc19m00.avivclstt  ,
                             ctc19m00.obs        ,
                             l_data              ,
                             g_issk.empcod       ,
                             g_issk.funmat       )
                       where lcvcod    = k_ctc19m00.lcvcod  and
                             avivclcod = k_ctc19m00.avivclcod

    if sqlca.sqlcode <>  0  then
       error " Erro (", sqlca.sqlcode, ") na alteracao dos dados do veiculo. AVISE A INFORMATICA!"
       initialize ctc19m00.*   to null
       initialize k_ctc19m00.* to null
       return k_ctc19m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

    clear form
 end if

 return k_ctc19m00.*

end function  ###  modifica_ctc19m00

#--------------------------------------------------------------------
 function remove_ctc19m00(k_ctc19m00)
#--------------------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do registro."
              clear form
              initialize ctc19m00.*   to null
              initialize k_ctc19m00.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_ctc19m00(k_ctc19m00.*) returning ctc19m00.*

              if sqlca.sqlcode = NOTFOUND  then
                 initialize ctc19m00.*   to null
                 initialize k_ctc19m00.* to null
                 error " Registro nao localizado!"
              else
                 begin work

                 delete from datkavisveic
                  where lcvcod    = k_ctc19m00.lcvcod    and
                        avivclcod = k_ctc19m00.avivclcod

                 if sqlca.sqlcode <>  0  then
                    error " Erro (", sqlca.sqlcode,") na exclusao dos dados do veiculo. AVISE A INFORMATICA!"
                    rollback work
                    initialize ctc19m00.*   to null
                    initialize k_ctc19m00.* to null
                    return k_ctc19m00.*
                 end if

                 delete from datklocaldiaria
                  where lcvcod    = k_ctc19m00.lcvcod    and
                        avivclcod = k_ctc19m00.avivclcod

                 if sqlca.sqlcode <>  0  then
                    error " Erro (", sqlca.sqlcode,") na exclusao dos valores do veiculo. AVISE A INFORMATICA!"
                    rollback work
                    initialize ctc19m00.*   to null
                    initialize k_ctc19m00.* to null
                    return k_ctc19m00.*
                 end if

                 COMMIT WORK

                 initialize ctc19m00.*   to null
                 initialize k_ctc19m00.* to null
                 error " Registro excluido!"
                 clear form
              end if
              exit menu
   end menu

   return k_ctc19m00.*

end function  ###  remove_ctc19m00

#------------------------------------------------------------
 function inclui_ctc19m00()
#------------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

 define aux_cont    smallint

 define l_data       date,
        l_hora2      datetime hour to minute

   clear form

   initialize ctc19m00.*   to null
   initialize k_ctc19m00.* to null

   call input_ctc19m00("i",k_ctc19m00.*, ctc19m00.*) returning ctc19m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc19m00.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora2
 
   call ctc30m00_remove_caracteres(ctc19m00.avivclmdl)
            returning ctc19m00.avivclmdl 
   
   call ctc30m00_remove_caracteres(ctc19m00.avivcldes)
            returning ctc19m00.avivcldes
   
   call ctc30m00_remove_caracteres(ctc19m00.obs)
            returning ctc19m00.obs
   
   insert into datkavisveic (lcvcod   ,
                             avivclcod,
                             avivclgrp,
                             avivclmdl,
                             avivcldes,
                             frqvlr   ,
                             rduvlr   ,
                             isnvlr   ,
                             avivclstt,
                             caddat   ,
                             cademp   ,
                             cadmat   ,
                             atldat   ,
                             atlemp   ,
                             atlmat   ,
                             obs      )
                    values  (ctc19m00.lcvcod   ,
                             ctc19m00.avivclcod,
                             ctc19m00.avivclgrp,
                             ctc19m00.avivclmdl,
                             ctc19m00.avivcldes,
                             ctc19m00.frqvlr   ,
                             ctc19m00.rduvlr   ,
                             ctc19m00.isnvlr   ,
                             ctc19m00.avivclstt,
                             l_data           ,
                             g_issk.empcod     ,
                             g_issk.funmat     ,
                             l_data            ,
                             g_issk.empcod     ,
                             g_issk.funmat     ,
                             ctc19m00.obs      )

   if sqlca.sqlcode <>  0  then
      error " Erro (", sqlca.sqlcode, ") na inclusao do veiculo. AVISE A INFORMATICA!"
      return
   end if

   error " Inclusao efetuada com sucesso!"

   while TRUE
      error " Informe os valores da diaria e seguro!"
      call ctc19m01(ctc19m00.lcvcod, ctc19m00.avivclcod)

      let aux_cont = 0

      select count(*) into aux_cont
        from datklocaldiaria
       where lcvcod    = ctc19m00.lcvcod    and
             avivclcod = ctc19m00.avivclcod

      if aux_cont is not null and
         aux_cont >  0        then
         exit while
      end if
   end while

   clear form

end function  ###  inclui_ctc19m00

#--------------------------------------------------------------------
 function input_ctc19m00(operacao, k_ctc19m00, ctc19m00)
#--------------------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

 define operacao      char (1)

   let int_flag = false

   input by name k_ctc19m00.lcvcod   ,
                 k_ctc19m00.avivclcod,
                 ctc19m00.avivclgrp  ,
                 ctc19m00.avivclmdl  ,
                 ctc19m00.avivcldes  ,
                 ctc19m00.frqvlr     ,
                 ctc19m00.rduvlr     ,
                 ctc19m00.isnvlr     ,
                 ctc19m00.avivclstt  ,
                 ctc19m00.obs       without defaults

      before field lcvcod
         if operacao = "a" then
            next field avivclgrp
         end if
         display by name k_ctc19m00.lcvcod    attribute (reverse)

      after  field lcvcod
         display by name k_ctc19m00.lcvcod

         if k_ctc19m00.lcvcod is null then
            error " Codigo da Locadora deve ser informado!"
            call ctc30m01()  returning k_ctc19m00.lcvcod
            next field lcvcod
         end if

         initialize ctc19m00.lcvnom to null

         select lcvcod, lcvnom
           into ctc19m00.lcvcod, ctc19m00.lcvnom
           from datklocadora
          where lcvcod = k_ctc19m00.lcvcod

         if sqlca.sqlcode <> 0  then
            error " Locadora nao cadastrada!"
            next field lcvcod
         else
            display by name ctc19m00.lcvnom
         end if

      before field avivclcod
         display by name k_ctc19m00.avivclcod attribute (reverse)

         if operacao = "i"  then
            select max(avivclcod)
              into k_ctc19m00.avivclcod
              from datkavisveic

            if k_ctc19m00.avivclcod is null then
               let k_ctc19m00.avivclcod = 0
            end if

            let k_ctc19m00.avivclcod = k_ctc19m00.avivclcod + 1
         end if

         let ctc19m00.avivclcod = k_ctc19m00.avivclcod
         display by name k_ctc19m00.avivclcod
         next field avivclgrp

   before field avivclgrp
      if operacao = "a" then
         next field avivclmdl
      end if

      display by name ctc19m00.avivclgrp attribute (reverse)

   after  field avivclgrp
      display by name ctc19m00.avivclgrp

      if fgl_lastkey() = fgl_keyval("up")       or
         fgl_lastkey() = fgl_keyval("left")   then
         next field avivclcod
      end if

      if ctc19m00.avivclgrp is null then
         error " Grupo do veiculo deve ser informado!"
         next field avivclgrp
      end if

   before field avivclmdl
      display by name ctc19m00.avivclmdl attribute (reverse)

   after  field avivclmdl
      display by name ctc19m00.avivclmdl

      if fgl_lastkey() = fgl_keyval("up")       or
         fgl_lastkey() = fgl_keyval("left")   then
         next field avivclgrp
      end if

      if ctc19m00.avivclmdl is null then
         error " Modelo do veiculo deve ser informado!"
         next field avivclmdl
      end if

   before field avivcldes
      display by name ctc19m00.avivcldes attribute (reverse)

   after  field avivcldes
      display by name ctc19m00.avivcldes

      if fgl_lastkey() = fgl_keyval("up")       or
         fgl_lastkey() = fgl_keyval("left")   then
         next field avivclmdl
      end if

      if ctc19m00.avivcldes is null then
         error " Discriminacao do veiculo deve ser informado!"
         next field avivcldes
      end if


   before field frqvlr
      display by name ctc19m00.frqvlr attribute (reverse)

   after field frqvlr
      display by name ctc19m00.frqvlr
      if fgl_lastkey() = fgl_keyval("up")       or
         fgl_lastkey() = fgl_keyval("left")   then
          if ctc19m00.frqvlr is null then
             error " Valor de Franquia do Veiculo deve ser informada!"
             next field frqvlr
          end if
      end if


   before field rduvlr
      display by name ctc19m00.rduvlr attribute (reverse)

   after field rduvlr
      display by name ctc19m00.rduvlr
      if fgl_lastkey() = fgl_keyval("up")       or
         fgl_lastkey() = fgl_keyval("left")   then
          if ctc19m00.rduvlr is null then
            error " Taxa de Reducao de Franquia do Veiculo deve ser informada!"
            next field rduvlr
          end if
      end if


   before field isnvlr
      display by name ctc19m00.isnvlr attribute (reverse)

   after field isnvlr
      display by name ctc19m00.isnvlr
      if fgl_lastkey() = fgl_keyval("up")       or
         fgl_lastkey() = fgl_keyval("left")   then
          if ctc19m00.isnvlr is null then
            error " Taxa de Isencao de Franquia do Veiculo deve ser informada!"
            next field isnvlr
          end if
      end if


   before field avivclstt
      if operacao = "i"  then
         let ctc19m00.avivclstt = "A"
         display by name ctc19m00.avivclstt
         next field obs
      else
         display by name ctc19m00.avivclstt attribute (reverse)
      end if

   after  field avivclstt
      display by name ctc19m00.avivclstt

      if ctc19m00.avivclstt = "A"  then
         let ctc19m00.vclsttdes = "ATIVO"
      else
         let ctc19m00.vclsttdes = "CANCELADO"
      end if

      display by name ctc19m00.vclsttdes

   before field obs
      display by name ctc19m00.obs       attribute (reverse)

   after  field obs
      display by name ctc19m00.obs

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc19m00.*  to null
   end if

   return ctc19m00.*

end function  ###  input_ctc19m00

#---------------------------------------------------------
 function sel_ctc19m00(k_ctc19m00)
#---------------------------------------------------------

 define ctc19m00   record
    lcvcod         like datkavisveic.lcvcod   ,
    lcvnom         like datklocadora.lcvnom   ,
    avivclcod      like datkavisveic.avivclcod,
    avivclgrp      like datkavisveic.avivclgrp,
    avivclmdl      like datkavisveic.avivclmdl,
    avivcldes      like datkavisveic.avivcldes,
    frqvlr         like datkavisveic.frqvlr   ,
    rduvlr         like datkavisveic.rduvlr   ,
    isnvlr         like datkavisveic.isnvlr   ,
    avivclstt      like datkavisveic.avivclstt,
    vclsttdes      char (10)                  ,
    obs            like datkavisveic.obs      ,
    caddat         like datkavisveic.caddat   ,
    cademp         like datkavisveic.cademp   ,
    cadmat         like datkavisveic.cadmat   ,
    cadnom         like isskfunc.funnom       ,
    atldat         like datkavisveic.atldat   ,
    atlemp         like datkavisveic.atlemp   ,
    atlmat         like datkavisveic.atlmat   ,
    atlnom         like isskfunc.funnom
 end record

 define k_ctc19m00 record
    lcvcod         like datkavisveic.lcvcod   ,
    avivclcod      like datkavisveic.avivclcod
 end record

 initialize ctc19m00.*  to null

 select lcvcod   ,
        avivclcod,
        avivclgrp,
        avivclmdl,
        avivcldes,
        frqvlr,
        rduvlr,
        isnvlr,
        avivclstt,
        obs      ,
        caddat   ,
        cademp   ,
        cadmat   ,
        atldat   ,
        atlemp   ,
        atlmat
   into ctc19m00.lcvcod   ,
        ctc19m00.avivclcod,
        ctc19m00.avivclgrp,
        ctc19m00.avivclmdl,
        ctc19m00.avivcldes,
        ctc19m00.frqvlr ,
        ctc19m00.rduvlr ,
        ctc19m00.isnvlr ,
        ctc19m00.avivclstt,
        ctc19m00.obs      ,
        ctc19m00.caddat   ,
        ctc19m00.cademp   ,
        ctc19m00.cadmat   ,
        ctc19m00.atldat   ,
        ctc19m00.atlemp   ,
        ctc19m00.atlmat
   from datkavisveic
  where lcvcod    = k_ctc19m00.lcvcod
    and avivclcod = k_ctc19m00.avivclcod

 if sqlca.sqlcode <> 0  then
    initialize k_ctc19m00.*  to null
    initialize ctc19m00.*    to null
 else
    if ctc19m00.avivclstt = "A"  then
       let ctc19m00.vclsttdes = "ATIVO"
    else
       let ctc19m00.vclsttdes = "CANCELADO"
    end if

    call ctc19m00_func(ctc19m00.cademp, ctc19m00.cadmat)
         returning ctc19m00.cadnom

    call ctc19m00_func(ctc19m00.atlemp, ctc19m00.atlmat)
         returning ctc19m00.atlnom
 end if

 return ctc19m00.*

end function  ###  sel_ctc19m00

#---------------------------------------------------------
 function ctc19m00_func(k_ctc19m00)
#---------------------------------------------------------

 define k_ctc19m00 record
    empcod         like isskfunc.empcod ,
    funmat         like isskfunc.funmat
 end record

 define ws         record
    funnom         like isskfunc.funnom
 end record

 let ws.funnom = "NAO CADASTRADO!"

 select funnom
   into ws.funnom
   from isskfunc
  where empcod = k_ctc19m00.empcod  and
        funmat = k_ctc19m00.funmat

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  ctc19m00_func

#---------------------------------------------------------
function ctc19m00_empresa(param)
#---------------------------------------------------------
    define param record
         lcvcod         like datkavisveic.lcvcod   ,
         avivclcod      like datkavisveic.avivclcod       
    end record

    define a_empresas array[15] of record
        ciaempcod   like gabkemp.empcod
    end record 
    
    define l_ret   smallint,
           l_mensagem char(60),
           l_aux  smallint,
           l_total smallint
    
    initialize a_empresas to null
    let l_ret = 0
    let l_mensagem = null
    let l_aux = 1
    let l_total = 0
    
    call ctd04g00_empresas(1,
                           param.lcvcod,
                           param.avivclcod )
         returning l_ret,
                   l_mensagem,
                   l_total,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_empresas[15].ciaempcod    
    
    
    #Abrir janela para atualizacao de empresas para o prestador
    call ctc00m03 (3,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_empresas[15].ciaempcod  )
         returning l_ret,
                   l_mensagem,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_empresas[15].ciaempcod
                   
    if l_ret = 1 then                
       #apagar empresas cadastradas ao prestador
       call ctd04g00_delete_datravsemp(param.lcvcod, 
                                       param.avivclcod)
            returning l_ret,
                      l_mensagem
       #inserir empresas cadastradas a locadora/veiculo
       if l_ret = 1 then
          #percorrer array de empresas e inserir para o prestador
          while l_aux <= 15    #tamanho do array
                if a_empresas[l_aux].ciaempcod is not null then
                    call ctd04g00_insert_datravsemp(param.lcvcod, 
                                                    param.avivclcod,
                                                    a_empresas[l_aux].ciaempcod)
                         returning l_ret,
                                   l_mensagem
                    if l_ret <> 1 then
                       error l_mensagem
                       exit while
                    end if
                    let l_aux = l_aux + 1                              
                else
                    #se é nulo mas não chegou no fim do array - continua
                    # pois em ctc00m03 se tentar inserir com f1, mas 
                    # não informar ciaempcod e nem excluir a linha
                    let l_aux = l_aux + 1
                end if
          end while      
       else
          error l_mensagem
       end if               
    else
       error l_mensagem   
    end if
    
    return                   

end function
