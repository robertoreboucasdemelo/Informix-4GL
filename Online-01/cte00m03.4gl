###########################################################################
# Nome do Modulo: CTE00M03                                           Raji #
#                                                                    Ruiz #
# Cadastro de codigos de programa                                Ago/2000 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#

# ........................................................................#
#                                                                         #
#                    * * * Alteracoes * * *                               #
#                                                                         #
# Data       Autor Fabrica   Origem        Alteracao                      #
# ---------- --------------  ----------    -------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao              # 
#                                          "fun_dba_abre_banco" e troca da#
#                                          "systables" por "dual"         #
#-------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
#-------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
{
main
	let g_issk.empcod = "1"
	let g_issk.funmat = "61566"
	call cte00m03()
end main
}
#------------------------------------------------------------



#------------------------------------------------------------
 function cte00m03()
#------------------------------------------------------------

 define cte00m03      record
    prgextcod         like dackprgext.prgextcod,
    prgsgl            like dackprgext.prgsgl,
    prgextdes         like dackprgext.prgextdes,
    caddat            like dackprgext.caddat,
    cademp            like dackprgext.cademp,
    cadmat            like dackprgext.cadmat,
    funnom            like isskfunc.funnom
 end record

 define param record
    prgextcod         like dackass.prgextcod
 enD record

#PSI 202290
#if not get_niv_mod(g_issk.prgsgl, "cte00m03) then
#    error "Modulo sem nivel de consulta e atualizacao!"
#    return
# end if

 let int_flag = false

 initialize cte00m03.*  to null

 open window cte00m03 at 04,02 with form "cte00m03"


 menu "Programas"

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
                   "Pesquisa programa conforme criterios"
          call cte00m03_seleciona()  returning param.*
          if param.prgextcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum programa selecionado!"
             message ""
             next option "Seleciona"
          end if

  command key ("P") "Proximo"
                   "Mostra proximo programa selecionado"
          message ""
          call cte00m03_proximo(param.*)
               returning param.*

  command key ("A") "Anterior"
                   "Mostra programa anterior selecionado"
          message ""
          if param.prgextcod    is not null then
             call cte00m03_anterior(param.prgextcod   )
                  returning param.*
          else
             error " Nenhum programa nesta direcao!"
             next option "Seleciona"
          end if

  command key ("M") "Modifica"
                   "Modifica programa corrente selecionado"
          message ""
          if param.prgextcod     is not null then
             call cte00m03_modifica(param.*)
                  returning param.*
             next option "Seleciona"
          else
             error " Nenhum programa selecionado!"
             next option "Seleciona"
          end if

  command key ("I") "Inclui"
                   "Inclui programa"
          message ""
          call cte00m03_inclui()
          next option "Seleciona"

  command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window cte00m03

 end function  # cte00m03


#------------------------------------------------------------
 function cte00m03_seleciona()
#------------------------------------------------------------

 define cte00m03      record
    prgextcod         like dackprgext.prgextcod,
    prgsgl            like dackprgext.prgsgl,
    prgextdes         like dackprgext.prgextdes,
    caddat            like dackprgext.caddat,
    cademp            like dackprgext.cademp,
    cadmat            like dackprgext.cadmat,
    funnom            like isskfunc.funnom
 end record

 define param         record
    prgextcod         like dackprgext.prgextcod
 end record

 let int_flag = false
 initialize cte00m03.*  to null
 initialize param.*     to null
 display by name cte00m03.*

 input by name cte00m03.prgextcod

    before field prgextcod
        display by name cte00m03.prgextcod attribute (reverse)

    after  field prgextcod
        display by name cte00m03.prgextcod

        if cte00m03.prgextcod  is null  or
           cte00m03.prgextcod  =  0     then
              error " Codigo de programa deve ser informado!"
              next field prgextcod
        end if
        display by name cte00m03.prgextcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize cte00m03.*   to null
    display by name cte00m03.*
    error " Operacao cancelada!"
    return param.*
 end if

 call cte00m03_ler(cte00m03.prgextcod)
      returning cte00m03.*

 if cte00m03.prgextcod  is not null   then
    display by name  cte00m03.*
 else
    error " programa nao cadastrado!"
    initialize cte00m03.*    to null
 end if

 let param.prgextcod = cte00m03.prgextcod
 return param.*

 end function  # cte00m03_seleciona


#------------------------------------------------------------
 function cte00m03_proximo(param)
#------------------------------------------------------------

 define param         record
    prgextcod         like dackprgext.prgextcod
 end record

 define cte00m03      record
    prgextcod         like dackprgext.prgextcod,
    prgsgl            like dackprgext.prgsgl,
    prgextdes         like dackprgext.prgextdes,
    caddat            like dackprgext.caddat,
    cademp            like dackprgext.cademp,
    cadmat            like dackprgext.cadmat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false

 select min(dackprgext.prgextcod)
   into cte00m03.prgextcod
   from dackprgext
  where dackprgext.prgextcod > param.prgextcod

 if cte00m03.prgextcod  is not null   then
    let param.prgextcod = cte00m03.prgextcod
    call cte00m03_ler(cte00m03.prgextcod)
         returning cte00m03.*
    display by name cte00m03.*
 else
    error " Nao ha' programa nesta direcao!"
 end if

 return param.*

 end function    # cte00m03_proximo


#------------------------------------------------------------
 function cte00m03_anterior(param)
#------------------------------------------------------------

 define param         record
    prgextcod         like dackprgext.prgextcod
 end record

 define cte00m03      record
    prgextcod         like dackprgext.prgextcod,
    prgsgl            like dackprgext.prgsgl,
    prgextdes         like dackprgext.prgextdes,
    caddat            like dackprgext.caddat,
    cademp            like dackprgext.cademp,
    cadmat            like dackprgext.cadmat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false

 select max(dackprgext.prgextcod)
   into cte00m03.prgextcod
   from dackprgext
  where dackprgext.prgextcod     < param.prgextcod

 if cte00m03.prgextcod  is not null   then
    let param.prgextcod = cte00m03.prgextcod
    call cte00m03_ler(cte00m03.prgextcod)
         returning cte00m03.*
    display by name cte00m03.*
 else
    error " Nao ha' programa nesta direcao!"
#   initialize cte00m03.*    to null
 end if

 return param.*

 end function    # cte00m03_anterior


#------------------------------------------------------------
 function cte00m03_modifica(param)
#------------------------------------------------------------

 define param         record
    prgextcod         like dackprgext.prgextcod
 end record

 define cte00m03      record
    prgextcod         like dackprgext.prgextcod,
    prgsgl            like dackprgext.prgsgl,
    prgextdes         like dackprgext.prgextdes,
    caddat            like dackprgext.caddat,
    cademp            like dackprgext.cademp,
    cadmat            like dackprgext.cadmat,
    funnom            like isskfunc.funnom
 end record

 call cte00m03_ler(param.prgextcod)
      returning cte00m03.*
 if cte00m03.prgextcod is null then
    error " Registro nao localizado "
    return param.*
 end if
 display by name  cte00m03.*

 call cte00m03_input("a", param.*,cte00m03.*)
                returning param.*, cte00m03.*

 if int_flag  then
    let int_flag = false
    initialize cte00m03.*  to null
    display by name  cte00m03.*
    error " Operacao cancelada!"
    return param.*
 end if

 whenever error continue


 begin work
    update dackprgext  set  ( prgsgl,
                              prgextdes,
                              caddat,
                              cademp,
                              cadmat )
                        =   ( cte00m03.prgsgl,
                              cte00m03.prgextdes,
                              cte00m03.caddat,
                              cte00m03.cademp,
                              cte00m03.cadmat )
           where dackprgext.prgextcod  =  param.prgextcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do programa!"
       rollback work
       initialize cte00m03.*   to null
       initialize param.*      to null
       return param.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize cte00m03.*  to null
 display by name  cte00m03.*
 message ""
 return param.*

 end function   #  cte00m03_modifica


#------------------------------------------------------------
 function cte00m03_inclui()
#------------------------------------------------------------

 define cte00m03      record
    prgextcod         like dackprgext.prgextcod,
    prgsgl            like dackprgext.prgsgl,
    prgextdes         like dackprgext.prgextdes,
    caddat            like dackprgext.caddat,
    cademp            like dackprgext.cademp,
    cadmat            like dackprgext.cadmat,
    funnom            like isskfunc.funnom
 end record

 define param         record
    prgextcod         like dackprgext.prgextcod
 end record

 define  ws_resp       char(01)

 initialize cte00m03.*, param.*   to null

 display by name  cte00m03.*

 call cte00m03_input("i", param.*, cte00m03.*)
                 returning param.*, cte00m03.*

 if int_flag  then
    let int_flag = false
    initialize cte00m03.*  to null
    display by name  cte00m03.*
    error " Operacao cancelada!"
    return
 end if

 #let cte00m03.caddat = today


 whenever error continue

 begin work
    insert into dackprgext  ( prgextcod,
                              prgsgl,
                              prgextdes,
                              caddat,
                              cademp,
                              cadmat )
                  values
                            ( cte00m03.prgextcod,
                              cte00m03.prgsgl,
                              cte00m03.prgextdes,
                              cte00m03.caddat,
                              cte00m03.cademp,
                              cte00m03.cadmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do programa!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 display by name  cte00m03.*

 display by name cte00m03.prgextcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize cte00m03.*  to null
 display by name cte00m03.*

 end function   #  cte00m03_inclui


#--------------------------------------------------------------------
 function cte00m03_input(ws_operacao,param,cte00m03)
#--------------------------------------------------------------------

 define ws_operacao   char (1)
 define funnom        char (30)
 define param         record
    prgextcod         like dackprgext.prgextcod
 end record

 define cte00m03      record
    prgextcod         like dackprgext.prgextcod,
    prgsgl            like dackprgext.prgsgl,
    prgextdes         like dackprgext.prgextdes,
    caddat            like dackprgext.caddat,
    cademp            like dackprgext.cademp,
    cadmat            like dackprgext.cadmat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    cont              integer
 end record


 let int_flag = false
 let ws.cont  = 0

 if ws_operacao   = "i"  then
    select max(prgextcod)
         into ws.cont
         from dackprgext
    if  ws.cont  is null then
        let ws.cont =  1
    else
        let ws.cont = ws.cont + 1
    end if
 end if

 input by name
               cte00m03.prgextcod,
               cte00m03.prgsgl,
               cte00m03.prgextdes,
               cte00m03.cademp,
               cte00m03.caddat,
               cte00m03.cadmat,
	       cte00m03.funnom	
	         without defaults

    before field prgextcod
            if ws_operacao  =  "a"   then
               next field  prgsgl
            end if
            let cte00m03.prgextcod = ws.cont
            display by name cte00m03.prgextcod # attribute (reverse)

            let cte00m03.caddat = today
            display by name cte00m03.caddat # attribute (reverse)

            let cte00m03.cademp = g_issk.empcod
            display by name cte00m03.cademp # attribute (reverse)

            let cte00m03.cadmat = g_issk.funmat
            display by name cte00m03.cadmat # attribute (reverse)

            call cte00m03_func(cte00m03.cadmat)
                 returning cte00m03.funnom
            display by name cte00m03.funnom # attribute (reverse)
            next field  prgsgl

    after  field prgextcod
           display by name cte00m03.prgextcod

           if cte00m03.prgextcod  is null   then
              error " Codigo do programa deve ser informado!"
              next field prgextcod
           end if

           select prgextcod
             from dackprgext
            where prgextcod = cte00m03.prgextcod

           if sqlca.sqlcode  =  0   then
              error " Codigo de programa ja' cadastrado!"
              next field prgextcod
           end if

    before field prgsgl
           display by name cte00m03.prgsgl #attribute (reverse)

    after  field prgsgl
           display by name cte00m03.prgsgl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ws_operacao  =  "i"   then
                 next field  prgextcod
              else
                 next field  prgsgl
              end if
           end if

           if cte00m03.prgsgl  is null   then
              error " Nome do programa deve ser informado!"
              next field prgsgl
           end if

    before field prgextdes
           display by name cte00m03.prgextdes #attribute (reverse)

    after  field prgextdes
           display by name cte00m03.prgextdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  prgsgl
           end if

           if cte00m03.prgextdes  is null   then
              error " Descricao do programa deve ser informado!"
              next field prgextdes
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize param.*, cte00m03.*  to null
 end if

 return param.*, cte00m03.*

 end function   # cte00m03_input


#---------------------------------------------------------
 function cte00m03_ler(param)
#---------------------------------------------------------

 define param         record
    prgextcod         like dackprgext.prgextcod
 end record

 define cte00m03      record
    prgextcod         like dackprgext.prgextcod,
    prgsgl            like dackprgext.prgsgl,
    prgextdes         like dackprgext.prgextdes,
    caddat            like dackprgext.caddat,
    cademp            like dackprgext.cademp,
    cadmat            like dackprgext.cadmat,
    funnom            like isskfunc.funnom
 end record

 initialize cte00m03.*   to null

 select prgextcod,
           prgsgl,
        prgextdes,
           caddat,
           cademp,
           cadmat
   into  cte00m03.prgextcod,
         cte00m03.prgsgl,
         cte00m03.prgextdes,
         cte00m03.caddat,
         cte00m03.cademp,
         cte00m03.cadmat
   from  dackprgext
  where  prgextcod = param.prgextcod

 if sqlca.sqlcode = notfound   then
    error " Codigo de programa nao cadastrado!"
    initialize cte00m03.*    to null
    return cte00m03.*
 end if
 call cte00m03_func(cte00m03.cadmat)
    returning cte00m03.funnom
 return cte00m03.*

 end function   # cte00m03_ler



#---------------------------------------------------------
 function cte00m03_func(_funmat)
#---------------------------------------------------------

   define _funmat like isskfunc.funmat

   define _funnom like isskfunc.funnom

   initialize _funnom to null

   select funnom
     into _funnom
     from isskfunc
    where isskfunc.funmat = _funmat

   return _funnom

 end function   # cte00m03_func
