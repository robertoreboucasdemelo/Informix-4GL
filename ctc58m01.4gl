################################################################################
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        :  Central24h                                                 #
# Modulo         :  ctc58m01                                                   #
# Analista Resp. :  Raji                                                       #
# PSI            :  146994 - Cadastro de  Centro de Custo para                 #
#                            Agrupamento de Assunto da Central 24h             #
#..............................................................................#
# Desenvolvimento:  Fabrica de Software - Cristina                             #
# Data           :  08/02/2002                                                 #
# Liberacao      :                                                             #
#..............................................................................#
#                     * * *  ALTERACOES * * *                                  #
#                                                                              #
# Data        Autor Fabrica       PSI    Alteracao                             #
# ----        -------------       ----   ---------                             #
# 22/04/2003  Aguinaldo Costa     168920 Resolucao 86                          #
#                                                                              #
# 14/06/2005  Helio (Meta)        192341 Unificacao de Centros de Custo        #
################################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define f_c24astagpdes  like datkastagp.c24astagpdes
define f_c24astagp     like datkastagp.c24astagp

define l_opcao         char(01)
define w_comando       char(1000)
define l_aux           smallint
define scr_aux         smallint
define l_totalitens    smallint
define w_obs           char(80)
define l_flg_aux       char(01)

define r_ctc58m01 array[300] of record
       ramcod          like dattagpcct.ramcod,
       ramnom          like gtakram.ramnom,
       cctcod          like dattagpcct.cctcod,
       cctnom          like ctokcentrosuc.cctnom,
       corasspsocod    like dattagpcct.corasspsocod,
       viginc          like dattagpcct.viginc,
       vigfnl          like dattagpcct.vigfnl,
       cctagpstt       like dattagpcct.cctagpstt,
       flg             char(01)
end record

#tirar
# main 

#   let g_issk.usrtip = 1
#   let g_issk.empcod = 1
#   let g_issk.funmat = 932

#   defer interrupt
#   call ctc58m01()
# end main

#-----------------------------------------------------------------------
function ctc58m01()
#-----------------------------------------------------------------------



open window w_ctc58m01 at 4,2 with form "ctc58m01"
     attribute(form line first, comment line last - 2)

  let w_obs = " (F17)Abandona  (F9)Historico "
  display w_obs to obs   
   
   menu "CUSTOS"
      before menu
         hide option all
         show option "Seleciona", 
                     "Proximo", 
                     "Anterior",
                     "Modifica",
                     "Incluir",
                     "Excecao",
                     "Encerra"

      command "Seleciona" "Pesquisa Agrupamentos conforme criterios"
         let l_opcao = "S"
         clear form
         call ctc58m01_selecao()

      command "Proximo" "Mostra proxima linha selecionada"
         if f_c24astagp is not null or
            f_c24astagp <> " "  then
            let l_opcao = "P"
            call ctc58m01_proximo()
         else
            error " Nenhum agrupamento selecionado "
            next option "Seleciona"
         end if

      command "Anterior" "Mostra linha anterior selecionada"
         if f_c24astagp is not null or
            f_c24astagp <> " "  then
            let l_opcao = "A"
            call ctc58m01_proximo()
         else
            error " Nenhum agrupamento selecionado "
            next option "Seleciona"
         end if

      command "Modifica" "Modifica a linha atual"
         if f_c24astagp is not null or 
            f_c24astagp <> " "  then
               let l_opcao = "M"
              call ctc58m01_grava()
         else
            error " Nenhum agrupamento selecionado "
            next option "Seleciona"
         end if

      command "Incluir" "Inclui uma nova linha"
         if f_c24astagp is not null or 
            f_c24astagp <> " "  then
               let l_opcao = "I"
              call ctc58m01_grava()
         else
            error " Nenhum agrupamento selecionado "
            next option "Seleciona"
         end if


       command key (x) "Excecao" 
          call ctc58m02()

      command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
         let l_opcao = " "
         exit menu

   end menu

   close window w_ctc58m01

end function

#-----------------------------------------------------------------------
function ctc58m01_selecao()
#-----------------------------------------------------------------------

  let w_comando = " select c24astagpdes   ",
                  "   from datkastagp     ", 
                  "  where c24astagp = ?  " 
  prepare pctc58m01001 from w_comando
  declare cctc58m01001 cursor for pctc58m01001 

  let w_obs = " (F17)Abandona  (F9)Historico "
  display w_obs to obs   

  input f_c24astagp
  from c24astagp
       
      before field c24astagp
          display f_c24astagp  to  c24astagp  attribute(reverse)
          
      after field c24astagp
         if f_c24astagp is null then
            let f_c24astagp = null 
            next field c24astagp
         end if 
          
         open cctc58m01001 using f_c24astagp
         fetch cctc58m01001 into f_c24astagpdes
           if sqlca.sqlcode <> 0 then
             error "Assunto nao Cadastrado"
             next field c24astagp
           else
             display f_c24astagp     to c24astagp  
             display f_c24astagpdes  to c24astagpdes  
          end if 

    after input
        call ctc58m01_mostra_dados()


     on key (interrupt)
        exit input

  end input 

end function

#-----------------------------------------------------------------------
function ctc58m01_proximo()
#-----------------------------------------------------------------------

define l_c24astagp     like datkastagp.c24astagp

    let w_obs = " (F17)Abandona  (F9)Historico "
    display  w_obs to obs

    if l_opcao = 'P' then 
       let w_comando = " select min(c24astagp)   ",
                       "   from datkastagp     ", 
                       "  where c24astagp > ?  " 
    else
       let w_comando = " select max(c24astagp)   ",
                       "   from datkastagp     ", 
                       "  where c24astagp < ?  " 
    end if 
    prepare pctc58m01006 from w_comando
    declare cctc58m01006 cursor for pctc58m01006 

    open cctc58m01006 using f_c24astagp
    fetch cctc58m01006 into l_c24astagp
 
      if sqlca.sqlcode <> 0 then
         error "Nao exite registro posterior ao selecionado"
      else  
        let f_c24astagp = l_c24astagp
        open cctc58m01001 using f_c24astagp
        fetch cctc58m01001 into f_c24astagpdes
          if sqlca.sqlcode <> 0 then
            error "Assunto nao Cadastrado"
          else
            display f_c24astagp     to  c24astagp  
            display f_c24astagpdes  to  c24astagpdes  
         end if 
         call ctc58m01_mostra_dados()
      end if 
         
end function

#-------------------------------------------------------------------
function ctc58m01_mostra_dados()
#-------------------------------------------------------------------

define r_param   array[300] of record
       agpcctseq     like dattagpcct.agpcctseq,
       ramcod        like dattagpcct.ramcod 
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
    initialize r_ctc58m01[l_aux].*  to null
end for

  let w_comando = " select ramcod, max(agpcctseq)  ",
                  "   from dattagpcct     ", 
                  "  where c24astagp = ?  ", 
                  " group by 1             "

  prepare pctc58m01002 from w_comando
  declare cctc58m01002 cursor for pctc58m01002 

  let w_comando = " select ramcod, cctcod, corasspsocod,  ",
                  "        viginc, vigfnl, cctagpstt      ",
                  "   from dattagpcct     ", 
                  "  where agpcctseq = ?  " 

  prepare pctc58m01003 from w_comando
  declare cctc58m01003 cursor for pctc58m01003 

  let w_comando = " select ramnom  ",
                  "   from gtakram     ", 
                  "  where ramcod = ?  ",
                  "    and empcod = 1  " 

  prepare pctc58m01004 from w_comando
  declare cctc58m01004 cursor for pctc58m01004 

  #let w_comando = " select cctnom  ",
  #                "   from ctokcentrosuc     ", 
  #                "  where cctcod = ?  " 
#
  #prepare pctc58m01005 from w_comando
  #declare cctc58m01005 cursor for pctc58m01005 

  let w_comando = " select max(agpcctseq)   ",
                  "   from dattagpcct      "
    
  prepare pctc58m01008 from w_comando
  declare cctc58m01008 cursor for pctc58m01008 

  let w_obs = " (F17)Abandona  (F9)Historico "
  display w_obs to obs   

  set isolation to dirty read

  let l_aux = 1 
  open cctc58m01002 using f_c24astagp
  foreach cctc58m01002 into r_param[l_aux].ramcod,
                            r_param[l_aux].agpcctseq
     if sqlca.sqlcode <> 0 then
       error "Nenhuma sequencia cadastrada"
     end if 

     open cctc58m01003 using r_param[l_aux].agpcctseq
     fetch cctc58m01003 into r_ctc58m01[l_aux].ramcod, 
                             r_ctc58m01[l_aux].cctcod,
                             r_ctc58m01[l_aux].corasspsocod,
                             r_ctc58m01[l_aux].viginc,
                             r_ctc58m01[l_aux].vigfnl,
                             r_ctc58m01[l_aux].cctagpstt
        
      open cctc58m01004 using r_ctc58m01[l_aux].ramcod
      fetch cctc58m01004 into r_ctc58m01[l_aux].ramnom
        if sqlca.sqlcode <> 0 then
          error "Ramo: ", r_ctc58m01[l_aux].ramcod, "  nao cadastrado"
        end if 

        #open cctc58m01005 using r_ctc58m01[l_aux].cctcod
        #fetch cctc58m01005 into r_ctc58m01[l_aux].cctnom
        #  if sqlca.sqlcode <> 0 then
        #    error "Centro de Custo: ", r_ctc58m01[l_aux].cctcod, "  nao cadastrado"
        #  end if 

        #PSI 192341
        let lr_param.empcod = 1
        let lr_param.succod = 1 
        let lr_param.cctlclcod = (r_ctc58m01[l_aux].cctcod / 10000)
        let lr_param.cctdptcod = (r_ctc58m01[l_aux].cctcod mod 10000)

        call fctgc102_vld_dep(lr_param.*)
	   returning lr_ret.*

        let r_ctc58m01[l_aux].cctnom = lr_ret.cctdptnom 

        let r_ctc58m01[l_aux].flg = " " 
        let l_aux = l_aux + 1 
  end foreach

    let l_totalitens =  l_aux - 1

    if l_totalitens = 0 then
       error "Nao encontrou nenhuma ocorrencia que satisfaca a consulta"
    end if 
    call set_count(l_totalitens)
    display array r_ctc58m01 to s_tela.*

     on key (f9) 
       let l_aux = arr_curr()
       call ctc58m03('AGP',f_c24astagp,r_ctc58m01[l_aux].ramcod)

   end display


end function

#--------------------------------------------------------------------
function ctc58m01_input() 
#--------------------------------------------------------------------

define r_aux record
       ramcod          like dattagpcct.ramcod,
       ramnom          like gtakram.ramnom,
       cctcod          like dattagpcct.cctcod,
       cctnom          like ctokcentrosuc.cctnom,
       corasspsocod    like dattagpcct.corasspsocod,
       viginc          like dattagpcct.viginc,
       vigfnl          like dattagpcct.vigfnl,
       cctagpstt       like dattagpcct.cctagpstt
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

    input array  r_ctc58m01
    without defaults from s_tela.*    

    before row
         let l_aux = arr_curr()
         let scr_aux = scr_line() 

         let r_ctc58m01[l_aux].flg = 'N' 
         let r_aux.ramcod         = r_ctc58m01[l_aux].ramcod
         let r_aux.ramnom         = r_ctc58m01[l_aux].ramnom
         let r_aux.cctcod         = r_ctc58m01[l_aux].cctcod
         let r_aux.cctnom         = r_ctc58m01[l_aux].cctnom
         let r_aux.corasspsocod   = r_ctc58m01[l_aux].corasspsocod
         let r_aux.viginc         = r_ctc58m01[l_aux].viginc
         let r_aux.vigfnl         = r_ctc58m01[l_aux].vigfnl
         let r_aux.cctagpstt      = r_ctc58m01[l_aux].cctagpstt

    #----Ramo
    before field ramcod 
      if r_ctc58m01[l_aux].ramcod is not  null or 
         r_ctc58m01[l_aux].ramcod <> " " then
         next field cctcod
      else
        display r_ctc58m01[l_aux].ramcod to s_tela[scr_aux].ramcod 
        attribute (reverse)
      end if

    after field ramcod
       if r_ctc58m01[l_aux].ramcod is null then
          next field ramcod 
       else  
         open cctc58m01004 using r_ctc58m01[l_aux].ramcod
         fetch cctc58m01004 into r_ctc58m01[l_aux].ramnom
            if sqlca.sqlcode <> 0 then
               error "Ramo ", r_ctc58m01[l_aux].ramcod , "nao cadastrado"
            else
              display r_ctc58m01[l_aux].ramcod to s_tela[scr_aux].ramcod 
              display r_ctc58m01[l_aux].ramnom to s_tela[scr_aux].ramnom 
            end if 
       end if 
 
    #----Codigo do Centro de Custo
    before field cctcod
       display r_ctc58m01[l_aux].cctcod to s_tela[scr_aux].cctcod 
       attribute (reverse)
   
    after field cctcod
       if r_ctc58m01[l_aux].cctcod is null then
          next field cctcod 
       else  
          #open cctc58m01005 using r_ctc58m01[l_aux].cctcod
          #fetch cctc58m01005 into r_ctc58m01[l_aux].cctnom
          #  if sqlca.sqlcode <> 0 then
          #     error "Centro de Custo ", r_ctc58m01[l_aux].cctcod, 
          #           " nao cadastrado"
          #     initialize r_ctc58m01[l_aux].cctcod to null
          #     display r_ctc58m01[l_aux].cctcod to s_tela[scr_aux].cctcod 
          #     next field cctcod
          #  else
          #    display r_ctc58m01[l_aux].cctcod to s_tela[scr_aux].cctcod 
          #    display r_ctc58m01[l_aux].cctnom to s_tela[scr_aux].cctnom 
          #  end if 

          #PSI 192341
          let lr_param.empcod = 1
          let lr_param.succod = 1 
          let lr_param.cctlclcod = (r_ctc58m01[l_aux].cctcod / 10000)
          let lr_param.cctdptcod = (r_ctc58m01[l_aux].cctcod mod 10000)

          call fctgc102_vld_dep(lr_param.*)
	     returning lr_ret.*
	   
	  if lr_ret.erro <> 0 then
	     error lr_ret.mens
             initialize r_ctc58m01[l_aux].cctcod to null
             display r_ctc58m01[l_aux].cctcod to s_tela[scr_aux].cctcod
             next field cctcod
          end if

          let r_ctc58m01[l_aux].cctnom = lr_ret.cctdptnom 
          display r_ctc58m01[l_aux].cctcod to s_tela[scr_aux].cctcod 
          display r_ctc58m01[l_aux].cctnom to s_tela[scr_aux].cctnom 

       end if 

    #----Peso
    before field corasspsocod 
       display r_ctc58m01[l_aux].corasspsocod to s_tela[scr_aux].corasspsocod 
       attribute (reverse)

    after field corasspsocod
       if r_ctc58m01[l_aux].corasspsocod is null then
          next field corasspsocod 
       else  
         display r_ctc58m01[l_aux].corasspsocod to s_tela[scr_aux].corasspsocod 
       end if  
  
    #----Vigencia Inicial
    before field viginc 
       display r_ctc58m01[l_aux].viginc to s_tela[scr_aux].viginc 
       attribute (reverse)
  
    after field viginc
       if r_ctc58m01[l_aux].viginc is null then
          next field viginc 
       else  
         display r_ctc58m01[l_aux].viginc to s_tela[scr_aux].viginc 
       end if 
            
    #----Vigencia Final
    before field vigfnl 
       display r_ctc58m01[l_aux].vigfnl to s_tela[scr_aux].vigfnl 
       attribute (reverse)
  
    after field vigfnl
       if r_ctc58m01[l_aux].vigfnl is null then
          next field vigfnl 
       else  
         display r_ctc58m01[l_aux].vigfnl to s_tela[scr_aux].vigfnl 
       end if  
     
    #----Situacao
    before field cctagpstt 
       display r_ctc58m01[l_aux].cctagpstt to s_tela[scr_aux].cctagpstt 
       attribute (reverse)

    after field cctagpstt
       if r_ctc58m01[l_aux].cctagpstt is null then
          next field cctagpstt 
       else  
         display r_ctc58m01[l_aux].cctagpstt to s_tela[scr_aux].cctagpstt 
       end if  

    after row
       if r_aux.ramcod <> r_ctc58m01[l_aux].ramcod or 
          r_aux.ramcod is  null or  
          r_aux.cctcod <> r_ctc58m01[l_aux].cctcod or
          r_aux.cctcod is  null or
          r_aux.corasspsocod <> r_ctc58m01[l_aux].corasspsocod or
          r_aux.corasspsocod  is  null or
          r_aux.viginc <> r_ctc58m01[l_aux].viginc or
          r_aux.viginc is  null or
          r_aux.vigfnl <> r_ctc58m01[l_aux].vigfnl or
          r_aux.vigfnl is  null or
          r_aux.cctagpstt  <> r_ctc58m01[l_aux].cctagpstt or
          r_aux.cctagpstt  is  null then
          if r_ctc58m01[l_aux].ramcod is not null and 
             r_ctc58m01[l_aux].cctcod is not null and 
             r_ctc58m01[l_aux].corasspsocod is not null and 
             r_ctc58m01[l_aux].viginc is not null and 
             r_ctc58m01[l_aux].vigfnl is not null and 
             r_ctc58m01[l_aux].cctagpstt is not null then 
             let r_ctc58m01[l_aux].flg = 'S' 
             initialize r_aux to null
             let l_flg_aux = 'S'
          end if 
       end if 
       let l_totalitens = l_aux

       
    on key (f1)
        let l_opcao = 'I'
        call ctc58m01_grava()


 end input

end function
 
#--------------------------------------------------------------------
function ctc58m01_grava()
#--------------------------------------------------------------------
     
define l_agpcctseq     like dattagpcct.agpcctseq
define l_resp          char(01)
define l_today         date

 let w_comando = "insert into  dattagpcct  ",
                            " (agpcctseq,     ",
                            " c24astagp,      ",
                            " ramcod,         ",
                            " cctcod,         ",
                            " corasspsocod,   ",
                            " viginc,         ",
                            " vigfnl,         ",
                            " cctagpstt,      ",
                            " atlusrtip,      ",
                            " atlemp,         ",
                            " atlmat,         ",
                            " atldat)         ",
                 " values  (?,?,?,?,?,?,?,?,?,?,?,?) "         

  prepare pctc58m01007 from w_comando


   let w_obs = " (F17)Abandona  (F1)Inclui   (F9)Historico "
   display w_obs to obs   

   call ctc58m01_input()

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
      open cctc58m01008 
      fetch cctc58m01008 into l_agpcctseq
         if l_agpcctseq is null or
             l_agpcctseq = 0 then
             let l_agpcctseq = 0
          end if

        for l_aux = 1 to l_totalitens
           if r_ctc58m01[l_aux].flg = 'S' then 
              let l_agpcctseq = l_agpcctseq + 1
              execute pctc58m01007 using l_agpcctseq,
                                         f_c24astagp,
                                         r_ctc58m01[l_aux].ramcod, 
                                         r_ctc58m01[l_aux].cctcod, 
                                         r_ctc58m01[l_aux].corasspsocod, 
                                         r_ctc58m01[l_aux].viginc, 
                                         r_ctc58m01[l_aux].vigfnl, 
                                         r_ctc58m01[l_aux].cctagpstt, 
                                         g_issk.usrtip, 
                                         g_issk.empcod, 
                                         g_issk.funmat, 
                                         l_today 
            end if 
        end for

        whenever error stop
        if sqlca.sqlcode <> 0 then
           if l_opcao = 'M' then
              error "Erro: ", sqlca.sqlcode,
                   ", Problemas na alteracao do registro na tabela dattagpcct! "
           else
              error "Erro: ", sqlca.sqlcode,
                   ", Problemas na inclusao do registro na tabela dattagpcct! "
           end if 
           rollback work
        else
           commit work
           error " Registro gravado! "
        end if
        call ctc58m01_mostra_dados()
   end if 

end function



   

        




