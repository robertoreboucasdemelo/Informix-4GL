###########################################################################
#                       PORTO SEGURO CIA DE SEGUROS GERAIS
#
# Sistema   : 
# Programa  : Pesquisa de endereco
# Modulo    : ctc71m03.4gl
#
# Objetivo: Pesquisar o endereco do local selecionado.
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
# call ctc71m03(1)
##end main

#==============================================================================
function ctc71m03_prepare()
#==============================================================================

 define l_comando  char(600)

 
 let l_comando = " select lgdtip, lgdnom, lgdnum, brrnom  "
                ,"   from datkfxolcl                      "
                ,"  where c24fxolclcod = ?                "
 prepare pctc71m03001 from l_comando
 declare cctc71m03001 cursor for pctc71m03001

 let m_flag = true

end function #--> ctc71m03_prepare()

#==============================================================================
function ctc71m03(l_c24fxolclcod)
#==============================================================================

 define l_c24fxolclcod   like datkfxolcl.c24fxolclcod

 define l_ctc71m03 record
   lgdtip     like datkfxolcl.lgdtip
  ,lgdnom     like datkfxolcl.lgdnom
  ,lgdnum     like datkfxolcl.lgdnum
  ,brrnom     like datkfxolcl.brrnom
 end record

 define l_resp char(01)

 #----------------------#
 # Prepara comandos SQL #
 #----------------------#
 if m_flag <> true then
    call ctc71m03_prepare()
 end if

 options prompt  line last
        ,message line last
 
 open window s_ctc71m03 at 07,10 with form "ctc71m03"
      attribute(form line 1,border)
 

      #----------------------------------------------------------------------#
      # Utilizando o cursor 'cctc71m03001' - Sel. dados da tab. 'datkfxolcl' #
      #----------------------------------------------------------------------#
      whenever error continue
      open cctc71m03001 using l_c24fxolclcod
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'datkfxolcl' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if
      whenever error continue
      fetch cctc71m03001 into l_ctc71m03.lgdtip
                             ,l_ctc71m03.lgdnom
                             ,l_ctc71m03.lgdnum
                             ,l_ctc71m03.brrnom
   
      whenever error stop
       if sqlca.sqlcode < 0 then
          error "Erro ao acessar a tabela 'datkfxolcl' ",
                "erro = ",sqlca.sqlcode," ",sqlca.sqlerrd[2] sleep 2
          return
       end if

      close cctc71m03001

     display by name l_ctc71m03.*

     let int_flag = false
     while not int_flag
           prompt " " for char l_resp
     end while
     close window s_ctc71m03

end function #--> ctc71m03()
