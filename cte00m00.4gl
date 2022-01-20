###########################################################################
# Nome do Modulo: CTE00M00                                           Ruiz #
#                                                                    Akio #
# Cadastro de codigos de assunto                                 Abr/2000 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
###########################################################################
#                        * * * A L T E R A C A O * * *                    #
#  Analista Resp. : Ligia Mattge                                          #
#  PSI            : 170178 - OSF: 18902                                   #
#.........................................................................#
#  Data        Autor Fabrica  Alteracao                                   #
#  ----------  -------------  --------------------------------------------#
#  20/05/2003  Gustavo(FSW)   Incluir "Aceita Acao p/ outras Areas".      #
#-------------------------------------------------------------------------#
#  PSI 192341  JUNIOR, Meta   Unificacao de Centro de Custos              #
#  14/05/2005                                                             #
#-------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
#-------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cte00m00()
#------------------------------------------------------------

 define cte00m00      record
    corasscod         like dackass.corasscod,
    corassdes         like dackass.corassdes,
    corassagpcod      like dackass.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    prgextcod         like dackprgext.prgextcod,
    prgextdes         like dackprgext.prgextdes,
    corasspndflg      like dackass.corasspndflg,
    corasshstflg      like dackass.corasshstflg,
    maienvflg         like dackass.maienvflg,
    webrlzflg         like dackass.webrlzflg,
    atdexbflg         like dackass.atdexbflg,
    slccctcod         like dackass.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackass.corasspsocod,
    corassstt         like dackass.corassstt,
    caddat            like dackass.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackass.atldat,
    funnom            like isskfunc.funnom
 end record

 define param record
    corasscod         like dackass.corasscod 
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
    cctlclnom     like ctgklcl.cctlclnom,       --Nome do local
    cctdptnom     like ctgkdpt.cctdptnom,       --Nome do depto (antigo cctnom)
    cctdptrspnom  like ctgrlcldpt.cctdptrspnom, --Responsavel pelo departamento
    cctdptlclsit  like ctgrlcldpt.cctdptlclsit, --Sit do depto (A)tivo (I)nativo
    cctdpttip     like ctgkdpt.cctdpttip        -- Tipo de departamento
 end record

 define ws  record
    corassdes     like dackass.corassdes,
    corassagpcod  like dackass.corassagpcod
 end record

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "cte00m00") then
 #   error "Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 let int_flag = false

 initialize cte00m00.*  to null

 open window cte00m00 at 04,02 with form "cte00m00"


 menu "ASSUNTOS"

  before menu
          hide option all
          show option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica" , "Inclui"
          #end if
          show option "Encerra"

  command key ("S") "Seleciona"
                   "Pesquisa assunto conforme criterios"
          call cte00m00_seleciona()  returning param.*
          if param.corasscod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum assunto selecionado!"
             message ""
             next option "Seleciona"
          end if

  command key ("P") "Proximo"
                   "Mostra proximo assunto selecionado"
          message ""
          call cte00m00_proximo(param.*)
               returning param.*

  command key ("A") "Anterior"
                   "Mostra assunto anterior selecionado"
          message ""
          if param.corasscod    is not null then
             call cte00m00_anterior(param.corasscod   )
                  returning param.*
          else
             error " Nenhum assunto nesta direcao!"
             next option "Seleciona"
          end if

  command key ("M") "Modifica"
                   "Modifica assunto corrente selecionado"
          message ""
          if param.corasscod     is not null then
             call cte00m00_modifica(param.*)
                  returning param.*
             next option "Seleciona"
          else
             error " Nenhum assunto selecionado!"
             next option "Seleciona"
          end if

  command key ("I") "Inclui"
                   "Inclui assunto"
          message ""
          call cte00m00_inclui()
          next option "Seleciona"


  command key ("T") "maTricula"
                    "Matricula com permissao para acesso ao assunto"
          message ""
          if param.corasscod is not null then
             select corassdes,corassagpcod
               into ws.corassdes, ws.corassagpcod
                 from dackass
               where corasscod = param.corasscod

             if ws.corassagpcod  = 27 then
                call ctc14m05(param.corasscod,
                              " ", #param.c24astagpdes,
                              ws.corassdes,
                              g_issk.sissgl)
             else
                error "Permitido somente para assuntos do agrupamento 27-Endosso Web"
             end if

          else 
             next option "Seleciona"
          end if

  command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window cte00m00

 end function  # cte00m00


#------------------------------------------------------------
 function cte00m00_seleciona()
#------------------------------------------------------------

 define cte00m00      record
    corasscod         like dackass.corasscod,
    corassdes         like dackass.corassdes,
    corassagpcod      like dackass.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    prgextcod         like dackprgext.prgextcod,
    prgextdes         like dackprgext.prgextdes,
    corasspndflg      like dackass.corasspndflg,
    corasshstflg      like dackass.corasshstflg,
    maienvflg         like dackass.maienvflg,
    webrlzflg         like dackass.webrlzflg,
    atdexbflg         like dackass.atdexbflg,
    slccctcod         like dackass.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackass.corasspsocod,
    corassstt         like dackass.corassstt,
    caddat            like dackass.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackass.atldat,
    funnom            like isskfunc.funnom
 end record

 define param         record
    corasscod         like dackass.corasscod 
 end record

 define ws_corassagpcod like dackassagp.corassagpcod


 let int_flag = false
 initialize cte00m00.*  to null
 initialize param.*     to null
 display by name cte00m00.*

 input by name cte00m00.corasscod

    before field corasscod
        display by name cte00m00.corasscod attribute (reverse)

    after  field corasscod
        display by name cte00m00.corasscod

        if cte00m00.corasscod  is null  or
           cte00m00.corasscod  =  0     then
           call cto00m03() returning cte00m00.corassagpcod,
                                     cte00m00.corassagpdes
           if cte00m00.corassagpcod  is null  then
              error " Codigo de assunto deve ser informado!"
              next field corasscod
           else
               call cto00m04(cte00m00.corassagpcod,"")
                               returning cte00m00.corasscod,
                                         cte00m00.corassdes
               if cte00m00.corasscod is null  then
                  error " Codigo de assunto deve ser informado!"
                  next field corasscod
               end if
           end if
        end if
        display by name cte00m00.corasscod
        display by name cte00m00.corassdes

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize cte00m00.*   to null
    display by name cte00m00.*
    error " Operacao cancelada!"
    return param.*
 end if

 call cte00m00_ler(cte00m00.corasscod)
      returning cte00m00.*

 if cte00m00.corasscod  is not null   then
    display by name  cte00m00.*
 else
    error " Assunto nao cadastrado!"
    initialize cte00m00.*    to null
 end if

 let param.corasscod = cte00m00.corasscod
 return param.*

 end function  # cte00m00_seleciona


#------------------------------------------------------------
 function cte00m00_proximo(param)
#------------------------------------------------------------

 define param         record
    corasscod         like dackass.corasscod 
 end record

 define cte00m00      record
    corasscod         like dackass.corasscod,
    corassdes         like dackass.corassdes,
    corassagpcod      like dackass.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    prgextcod         like dackprgext.prgextcod,
    prgextdes         like dackprgext.prgextdes,
    corasspndflg      like dackass.corasspndflg,
    corasshstflg      like dackass.corasshstflg,
    maienvflg         like dackass.maienvflg,
    webrlzflg         like dackass.webrlzflg,
    atdexbflg         like dackass.atdexbflg,
    slccctcod         like dackass.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackass.corasspsocod,
    corassstt         like dackass.corassstt,
    caddat            like dackass.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackass.atldat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
#initialize cte00m00.*   to null

#if param.corasscod  is null  then
#   let param.corasscod = 0
#end if

 select min(dackass.corasscod)
   into cte00m00.corasscod
   from dackass
  where dackass.corasscod > param.corasscod

 if cte00m00.corasscod  is not null   then
    let param.corasscod = cte00m00.corasscod
    call cte00m00_ler(cte00m00.corasscod)
         returning cte00m00.*

    if cte00m00.corasscod  is not null   then
       display by name  cte00m00.*
    else
       error " Nao ha' assunto nesta direcao!"
     # initialize cte00m00.*    to null
    end if
 else
    error " Nao ha' assunto nesta direcao!"
#   initialize cte00m00.*    to null
 end if

 return param.*

 end function    # cte00m00_proximo


#------------------------------------------------------------
 function cte00m00_anterior(param)
#------------------------------------------------------------

 define param         record
    corasscod         like dackass.corasscod 
 end record

 define cte00m00      record
    corasscod         like dackass.corasscod,
    corassdes         like dackass.corassdes,
    corassagpcod      like dackass.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    prgextcod         like dackprgext.prgextcod,
    prgextdes         like dackprgext.prgextdes,
    corasspndflg      like dackass.corasspndflg,
    corasshstflg      like dackass.corasshstflg,
    maienvflg         like dackass.maienvflg,
    webrlzflg         like dackass.webrlzflg,
    atdexbflg         like dackass.atdexbflg,
    slccctcod         like dackass.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackass.corasspsocod,
    corassstt         like dackass.corassstt,
    caddat            like dackass.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackass.atldat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
#initialize cte00m00.*  to null

#if param.corasscod  is null  then
#   let param.corasscod = 0
#end if

 select max(dackass.corasscod)
   into cte00m00.corasscod
   from dackass
  where dackass.corasscod     < param.corasscod

 if cte00m00.corasscod  is not null   then
    let param.corasscod = cte00m00.corasscod
    call cte00m00_ler(cte00m00.corasscod)
         returning cte00m00.*

    if cte00m00.corasscod  is not null   then
       display by name  cte00m00.*
    else
       error " Nao ha' assunto nesta direcao!"
#      initialize cte00m00.*    to null
    end if
 else
    error " Nao ha' assunto nesta direcao!"
#   initialize cte00m00.*    to null
 end if

 return param.*

 end function    # cte00m00_anterior


#------------------------------------------------------------
 function cte00m00_modifica(param)
#------------------------------------------------------------

 define param         record
    corasscod         like dackass.corasscod 
 end record

 define cte00m00      record
    corasscod         like dackass.corasscod,
    corassdes         like dackass.corassdes,
    corassagpcod      like dackass.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    prgextcod         like dackprgext.prgextcod,
    prgextdes         like dackprgext.prgextdes,
    corasspndflg      like dackass.corasspndflg,
    corasshstflg      like dackass.corasshstflg,
    maienvflg         like dackass.maienvflg,
    webrlzflg         like dackass.webrlzflg,
    atdexbflg         like dackass.atdexbflg,
    slccctcod         like dackass.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackass.corasspsocod,
    corassstt         like dackass.corassstt,
    caddat            like dackass.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackass.atldat,
    funnom            like isskfunc.funnom
 end record

 call cte00m00_ler(param.corasscod)
      returning cte00m00.*
 if cte00m00.corasscod is null then
    error " Registro nao localizado "
    return param.*
 end if

 call cte00m00_input("a", param.*,cte00m00.*)
                returning param.*, cte00m00.*

 if int_flag  then
    let int_flag = false
    initialize cte00m00.*  to null
    display by name  cte00m00.*
    error " Operacao cancelada!"
    return param.*
 end if

 whenever error continue

 let cte00m00.atldat = today

 begin work
    update dackass     set  ( corassdes,
                              corassagpcod,
                              prgextcod,
                              corasspndflg,
                              corasshstflg,
                              maienvflg,
                              webrlzflg,
                              atdexbflg,
                              slccctcod,
                              corasspsocod,
                              corassstt,
                              atldat,
                              atlmat )
                        =   ( cte00m00.corassdes,
                              cte00m00.corassagpcod,
                              cte00m00.prgextcod,
                              cte00m00.corasspndflg,
                              cte00m00.corasshstflg,
                              cte00m00.maienvflg,
                              cte00m00.webrlzflg,
                              cte00m00.atdexbflg,
                              cte00m00.slccctcod,
                              cte00m00.corasspsocod,
                              cte00m00.corassstt,
                              cte00m00.atldat,
                              g_issk.funmat )
           where dackass.corasscod  =  param.corasscod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do assunto!"
       rollback work
       initialize cte00m00.*   to null
       initialize param.*      to null
       return param.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize cte00m00.*  to null
 display by name  cte00m00.*
 message ""
 return param.*

 end function   #  cte00m00_modifica

#------------------------#
function cte00m00_inclui()
#------------------------#

 define cte00m00      record
    corasscod         like dackass.corasscod,
    corassdes         like dackass.corassdes,
    corassagpcod      like dackass.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    prgextcod         like dackprgext.prgextcod,
    prgextdes         like dackprgext.prgextdes,
    corasspndflg      like dackass.corasspndflg,
    corasshstflg      like dackass.corasshstflg,
    maienvflg         like dackass.maienvflg,
    webrlzflg         like dackass.webrlzflg,
    atdexbflg         like dackass.atdexbflg,
    slccctcod         like dackass.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackass.corasspsocod,
    corassstt         like dackass.corassstt,
    caddat            like dackass.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackass.atldat,
    funnom            like isskfunc.funnom
 end record

 define param         record
    corasscod         like dackass.corasscod
 end record

 define  ws_resp       char(01)

 initialize cte00m00.*, param.*   to null

 display by name  cte00m00.*

 call cte00m00_input("i", param.*, cte00m00.*)
                 returning param.*, cte00m00.*

 if int_flag  then
    let int_flag = false
    initialize cte00m00.*  to null
    display by name  cte00m00.*
    error " Operacao cancelada!"
    return
 end if

 let cte00m00.atldat = today
 let cte00m00.caddat = today


 whenever error continue

 begin work
    insert into dackass     ( corasscod,
                              corassdes,
                              corassagpcod,
                              prgextcod,
                              corasspndflg,
                              corasshstflg,
                              maienvflg,
                              webrlzflg,
                              atdexbflg,
                              slccctcod,
                              corasspsocod,
                              corassstt,
                              caddat,
                              cademp,
                              cadmat,
                              atldat,
                              atlemp,
                              atlmat )
                  values
                            ( cte00m00.corasscod,
                              cte00m00.corassdes,
                              cte00m00.corassagpcod,
                              cte00m00.prgextcod,
                              cte00m00.corasspndflg,
                              cte00m00.corasshstflg,
                              cte00m00.maienvflg,
                              cte00m00.webrlzflg,
                              cte00m00.atdexbflg,
                              cte00m00.slccctcod,
                              cte00m00.corasspsocod,
                              cte00m00.corassstt,
                              cte00m00.caddat,
                              g_issk.empcod,
                              g_issk.funmat,
                              cte00m00.atldat,
                              g_issk.empcod,
                              g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do assunto!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call cte00m00_func(g_issk.empcod,g_issk.funmat)
      returning cte00m00.cadfunnom

 call cte00m00_func(g_issk.empcod,g_issk.funmat)
      returning cte00m00.funnom

 display by name  cte00m00.*

 display by name cte00m00.corasscod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize cte00m00 to null

 display by name cte00m00.*

 end function   #  cte00m00_inclui

#-------------------------------------------------#
function cte00m00_input(ws_operacao,param,cte00m00)
#-------------------------------------------------#

 define ws_operacao   char (1)

 define param         record
    corasscod         like dackass.corasscod 
 end record

 define cte00m00      record
    corasscod         like dackass.corasscod,
    corassdes         like dackass.corassdes,
    corassagpcod      like dackass.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    prgextcod         like dackprgext.prgextcod,
    prgextdes         like dackprgext.prgextdes,
    corasspndflg      like dackass.corasspndflg,
    corasshstflg      like dackass.corasshstflg,
    maienvflg         like dackass.maienvflg,
    webrlzflg         like dackass.webrlzflg,
    atdexbflg         like dackass.atdexbflg,
    slccctcod         like dackass.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackass.corasspsocod,
    corassstt         like dackass.corassstt,
    caddat            like dackass.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackass.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    cont              integer
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
    cctlclnom     like ctgklcl.cctlclnom,       --Nome do local
    cctdptnom     like ctgkdpt.cctdptnom,       --Nome do depto (antigo cctnom)
    cctdptrspnom  like ctgrlcldpt.cctdptrspnom, --Responsavel pelo departamento
    cctdptlclsit  like ctgrlcldpt.cctdptlclsit, --Sit do depto (A)tivo (I)nativo
    cctdpttip     like ctgkdpt.cctdpttip        -- Tipo de departamento
 end record

 let int_flag = false
 let ws.cont  = 0

 if ws_operacao   = "i"  then
    select max(corasscod)
         into ws.cont
         from dackass
    if  ws.cont  is null then
        let ws.cont =  1
    else
        let ws.cont = ws.cont + 1
    end if
 end if

 input by name cte00m00.corasscod,
               cte00m00.corassdes,
               cte00m00.corassagpcod,
               cte00m00.prgextcod,
               cte00m00.corasspndflg,
               cte00m00.corasshstflg,
               cte00m00.maienvflg,
               cte00m00.webrlzflg,
               cte00m00.atdexbflg,
               cte00m00.slccctcod,
               cte00m00.corasspsocod,
               cte00m00.corassstt  without defaults

    before field corasscod
            if ws_operacao  =  "a"   then
               next field  corassdes
            end if
            let cte00m00.corasscod = ws.cont
            display by name cte00m00.corasscod # attribute (reverse)
            next field  corassdes

    after  field corasscod
           display by name cte00m00.corasscod

           if cte00m00.corasscod  is null   then
              error " Codigo do assunto deve ser informado!"
              next field corasscod
           end if

           select corasscod
             from dackass
            where corasscod = cte00m00.corasscod

           if sqlca.sqlcode  =  0   then
              error " Codigo de assunto ja' cadastrado!"
              next field corasscod
           end if

    before field corassdes
           display by name cte00m00.corassdes #attribute (reverse)

    after  field corassdes
           display by name cte00m00.corassdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ws_operacao  =  "i"   then
                 next field  corasscod
              else
                 next field  corassdes
              end if
           end if

           if cte00m00.corassdes  is null   then
              error " Descricao do assunto deve ser informado!"
              next field corassdes
           end if

       before field corassagpcod
          display by name cte00m00.corassagpcod # attribute(reverse)

       after  field corassagpcod
          display by name cte00m00.corassagpcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field corassdes
          end if
          if cte00m00.corassagpcod is null   then
             call cto00m03() returning cte00m00.corassagpcod,
                                       cte00m00.corassagpdes
             if cte00m00.corassagpcod is null  then
                error " Codigo do Agrupamento deve ser informado!"
                next field corassagpcod
             end if
          end if
          select corassagpdes
                into cte00m00.corassagpdes
                from dackassagp
                where corassagpcod = cte00m00.corassagpcod

          if sqlca.sqlcode = notfound then
             error " Codigo de Agrupamento nao cadastrado"
             next field corassagpcod
          end if
          display by name cte00m00.corassagpcod
          display by name cte00m00.corassagpdes

       before field prgextcod
          display by name cte00m00.prgextcod # attribute(reverse)

       after  field prgextcod
          display by name cte00m00.prgextcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field corassagpcod
          end if

          if cte00m00.prgextcod is null  then
             call cto00m02() returning cte00m00.prgextcod,
                                       cte00m00.prgextdes
            #call ctc14m02() returning cte00m00.prgextcod,
            #                          cte00m00.prgextdes
             if cte00m00.prgextcod is null  then
                error " Acao a ser tomada deve ser informada!!!"
                next field prgextcod
             end if
          else
             select prgextdes
                    into cte00m00.prgextdes
                    from dackprgext
                    where prgextcod = cte00m00.prgextcod
             if sqlca.sqlcode = notfound  then
                error " Acao nao cadastrada! "
                next field prgextcod
             end if
          end if
          display by name cte00m00.prgextcod
          display by name cte00m00.prgextdes

    before field corasspndflg
           let cte00m00.corasspndflg  =  "N"
           display  by name cte00m00.corasspndflg # attribute (reverse)

    after  field corasspndflg
           display by name cte00m00.corasspndflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  prgextcod
           end if

           if cte00m00.corasspndflg is null   or
             (cte00m00.corasspndflg <> "S"    and
              cte00m00.corasspndflg <> "N")   then
              error " Aceita Pendencia deve ser: (S)Sim ou (N)Nao!"
              next field corasspndflg
           end if

    before field corasshstflg
           let cte00m00.corasshstflg  =  "N"
           display  by name cte00m00.corasshstflg # attribute (reverse)

    after  field corasshstflg
           display by name cte00m00.corasshstflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  corasspndflg
           end if

           if cte00m00.corasshstflg is null   or
             (cte00m00.corasshstflg <> "S"    and
              cte00m00.corasshstflg <> "N")   then
              error " Aceita Historico deve ser: (S)Sim ou (N)Nao!"
              next field corasshstflg
           end if

    before field maienvflg
           display  by name cte00m00.maienvflg # attribute (reverse)

    after  field maienvflg
           display  by name cte00m00.maienvflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field corasshstflg
           end if

           if cte00m00.maienvflg is null then
              let cte00m00.maienvflg = "N"
           end if

           if cte00m00.maienvflg = "S" then
              call cte00m04 (cte00m00.corasscod)
           end if

           display  by name cte00m00.maienvflg

    before field webrlzflg
       display by name cte00m00.webrlzflg #attribute(reverse)

    after field webrlzflg
       display by name cte00m00.webrlzflg

       if fgl_lastkey() = fgl_keyval ("up") or
          fgl_lastkey() = fgl_keyval ("left") then
          next field maienvflg
       end if

       if cte00m00.webrlzflg is null then
          let cte00m00.webrlzflg = "N"
          display by name cte00m00.webrlzflg
       end if

       if cte00m00.webrlzflg <> "N" and
          cte00m00.webrlzflg <> "S" then
          error " Acesso pela Web deve ser: (S)Sim ou (N)Nao!"
          let cte00m00.webrlzflg = "N"
          display by name cte00m00.webrlzflg
          next field webrlzflg
       end if

    before field atdexbflg
       display by name cte00m00.atdexbflg #attribute(reverse)

    after field atdexbflg
       display by name cte00m00.atdexbflg

       if fgl_lastkey() = fgl_keyval ("up") or
          fgl_lastkey() = fgl_keyval ("left") then
          next field webrlzflg
       end if

       if cte00m00.atdexbflg is null then
          let cte00m00.atdexbflg = "N"
          display by name cte00m00.atdexbflg
       end if

       if cte00m00.atdexbflg <> "N" and
          cte00m00.atdexbflg <> "S" then
          error " Exibe o Assunto deve ser: (S)Sim ou (N)Nao!"
          let cte00m00.atdexbflg = "N"
          display by name cte00m00.atdexbflg
          next field atdexbflg
       end if

    before field slccctcod
       display by name cte00m00.slccctcod  attribute (reverse)

    after  field slccctcod
       display by name cte00m00.slccctcod

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field atdexbflg
       end if

       if cte00m00.slccctcod is not null  then
          let lr_param.empcod    = 1
          let lr_param.succod    = 1
          let lr_param.cctlclcod = (cte00m00.slccctcod / 10000)
          let lr_param.cctdptcod = (cte00m00.slccctcod mod 10000)
          call fctgc102_vld_dep(lr_param.*)
          returning lr_ret.*
          let cte00m00.cctnom = lr_ret.cctdptnom
          display by name cte00m00.cctnom
       end if

    before field corasspsocod
       display by name cte00m00.corasspsocod attribute(reverse)

    after  field corasspsocod
       display by name cte00m00.corasspsocod

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field slccctcod
       end if

    before field corassstt
           if ws_operacao  =  "i"   then
              let cte00m00.corassstt = "A"
           end if
           display  by name cte00m00.corassstt # attribute (reverse)

    after  field corassstt
           display by name cte00m00.corassstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  corasspndflg
           end if

           if cte00m00.corassstt  is null   or
             (cte00m00.corassstt  <> "A"    and
              cte00m00.corassstt  <> "C")   then
              error " Situacao assunto deve ser: (A)tivo ou (C)ancelado!"
              next field corassstt
           end if

           if ws_operacao      = "i"   and
              cte00m00.corassstt  = "C"   then
              error " Nao deve ser incluido assunto com situacao (C)ancelado!"
              next field corassstt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize param.*, cte00m00.*  to null
 end if

 return param.*, cte00m00.*

 end function   # cte00m00_input


#---------------------------------------------------------
 function cte00m00_ler(param)
#---------------------------------------------------------

 define param         record
    corasscod         like dackass.corasscod 
 end record

 define cte00m00      record
    corasscod         like dackass.corasscod,
    corassdes         like dackass.corassdes,
    corassagpcod      like dackass.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    prgextcod         like dackprgext.prgextcod,
    prgextdes         like dackprgext.prgextdes,
    corasspndflg      like dackass.corasspndflg,
    corasshstflg      like dackass.corasshstflg,
    maienvflg         like dackass.maienvflg,
    webrlzflg         like dackass.webrlzflg,
    atdexbflg         like dackass.atdexbflg,
    slccctcod         like dackass.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackass.corasspsocod,
    corassstt         like dackass.corassstt,
    caddat            like dackass.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackass.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    atlemp            like dackass.atlemp,
    cadmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    corassagpcod      like dackass.corassagpcod
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
    cctlclnom     like ctgklcl.cctlclnom,       --Nome do local
    cctdptnom     like ctgkdpt.cctdptnom,       --Nome do depto (antigo cctnom)
    cctdptrspnom  like ctgrlcldpt.cctdptrspnom, --Responsavel pelo departamento
    cctdptlclsit  like ctgrlcldpt.cctdptlclsit, --Sit do depto (A)tivo (I)nativo
    cctdpttip     like ctgkdpt.cctdpttip        -- Tipo de departamento
 end record

 initialize cte00m00.*   to null
 initialize ws.*         to null

 select  corasscod,
         corassdes,
         corassagpcod,
         slccctcod,
         corasspsocod,
         corassstt,
         prgextcod,
         corasspndflg,
         corasshstflg,
         maienvflg,
         webrlzflg,
         atdexbflg,
         caddat,
         cadmat,
         cademp,
         atldat ,
         atlmat ,
         atlemp
   into  cte00m00.corasscod,
         cte00m00.corassdes,
         ws.corassagpcod,
         cte00m00.slccctcod,
         cte00m00.corasspsocod,
         cte00m00.corassstt,
         cte00m00.prgextcod,
         cte00m00.corasspndflg,
         cte00m00.corasshstflg,
         cte00m00.maienvflg,
         cte00m00.webrlzflg,
         cte00m00.atdexbflg,
         cte00m00.caddat,
         ws.cadmat,
         ws.cademp,
         cte00m00.atldat,
         ws.atlmat,
         ws.atlemp
   from  dackass
  where  corasscod = param.corasscod

 if sqlca.sqlcode = notfound   then
    error " Codigo de assunto nao cadastrado!"
    initialize cte00m00.*    to null
    return cte00m00.*
 else
    call cte00m00_func(ws.cademp,ws.cadmat)
         returning cte00m00.cadfunnom

    call cte00m00_func(ws.atlemp,ws.atlmat)
         returning cte00m00.funnom

    select prgextdes
      into cte00m00.prgextdes
      from dackprgext
     where prgextcod = cte00m00.prgextcod

    select corassagpcod, corassagpdes
        into cte00m00.corassagpcod, cte00m00.corassagpdes
        from dackassagp
        where corassagpcod = ws.corassagpcod


        let lr_param.empcod    = 1
        let lr_param.succod    = 1
        let lr_param.cctlclcod = (cte00m00.slccctcod / 10000)
        let lr_param.cctdptcod = (cte00m00.slccctcod mod 10000)
        call fctgc102_vld_dep(lr_param.*)
        returning lr_ret.*
        let cte00m00.cctnom = lr_ret.cctdptnom

 end if

 return cte00m00.*

 end function   # cte00m00_ler


#---------------------------------------------------------
 function cte00m00_func(param)
#---------------------------------------------------------

   define param         record
      empcod            like isskfunc.empcod,
      funmat            like isskfunc.funmat
   end record

   define ws            record
      funnom            like isskfunc.funnom
   end record

   initialize ws.*    to null

   select funnom
     into ws.funnom
     from isskfunc
    where isskfunc.empcod = param.empcod
      and isskfunc.funmat = param.funmat
      and isskfunc.usrtip = "F"

   return ws.funnom

 end function   # cte00m00_func
