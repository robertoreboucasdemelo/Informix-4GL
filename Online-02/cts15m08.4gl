###############################################################################
# Nome do Modulo: CTS15M08                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Dados para reserva  por departamento                               Set/1999 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 30/08/2000  CORREIO      Wagner       Substituicao tabela p/centro de custo #
#-----------------------------------------------------------------------------#
# 17/05/2002  PSI 13643-3  Wagner       Inclusao tipo reserva p/Funcionario.  #
###############################################################################
#.............................................................................#
#                           * * *  ALTERACOES  * * *                          #
# Data       Autor           Origem      Alteracao                            #
# ---------- --------------- ---------   -------------------------------------#
# 10/09/2003 Julianna,Meta   PSI176532   Implementar para que seja informado e#
#                            OSF25887    consultado o centro de custo completo#
#-----------------------------------------------------------------------------#
# 14/06/2004 JUNIOR  ,Meta   PSI 192341  Unificacao de Centro de Custo        #
#                                                                             #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function cts15m08(param)
#--------------------------------------------------------------

 define param        record
    vclloctip        like datmavisrent.vclloctip,
    slcemp           like datmavisrent.slcemp,
    slcsuccod        like datmavisrent.slcsuccod,
    slcmat           like datmavisrent.slcmat,
    slccctcod        like datmavisrent.slccctcod,
    flg              char (01)          #  "A"-atualizacao "C"-consulta
 end record

 define d_cts15m08   record
    slcemp           like datmavisrent.slcemp,
    slcsuccod        like datmavisrent.slcsuccod,
    slcmat           like datmavisrent.slcmat,
    slccctcod        like datmavisrent.slccctcod,
    empnom           like gabkemp.empnom,
    sucnom           like gabksuc.sucnom,
    funnom           like isskfunc.funnom,
    cctnom           like ctokcentrosuc.cctnom,
    confirma         char (01)
 end record

 define ws           record
    rhmfunsitcod     like isskfunc.rhmfunsitcod,
    rhmseccod        like isskfunc.rhmseccod,
    cctcod           decimal (7,0),
    confirma         char (01)
 end record
  define l_ret   decimal(3,0)

  define lr_param record
      empcod    like ctgklcl.empcod,       --Empresa
      succod    like ctgklcl.succod,       --Sucursal
      cctlclcod like ctgklcl.cctlclcod,    --Local
      cctdptcod like ctgrlcldpt.cctdptcod  --Departamento
  end record

  define lr_ret record
      erro          smallint, ## 0-Ok,1-erro
      mens          char(40),
      cctlclnom     like ctgklcl.cctlclnom,  --Nome do local
      cctdptnom     like ctgkdpt.cctdptnom,  --Nome do depto (antigo cctnom)
      cctdptrspnom  like ctgrlcldpt.cctdptrspnom, --Resp pelo departamento
      cctdptlclsit  like ctgrlcldpt.cctdptlclsit, --Sit do depto (A)tivo (I)nativo
      cctdpttip     like ctgkdpt.cctdpttip        -- Tipo de departamento
  end record

  define lr_param_a record
      empcod    like ctgklcl.empcod,       --Empresa
      succod    like ctgklcl.succod,       --Sucursal
      cctlclcod like ctgklcl.cctlclcod,    --Local
      cctdptcod like ctgrlcldpt.cctdptcod  --Departamento
  end record

  define lr_ret_a record
      erro          smallint, ## 0-Ok,1-erro
      mens          char(40),
      cctlclnom     like ctgklcl.cctlclnom,    --Nome do local
      cctdptnom     like ctgkdpt.cctdptnom,    --Nome do depto (antigo cctnom)
      cctdptrspnom  like ctgrlcldpt.cctdptrspnom, --Resp pelo departamento
      cctdptlclsit  like ctgrlcldpt.cctdptlclsit, --Sit do depto (A)tivo (I)nativo
      cctdpttip     like ctgkdpt.cctdpttip        -- Tipo de departamento
  end record
  define lr_dpt_pop   record
         lin          smallint,
         col          smallint,
         title        char(054),
         col_tit_1    char(012),
         col_tit_2    char(040),
         tipcod       char(001),
         cmd_sql      char(600),
         comp_sql     char(200),
         tipo         char(001)
                     end record
 initialize d_cts15m08.* to null
 initialize ws.*         to null
 initialize d_cts15m08.* to null
 initialize lr_dpt_pop.* to null

 let int_flag = false

 if param.slcemp    is not null  or
    param.slcsuccod is not null  or
    param.slcmat    is not null  or
    param.slccctcod is not null  then
    if param.vclloctip = 4 then
       let param.slccctcod = null
    end if
    let d_cts15m08.slcemp     = param.slcemp
    let d_cts15m08.slcsuccod  = param.slcsuccod
    let d_cts15m08.slcmat     = param.slcmat
    let d_cts15m08.slccctcod  = param.slccctcod

    select empnom
      into d_cts15m08.empnom
      from gabkemp
     where empcod = d_cts15m08.slcemp

    select sucnom
      into d_cts15m08.sucnom
      from gabksuc
     where succod = d_cts15m08.slcsuccod

    select funnom
      into d_cts15m08.funnom
      from isskfunc
     where funmat = d_cts15m08.slcmat
       and empcod = d_cts15m08.slcemp

    if param.vclloctip = 3 then
       let lr_param_a.empcod    = 1
       let lr_param_a.succod    = 1
       let lr_param_a.cctlclcod = (ws.cctcod / 10000)
       let lr_param_a.cctdptcod = (d_cts15m08.slccctcod mod 10000)
       call fctgc102_vld_dep(lr_param_a.*)
	   returning lr_ret.*
       let d_cts15m08.cctnom = lr_ret.cctdptnom

    end if
 end if
 let lr_dpt_pop.lin         = 6
 let lr_dpt_pop.col         = 2
 let lr_dpt_pop.title       = 'Centro de Custo'
 let lr_dpt_pop.col_tit_1   = 'Codigo'
 let lr_dpt_pop.col_tit_2   = 'Descricao'
 let lr_dpt_pop.tipcod      = 'N'
 let lr_dpt_pop.tipo        = 'D'

 open window cts15m08 at 13,14 with form "cts15m08"
                      attribute (form line 1, border, comment line last - 1)

 if param.vclloctip = 3 then
    display "C.Custo p/Debito:" to teldep
 end if
 message " (F17)Abandona"

 display by name d_cts15m08.*

 while true

    input by name d_cts15m08.slcemp,
                  d_cts15m08.slcsuccod,
                  d_cts15m08.slcmat,
                  d_cts15m08.slccctcod,
                  d_cts15m08.confirma   without defaults

       before field slcemp
          display by name d_cts15m08.slcemp attribute (reverse)

       after  field slcemp
          if param.flg = "C" then
             error " Disponivel apenas para consulta!"
             next field slcemp
          end if
          display by name d_cts15m08.slcemp

          if d_cts15m08.slcemp is null  then
             error " Informe o codigo da empresa!"
             next field slcemp
          end if

          select empnom
            into d_cts15m08.empnom
            from gabkemp
           where empcod = d_cts15m08.slcemp

          if sqlca.sqlcode <> 0  then
             error " Empresa nao cadastrada!"
             next field slcemp
          end if

          display by name d_cts15m08.empnom

       before field slcsuccod
          display by name d_cts15m08.slcsuccod  attribute (reverse)

       after  field slcsuccod
          display by name d_cts15m08.slcsuccod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field slcemp
          end if

          if d_cts15m08.slcsuccod is null    or
             d_cts15m08.slcsuccod =  "  "    then
             error " Informe a sucursal!"
             next field slcsuccod
          end if

          select sucnom
            into d_cts15m08.sucnom
            from gabksuc
           where succod = d_cts15m08.slcsuccod

          if sqlca.sqlcode <> 0 then
             error " Codigo da Sucursal nao existe!"
             next field slcsuccod
          end if

          display by name d_cts15m08.sucnom

       before field slcmat
          display by name d_cts15m08.slcmat  attribute (reverse)

       after  field slcmat
          display by name d_cts15m08.slcmat

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field slcsuccod
          end if

          select isskfunc.funnom,
                 isskfunc.rhmfunsitcod,
                 isskfunc.rhmseccod
            into d_cts15m08.funnom,
                 ws.rhmfunsitcod,
                 ws.rhmseccod
            from isskfunc
           where isskfunc.funmat = d_cts15m08.slcmat
             and isskfunc.empcod = d_cts15m08.slcemp

          if sqlca.sqlcode <> 0  then
             error " Funcionario nao encontrado!"
             next field slcmat
          end if

          if ws.rhmfunsitcod = "D"  then
             error " Funcionario nao esta' mais ativo!"
             next field slcmat
          end if

          if ws.rhmfunsitcod = "F"  then
             error " Funcionario afastado!"
             call cts08g01("C","S","","FUNCIONARIO CONSTA COMO AFASTADO!","EFETUA RESERVA ?","") returning ws.confirma

             if ws.confirma = "N"  then
                next field slcmat
             end if
          end if

          let d_cts15m08.funnom = upshift(d_cts15m08.funnom)
          display by name d_cts15m08.funnom
          #PSI176532
          call fgrhc004_cct_ctb(ws.rhmseccod) returning  l_ret,ws.cctcod

          let d_cts15m08.slccctcod = ws.cctcod # FIM PSI176532

       before field slccctcod
          if param.vclloctip = 4 then
             initialize d_cts15m08.slccctcod, ws.cctcod to null
             next field confirma
          end if
          display by name d_cts15m08.slccctcod  attribute (reverse)

       after  field slccctcod
          display by name d_cts15m08.slccctcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field slcmat
          end if

          if d_cts15m08.slccctcod is null then #PSI176532
             error " Informe o centro de custo!"
             let lr_param.empcod = d_cts15m08.slcemp
             let lr_param.succod = d_cts15m08.slcsuccod
             let lr_dpt_pop.cmd_sql =  'select a.cctdptcod,b.cctdptnom  '
                                      ,'  from ctgrlcldpt a,ctgkdpt b '
                                      ,' where a.cctdptcod = b.cctdptcod '
                                      ,'   and a.empcod = ',lr_param.empcod
                                      ,'   and a.succod = ',lr_param.succod
              call ofgrc001_popup(lr_dpt_pop.*) returning l_ret
                                                         ,d_cts15m08.slccctcod
                                                         ,d_cts15m08.cctnom
              if l_ret <> 0 then
                 next field slccctcod
              end if
              display by name d_cts15m08.slccctcod
              display by name d_cts15m08.cctnom
          else # FIM PSI176532

             let lr_param_a.empcod    = d_cts15m08.slcemp
	     let lr_param_a.succod    = d_cts15m08.slcsuccod
	     let lr_param_a.cctlclcod = (ws.cctcod / 10000)
	     let lr_param_a.cctdptcod = (d_cts15m08.slccctcod mod 10000)

	     call fctgc102_vld_dep(lr_param_a.*)
		  returning lr_ret_a.*

	     let d_cts15m08.cctnom = lr_ret_a.cctdptnom
             let d_cts15m08.cctnom = upshift(d_cts15m08.cctnom)
             display by name d_cts15m08.cctnom
                          
#             #860902 INI
#             if lr_ret_a.erro > 0 then
#                error "Centro de custo nao cadastrado!"
#                next field slccctcod
#             end if
#             #860902 FIM

             if d_cts15m08.slccctcod <> ws.cctcod then
                error " Centro de custo digitado diferente do cadastro de funcionarios!"
             end if

          end if

       before field confirma
          display by name d_cts15m08.confirma attribute (reverse)

       after field confirma
          display by name d_cts15m08.confirma

          if fgl_lastkey() =  fgl_keyval("up")   or
             fgl_lastkey() =  fgl_keyval("left") then
             if param.vclloctip = 4 then
                next field confirma
             else
                next field slccctcod
             end if
          end if

          if d_cts15m08.confirma is null  then
             error " Confirmacao e' necessaria! "
             next field confirma
          end if

          if d_cts15m08.confirma = "N"  then
             error " Dados nao confirmados! "
             next field slcemp
          else
             if d_cts15m08.confirma = "S"  then
                exit input
             else
                error " Confirma dados ? (S)im ou (N)ao "
                next field confirma
             end if
          end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    if d_cts15m08.confirma = "S"  then
       let param.slcemp     = d_cts15m08.slcemp
       let param.slcsuccod  = d_cts15m08.slcsuccod
       let param.slcmat     = d_cts15m08.slcmat
       let param.slccctcod  = d_cts15m08.slccctcod
       exit while
    end if

 end while

 close window cts15m08

 let int_flag = false

 return param.slcemp     , param.slcsuccod,
        param.slcmat     , param.slccctcod,
        d_cts15m08.funnom

end function  ###  cts15m08
