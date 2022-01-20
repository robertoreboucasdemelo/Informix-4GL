#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros Gerais                                          #
#.............................................................................#
# Sistema.......: Atendimento Diferenciado ao Corretor-Central de Atendimento #
# Modulo........: ctc84m00                                                    #
# Analista Resp.: Luiz Silva                                                  #
# PSI...........: psi224499                                                   #
# Objetivo......: Manutencao de Cadastro Complementar de Corretores           #
#.............................................................................#
# Desenvolvimento: Ismael, META                                               #
# Liberacao......: 07/08/2008                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
 globals '/homedsa/projetos/geral/globals/glcte.4gl'
 
 define m_prep    smallint
 define l_altera  char(1)
 define w_resp    char(1)
 define m_corsus  like dackcorsgm.corsus
 define m_chamada int 
  
 define am_ctc84m00 array[500] of record
     ghost   char(01)
    ,corsus  like dackcorsgm.corsus
    ,cornom  like gcakcorr.cornom
    ,vigdat  like dackcorsgm.vigdat
    ,celatd  like packcel.atdcelcod
    ,vigincdat like dackcorsgm.vigincdat
 end record
 
#-------------------------------#
 function ctc84m00_prepare()
#-------------------------------#
   define l_sql char(500)
      
   let l_sql = ' select cornom     '
              ,'   from gcakcorr   '
              ,'  where corsuspcp = ? '
   prepare pctc84m00002 from l_sql
   declare cctc84m00002 cursor for pctc84m00002
   
   let l_sql = ' update dackcorsgm '
               ,'   set vigdat = ? '
               ,'     , atlmat = ? '
               ,'     , atldat = today '
               ,'     , atlemp = ? '
               ,'     , atlusrtip = ? '
               ,'     , vigincdat = ? '
               ,' where corsus = ? '
   prepare pctc84m00003 from l_sql

   let l_sql = ' update dackcorsgm '
               ,'   set atdcelcod = ? '
               ,'     , atlmat = ? '
               ,'     , atldat = today '
               ,'     , atlemp = ? '
               ,'     , atlusrtip = ? '
               ,'     , vigincdat = ? '
               ,' where corsus = ? '
   prepare pctc84m00004 from l_sql
   
   let l_sql = 'select c.unocod,'
               ,'c.unonom,'
               ,'d.atdcelcod,' 
               ,'d.atdceldes '
               ,'from packvincor a , packtcn b , gabkuno c , packcel d '
               ,'where  a.corsus = ? '
               ,'and a.empcod = b.empcod '
               ,'and a.funmat = b.funmat '
               ,'and b.unocod = c.unocod '
               ,'and d.unocod = b.unocod '
               ,'and d.atdcelcod = b.atdcelcod '
               
   prepare pctc84m00005 from l_sql 
   declare cctc84m00005 cursor for pctc84m00005          
   
   let m_prep = true

end function

#-------------------------------#
 function ctc84m00()
#-------------------------------#

   initialize am_ctc84m00 to null
   
   if m_prep is null or
      m_prep <> true then
      call ctc84m00_prepare()
   end if
   
   options
       insert key control-j
      ,delete key control-y
   
   
   open window w_ctc84m00 at 05,02 with form 'ctc84m00'
      attribute (form line first)
   
   call ctc84m00_input()
   
   close window w_ctc84m00
   let int_flag = false
   
   options
       insert key F1
      ,delete key F2

end function

 
#-------------------------------#
 function ctc84m00_input()
#-------------------------------#
   define lr_reg record 
       susep    like dackcorsgm.corsus
      ,corretor like gcakcorr.cornom
      ,stt      char(01)
      ,vigfni   date
      ,vigfnf   date
      #,celatd   smallint
   end record
   define l_corretor like gcakcorr.cornom
         ,l_tipo     char(01)
         ,l_qtd      smallint
         ,l_stt      smallint
         
   let l_tipo     = null
   let l_corretor = null
   let l_qtd      = 0
   let l_stt      = null
   let l_altera   = "N"
   initialize lr_reg to null
   clear form

   
   if m_chamada = 99 then
   	let lr_reg.susep = m_corsus
   end if 
   
   input by name lr_reg.* without defaults
   	
      before field susep   
			if m_chamada = 99 then
				if fgl_lastkey() = fgl_keyval('f8') then
                       let int_flag = false
                       exit input
				end if
			end if
         display by name lr_reg.susep attribute (reverse)
      
      after field susep   
         display by name lr_reg.susep

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field susep
         end if

         if lr_reg.susep is null or 
            lr_reg.susep = ' '   then
            next field corretor
         end if

         let lr_reg.corretor = null
         let lr_reg.stt      = null
         let lr_reg.vigfni   = null
         let lr_reg.vigfnf   = null
         clear corretor, stt, vigfni, vigfnf
         
         call ctc84m00_carrega('X'
                               ,lr_reg.susep
                               ,''
                               ,'' 
                               ,'')
            returning l_qtd
                     ,l_stt

         if l_stt = 0 then
            call ctc84m00_input_array(l_qtd)
         else
            if l_stt = 1 then
               error 'Nenhum registro encontrado'
            end if
         end if

         clear form
         initialize lr_reg, am_ctc84m00 to null
         next field susep

      before field corretor 
         display by name lr_reg.corretor attribute (reverse)
         
      after field corretor
         display by name lr_reg.corretor

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field susep
         end if

      before field stt
         display by name lr_reg.stt attribute (reverse)

      after field stt
         display by name lr_reg.stt
         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field corretor
         end if

         if lr_reg.stt is null or 
            lr_reg.stt = ' '   then
            let lr_reg.vigfni = null
            next field vigfni
         end if

         if lr_reg.stt = 'A' then 
            let lr_reg.vigfni = null
            clear vigfni

            let lr_reg.vigfnf = today - 1 units day
            display by name lr_reg.vigfnf
            next field vigfni 
         else
            if lr_reg.stt = 'N' then 
               let lr_reg.vigfnf = null
               clear vigfnf

               let lr_reg.vigfni = today
               display by name lr_reg.vigfni
               next field vigfnf
            else
               error 'Informe "N" ou "A"'
               next field stt
            end if
         end if
      
      before field vigfni
         display by name lr_reg.vigfni attribute (reverse)

      after field vigfni
         display by name lr_reg.vigfni

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field stt
         end if

         if lr_reg.vigfni is null then
            if (lr_reg.stt      is null     or lr_reg.stt = ' ')        and
               (lr_reg.corretor is not null or lr_reg.corretor <> ' ' ) then
               next field vigfnf
            else
               error 'Informe primeira Vigencia para consulta'
               next field vigfni
            end if
         else
           if lr_reg.vigfnf < lr_reg.vigfni then
               error 'Primeira vigencia nao deve ser maior do que a ultima'
               next field vigfni
            end if
         end if
         
         if lr_reg.stt is null or
            lr_reg.stt = ' '   then
            next field vigfnf
         end if
         
         let l_corretor = null

         if lr_reg.corretor is null or
            lr_reg.corretor = ' '   then
            let l_tipo = 'V' 
         else   
            let l_corretor = ctc84m00_parse(lr_reg.corretor)
            let l_tipo = 'S'
         end if

         call ctc84m00_carrega(l_tipo
                              ,lr_reg.susep
                              ,l_corretor
                              ,lr_reg.vigfni
                              ,lr_reg.vigfnf)
            returning l_qtd
                     ,l_stt


         if l_stt = 0 then
            call ctc84m00_input_array(l_qtd)
         else
            if l_stt = 1 then 
               error 'Nenhum registro encontrado'
            end if
         end if

         clear form
         initialize lr_reg, am_ctc84m00 to null
         next field susep
      
      before field vigfnf
         display by name lr_reg.vigfnf attribute (reverse)

      after field vigfnf
        display by name lr_reg.vigfnf

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            if lr_reg.stt = 'N' then 
               next field stt
            else
               next field vigfni
            end if
         end if
         
         let l_corretor = null
         
         if lr_reg.vigfnf is null then
            if lr_reg.vigfni is null then
               let l_tipo = 'C'
               let l_corretor = ctc84m00_parse(lr_reg.corretor)
            else
               error 'Informe Ultima Vigencia para consulta'
               next field vigfnf
            end if 
         else
            if lr_reg.vigfnf < lr_reg.vigfni then
               error 'Ultima vigencia nao deve ser menor do que a primeira'
               next field vigfnf
            end if

            if lr_reg.corretor is null or
               lr_reg.corretor = ' '   then 
               let l_tipo = 'V' 
               let l_corretor = null
            else
               let l_tipo = 'S' 
               let l_corretor = ctc84m00_parse(lr_reg.corretor)
            end if
         end if
         
         call ctc84m00_carrega(l_tipo
                              ,lr_reg.susep
                              ,l_corretor
                              ,lr_reg.vigfni
                              ,lr_reg.vigfnf)
            returning l_qtd
                     ,l_stt
         
         if l_stt = 0 then
            call ctc84m00_input_array(l_qtd)
         else
            if l_stt = 1 then 
               error 'Nenhum registro encontrado'
            end if
         end if
         
         clear form
         initialize lr_reg, am_ctc84m00 to null
         next field susep
      
      on key (control-c, f17, interrupt)
         let int_flag = false
         exit input
      
   end input
end function

#------------------------------------#
 function ctc84m00_input_array(l_qtd)
#------------------------------------#
   define l_qtd        smallint
         ,l_arr        smallint
         ,l_tela       smallint
         ,l_alterou    smallint
         ,l_i          smallint
         ,l_altflg     smallint
   define al_vigold array[500] of date
   define al_celold array[500] of smallint
   define al_vigincold array[500] of date
   
   let l_altflg   = false
   let l_arr        = null
   let l_tela       = null
   let l_i          = null
   let l_alterou    = null
   initialize al_vigold to null
   initialize al_celold to null
   initialize al_vigincold to null
   
   for l_i = 1 to l_qtd
      let al_vigold[l_i] = am_ctc84m00[l_i].vigdat
      let al_celold[l_i] = am_ctc84m00[l_i].celatd
      let al_vigincold[l_i] = am_ctc84m00[l_i].vigincdat
   end for
   
   call set_count(l_qtd)
      
   input array am_ctc84m00 without defaults from s_ctc84m00.*

      
      before row
                   
         let l_arr  = arr_curr()
         let l_tela = scr_line()
         
         next field ghost
         
     before field ghost
     
        call ctc84m00_carrega_unicel(am_ctc84m00[l_arr].corsus)
      
      after field ghost
                     
         if fgl_lastkey() = 2014 then
            next field ghost
         else
            if fgl_lastkey() = fgl_keyval('down')     or
               fgl_lastkey() = fgl_keyval('nextpage') then
               if l_arr < 500 then
                  if am_ctc84m00[l_arr+1].corsus is null then
                     next field ghost
                  else
                     continue input
                  end if
               else
                  next field ghost
               end if
            end if

            if fgl_lastkey() = fgl_keyval('up')       or
               fgl_lastkey() = fgl_keyval('prevpage') then
               continue input
            else
               next field ghost
            end if
         end if

      before field vigdat
         display am_ctc84m00[l_arr].vigdat to s_ctc84m00[l_tela].vigdat attribute (reverse)
      after field vigdat
         display am_ctc84m00[l_arr].vigdat to s_ctc84m00[l_tela].vigdat
         
         if am_ctc84m00[l_arr].vigdat is null then
            error 'Informe uma data valida'
            next field vigdat
         end if

         if l_arr = arr_count() then
            next field ghost
         end if

      before field celatd
         display am_ctc84m00[l_arr].celatd to s_ctc84m00[l_tela].celatd attribute (reverse)
      after field celatd
         display am_ctc84m00[l_arr].celatd to s_ctc84m00[l_tela].celatd
         
         if am_ctc84m00[l_arr].celatd is null or am_ctc84m00[l_arr].celatd = 0 then
            error 'Informe uma celula valida'
            next field celatd
         end if

         if l_arr = arr_count() then
            next field ghost
         end if

      on key(f5)
         let l_altera = "S"
         if infield(ghost) then
            next field vigincdat
         end if
      
      on key(f6)
         let l_altera = "S"
         if infield(ghost) then
            next field vigdat
         end if
         
      on key(f7)
         let l_altera = "S"
         if infield(ghost) then
            next field celatd
         end if

      on key (f8)
      
         if infield(vigdat) then
         	let am_ctc84m00[l_arr].vigdat = get_fldbuf(vigdat)
         end if
         if infield(celatd) then
         	let am_ctc84m00[l_arr].celatd = get_fldbuf(celatd)
         end if

         if infield(vigincdat) then
         	let am_ctc84m00[l_arr].vigincdat = get_fldbuf(vigincdat)
         end if
         
         let l_altflg = 0
         
         begin work
         
         for l_i = 1 to l_qtd
            if (am_ctc84m00[l_i].celatd <> al_celold[l_i]) or 
               (am_ctc84m00[l_i].celatd is not null and al_celold[l_i] is null)then
               if ctc84m00_atualiza(l_i,1) then
                  let l_altflg = 1
                  let al_celold[l_i] = am_ctc84m00[l_i].celatd 
               else
                  let l_altflg = 2
                  exit for
               end if
            end if
         end for

         for l_i = 1 to l_qtd
            if am_ctc84m00[l_i].vigdat <> al_vigold[l_i] then
               if ctc84m00_atualiza(l_i,0) then
                  let l_altflg = 1
                  let al_vigold[l_i] = am_ctc84m00[l_i].vigdat 
               else
                  let l_altflg = 2
                  exit for
               end if
            end if
         end for

         for l_i = 1 to l_qtd
            if am_ctc84m00[l_i].vigincdat <> al_vigincold[l_i] then
               if ctc84m00_atualiza(l_i,2) then
                  let l_altflg = 1
                  let al_vigincold[l_i] = am_ctc84m00[l_i].vigincdat 
               else
                  let l_altflg = 2
                  exit for
               end if
            end if
         end for
         
         if l_altflg = 2 then
            rollback work
            exit input
         else
            commit work
         
            if l_altflg = 1 then
               error 'Alteracoes salvas com sucesso'
            else
               error 'Nao ha alteracoes a serem salvas'
            end if
         end if
         
			if m_chamada = 99 then
                  let int_flag = false
                  exit input
			end if
			
      on key (control-c, f17, interrupt)
         
         if l_altera = "S" then
            prompt "Confirma alteração S/N?" attribute (reverse) for char w_resp
            if w_resp = "s" or w_resp = "S" then
               let l_altera = "N"
               if infield(vigdat) then
               	let am_ctc84m00[l_arr].vigdat = get_fldbuf(vigdat)
               end if
               if infield(celatd) then
               	let am_ctc84m00[l_arr].celatd = get_fldbuf(celatd)
               end if
               if infield(vigincdat) then
               	let am_ctc84m00[l_arr].vigincdat = get_fldbuf(vigincdat)
               end if
               
               let l_altflg = 0
               
               begin work
               
               for l_i = 1 to l_qtd
	                if (am_ctc84m00[l_i].celatd <> al_celold[l_i]) or 
	                   (am_ctc84m00[l_i].celatd is not null and al_celold[l_i] is null)then
                      if ctc84m00_atualiza(l_i,1) then
                         let l_altflg = 1
                         let al_celold[l_i] = am_ctc84m00[l_i].celatd 
                      else
                         let l_altflg = 2
                         exit for
                      end if
                   end if
               end for

               for l_i = 1 to l_qtd
                  if am_ctc84m00[l_i].vigdat <> al_vigold[l_i] then
                     if ctc84m00_atualiza(l_i,0) then
                        let l_altflg = 1
                        let al_vigold[l_i] = am_ctc84m00[l_i].vigdat 
                     else
                        let l_altflg = 2
                        exit for
                     end if
                  end if
               end for

               for l_i = 1 to l_qtd
                  if am_ctc84m00[l_i].vigincdat <> al_vigincold[l_i] then
                     if ctc84m00_atualiza(l_i,2) then
                        let l_altflg = 1
                        let al_vigincold[l_i] = am_ctc84m00[l_i].vigincdat 
                     else
                        let l_altflg = 2
                        exit for
                     end if
                  end if
               end for
               
               if l_altflg = 2 then
                  rollback work
                  exit input
               else
                  commit work
               
                  if l_altflg = 1 then
                     error 'Alteracoes salvas com sucesso'
                  else
                     error 'Nao ha alteracoes a serem salvas'
                  end if
               end if
                          
            else
                let l_altera = "N"
                let int_flag = false
                exit input
            end if 
         end if
         let int_flag = false
         exit input

   end input

end function
   
#----------------------------------------#
 function ctc84m00_carrega(l_tipo,lr_par)
#----------------------------------------#
   define l_tipo char(01)
   
   define lr_par record 
       susep     like dackcorsgm.corsus
      ,corretor  like gcakcorr.cornom
      ,vigfni    date
      ,vigfnf    date
   end record
   
   define l_i    smallint
         ,l_erro smallint 
         ,l_tmp1 like gcakcorr.cornom 
         ,l_tmp2 like dackcorsgm.corsus
         ,l_tmp3 date
   
   define l_sql  char(500)
   
   let l_tmp1 = null
   let l_tmp2 = null
   let l_tmp3 = null
   let l_i    = 1
   let l_erro = 0
   
   case l_tipo
      
      when 'X'
         let l_sql = ' select corsus '
                     ,'     , vigdat '
                     ,'     , atdcelcod '
                     ,'     , vigincdat '
                     ,'  from dackcorsgm '
                     ,' where corsus = "', lr_par.susep clipped, '"'
                  ,' order by corsus '
      
      when 'V'
         let l_sql = ' select corsus  '
                     ,'     , vigdat       '
                     ,'     , atdcelcod '
                     ,'     , vigincdat '
                     ,'  from dackcorsgm   '
                     ,' where vigdat  >= "',lr_par.vigfni,'"' 
                     ,'   and vigdat  <= "',lr_par.vigfnf,'"' 
                     ,' order by corsus '
      
      when 'C'
         let l_sql = ' select b.corsus '
                     ,'     , b.vigdat '
                     ,'     , b.atdcelcod '
                     ,'     , vigincdat '
                     ,'  from gcakcorr a  '
                     ,'     , dackcorsgm b '
                     ,' where a.cornom matches "', lr_par.corretor  clipped, '"'
                     ,'   and b.corsus = a.corsuspcp '
                  ,' order by b.corsus '
      
      when 'S' 
         let l_sql = ' select b.corsus '
                     ,'     , b.vigdat '
                     ,'     , b.atdcelcod '
                     ,'     , vigincdat '
                     ,'  from gcakcorr a  '
                     ,'     , dackcorsgm b '
                     ,' where a.cornom matches "', lr_par.corretor  clipped, '"'
                     ,'   and b.corsus = a.corsuspcp '
                     ,'   and vigdat  >= "',lr_par.vigfni,'"'
                     ,'   and vigdat  <= "',lr_par.vigfnf,'"'
                  ,' order by corsus '
   end case
    
   prepare pctc84m00001 from l_sql
   declare cctc84m00001 cursor for pctc84m00001
   
   open cctc84m00001 
   foreach cctc84m00001 into am_ctc84m00[l_i].corsus
                           , am_ctc84m00[l_i].vigdat
                           , am_ctc84m00[l_i].celatd
                           , am_ctc84m00[l_i].vigincdat
      open cctc84m00002 using am_ctc84m00[l_i].corsus
      whenever error continue
      fetch cctc84m00002 into am_ctc84m00[l_i].cornom
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let am_ctc84m00[l_i].cornom = null
         else
            error 'Erro SELECT cctc84m00002 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
            error 'ctc84m00 / ctc84m00_carrega() / ',am_ctc84m00[l_i].corsus sleep 2
            let l_erro = 2
            exit foreach
         end if
      end if 
      
      let l_i = l_i + 1
      if l_i > 500 then
         error 'Limite de 500 registros atingido'
         exit foreach
      end if
   end foreach

   let l_i = l_i - 1

   if l_erro = 0  then 
      if l_i = 0 then
         let l_erro = 1
      end if
   end if
   
   return l_i
         ,l_erro

end function
   
#-----------------------------------#
 function ctc84m00_parse(l_corretor)
#-----------------------------------#
   define l_corretor       like gcakcorr.cornom
   define l_cornom_pesq    char(50)
         ,l_ind_in         smallint
         ,l_ind_ou         smallint
         ,l_achou_palavra  smallint
   
   let l_cornom_pesq   = null
   let l_ind_in        = null
   let l_ind_ou        = 0
   let l_achou_palavra = false
   
   for l_ind_in = 1 to (length(l_corretor))
      if l_corretor[l_ind_in,l_ind_in] <> " " and
         l_corretor[l_ind_in,l_ind_in] is not null then
         let l_achou_palavra = true
      else
         if l_achou_palavra then
            let l_ind_ou = l_ind_ou + 1
            let l_cornom_pesq[l_ind_ou,l_ind_ou] = "*"
            let l_ind_ou = l_ind_ou + 1
            let l_cornom_pesq[l_ind_ou,l_ind_ou] = " "
            let l_achou_palavra = false
         end if
      end if
      if l_achou_palavra then
         let l_ind_ou = l_ind_ou + 1
         let l_cornom_pesq[l_ind_ou,l_ind_ou] = l_corretor[l_ind_in,l_ind_in]
      end if
      if l_ind_in = (length(l_corretor)) then
         let l_ind_ou = l_ind_ou + 1
         let l_cornom_pesq[l_ind_ou,l_ind_ou] = "*"
         let l_cornom_pesq[l_ind_ou+1,50] = ""
      end if
      
   end for
   
   return l_cornom_pesq
   
end function
   
#-------------------------------------#
 function ctc84m00_atualiza(l_i,l_flag)
#-------------------------------------#
   
   define l_i  smallint
         ,l_ok smallint
         ,l_flag smallint
   
	if l_flag = 0 then
	   let l_ok = true
	   
	   whenever error continue
	   execute pctc84m00003 using am_ctc84m00[l_i].vigdat
	                             ,g_issk.funmat
	                             ,g_issk.empcod
	                             ,g_issk.usrtip
	                             ,am_ctc84m00[l_i].vigincdat
	                             ,am_ctc84m00[l_i].corsus
	   whenever error stop
	   if sqlca.sqlcode <> 0 then
	      error 'Erro UPDATE pctc84m00003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	      error 'ctc84m00 / ctc84m00_atualiza(,0) / ',am_ctc84m00[l_i].vigdat
	                                         ,' / ',g_issk.funmat
	                                         ,' / ',g_issk.empcod
	                                         ,' / ',am_ctc84m00[l_i].vigincdat
	                                         ,' / ',am_ctc84m00[l_i].corsus sleep 2
	      let l_ok = false
	   end if
	   
	   return l_ok
	else    
	   let l_ok = true
	   
	   whenever error continue
	   execute pctc84m00004 using am_ctc84m00[l_i].celatd
	                             ,g_issk.funmat
	                             ,g_issk.empcod
	                             ,g_issk.usrtip
	                             ,am_ctc84m00[l_i].vigincdat
	                             ,am_ctc84m00[l_i].corsus
	   whenever error stop
	   if sqlca.sqlcode <> 0 then
	      error 'Erro UPDATE pctc84m00004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
	      error 'ctc84m00 / ctc84m00_atualiza(,1) / ',am_ctc84m00[l_i].celatd
	                                         ,' / ',g_issk.funmat
	                                         ,' / ',g_issk.empcod
	                                         ,' / ',g_issk.usrtip
                                              ,' / ',am_ctc84m00[l_i].vigincdat
	                                         ,' / ',am_ctc84m00[l_i].corsus sleep 2
	      let l_ok = false
	   end if

	   return l_ok
	end if   
end function


#-------------------------------------------------#
 function ctc84m00_chama_externo(l_chamada,l_susep)
#-------------------------------------------------#
	define l_susep like dackcorsgm.corsus
	define l_chamada int 

	let m_corsus = l_susep
	let m_chamada = l_chamada 
	
	call ctc84m00()

end function	
	
#-------------------------------------------------#
 function ctc84m00_carrega_unicel(l_susep)
#-------------------------------------------------#
	define l_susep like dackcorsgm.corsus
     
      define unocod   like gabkuno.unocod
      define unonome  like gabkuno.unonom
      define celcod   like packcel.atdcelcod
      define celnome  like packcel.atdceldes
          
      open cctc84m00005 using l_susep
      whenever error continue
      fetch cctc84m00005 into unocod,unonome,celcod,celnome      
          
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let unocod = null
            let unonome = null
            let celcod = null
            let celnome = null
         else
            error 'Erro SELECT cctc84m00005 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
            error 'ctc84m00 / ctc84m00_carrega() / ',l_susep sleep 2
         end if
      end if 
      
     display by name unocod
     display by name unonome
     display by name celcod
     display by name celnome  
           
end function		
