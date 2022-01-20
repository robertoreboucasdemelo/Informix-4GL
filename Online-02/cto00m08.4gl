#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: PSS - PortoSeguro Servicos                                #
# Modulo.........: cto00m08                                                  #
# Objetivo.......: Popup das Naturezas do PSS                                #
# Analista Resp. : Roberto Reboucas                                          #
# PSI            : 218545                                                    #
#............................................................................#
# Desenvolvimento:                                                           #
# Liberacao      : 22/04/2010                                                #
#............................................................................#


globals "/homedsa/projetos/geral/globals/glct.4gl"


define a_cto00m08 array[500] of record
       socntzdes like datksocntz.socntzdes ,
       socntzcod like datksocntz.socntzcod
end record

define m_prep_sql smallint

#---------------------------------------------------------------
function cto00m08_prepare()
#---------------------------------------------------------------

 define l_sql char(2000)
 let l_sql = "select socntzgrpcod " ,
             "from datrempgrp " ,
             "where empcod = ?" ,
             "and c24astcod = ?"
 prepare pcto00m08001 from l_sql
 declare ccto00m08001 cursor for pcto00m08001
 let l_sql = "select b.socntzdes, b.socntzcod, a.socntzgrpcod ",
             "from datrgrpntz a, datksocntz b , datrempgrp c ",
             "where a.socntzcod = b.socntzcod ",
             "and  a.socntzgrpcod = c.socntzgrpcod ",
             "and b.socntzstt    = 'A'",
             "and c.empcod = ?" ,
             "and c.c24astcod = ?" ,
             "order by b.socntzdes"
 prepare pcto00m08003 from l_sql
 declare ccto00m08003 cursor for pcto00m08003
 let l_sql = "select socntzgrpcod ",
             "from datksocntz ",
             "where socntzcod = ? "
 prepare pcto00m08004 from l_sql
 declare ccto00m08004 cursor for pcto00m08004
 let l_sql = "select a.socntzdes, b.socntzgrpcod ",
             "from datksocntz a, datrgrpntz b, datrempgrp c ",
             "where a.socntzcod = b.socntzcod ",
             "and b.socntzgrpcod = c.socntzgrpcod ",
             "and a.socntzcod = ?  ",
             "and a.socntzstt    = ? ",
             "and c.empcod = ? " ,
             "and c.c24astcod = ? "
 prepare pcto00m08005 from l_sql
 declare ccto00m08005 cursor for pcto00m08005
 let l_sql = "select socntzdes, socntzgrpcod "
            ,"  from datksocntz    "
            ," where socntzcod = ? "
            ,"   and socntzstt = ? "
 prepare pcto00m08006 from l_sql
 declare ccto00m08006 cursor for pcto00m08006
 let m_prep_sql = true

end function

#------------------------------------------------------------------------------
function cto00m08_cria_temp()
#------------------------------------------------------------------------------
 call cto00m08_drop_temp()
 whenever error continue
      create temp table cto00m08_temp(socntzdes    char(50)    ,
                                      socntzcod    integer ) with no log
  whenever error stop
      if sqlca.sqlcode <> 0  then
	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        call cto00m08_drop_temp()
	  end if
	 return false
     end if
     return true
end function
#------------------------------------------------------------------------------
function cto00m08_drop_temp()
#------------------------------------------------------------------------------
    whenever error continue
        drop table cto00m08_temp
    whenever error stop
    return
end function
#--------------------------------------------
function cto00m08_prep_temp()
#--------------------------------------------
    define l_sql char(500)
    let l_sql = "select * from " ,
                "cto00m08_temp " ,
                "order by 1    "
    prepare pcto00m08002 from l_sql
    declare ccto00m08002 cursor for pcto00m08002
    let l_sql = 'insert into cto00m08_temp'
	     , ' values(?,?)'
    prepare p_insert from l_sql
end function


#---------------------------------------------------------------
function cto00m08_natureza_pss(lr_param)
#---------------------------------------------------------------
define lr_param record
   tipo      smallint                   , # 1-Laudo Original 2-Laudo Multiplo
   c24astcod like datmligacao.c24astcod ,
   socntzcod like datksocntz.socntzcod
end record
define lr_retorno  record
       resultado    integer                     ,
       mensagem     char(200)                   ,
       qtd          integer                     ,
       socntzcod    like datksocntz.socntzcod   ,
       socntzdes    like datksocntz.socntzdes   ,
       socntzgrpcod like datksocntz.socntzgrpcod,
       ntzcod       like datksocntz.socntzcod
end record
define lr_cota record
       socntzgrpcod_ori  like datksocntz.socntzgrpcod,
       socntzgrpcod_mul  like datksocntz.socntzgrpcod
end record

define l_index integer
define arr_aux integer
initialize lr_retorno.*,
           lr_cota.*     to null

for l_index  =  1  to  500
    initialize  a_cto00m08[l_index].* to  null
end  for
let l_index              = null
let lr_retorno.resultado = 0
let arr_aux              = 0
  if not cto00m08_cria_temp() then
      error  "Erro na Criacao da Tabela Temporaria!"
      return lr_retorno.ntzcod
  end if
  if m_prep_sql is null or
     m_prep_sql <> true then
     call cto00m08_prepare()
  end if
  call cto00m08_prep_temp()
  # Verifica se e Laudo Multiplo
  if lr_param.tipo = 2              and
     lr_param.socntzcod is not null then
     call cto00m08_recupera_grupo_cota(lr_param.socntzcod)
     returning lr_cota.socntzgrpcod_ori
  end if
  if g_pss.psscntcod is not null then
    call pss01g00_consulta_servicos(g_pss.psscntcod,
                                    lr_param.c24astcod)
    returning lr_retorno.resultado ,
              lr_retorno.mensagem  ,
              lr_retorno.qtd
    if lr_retorno.resultado <> 0 then
       error lr_retorno.mensagem
    else
       for l_index  =  1  to lr_retorno.qtd
           if lr_param.tipo = 2              and
              lr_param.socntzcod is not null then
              call cto00m08_recupera_grupo_cota(g_pss_natureza[l_index].socntzcod)
              returning lr_cota.socntzgrpcod_mul
              if lr_cota.socntzgrpcod_ori = lr_cota.socntzgrpcod_mul then
                 # Insere na temporaria Multiplo
                 whenever error continue
                    execute p_insert using g_pss_natureza[l_index].socntzdes,
                                           g_pss_natureza[l_index].socntzcod
                 whenever error stop
              end if
           else
                 # Insere na temporaria Original
                 whenever error continue
                    execute p_insert using g_pss_natureza[l_index].socntzdes,
                                           g_pss_natureza[l_index].socntzcod
                 whenever error stop
           end if
           let arr_aux = arr_aux + 1
           if arr_aux > 500  then
              error " Limite excedido. Foram encontradas mais de 500 naturezas!"
              exit for
           end if
       end for
    end if
   else
       # Sem Documento
       whenever error continue
       open ccto00m08001 using g_documento.ciaempcod ,
                               lr_param.c24astcod
       fetch ccto00m08001 into lr_retorno.socntzgrpcod
       whenever error stop
       if lr_retorno.socntzgrpcod is not null then
           whenever error continue
           open ccto00m08003 using g_documento.ciaempcod ,
                                   lr_param.c24astcod
           whenever error stop
           foreach ccto00m08003 into lr_retorno.socntzdes    ,
                                     lr_retorno.socntzcod    ,
                                     lr_retorno.socntzgrpcod
             if lr_param.tipo = 2              and
                lr_param.socntzcod is not null then
                call cto00m08_recupera_grupo_cota(lr_retorno.socntzcod)
                returning lr_cota.socntzgrpcod_mul
                if lr_cota.socntzgrpcod_ori = lr_cota.socntzgrpcod_mul then
                   # Insere na temporaria Multiplo
                   whenever error continue
                      execute p_insert using lr_retorno.socntzdes,
                                             lr_retorno.socntzcod
                   whenever error stop
                end if
             else
                 # Insere na temporaria Original
                 whenever error continue
                    execute p_insert using lr_retorno.socntzdes ,
                                           lr_retorno.socntzcod
                 whenever error stop
             end if
             let arr_aux = arr_aux + 1
             if arr_aux > 500  then
                error " Limite excedido. Foram encontradas mais de 500 naturezas!"
                exit foreach
             end if
           end foreach
      else
         error "Assunto sem Grupo de Natureza Especificada"
      end if
   end if
   let l_index = 1
   open ccto00m08002
   foreach ccto00m08002 into a_cto00m08[l_index].socntzdes,
                             a_cto00m08[l_index].socntzcod
   let l_index = l_index + 1
   end foreach
   open window cto00m08 at 10,29 with form "cto00m08"
        attribute(form line first, border)
   message " (F17)Abandona, (F8)Seleciona"
   call set_count(l_index-1)
   display array a_cto00m08 to s_cto00m08.*
      on key (interrupt,control-c)
         initialize a_cto00m08   to null
         exit display
     on key (F8)
        let l_index = arr_curr()
        let lr_retorno.ntzcod = a_cto00m08[l_index].socntzcod
        exit display
   end display
   close window  cto00m08
   let int_flag = false
   return lr_retorno.ntzcod
end function

#---------------------------------------------------------------
function cto00m08_recupera_grupo_cota(lr_param)
#---------------------------------------------------------------

define lr_param record
   socntzcod    like datksocntz.socntzcod
end record

define lr_retorno record
  socntzgrpcod like datksocntz.socntzgrpcod
end record

if m_prep_sql is null or
   m_prep_sql <> true then
   call cto00m08_prepare()
end if

initialize lr_retorno.* to null

  whenever error continue
  open ccto00m08004 using lr_param.socntzcod
  fetch ccto00m08004 into lr_retorno.socntzgrpcod
  whenever error stop

  return lr_retorno.socntzgrpcod

end function

#------------------------------------------#
function cto00m08_inf_natureza(lr_param)
#------------------------------------------#

define lr_param record
    tipo           smallint                   , # 1-Laudo Original 2-Laudo Multiplo
    socntzcod      like datksocntz.socntzcod  ,
    socntzstt      like datksocntz.socntzstt  ,
    socntzcod_ori  like datksocntz.socntzcod
end record

define lr_retorno record
    socntzdes      like datksocntz.socntzdes    ,
    socntzgrpcod   like datksocntz.socntzgrpcod ,
    resultado      smallint                     ,
    mensagem       char(80)                     ,
    qtd            integer                      ,
    flg_socntzcod  smallint
end record

define lr_cota record
       socntzgrpcod_ori  like datksocntz.socntzgrpcod,
       socntzgrpcod_mul  like datksocntz.socntzgrpcod
end record

define l_index smallint

initialize lr_retorno.* ,
           lr_cota.*  to null

let l_index = null
let lr_retorno.flg_socntzcod = false

   if lr_param.socntzcod     is null or
      lr_param.socntzstt     is null then
      let lr_retorno.mensagem = "Parametros incorretos !(ctc16m03_inf_natureza()) "
      let lr_retorno.resultado = 3
      return lr_retorno.resultado    ,
             lr_retorno.mensagem     ,
             lr_retorno.socntzdes    ,
             lr_retorno.socntzgrpcod
   end if
   if m_prep_sql is null or
      m_prep_sql <> true then
      call cto00m08_prepare()
   end if
   if lr_param.tipo = 2              and
      lr_param.socntzcod is not null then
      # Verifica Grupo de Cota Laudo Multiplo
      call cto00m08_recupera_grupo_cota(lr_param.socntzcod)
      returning lr_cota.socntzgrpcod_mul
      # Verifica Grupo de Cota Laudo Original
      call cto00m08_recupera_grupo_cota(lr_param.socntzcod_ori)
      returning lr_cota.socntzgrpcod_ori
      if lr_cota.socntzgrpcod_ori <> lr_cota.socntzgrpcod_mul then
         let lr_retorno.mensagem = "Natureza não Cadastrada para o Mesmo Grupo de Cota do Original "
         let lr_retorno.resultado = 2
         return lr_retorno.resultado    ,
                lr_retorno.mensagem     ,
                lr_retorno.socntzdes    ,
                lr_retorno.socntzgrpcod
      end if
   end if
   if g_documento.c24astcod <> "RET"  then
       whenever error continue
       open ccto00m08005 using lr_param.socntzcod
                              ,lr_param.socntzstt
                              ,g_documento.ciaempcod
                              ,g_documento.c24astcod
       fetch ccto00m08005 into lr_retorno.socntzdes
                              ,lr_retorno.socntzgrpcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode < 0 then
             let lr_retorno.mensagem  = "Erro : ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," no acesso a tabela datksocntz "
             let lr_retorno.resultado = 3
          else
             let lr_retorno.mensagem  = "Natureza nao Cadastrada "
             let lr_retorno.resultado = 2
          end if
       else
          if g_pss.psscntcod is not null then
             call pss01g00_consulta_servicos(g_pss.psscntcod,
                                             g_documento.c24astcod )
             returning lr_retorno.resultado ,
                       lr_retorno.mensagem  ,
                       lr_retorno.qtd
             if lr_retorno.resultado = 0 then
                for l_index  =  1  to lr_retorno.qtd
                    if lr_param.socntzcod = g_pss_natureza[l_index].socntzcod then
                         let lr_retorno.resultado = 1
                         let lr_retorno.flg_socntzcod = true
                         exit for
                    end if
                end for
                if lr_retorno.flg_socntzcod then
                   let lr_retorno.resultado = 1
                end if
             end if
          else
             let lr_retorno.resultado = 1
          end if
       end if
   else
       whenever error continue
       open ccto00m08006 using lr_param.socntzcod
                              ,lr_param.socntzstt
       fetch ccto00m08006 into lr_retorno.socntzdes
                              ,lr_retorno.socntzgrpcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode < 0 then
             let lr_retorno.mensagem  = "Erro : ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," no acesso a tabela datksocntz "
             let lr_retorno.resultado = 3
          else
             let lr_retorno.mensagem  = "Natureza nao Cadastrada "
             let lr_retorno.resultado = 2
          end if
       else
          let lr_retorno.resultado = 1
       end if
   end if
   return lr_retorno.resultado    ,
          lr_retorno.mensagem     ,
          lr_retorno.socntzdes    ,
          lr_retorno.socntzgrpcod

end function
