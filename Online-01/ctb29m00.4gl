#---------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                           #
# ..........................................................................#
# Sistema       : Central 24 Horas                                          #
# Modulo        : CTB29M00                                                  #
# Analista Resp.: Carlos Zyon                                               #
# PSI           : 188751                                                    #
#                 Parametros Porto Socorro                                  #
#...........................................................................#
# Desenvolvimento: Daniel , META                                            #
# Liberacao      : 17/03/2005                                               #
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor  Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- -------------------------------------#
#                                                                           #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"

define m_prep_sql   smallint
define m_selecionou smallint
define m_erro       smallint

define m_hostname   char(12)                                
define m_server     like ibpkdbspace.srvnom #Saymon ambnovo 


define mr_ctb29m00 record
    chave       like datkgeral.grlchv
   ,descricao   like datkgeral.grlinf
   ,valor       like datkgeral.grlinf
   ,atldat      like datkgeral.atldat
   ,atlhor      like datkgeral.atlhor
   ,atlemp      like datkgeral.atlemp
   ,atlmat      like datkgeral.atlmat
   ,funnom      like isskfunc.funnom
end record

#------------------------------------------------------------
function ctb29m00_prepare()
#------------------------------------------------------------

   define l_sql char(1000)
   
   let m_server   = fun_dba_servidor("CT24HS")
   let m_hostname = "porto@", m_server clipped , ":"
   
   
   let l_sql = " select atldat,atlhor,atlemp,atlmat,grlchv[4,15], "
              ," max(case grlchv[1,3] when 'PSO' then grlinf else '' end), "
              ," max(case grlchv[1,3] when 'PSD' then grlinf else '' end) "
              ," from ",m_hostname clipped,"datkgeral "
              ," where grlchv[1,3] in ('PSO','PSD') "
              ," and grlchv[4,15] = ? "
              ," group by 1,2,3,4,5 "
   prepare pctb29m00001 from l_sql
   declare cctb29m00001 cursor for pctb29m00001

   let l_sql = " select funnom "
                ," from isskfunc "
               ," where empcod = ? "
                 ," and isskfunc.funmat = ? "
   prepare pctb29m00002 from l_sql
   declare cctb29m00002 cursor for pctb29m00002

   let l_sql = " update ",m_hostname clipped,"datkgeral set (grlinf,atldat,atlhor,atlemp,atlmat) = (?,today,current,?,?) "
               ," where grlchv = ? "
   prepare pctb29m00003 from l_sql

   let l_sql = " insert into ",m_hostname clipped,"datkgeral (grlchv,grlinf,atldat,atlhor,atlemp,atlmat) "
              ," values (?,?,today,current,?,?) "
   prepare pctb29m00004 from l_sql

   let l_sql = " delete from ",m_hostname clipped,"datkgeral "
              ," where grlchv = ? "
   prepare pctb29m00005 from l_sql

   let l_sql = " select atldat,atlhor,atlemp,atlmat,grlchv[4,15], "
              ," max(case grlchv[1,3] when 'PSO' then grlinf else '' end), "
              ," max(case grlchv[1,3] when 'PSD' then grlinf else '' end) "
              ," from ",m_hostname clipped,"datkgeral "
              ," where grlchv[1,3] in ('PSO','PSD') "
              ," and grlchv[4,15] > ? "
              ," group by 1,2,3,4,5 "
              ," order by 5 "
   prepare pctb29m00006 from l_sql
   declare cctb29m00006 cursor for pctb29m00006

   let l_sql = " select atldat,atlhor,atlemp,atlmat,grlchv[4,15], "
              ," max(case grlchv[1,3] when 'PSO' then grlinf else '' end), "
              ," max(case grlchv[1,3] when 'PSD' then grlinf else '' end) "
              ," from ",m_hostname clipped,"datkgeral "
              ," where grlchv[1,3] in ('PSO','PSD') "
              ," and grlchv[4,15] < ? "
              ," group by 1,2,3,4,5 "
              ," order by 5 desc"
   prepare pctb29m00007 from l_sql
   declare cctb29m00007 cursor for pctb29m00007

   let l_sql = " select 1 from ",m_hostname clipped,"datkgeral "
              ," where grlchv = ? "
   prepare pctb29m00008 from l_sql
   declare cctb29m00008 cursor for pctb29m00008

   let m_prep_sql = true

end function

#-------------------------------------------------------------
function ctb29m00()
#-------------------------------------------------------------

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctb29m00_prepare()
   end if

   let m_selecionou = false

   open window w_ctb29m00 at 4,2 with form "ctb29m00"

   menu "OPCOES"
      command key ("S") "Seleciona" "Seleciona Registro"
         call ctb29m00_seleciona()
      command key ("P") "Proximo" "Proximo Registro"
         if not m_selecionou then
            error "Selecione um registro" sleep 2
            next option "Seleciona"
         else
            call ctb29m00_proximo()
         end if
      command key ("A") "Anterior" "Registro Aterior"
         if not m_selecionou then
            error "Selecione um registro" sleep 2
            next option "Seleciona"
         else
            call ctb29m00_anterior()
         end if
      command key ("M") "Modifica" "Modifica Registro"
         if not m_selecionou then
            error "Selecione um registro" sleep 2
            next option "Seleciona"
         else
            call ctb29m00_modifica()
         end if
      command key ("I") "Inclui" "Inclui Registro"
         call ctb29m00_inclui()
      command key ("R") "Remove" "Remove Registro"
         if not m_selecionou then
            error "Selecione um registro" sleep 2
         else
            call ctb29m00_remove()
         end if
         next option "Seleciona"
      command key ("E",f17) "Encerra" "Encerrar"
         exit menu
   end menu
   let int_flag = false
   close window w_ctb29m00

end function

#--------------------------------------------------
function ctb29m00_seleciona()
#--------------------------------------------------

   define l_opcao char(1)

   clear form

   call ctb29m00_entrada_dados("S")

   if int_flag then
      error " selecao cancelada " sleep 2
      let int_flag = false
      let m_selecionou = false
   end if

end function

#--------------------------------------------------
function ctb29m00_proximo()
#--------------------------------------------------

   open cctb29m00006 using mr_ctb29m00.chave
   whenever error continue
   fetch cctb29m00006 into mr_ctb29m00.atldat
                          ,mr_ctb29m00.atlhor
                          ,mr_ctb29m00.atlemp
                          ,mr_ctb29m00.atlmat
                          ,mr_ctb29m00.chave
                          ,mr_ctb29m00.valor
                          ,mr_ctb29m00.descricao
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error "Nao existem mais registros nesta direcao" sleep 2
      else
         error "Problemas ao selecionar o valor da chave"  sleep 2
         error "Erro SELECT cctb29m00006 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
         error "CTB29M00 / ctb29m00_proximo() ", mr_ctb29m00.chave sleep 2
      end if
   else
      display by name mr_ctb29m00.valor
      display by name mr_ctb29m00.descricao
      display by name mr_ctb29m00.atldat
      display by name mr_ctb29m00.atlhor
      display by name mr_ctb29m00.chave
      open cctb29m00002 using mr_ctb29m00.atlemp
                             ,mr_ctb29m00.atlmat
      whenever error continue
      fetch cctb29m00002 into mr_ctb29m00.funnom
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let mr_ctb29m00.funnom = "DESCONHECIDO"
         else
            error "Erro SELECT cctb29m00002 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
            error "CTB29M00 / ctb29m00_proximo() ",mr_ctb29m00.atlemp, " / "
                                                  ,mr_ctb29m00.atlmat sleep 2
            return
         end if
      end if
      display by name mr_ctb29m00.funnom
   end if

end function

#--------------------------------------------------
function ctb29m00_anterior()
#--------------------------------------------------

   open cctb29m00007 using mr_ctb29m00.chave
   whenever error continue
   fetch cctb29m00007 into mr_ctb29m00.atldat
                          ,mr_ctb29m00.atlhor
                          ,mr_ctb29m00.atlemp
                          ,mr_ctb29m00.atlmat
                          ,mr_ctb29m00.chave
                          ,mr_ctb29m00.valor
                          ,mr_ctb29m00.descricao
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error "Nao existem mais registros nesta direcao" sleep 2
      else
         error "Problemas ao selecionar o valor da chave"  sleep 2
         error "Erro SELECT cctb29m00007 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
         error "CTB29M00 / ctb29m00_anterior() ", mr_ctb29m00.chave sleep 2
      end if
   else
      display by name mr_ctb29m00.valor
      display by name mr_ctb29m00.descricao
      display by name mr_ctb29m00.atldat
      display by name mr_ctb29m00.atlhor
      display by name mr_ctb29m00.chave
      open cctb29m00002 using mr_ctb29m00.atlemp
                             ,mr_ctb29m00.atlmat
      whenever error continue
      fetch cctb29m00002 into mr_ctb29m00.funnom
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let mr_ctb29m00.funnom = "DESCONHECIDO"
         else
            error "Erro SELECT cctb29m00002 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
            error "CTB29M00 / ctb29m00_anterior() ",mr_ctb29m00.atlemp, " / "
                                                   ,mr_ctb29m00.atlmat sleep 2
            return
         end if
      end if
      display by name mr_ctb29m00.funnom
   end if

end function

#--------------------------------------------------
function ctb29m00_modifica()
#--------------------------------------------------

define l_chave      like datkgeral.grlchv

   call ctb29m00_entrada_dados("M")

   if int_flag then
      let int_flag = false
      error "Modificacao cancelada"  sleep 2
      return
   end if
   begin work
   let l_chave = "PSO", mr_ctb29m00.chave clipped
   if ctb29m00_grava(l_chave,mr_ctb29m00.valor) = 1 then
      rollback work
      return
   end if
   let l_chave = "PSD", mr_ctb29m00.chave clipped
   if ctb29m00_grava(l_chave,mr_ctb29m00.descricao) = 1 then
      rollback work
      return
   end if
   commit work

   error "Alteracao efetuada com sucesso" sleep 2

end function

#--------------------------------------------------
function ctb29m00_inclui()
#--------------------------------------------------
define l_chave      like datkgeral.grlchv

   initialize mr_ctb29m00.* to null
   clear form

   call ctb29m00_entrada_dados("I")

   if int_flag then
      let int_flag = false
      error "Inclusao cancelada"
      return
   end if

   begin work
   let l_chave = "PSO", mr_ctb29m00.chave clipped
   if ctb29m00_grava(l_chave,mr_ctb29m00.valor) = 1 then
      rollback work
      return
   end if
   let l_chave = "PSD", mr_ctb29m00.chave clipped
   if ctb29m00_grava(l_chave,mr_ctb29m00.descricao) = 1 then
      rollback work
      return
   end if
   commit work

   if ctb29m00_aux_seleciona() = 0 then
      error "Inclusao efetuada com sucesso " sleep 2
   end if

end function

#--------------------------------------------------
function ctb29m00_remove()
#--------------------------------------------------

   define l_resposta   char(1),
          l_chave      like datkgeral.grlchv

   let l_resposta = "E"

   while l_resposta <> 'S' and l_resposta <> 'N'
      prompt 'Confirma exclusao do Registro ?(S/N)' for l_resposta
      let l_resposta = upshift(l_resposta)
   end while

   let int_flag = false

   if l_resposta = 'N' then
      error "Remocao cancelada" sleep 2
      return
   end if

   begin work

   let l_chave = "PSO" , mr_ctb29m00.chave
   whenever error continue
   execute pctb29m00005 using l_chave
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error "Problemas ao excluir o valor da chave" sleep 2
      error "Erro DELETE pctb29m00005 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
      error "CTB29M00 / ctb29m00_remove() ",l_chave sleep 2
      let m_selecionou = false
      rollback work
      return
   end if

   let l_chave = "PSD" , mr_ctb29m00.chave
   whenever error continue
   execute pctb29m00005 using l_chave
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error "Problemas ao excluir o valor da chave" sleep 2
      error "Erro DELETE pctb29m00005 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
      error "CTB29M00 / ctb29m00_Remove() ",l_chave sleep 2
      let m_selecionou = false
      rollback work
      return
   end if

   commit work

   error "Remocao efetuada com sucesso" sleep 2

   initialize mr_ctb29m00.* to null
   clear form

   let m_selecionou = false

end function

#--------------------------------------------------
function ctb29m00_aux_seleciona()
#--------------------------------------------------

   let m_erro = false

   open cctb29m00001 using mr_ctb29m00.chave
   whenever error continue
   fetch cctb29m00001 into mr_ctb29m00.atldat
                          ,mr_ctb29m00.atlhor
                          ,mr_ctb29m00.atlemp
                          ,mr_ctb29m00.atlmat
                          ,mr_ctb29m00.chave
                          ,mr_ctb29m00.valor
                          ,mr_ctb29m00.descricao
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_selecionou = false
      if sqlca.sqlcode = notfound then
         return 1
      else
         error "Problemas ao selecionar o valor da chave"  sleep 2
         error "Erro SELECT cctb29m00001 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
         error "CTB29M00 / ctb29m00_aux_seleciona() ", mr_ctb29m00.chave sleep 2
         return 2
      end if
   else
      display by name mr_ctb29m00.valor
      display by name mr_ctb29m00.descricao
      display by name mr_ctb29m00.atldat
      display by name mr_ctb29m00.atlhor
      open cctb29m00002 using mr_ctb29m00.atlemp
                             ,mr_ctb29m00.atlmat
      whenever error continue
      fetch cctb29m00002 into mr_ctb29m00.funnom
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode <> notfound then
            error "Erro SELECT cctb29m00002 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
            error "CTB29M00 / ctb29m00_aux_seleciona() ",mr_ctb29m00.atlemp, " / "
                                                       ,mr_ctb29m00.atlmat sleep 2
            return 2
         end if
      end if
      if mr_ctb29m00.funnom is null then
         let mr_ctb29m00.funnom = "DESCONHECIDO"
      end if
      display by name mr_ctb29m00.funnom
      let m_selecionou = true
   end if

   return 0

end function

#--------------------------------------------------
function ctb29m00_entrada_dados(l_opcao)
#--------------------------------------------------

   define l_opcao   char(1)
   define ret_chave like datkgeral.grlchv

   if l_opcao = "S" then
      let m_selecionou = false
      initialize mr_ctb29m00 to null
      clear form
   end if

   input by name mr_ctb29m00.chave,mr_ctb29m00.descricao,mr_ctb29m00.valor without defaults

      before field chave
         if l_opcao = "M" then
            next field descricao
         else
            display by name mr_ctb29m00.chave attribute(reverse)
         end if

      after field chave
         display by name mr_ctb29m00.chave

         if mr_ctb29m00.chave is null or
            mr_ctb29m00.chave = " " then
            call ctb29m00a()
            returning mr_ctb29m00.chave ## ret_grlchv
            display by name mr_ctb29m00.chave

            ## error "Campo obrigatorio"
            ## next field chave
         end if

         if l_opcao = "S" then
            if ctb29m00_aux_seleciona() <> 0 then
               error "Chave nao encontrada"
               next field chave
            end if
            exit input
         else
            if ctb29m00_aux_seleciona() = 0 then
               let m_selecionou = false
               error "Chave ja existe. Utilize opcao Modifica" sleep 2
               clear form
               let mr_ctb29m00.chave = null
               let mr_ctb29m00.descricao = null
               let mr_ctb29m00.valor = null
               next field chave
            end if
         end if

      before field descricao
         display by name mr_ctb29m00.descricao attribute(reverse)

      after field descricao
         display by name mr_ctb29m00.descricao

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            if l_opcao = "M" then
               next field descricao
            else
               next field chave
            end if
         end if

         if mr_ctb29m00.descricao is null or
            mr_ctb29m00.descricao = " " then
            error "Campo obrigatorio"
            next field descricao
         end if

      before field valor
         display by name mr_ctb29m00.valor attribute(reverse)

      after field valor
         display by name mr_ctb29m00.valor

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field descricao
         end if

         if mr_ctb29m00.valor is null or
            mr_ctb29m00.valor = " " then
            error "Campo obrigatorio"
            next field valor
         end if

      on key(interrupt,f17,control-c)
         clear form
         let int_flag = true
         let m_selecionou = false
         exit input

   end input

end function

#--------------------------------#
function ctb29m00_grava(lr_param)
#--------------------------------#

 define lr_param    record
        grlchv      like datkgeral.grlchv,
        grlinf      like datkgeral.grlinf
 end record

 define lr_retorno  record
        status      smallint
 end record

 let lr_retorno.status = 0

 let lr_param.grlchv = upshift(lr_param.grlchv)

 open cctb29m00008 using lr_param.grlchv
 whenever error continue
 fetch cctb29m00008
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       whenever error continue
       execute pctb29m00004 using lr_param.grlchv
                                 ,lr_param.grlinf
                                 ,g_issk.empcod
                                 ,g_issk.funmat
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Problemas ao incuir o valor da chave" sleep 3
          error "Erro INSERT pctb29m00004 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
          error "CTB29M00 / ctb29m00_modifica() ",lr_param.grlchv, " / "
                                                 ,lr_param.grlinf, " / "
                                                 ,g_issk.empcod, " / "
                                                 ,g_issk.funmat sleep 2
          let lr_retorno.status = 1
       end if
    else
       error "Erro SELECT cctb29m00008 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
       error "CTB29M00 / ctb29m00_modifica() ",lr_param.grlchv sleep 2
       let lr_retorno.status = 1
    end if
 else
    whenever error continue
    execute pctb29m00003 using lr_param.grlinf
                              ,g_issk.empcod
                              ,g_issk.funmat
                              ,lr_param.grlchv
    whenever error stop
    if sqlca.sqlcode <> 0 then
       error "Problemas ao atualizar o valor da chave" sleep 3
       error "Erro UPDATE pctb29m00003 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
       error "CTB29M00 / ctb29m00_modifica() ",lr_param.grlinf, " / "
                                              ,g_issk.empcod," / "
                                              ,g_issk.funmat," / "
                                              ,lr_param.grlchv sleep 2
       let lr_retorno.status = 1
    end if
 end if

 return lr_retorno.status

end function

#-----------------------------------------------------------
 function ctb29m00a()
#-----------------------------------------------------------

 define a_ctb29m00a array[200] of record
    grlinf   like datkgeral.grlinf,
    grlchv   like datkgeral.grlchv
 end record

 define arr_aux    smallint

 define ws         record
    grlinf   like datkgeral.grlinf,
    grlchv   like datkgeral.grlchv
 end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctb29m00a[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let int_flag = false

 let arr_aux  = 1
 initialize a_ctb29m00a   to null

 declare c_ctb29m00a cursor for
    select grlchv[4,15], grlinf
      from datkgeral
      where grlchv[1,3] in ('PSO','PSD')
      order by 2

 foreach c_ctb29m00a into a_ctb29m00a[arr_aux].grlchv,
                         a_ctb29m00a[arr_aux].grlinf

    let arr_aux = arr_aux + 1

    if arr_aux > 200  then
       error " Limite excedido. Foram encontrados mais de 200 parametros !"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.grlchv = a_ctb29m00a[arr_aux - 1].grlchv
    else
       open window w_ctb29m0a at 12,25 with form "ctb29m00a"
                            attribute(form line 1, border)

       message " (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_ctb29m00a to s_ctb29m00a.*

          on key (interrupt,control-c)
             initialize a_ctb29m00a     to null
             initialize ws.grlchv to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.grlchv = a_ctb29m00a[arr_aux].grlchv
             exit display

       end display

       let int_flag = false
       close window w_ctb29m0a
    end if
 else
    initialize ws.grlchv to null
    error " Nao foi encontrado nenhum parametro!"
 end if

 return ws.grlchv

end function  ###  ctb29m00a