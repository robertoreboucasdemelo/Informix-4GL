#---------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                           #
#...........................................................................#
# Sistema        : Central 24H                                              #
# Modulo         : ctc61m02                                                 #
#                  Tela de alertas                                          #
# Analista Resp. : Alberto Rodrigues                                        #
#...........................................................................#
# Desenvolvimento: Fabrica de Software META, JUNIOR                         #
# PSI            : 192015                                                   #
# Liberacao      : 08/08/2005                                               #
#...........................................................................#
#                                                                           #
#                       * * * Alteracoes * * *                              #
#                                                                           #
# Data        Autor Fabrica  Origem      Alteracao                          #
# ----------  -------------- --------- -------------------------------------#
#                                                                           #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl" 

define am_tela       array[100] of record
       opcao         char(01),
       descricao     like datkvclcndlcl.vclcndlcldes
end record

define am_aux        array[100] of record
       vclcndlclcod  like datkvclcndlcl.vclcndlclcod,
       vclcndlcldes  like datkvclcndlcl.vclcndlcldes
end record

define m_prep_sql  smallint

#--------------------------#
function ctc61m02_prepara()
#--------------------------#
define l_sql       char(500)     

   let l_sql = " delete from datrcndlclsrv "
              ," where atdsrvnum = ? "
              ,"   and atdsrvano = ?" 
   prepare pctc61m02002 from l_sql

   let l_sql = " select (case when a.vclcndlclcod = b.vclcndlclcod then 'X' else ' ' end), "
              ,"        a.vclcndlclcod, a.vclcndlcldes "
              ,"  from datkvclcndlcl a, outer datrcndlclsrv b "
              ," where  b.atdsrvnum = ?  "
              ,"   and  b.atdsrvano = ?  "
              ,"   and  a.vclcndlclcod = b.vclcndlclcod "
              ,"  order by a.vclcndlcldes, a.vclcndlclcod "
   prepare pctc61m02004 from l_sql
   declare cctc61m02004 cursor for pctc61m02004

   let l_sql = " select count(*) "
              ,"  from datkvclcndlcl a, datrcndlclsrv b "
              ," where  b.atdsrvnum = ?  "
              ,"   and  b.atdsrvano = ?  "
              ,"   and  a.vclcndlclcod = b.vclcndlclcod "
   prepare pctc61m02006 from l_sql
   declare cctc61m02006 cursor for pctc61m02006

   let l_sql = " select 'X', a.vclcndlclcod, a.vclcndlcldes "
              ,"  from datkvclcndlcl a, datrcndlclsrv b "
              ," where  b.atdsrvnum = ?  "
              ,"   and  b.atdsrvano = ?  "
              ,"   and  a.vclcndlclcod = b.vclcndlclcod "
              ,"  order by a.vclcndlcldes, a.vclcndlclcod "
   prepare pctc61m02007 from l_sql
   declare cctc61m02007 cursor for pctc61m02007

   let m_prep_sql = true  
 
end function   

#-----------------------------------#
 function ctc61m02_criatmp(lr_param)
#-----------------------------------#

 define lr_param      record
        ins_del       smallint,
        atdsrvnum     like datrcndlclsrv.atdsrvnum,
        atdsrvano     like datrcndlclsrv.atdsrvano
 end record

 define lr_temp       record
        atdsrvnum     like datrcndlclsrv.atdsrvnum, 
        atdsrvano     like datrcndlclsrv.atdsrvano,
        vclcndlclcod  like datrcndlclsrv.vclcndlclcod
 end record

 define l_sql  char(500)

  if lr_param.atdsrvnum is null then
     let lr_param.atdsrvnum = 0
     let lr_param.atdsrvano = 0
  end if
  
  if m_prep_sql is null or
     m_prep_sql <> true then
     call ctc61m02_prepara()
  end if
  
  whenever error continue
  select count(*) from tmp_datrcndlclsrv
  whenever error stop
  if sqlca.sqlcode = -206 then
     whenever error continue
     drop table tmp_datrcndlclsrv

     select atdsrvnum, atdsrvano, vclcndlclcod
       from datrcndlclsrv
      where atdsrvnum = lr_param.atdsrvnum
        and atdsrvano = lr_param.atdsrvano
       into temp tmp_datrcndlclsrv with no log;
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error 'ERRO CREATE TEMP TABLE tmp_datrcndlclsrv - SqlCode ',sqlca.sqlcode sleep 2
        return 1
     end if

     let l_sql = " select atdsrvnum  "
                ,"  from tmp_datrcndlclsrv  "
                ," where  atdsrvnum = ?  "
                ,"   and  atdsrvano = ?  "
                ,"   and  vclcndlclcod = ? "
     prepare pctc61m02008 from l_sql
     declare cctc61m02008 cursor for pctc61m02008
   
     let l_sql = " insert into tmp_datrcndlclsrv ",
                 " (atdsrvnum, atdsrvano, vclcndlclcod) ",
                 " values(?,?,?) "
     prepare pctc61m02005 from l_sql

     let l_sql = " delete from tmp_datrcndlclsrv ",
                 "  where atdsrvnum    = ?  ",
                 "    and atdsrvano    = ?  ",
                 "    and vclcndlclcod = ? "
     prepare pctc61m02009 from l_sql

     let l_sql = " select (case when a.vclcndlclcod = b.vclcndlclcod then 'X' else ' ' end), "
                ,"        a.vclcndlclcod, a.vclcndlcldes "
                ,"  from datkvclcndlcl a, outer tmp_datrcndlclsrv b "
                ," where  b.atdsrvnum = ?  "
                ,"   and  b.atdsrvano = ?  "
                ,"   and  a.vclcndlclcod = b.vclcndlclcod "
                ," order by a.vclcndlcldes, a.vclcndlclcod "
     prepare pctc61m02010 from l_sql
     declare cctc61m02010 cursor for pctc61m02010

     if lr_param.ins_del = 2 then
        whenever error continue
        drop table tmp_datrcndlclsrv
        whenever error stop
        if sqlca.sqlcode = -206 then 
           return 1
        end if  
     end if
     return 0
  else
     if lr_param.ins_del = 2 then
        whenever error continue
        drop table tmp_datrcndlclsrv
        whenever error stop
        if sqlca.sqlcode = -206 then
           return 1
        else
           return 0
        end if
     end if
     return 1
  end if

  return 0

end function

#---------------------------#
 function ctc61m02(lr_param)
#---------------------------#

 define lr_param      record
        atdsrvnum     like datrcndlclsrv.atdsrvnum,
        atdsrvano     like datrcndlclsrv.atdsrvano,
        flg_char      char(01)
 end record
 
 define l_tmp_flg     smallint,
        l_qtde        smallint,
        l_mensagem    char(60)

  if lr_param.atdsrvnum is null then
     let lr_param.atdsrvnum = 0
     let lr_param.atdsrvano = 0
  end if

  let l_tmp_flg = ctc61m02_criatmp(1, 
                                   lr_param.atdsrvnum,
                                   lr_param.atdsrvano)

  if ctc61m02_display(lr_param.*,l_tmp_flg) = false then
     return
  end if

  open window w_ctc61m02 at 11,23 with form "ctc61m02"
                attribute(form line 1, border)

  let l_mensagem = null
  display l_mensagem to mensagem

  if lr_param.flg_char = "M" then
     call ctc61m02_input(lr_param.atdsrvnum
                        ,lr_param.atdsrvano         
                        ,lr_param.flg_char
                        ,l_tmp_flg) 
  else
     if lr_param.flg_char = "C" then
        call ctc61m02_mostra(lr_param.*,l_tmp_flg)
     else
        if lr_param.flg_char = "A" then
           let l_qtde = ctc61m02_verifica(lr_param.atdsrvnum,
                                          lr_param.atdsrvano,
                                          lr_param.flg_char,
                                          l_tmp_flg)
           if l_qtde > 0 then
              call ctc61m02_mostra(lr_param.*,l_tmp_flg)
           end if
        end if
     end if 
  end if

  close window w_ctc61m02 
  
  let int_flag = false

end function
#--------------------------------------------------------------------
function ctc61m02_display(lr_param)
#--------------------------------------------------------------------

define lr_param        record
       atdsrvnum       like datrcndlclsrv.atdsrvnum,
       atdsrvano       like datrcndlclsrv.atdsrvano,
       flg_char        char(01),
       tmp_flg         char(01)
end record

define l_i             smallint,
       l_retorno       smallint

 let l_i = 1

 let l_retorno = true

 if lr_param.atdsrvnum is null then
    let lr_param.atdsrvnum = 0
    let lr_param.atdsrvano = 0
 end if
 
 initialize am_tela  to  null
 initialize am_aux   to  null

 if lr_param.tmp_flg = 0 then
    if lr_param.flg_char = "A" then
       open cctc61m02007 using lr_param.atdsrvnum,
                               lr_param.atdsrvano
   
       foreach cctc61m02007 into am_tela[l_i].opcao,
                                 am_aux[l_i].vclcndlclcod,
                                 am_aux[l_i].vclcndlcldes
                                 
          let am_tela[l_i].descricao = am_aux[l_i].vclcndlcldes
   
          let l_i = l_i + 1
   
          if l_i > 100 then
             error "Estouro do limite da tabela, avise a INFORMATICA."
             exit foreach
          end if
       end foreach
    else
       open cctc61m02004 using lr_param.atdsrvnum,
                               lr_param.atdsrvano
    
       foreach cctc61m02004 into am_tela[l_i].opcao,
                                 am_aux[l_i].vclcndlclcod,
                                 am_aux[l_i].vclcndlcldes
    
          let am_tela[l_i].descricao = am_aux[l_i].vclcndlcldes
          
          if am_tela[l_i].opcao = "X" then
             if lr_param.tmp_flg = 0  then
                open cctc61m02008 using lr_param.atdsrvnum,
                                        lr_param.atdsrvano,
                                        am_aux[l_i].vclcndlclcod
                whenever error continue
                fetch cctc61m02008
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   whenever error continue
                   execute pctc61m02005  using lr_param.atdsrvnum
                                              ,lr_param.atdsrvano
                                              ,am_aux[l_i].vclcndlclcod
                   whenever error stop
                   if sqlca.sqlcode <> 0 then
                      error " Erro na inclusao do local/condicoes Veiculo! " sleep 2
                      exit foreach
                   end if
                end if
                close cctc61m02008
             end if
          end if
    
          let l_i = l_i + 1
    
          if l_i > 100 then
             error "Estouro do limite da tabela, avise a INFORMATICA."
             exit foreach
          end if
       end foreach
    end if
 else  
    open cctc61m02010 using lr_param.atdsrvnum,
                            lr_param.atdsrvano
    foreach cctc61m02010 into am_tela[l_i].opcao,
                              am_aux[l_i].vclcndlclcod,
                              am_aux[l_i].vclcndlcldes
       let am_tela[l_i].descricao = am_aux[l_i].vclcndlcldes
       let l_i = l_i + 1
       if l_i > 100 then
          error "Estouro do limite da tabela, avise a INFORMATICA."
          exit foreach
       end if
    end foreach
    close cctc61m02010
 end if
 
 call set_count(l_i)

 return l_retorno

end function
#--------------------------------------------------------------------
function ctc61m02_mostra(lr_param)
#--------------------------------------------------------------------

   define lr_param       record
          atdsrvnum      like datmservico.atdsrvnum,
          atdsrvano      like datmservico.atdsrvano,
          flg_char       char(01),
          tmp_flg        smallint
   end   record

   let int_flag = false

   display array am_tela to s_ctc61m02.*

      on key(interrupt,control-c,escape)
         exit display

   end display

   let int_flag = false

end function
#--------------------------------------------------------------------
function ctc61m02_verifica(lr_param)
#--------------------------------------------------------------------

 define lr_param       record
        atdsrvnum      like datmservico.atdsrvnum,
        atdsrvano      like datmservico.atdsrvano,
        flg_char       char(01),
        tmp_flg        smallint
 end   record

 define l_qtde    smallint

  let l_qtde = 0

  whenever error continue
  open cctc61m02006 using lr_param.atdsrvnum
                         ,lr_param.atdsrvano
  fetch cctc61m02006 into l_qtde
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        error "Erro SELECT cctc61m02006 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
        error "CTC61M01 / ctc61m02_verifica() " sleep 2
     end if  
  end if
  
  return l_qtde

end function
#--------------------------------------------------------------------
function ctc61m02_input(lr_param)
#--------------------------------------------------------------------

 define lr_param       record
        atdsrvnum      like datmservico.atdsrvnum,
        atdsrvano      like datmservico.atdsrvano,
        flg_char       char(01),
        tmp_flg        smallint
 end   record
 
 define l_scr          smallint,
        l_arr          smallint,
        l_opcao_ant    char(01),
        l_mensagem     char(60)

   let l_scr       = null
   let l_arr       = null
   let l_opcao_ant = " "

   if lr_param.atdsrvnum is null then
      let lr_param.atdsrvnum = 0
      let lr_param.atdsrvano = 0
   end if

   let int_flag = false

   options
      delete   key control-y,
      insert   key control-z,
      next     key f3,
      previous key f4 
      
   let l_mensagem = "MARQUE COM UM 'X' P/SELECIONAR LOCAL/CONDICAO DO VEICULO"
   
   display l_mensagem to mensagem

   input array am_tela without defaults from s_ctc61m02.*

         before row
           let l_arr = arr_curr()
           let l_scr = scr_line()
      
         before field opcao
           display am_tela[l_arr].opcao  to
                   s_ctc61m02[l_scr].opcao  attribute (reverse)
      
           if am_tela[l_arr].opcao is null  then
              let am_tela[l_arr].opcao = " "
           end if
      
           let l_opcao_ant = am_tela[l_arr].opcao
      
         after field opcao
           display am_tela[l_arr].opcao  to s_ctc61m02[l_scr].opcao

           if am_tela[l_arr].opcao is null  then
              let am_tela[l_arr].opcao = " "
           end if

           if am_tela[l_arr].opcao <> "X" and
              am_tela[l_arr].opcao <> " " then
              error 'Somente digitar "X" ou barra de espaco '
              next field opcao
           end if

           if l_opcao_ant <> am_tela[l_arr].opcao then
              if am_tela[l_arr].opcao = "X" then
                 if am_aux[l_arr].vclcndlclcod is not null then
                    open cctc61m02008 using lr_param.atdsrvnum,
                                            lr_param.atdsrvano,
                                            am_aux[l_arr].vclcndlclcod
                    whenever error continue
                    fetch cctc61m02008
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
                       whenever error continue
                       execute pctc61m02005  using lr_param.atdsrvnum
                                                  ,lr_param.atdsrvano
                                                  ,am_aux[l_arr].vclcndlclcod
                       whenever error stop
                       if sqlca.sqlcode <> 0 then
                          error " Erro na inclusao do local/condicoes Veiculo! " sleep 2
                          let int_flag = true
                          exit input
                       end if
                    end if
                    close cctc61m02008
                 end if
              else
                 whenever error continue
                 execute pctc61m02009 using lr_param.atdsrvnum,
                                            lr_param.atdsrvano,
                                            am_aux[l_arr].vclcndlclcod
                 whenever error stop
                 if sqlca.sqlcode <> 0 then
                    error " Erro na exclusao do local/condicoes Veiculo! " sleep 2
                    let int_flag = true
                    exit input
                 end if
              end if
           end if

           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = 2005             or    ## f3
              fgl_lastkey() = 2006             then  ## f4
              continue input
           end if

           if am_tela[l_arr + 1].descricao is null then
              next field opcao
           else
              continue input
           end if

         on key (f17,control-c,interrupt,accept,escape)

           let int_flag = true
           exit input
      
   end input

   let l_mensagem = ""
   
   display l_mensagem to mensagem

   let int_flag = false

   options
      delete   key f2,
      insert   key f1,
      next     key f3,
      previous key f4 

end function 
#--------------------------------------------------------------------
