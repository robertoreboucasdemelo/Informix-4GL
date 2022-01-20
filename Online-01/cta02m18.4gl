#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        : Central 24h                                  #
#  Modulo         : cta02m18.4gl                                 #
#                   Exibe matriculas com permissao de liberacao  #
#                   de atendimentos                              #
#  Analista Resp. : Carlos Ruiz                                  #
#  PSI            : 166871                                       #
#................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE, Mariana Gimenez         #
#  Liberacao      : 06/03/2003                                   #
#................................................................#
#                     * * *  ALTERACOES  * * *                   #
#                                                                #
#  Data         Autor Fabrica  Data   Alteracao                  #
#  ----------   -------------  ------ -------------------------- #
#                                                                #
#----------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'
{
main
defer interrupt
call cta02m18()
end main
}
#---------------------------#
function cta02m18()
#---------------------------#

define vl_a_cta02m18       array[500] of record
       empcod              like datkfun.empcod,
       funmat              like datkfun.funmat,
       funnom              like isskfunc.funnom
                           end record

define w_arr               integer



   open window w_cta02m18 at 4,7 with form "cta02m18"
      attribute(border)

     declare c_cta02m18_001 cursor with hold for

        select empcod, funmat
          from datkfun
          order by 1,2

     let w_arr = 1

     foreach c_cta02m18_001 into vl_a_cta02m18[w_arr].empcod,
                             vl_a_cta02m18[w_arr].funmat

         select funnom
           into vl_a_cta02m18[w_arr].funnom
           from isskfunc
          where empcod = vl_a_cta02m18[w_arr].empcod
            and funmat = vl_a_cta02m18[w_arr].funmat

         let w_arr = w_arr + 1

         if w_arr > 500 then
            error "Limite do array estourado. Avise a informatica"
            exit foreach
         end if

      end foreach

      call set_count(w_arr - 1)
      let w_arr = w_arr - 1

      display array vl_a_cta02m18 to s_cta02m18.*

         on key(control-c, interrupt)
            exit display

      end display

  close window w_cta02m18

end function

