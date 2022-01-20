#------------------------------------------------------------------------------#
#                       PORTO SEGURO CIA DE SEGUROS GERAIS                     #
#..............................................................................#
#  Sistema        : CT24H                                                      #
#  Modulo         : cts18m11.4gl                                               #
#  Objetivo       : Para retornar os dados do principal condutor de acordo     #
#                   com a apolice ou proposta                                  #
#  Analista Resp. :                                                            #
#  PSI/OSF        : 172090 / 32859                                             #
#..............................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE, Amaury Gimenez                        #
#  Liberacao      :                                                            #
#..............................................................................#
#                  * * *  A L T E R A C O E S  * * *                           #
#                                                                              #
# Data       Autor Fabrica         PSI    Alteracoes                           #
# ---------- --------------------- ------ -------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco.  #
# ---------- --------------------- ------ -------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a     #
#                                         global                               #
#------------------------------------------------------------------------------#
# 05/01/2010 Amilton                      projeto sucursal smallint            #
#------------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689


{TESTES -------------------------------------------
database porto

  define l_ret_faemc049            record
         tipo_motorista          char(01)
        ,nome_principal_condutor   char(50)
        ,cgccpfnum_condutor        dec(12,0)
        ,cgcord_condutor           dec(04,0)
        ,cgccpfdig_condutor        dec(02,0)
        ,cnh_condutor              dec(12,0)
        ,data_exame_condutor       date
        ,idade_condutor            dec(02,0)
        ,sexo_condutor             char(01)
  end record
  main
    call fun_dba_abre_banco("CT24HS")
    call cts18m11_condutor_veiculo(1,217671,0,"JOAO ALVES DE REZENDE","","")
        returning l_ret_faemc049.*
    display l_ret_faemc049.*
  end main
TESTES ------------------------------------------- }

#-------------------------------------------------------------------------------
function cts18m11_condutor_veiculo(l_param)
#-------------------------------------------------------------------------------

  define l_param  record
         succod      smallint #dec(2,0) projeto succod
        ,aplnumdig   dec(9,0)
        ,itmnumdig   dec(7,0)
        ,segnom      char(50)
        ,prporg      dec(2,0)
        ,prpnumdig   dec(8,0)
  end record

  define l_tipo_motorista          char(01)

  define l_ret_faemc049            record
         nome_principal_condutor   char(50)
        ,cgccpfnum_condutor        dec(12,0)
        ,cgcord_condutor           dec(04,0)
        ,cgccpfdig_condutor        dec(02,0)
        ,cnh_condutor              dec(12,0)
        ,data_exame_condutor       date
        ,idade_condutor            dec(02,0)
        ,sexo_condutor             char(01)
       #,est_civil_condutor        smallint
       #,vinculo_condutor          char(20)
       #,cod_profissao_condutor    dec(04,0)
       #,desc_profissao_condutor   char(60)
  end record

  define l_resp      char(05)
        ,l_tipo_pesq smallint

  define l_dados    record
         selsegnom  char(50)
        ,selprpcon  char(50)
        ,seloutros  char(13)
  end record

  if l_param.prpnumdig is not null then
     let l_tipo_pesq = 2
  end if
  if l_param.aplnumdig is not null then
     let l_tipo_pesq = 1
  end if

  initialize l_ret_faemc049.* to null
  call figrc072_setTratarIsolamento()        --> 223689
  call faemc049_dados_condutor(l_param.succod
                              ,l_param.aplnumdig
                              ,l_param.itmnumdig
                              ,l_param.prporg
                              ,l_param.prpnumdig
                              ,l_tipo_pesq)
       returning l_ret_faemc049.*
  if g_isoAuto.sqlCodErr <> 0 then --> 223689
     error "Função faemc049 indisponivel no momento ! Avise a Informatica !" sleep 2
     return l_tipo_motorista ,l_ret_faemc049.*
  end if    --> 223689

  #--------------------------------------------------------------------------
  # Se tiver perfil, exibe a tela para escolha do motorista, se nao tiver
  # perfil, a tela nao sera exibida.
  #--------------------------------------------------------------------------
  if l_ret_faemc049.nome_principal_condutor is null then
     return l_tipo_motorista ,l_ret_faemc049.*
  end if

  open window w_cts18m11 at 16,04 with form "cts18m11"
  attribute(border, form line 1)

  display by name l_param.segnom
  display l_ret_faemc049.nome_principal_condutor to condutor
  display "Outro Condutor" to outro

  input by name l_dados.*
     before field selsegnom
        display by name l_param.segnom attribute(reverse)

     after field selsegnom
        display by name l_param.segnom

     before field selprpcon
        display l_ret_faemc049.nome_principal_condutor to condutor
        attribute(reverse)

     after field selprpcon
        display l_ret_faemc049.nome_principal_condutor to condutor

     before field seloutros
        display "Outro Condutor" to outro attribute(reverse)

     after field seloutros
        display "Outro Condutor" to outro
        next field selsegnom

     on key(f8)
        if infield(selsegnom) then
           initialize l_ret_faemc049.* to null
           let l_tipo_motorista = "S"
        end if
        if infield(selprpcon) then
           let l_tipo_motorista = "C"
        end if
        if infield(seloutros) then
           let l_tipo_motorista = "O"
        end if
        exit input

     on key(interrupt,f17)
        initialize l_ret_faemc049.* to null
        let l_tipo_motorista = ""
        exit input

  end input
  let int_flag = false

  close window w_cts18m11

  return l_tipo_motorista ,l_ret_faemc049.*

end function
