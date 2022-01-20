#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : sinistro auto                                       #
# Modulo        : ctc00m10.4gl                                        #
# Analista Resp.: Ligia Mattge                                        #
# OSF/PSI       : 26077/175552                                        #
#.....................................................................#
# Desenvolvimento: Meta, Eduardo Luis Nogueira                        #
# Liberacao      : 22/09/2003                                         #
#.....................................................................#
# 30/04/2008 Norton Nery-Meta    psi221112  Mudanca no nome da tabela #
#                                           gtakram.                  #
#.....................................................................#
#                                                                     #
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_ctc00m10      record
           ramcod       like datkprtinftip.ramcod,
           ramnom       like gtakram.ramnom,
           c24astcod    like datkprtinftip.c24astcod,
           c24astdes    like datkassunto.c24astdes,
           cvnnum       like datkprtinftip.cvnnum,
           cpodes       like iddkdominio.cpodes,
           c24prtseq    like datkprtinftip.c24prtseq
                        end record

define mr_ctc00m102     record
           c24prtsit    like datkprtcpa.c24prtsit,
           caddat       date,
           cadhor       datetime hour to minute,
           funmat       like isskfunc.funmat,
           funnom       like isskfunc.funnom
                        end record

define am_ctc00m10 array[100] of record
           c24prtinftip char(01),
           cpocod       like iddkdominio.cpocod,
           cpodes2      like iddkdominio.cpodes
                   end record

define am_ctc00m101 array[100] of record
           emapager     char(01),
           empcod       like gabkemp.empcod,
           codigo       char(10),
           destinat     char(20)
                   end record

define am_ctc00m102 array[100] of record
           maicod     like datkprtextmai.maicod
                   end record

define am_ctc00m103 array[100] of record
           ustcod       like datkprtdst.ustcod,
           funmat       like datkprtdst.funmat,
           c24prtinftip like datkprtinftip.c24prtinftip
                    end record

define am_ctc00m10b array[100] of record
           cpodes2      like iddkdominio.cpodes,
           cpocod       like iddkdominio.cpocod
                   end record


define m_prepara_sql    smallint

define m_arr_curr  smallint,
       m_scr_line  smallint,
       m_count     smallint

define m_arr_curr_1  smallint,
       m_scr_line_1  smallint,
       m_count1      smallint

define m_arr_curr_2  smallint,
       m_scr_line_2  smallint,
       m_count2      smallint

define m_prepare_sql     smallint,
       m_consulta_ativa  smallint

#------------------------#
function ctc00m10_prep()
#------------------------#

 define l_sql_stmt    char(1500)

 #inicio
 let l_sql_stmt = 'select ramnom ',
                   ' from gtakram ',
                  ' where ramcod = ? '

 prepare pctc00m10001 from l_sql_stmt

 declare cctc00m10001 cursor for pctc00m10001
 #fim

 #inicio
 let l_sql_stmt = ' select c24astdes ',
                    ' from datkassunto ',
                   ' where c24astcod = ? '

 prepare pctc00m10002 from l_sql_stmt

 declare cctc00m10002 cursor for pctc00m10002
 #fim

 #inicio
 let l_sql_stmt = ' select cpocod, ',
                         ' cpodes ',
                    ' from datkdominio ',
                   ' where cpocod = ?  ',
                     ' and cponom = ? ',
                   ' order by cpocod '

 prepare pctc00m10003 from l_sql_stmt

 declare cctc00m10003 cursor for pctc00m10003
 #fim

 #inicio
 let l_sql_stmt = ' select max(c24prtseq) ',
                    ' from datkprtcpa ',
                   ' where ramcod = ? ',
                     ' and c24astcod = ? ',
                     ' and cvnnum = ? '


 prepare pctc00m10004 from l_sql_stmt

 declare cctc00m10004 cursor for pctc00m10004
 #fim

 #inicio
 let l_sql_stmt = ' select 1 ',
                    ' from gabkemp ',
                   ' where empcod = ? '

 prepare pctc00m10006 from l_sql_stmt

 declare cctc00m10006  cursor with hold for  pctc00m10006
 #fim

 #inicio
 let l_sql_stmt = ' select funnom ',
                    ' from isskfunc ',
                   ' where funmat = ? ',
                     ' and empcod = ? ',
                     ' and usrtip = "F" '

 prepare pctc00m10007 from l_sql_stmt

 declare cctc00m10007  cursor with hold for  pctc00m10007
 #fim

 #inicio

 let l_sql_stmt = ' select pgrnum ',
                    ' from htlrust ',
                   ' where ustcod = ? '

 prepare pctc00m10008 from l_sql_stmt

 declare cctc00m10008 cursor for pctc00m10008

 #fim

 #inicio
 let l_sql_stmt = ' insert into datkprtinftip ( ramcod, ',
                                              ' c24astcod, ',
                                              ' cvnnum, ',
                                              ' c24prtseq, ',
                                              ' c24prtinftip )',
                                     ' values (?,?,?,?,?) '

 prepare pctc00m10009 from l_sql_stmt
 #fim

 #inicio
 let l_sql_stmt = ' insert into datkprtdst ( ramcod, ',
                                           ' c24astcod, ',
                                           ' cvnnum, ',
                                           ' c24prtseq, ',
                                           ' ustcod, ',
                                           ' empcod, ',
                                           ' usrtip, ',
                                           ' funmat )',
                                  ' values (?,?,?,?,?,?,?,?) '

 prepare pctc00m10010 from l_sql_stmt
 #fim

 #inicio
 let l_sql_stmt = ' insert into datkprtextmai ( ramcod, ',
                                              ' c24astcod, ',
                                              ' cvnnum, ',
                                              ' c24prtseq, ',
                                              ' maicod )',
                                     ' values (?,?,?,?,?) '

 prepare pctc00m10011 from l_sql_stmt
 #fim

#inicio
 let l_sql_stmt = ' insert into datkprtcpa ( ramcod, ',
                                           ' c24astcod, ',
                                           ' cvnnum, ',
                                           ' c24prtseq, ',
                                           ' c24prtsit, ',
                                           ' caddat, ',
                                           ' cadhor, ',
                                           ' cadmat, ',
                                           ' cadusrtip, ',
                                           ' cademp )',
                                  ' values (?,?,?,?,?,?,?,?,?,?) '

 prepare pctc00m10012 from l_sql_stmt
 #fim

 #inicio
 let l_sql_stmt = ' select a.ramcod, ',
                         ' e.ramnom, ',
                         ' a.c24astcod, ',
                         ' b.c24astdes, ',
                         ' a.cvnnum, ',
                         ' d.cpodes, ',
                         ' a.c24prtseq, ',
                         ' c.c24prtsit, ',
                         ' c.caddat, ',
                         ' c.cadhor, ',
                         ' c.cadmat, ',
                         ' c.cademp ',
                    ' from datkprtinftip a,datkassunto b,datkprtcpa c,datkdominio d, ',
                         ' outer gtakram e',
                   ' where a.ramcod = e.ramcod ',
                     ' and a.cvnnum = d.cpocod ',
                     ' and "cvnnum" = d.cponom ',
                     ' and a.c24astcod = b.c24astcod ',
                     ' and a.ramcod = c.ramcod ',
                     ' and a.c24astcod = c.c24astcod ',
                     ' and a.cvnnum = c.cvnnum ',
                     ' and a.c24prtseq = c.c24prtseq ',
                     ' and (1 = ? or a.ramcod = ?) ',
                     ' and (1 = ? or a.c24astcod = ?) ',
                     ' and (1 = ? or a.cvnnum = ?) ',
                     ' and (1 = ? or a.c24prtseq = ?) ',
                     ' and a.c24prtinftip = (select max(f.c24prtinftip) ',
                                             ' from datkprtinftip f ',
                                            ' where f.ramcod = a.ramcod ',
                                             '  and f.c24astcod = a.c24astcod ',
                                             '  and f.cvnnum = a.cvnnum ',
                                             '  and f.c24prtseq = a.c24prtseq) ',
                     ' order by a.ramcod,a.c24astcod,a.cvnnum,a.c24prtseq '

 prepare pctc00m10013 from l_sql_stmt
 declare cctc00m10013 scroll cursor for pctc00m10013
 #fim

 #inicio

 let l_sql_stmt = "select a.cpocod, a.cpodes, ",
                  "(case when b.c24prtinftip is null then ' ' else 'X' end) c24prtinftip",
                  "  from iddkdominio a, outer datkprtinftip b",
                  " where a.cpocod = b.c24prtinftip",
                  "    and a.cponom = 'c24prtinftip'",
                  "    and b.ramcod = ? ",
                  "    and b.c24astcod = ? ",
                  "    and b.cvnnum = ? ",
                  "    and b.c24prtseq = ? ",
                  "order by a.cpocod    "

 prepare pctc00m10014 from l_sql_stmt
 declare cctc00m10014 scroll cursor with hold for pctc00m10014
 #fim

 #inicio
 let l_sql_stmt = ' select b.ustcod, ',
                         ' b.empcod, ',
                         ' b.funmat ',
                    ' from datkprtdst b ',
                   ' where b.ramcod = ? ',
                     ' and b.c24astcod = ? ',
                     ' and b.cvnnum = ? ',
                     ' and b.c24prtseq = ? ',
                   ' order by b.ustcod '

 prepare pctc00m10015 from l_sql_stmt
 declare cctc00m10015 scroll cursor with hold for pctc00m10015
 #fim

 #inicio
 let l_sql_stmt = ' delete from datkprtinftip ',
                        ' where ramcod = ? ',
                          ' and c24astcod = ? ',
                          ' and cvnnum = ? ',
                          ' and c24prtseq = ? '

 prepare pctc00m10016 from l_sql_stmt
 #fim

 #inicio
 let l_sql_stmt = ' delete from datkprtdst ',
                        ' where ramcod = ? ',
                          ' and c24astcod = ? ',
                          ' and cvnnum = ? ',
                          ' and c24prtseq = ? '

 prepare pctc00m10017 from l_sql_stmt
 #fim

 #inicio
 let l_sql_stmt = ' delete from datkprtextmai ',
                        ' where ramcod = ? ',
                          ' and c24astcod = ? ',
                          ' and cvnnum = ? ',
                          ' and c24prtseq = ? '

 prepare pctc00m10018 from l_sql_stmt
 #fim

 #inicio
 let l_sql_stmt = ' delete from datkprtcpa ',
                        ' where ramcod = ? ',
                          ' and c24astcod = ? ',
                          ' and cvnnum = ? ',
                          ' and c24prtseq = ? '

 prepare pctc00m10019 from l_sql_stmt
 #fim

 #inicio
 let l_sql_stmt = ' update datkprtcpa ',
                     ' set c24prtsit = ?, ',
                         ' caddat = ?, ',
                         ' cadhor = ?, ',
                         ' cadmat = ?, ',
                         ' cadusrtip = ?, ',
                         ' cademp = ? ',
                   ' where ramcod = ? ',
                     ' and c24astcod = ? ',
                     ' and cvnnum = ? ',
                     ' and c24prtseq = ? '

 prepare pctc00m10023 from l_sql_stmt
 #fim

#inicio
 let l_sql_stmt = ' select c.maicod ',
                    ' from datkprtextmai c ',
                   ' where c.ramcod = ? ',
                     ' and c.c24astcod = ? ',
                     ' and c.cvnnum = ? ',
                     ' and c.c24prtseq = ? '

 prepare pctc00m10024 from l_sql_stmt
 declare cctc00m10024 scroll cursor with hold for pctc00m10024
 #fim

 let m_prepara_sql = true

end function

#-----------------#
function ctc00m10()
#-----------------#
 define l_consulta  char(01)

  if m_prepara_sql is null or
     m_prepara_sql <> true then
     call ctc00m10_prep()
  end if

 open window ctc00m10 at 4,2 with form "ctc00m10"
 attribute (prompt line last)

 menu "Opcao"

    before menu
       clear form

    command key("I") "Inclui" "Inclui um registro"
            message " "
            clear form
            call ctc00m10_incluir()

    command key("S") "Seleciona" "Seleciona um registro"
            message " "
            clear form
            call ctc00m10_selecionar()

    command key("P") "Proximo" "Proximo registro"
            message " "
            if m_consulta_ativa = true then
               let l_consulta = "P"
               if not ctc00m10_busca_dados(l_consulta) then
                  error "Nao existem registros nessa direcao" sleep 2
               end if
            else
               error "Nenhuma linha foi selecionada! " sleep 2
               next option "Seleciona"
            end if

    command key("A") "Anterior" "Registro anteriror"
            message " "
            if m_consulta_ativa = true then
               let l_consulta = "A"
               if not ctc00m10_busca_dados(l_consulta) then
                  error "Nao existem registros nessa direcao" sleep 2
               end if
            else
               error "Nenhuma linha foi selecionada! " sleep 2
               next option "Seleciona"
            end if

    command key("M") "Modifica" "Modifica o registro atual"
            message " "
            if m_consulta_ativa then
               if ctc00m10_modificar() then
               else
                  next option "Seleciona"
               end if
            else
               error "Nenhum registro foi selecionado! Utilize primeiro a opcao Seleciona. " sleep 2
               next option "Seleciona"
            end if

    command key("X") "eXclui" "Exclui o registro atual"
            message " "
            if m_consulta_ativa then
               if ctc00m10_excluir() then
               else
                  next option "Seleciona"
               end if
            else
               error " Nenhum registro foi selecionado! Utilize primeiro a opcao Seleciona. " sleep 2
               next option "Seleciona"
            end if

    command key (interrupt,"E") "Encerra" "Retorna ao menu anterior"
            exit menu
 end menu
 close window ctc00m10
 let int_flag = false

end function

#----------------------------#
function ctc00m10_incluir()
#----------------------------#
 define l_funcao char(11)
 define l_i      smallint,
        l_j      smallint,
        l_l      smallint
 define l_flag   smallint

 define l_ustcod like datkprtdst.ustcod,
        l_usrtip like datkprtdst.usrtip

 initialize mr_ctc00m10.*   to null
 initialize mr_ctc00m102.*  to null
 initialize am_ctc00m101    to null
 initialize am_ctc00m102    to null

 let int_flag = false
 let l_flag   = false
 let l_funcao = "inclusao"

 if ctc00m10_entrada_dados(l_funcao) then
    let int_flag = false
    let l_flag   = false

    begin work

    #grava dados na tabela datkprtinftip
    for l_i = 1 to (m_arr_curr)
       if am_ctc00m10[l_i].c24prtinftip = 'X' or
          am_ctc00m10[l_i].c24prtinftip = 'x' then
          whenever error continue
          execute pctc00m10009 using mr_ctc00m10.ramcod,
                                     mr_ctc00m10.c24astcod,
                                     mr_ctc00m10.cvnnum,
                                     mr_ctc00m10.c24prtseq,
                                     am_ctc00m10[l_i].cpocod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             error 'Problemas na inclusao da tabela DATKPRTINFTIP: ',sqlca.sqlcode,' / ', sqlca.sqlerrd[2] sleep 2
             let l_flag   = true
             exit for
          end if
       end if
    end for

    #grava dados na tabela datkprtdst
    if l_flag = false then
       whenever error continue
       execute pctc00m10017 using mr_ctc00m10.ramcod,
                                  mr_ctc00m10.c24astcod,
                                  mr_ctc00m10.cvnnum,
                                  mr_ctc00m10.c24prtseq
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error 'Problemas na exclusao (2) da tabela DATKPRTDST: ',sqlca.sqlcode,' / ', sqlca.sqlerrd[2] sleep 2
          let l_flag   = true
       end if
    end if
    if l_flag = false then
       for l_j = 1 to (m_arr_curr_1 - 1)
          if am_ctc00m101[l_j].emapager = "E" then
             let l_ustcod = 0
             let l_usrtip = 'F'
             if not (am_ctc00m101[l_j].codigo is null) then
                whenever error continue
                execute pctc00m10010 using mr_ctc00m10.ramcod,
                                           mr_ctc00m10.c24astcod,
                                           mr_ctc00m10.cvnnum,
                                           mr_ctc00m10.c24prtseq,
                                           l_ustcod,
                                           am_ctc00m101[l_j].empcod,
                                           l_usrtip,
                                           am_ctc00m101[l_j].codigo
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   error 'Problemas na inclusao da tabela DATKPRTDST: ',sqlca.sqlcode,' / ', sqlca.sqlerrd[2] sleep 2
                   let l_flag   = true
                   exit for
                end if
             end if
          else
             let l_ustcod = 0
             let l_usrtip = 'X'
             if not (am_ctc00m101[l_j].codigo is null) then
                whenever error continue
                execute pctc00m10010 using mr_ctc00m10.ramcod,
                                           mr_ctc00m10.c24astcod,
                                           mr_ctc00m10.cvnnum,
                                           mr_ctc00m10.c24prtseq,
                                           am_ctc00m101[l_j].codigo,
                                           l_ustcod,  #referente ao campo empcod, usada esta variavel pois valor eh fixo
                                           l_usrtip,
                                           l_ustcod   #referente ao campo funmat, usada esta variavel pois valor eh fixo
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   error 'Problemas na inclusao da tabela DATKPRTDST: ',sqlca.sqlcode,' / ', sqlca.sqlerrd[2] sleep 2
                   let l_flag = true
                   exit for
                end if
             end if
          end if
       end for
    end if

    #grava dados na tabela datkprtextmai
    if l_flag = false then
       for l_l = 1 to (m_arr_curr_2 - 1)
          if am_ctc00m102[l_l].maicod is not null then
             whenever error continue
             execute pctc00m10011 using mr_ctc00m10.ramcod,
                                        mr_ctc00m10.c24astcod,
                                        mr_ctc00m10.cvnnum,
                                        mr_ctc00m10.c24prtseq,
                                        am_ctc00m102[l_l].maicod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                error 'Problemas na inclusao da tabela DATKPRTEXTMAI: ',sqlca.sqlcode,' / ', sqlca.sqlerrd[2] sleep 2
                let l_flag   = true
                exit for
             end if
          else
             exit for
          end if
       end for
    end if

    #grava dados na tabela datkprtcpa
    if l_flag = false then
       whenever error continue
       execute pctc00m10012 using mr_ctc00m10.ramcod,
                                  mr_ctc00m10.c24astcod,
                                  mr_ctc00m10.cvnnum,
                                  mr_ctc00m10.c24prtseq,
                                  mr_ctc00m102.c24prtsit,
                                  mr_ctc00m102.caddat,
                                  mr_ctc00m102.cadhor,
                                  mr_ctc00m102.funmat,
                                  g_issk.usrtip,
                                  g_issk.empcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Problemas na inclusao da tabela DATKPRTCPA: ",sqlca.sqlcode," / ", sqlca.sqlerrd[2] sleep 2
          let l_flag = true
       end if
    end if

    if l_flag then
       rollback work
       error "Inclusao cancelada!"
       clear form
       let l_flag           = false
       let m_consulta_ativa = false
    else
       commit work
       error "Dados incluidos com sucesso!"
       let m_consulta_ativa = true
    end if
 end if

end function

#----------------------------------------#
function ctc00m10_entrada_dados(l_funcao)
#----------------------------------------#
#entrada dados para os campos ramo, assunto e convenio
#se ok chama a funcao para entrada de dados do campo tipo de informacao

 define l_funcao     char(11)

 define l_cpocod     like iddkdominio.cpocod,
        l_cponom     like iddkdominio.cponom,
        l_popup      smallint,
        l_count      smallint

 define l_par_pop record
                   lin       smallint,
                   col       smallint,
                   title     char(54),
                   coltit_1  char(10),
                   coltit_2  char(10),
                   tipcod    char(01),
                   com_sql   char(1000),
                   compl_sql char(200),
                   tipo      char(01)
                   end record

 define l_retorno   record
           erro      smallint,
           cod       char (011),
           dsc       char (040)
         end record

 let l_par_pop.lin      = 6
 let l_par_pop.col      = 2
 let l_par_pop.coltit_1 = ' '
 let l_par_pop.coltit_2 = ' '
 let l_par_pop.tipcod   = 'A'

 let int_flag = false
 let l_popup  = false

 if l_funcao <> 'modificacao' then
    input by name mr_ctc00m10.* without defaults

       before field ramcod
             let mr_ctc00m10.ramcod = 0
             let mr_ctc00m10.ramnom = 'TODOS'
             display by name mr_ctc00m10.ramcod attribute (reverse)
             display by name mr_ctc00m10.ramnom
         if l_funcao = 'inclusao' then
             let mr_ctc00m102.caddat = extend(current,year to day)
             let mr_ctc00m102.cadhor = extend(current,hour to minute)
             let mr_ctc00m102.funmat = g_issk.funmat
             let mr_ctc00m102.funnom = g_issk.funnom

             display by name mr_ctc00m102.caddat
             display by name mr_ctc00m102.cadhor
             display by name mr_ctc00m102.funmat
             display by name mr_ctc00m102.funnom
          end if

       after field ramcod
          display by name mr_ctc00m10.ramcod

          if mr_ctc00m10.ramcod = 0 then
             next field c24astcod
          end if

          if mr_ctc00m10.ramcod is null then
             let l_par_pop.tipo     = 'D'
             let l_par_pop.title    = 'R A M O'
             let l_par_pop.com_sql  = ' select ramcod,ramnom ',
                                       ' from gtakram  ',
                                      ' order by ramnom '
             call ofgrc001_popup(l_par_pop.*) returning l_retorno.*
             if l_retorno.erro <> 0 then
                next field ramcod
             end if
             let mr_ctc00m10.ramcod = l_retorno.cod
             let mr_ctc00m10.ramnom = l_retorno.dsc
             display by name mr_ctc00m10.ramcod
             display by name mr_ctc00m10.ramnom
          else
             open cctc00m10001 using mr_ctc00m10.ramcod

             whenever error continue
             fetch cctc00m10001 into mr_ctc00m10.ramnom
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   error 'Ramo invalido' sleep 2
                   next field ramcod
                else
                   error 'Erro Sql cctc00m10001: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                   let int_flag = true
                   exit input
                end if
             end if
             display by name mr_ctc00m10.ramcod
             display by name mr_ctc00m10.ramnom
          end if

       before field c24astcod
          display by name mr_ctc00m10.c24astcod attribute (reverse)
          let l_popup = true

       after field c24astcod
          display by name mr_ctc00m10.c24astcod

          if fgl_lastkey() = fgl_keyval("up") then
          else
             if l_funcao = 'seleciona' then
                if mr_ctc00m10.c24astcod is null then
                   next field cvnnum
                else
                   display by name mr_ctc00m10.c24astcod
                end if
             end if

             if mr_ctc00m10.c24astcod is null  then
                let l_par_pop.tipo     = 'D'
                let l_par_pop.title    = 'A S S U N T O'
                let l_par_pop.com_sql  = ' select c24astcod, c24astdes ',
                                          ' from datkassunto ',
                                         ' order by c24astdes '
                call ofgrc001_popup(l_par_pop.*) returning l_retorno.*
                if l_retorno.erro <> 0 then
                   next field c24astcod
                end if
                let mr_ctc00m10.c24astcod = l_retorno.cod
                let mr_ctc00m10.c24astdes = l_retorno.dsc
             end if

             open cctc00m10002 using mr_ctc00m10.c24astcod

             whenever error continue
             fetch cctc00m10002 into mr_ctc00m10.c24astdes
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   error 'Assunto invalido.' sleep 2
                   next field c24astcod
                else
                   error 'Erro Sql cctc00m10002: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                   let int_flag = true
                   exit input
                end if
             end if

          end if
          display by name mr_ctc00m10.c24astcod
          display by name mr_ctc00m10.c24astdes

       before field cvnnum
          let mr_ctc00m10.cvnnum = 0
          let mr_ctc00m10.cpodes = 'TODOS'
          display by name mr_ctc00m10.cvnnum  attribute (reverse)
          display by name mr_ctc00m10.cpodes

       after field cvnnum
          display by name mr_ctc00m10.cvnnum

          if fgl_lastkey() = fgl_keyval("up") then
          else
             if mr_ctc00m10.cvnnum = 0 then
                next field c24prtseq
             end if

             if mr_ctc00m10.cvnnum is null then
                let l_par_pop.tipo     = 'D'
                let l_par_pop.title    = 'C O N V E N I O'
                let l_par_pop.com_sql  = ' select cpocod, cpodes ',
                                          ' from datkdominio ',
                                         ' where cponom = "cvnnum" ',
                                         ' order by cpocod '
                call ofgrc001_popup(l_par_pop.*) returning l_retorno.*
                if l_retorno.erro <> 0 then
                   next field c24prtseq
                end if
                let mr_ctc00m10.cvnnum = l_retorno.cod
                let mr_ctc00m10.cpodes = l_retorno.dsc
             else
                let l_cponom = "cvnnum"
                open cctc00m10003 using mr_ctc00m10.cvnnum,
                                        l_cponom

                whenever error continue
                fetch cctc00m10003 into l_cpocod,
                                        mr_ctc00m10.cpodes
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                      error 'Convenio invalido.' sleep 2
                      next field cvnnum
                   else
                      error 'Erro Sql cctc00m10003: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                      let int_flag = true
                      exit input
                   end if
                end if
             end if
             close cctc00m10003
          end if
          display by name mr_ctc00m10.cvnnum 
          display by name mr_ctc00m10.cpodes

       before field c24prtseq
          display by name mr_ctc00m10.c24prtseq attribute (reverse)

          if l_funcao = 'inclusao' then
             open cctc00m10004 using mr_ctc00m10.ramcod,
                                     mr_ctc00m10.c24astcod,
                                     mr_ctc00m10.cvnnum

             whenever error continue
             fetch cctc00m10004 into mr_ctc00m10.c24prtseq
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> 100 then
                   error 'Erro Sql cctc00m10004: ',sqlca.sqlcode,' / ', sqlca.sqlerrd[2] sleep 2
                   let int_flag = true
                   exit input
                end if
             end if
             if mr_ctc00m10.c24prtseq is null then
                let mr_ctc00m10.c24prtseq = 0
             end if
             let mr_ctc00m10.c24prtseq = mr_ctc00m10.c24prtseq + 1
             display by name mr_ctc00m10.c24prtseq
             exit input
          end if

       after field c24prtseq
          display by name mr_ctc00m10.c24prtseq

          if fgl_lastkey() = fgl_keyval("up") then
          else
             if mr_ctc00m10.c24prtseq is null then
                exit input
             else
                display by name mr_ctc00m10.c24prtseq
                exit input
             end if
          end if

        on key (f5)
           if l_popup then
              let l_par_pop.tipo     = 'D'
              let l_par_pop.title    = 'A S S U N T O'
              let l_par_pop.com_sql  = ' select c24astcod, c24astdes ',
                                        ' from datkassunto ',
                                       ' order by c24astdes '
              call ofgrc001_popup(l_par_pop.*) returning l_retorno.*
              if l_retorno.erro <> 0 then
                 next field c24astcod
              end if
              let mr_ctc00m10.c24astcod = l_retorno.cod
              let mr_ctc00m10.c24astdes = l_retorno.dsc
          end if

       on key (f17, control-c, interrupt)
          let int_flag = true
          exit input
    end input
 end if

 if int_flag then
    let int_flag = false
    return false
 else
    if l_funcao = 'seleciona' then
       return true
    end if

    if l_funcao = 'inclusao' then
       open cctc00m10014 using  mr_ctc00m10.ramcod,
                                mr_ctc00m10.c24astcod,
                                mr_ctc00m10.cvnnum,
                                mr_ctc00m10.c24prtseq
       let l_count = 1
       foreach cctc00m10014 into am_ctc00m10[l_count].cpocod,
                                 am_ctc00m10[l_count].cpodes2,
                                 am_ctc00m10[l_count].c24prtinftip
          let l_count = l_count + 1
          if l_count > 100 then
             exit foreach
          end if
       end foreach
       close cctc00m10014
       let m_count = l_count
       let mr_ctc00m102.c24prtsit = "A"
    end if

    call ctc00m10_entrada_array()
    if int_flag then
       let int_flag = false
       return false
    end if
 end if

 return true

end function

#---------------------------------#
function ctc00m10_entrada_array()
#---------------------------------#
#entrada de dados para o campo tipo de informacao
#se ok chama entrada dados para os campos E/P, emp, codigo
define l_i     smallint,
       l_ok    smallint

 call set_count(m_count - 1)

 input array am_ctc00m10 without defaults from s_tela.*

    before row
       let m_arr_curr = arr_curr()
       let m_scr_line = scr_line()

    before field c24prtinftip
       if am_ctc00m10[m_arr_curr].c24prtinftip <> "X" then
          let am_ctc00m10[m_arr_curr].c24prtinftip = " "
       end if

       display am_ctc00m10[m_arr_curr].c24prtinftip to s_tela[m_scr_line].c24prtinftip attribute (reverse)

    after field c24prtinftip
       display am_ctc00m10[m_arr_curr].c24prtinftip to s_tela[m_scr_line].c24prtinftip

       if am_ctc00m10[m_arr_curr].cpodes2 is not null then
          if am_ctc00m10[m_arr_curr].c24prtinftip not matches '[Xx]' and
             am_ctc00m10[m_arr_curr].c24prtinftip <> ' ' then
             next field c24prtinftip
          end if
       end if

       if am_ctc00m10[m_arr_curr + 1].cpodes2 is null then
          if fgl_lastkey() = fgl_keyval('up') then
          else
             next field c24prtinftip
          end if
       end if

       display am_ctc00m10[m_arr_curr].c24prtinftip to s_tela[m_scr_line].c24prtinftip

    on key (f8,esc)
       for l_i = 1 to 100
           if am_ctc00m10[l_i].c24prtinftip matches '[Xx]' then
              let l_ok = true
              exit for
           end if
       end for
       if l_ok then
          exit input
       else
          error 'Tipo de informacao deve ser selecionado.' sleep 2
          next field c24prtinftip
       end if

    on key(f17,control-c,interrupt)
       let int_flag = true
       exit input

 end input

 if not int_flag then
    call ctc00m10_entrada_array_1()
 end if

end function

#----------------------------------#
function ctc00m10_entrada_array_1()
#----------------------------------#
#entrada dados para os campos E/P, emp, codigo
#se ok chama funcao para entrada de dados do campo emails externos
 define l_par_pop record
                   lin       smallint,
                   col       smallint,
                   title     char(54),
                   coltit_1  char(10),
                   coltit_2  char(10),
                   tipcod    char(01),
                   com_sql   char(1000),
                   compl_sql char(200),
                   tipo      char(01)
                   end record

 define l_count    smallint,
        l_i        smallint,
        l_ok       smallint

 define l_aux      integer

 define l_retorno   record
           erro      smallint,
           cod       char (011),
           dsc       char (040)
         end record

 let l_par_pop.lin      = 6
 let l_par_pop.col      = 2
 let l_par_pop.coltit_1 = ' '

 input array am_ctc00m101 without defaults from s_tela1.*

    before row
       let m_arr_curr_1 = arr_curr()
       let m_scr_line_1 = scr_line()


    before field emapager
       display am_ctc00m101[m_arr_curr_1].emapager to s_tela1[m_scr_line_1].emapager attribute (reverse)

    after field emapager
       display am_ctc00m101[m_arr_curr_1].emapager to s_tela1[m_scr_line_1].emapager

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("down")  then
       else
          if am_ctc00m101[m_arr_curr_1].emapager not matches '[EePp]' or
             am_ctc00m101[m_arr_curr_1].emapager is null then
             next field emapager
          end if
          display am_ctc00m101[m_arr_curr_1].emapager to s_tela1[m_scr_line_1].emapager
          if am_ctc00m101[m_arr_curr_1].emapager = "P" then
             let am_ctc00m101[m_arr_curr_1].empcod = 0
             display am_ctc00m101[m_arr_curr_1].empcod to s_tela1[m_scr_line_1].empcod
             next field codigo
          end if
       end if

    before field empcod
       let am_ctc00m101[m_arr_curr_1].empcod = 1
       display am_ctc00m101[m_arr_curr_1].empcod to s_tela1[m_scr_line_1].empcod attribute (reverse)

    after field empcod
       display am_ctc00m101[m_arr_curr_1].empcod to s_tela1[m_scr_line_1].empcod

       if fgl_lastkey() = fgl_keyval("up") then
       else
          open cctc00m10006 using am_ctc00m101[m_arr_curr_1].empcod

          whenever error continue
          fetch cctc00m10006
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
                error 'Empresa invalida' sleep 2
                next field empcod
             else
                error 'Erro Sql cctc00m10006: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                let int_flag = true
                exit input
             end if
          end if
       end if

       display am_ctc00m101[m_arr_curr_1].empcod to s_tela1[m_scr_line_1].empcod

    before field codigo
       display am_ctc00m101[m_arr_curr_1].codigo to s_tela1[m_scr_line_1].codigo attribute (reverse)

    after field codigo
       display am_ctc00m101[m_arr_curr_1].codigo to s_tela1[m_scr_line_1].codigo

       if fgl_lastkey() = fgl_keyval("up") then
          if am_ctc00m101[m_arr_curr_1].emapager is null or
             am_ctc00m101[m_arr_curr_1].emapager = "P" then
             next field emapager
          else
             next field empcod
          end if
       else
          if am_ctc00m101[m_arr_curr_1].emapager  = "E" then
             if am_ctc00m101[m_arr_curr_1].codigo is null then
                let l_par_pop.coltit_2 = ' '
                let l_par_pop.tipcod   = 'A'
                let l_par_pop.tipo     = 'E'
                let l_par_pop.title    = 'M A T R I C U L A'
                let l_par_pop.com_sql  = ' select funmat, funnom ',
                                           ' from isskfunc ',
                                          ' where empcod = " ' , am_ctc00m101[m_arr_curr_1].empcod, ' " ' ,
                                            ' and usrtip = "F" ',
                                            ' and funnom '

                let l_par_pop.compl_sql =   ' order by funnom '

                call ofgrc001_popup(l_par_pop.*) returning l_retorno.*
                if l_retorno.erro <> 0 then
                   next field codigo
                end if
                let am_ctc00m101[m_arr_curr_1].codigo   = l_retorno.cod
                let am_ctc00m101[m_arr_curr_1].destinat = l_retorno.dsc
             else
                open cctc00m10007 using am_ctc00m101[m_arr_curr_1].codigo,
                                        am_ctc00m101[m_arr_curr_1].empcod

                whenever error continue
                fetch cctc00m10007 into am_ctc00m101[m_arr_curr_1].destinat
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode =  100 then
                      error 'Matricula invalida.' sleep 2
                      next field codigo
                   else
                      error 'Erro Sql cctc00m10007: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                      let int_flag = true
                      exit input
                   end if
                end if
                close cctc00m10007
             end if
          else
             if am_ctc00m101[m_arr_curr_1].codigo is null then
                let l_par_pop.coltit_2 = 'Nr.Pager: '
                let l_par_pop.tipcod   = 'N'
                let l_par_pop.tipo     = '1'
                let l_par_pop.title    = 'P A G E R'
                let l_par_pop.com_sql  = ' select pgrnum, ustcod ',
                                           ' from htlrust ',
                                          ' where pgrnum is not null ' ,
                                          '   and pgrnum > 0 ',
                                            ' and pgrnum '
                let l_par_pop.compl_sql = ' order by pgrnum '

                call ofgrc001_popup(l_par_pop.*) returning l_retorno.erro,
                                                           l_aux,
                                                           l_retorno.dsc
                if l_retorno.erro <> 0 then
                   next field codigo
                end if
                let am_ctc00m101[m_arr_curr_1].codigo   = l_retorno.dsc
                let am_ctc00m101[m_arr_curr_1].destinat = l_aux
             else
                open cctc00m10008 using am_ctc00m101[m_arr_curr_1].codigo
                whenever error continue
                fetch cctc00m10008 into am_ctc00m101[m_arr_curr_1].destinat
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                      error 'Codigo invalido.' sleep 2
                      next field codigo
                   else
                      error 'Erro Sql cctc00m10008: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                      let int_flag = true
                      exit input
                   end if
                end if
                close cctc00m10008
             end if
          end if
       end if

       if m_arr_curr_1 > 1 then
          for l_count = 1 to (m_arr_curr_1 - 1)
              if am_ctc00m101[m_arr_curr_1].codigo = am_ctc00m101[m_arr_curr_1 - l_count].codigo  and
                 am_ctc00m101[m_arr_curr_1].emapager = am_ctc00m101[m_arr_curr_1 - l_count].emapager then
                 error 'Registro ja cadastrado. '
                 next field codigo
              end if
          end for
       end if

       display am_ctc00m101[m_arr_curr_1].codigo   to s_tela1[m_scr_line_1].codigo
       display am_ctc00m101[m_arr_curr_1].destinat to s_tela1[m_scr_line_1].destinat

    on key (f8,esc)
       for l_i = 1 to 30
           if am_ctc00m101[l_i].codigo is not null then
              let l_ok = true
              exit for
           end if
       end for
       if l_ok then
          exit input
       else
          error 'Preenchimento obrigatorio.' sleep 2
          next field codigo
       end if

    on key(f17,control-c,interrupt)
       let int_flag = true
       exit input

 end input

 if not int_flag then
    call ctc00m10_entrada_array_2()
 end if

end function

#----------------------------------#
function ctc00m10_entrada_array_2()
#----------------------------------#
#entrada dados para o campo emails externos
#se ok chama funcao para entrada de dados dos campos situacao e Ult. Atualizacao
define l_count   smallint

let int_flag = false

 input array am_ctc00m102 without defaults from s_tela2.*

    before row
       let m_arr_curr_2 = arr_curr()
       let m_scr_line_2 = scr_line()

    before field maicod
       display am_ctc00m102[m_arr_curr_2].maicod to s_tela2[m_scr_line_2].maicod attribute (reverse)

    after field maicod
       display am_ctc00m102[m_arr_curr_2].maicod to s_tela2[m_scr_line_2].maicod

       if m_arr_curr_2 > 1 then
          for l_count = 1 to (m_arr_curr_2 - 1)
              if am_ctc00m102[m_arr_curr_2].maicod = am_ctc00m102[m_arr_curr_2 - l_count].maicod  then
                 error 'Registro ja cadastrado. '
                 next field maicod
              end if
          end for
       end if


    on key (f8,esc)
       exit input

    on key(f17,control-c,interrupt)
       let int_flag = true
       exit input

 end input

 if not int_flag then
    call ctc00m10_entrada_dados_3()
 end if

end function

#----------------------------------#
function ctc00m10_entrada_dados_3()
#----------------------------------#
#entrada dados para campos situacao e Ult. Atualizacao
#se ok retorna true para inserir nas tabelas correspondentes
define l_funcao   char(11)

 let int_flag = false

 input by name mr_ctc00m102.* without defaults

    before field c24prtsit
       if mr_ctc00m102.c24prtsit is null then
          let mr_ctc00m102.c24prtsit = "A"
       end if

       display by name mr_ctc00m102.c24prtsit attribute (reverse)

    after field c24prtsit
       display by name mr_ctc00m102.c24prtsit

       if mr_ctc00m102.c24prtsit is null or
          mr_ctc00m102.c24prtsit not matches '[AaCc]' then
          next field c24prtsit
       end if
       display by name mr_ctc00m102.c24prtsit

       if l_funcao = 'modificacao' then
          let mr_ctc00m102.caddat = today
          let mr_ctc00m102.cadhor = extend(current,hour to minute)
          let mr_ctc00m102.funmat = g_issk.funmat
          let mr_ctc00m102.funnom = g_issk.funnom
          display by name mr_ctc00m102.caddat
          display by name mr_ctc00m102.cadhor
          display by name mr_ctc00m102.funmat
          display by name mr_ctc00m102.funnom
       end if

    on key (f8,esc)

       display by name mr_ctc00m102.c24prtsit

       if mr_ctc00m102.c24prtsit is null or
          mr_ctc00m102.c24prtsit not matches '[AaCc]' then
          next field c24prtsit
       else
          exit input
       end if

    on key(f17,control-c,interrupt)
       let int_flag = true
       exit input

 end input

end function

#------------------------------#
 function ctc00m10_selecionar()
#------------------------------#
 define l_consulta     char(01),
        l_funcao       char(11),
        l_aux1         smallint,
        l_aux2         smallint,
        l_aux3         smallint,
        l_aux4         smallint

 define l_flag         smallint

 let int_flag = false
 let l_funcao = 'seleciona'

 initialize mr_ctc00m10.*   to null
 initialize mr_ctc00m102.*  to null
 initialize am_ctc00m101    to null
 initialize am_ctc00m102    to null

 if ctc00m10_entrada_dados(l_funcao) then

   if mr_ctc00m10.ramcod is null then
      let l_aux1 = 1
   else
      let l_aux1 = 0
   end if
   if mr_ctc00m10.c24astcod is null then
      let l_aux2 = 1
   else
      let l_aux2 = 0
   end if
   if mr_ctc00m10.cvnnum is null then
      let l_aux3 = 1
   else
      let l_aux3 = 0
   end if
   if mr_ctc00m10.c24prtseq is null then
      let l_aux4 = 1
   else
      let l_aux4 = 0
   end if

   open cctc00m10013 using l_aux1, mr_ctc00m10.ramcod,
                           l_aux2, mr_ctc00m10.c24astcod,
                           l_aux3, mr_ctc00m10.cvnnum,
                           l_aux4, mr_ctc00m10.c24prtseq

   let l_consulta = "P"
   if ctc00m10_busca_dados(l_consulta) then
      let m_consulta_ativa = true
   else
      if l_flag = true then
         error 'Selecao cancelada!' sleep 2
      else
         error "Nao ha registros na selecao efetuada!! " sleep 2
      end if
   end if

 end if

 if int_flag then
    error "Selecao cancelada!" sleep 2
    clear form
    let int_flag         = false
    let m_consulta_ativa = false
 end if

end function

#---------------------------------------#
function ctc00m10_busca_dados(l_consulta)
#---------------------------------------#
define l_consulta   char(01),
       l_count      smallint,
       l_cademp     like datkprtcpa.cademp

define l_cpocod     like iddkdominio.cpocod,
       l_cponom     like iddkdominio.cponom,
       l_cpodes     like iddkdominio.cpodes

define l_flag       smallint,
       l_ix1        smallint,
       l_aux        smallint


 if l_consulta = "M" then
    let l_aux = 0
    open cctc00m10013 using l_aux, mr_ctc00m10.ramcod,
                            l_aux, mr_ctc00m10.c24astcod,
                            l_aux, mr_ctc00m10.cvnnum,
                            l_aux, mr_ctc00m10.c24prtseq
 end if

 whenever error continue
 if l_consulta <> "A" then
    whenever error continue
    fetch next cctc00m10013 into mr_ctc00m10.ramcod,
                                 mr_ctc00m10.ramnom,
                                 mr_ctc00m10.c24astcod,
                                 mr_ctc00m10.c24astdes,
                                 mr_ctc00m10.cvnnum,
                                 mr_ctc00m10.cpodes,
                                 mr_ctc00m10.c24prtseq,
                                 mr_ctc00m102.c24prtsit,
                                 mr_ctc00m102.caddat,
                                 mr_ctc00m102.cadhor,
                                 mr_ctc00m102.funmat,
                                 l_cademp
    whenever error stop

    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          return false
       else
          error "ERRO SQL - cctc00m10013: ",sqlca.sqlcode," / ",sqlca.sqlerrd[2] sleep 2
          return false
       end if
    else
       initialize am_ctc00m101    to null
       initialize am_ctc00m102    to null

       open cctc00m10007 using mr_ctc00m102.funmat,     #utilizado pra busca o nome da matricula
                               l_cademp                #cadastrada na tabela datkprtcpa

       whenever error continue
       fetch cctc00m10007 into mr_ctc00m102.funnom
       whenever error stop
       if sqlca.sqlcode < 0 then
          error 'Erro 3 Sql cctc00m10007: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          return false
       end if
       close cctc00m10007


       open cctc00m10014 using  mr_ctc00m10.ramcod,
                                mr_ctc00m10.c24astcod,
                                mr_ctc00m10.cvnnum,
                                mr_ctc00m10.c24prtseq

       let l_count = 1

       foreach cctc00m10014 into am_ctc00m10[l_count].cpocod,
                                 am_ctc00m10[l_count].cpodes2,
                                 am_ctc00m10[l_count].c24prtinftip
          let l_count = l_count + 1
          if l_count > 100 then
             error 'Limite de array excedido'
             exit foreach
          end if
       end foreach
       close cctc00m10014

       let m_count = l_count

       open cctc00m10015 using mr_ctc00m10.ramcod,
                               mr_ctc00m10.c24astcod,
                               mr_ctc00m10.cvnnum,
                               mr_ctc00m10.c24prtseq

       let l_count = 1

          foreach cctc00m10015 into am_ctc00m103[l_count].ustcod,
                                    am_ctc00m101[l_count].empcod,
                                    am_ctc00m103[l_count].funmat

             if am_ctc00m101[l_count].empcod <> 0 then
                let am_ctc00m101[l_count].emapager = 'E'
                let am_ctc00m101[l_count].codigo = am_ctc00m103[l_count].funmat
                open cctc00m10007 using am_ctc00m101[l_count].codigo,    #utilizado pra busca o nome da matricula
                                        am_ctc00m101[l_count].empcod     #cadastrada na tabela datkprtdst
                whenever error continue
                fetch cctc00m10007 into am_ctc00m101[l_count].destinat
                whenever error stop
                if sqlca.sqlcode < 0 then
                   error 'Erro 2 Sql cctc00m10007: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                   let l_flag = true
                   exit foreach
                end if
                close cctc00m10007
             else
                let am_ctc00m101[l_count].emapager = 'P'
                let am_ctc00m101[l_count].codigo = am_ctc00m103[l_count].ustcod
                open cctc00m10008 using am_ctc00m101[l_count].codigo
                whenever error continue
                fetch cctc00m10008 into am_ctc00m101[l_count].destinat
                whenever error stop
                if sqlca.sqlcode < 0 then
                   error 'Erro Sql cctc00m10008: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                   let l_flag = true
                   exit foreach
                end if
                close cctc00m10008
             end if

             let l_count = l_count + 1

             if l_count > 100 then
                error 'Limite de array excedido'
                exit foreach
             end if
          end foreach
       close cctc00m10015

       let m_count1 = l_count

       open cctc00m10024 using mr_ctc00m10.ramcod,
                               mr_ctc00m10.c24astcod,
                               mr_ctc00m10.cvnnum,
                               mr_ctc00m10.c24prtseq

       let l_count = 1

          foreach cctc00m10024 into am_ctc00m102[l_count].maicod

             let l_count = l_count + 1

             if l_count > 100 then
                error 'Limite de array excedido'
                exit foreach
             end if
          end foreach
       let m_count2 = l_count
       close cctc00m10024
    end if
 else
    whenever error continue
    fetch previous cctc00m10013 into mr_ctc00m10.ramcod,
                                     mr_ctc00m10.ramnom,
                                     mr_ctc00m10.c24astcod,
                                     mr_ctc00m10.c24astdes,
                                     mr_ctc00m10.cvnnum,
                                     mr_ctc00m10.cpodes,
                                     mr_ctc00m10.c24prtseq,
                                     mr_ctc00m102.c24prtsit,
                                     mr_ctc00m102.caddat,
                                     mr_ctc00m102.cadhor,
                                     mr_ctc00m102.funmat,
                                     l_cademp
    whenever error stop

    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          return false
       else
          error "ERRO SQL - cctc00m10013: ",sqlca.sqlcode," / ",sqlca.sqlerrd[2] sleep 2
          return false
       end if
    else
       initialize am_ctc00m101    to null
       initialize am_ctc00m102    to null

       open cctc00m10007 using mr_ctc00m102.funmat,     #utilizado pra busca o nome da matricula
                               l_cademp                #cadastrada na tabela datkprtcpa

       whenever error continue
       fetch cctc00m10007 into mr_ctc00m102.funnom
       whenever error stop
       if sqlca.sqlcode < 0 then
          error 'Erro 3 Sql cctc00m10007: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          return false
       end if
       close cctc00m10007

       open cctc00m10014 using  mr_ctc00m10.ramcod,
                                mr_ctc00m10.c24astcod,
                                mr_ctc00m10.cvnnum,
                                mr_ctc00m10.c24prtseq

       let l_count = 1

       foreach cctc00m10014 into am_ctc00m10[l_count].cpocod,
                                 am_ctc00m10[l_count].cpodes2,
                                 am_ctc00m10[l_count].c24prtinftip
          let l_count = l_count + 1
          if l_count > 100 then
             error 'Limite de array excedido'
             exit foreach
          end if
       end foreach
       close cctc00m10014

       let m_count = l_count

       open cctc00m10015 using mr_ctc00m10.ramcod,
                               mr_ctc00m10.c24astcod,
                               mr_ctc00m10.cvnnum,
                               mr_ctc00m10.c24prtseq

       let l_count = 1

          foreach cctc00m10015 into am_ctc00m103[l_count].ustcod,
                                    am_ctc00m101[l_count].empcod,
                                    am_ctc00m103[l_count].funmat

             if am_ctc00m101[l_count].empcod <> 0 then
                let am_ctc00m101[l_count].emapager = 'E'
                let am_ctc00m101[l_count].codigo = am_ctc00m103[l_count].funmat
                open cctc00m10007 using am_ctc00m101[l_count].codigo,    #utilizado pra busca o nome da matricula
                                        am_ctc00m101[l_count].empcod     #cadastrada na tabela datkprtdst

                whenever error continue
                fetch cctc00m10007 into am_ctc00m101[l_count].destinat
                whenever error stop
                if sqlca.sqlcode < 0 then
                   error 'Erro 2 Sql cctc00m10007: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                   let l_flag = true
                   exit foreach
                end if
                close cctc00m10007
             else
                let am_ctc00m101[l_count].emapager = 'P'
                open cctc00m10008 using am_ctc00m101[l_count].codigo

                whenever error continue
                fetch cctc00m10008 into am_ctc00m101[l_count].destinat
                whenever error stop
                if sqlca.sqlcode < 0 then
                   error 'Erro Sql cctc00m10008: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                   let l_flag = true
                   exit foreach
                end if
                close cctc00m10008
             end if

             let l_count = l_count + 1

             if l_count > 100 then
                error 'Limite de array excedido'
                exit foreach
             end if
          end foreach
       close cctc00m10015
       let m_count1 = l_count

       open cctc00m10024 using mr_ctc00m10.ramcod,
                               mr_ctc00m10.c24astcod,
                               mr_ctc00m10.cvnnum,
                               mr_ctc00m10.c24prtseq

       let l_count = 1

          foreach cctc00m10024 into am_ctc00m102[l_count].maicod

             let l_count = l_count + 1

             if l_count > 100 then
                error 'Limite de array excedido'
                exit foreach
             end if
          end foreach
       close cctc00m10024
       let m_count2 = l_count
    end if

 end if
 whenever error stop

 if l_flag = true then
    return false
 end if

 display by name mr_ctc00m10.ramcod
 if mr_ctc00m10.ramcod = 0 then
    let mr_ctc00m10.ramnom = 'TODOS'
 end if
 display by name mr_ctc00m10.ramnom
 display by name mr_ctc00m10.c24astcod
 display by name mr_ctc00m10.c24astdes
 display by name mr_ctc00m10.cvnnum 
 if mr_ctc00m10.cvnnum = 0 then
    let mr_ctc00m10.cpodes = 'TODOS'
 end if
 display by name mr_ctc00m10.cpodes
 display by name mr_ctc00m10.c24prtseq
 display by name mr_ctc00m102.c24prtsit
 display by name mr_ctc00m102.caddat
 display by name mr_ctc00m102.cadhor
 display by name mr_ctc00m102.funmat
 display by name mr_ctc00m102.funnom

#  call set_count(l_count - 1)

  for l_ix1 = 1 to 4 #qtd de linhas na tela array de cima
      display am_ctc00m10[l_ix1].c24prtinftip to s_tela[l_ix1].c24prtinftip
      display am_ctc00m10[l_ix1].cpodes2      to s_tela[l_ix1].cpodes2
      display am_ctc00m101[l_ix1].emapager    to s_tela1[l_ix1].emapager
      display am_ctc00m101[l_ix1].empcod      to s_tela1[l_ix1].empcod
      display am_ctc00m101[l_ix1].codigo      to s_tela1[l_ix1].codigo
      display am_ctc00m101[l_ix1].destinat    to s_tela1[l_ix1].destinat
  end for

  for l_count = 1 to 2 #qtd de linhas na tela array de baixo
      display am_ctc00m102[l_count].maicod to s_tela2[l_count].maicod
  end for

  return true

end function

#----------------------------#
function ctc00m10_excluir()
#----------------------------#

 define l_resp      char(01)

  if m_consulta_ativa = true then

     prompt "Confirma exclusao (S/N) ? " for char l_resp
     let l_resp = upshift(l_resp)
     if l_resp = "S" then
        begin work

        whenever error continue
        execute pctc00m10016 using mr_ctc00m10.ramcod,
                                   mr_ctc00m10.c24astcod,
                                   mr_ctc00m10.cvnnum,
                                   mr_ctc00m10.c24prtseq
        whenever error stop
        if sqlca.sqlcode <> 0 then
           rollback work
           error "Problemas na exclusao da tabela DATKPRTINFTIP.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
           clear form
           return false
        end if

        whenever error continue
        execute pctc00m10017 using mr_ctc00m10.ramcod,
                                   mr_ctc00m10.c24astcod,
                                   mr_ctc00m10.cvnnum,
                                   mr_ctc00m10.c24prtseq
        whenever error stop
        if sqlca.sqlcode <> 0 then
           rollback work
           error "Problemas na exclusao da tabela DATKPRTDST.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
           clear form
           return false
        end if

        whenever error continue
        execute pctc00m10018 using mr_ctc00m10.ramcod,
                                   mr_ctc00m10.c24astcod,
                                   mr_ctc00m10.cvnnum,
                                   mr_ctc00m10.c24prtseq
        whenever error stop
        if sqlca.sqlcode <> 0 then
           rollback work
           error "Problemas na exclusao da tabela DATKPRTEXTMAI.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
           clear form
           return false
        end if

        whenever error continue
        execute pctc00m10019 using mr_ctc00m10.ramcod,
                                   mr_ctc00m10.c24astcod,
                                   mr_ctc00m10.cvnnum,
                                   mr_ctc00m10.c24prtseq
        whenever error stop
        if sqlca.sqlcode <> 0 then
           rollback work
           error "Problemas na exclusao da tabela DATKPRTCPA.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
           clear form
           return false
        else
           commit work
           error "Exclusao efetuada com sucesso." sleep 2
           let m_consulta_ativa = false
           clear form
        end if
     else
        error "Exclusao cancelada! "
        let m_consulta_ativa = false
        clear form
        return false
     end if
  else
     error "Consulte previamente para excluir! "
  end if

  if int_flag then
     let int_flag = false
     let m_consulta_ativa = false
     return false
  else
     return true
  end if

end function

#----------------------------#
function ctc00m10_modificar()
#----------------------------#
 define l_funcao   char(11)
 define l_i        smallint,
        l_j        smallint,
        l_l        smallint,
        l_count    smallint

 define l_flag     smallint,
        l_consulta char(01)
 define l_ustcod   like datkprtdst.ustcod,
        l_usrtip   like datkprtdst.usrtip

 let l_consulta = "M"
 call ctc00m10_busca_dados(l_consulta) returning l_flag

 let l_flag    = false
 let int_flag  = false
 let l_funcao = 'modificacao'

 if ctc00m10_entrada_dados(l_funcao) then
    let l_flag    = false
    let int_flag  = false

    begin work

    whenever error continue
    execute pctc00m10016 using mr_ctc00m10.ramcod,
                               mr_ctc00m10.c24astcod,
                               mr_ctc00m10.cvnnum,
                               mr_ctc00m10.c24prtseq
    whenever error stop
    if sqlca.sqlcode <> 0 then
       error "Problemas na modificacao (1) da tabela DATKPRTINFTIP.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
       clear form
       let l_flag = true
       let int_flag = true
    end if

    for l_i = 1 to 100
        if am_ctc00m10[l_i].c24prtinftip = 'X' or
           am_ctc00m10[l_i].c24prtinftip = 'x' then
           whenever error continue
           execute pctc00m10009 using mr_ctc00m10.ramcod,
                                      mr_ctc00m10.c24astcod,
                                      mr_ctc00m10.cvnnum,
                                      mr_ctc00m10.c24prtseq,
                                      am_ctc00m10[l_i].cpocod
           whenever error stop
           if sqlca.sqlcode <> 0 then
              error "Problemas na modificacao da tabela DATKPRTINFTIP.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
              clear form
              let l_flag = true
              let int_flag = true
              exit for
           end if
        end if
    end for

    if l_flag = false then
       whenever error continue
       execute pctc00m10017 using mr_ctc00m10.ramcod,
                                  mr_ctc00m10.c24astcod,
                                  mr_ctc00m10.cvnnum,
                                  mr_ctc00m10.c24prtseq
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error 'Problemas na modificacao (3) da tabela DATKPRTDST: ',sqlca.sqlcode,' / ', sqlca.sqlerrd[2] sleep 2
          let l_flag   = true
       end if
    end if

    if l_flag = false then
       for l_j = 1 to 100
          if am_ctc00m101[l_j].emapager = "E" then
             let l_ustcod = 0
             let l_usrtip = 'F'
             if not (am_ctc00m101[l_j].codigo is null) then                
                whenever error continue                                                                                
                execute pctc00m10010 using mr_ctc00m10.ramcod,
                                           mr_ctc00m10.c24astcod,
                                           mr_ctc00m10.cvnnum,
                                           mr_ctc00m10.c24prtseq,
                                           l_ustcod,
                                           am_ctc00m101[l_j].empcod,
                                           l_usrtip,
                                           am_ctc00m101[l_j].codigo
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   error "Problemas na modificacao da tabela DATKPRTDST.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
                   clear form
                   let l_flag = true
                   let int_flag = true
                   exit for
                end if
             end if
          else
             if am_ctc00m101[l_j].emapager = "P" then
                let l_ustcod = 0
                let l_usrtip = 'X'
                if not (am_ctc00m101[l_j].codigo is null) then
                   whenever error continue
                   execute pctc00m10010 using mr_ctc00m10.ramcod,
                                              mr_ctc00m10.c24astcod,
                                              mr_ctc00m10.cvnnum,
                                              mr_ctc00m10.c24prtseq,
                                              am_ctc00m101[l_j].codigo,
                                              l_ustcod,  #referente ao campo empcod, usada esta variavel pois valor eh fixo
                                              l_usrtip,
                                              l_ustcod   #referente ao campo funmat, usada esta variavel pois valor eh fixo
                   whenever error stop
                   if sqlca.sqlcode <> 0 then
                      error "Problemas na modificacao da tabela DATKPRTDST.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
                      clear form
                      let l_flag = true
                      let int_flag = true
                      exit for
                   end if
                end if
             end if
          end if
       end for
    end if


    if l_flag = false then
       whenever error continue
       execute pctc00m10018 using mr_ctc00m10.ramcod,
                                  mr_ctc00m10.c24astcod,
                                  mr_ctc00m10.cvnnum,
                                  mr_ctc00m10.c24prtseq
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Problemas na modificacao (E) da tabela DATKPRTEXTMAI.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
          let l_flag   = true
       end if
    end if

    if l_flag = false then
       for l_l = 1 to 100
          if am_ctc00m102[l_l].maicod is not null then
             whenever error continue
             execute pctc00m10011 using mr_ctc00m10.ramcod,
                                        mr_ctc00m10.c24astcod,
                                        mr_ctc00m10.cvnnum,
                                        mr_ctc00m10.c24prtseq,
                                        am_ctc00m102[l_l].maicod
             whenever error stop
             if sqlca.sqlcode <> 0 then
                error "Problemas na modificacao da tabela DATKPRTEXTMAI.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
                clear form
                let l_flag = true
                let int_flag = true
                exit for
             end if
          end if
       end for
    end if

    if l_flag = false then
       let mr_ctc00m102.caddat = today
       let mr_ctc00m102.cadhor = extend(current,hour to minute)

       whenever error continue
       execute pctc00m10023 using mr_ctc00m102.c24prtsit,
                                  mr_ctc00m102.caddat,
                                  mr_ctc00m102.cadhor,
                                  g_issk.funmat,
                                  g_issk.usrtip,
                                  g_issk.empcod,
                                  mr_ctc00m10.ramcod,
                                  mr_ctc00m10.c24astcod,
                                  mr_ctc00m10.cvnnum,
                                  mr_ctc00m10.c24prtseq
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Problemas na modificacao da tabela DATKPRTCPA.", sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] sleep 2
          clear form
          let l_flag = true
          let int_flag = true
       end if
    end if

    if l_flag then
       rollback work
       error 'Modificacao cancelada!'
       let m_consulta_ativa = false
       let int_flag = false
       let l_flag = false
       clear form
       return false
    else
       commit work
       error "Modificacao efetuada com sucesso." sleep 2
       let m_consulta_ativa = true
       return true
    end if
 else
    let int_flag = true
 end if

 return false

end function
