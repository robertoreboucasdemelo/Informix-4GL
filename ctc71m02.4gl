###########################################################################
#                       PORTO SEGURO CIA DE SEGUROS GERAIS
#
# Sistema   : 
# Programa  : Pesquisa dos responsaveis do local
# Modulo    : ctc71m02.4gl
#
# Objetivo: Pesquisar os responsaveis pelo registro gravado.
#
# Analista Responsavel: Glauce
# Programador         : Paula Romanini
# Data da Criacao     : 12/03/2004 - Fabrica de Software
# PSI/OSF             : 183024/33529
#------------------------------------------------------------------------------
# A L T E R A C O E S :
#------------------------------------------------------------------------------
# Data        PSI/OSF      Descricao      Situacao        Responsavel
#
###############################################################################

database porto

define m_flag smallint

##main
## call ctc71m02(1)
##end main

#==============================================================================
function ctc71m02_prepare()
#==============================================================================

 define l_comando  char(600)

 
 let l_comando = " select cadhordat, atlhordat, canhordat, atlemp    "
                ,"       ,atlmat   , atlusrtip, cademp   , cadmat    "
                ,"       ,cadusrtip, canemp   , canmat   , canusrtip "
                ,"   from datkfxolcl                                 "
                ,"  where c24fxolclcod = ?                           "
 prepare pctc71m02001 from l_comando
 declare cctc71m02001 cursor for pctc71m02001

 
 let l_comando = " select funnom     "
                ,"   from isskfunc   "
                ,"  where funmat = ? "
                ,"    and empcod = ? "
                ,"    and usrtip = ? "
 prepare pctc71m02002 from l_comando
 declare cctc71m02002 cursor for pctc71m02002


 let m_flag = true

end function #--> ctc71m02_prepare()

#==============================================================================
function ctc71m02(l_c24fxolclcod)
#==============================================================================

 define l_c24fxolclcod   like datkfxolcl.c24fxolclcod

 define l_ctc71m02 record
   cadhordat  char(18)
  ,cadnom     like isskfunc.funnom
  ,atlhordat  char(18)
  ,atlnom     like isskfunc.funnom
  ,canhordat  char(18)
  ,cannom     like isskfunc.funnom
 end record

 define l_atlemp     like datkfxolcl.atlemp
       ,l_atlmat     like datkfxolcl.atlmat     
       ,l_atlusrtip  like datkfxolcl.atlusrtip
       ,l_cademp     like datkfxolcl.cademp
       ,l_cadmat     like datkfxolcl.cadmat
       ,l_cadusrtip  like datkfxolcl.cadusrtip
       ,l_canemp     like datkfxolcl.canemp
       ,l_canmat     like datkfxolcl.canmat
       ,l_canusrtip  like datkfxolcl.canusrtip
       ,l_dathor1    char(25)
       ,l_dathor2    char(25)
       ,l_dathor3    char(25)
       ,l_resp       char(01)

 #----------------------#
 # Prepara comandos SQL #
 #----------------------#
 if m_flag <> true then
    call ctc71m02_prepare()
 end if

 options prompt line last
        ,message line last
 
 open window s_ctc71m02 at 07,10 with form "ctc71m02"
      attribute(form line 1,border)
 

      #----------------------------------------------------------------------#
      # Utilizando o cursor 'cctc71m02001' - Sel. dados da tab. 'datkfxolcl' #
      #----------------------------------------------------------------------#
      whenever error continue
      open cctc71m02001 using l_c24fxolclcod
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'datkfxolcl' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if
      whenever error continue
      fetch cctc71m02001 into l_dathor1
                             ,l_dathor2
                             ,l_dathor3
                             ,l_atlemp
                             ,l_atlmat
                             ,l_atlusrtip
                             ,l_cademp
                             ,l_cadmat
                             ,l_cadusrtip
                             ,l_canemp
                             ,l_canmat
                             ,l_canusrtip
   
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'datkfxolcl' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if

       let l_ctc71m02.cadhordat = l_dathor1[9,10],"/",
                                  l_dathor1[6,7] ,"/",
                                  l_dathor1[1,4] ," ",
                                  l_dathor1[12,16]

       let l_ctc71m02.atlhordat = l_dathor2[9,10],"/",
                                  l_dathor2[6,7] ,"/",
                                  l_dathor2[1,4] ," ",
                                  l_dathor2[12,16]

       let l_ctc71m02.canhordat = l_dathor3[9,10],"/",
                                  l_dathor3[6,7] ,"/",
                                  l_dathor3[1,4] ," ",
                                  l_dathor3[12,16]

      close cctc71m02001

      #---        Seleciona o nome do responsavel pelo cadastro         ---#
      #--------------------------------------------------------------------#
      # Utilizando o cursor 'cctc71m02002' - Sel. dados da tab. 'isskfunc' #
      #--------------------------------------------------------------------#
      whenever error continue
      open cctc71m02002 using l_cadmat
                             ,l_cademp
                             ,l_cadusrtip
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'isskfunc' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if
      whenever error continue
      fetch cctc71m02002 into l_ctc71m02.cadnom
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'isskfunc' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if

      #---   Seleciona o nome do responsavel pela ultima atualizacao    ---#
      #--------------------------------------------------------------------#
      # Utilizando o cursor 'cctc71m02002' - Sel. dados da tab. 'isskfunc' #
      #--------------------------------------------------------------------#
      whenever error continue
      open cctc71m02002 using l_atlmat
                             ,l_atlemp
                             ,l_atlusrtip
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'isskfunc' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if
      whenever error continue
      fetch cctc71m02002 into l_ctc71m02.atlnom
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'isskfunc' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if

      #---       Seleciona o nome do responsavel pelo cancelamento      ---#
      #--------------------------------------------------------------------#
      # Utilizando o cursor 'cctc71m02002' - Sel. dados da tab. 'isskfunc' #
      #--------------------------------------------------------------------#
      whenever error continue
      open cctc71m02002 using l_canmat
                             ,l_canemp
                             ,l_canusrtip
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'isskfunc' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if
      whenever error continue
      fetch cctc71m02002 into l_ctc71m02.cannom
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'isskfunc' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if
      close cctc71m02002

     display by name l_ctc71m02.*


     let int_flag = false
     while not int_flag
           prompt " " for char l_resp
     end while
     close window s_ctc71m02

end function #--> ctc71m02()
