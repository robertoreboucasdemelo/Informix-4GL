#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24 horas                                    #
# Modulo        : cts00m36                                            #
# Analista Resp.: Ligia Mattge                                        #
# PSI/OSF       : 186414 / 37940                                      #
#                 Recebimento dos parametros para pesquisa de         #
#                 servicos                                            #
#.....................................................................#
# Desenvolvimento: Meta, Paulo                                        #
# Liberacao      : 21/07/2004                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 04/08/2004  Marcio Meta    PSI186414 Excluir os campos              #
#                                                                     #
#---------------------------------------------------------------------#
database porto

 define mr_cts00m36    record
        data_inicial   date,
        data_final     date,
        atdprscod      like datmservico.atdprscod,
        atdsrvorg      like datmservico.atdsrvorg,
        nome           like datmservico.nom,
        vcllicnum      like datmservico.vcllicnum,
        in_empresas    char(30)
 end record

#------------------------------
function cts00m36_parametros()
#------------------------------
 define l_srvtipabvdes  char(40)
       ,l_nomgrr        char(40)
 define l_tam           smallint
       ,l_flag          smallint
       ,l_par1          char(01)
       ,l_resultado     smallint
       ,l_mensagem      char(80)

define lr_emp record 
       empauxpor     char(1),
       empauxazu     char(1), 
       empauxita     char(1), 
       empauxvid     char(1), 
       empauxpro     char(1), 
       empauxsau     char(1),
       empauxcar     char(1),
       empauxpss     char(1) 
end record

 let lr_emp.empauxpor = 'X'
 let lr_emp.empauxazu = 'X'
 let lr_emp.empauxita = 'X'
 let lr_emp.empauxvid = 'X'
 let lr_emp.empauxpro = 'X'
 let lr_emp.empauxsau = 'X'
 let lr_emp.empauxcar = 'X'
 let lr_emp.empauxpss = ' '

 open window w_cts00m36 at 08,02 with form 'cts00m36'
    attribute (form line 1)
 
 while true
 
    initialize mr_cts00m36   to null
    input by name mr_cts00m36.data_inicial,
                  mr_cts00m36.data_final,
                  mr_cts00m36.atdprscod,
                  mr_cts00m36.atdsrvorg,
                  mr_cts00m36.nome,
                  mr_cts00m36.vcllicnum,
                  lr_emp.empauxpor,
                  lr_emp.empauxazu,
                  lr_emp.empauxita,
                  lr_emp.empauxvid,
                  lr_emp.empauxpro,
                  lr_emp.empauxsau,
                  lr_emp.empauxcar,
                  lr_emp.empauxpss
                  without defaults
    
       on key(control-c,interrupt,f17)
          initialize mr_cts00m36  to null
          let int_flag = true
          exit input
       before field data_inicial
          let mr_cts00m36.data_inicial = today

          display by name mr_cts00m36.data_inicial attribute (reverse)
       after field data_inicial

          display by name mr_cts00m36.data_inicial

          if mr_cts00m36.data_inicial is null then
             let mr_cts00m36.data_final   = null
             display by name mr_cts00m36.data_inicial
             display by name mr_cts00m36.data_final
             next field atdprscod
          end if
       before field data_final
          let mr_cts00m36.data_final = mr_cts00m36.data_inicial

          display by name mr_cts00m36.data_final attribute (reverse)
       after field data_final

          display by name mr_cts00m36.data_final

          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field data_inicial
          end if

          if mr_cts00m36.data_final is null then
             error 'Informe a data final'
             next field data_final
          end if
          if mr_cts00m36.data_final < mr_cts00m36.data_inicial then
             error 'Data final menor que data inicial'
             next field data_final
          end if
       before field atdprscod
          display by name mr_cts00m36.atdprscod attribute (reverse)

       after field atdprscod

          display by name mr_cts00m36.atdprscod

          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field data_final
          end if
          if mr_cts00m36.atdprscod is null then
             next field atdsrvorg
          end if
          let l_par1 = 'G'
          # Obter nome do prestador
          call ctn24c00_nome_prestador(mr_cts00m36.atdprscod, l_par1)
             returning l_resultado
                      ,l_mensagem
                      ,l_nomgrr
          if l_resultado = 1 then
             display l_nomgrr to nomgrr
             exit input
          else
             if l_resultado = 2 then
                # Popup para escolha do prestador
                let mr_cts00m36.atdprscod = ctn24c00()
                if mr_cts00m36.atdprscod is not null then
                   # Obter nome do prestador
                   call ctn24c00_nome_prestador(mr_cts00m36.atdprscod, l_par1)
                      returning l_resultado
                               ,l_mensagem
                               ,l_nomgrr
                   display by name mr_cts00m36.atdprscod
                   display l_nomgrr  to nomgrr
                   exit input
                end if
             else
                error l_mensagem
                let int_flag = true
                exit input
             end if
          end if

       before field atdsrvorg

          display by name mr_cts00m36.atdsrvorg attribute (reverse)
       after field atdsrvorg

          display by name mr_cts00m36.atdsrvorg

          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field atdprscod
          end if

          if mr_cts00m36.atdsrvorg is null then
             next field nome
          end if
          let l_par1 = 'A'
          # Obter descricao do tipo de servico
          call cts00m09_desc_tipo_srv(mr_cts00m36.atdsrvorg, l_par1)
             returning l_resultado
                      ,l_mensagem
                      ,l_srvtipabvdes

          if l_resultado = 1 then
             display l_srvtipabvdes to srvtipabvdes
             exit input
          else
             if l_resultado = 2 then
                error l_mensagem
                let mr_cts00m36.atdsrvorg = cts00m09()
                if mr_cts00m36.atdsrvorg = 10 then
                   error 'Vistoria Previa deve ser consultada no modulo Vist_Previa'
                   next field atdsrvorg
                end if
                if mr_cts00m36.atdsrvorg is not null then
                   call cts00m09_desc_tipo_srv(mr_cts00m36.atdsrvorg, l_par1)
                      returning l_resultado
                               ,l_mensagem
                               ,l_srvtipabvdes
                   display l_srvtipabvdes        to srvtipabvdes
                   display mr_cts00m36.atdsrvorg to atdsrvorg
                   exit input
                end if
             else
                error l_mensagem
                let int_flag = true
                exit input
             end if
          end if
       before field nome
          if mr_cts00m36.data_inicial is not null and
             mr_cts00m36.atdsrvorg    is not null then
             exit input
          end if
          display by name mr_cts00m36.nome attribute (reverse)

       after field nome

          display by name mr_cts00m36.nome

          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field atdsrvorg
          end if

          if mr_cts00m36.nome is not null then
             let l_tam = length(mr_cts00m36.nome)
             if l_tam = 40 then
                let mr_cts00m36.nome[l_tam] = '*'
             else
                let mr_cts00m36.nome[l_tam+1] = '*'
             end if
             exit input
          end if
       before field vcllicnum
          display by name mr_cts00m36.vcllicnum attribute (reverse)

       after field vcllicnum

          display by name mr_cts00m36.vcllicnum

          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field nome
          end if
          
          if mr_cts00m36.vcllicnum is null then
             next field empauxpor
          end if
          if not srp1415(mr_cts00m36.vcllicnum) then
             error 'Placa invalida!'
             next field vcllicnum
          end if
          
       before field empauxpor                                    
          display by name lr_emp.empauxpor attribute(reverse)   
                                                               
       after field empauxpor                                     
          display by name lr_emp.empauxpor
       
          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field nome
          end if

          if  lr_emp.empauxpor is not null and 
              lr_emp.empauxpor <> " "      and 
              lr_emp.empauxpor <> "X"      then
              let lr_emp.empauxpor = " "
              error "Opção invalida, Marque com X ou desmarque a opção desejada."
              next field empauxpor
          end if
          
       before field empauxazu                                    
          display by name lr_emp.empauxazu attribute(reverse)   
                                                               
       after field empauxazu                                         
          display by name lr_emp.empauxazu
          
          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field empauxpor
          end if

          if  lr_emp.empauxazu is not null and 
              lr_emp.empauxazu <> " "      and 
              lr_emp.empauxazu <> "X"      then
              let lr_emp.empauxazu = " "
              error "Opção invalida, Marque com X ou desmarque a opção desejada."
              next field empauxazu
          end if  
          
       before field empauxita                                    
          display by name lr_emp.empauxita attribute(reverse)   
                                                               
       after field empauxita                                     
          display by name lr_emp.empauxita                       
          
          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field empauxazu
          end if

          if  lr_emp.empauxita is not null and 
              lr_emp.empauxita <> " "      and 
              lr_emp.empauxita <> "X"      then
              let lr_emp.empauxita = " "
              error "Opção invalida, Marque com X ou desmarque a opção desejada."
              next field empauxita
          end if  
          
       before field empauxvid                                    
          display by name lr_emp.empauxvid attribute(reverse)   
                                                               
       after field empauxvid                                     
          display by name lr_emp.empauxvid                        
          
          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field empauxita
          end if

          if  lr_emp.empauxvid is not null and 
              lr_emp.empauxvid <> " "      and 
              lr_emp.empauxvid <> "X"      then
              let lr_emp.empauxvid = " "
              error "Opção invalida, Marque com X ou desmarque a opção desejada."
              next field empauxvid
          end if  
          
       before field empauxpro                                    
          display by name lr_emp.empauxpro attribute(reverse)   
                                                               
       after field empauxpro                                     
          display by name lr_emp.empauxpro         
       
          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field empauxvid
          end if

          if  lr_emp.empauxpro is not null and 
              lr_emp.empauxpro <> " "      and 
              lr_emp.empauxpro <> "X"      then
              let lr_emp.empauxpro = " "
              error "Opção invalida, Marque com X ou desmarque a opção desejada."
              next field empauxpro
          end if  
          
       before field empauxsau                                    
          display by name lr_emp.empauxsau attribute(reverse)   
                                                               
       after field empauxsau                                     
          display by name lr_emp.empauxsau                      

          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field empauxpro
          end if

          if  lr_emp.empauxsau is not null and 
              lr_emp.empauxsau <> " "      and 
              lr_emp.empauxsau <> "X"      then
              let lr_emp.empauxsau = " "
              error "Opção invalida, Marque com X ou desmarque a opção desejada."
              next field empauxsau
          end if
         
       before field empauxcar                                    
          display by name lr_emp.empauxcar attribute(reverse)   
                                                               
       after field empauxcar                                     
          display by name lr_emp.empauxcar        

          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field empauxsau
          end if
          
          if  lr_emp.empauxcar is not null and 
              lr_emp.empauxcar <> " "      and 
              lr_emp.empauxcar <> "X"      then
              let lr_emp.empauxcar = " "
              error "Opção invalida, Marque com X ou desmarque a opção desejada."
              next field empauxcar
          end if   
                 
       before field empauxpss                                    
          display by name lr_emp.empauxpss attribute(reverse)   
                                                               
       after field empauxpss                                     
          display by name lr_emp.empauxpss 

          if fgl_lastkey() = fgl_keyval('up')   or
             fgl_lastkey() = fgl_keyval('left') then
             next field empauxcar
          end if
          
          if  lr_emp.empauxpss is not null and 
              lr_emp.empauxpss <> " "      and 
              lr_emp.empauxpss <> "X"      then
              let lr_emp.empauxpss = " "
              error "Opção invalida, Marque com X ou desmarque a opção desejada."
              next field empauxpss
          end if   
                    
          if  (lr_emp.empauxpor is null or lr_emp.empauxpor = " ") and
              (lr_emp.empauxazu is null or lr_emp.empauxazu = " ") and
              (lr_emp.empauxita is null or lr_emp.empauxita = " ") and
              (lr_emp.empauxvid is null or lr_emp.empauxvid = " ") and
              (lr_emp.empauxpro is null or lr_emp.empauxpro = " ") and
              (lr_emp.empauxsau is null or lr_emp.empauxsau = " ") and
              (lr_emp.empauxcar is null or lr_emp.empauxcar = " ") and
              (lr_emp.empauxpss is null or lr_emp.empauxpss = " ") then
              error "É obrigatório informar no mínimo uma empresa para filtro."
              next field empauxpor
          end if

    end input
    if int_flag = true then
       exit while
    else
       # Verificar se existe servicos com os parametros solicitados
       let l_flag = cts00m36_testa_parametros()
       if l_flag = 0 then
          error 'Nao existem servicos programados nessas condicoes' ## (retornar ao input)
          let l_srvtipabvdes = null
          let l_nomgrr       = null

          display l_srvtipabvdes  to srvtipabvdes
          display l_nomgrr        to nomgrr
          initialize mr_cts00m36  to null
       else
       
          let mr_cts00m36.in_empresas = null
          
          if lr_emp.empauxpor = 'X' then
             let mr_cts00m36.in_empresas = '1'
          end if 
          
          if lr_emp.empauxazu = 'X' then
             if mr_cts00m36.in_empresas is not null then
                let mr_cts00m36.in_empresas = mr_cts00m36.in_empresas clipped,',35'
             else
                let mr_cts00m36.in_empresas = '35'
             end if 
          end if 
          
          if lr_emp.empauxita = 'X' then
             if mr_cts00m36.in_empresas is not null then
                let mr_cts00m36.in_empresas = mr_cts00m36.in_empresas clipped,',84'
             else
                let mr_cts00m36.in_empresas = '84'
             end if 
          end if 
          
          if lr_emp.empauxvid = 'X' then
             if mr_cts00m36.in_empresas is not null then
                let mr_cts00m36.in_empresas = mr_cts00m36.in_empresas clipped,',14'
             else
                let mr_cts00m36.in_empresas = '14'
             end if 
          end if 
          
          if lr_emp.empauxpro = 'X' then
             if mr_cts00m36.in_empresas is not null then
                let mr_cts00m36.in_empresas = mr_cts00m36.in_empresas clipped,',27'
             else
                let mr_cts00m36.in_empresas = '27'
             end if 
          end if 
          
          if lr_emp.empauxsau = 'X' then
             if mr_cts00m36.in_empresas is not null then
                let mr_cts00m36.in_empresas = mr_cts00m36.in_empresas clipped,',50'
             else
                let mr_cts00m36.in_empresas = '50'
             end if 
          end if   
          
          if lr_emp.empauxcar = 'X' then
             if mr_cts00m36.in_empresas is not null then
                let mr_cts00m36.in_empresas = mr_cts00m36.in_empresas clipped,',40'
             else
                let mr_cts00m36.in_empresas = '40'
             end if 
          end if   
          
          if lr_emp.empauxpss = 'X' then
             if mr_cts00m36.in_empresas is not null then
                let mr_cts00m36.in_empresas = mr_cts00m36.in_empresas clipped,',43'
             else
                let mr_cts00m36.in_empresas = '43'
             end if 
          end if 
       
          exit while
       end if
    end if
 end while
 sleep 1

# let int_flag = false
 close window w_cts00m36
 return mr_cts00m36.*

end function

#------------------------------------
function cts00m36_testa_parametros()
#------------------------------------

 define l_retorno    smallint,
        l_sql        char(100),
        l_condicao   char(700),
        l_comando    char(800)

 let l_retorno = 0

 let l_condicao = null

 let l_sql      = " select 1 from datmservico "

 let l_condicao = " where datmservico.atdlibflg = 'S' ",
                  "   and datmservico.atdfnlflg in('N','A') ",
                  "   and datmservico.atdsrvorg <> 10 "
 if mr_cts00m36.data_inicial is not null and mr_cts00m36.data_final is not null then
    let l_condicao = l_condicao clipped,
                     " and datmservico.atddatprg >= '", mr_cts00m36.data_inicial, "'",
                     " and datmservico.atddatprg <= '", mr_cts00m36.data_final, "'"
 else
    let l_condicao = l_condicao clipped,
                     " and datmservico.atddatprg >= today   "
 end if
 if mr_cts00m36.atdsrvorg is not null then
    let l_condicao = l_condicao clipped,
                     " and datmservico.atdsrvorg = ", mr_cts00m36.atdsrvorg
 end if

 if mr_cts00m36.vcllicnum is not null then
    let l_condicao = l_condicao clipped,
                     " and datmservico.vcllicnum = '", mr_cts00m36.vcllicnum, "'"
 end if

 if mr_cts00m36.nome is not null then
    let l_condicao = l_condicao clipped,
                     " and datmservico.nom matches '", mr_cts00m36.nome, "'"
 end if

 if mr_cts00m36.atdprscod is not null then
    let l_sql = l_sql clipped, ", datmsrvre b "
    let l_condicao = l_condicao clipped,
                     " and datmservico.atdsrvorg  in (9,13) ",
                     " and datmservico.atdsrvnum  = b.atdsrvnum ",
                     " and datmservico.atdsrvano  = b.atdsrvano ",
                     " and b.atdorgsrvnum in ",
                     " (select c.atdsrvnum   ",
                     "  from datmservico c ",
                     " where c.atdsrvano = b.atdorgsrvano ",
                     "   and c.atdprscod = ",mr_cts00m36.atdprscod,")"
 end if

 let l_comando = l_sql clipped, l_condicao clipped
 prepare pcts00m36001  from  l_comando
 declare ccts00m36001  cursor  for pcts00m36001

 open ccts00m36001
 whenever error continue
 fetch ccts00m36001
 whenever error stop
 if sqlca.sqlcode = 0 then
    let l_retorno = 1
 else
    if sqlca.sqlcode <> notfound then
       error 'Erro SELECT ccts00m36001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       let l_retorno = 2
    end if
 end if

 return l_retorno

end function

