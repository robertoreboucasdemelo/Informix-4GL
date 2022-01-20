#############################################################################
# Nome do Modulo: CTS15M09                                         Marcelo  #
#                                                                  Gilberto #
# Tipo de locacao de veiculo                                       Dez/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 31/03/2000  ** ERRO      Akio         Colocar Close window antes do       #
#                                       return                              #
#---------------------------------------------------------------------------#
# 17/05/2002  PSI 13643-3  Wagner       Incluir tipo reserva p/funcionario  #
#---------------------------------------------------------------------------#
# 05/12/2006  PSI 205206   Ruiz         receber ciaempcod no parametro      #
#                                       projeto Azul Seguros.               #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function cts15m09(d_cts15m09)
#--------------------------------------------------------------

 define d_cts15m09   record
    vclloctip        like datmavisrent.vclloctip,
    corsus           like gcaksusep.corsus,
    nomeusu          char (40),
    slcemp           like datmavisrent.slcemp,
    slcsuccod        like datmavisrent.slcsuccod,
    slcmat           like datmavisrent.slcmat,
    slccctcod        like datmavisrent.slccctcod,
    ciaempcod        like datmligacao.ciaempcod
 end record

 define ws           record
    vclloctip        like datmavisrent.vclloctip,
    corsus           like gcaksusep.corsus,
    cornom           char (40),
    slcemp           like datmavisrent.slcemp,
    slcsuccod        like datmavisrent.slcsuccod,
    slcmat           like datmavisrent.slcmat,
    slccctcod        like datmavisrent.slccctcod,
    ciaempcod        like datmservico.ciaempcod
 end record

        initialize  ws.*  to  null

 initialize ws.*          to null

 let ws.vclloctip = d_cts15m09.vclloctip
 let ws.corsus    = d_cts15m09.corsus
 let ws.cornom    = d_cts15m09.nomeusu
 let ws.slcemp    = d_cts15m09.slcemp
 let ws.slcsuccod = d_cts15m09.slcsuccod
 let ws.slcmat    = d_cts15m09.slcmat
 let ws.slccctcod = d_cts15m09.slccctcod
 let ws.ciaempcod = d_cts15m09.ciaempcod

 let int_flag  =  false

 open window cts15m09 at 07,14 with form "cts15m09"
                      attribute (form line 1, border)

 if d_cts15m09.ciaempcod = 35 then
   #display "Tipos: (3)Deptos. ou (4)Func." to msgfun
    display "Tipos: (3)Deptos." to msgfun
 else
    display "Tipos: (1)Segurado, (2)Corretor, (3)Deptos. ou (4)Func." to msgfun
 end if

 if d_cts15m09.vclloctip is not null  then
    display by name d_cts15m09.vclloctip
    if d_cts15m09.ciaempcod = 35 then
       case d_cts15m09.vclloctip
          when 3  display "DEPARTAMENTO" to vcllocdes
        # when 4  display "FUNCIONARIO"  to vcllocdes
       end case
    else
       case d_cts15m09.vclloctip
          when 1  display "SEGURADO"     to vcllocdes
          when 2  display "CORRETOR"     to vcllocdes
          when 3  display "DEPARTAMENTO" to vcllocdes
          when 4  display "FUNCIONARIO"  to vcllocdes
       end case
    end if
 end if

 input by name d_cts15m09.vclloctip  without defaults

   before field vclloctip
      display by name d_cts15m09.vclloctip  attribute (reverse)

   after field vclloctip
      display by name d_cts15m09.vclloctip

      if d_cts15m09.vclloctip is null  then
         error " Tipo da locacao deve ser informado! "
         next field vclloctip
      end if
      if d_cts15m09.ciaempcod = 35 then  # Azul Seguros
        #if d_cts15m09.vclloctip <> 3 and
        #   d_cts15m09.vclloctip <> 4 then
         if d_cts15m09.vclloctip <> 3 then
           #error " Tipos de locacao: (3)Departamento ou (4)Funcionario!"
            error " Tipos de locacao: (3)Departamento!"
            next field vclloctip
         end if
      end if

      case d_cts15m09.vclloctip
         when  1
              display "SEGURADO" to vcllocdes
              initialize d_cts15m09.corsus, d_cts15m09.nomeusu  ,
                         d_cts15m09.slcemp, d_cts15m09.slcsuccod,
                         d_cts15m09.slcmat, d_cts15m09.slccctcod to null

              if (g_documento.succod    is null  or
                  g_documento.ramcod    is null  or
                  g_documento.aplnumdig is null  or
                  g_documento.itmnumdig is null) and
                 (g_documento.prporg    is null  or
                  g_documento.prpnumdig is null) then
                  error " Locacao para segurado deve ter documento localizado/informado! "
                  next field vclloctip
              else
                 exit input
              end if

         when  2
              display "CORRETOR" to vcllocdes
              initialize d_cts15m09.slcemp, d_cts15m09.slcsuccod,
                         d_cts15m09.slcmat, d_cts15m09.slccctcod to null

              call cts15m10(d_cts15m09.corsus, d_cts15m09.nomeusu)
                  returning d_cts15m09.corsus, d_cts15m09.nomeusu

              if d_cts15m09.corsus is null  then
                 error " SUSEP do corretor deve ser informada! "
                 next field vclloctip
              else
                 exit input
              end if

         when  3
              display "DEPARTAMENTO" to vcllocdes
              initialize d_cts15m09.corsus, d_cts15m09.nomeusu to null

              call cts15m08(d_cts15m09.vclloctip,
                            d_cts15m09.slcemp,
                            d_cts15m09.slcsuccod,
                            d_cts15m09.slcmat,
                            d_cts15m09.slccctcod,
                            "A" )            # -->  (A)tualiza/(C)onsulta
                  returning d_cts15m09.slcemp,
                            d_cts15m09.slcsuccod,
                            d_cts15m09.slcmat,
                            d_cts15m09.slccctcod,
                            d_cts15m09.nomeusu  #-> neste caso nome funcionario

              if d_cts15m09.slcemp    is null  or
                 d_cts15m09.slcsuccod is null  or
                 d_cts15m09.slcmat    is null  or
                 d_cts15m09.slccctcod is null  then
                 error " Dados do departamento/centro de custo devem ser informados!"
                 next field vclloctip
              else
                 exit input
              end if

         when  4
              display "FUNCIONARIO" to vcllocdes
              initialize d_cts15m09.corsus, d_cts15m09.nomeusu to null

              call cts15m08(d_cts15m09.vclloctip,
                            d_cts15m09.slcemp,
                            d_cts15m09.slcsuccod,
                            d_cts15m09.slcmat,
                            d_cts15m09.slccctcod,
                            "A" )            # -->  (A)tualiza/(C)onsulta
                  returning d_cts15m09.slcemp,
                            d_cts15m09.slcsuccod,
                            d_cts15m09.slcmat,
                            d_cts15m09.slccctcod,
                            d_cts15m09.nomeusu   #-> neste caso nome funcionario

              if d_cts15m09.slcemp    is null  or
                 d_cts15m09.slcsuccod is null  or
                 d_cts15m09.slcmat    is null  then
                 error "Dados do departamento/funcionario devem ser informados!"
                 next field vclloctip
              else
                 exit input
              end if

         otherwise
              if d_cts15m09.ciaempcod = 35 then  # Azul Seguros
                #error " Tipos de locacao: (3)Departamento ou (4)Funcionario!"
                 error " Tipos de locacao: (3)Departamento!"
              else
                 error " Tipos de locacao: (2)Corretor, (3)Departamento ou (4)Funcionario!"
              end if
              next field vclloctip

      end case

   on key (interrupt)
      exit input

 end input

 close window cts15m09

 if int_flag = true  then
    let int_flag = false
    return ws.*
 end if

 return d_cts15m09.*

end function  ###  cts15m09
