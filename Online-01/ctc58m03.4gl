################################################################################
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        :  Central24h                                                 #
# Modulo         :  ctc58m03                                                   #
# Analista Resp. :  Raji                                                       #
# PSI            :  146994 - Historico do Agrupamento/ Assunto                 #
#                            da Central 24h                                    #
#..............................................................................#
# Desenvolvimento:  Fabrica de Software - Cristina                             #
# Data           :  15/02/2002                                                 #
# Liberacao      :                                                             #
#..............................................................................#
#                     * * *  ALTERACOES * * *                                  #
#                                                                              #
# Data       Autor Fabrica      PSI    Alteracao                               #
# ----       -------------      ------ ---------                               #
# 22/04/2003 Aguinaldo Costa    168920 Resolucao 86                            #
#                                                                              #
# 14/06/2005 Helio (Meta)       192341 Unificacao de Centros de Custo          #
################################################################################

#------------------------------------------------------------------
#  A funcao recebe como parametros:
#   tip = AST (historico do assunto)  ou
#         AGP (historico do agrupamento)
#   codigo = campo c24astcod da tabela dattastcct ou da tabela dattagpcct
#   ramcod = ramo a ser pesquisado
#------------------------------------------------------------------


globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------
function ctc58m03(r_param)
#------------------------------------------------------------------------

 define w_comando   char(1000)
 define l_cont      smallint
 define scr_aux     smallint

 define r_param record
       tip      char(03),
       codigo   char(03),
       ramcod   like dattastcct. ramcod 
 end record

 define r_ctc58m03 array[300] of record
       ramcod          like dattagpcct.ramcod,
       ramnom          like gtakram.ramnom,
       cctcod          like dattagpcct.cctcod,
       cctnom          like ctokcentrosuc.cctnom,
       corasspsocod    like dattagpcct.corasspsocod,
       viginc          like dattagpcct.viginc,
       vigfnl          like dattagpcct.vigfnl,
       cctagpstt       like dattagpcct.cctagpstt,
       atldat          like dattagpcct.atldat,
       desc            char(40) 
 end record

 define lr_param    record
    empcod          like ctgklcl.empcod       #Empresa
   ,succod          like ctgklcl.succod       #Sucursal
   ,cctlclcod       like ctgklcl.cctlclcod    #Local
   ,cctdptcod       like ctgrlcldpt.cctdptcod #Departamento 
 end record 

 define lr_ret      record
    erro            smallint                      # 0-Ok, 1 - erro
   ,mens            char(40)                   
   ,cctlclnom       like ctgklcl.cctlclnom        #Nome do local
   ,cctdptnom       like ctgkdpt.cctdptnom        #Nome do depto(antigo cctnom)
   ,cctdptrspnom    like ctgrlcldpt.cctdptrspnom  #Responsavel pelo Depto
   ,cctdptlclsit    like ctgrlcldpt.cctdptlclsit  #Sit do Depto A-Ativo/I-Inat.
   ,cctdpttip       like ctgkdpt.cctdpttip        #Tipo de Depto 
 end record 

 define r_aux     array[300] of record
       atlmat          like dattagpcct.atlmat,
       funnom          like isskfunc.funnom, 
       seq             like dattagpcct.agpcctseq
 end record

 if r_param.tip = 'AST' then
    let w_comando =  " select ramcod, cctcod, corasspsocod,  ",
                     "        viginc, vigfnl, astcctstt ,    ",
                     "        atlmat, atldat, astcctseq      ",
                     "   from dattastcct     ",
                     "  where c24astcod = ?  ",
                     "  and   ramcod = ?  ",
                     " order by astcctseq  "
 else
    let w_comando =  " select ramcod, cctcod, corasspsocod,  ",
                     "        viginc, vigfnl, cctagpstt ,    ",
                     "        atlmat, atldat, agpcctseq      ",
                     "   from dattagpcct     ",
                     "  where c24astagp = ?  ",
                     "  and   ramcod = ?  ",
                     " order by agpcctseq  "
 end if 
 prepare pctc58m03001 from w_comando
 declare cctc58m03001 cursor for pctc58m03001

 let w_comando = " select ramnom  ",
                  "   from gtakram     ",
                  "  where ramcod = ?  ",
                  "    and empcod = 1  "

  prepare pctc58m03002 from w_comando
  declare cctc58m03002 cursor for pctc58m03002

  #let w_comando = " select cctnom  ",
  #                "   from ctokcentrosuc     ",
  #                "  where cctcod = ?  "
#
  #prepare pctc58m03003 from w_comando
  #declare cctc58m03003 cursor for pctc58m03003

  let w_comando = " select funnom  ",
                  "   from isskfunc     ",
                  "  where funmat = ?  "

  prepare pctc58m03004 from w_comando
  declare cctc58m03004 cursor for pctc58m03004
 
 open window w_ctc58m03 at 12,3 with form "ctc58m03"
     attribute(form line first, border)

 let l_cont = 1
 open cctc58m03001 using r_param.codigo,
                         r_param.ramcod
 foreach cctc58m03001 into r_ctc58m03[l_cont].ramcod,
                           r_ctc58m03[l_cont].cctcod,
                           r_ctc58m03[l_cont].corasspsocod,
                           r_ctc58m03[l_cont].viginc,
                           r_ctc58m03[l_cont].vigfnl,
                           r_ctc58m03[l_cont].cctagpstt,
                           r_aux[l_cont].atlmat,
                           r_ctc58m03[l_cont].atldat,
                           r_aux[l_cont].seq

    open cctc58m03002 using r_ctc58m03[l_cont].ramcod
    fetch cctc58m03002 into r_ctc58m03[l_cont].ramnom
      if sqlca.sqlcode <> 0 then
         error "Ramo: ", r_ctc58m03[l_cont].ramcod ," nao cadastrado "
         let r_ctc58m03[l_cont].ramnom = null
      end if 
   
      #open cctc58m03003 using r_ctc58m03[l_cont].cctcod
      #fetch cctc58m03003 into r_ctc58m03[l_cont].cctnom
      #  if sqlca.sqlcode <> 0 then
      #    error "Centro de Custo: ", r_ctc58m03[l_cont].cctcod ,
      #          " nao cadastrado "
      #    let r_ctc58m03[l_cont].cctnom = null
      #  end if 
           
      #PSI 192341
      let lr_param.empcod = 1
      let lr_param.succod = 1 
      let lr_param.cctlclcod = (r_ctc58m03[l_cont].cctcod / 10000)
      let lr_param.cctdptcod = (r_ctc58m03[l_cont].cctcod mod 10000)
      call fctgc102_vld_dep(lr_param.*)
	 returning lr_ret.* 
      let r_ctc58m03[l_cont].cctnom = lr_ret.cctdptnom 
      if lr_ret.erro <> 0 then
         error "Centro de Custo: ", r_ctc58m03[l_cont].cctcod ,
               " nao cadastrado "
         let r_ctc58m03[l_cont].cctnom = null
      end if 

      open cctc58m03004 using r_aux[l_cont].atlmat
      fetch cctc58m03004 into r_aux[l_cont].funnom

        if sqlca.sqlcode <> 0 then
          error "Funcionario: ", r_aux[l_cont].atlmat ,
                " nao cadastrado "
          let r_aux[l_cont].funnom = null
        end if 

        let r_ctc58m03[l_cont].desc = "por ",r_aux[l_cont].atlmat  ," - ",
                                      r_aux[l_cont].funnom
           
    let l_cont = l_cont + 1 
 end foreach    

  call set_count(l_cont - 1) 
  let scr_aux = scr_line()
  display array r_ctc58m03 to s_tela.*

    on key (interrupt)
       exit display
       return

   end display 

   close window w_ctc58m03

end function
