#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : ctc72m01.4gl                                        #
# Analista Resp.: Priscila Staingel                                   #
# OSF/PSI       : 195138                                              #
#                Cadastro de parametros para rodizio                  #
#                                                                     #
# Desenvolvedor  : Priscila Staingel                                  #
# DATA           : 07/11/2005                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_ctc72m01  record
          cidnom   like glakcid.cidnom, 
          ufdcod   like glakcid.ufdcod,
          cidcod   like datkvclrdzprt.cidcod
end record   

define am_ctc72m01 array[100] of record
          vclplcfnlnum    like datkvclrdzprt.vclplcfnlnum,
          rdzsmndianum    like datkvclrdzprt.rdzsmndianum,
          tracox          char (01),
          cplDiaDesc      char (10), 
          vclrdzinchor    like datkvclrdzprt.vclrdzinchor,
          vclrdzfnlhor    like datkvclrdzprt.vclrdzfnlhor,
          rdzlcldst       like datkvclrdzprt.rdzlcldst,
          rdzsttflg       like datkvclrdzprt.rdzsttflg,
          tracoy          char (01),
          cplFlagDesc     char (10)          
end record

define m_prepara_sql     smallint,
       m_consulta_ativa  smallint,
       m_count           smallint
       


#------------------------#
function ctc72m01_prep()
#------------------------#
  define l_sql_stmt  char(1500)

   #Busca dados do rodizio para a cidade
   let l_sql_stmt = 'select vclplcfnlnum, rdzsmndianum, '
                   ,' vclrdzinchor, vclrdzfnlhor,       '
                   ,' rdzlcldst, rdzsttflg              '
                   ,'from datkvclrdzprt                 '
                   ,'where cidcod = ?                   '
                   ,'order by vclplcfnlnum, rdzsmndianum, '
                   ,'         vclrdzinchor, vclrdzfnlhor  '
   prepare pctc72m01002  from l_sql_stmt
   declare cctc72m01002 cursor for pctc72m01002

   #Insere dados na tabela de rodizio
   let l_sql_stmt = 'insert into datkvclrdzprt                '
                   ,' (cidcod, vclplcfnlnum, rdzsmndianum,    '
                   ,'  vclrdzinchor, vclrdzfnlhor, rdzlcldst, '
                   ,'  rdzsttflg )                            '
                   ,'values(?, ?, ?, ?, ?, ?, ?)              '
   prepare pctc72m01003  from l_sql_stmt

   #apaga os registros da tabela para a cidade selecionada
   let l_sql_stmt = 'delete from datkvclrdzprt '
                   ,' where cidcod = ?         '
                   ,'   and vclplcfnlnum = ?   '
                   ,'   and rdzsmndianum = ?   '
                   ,'   and vclrdzinchor = ?   '
                   ,'   and vclrdzfnlhor = ?   '
   prepare pctc72m01004  from l_sql_stmt

  let m_prepara_sql = true
end function

#-----------------#
function ctc72m01()
#-----------------#

  if m_prepara_sql is null or
     m_prepara_sql <> true then
     call ctc72m01_prep()
  end if

  open window ctc72m01 at 6,2 with form "ctc72m01"
  attribute (form line 1,comment line last - 1)

  message " (F17)Abandona"

  initialize mr_ctc72m01.*   to null
  initialize am_ctc72m01     to null 

  let int_flag = false

  call ctc72m01_entrada_dados()
  if int_flag = true then
     close window ctc72m01
     return
  end if
 
  options 
     delete key control-y
  
  call ctc72m01_busca_dados() 
 
  #chama funcao que carrega dados do rodizio para a cidade
  call ctc72m01_entrada_rodizio()

  options
     delete key f2

  close window ctc72m01

end function


#----------------------------#
function ctc72m01_entrada_dados()
#----------------------------#

  define l_ret smallint,
         l_mensagem  char(100)

  input by name mr_ctc72m01.cidnom, mr_ctc72m01.ufdcod without defaults

    before field cidnom
         display by name mr_ctc72m01.cidnom attribute (reverse)

    after field cidnom
         display by name mr_ctc72m01.cidnom
         if mr_ctc72m01.cidnom is null then
             error "Cidade deve ser informada."
             next field cidnom
         end if

    before field ufdcod
         display by name mr_ctc72m01.ufdcod attribute (reverse)

    after field ufdcod
         display by name mr_ctc72m01.ufdcod
         #Buscar codigo para essa cidade e estado
         call cty10g00_obter_cidcod(mr_ctc72m01.cidnom,
                                    mr_ctc72m01.ufdcod)
              returning l_ret,
                        l_mensagem,
                        mr_ctc72m01.cidcod

         if l_ret <> 0 then
             if l_ret = 1 then
                 call cts06g04(mr_ctc72m01.cidnom, mr_ctc72m01.ufdcod)
                     returning mr_ctc72m01.cidcod,
                               mr_ctc72m01.cidnom,
                               mr_ctc72m01.ufdcod
                 if mr_ctc72m01.cidnom  is null   then
                     next field cidnom
                 end if
             else
                 error l_mensagem sleep 2
                 next field cidnom
             end if
         end if

    on key (f17, control-c, interrupt)
          let int_flag = true
          exit input

  end input

end function

#----------------------------#
function ctc72m01_entrada_rodizio()
#----------------------------#
  define l_msg char (20),
         l_tela smallint,
         l_arr  smallint,
         l_modifica_chave smallint,
         l_salva_dist   like datkvclrdzprt.rdzlcldst,
         l_salva_flg  like datkvclrdzprt.rdzsttflg,
         l_aux  smallint

  let l_aux = true
  let l_modifica_chave = false
  call set_count(m_count)
  options comment line last - 1
  message " (F17)Abandona, (F2)Exclui"

  input array am_ctc72m01 without defaults from s_tela.*

    before row
        let l_tela  = scr_line()
        let l_arr   = arr_curr()
        let l_salva_dist = am_ctc72m01[l_arr].rdzlcldst 
        let l_salva_flg  = am_ctc72m01[l_arr].rdzsttflg

    before field vclplcfnlnum
        #se ja tiver dado no array - nao pode alterar chave, entao vai para
        # o campo distancia
        if am_ctc72m01[l_arr].vclplcfnlnum is not null and 
           l_modifica_chave = false then
            let l_modifica_chave = false
            next field rdzlcldst
        else
            let l_modifica_chave = true
        end if
        display am_ctc72m01[l_arr].vclplcfnlnum to s_tela[l_tela].vclplcfnlnum attribute (reverse)
    after field vclplcfnlnum
        display am_ctc72m01[l_arr].vclplcfnlnum to s_tela[l_tela].vclplcfnlnum
        if fgl_lastkey() <> fgl_keyval("up")   and
           fgl_lastkey() <> fgl_keyval("left") then
           if am_ctc72m01[l_arr].vclplcfnlnum is null then
              next field vclplcfnlnum
           end if
        end if

    before field rdzsmndianum
         display am_ctc72m01[l_arr].rdzsmndianum to s_tela[l_tela].rdzsmndianum attribute (reverse)
    after field rdzsmndianum
         display am_ctc72m01[l_arr].rdzsmndianum to s_tela[l_tela].rdzsmndianum
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
               next field vclplcfnlnum
         end if
         #chamar funcao para buscar dia da semana do controle_componentes
         call funferia_Dia_Semana(am_ctc72m01[l_arr].rdzsmndianum)
              returning am_ctc72m01[l_arr].cplDiaDesc,
                        l_msg
         if am_ctc72m01[l_arr].cplDiaDesc is null then
            error "Codigo dia da semana invalido." sleep 2
            next field rdzsmndianum
         end if
         let am_ctc72m01[l_arr].tracox = '-'
         display am_ctc72m01[l_arr].tracox to s_tela[l_tela].tracox
         display am_ctc72m01[l_arr].cplDiaDesc to s_tela[l_tela].cplDiaDesc

    before field vclrdzinchor
         display am_ctc72m01[l_arr].vclrdzinchor to s_tela[l_tela].vclrdzinchor attribute (reverse)
    after field vclrdzinchor
         display am_ctc72m01[l_arr].vclrdzinchor to s_tela[l_tela].vclrdzinchor
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
               next field rdzsmndianum
         end if
         if am_ctc72m01[l_arr].vclrdzinchor is null then
              error "Informe a hora inicial do rodizio" sleep 2
              next field vclrdzinchor
         end if

    before field vclrdzfnlhor
         display am_ctc72m01[l_arr].vclrdzfnlhor to s_tela[l_tela].vclrdzfnlhor attribute (reverse)
    after field vclrdzfnlhor
         display am_ctc72m01[l_arr].vclrdzfnlhor to s_tela[l_tela].vclrdzfnlhor
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
              next field vclrdzinchor
         end if
         if am_ctc72m01[l_arr].vclrdzfnlhor is null then
            error "Informe a hora final do rodizio" sleep 2
            next field vclrdzfnlhor
         end if
         if am_ctc72m01[l_arr].vclrdzfnlhor < am_ctc72m01[l_arr].vclrdzinchor then
             error "Hora inicial maior que hora final" sleep 2
             next field vclrdzinchor
         end if

    before field rdzlcldst
         display am_ctc72m01[l_arr].rdzlcldst to s_tela[l_tela].rdzlcldst attribute (reverse)
    after field rdzlcldst
         display am_ctc72m01[l_arr].rdzlcldst to s_tela[l_tela].rdzlcldst
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
              if l_modifica_chave <> false then
                 next field vclrdzfnlhor
              else
                 if fgl_lastkey() = fgl_keyval("up") then
                    continue input
                 else
                    error "Nao e permitido alterar hora"
                    next field rdzlcldst
                 end if
              end if
         end if
         if am_ctc72m01[l_arr].rdzlcldst is null then
               error "Informe a distancia" sleep 2
               next field rdzlcldst
         end if

    before field rdzsttflg
          display am_ctc72m01[l_arr].rdzsttflg to s_tela[l_tela].rdzsttflg attribute (reverse)
    after field rdzsttflg
         display am_ctc72m01[l_arr].rdzsttflg to s_tela[l_tela].rdzsttflg
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
               next field rdzlcldst
         end if
         if am_ctc72m01[l_arr].rdzsttflg is null or
            (am_ctc72m01[l_arr].rdzsttflg <> 'S' and 
             am_ctc72m01[l_arr].rdzsttflg <> 'N') then
              error "Flag Rodizio - (N)ormal ou (S)uspenso"
              next field rdzsttflg
         end if
         if am_ctc72m01[l_arr].rdzsttflg = 'S' then
               let am_ctc72m01[l_arr].cplFlagDesc = 'Suspenso'
         else
               let am_ctc72m01[l_arr].cplFlagDesc = 'Normal'
         end if
         let am_ctc72m01[l_arr].tracoy = '-'
         display am_ctc72m01[l_arr].tracoy to s_tela[l_tela].tracoy
         display am_ctc72m01[l_arr].cplFlagDesc to s_tela[l_tela].cplFlagDesc
            
    after row
       #grava linha se foi alterada
       if am_ctc72m01[l_arr].vclplcfnlnum is not null and
          am_ctc72m01[l_arr].rdzsmndianum is not null and
          am_ctc72m01[l_arr].vclrdzinchor is not null and
          am_ctc72m01[l_arr].vclrdzfnlhor is not null and
          am_ctc72m01[l_arr].rdzlcldst is not null and
          am_ctc72m01[l_arr].rdzsttflg is not null then
          if l_salva_dist <> am_ctc72m01[l_arr].rdzlcldst or
             l_salva_flg <> am_ctc72m01[l_arr].rdzsttflg or
             l_modifica_chave = true then
             begin work
             if l_modifica_chave <> true then
                #alterou dados ou inseriu novo
                whenever error continue
                execute pctc72m01004 using mr_ctc72m01.cidcod,
                                           am_ctc72m01[l_arr].vclplcfnlnum,
                                           am_ctc72m01[l_arr].rdzsmndianum,
                                           am_ctc72m01[l_arr].vclrdzinchor,
                                           am_ctc72m01[l_arr].vclrdzfnlhor
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   error "Erro ao excluir dados da tabela de parametros de rodizio!!"
                   let l_aux = false
                end if
             end if
             #display "Inserindo dados:"
             #display "cidcod: ",mr_ctc72m01.cidcod
             #display "vclplcfnlnum: ",am_ctc72m01[l_arr].vclplcfnlnum
             #display "rdzsmndianum: ",am_ctc72m01[l_arr].rdzsmndianum
             #display "vclrdzinchor: ",am_ctc72m01[l_arr].vclrdzinchor
             #display "vclrdzfnlhor: ",am_ctc72m01[l_arr].vclrdzfnlhor
             #display "rdzlcldst: ",am_ctc72m01[l_arr].rdzlcldst
             #display "rdzsttflg: ",am_ctc72m01[l_arr].rdzsttflg
             whenever error continue
             execute pctc72m01003 using mr_ctc72m01.cidcod,
                                        am_ctc72m01[l_arr].vclplcfnlnum,
                                        am_ctc72m01[l_arr].rdzsmndianum,
                                        am_ctc72m01[l_arr].vclrdzinchor,
                                        am_ctc72m01[l_arr].vclrdzfnlhor,
                                        am_ctc72m01[l_arr].rdzlcldst,
                                        am_ctc72m01[l_arr].rdzsttflg
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = -391 then
                   error "Dados Incompletos"
                else
                  error "Erro [", sqlca.sqlcode, "] ao inserir dados na tabela de cidades sede para parametros de acionamento!!" 
                end if
                let l_aux = false
             end if
   
             if l_aux = false then
                rollback work
                exit input
             else
                commit work
             end if
          end if
       else
         let l_modifica_chave = false 
         initialize am_ctc72m01[l_arr].* to null 
       end if
    
    on key (f17, control-c, interrupt)
          exit input

    on key (f2)
          #apagar linha corrente da tabela
          begin work
          whenever error continue
          execute pctc72m01004 using mr_ctc72m01.cidcod,
                                     am_ctc72m01[l_arr].vclplcfnlnum,
                                     am_ctc72m01[l_arr].rdzsmndianum,
                                     am_ctc72m01[l_arr].vclrdzinchor,
                                     am_ctc72m01[l_arr].vclrdzfnlhor
          whenever error stop
          if sqlca.sqlcode <> 0 then
             error "Erro ao excluir dados da tabela de parametros de rodizio!!"
             let l_aux = false
          end if
          if l_aux = false then
             rollback work
             exit input
          else
             commit work
             call ctc72m01_deleta_linha(l_arr, l_tela)
          end if

  end input

end function


#----------------------------#
function ctc72m01_busca_dados()
#----------------------------#
   define l_msg char (20)
   
   let m_count = 1

   open cctc72m01002 using mr_ctc72m01.cidcod
   foreach cctc72m01002 into am_ctc72m01[m_count].vclplcfnlnum,
                             am_ctc72m01[m_count].rdzsmndianum,
                             am_ctc72m01[m_count].vclrdzinchor,
                             am_ctc72m01[m_count].vclrdzfnlhor,
                             am_ctc72m01[m_count].rdzlcldst,
                             am_ctc72m01[m_count].rdzsttflg

         call funferia_Dia_Semana(am_ctc72m01[m_count].rdzsmndianum)
              returning am_ctc72m01[m_count].cplDiaDesc,
                        l_msg
         if am_ctc72m01[m_count].cplDiaDesc is null then
            error "Codigo dia da semana invalido." sleep 2
         end if
         let am_ctc72m01[m_count].tracox = '-'

         if am_ctc72m01[m_count].rdzsttflg = 'S' then
               let am_ctc72m01[m_count].cplFlagDesc = 'Suspenso'
         else
               let am_ctc72m01[m_count].cplFlagDesc = 'Normal'
         end if
         let am_ctc72m01[m_count].tracoy = '-'

         let m_count = m_count + 1
         if m_count > 100 then
            exit foreach
         end if
   end foreach
   let m_count = m_count - 1
   close cctc72m01002

end function


#---------------------------------------#
function ctc72m01_deleta_linha(l_arr, l_scr)
#---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint

  for l_cont = l_arr to 99
     if am_ctc72m01[l_arr].vclplcfnlnum is not null then
        let am_ctc72m01[l_cont].* = am_ctc72m01[l_cont + 1].*
     else
        initialize am_ctc72m01[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 11
     display am_ctc72m01[l_arr].vclplcfnlnum to s_tela[l_cont].vclplcfnlnum
     display am_ctc72m01[l_arr].rdzsmndianum to s_tela[l_cont].rdzsmndianum
     display am_ctc72m01[l_arr].tracox       to s_tela[l_cont].tracox
     display am_ctc72m01[l_arr].cplDiaDesc   to s_tela[l_cont].cplDiaDesc
     display am_ctc72m01[l_arr].vclrdzinchor to s_tela[l_cont].vclrdzinchor
     display am_ctc72m01[l_arr].vclrdzfnlhor to s_tela[l_cont].vclrdzfnlhor
     display am_ctc72m01[l_arr].rdzlcldst    to s_tela[l_cont].rdzlcldst
     display am_ctc72m01[l_arr].rdzsttflg    to s_tela[l_cont].rdzsttflg
     display am_ctc72m01[l_arr].tracoy       to s_tela[l_cont].tracoy
     display am_ctc72m01[l_arr].cplFlagDesc  to s_tela[l_cont].cplFlagDesc
     let l_arr = l_arr + 1
  end for

end function


