###########################################################################
# Nome do Modulo: ctc43m01                                        Marcelo #
#                                                                Gilberto #
# Manutencao no cadastro de programacao de botoes dos MDTs       Jul/1999 #
###########################################################################
#                                                                         #
#                  * * * Alteracoes * * *                                 #
#                                                                         #
# Data        Autor Fabrica  Origem    Alteracao                          #
# ----------  -------------- --------- ---------------------------------- #
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
#-------------------------------------------------------------------------#

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc43m01()
#------------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc43m01") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 initialize d_ctc43m01.*   to  null
 let int_flag = false

 open window w_ctc43m01 at 4,2 with form "ctc43m01"

 menu "PROGRAMACOES"

     before menu
        hide option all
        #PSI 202290
        #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
        #      show option "Seleciona", "Proximo", "Anterior"
        #end if
        #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
              show option "Seleciona", "Proximo", "Anterior",
                          "Modifica", "Remove", "Inclui"
        #end if

        show option "Encerra"

 command "Seleciona" "Seleciona programacao conforme criterios"
          call ctc43m01_seleciona(d_ctc43m01.*)  returning  d_ctc43m01.*
          if d_ctc43m01.mdtprgcod is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma programacao selecionada!"
             message ""
             next option "Seleciona"
          end if

 command "Proximo" "Mostra proxima programacao selecionada"
          message ""
          if d_ctc43m01.mdtprgcod is not null then
             call ctc43m01_proximo(d_ctc43m01.*)  returning d_ctc43m01.*
          else
             error " Nenhuma programacao nesta direcao!"
             next option "Seleciona"
        end if

 command "Anterior" "Mostra programacao anterior selecionada"
          message ""
          if d_ctc43m01.mdtprgcod is not null then
             call ctc43m01_anterior(d_ctc43m01.*)  returning d_ctc43m01.*
          else
             error " Nenhuma programacao nesta direcao!"
             next option "Seleciona"
          end if

 command "Modifica" "Modifica programacao corrente selecionada"
          message ""
          if d_ctc43m01.mdtprgcod is not null then
             call ctc43m01_modifica(d_ctc43m01.*)  returning d_ctc43m01.*
             initialize d_ctc43m01.*   to  null
             next option "Seleciona"
          else
             error " Nenhuma programacao selecionada!"
             next option "Seleciona"
          end if
          initialize d_ctc43m01.*  to null

 command "Remove" "Remove programacao corrente selecionada"
          message ""
          if d_ctc43m01.mdtprgcod is not null then
             call ctc43m01_remove(d_ctc43m01.*)  returning d_ctc43m01.*
             next option "Seleciona"
          else
             error " Nenhuma programacao selecionada!"
             next option "Seleciona"
          end if
          initialize d_ctc43m01.*  to null

 command "Inclui" "Inclui programacao"
          message ""
          call inclui_ctc43m01()
          initialize d_ctc43m01.*  to null

 command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
          exit menu
 end menu

 close window w_ctc43m01

end function  ###-- ctc43m01


#------------------------------------------------------------
 function ctc43m01_seleciona(d_ctc43m01)
#------------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record


 clear form
 let int_flag = false
 initialize d_ctc43m01.*  to null

 input by name d_ctc43m01.mdtprgcod  without defaults

    before field mdtprgcod
        display by name d_ctc43m01.mdtprgcod attribute (reverse)

    after  field mdtprgcod
        display by name d_ctc43m01.mdtprgcod

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc43m01.*   to null
    error " Operacao cancelada!"
    clear form
    return d_ctc43m01.*
 end if

 call ctc43m01_ler(d_ctc43m01.*)  returning d_ctc43m01.*

 if d_ctc43m01.mdtprgcod  is not null  then
    display by name  d_ctc43m01.*
    call ctc43m01_display(d_ctc43m01.*)
 else
    error " Programacao nao cadastrada!"
    initialize d_ctc43m01.*  to null
 end if

 return d_ctc43m01.*

end function  ###-- ctc43m01_seleciona


#------------------------------------------------------------
 function ctc43m01_proximo(d_ctc43m01)
#------------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record


 select min (datkmdtprg.mdtprgcod)
   into d_ctc43m01.mdtprgcod
   from datkmdtprg
  where datkmdtprg.mdtprgcod > d_ctc43m01.mdtprgcod

 if  d_ctc43m01.mdtprgcod  is not null  then
     call ctc43m01_ler(d_ctc43m01.*)  returning d_ctc43m01.*

     if d_ctc43m01.mdtprgcod  is not null  then
        display by name  d_ctc43m01.*
        call ctc43m01_display(d_ctc43m01.*)
     else
        error " Programacao nao cadastrada!"
        initialize d_ctc43m01.*  to null
     end if
 else
    error " Nao ha' mais programacao nesta direcao!"
    initialize d_ctc43m01.*  to null
 end if

 return d_ctc43m01.*

end function    # ctc43m01_proximo


#------------------------------------------------------------
 function ctc43m01_anterior(d_ctc43m01)
#------------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record


 select max(datkmdtprg.mdtprgcod)
   into d_ctc43m01.mdtprgcod
   from datkmdtprg
  where datkmdtprg.mdtprgcod < d_ctc43m01.mdtprgcod

 if  d_ctc43m01.mdtprgcod  is not  null  then
     let d_ctc43m01.mdtprgcod = d_ctc43m01.mdtprgcod
     call ctc43m01_ler(d_ctc43m01.*)  returning d_ctc43m01.*

     if d_ctc43m01.mdtprgcod  is not null  then
        display by name  d_ctc43m01.*
        call ctc43m01_display(d_ctc43m01.*)
     else
        error " Programacao nao cadastrada!"
        initialize d_ctc43m01.*  to null
     end if
 else
    error " Nao ha' mais programacao nesta direcao!"
    initialize d_ctc43m01.*  to null
   end if

 return  d_ctc43m01.*

end function   ###-- ctc43m01_anterior


#------------------------------------------------------------
 function ctc43m01_modifica(d_ctc43m01)
#------------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record


 call ctc43m01_input("a", d_ctc43m01.*) returning d_ctc43m01.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc43m01.*  to null
    error " Operacao cancelada!"
    clear form
    return d_ctc43m01.*
 end if

 begin work
    update datkmdtprg set  ( mdtprgdes,
                             mdtprgstt )
                       =   ( d_ctc43m01.mdtprgdes,
                             d_ctc43m01.mdtprgstt )
     where datkmdtprg.mdtprgcod  =  d_ctc43m01.mdtprgcod
 commit work

 if sqlca.sqlcode <>  0  then
    error " Erro (",sqlca.sqlcode,") na alteracao da programacao!"
    rollback work
    initialize d_ctc43m01.*  to null
    return d_ctc43m01.*
 end if

 call ctc43m02("a", d_ctc43m01.mdtprgcod,
                    d_ctc43m01.mdtprgdes,
                    d_ctc43m01.mdtprgstt,
                    d_ctc43m01.atldat,
                    d_ctc43m01.funnom)

 clear form
 message ""

 return d_ctc43m01.*

end function   ###-- ctc43m01_modifica


#--------------------------------------------------------------------
 function ctc43m01_remove(d_ctc43m01)
#--------------------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record

 define ws             record
    mdtcod             like datkmdt.mdtcod
 end record


 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui programacao"
            clear form
            initialize d_ctc43m01.*   to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui programacao"
            call ctc43m01_ler(d_ctc43m01.*)  returning d_ctc43m01.*

            if sqlca.sqlcode = notfound         and
               d_ctc43m01.mdtprgcod  is null   then
               initialize d_ctc43m01.*   to null
               error "Programacao nao localizada!"
            else
               initialize ws.mdtcod  to null

               select max (datkmdt.mdtcod)
                 into ws.mdtcod
                 from datkmdt
                where datkmdt.mdtprgcod = d_ctc43m01.mdtprgcod

               if ws.mdtcod  is not null   and
                  ws.mdtcod  > 0           then
                  error " Programacao e' utilizada por MDT, portanto nao deve ser removida!"
                  exit menu
               end if

               begin work

                delete from datkmdtprg
                   where mdtprgcod = d_ctc43m01.mdtprgcod

                delete from datrmdtbotprg
                   where mdtprgcod = d_ctc43m01.mdtprgcod

                delete from datkmdtbotval
                   where mdtprgcod = d_ctc43m01.mdtprgcod

               commit work

               if sqlca.sqlcode <>  0  then
                  error " Erro (",sqlca.sqlcode,") na remocao da programacao!"
                  rollback work
               else
                  error  " Programacao removida!"
               end if

               initialize d_ctc43m01.*   to null
               message ""
               clear form
            end if
            exit menu
 end menu

 return d_ctc43m01.*

end function    ###-- ctc43m01_remove


#------------------------------------------------------------
 function inclui_ctc43m01()
#------------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record


 clear form
 initialize d_ctc43m01.*   to null

 call ctc43m01_input("i", d_ctc43m01.*)  returning d_ctc43m01.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc43m01.*  to null
    error " Operacao cancelada!"
    clear form
    return
 end if

 call ctc43m02("i", d_ctc43m01.mdtprgcod,
                    d_ctc43m01.mdtprgdes,
                    d_ctc43m01.mdtprgstt,
                    d_ctc43m01.atldat,
                    d_ctc43m01.funnom)

 clear form
 message ""

end function   ###-- ctc43m01_inclui


#--------------------------------------------------------------------
 function ctc43m01_input(param, d_ctc43m01)
#--------------------------------------------------------------------

 define param          record
    operacao           char (01)
 end record

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record

 define ws             record
    confirma           char (01)
 end record


 initialize ws.*  to null
 let int_flag     =  false
 let ws.confirma  =  "N"

 input by name d_ctc43m01.mdtprgdes,
               d_ctc43m01.mdtprgstt   without defaults

    before field mdtprgdes
           display by name d_ctc43m01.mdtprgdes attribute (reverse)

    after field mdtprgdes
           display by name d_ctc43m01.mdtprgdes

           if d_ctc43m01.mdtprgdes  is null   then
              error " Nome da programacao deve ser informado!"
              next field mdtprgdes
           end if

    before field mdtprgstt
           if param.operacao  =  "i"   then
              let d_ctc43m01.mdtprgstt  =  "A"
           end if
           display by name d_ctc43m01.mdtprgstt attribute (reverse)

    after field mdtprgstt
           display by name d_ctc43m01.mdtprgstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtprgdes
           end if

           if (d_ctc43m01.mdtprgstt  is null)  or
              (d_ctc43m01.mdtprgstt  <>  "A"   and
               d_ctc43m01.mdtprgstt  <>  "C")  then
              error " Situacao: (A)tivo, (C)ancelado!"
              next field mdtprgstt
           end if

           if param.operacao        =  "i"   and
              d_ctc43m01.mdtprgstt  <> "A"   then
              error " Na inclusao situacao deve ser ATIVO!"
              next field mdtprgstt
           end if

           if param.operacao        <>  "i"   and
              d_ctc43m01.mdtprgstt  =   "C"   then
              let ws.confirma  =  "N"

              declare c_datkmdt  cursor for
                select mdtcod
                  from datkmdt
                 where mdtprgcod  =  d_ctc43m01.mdtprgcod

              open  c_datkmdt
              fetch c_datkmdt

              if sqlca.sqlcode  =  0   then
                 call cts08g01("C","S",
                                   "EXISTEM MDTs QUE UTILIZAM ESTA",
                                   "PROGRAMACAO E COM O CANCELAMENTO",
                                   "FICARAO SEM PROGRAMACAO",
                                   "")
                      returning ws.confirma

                 if ws.confirma  =  "N"   then
                    close c_datkmdt
                    next field  mdtprgstt
                 end if
              end if

              close c_datkmdt

           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc43m01.*  to null
    return d_ctc43m01.*
 end if

 return d_ctc43m01.*

end function   # ctc43m01_input


#---------------------------------------------------------
 function ctc43m01_ler(d_ctc43m01)
#---------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record

 define ws             record
    atlemp             like datkmdtprg.atlemp,
    atlmat             like datkmdtprg.atlmat
 end record


 initialize ws.*  to null

 select mdtprgcod,
        mdtprgdes,
        mdtprgstt,
        atldat,
        atlemp,
        atlmat
   into d_ctc43m01.mdtprgcod,
        d_ctc43m01.mdtprgdes,
        d_ctc43m01.mdtprgstt,
        d_ctc43m01.atldat,
        ws.atlemp,
        ws.atlmat
 from datkmdtprg
  where datkmdtprg.mdtprgcod = d_ctc43m01.mdtprgcod

 if sqlca.sqlcode  =  0   then
    select funnom
      into d_ctc43m01.funnom
      from isskfunc
   where isskfunc.empcod  =  ws.atlemp
     and isskfunc.funmat  =  ws.atlmat
 else
    error " Programacao nao cadastrada!"
    initialize d_ctc43m01.*  to null
 end if

 return d_ctc43m01.*

end function   # ctc43m01_ler


#---------------------------------------------------------------
 function ctc43m01_display(d_ctc43m01)
#---------------------------------------------------------------

 define d_ctc43m01     record
    mdtprgcod          like datkmdtprg.mdtprgcod,
    mdtprgdes          like datkmdtprg.mdtprgdes,
    mdtprgstt          like datkmdtprg.mdtprgstt,
    atldat             like datkmdtprg.atldat,
    funnom             like isskfunc.funnom
 end record

 define a_ctc43m01     array[50] of record
   mdtbotcod           like datrmdtbotprg.mdtbotcod,
   mdtbottxt           like datkmdtbot.mdtbottxt,
   mdtbotprgseq        like datrmdtbotprg.mdtbotprgseq,
   mdtbotprgsisflg     like datrmdtbotprg.mdtbotprgsisflg,
   mdtbotprgdigflg     like datrmdtbotprg.mdtbotprgdigflg,
   mdtbotvldflg        char (01)
 end record

 define arr_aux        integer


 initialize a_ctc43m01  to null
 let arr_aux = 1

 declare c_ctc43m01 cursor for
    select datrmdtbotprg.mdtbotcod,
           datkmdtbot.mdtbottxt,
           datrmdtbotprg.mdtbotprgseq,
           datrmdtbotprg.mdtbotprgsisflg,
           datrmdtbotprg.mdtbotprgdigflg
      from datrmdtbotprg, datkmdtbot
     where datrmdtbotprg.mdtprgcod  =  d_ctc43m01.mdtprgcod
       and datkmdtbot.mdtbotcod     =  datrmdtbotprg.mdtbotcod
  order by datrmdtbotprg.mdtbotprgseq

 foreach c_ctc43m01 into a_ctc43m01[arr_aux].mdtbotcod,
                         a_ctc43m01[arr_aux].mdtbottxt,
                         a_ctc43m01[arr_aux].mdtbotprgseq,
                         a_ctc43m01[arr_aux].mdtbotprgsisflg,
                         a_ctc43m01[arr_aux].mdtbotprgdigflg

    let a_ctc43m01[arr_aux].mdtbotvldflg  =  "N"

    declare c_datkmdtbotval  cursor for
       select mdtbotvalcod
         from datkmdtbotval
        where datkmdtbotval.mdtprgcod  =  d_ctc43m01.mdtprgcod
          and datkmdtbotval.mdtbotcod  =  a_ctc43m01[arr_aux].mdtbotcod

    open  c_datkmdtbotval
    fetch c_datkmdtbotval
    if sqlca.sqlcode  =  0   then
       let a_ctc43m01[arr_aux].mdtbotvldflg  =  "S"
    end if
    close c_datkmdtbotval

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error " Limite excedido, programacao com mais de 50 botoes!"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux-1)
 message " (F17)Abandona, (F8)Validacao"

 display array  a_ctc43m01 to s_ctc43m01.*

    on key(f8)
       let int_flag = false
       let arr_aux  =  arr_curr()
       call ctc43m03( "N",
                      d_ctc43m01.mdtprgcod,
                      a_ctc43m01[arr_aux].mdtbotcod )
            returning a_ctc43m01[arr_aux].mdtbotvldflg

    on key(interrupt)
       let int_flag = false
       exit display
 end display

 message ""

end function  #  ctc43m01_display
