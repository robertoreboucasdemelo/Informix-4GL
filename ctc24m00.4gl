###########################################################################
# Nome do Modulo: CTC24M00                                        Marcelo #
#                                                                Gilberto #
# Manutencao no Cadastro de Topicos e Procedimentos              Mar/1996 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONS. DESCRICAO                             #
#-------------------------------------------------------------------------#
# 03/01/2002  PSI 144908   Ruiz     Guardar historico da alteracao.       #
#-------------------------------------------------------------------------#
# 25/09/2006  PSI 202290   Priscila Remover verificacao nivel de acesso   #
###########################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc24m00()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define ctc24m00     record
          cvnnum       like datktopcvn.cvnnum    ,
          cvntopcod    like datktopcvn.cvntopcod ,
          cvntopnom    like datktopcvn.cvntopnom
   end record

   define k_ctc24m00   record
          cvnnum       like datktopcvn.cvnnum    ,
          cvntopcod    like datktopcvn.cvntopcod
   end record



	initialize  ctc24m00.*  to  null

	initialize  k_ctc24m00.*  to  null

   #PSI 202290
   #if not get_niv_mod(g_issk.prgsgl, "ctc24m00") then
   #   error "Modulo sem nivel de consulta e atualizacao!"
   #   return
   #end if

   let int_flag = false

   initialize ctc24m00.*   to  null
   initialize k_ctc24m00.* to  null

   open window ctc24m00 at 4,2 with form "ctc24m00"
           attribute(message line last, comment line last -1)

   menu "TOPICOS"

       before menu
          hide option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica" , "Remove" , "Inclui"
          #end if

          show option "Encerra"

   command "Seleciona" "Seleciona registro na tabela conforme criterios"
            call seleciona_ctc24m00() returning k_ctc24m00.*
            if k_ctc24m00.cvnnum    is not null and
               k_ctc24m00.cvntopcod is not null then
               next option "Proximo"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo topico"
            if k_ctc24m00.cvnnum    is not null and
               k_ctc24m00.cvntopcod is not null then
               call proximo_ctc24m00(k_ctc24m00.*)  returning k_ctc24m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra topico anterior"
            if k_ctc24m00.cvnnum    is not null and
               k_ctc24m00.cvntopcod is not null then
               call anterior_ctc24m00(k_ctc24m00.*)  returning k_ctc24m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica registro corrente selecionado"
            if k_ctc24m00.cvnnum    is not null and
               k_ctc24m00.cvntopcod is not null then
               call modifica_ctc24m00(k_ctc24m00.*)  returning k_ctc24m00.*
               initialize ctc24m00.*   to  null
               initialize k_ctc24m00.* to  null
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove registro corrente selecionado"
            if k_ctc24m00.cvnnum    is not null and
               k_ctc24m00.cvntopcod is not null then
               call remove_ctc24m00(k_ctc24m00.*)  returning k_ctc24m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui registro na tabela"
            call inclui_ctc24m00()
            initialize ctc24m00.*   to  null
            initialize k_ctc24m00.* to  null

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc24m00

end function  # ctc24m00

#------------------------------------------------------------
 function seleciona_ctc24m00()
#------------------------------------------------------------

   define ctc24m00    record
          cvnnum      like datktopcvn.cvnnum    ,
          cvntopcod   like datktopcvn.cvntopcod ,
          cvntopnom   like datktopcvn.cvntopnom
   end record

   define k_ctc24m00  record
          cvnnum      like datktopcvn.cvnnum    ,
          cvntopcod   like datktopcvn.cvntopcod
   end record

   define ws          record
          count       smallint ,
          convenio    char(20) ,
          topico      like datktopcvn.cvntopnom
   end record

   define aux_status  char(01)


	let	aux_status  =  null

	initialize  ctc24m00.*  to  null

	initialize  k_ctc24m00.*  to  null

	initialize  ws.*  to  null

   clear form
   let int_flag = false
   initialize k_ctc24m00.* to null

   input by name k_ctc24m00.*  without defaults

      before field cvnnum
          display by name k_ctc24m00.cvnnum attribute (reverse)

      after  field cvnnum
          display by name k_ctc24m00.cvnnum

          if k_ctc24m00.cvnnum is null then
             error "Codigo do Convenio e' obrigatorio!"
             call ctc24m02() returning k_ctc24m00.cvnnum
             next field cvnnum
          end if

          select cpodes
            into ws.convenio
            from datkdominio
           where cponom = "ligcvntip"
             and cpocod = k_ctc24m00.cvnnum

          if sqlca.sqlcode = notfound then
             error "Convenio nao encontrado! Informe novamente."
             call ctc24m02() returning k_ctc24m00.cvnnum
             next field cvnnum
          end if

         display by name ws.convenio

         let ws.count = 0

         select count(*) into ws.count
           from datktopcvn
          where cvnnum = k_ctc24m00.cvnnum

         if ws.count = 0 then
            error "Nao existem topicos cadastrados para este convenio!"
            next field cvnnum
         else
            next field cvntopcod
         end if

      before field cvntopcod
          display by name k_ctc24m00.cvntopcod attribute (reverse)

      after  field cvntopcod
          display by name k_ctc24m00.cvntopcod

          if k_ctc24m00.cvntopcod is null then
             error "Codigo do Topico e' obrigatorio!"
             call ctc24m03(k_ctc24m00.cvnnum)
                  returning k_ctc24m00.cvntopcod, aux_status
             if aux_status = 'X' then
                initialize k_ctc24m00.cvnnum to null
                initialize ws.convenio       to null
                display by name k_ctc24m00.cvnnum
                display by name ws.convenio
                exit input
             end if
             next field cvntopcod
          end if

          select cvntopnom
            into ws.topico
            from datktopcvn
           where cvnnum    = k_ctc24m00.cvnnum
             and cvntopcod = k_ctc24m00.cvntopcod

          if sqlca.sqlcode = notfound then
             error "Topico nao cadastrado! Informe novamente."
             call ctc24m03(k_ctc24m00.cvnnum)
                  returning k_ctc24m00.cvntopcod, aux_status
             if aux_status = 'X' then
                initialize k_ctc24m00.cvnnum to null
                initialize ws.convenio       to null
                display by name k_ctc24m00.cvnnum
                display by name ws.convenio
                exit input
             end if
             next field cvntopcod
          end if

      on key (interrupt)
          exit input

   end input

   if int_flag  then
      let int_flag = false
      initialize ctc24m00.* to null
      error "Operacao cancelada!"
      clear form
      return k_ctc24m00.*
   end if

   select cvnnum, cvntopcod, cvntopnom
     into ctc24m00.cvnnum, ctc24m00.cvntopcod, ctc24m00.cvntopnom
     from datktopcvn
    where datktopcvn.cvnnum    = k_ctc24m00.cvnnum
      and datktopcvn.cvntopcod = k_ctc24m00.cvntopcod

   if sqlca.sqlcode = 0   then
      display by name  ctc24m00.cvnnum, ctc24m00.cvntopcod, ctc24m00.cvntopnom
      call display_ctc24m00(k_ctc24m00.cvnnum, k_ctc24m00.cvntopcod)
   else
      error "Registro nao cadastrado!"
      initialize ctc24m00.*    to null
      initialize k_ctc24m00.*  to null
   end if

   return k_ctc24m00.*

end function  # seleciona

#------------------------------------------------------------
 function modifica_ctc24m00(k_ctc24m00)
#------------------------------------------------------------
# Modifica registros na tabela
#

   define ctc24m00   record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod ,
          cvntopnom  like datktopcvn.cvntopnom
   end record

   define k_ctc24m00 record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod
   end record



	initialize  ctc24m00.*  to  null

   select cvnnum, cvntopcod, cvntopnom
     into ctc24m00.cvnnum, ctc24m00.cvntopcod, ctc24m00.cvntopnom
     from datktopcvn
    where datktopcvn.cvnnum    = k_ctc24m00.cvnnum  and
          datktopcvn.cvntopcod = k_ctc24m00.cvntopcod

   call input_ctc24m00("a", k_ctc24m00.* , ctc24m00.*) returning ctc24m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc24m00.*  to null
      error "Operacao cancelada!"
      clear form
      return k_ctc24m00.*
   end if

   whenever error continue

   begin work
     update datktopcvn set ( cvntopnom ) = ( ctc24m00.cvntopnom )
      where datktopcvn.cvnnum    =  k_ctc24m00.cvnnum   and
            datktopcvn.cvntopcod = k_ctc24m00.cvntopcod
   commit work

   if sqlca.sqlcode <>  0  then
      error "Erro na Alteracao do Registro!"
      rollback work
      initialize ctc24m00.*   to null
      initialize k_ctc24m00.* to null
      return k_ctc24m00.*
   else
      call ctc24m01("a", ctc24m00.*)
   end if

   whenever error stop
   clear form

   return k_ctc24m00.*

end function

#--------------------------------------------------------------------
function remove_ctc24m00(k_ctc24m00)
#--------------------------------------------------------------------

   define ctc24m00   record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod ,
          cvntopnom  like datktopcvn.cvntopnom
   end record

   define k_ctc24m00 record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod
   end record



	initialize  ctc24m00.*  to  null

   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do topico"
              clear form
              initialize ctc24m00.*   to null
              initialize k_ctc24m00.* to null
              error "Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui topico"
              call sel_ctc24m00(k_ctc24m00.*) returning ctc24m00.*

              if sqlca.sqlcode = notfound  then
                 initialize ctc24m00.*   to null
                 initialize k_ctc24m00.* to null
                 error "Registro nao localizado!"
              else
                 whenever error continue
                 begin work
                    delete from datktopcvn
                          where datktopcvn.cvnnum    = ctc24m00.cvnnum and
                                datktopcvn.cvntopcod = ctc24m00.cvntopcod

                    delete from datkdestopcvn
                          where datkdestopcvn.cvnnum    = ctc24m00.cvnnum and
                                datkdestopcvn.cvntopcod = ctc24m00.cvntopcod
                 commit work

                 if sqlca.sqlcode <>  0  then
                    error "Erro na Remocao do Registro!"
                    rollback work
                 else
                    error  "Registro removido!"
                 end if
                 whenever error stop

                 initialize ctc24m00.*   to null
                 initialize k_ctc24m00.* to null
                 clear form
              end if
              exit menu
   end menu

   return k_ctc24m00.*

end function    # remove_ctc24m00

#------------------------------------------------------------
function inclui_ctc24m00()
#------------------------------------------------------------
# Inclui registros na tabela
#
   define ctc24m00   record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod ,
          cvntopnom  like datktopcvn.cvntopnom
   end record

   define k_ctc24m00  record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod
   end record



	initialize  ctc24m00.*  to  null

	initialize  k_ctc24m00.*  to  null

   clear form

   initialize ctc24m00.*   to null
   initialize k_ctc24m00.* to null

   call input_ctc24m00("i",k_ctc24m00.*, ctc24m00.*) returning ctc24m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc24m00.*  to null
      error "Operacao cancelada!"
      clear form
      return
   end if

   call ctc24m01("i", ctc24m00.*)

   clear form

end function  # inclui

#--------------------------------------------------------------------
 function input_ctc24m00(operacao_aux, k_ctc24m00, ctc24m00)
#--------------------------------------------------------------------
   define operacao_aux   char (1)

   define  ctc24m00   record
           cvnnum     like datktopcvn.cvnnum    ,
           cvntopcod  like datktopcvn.cvntopcod ,
           cvntopnom  like datktopcvn.cvntopnom
   end record

   define  k_ctc24m00 record
           cvnnum     like datktopcvn.cvnnum    ,
           cvntopcod  like datktopcvn.cvntopcod
   end record

   define  ws_convenio char(20)


	let	ws_convenio  =  null

   let int_flag = false

   input by name ctc24m00.cvnnum   ,
                 ctc24m00.cvntopcod,
                 ctc24m00.cvntopnom    without defaults

      before field cvnnum
          if operacao_aux = "a" then
             let ctc24m00.cvnnum = k_ctc24m00.cvnnum

             select cpodes
               into ws_convenio
               from datkdominio
              where cponom = "ligcvntip"
                and cpocod = ctc24m00.cvnnum

             if sqlca.sqlcode = notfound then
                error "Convenio nao encontrado!"
                exit input
             end if

             display ws_convenio to convenio
             next field cvntopcod
          else
             display by name ctc24m00.cvnnum attribute (reverse)
          end if

      after  field cvnnum
          display by name ctc24m00.cvnnum

          if ctc24m00.cvnnum is null then
             error "Codigo do Convenio e' obrigatorio!"
             call ctc24m02() returning ctc24m00.cvnnum
             next field cvnnum
          end if

          select cpodes
            into ws_convenio
            from datkdominio
           where cponom = "ligcvntip"
             and cpocod = ctc24m00.cvnnum

          if sqlca.sqlcode = notfound then
             error "Convenio nao encontrado! Informe novamente."
             call ctc24m02() returning ctc24m00.cvnnum
             next field cvnnum
          end if

         display ws_convenio to convenio
         next field cvntopcod

   before field cvntopcod
          if operacao_aux = "a"   then
             next field cvntopnom
          else
             display by name ctc24m00.cvntopcod attribute (reverse)
          end if

   after field cvntopcod
          display by name ctc24m00.cvntopcod

          if operacao_aux  =  "i"   then
             select * from datktopcvn
              where cvnnum    = ctc24m00.cvnnum    and
                    cvntopcod = ctc24m00.cvntopcod

             if sqlca.sqlcode  =  0   then
                error " Topico ja' cadastrado !!"
                next field cvntopcod
             end if
          end if

   before field cvntopnom
          display by name ctc24m00.cvntopnom attribute (reverse)

   after field cvntopnom
          display by name ctc24m00.cvntopnom

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc24m00.*  to null
   end if

   return ctc24m00.*

end function   # input_ctc24m00

#---------------------------------------------------------
function sel_ctc24m00(k_ctc24m00)
#---------------------------------------------------------

   define  ctc24m00   record
           cvnnum     like datktopcvn.cvnnum    ,
           cvntopcod  like datktopcvn.cvntopcod ,
           cvntopnom  like datktopcvn.cvntopnom
   end record

   define  k_ctc24m00 record
           cvnnum     like datktopcvn.cvnnum    ,
           cvntopcod  like datktopcvn.cvntopcod
   end record



	initialize  ctc24m00.*  to  null

   select cvnnum, cvntopcod, cvntopnom
     into ctc24m00.cvnnum, ctc24m00.cvntopcod, ctc24m00.cvntopnom
     from datktopcvn
    where datktopcvn.cvnnum    = k_ctc24m00.cvnnum
      and datktopcvn.cvntopcod = k_ctc24m00.cvntopcod

   return ctc24m00.*

end function   # sel_ctc24m00

#---------------------------------------------------------------
 function display_ctc24m00(par_ctc24m00)
#---------------------------------------------------------------

   define par_ctc24m00 record
          cvnnum    like datktopcvn.cvnnum ,
          cvntopcod like datktopcvn.cvntopcod
   end record

   define a_ctc24m00 array[500] of record
      cvntopdes      like datkdestopcvn.cvntopdes ,
      cvntopdesseq   like datkdestopcvn.cvntopdesseq
   end record

   define ws   record
          count      smallint,
          cvntopnom  like datktopcvn.cvntopnom
   end record
   define arr_aux    integer


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  500
		initialize  a_ctc24m00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   declare c_ctc24m00 cursor for
      select cvntopdes, cvntopdesseq
        from datkdestopcvn
       where cvnnum    = par_ctc24m00.cvnnum
         and cvntopcod = par_ctc24m00.cvntopcod

   initialize a_ctc24m00  to null
   let arr_aux = 1

   foreach c_ctc24m00 into a_ctc24m00[arr_aux].cvntopdes ,
                           a_ctc24m00[arr_aux].cvntopdesseq

      let arr_aux = arr_aux + 1
      if arr_aux > 500 then
         exit foreach
      end if
   end foreach

  if arr_aux > 1 then
     let ws.count = 0
     select count(*) into ws.count
         from datmtopcvnhst
        where cvnnum    = par_ctc24m00.cvnnum
          and cvntopcod = par_ctc24m00.cvntopcod
     if ws.count > 0 then
        message  "(F7)Historico"
     else
        message  ""
     end if
     call set_count(arr_aux - 1)
     display array a_ctc24m00 to s_ctc24m00.*
       on key (interrupt, control-c)
          exit display

       on key (f7)
          if ws.count > 0 then
             select cvntopnom
                 into ws.cvntopnom
                 from datktopcvn
                where cvnnum    = par_ctc24m00.cvnnum
                  and cvntopcod = par_ctc24m00.cvntopcod

             call ctc24m04(par_ctc24m00.cvnnum,
                           par_ctc24m00.cvntopcod,
                           ws.cvntopnom)
          end if
     end display
  end if
end function  #  display_ctc24m00

#------------------------------------------------------------
 function proximo_ctc24m00(k_ctc24m00)
#------------------------------------------------------------

   define ctc24m00   record
          cvnnum     like datktopcvn.cvnnum ,
          cvntopcod  like datktopcvn.cvntopcod ,
          cvntopnom  like datktopcvn.cvntopnom
   end record

   define k_ctc24m00 record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod
   end record



	initialize  ctc24m00.*  to  null

   initialize ctc24m00.* to null

     select min(cvntopcod)
       into k_ctc24m00.cvntopcod
       from datktopcvn
      where datktopcvn.cvnnum    = k_ctc24m00.cvnnum    and
            datktopcvn.cvntopcod > k_ctc24m00.cvntopcod

      if  k_ctc24m00.cvntopcod is not null  then
          select cvnnum, cvntopcod, cvntopnom
            into ctc24m00.*
            from datktopcvn
           where datktopcvn.cvnnum    = k_ctc24m00.cvnnum    and
                 datktopcvn.cvntopcod = k_ctc24m00.cvntopcod

          display by name  ctc24m00.cvnnum    ,
                           ctc24m00.cvntopcod ,
                           ctc24m00.cvntopnom
          call display_ctc24m00(k_ctc24m00.*)
      else
          error "Nao ha' mais registros nesta direcao!"
          initialize ctc24m00.*    to null
      end if

   return k_ctc24m00.*

end function    # proximo_ctc24m00

#------------------------------------------------------------
 function anterior_ctc24m00(k_ctc24m00)
#------------------------------------------------------------

   define ctc24m00   record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod ,
          cvntopnom  like datktopcvn.cvntopnom
   end record

   define k_ctc24m00 record
          cvnnum     like datktopcvn.cvnnum    ,
          cvntopcod  like datktopcvn.cvntopcod
   end record



	initialize  ctc24m00.*  to  null

   initialize ctc24m00.* to null

      select max(cvntopcod)
        into k_ctc24m00.cvntopcod
        from datktopcvn
       where datktopcvn.cvnnum    = k_ctc24m00.cvnnum    and
             datktopcvn.cvntopcod < k_ctc24m00.cvntopcod

      if  k_ctc24m00.cvntopcod is not null  then
          select cvnnum, cvntopcod, cvntopnom
            into ctc24m00.*
            from datktopcvn
           where datktopcvn.cvnnum    = k_ctc24m00.cvnnum    and
                 datktopcvn.cvntopcod = k_ctc24m00.cvntopcod

          display by name  ctc24m00.cvnnum    ,
                           ctc24m00.cvntopcod ,
                           ctc24m00.cvntopnom
          call display_ctc24m00(k_ctc24m00.*)
      else
          error "Nao ha' mais registros nesta direcao!"
          initialize ctc24m00.*    to null
      end if

   return k_ctc24m00.*

end function    # anterior_ctc24m00
