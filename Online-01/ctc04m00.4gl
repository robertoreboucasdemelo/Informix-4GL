#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : CTG                                                 #
# Modulo        : ctc04m00                                            #
# Analista Resp.: Ligia Mattge                                        #
# PSI/OSF       : 170771 / 34703                                      #
#                 Cadastro de tipos de fax imagem                     #
#.....................................................................#
# Desenvolvimento: Paulo, Meta                                        #
# Liberacao      : 23/04/2004                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#                                                                     #
#---------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl" 

 define am_rec array[200] of record
        c24imgfaxtip      like datkimgfaxtip.c24imgfaxtip
       ,c24imgfaxtipdes   like datkimgfaxtip.c24imgfaxtipdes
       ,atldat            like datkimgfaxtip.atldat
       ,funcionario       char(31)
 end record
 
 define m_prep_sql   smallint

#------------------------------------------------------------
function ctc04m00_prepara()
#------------------------------------------------------------
 define l_sql     char (700)

 let l_sql = 'select c24imgfaxtip, c24imgfaxtipdes, atldat, atlemp, atlmat '
            ,'  from datkimgfaxtip '

 prepare pctc04m00001 from l_sql
 declare cctc04m00001 cursor for pctc04m00001
 
 let l_sql = 'select funnom '
            ,' from isskfunc '
            ,' where empcod = ? '
              ,' and funmat = ? '
              ,' and usrtip = "F" '

 prepare pctc04m00002 from l_sql
 declare cctc04m00002 cursor for pctc04m00002
 
 let l_sql = 'insert into datkimgfaxtip (c24imgfaxtip, c24imgfaxtipdes, atldat, '
                                      ,' atlemp, atlmat, atlusrtip) '
                              ,' values (?,?,?,?,?,"F") '

 prepare pctc04m00003 from l_sql

 let l_sql = 'select 1 '
            ,'  from datkimgfaxtip '
            ,' where c24imgfaxtip = ? '

 prepare pctc04m00004 from l_sql
 declare cctc04m00004 cursor for pctc04m00004

 let l_sql = 'update datkimgfaxtip set (c24imgfaxtipdes, atldat, atlemp, atlmat) '
                                  ,' = (?, ?, ?, ?) '
            ,' where c24imgfaxtip = ? '

 prepare pctc04m00005 from l_sql

 let l_sql = 'delete from datkimgfaxtip '
            ,' where c24imgfaxtip = ? '

 prepare pctc04m00006 from l_sql

 let m_prep_sql = true

end function
   
#-------------------
function ctc04m00()
#-------------------

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc04m00_prepara()
 end if

 open window w_ctc04m00 at 6,2 with form "ctc04m00"
    attribute (form line 1)

 let int_flag = false

 call ctc04m00_input()

 let int_flag = false
 close window w_ctc04m00

end function

#-----------------------------
function ctc04m00_seleciona()
#-----------------------------
 define l_array    smallint
 define l_atlemp   like datkimgfaxtip.atlemp
       ,l_atlmat   like datkimgfaxtip.atlmat
       ,l_funnom   like isskfunc.funnom
      
 initialize am_rec   to null

 let l_array = 1

 open cctc04m00001

 foreach cctc04m00001 into am_rec[l_array].c24imgfaxtip
                          ,am_rec[l_array].c24imgfaxtipdes
                          ,am_rec[l_array].atldat
                          ,l_atlemp
                          ,l_atlmat
    
    open cctc04m00002 using l_atlemp
                           ,l_atlmat
    whenever error continue
    fetch cctc04m00002 into l_funnom
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_funnom = null
       else
          error 'Erro SELECT cctc04m00002 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTC04M00 / ctc04m00_seleciona() / ',l_atlemp,' / '
                                                    ,l_atlmat sleep 2
          let int_flag = true
          exit foreach
       end if
    end if

    let am_rec[l_array].funcionario = l_atlmat using '&&&&&&', ' - ',l_funnom clipped

    let l_array = l_array + 1
    if l_array > 200 then
       error 'Limite de 200 registros foi ultrapassado'  sleep 2
       exit foreach
    end if

 end foreach

 let l_array = l_array - 1

 return l_array

end function

#------------------------------------------------------------
function ctc04m00_input()
#------------------------------------------------------------
 define l_array       smallint
       ,l_tela        smallint
       ,l_x           smallint
       ,l_descricao   like datkimgfaxtip.c24imgfaxtipdes
       ,l_flag        char(01)
       ,l_atu         smallint
       ,l_funnom      like isskfunc.funnom
       ,l_char        char(01)
       ,l_cont        smallint

let l_cont = true

while l_cont

   let l_array = ctc04m00_seleciona()
   if int_flag then   
      return
   end if

   call set_count(l_array)
   
   for l_x = 1 to 13
       display am_rec[l_x].* to s_ctc04m00[l_x].*
   end for
  
   input array am_rec without defaults from s_ctc04m00.*
  
      before row
         let l_array = arr_curr()
         let l_tela  = scr_line()
  
      before delete
         while true
            prompt "Confirma a exclusao ? (S/N) " for l_char
            let l_char = upshift(l_char)
            if l_char = "S" or l_char = "N" then
               exit while
            end if
            error "Digite somente S ou N !!!" 
         end while
         
         if l_char = "N" then
            let int_flag = false
            exit input
         end if
         
         let l_flag = 'E'
         if not ctc04m00_atualiza(l_flag, l_array) then
            let l_cont = false
            exit input
         end if
             
      on key (interrupt, control-c, f17)
         let l_cont = false
         exit input
  
      before field c24imgfaxtip
         if am_rec[l_array].funcionario is not null and
            am_rec[l_array].funcionario <> ' '      then
            next field c24imgfaxtipdes
         end if
         display am_rec[l_array].c24imgfaxtip to s_ctc04m00[l_tela].c24imgfaxtip  attribute (reverse)
  
      after field c24imgfaxtip
         if fgl_lastkey() <> fgl_keyval('up')   and
            fgl_lastkey() <> fgl_keyval('left') then
            if am_rec[l_array].c24imgfaxtip is null then
               error 'Tipo nao pode ser nulo'
               next field c24imgfaxtip
            end if
  
            for l_x = 1 to 200
               if l_x <> l_array and
                  am_rec[l_x].c24imgfaxtip = am_rec[l_array].c24imgfaxtip then
                  error 'Tipo informado ja existe na linha ', l_x  using '<<&'
                  let l_x = -1000
                  exit for
               end if
            end for
  
            if l_x = -1000 then
               next field c24imgfaxtip
            end if
  
            open cctc04m00004 using am_rec[l_array].c24imgfaxtip
  
            whenever error continue
            fetch cctc04m00004
            whenever error stop
            if sqlca.sqlcode = 0 then
               error 'Tipo informado ja existe na tabela'
               next field c24imgfaxtip
            else
               if sqlca.sqlcode <> notfound then
                  error 'Erro SELECT cctc04m00004 / ',sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]    sleep 2
                  error 'CTC04M00 / ctc04m00_input() / ',  am_rec[l_array].c24imgfaxtip sleep 2
                  let l_cont = false
                  exit input
               end if
            end if
  
            let l_atu = true
         else
            display am_rec[l_array].c24imgfaxtip      to s_ctc04m00[l_tela].c24imgfaxtip
         end if
  
      before field c24imgfaxtipdes
  
         if am_rec[l_array].c24imgfaxtip is null then
            next field c24imgfaxtip
         end if
  
         let l_descricao = am_rec[l_array].c24imgfaxtipdes
         display am_rec[l_array].c24imgfaxtipdes to s_ctc04m00[l_tela].c24imgfaxtipdes  attribute (reverse)
  
      after field c24imgfaxtipdes
         if fgl_lastkey() <> fgl_keyval('up')   and
            fgl_lastkey() <> fgl_keyval('left') then
            if am_rec[l_array].c24imgfaxtipdes is null or
               am_rec[l_array].c24imgfaxtipdes = ' '   then
               error 'Descricao nao pode ser nula'
               next field c24imgfaxtipdes
            end if
  
            if l_descricao <> am_rec[l_array].c24imgfaxtipdes or
               l_atu = true                                   then
               let l_atu = true
               let am_rec[l_array].atldat = today
               if am_rec[l_array].funcionario is null or
                  am_rec[l_array].funcionario = ' '   then
                  let l_flag = 'I'
               else
                  let l_flag = 'A'
               end if
               open cctc04m00002 using g_issk.empcod
                                      ,g_issk.funmat
               whenever error continue
               fetch cctc04m00002 into l_funnom
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode = notfound then
                     let l_funnom = null
                  else
                     error 'Erro SELECT cctc04m00002 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
                     error 'CTC04M00 / ctc04m00_input() / ',g_issk.empcod,' / '
                                                           ,g_issk.funmat sleep 2
                     let int_flag = true
                     exit input
                  end if
               end if
               let am_rec[l_array].funcionario = g_issk.funmat using '&&&&&&',' - ',l_funnom
            end if
         else
            let l_atu = false
            let am_rec[l_array].c24imgfaxtipdes = l_descricao
         end if
  
         display am_rec[l_array].*      to s_ctc04m00[l_tela].*
  
         if l_atu = true then
            if not ctc04m00_atualiza(l_flag, l_array) then
               let l_cont = false
               exit input
            end if
            let l_atu = false
         end if
  
   end input
   
   if int_flag = true then
      let l_cont = false
   end if
   
   let int_flag = false
  
end while

end function

#---------------------------------------------------------
function ctc04m00_atualiza(l_flag, l_array)
#---------------------------------------------------------
 define l_array     smallint
       ,l_flag      char(01)

 case l_flag
    when 'I'
       whenever error continue
       execute pctc04m00003 using am_rec[l_array].c24imgfaxtip
                                 ,am_rec[l_array].c24imgfaxtipdes
                                 ,am_rec[l_array].atldat
                                 ,g_issk.empcod
                                 ,g_issk.funmat
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error 'Erro INSERT pctc04m00003 / ',sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTC04M00 / ctc04m00_atualiza() / ',  am_rec[l_array].c24imgfaxtip   sleep 2
          return false
       end if
    when 'A'
       whenever error continue
       execute pctc04m00005 using am_rec[l_array].c24imgfaxtipdes
                                 ,am_rec[l_array].atldat
                                 ,g_issk.empcod
                                 ,g_issk.funmat
                                 ,am_rec[l_array].c24imgfaxtip
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error 'Erro UPDATE pctc04m00005 / ',sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTC04M00 / ctc04m00_atualiza() / ',  am_rec[l_array].c24imgfaxtip   sleep 2
          return false
       end if
    otherwise
       whenever error continue
       execute pctc04m00006 using am_rec[l_array].c24imgfaxtip
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error 'Erro DELETE pctc04m00006 / ',sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTC04M00 / ctc04m00_atualiza() / ',  am_rec[l_array].c24imgfaxtip   sleep 2
          return false
       end if
 end case

 return true

end function
