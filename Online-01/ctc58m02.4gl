################################################################################
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        :  Central24h                                                 #
# Modulo         :  ctc58m02                                                   #
# Analista Resp. :  Raji                                                       #
# PSI            :  146994 - Cadastro de  Centro de Custo para                 #
#                            Assunto da Central 24h                            #
#..............................................................................#
# Desenvolvimento:  Fabrica de Software - Cristina                             #
# Data           :  21/02/2002                                                 #
# Liberacao      :                                                             #
#..............................................................................#
#                     * * *  ALTERACOES * * *                                  #
#                                                                              #
# Data       Autor Fabrica       Data   Alteracao                              #
# ----       -------------       ----   ---------                              #
# 22/04/2003 Aguinaldo Costa     168920 Resolucao 86                           #
#                                                                              #
# 14/06/2005 Helio (Meta)        192341 Unificacao de Centros de Custo         #
################################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define f_c24astdes     like datkassunto.c24astdes
define f_c24astcod     like datkassunto.c24astcod

define l_opcao         char(01)
define w_comando       char(1000)
define l_aux           smallint
define scr_aux         smallint
define l_totalitens    smallint
define w_obs           char(80)
define l_flg_aux       char(01)

define r_ctc58m02 array[300] of record
       ramcod          like dattastcct.ramcod,
       ramnom          like gtakram.ramnom,
       cctcod          like dattastcct.cctcod,
       cctnom          like ctokcentrosuc.cctnom,
       corasspsocod    like dattastcct.corasspsocod,
       viginc          like dattastcct.viginc,
       vigfnl          like dattastcct.vigfnl,
       astcctstt       like dattastcct.astcctstt,
       flg             char(01)
end record

#-----------------------------------------------------------------------
function ctc58m02()
#-----------------------------------------------------------------------

#tirar
#  let g_issk.usrtip = 1
#  let g_issk.empcod = 1
#  let g_issk.funmat = 932
#tirar

let f_c24astcod = null  


open window w_ctc58m02 at 4,2 with form "ctc58m02"
     attribute(form line first, comment line last - 2)

  let w_obs = " (F17)Abandona  (F9)Historico "
  display w_obs to obs   
   
   menu "AGRUPAMENTOS"
      before menu
         hide option all
         show option "Seleciona", 
                     "Proximo", 
                     "Anterior",
                     "Modifica",
                     "Incluir",
                     "Encerra"

      command "Seleciona" "Pesquisa Assuntos que nao seguem a regra do agrupamento"
         let l_opcao = "S"
         clear form
         call ctc58m02_selecao()

      command "Proximo" "Mostra proxima linha selecionada"
         if f_c24astcod is not null or
            f_c24astcod <> " "  then
            let l_opcao = "P"
            call ctc58m02_proximo()
         else
            error " Nenhum agrupamento selecionado "
            next option "Seleciona"
         end if

      command "Anterior" "Mostra linha anterior selecionada"
         if f_c24astcod is not null or
            f_c24astcod <> " "  then
            let l_opcao = "A"
            call ctc58m02_proximo()
         else
            error " Nenhum agrupamento selecionado "
            next option "Seleciona"
         end if

      command "Modifica" "Modifica a linha atual"
         if f_c24astcod is not null or 
            f_c24astcod <> " "  then
               let l_opcao = "M"
              call ctc58m02_grava()
         else
            error " Nenhum agrupamento selecionado "
            next option "Seleciona"
         end if

      command "Incluir" "Inclui uma nova linha"
         if f_c24astcod is not null or 
            f_c24astcod <> " "  then
               let l_opcao = "I"
              call ctc58m02_grava()
         else
            error " Nenhum agrupamento selecionado "
            next option "Seleciona"
         end if

      command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
         let l_opcao = " "
         exit menu

   end menu

   close window w_ctc58m02

end function

#-----------------------------------------------------------------------
function ctc58m02_selecao()
#-----------------------------------------------------------------------

  let w_comando = " select c24astdes   ",
                  "   from datkassunto     ", 
                  "  where c24astcod = ?  " 
  prepare pctc58m02001 from w_comando
  declare cctc58m02001 cursor for pctc58m02001 

  let w_obs = " (F17)Abandona  (F9)Historico "
  display w_obs to obs   

  input f_c24astcod
  from c24astcod
       
      before field c24astcod
          display f_c24astcod  to  c24astcod  attribute(reverse)
          
      after field c24astcod
         if f_c24astcod is null then
            let f_c24astcod = null 
            next field c24astcod
         end if 
          
         open cctc58m02001 using f_c24astcod
         fetch cctc58m02001 into f_c24astdes
           if sqlca.sqlcode <> 0 then
             error "Assunto nao Cadastrado"
             next field c24astcod
           else
             display f_c24astcod  to c24astcod  
             display f_c24astdes  to c24astdes  
          end if 

    after input
        call ctc58m02_mostra_dados()


     on key (interrupt)
        exit input

  end input 

end function

#-----------------------------------------------------------------------
function ctc58m02_proximo()
#-----------------------------------------------------------------------

define l_c24astcod     like dattastcct.c24astcod

    let w_obs = " (F17)Abandona  (F9)Historico "
    display  w_obs to obs

    if l_opcao = 'P' then 
       let w_comando = " select min(c24astcod)   ",
                       "   from datkassunto     ", 
                       "  where c24astcod > ?  " 
    else
       let w_comando = " select max(c24astcod)   ",
                       "   from datkassunto     ", 
                       "  where c24astcod < ?  " 
    end if 
    prepare pctc58m02006 from w_comando
    declare cctc58m02006 cursor for pctc58m02006 

    open cctc58m02006 using f_c24astcod
    fetch cctc58m02006 into l_c24astcod
 
      if sqlca.sqlcode <> 0 then
         error "Nao exite registro posterior ao selecionado"
      else  
        let f_c24astcod = l_c24astcod
        open cctc58m02001 using f_c24astcod
        fetch cctc58m02001 into f_c24astdes
          if sqlca.sqlcode <> 0 then
            error "Assunto nao Cadastrado"
          else
            display f_c24astcod  to  c24astcod  
            display f_c24astdes  to  c24astdes  
         end if 
         call ctc58m02_mostra_dados()
      end if 
         
end function

#-------------------------------------------------------------------
function ctc58m02_mostra_dados()
#-------------------------------------------------------------------

define r_param   array[300] of record
       astcctseq     like dattastcct.astcctseq,
       ramcod        like dattastcct.ramcod 
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

for l_aux = 1 to 300
    initialize r_ctc58m02[l_aux].*  to null
end for

  let w_comando = " select ramcod, max(astcctseq)  ",
                  "   from dattastcct     ", 
                  "  where c24astcod = ?  ", 
                  " group by 1             "

  prepare pctc58m02002 from w_comando
  declare cctc58m02002 cursor for pctc58m02002 

  let w_comando = " select ramcod, cctcod, corasspsocod,  ",
                  "        viginc, vigfnl, astcctstt      ",
                  "   from dattastcct     ", 
                  "  where astcctseq = ?  " 

  prepare pctc58m02003 from w_comando
  declare cctc58m02003 cursor for pctc58m02003 

  let w_comando = " select ramnom  ",
                  "   from gtakram     ", 
                  "  where ramcod = ?  ", 
                  "    and empcod = 1  "
  prepare pctc58m02004 from w_comando
  declare cctc58m02004 cursor for pctc58m02004 

  #let w_comando = " select cctnom  ",
  #                "   from ctokcentrosuc     ", 
  #                "  where cctcod = ?  " 
#
#  prepare pctc58m02005 from w_comando
#  declare cctc58m02005 cursor for pctc58m02005 

  let w_comando = " select max(astcctseq)   ",
                  "   from dattastcct      "
    
  prepare pctc58m02008 from w_comando
  declare cctc58m02008 cursor for pctc58m02008 

  let w_obs = " (F17)Abandona  (F9)Historico "
  display w_obs to obs   

  set isolation to dirty read

  let l_aux = 1 
  open cctc58m02002 using f_c24astcod
  foreach cctc58m02002 into r_param[l_aux].ramcod,
                            r_param[l_aux].astcctseq
     if sqlca.sqlcode <> 0 then
       error "Nenhuma sequencia cadastrada"
     end if 

     open cctc58m02003 using r_param[l_aux].astcctseq
     fetch cctc58m02003 into r_ctc58m02[l_aux].ramcod, 
                             r_ctc58m02[l_aux].cctcod,
                             r_ctc58m02[l_aux].corasspsocod,
                             r_ctc58m02[l_aux].viginc,
                             r_ctc58m02[l_aux].vigfnl,
                             r_ctc58m02[l_aux].astcctstt
        
      open cctc58m02004 using r_ctc58m02[l_aux].ramcod
      fetch cctc58m02004 into r_ctc58m02[l_aux].ramnom
        if sqlca.sqlcode <> 0 then
          error "Ramo: ", r_ctc58m02[l_aux].ramcod, "  nao cadastrado"
        end if 

        #open cctc58m02005 using r_ctc58m02[l_aux].cctcod
        #fetch cctc58m02005 into r_ctc58m02[l_aux].cctnom
        #  if sqlca.sqlcode <> 0 then
        #    error "Centro de Custo: ", r_ctc58m02[l_aux].cctcod, "  nao cadastrado"
        #  end if 

        #PSI 192341
        let lr_param.empcod = 1
        let lr_param.succod = 1 
        let lr_param.cctlclcod = (r_ctc58m02[l_aux].cctcod / 10000)
        let lr_param.cctdptcod = (r_ctc58m02[l_aux].cctcod mod 10000)
        call fctgc102_vld_dep(lr_param.*)
	   returning lr_ret.* 
	if lr_ret.erro <> 0 then
           error "Centro de Custo: ", r_ctc58m02[l_aux].cctcod
	       , "  nao cadastrado"
	end if 
        let r_ctc58m02[l_aux].flg = " "
        let l_aux = l_aux + 1 
        let r_ctc58m02[l_aux].cctnom = lr_ret.cctdptnom 

  end foreach

    let l_totalitens =  l_aux - 1

    if l_totalitens = 0 then
       error "Nao encontrou nenhuma ocorrencia que satisfaca a consulta"
    end if 
    call set_count(l_totalitens)
    display array r_ctc58m02 to s_tela.*

     on key (f9) 
       let l_aux = arr_curr()
       call ctc58m03('AST',f_c24astcod,r_ctc58m02[l_aux].ramcod)

   end display


end function

#--------------------------------------------------------------------
function ctc58m02_input() 
#--------------------------------------------------------------------

define r_aux record
       ramcod          like dattastcct.ramcod,
       ramnom          like gtakram.ramnom,
       cctcod          like dattastcct.cctcod,
       cctnom          like ctokcentrosuc.cctnom,
       corasspsocod    like dattastcct.corasspsocod,
       viginc          like dattastcct.viginc,
       vigfnl          like dattastcct.vigfnl,
       astcctstt       like dattastcct.astcctstt
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

options delete key F12
 initialize r_aux  to null 
 let l_flg_aux = 'N'

    input array  r_ctc58m02
    without defaults from s_tela.*    

    before row
         let l_aux = arr_curr()
         let scr_aux = scr_line() 

         let r_ctc58m02[l_aux].flg = 'N' 
         let r_aux.ramcod         = r_ctc58m02[l_aux].ramcod
         let r_aux.ramnom         = r_ctc58m02[l_aux].ramnom
         let r_aux.cctcod         = r_ctc58m02[l_aux].cctcod
         let r_aux.cctnom         = r_ctc58m02[l_aux].cctnom
         let r_aux.corasspsocod   = r_ctc58m02[l_aux].corasspsocod
         let r_aux.viginc         = r_ctc58m02[l_aux].viginc
         let r_aux.vigfnl         = r_ctc58m02[l_aux].vigfnl
         let r_aux.astcctstt      = r_ctc58m02[l_aux].astcctstt

    #----Ramo
    before field ramcod 
      if r_ctc58m02[l_aux].ramcod is not  null or 
         r_ctc58m02[l_aux].ramcod <> " " then
         next field cctcod
      else
        display r_ctc58m02[l_aux].ramcod to s_tela[scr_aux].ramcod 
        attribute (reverse)
      end if

    after field ramcod
       if r_ctc58m02[l_aux].ramcod is null then
          next field ramcod 
       else  
         open cctc58m02004 using r_ctc58m02[l_aux].ramcod
         fetch cctc58m02004 into r_ctc58m02[l_aux].ramnom
            if sqlca.sqlcode <> 0 then
               error "Ramo ", r_ctc58m02[l_aux].ramcod , "nao cadastrado"
            else
              display r_ctc58m02[l_aux].ramcod to s_tela[scr_aux].ramcod 
              display r_ctc58m02[l_aux].ramnom to s_tela[scr_aux].ramnom 
            end if 
       end if 
 
    #----Codigo do Centro de Custo
    before field cctcod
       display r_ctc58m02[l_aux].cctcod to s_tela[scr_aux].cctcod 
       attribute (reverse)
   
    after field cctcod
       if r_ctc58m02[l_aux].cctcod is null then
          next field cctcod 
       else  
          #open cctc58m02005 using r_ctc58m02[l_aux].cctcod
          #fetch cctc58m02005 into r_ctc58m02[l_aux].cctnom
          #  if sqlca.sqlcode <> 0 then
          #     error "Centro de Custo ", r_ctc58m02[l_aux].cctcod, 
          #           " nao cadastrado"
          #     initialize r_ctc58m02[l_aux].cctcod to null
          #     display r_ctc58m02[l_aux].cctcod to s_tela[scr_aux].cctcod 
          #     next field cctcod
          #  else
          #    display r_ctc58m02[l_aux].cctcod to s_tela[scr_aux].cctcod 
          #    display r_ctc58m02[l_aux].cctnom to s_tela[scr_aux].cctnom 
          #  end if 

          #PSI 192341
          let lr_param.empcod = 1
          let lr_param.succod = 1 
          let lr_param.cctlclcod = (r_ctc58m02[l_aux].cctcod / 10000)
          let lr_param.cctdptcod = (r_ctc58m02[l_aux].cctcod mod 10000)
          call fctgc102_vld_dep(lr_param.*)
	     returning lr_ret.* 
	  if lr_ret.erro <> 0 then
             error "Centro de Custo ", r_ctc58m02[l_aux].cctcod, 
                   " nao cadastrado"
             initialize r_ctc58m02[l_aux].cctcod to null
             display r_ctc58m02[l_aux].cctcod to s_tela[scr_aux].cctcod 
             next field cctcod
	  else 
             let r_ctc58m02[l_aux].cctnom = lr_ret.cctdptnom 
             display r_ctc58m02[l_aux].cctcod to s_tela[scr_aux].cctcod 
             display r_ctc58m02[l_aux].cctnom to s_tela[scr_aux].cctnom 
	  end if 
       end if 

    #----Peso
    before field corasspsocod 
       display r_ctc58m02[l_aux].corasspsocod to s_tela[scr_aux].corasspsocod 
       attribute (reverse)

    after field corasspsocod
       if r_ctc58m02[l_aux].corasspsocod is null then
          next field corasspsocod 
       else  
         display r_ctc58m02[l_aux].corasspsocod to s_tela[scr_aux].corasspsocod 
       end if  
  
    #----Vigencia Inicial
    before field viginc 
       display r_ctc58m02[l_aux].viginc to s_tela[scr_aux].viginc 
       attribute (reverse)
  
    after field viginc
       if r_ctc58m02[l_aux].viginc is null then
          next field viginc 
       else  
         display r_ctc58m02[l_aux].viginc to s_tela[scr_aux].viginc 
       end if 
            
    #----Vigencia Final
    before field vigfnl 
       display r_ctc58m02[l_aux].vigfnl to s_tela[scr_aux].vigfnl 
       attribute (reverse)
  
    after field vigfnl
       if r_ctc58m02[l_aux].vigfnl is null then
          next field vigfnl 
       else  
         display r_ctc58m02[l_aux].vigfnl to s_tela[scr_aux].vigfnl 
       end if  
     
    #----Situacao
    before field astcctstt 
       display r_ctc58m02[l_aux].astcctstt to s_tela[scr_aux].astcctstt 
       attribute (reverse)

    after field astcctstt
       if r_ctc58m02[l_aux].astcctstt is null then
          next field astcctstt 
       else  
         display r_ctc58m02[l_aux].astcctstt to s_tela[scr_aux].astcctstt 
       end if  

    after row
       if r_aux.ramcod <> r_ctc58m02[l_aux].ramcod or 
          r_aux.ramcod is  null or  
          r_aux.cctcod <> r_ctc58m02[l_aux].cctcod or
          r_aux.cctcod is  null or
          r_aux.corasspsocod <> r_ctc58m02[l_aux].corasspsocod or
          r_aux.corasspsocod  is  null or
          r_aux.viginc <> r_ctc58m02[l_aux].viginc or
          r_aux.viginc is  null or
          r_aux.vigfnl <> r_ctc58m02[l_aux].vigfnl or
          r_aux.vigfnl is  null or
          r_aux.astcctstt  <> r_ctc58m02[l_aux].astcctstt or
          r_aux.astcctstt  is  null then
          if r_ctc58m02[l_aux].ramcod is not null and 
             r_ctc58m02[l_aux].cctcod is not null and 
             r_ctc58m02[l_aux].corasspsocod is not null and 
             r_ctc58m02[l_aux].viginc is not null and 
             r_ctc58m02[l_aux].vigfnl is not null and 
             r_ctc58m02[l_aux].astcctstt is not null then 
             let r_ctc58m02[l_aux].flg = 'S' 
             let l_flg_aux = 'S'
             initialize r_aux to null
          end if 
       end if 
       let l_totalitens = l_aux

       
    on key (f1)
        let l_opcao = 'I'
        call ctc58m02_grava()

    on key (f2)
      next field ramcod 

 end input

end function
 
#--------------------------------------------------------------------
function ctc58m02_grava()
#--------------------------------------------------------------------
     
define l_astcctseq     like dattastcct.astcctseq
define l_resp          char(01)
define l_today         date

let l_astcctseq = 0 

 let w_comando = "insert into  dattastcct  ",
                            " (c24astcod,      ",
                            " ramcod,         ",
                            " astcctseq,     ",
                            " cctcod,         ",
                            " corasspsocod,   ",
                            " viginc,         ",
                            " vigfnl,         ",
                            " astcctstt,      ",
                            " atlusrtip,      ",
                            " atlemp,         ",
                            " atlmat,         ",
                            " atldat)         ",
                 " values  (?,?,?,?,?,?,?,?,?,?,?,?) "         

  prepare pctc58m02007 from w_comando


    let w_obs = " (F17)Abandona  (F1)Inclui   (F9)Historico "
    display w_obs to obs   

    call ctc58m02_input()

    if l_flg_aux = 'S' then 
       begin work
       while true
         if l_opcao = 'M' then
            prompt " Deseja gravar as alteracoes ?(s/n)"
            for l_resp
         else
            prompt " Deseja gravar as informacoes ?(s/n) "
            for l_resp
         end if 
            if (l_resp <> "S"  and
                l_resp <> "s"  and
                l_resp <> "N"  and
                l_resp <> "n") then
                   error " Digite 's' para confirmar ou 'n' para cancelar. "
               continue while
            end if
            exit while
       end while
   
       if l_resp <> "S" and
          l_resp <> "s" then
          if l_opcao = 'M' then
             error " Alteracao cancelada! "
          else
             error " Inclusao cancelada! "
          end if 
          rollback work
          return
       end if

       whenever error stop
  
       let l_today = today
       open cctc58m02008 
       fetch cctc58m02008 into l_astcctseq
          if l_astcctseq is null or
             l_astcctseq = 0 then 
             let l_astcctseq = 0
          end if 
 
          for l_aux = 1 to l_totalitens
            if r_ctc58m02[l_aux].flg = 'S' then 
               let l_astcctseq = l_astcctseq + 1

               execute pctc58m02007 using f_c24astcod,
                                          r_ctc58m02[l_aux].ramcod, 
                                          l_astcctseq,
                                          r_ctc58m02[l_aux].cctcod, 
                                          r_ctc58m02[l_aux].corasspsocod, 
                                          r_ctc58m02[l_aux].viginc, 
                                          r_ctc58m02[l_aux].vigfnl, 
                                          r_ctc58m02[l_aux].astcctstt, 
                                          g_issk.usrtip, 
                                          g_issk.empcod, 
                                          g_issk.funmat, 
                                          l_today 
            end if 
          end for

       whenever error stop
       if sqlca.sqlcode <> 0 then
          if l_opcao = 'M' then
             error "Erro: ", sqlca.sqlcode
                  ,", Problemas na alteracao do registro na tabela dattastcct! "
          else
             error "Erro: ", sqlca.sqlcode
                  ,", Problemas na inclusao do registro na tabela dattastcct! "
          end if 
          rollback work
       else
          commit work
          error " Registro gravado! "
       end if
       call ctc58m02_mostra_dados()
    end if  

end function



   

        




