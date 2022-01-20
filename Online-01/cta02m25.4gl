#---------------------------------------------------------------------------#
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                    #
#...........................................................................#
#  Sistema        : CT24H                                                   #
#  Modulo         : cta02m25.4gl                                            #
#                   Controle de transferencia de ligacoes novo sinistro     #
#  Analista Resp. :                                                         #
#  PSI            :                                                         #
#...........................................................................#
#  Desenvolvimento: Denilson Marques                                        #
#  Inicio         : 09/10/2007                                              #
#  Liberacao      :                                                         #
#...........................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

function cta02m25(param)

  define param record
     ramal   decimal(4,0),
     funmat  decimal(6,0),
     funnom  char(25)
  end record

  define w_tela record
    ramal     smallint,
    funmat    decimal(6,0),
    funnom    char(25),
    flgsinis  char(1),
    funmatatd decimal(6,0),
    funnomatd char(25),
    mtvcod    smallint,
    flgconf   char(1)
  end record

  define v_hora_inc datetime hour to second
  define v_hora_fim datetime hour to second
  define v_hora_tot interval hour to second

  define mr_cta02m25 record                   ## Alberto
         empcod      like isskfunc.empcod     ## Alberto
        ,rhmfunnom   like isskfunc.rhmfunnom  ## Alberto
  end record                                  ## Alberto
  define l_sql       char(200)                ## Alberto
  define  l_retorno   smallint                ## Alberto

  initialize w_tela.* to null
  initialize v_hora_inc to null
  initialize v_hora_fim to null
  initialize v_hora_tot to null

  initialize l_retorno, l_sql to null

  open window w_cta02m25 at 6,4 with form "cta02m25" attribute (border)

  let v_hora_inc = current
  let w_tela.ramal  = param.ramal
  let w_tela.funmat = param.funmat
  let w_tela.funnom = param.funnom

  display by name w_tela.ramal, w_tela.funmat, w_tela.funnom attribute(reverse)

  input by name w_tela.flgsinis, w_tela.funmatatd, w_tela.funnomatd,
                w_tela.mtvcod, w_tela.flgconf

     after field flgsinis
        if w_tela.flgsinis = "N" then
           let w_tela.funmatatd = ""
           let w_tela.funnomatd = ""
           display by name w_tela.funmatatd, w_tela.funnomatd
           next field mtvcod
        end if


     after field funmatatd
        if w_tela.funmatatd is not null and
           w_tela.funmatatd <> "0" then
           ## Alberto
           let l_sql = 'select empcod, rhmfunnom '
           ,'  from isskfunc '
           ,' where funmat  = ', w_tela.funmatatd
           ,' order by rhmfunnom '

           call ofgrc001_popup(10, 12, 'Funcionario', 'Empresa', 'Nome', 'A', l_sql, '', 'D')
                returning l_retorno
                         ,mr_cta02m25.empcod
                         ,mr_cta02m25.rhmfunnom
           ## Alberto
           select funnom
             into w_tela.funnomatd
             from isskfunc
            where funmat = w_tela.funmatatd
              and empcod = mr_cta02m25.empcod ## Alberto
              and usrtip = "F"

           display by name w_tela.funnomatd
        end if
        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field flgsinis
        end if
        if w_tela.flgsinis = "S" then
           next field flgconf
        end if

     after field mtvcod
         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left") then
            if w_tela.flgsinis = "N" then
               next field flgsinis
            end if
         end if

     after field flgconf
         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left") then
            if w_tela.flgsinis = "S" then
               next field funmatatd
            end if
         end if
         if w_tela.flgsinis = "N" and
            w_tela.mtvcod is null or
            w_tela.mtvcod =   ""  then
            next field mtvcod
            error "Informe o codigo do motivo da nao transferencia"
         end if
         if w_tela.flgconf = "N" then
            next field flgsinis
         end if
         if w_tela.flgsinis = "S" then
            if w_tela.funmatatd is null or
               w_tela.funmatatd = "" then
               next field funmatatd
            end if
         end if

     on key (interrupt)
        if w_tela.flgconf is null then
           error "Preencher os campos obrigatorios"
           next field flgsinis
        end if
  end input
  let v_hora_fim = current

  let v_hora_tot = v_hora_fim - v_hora_inc

  close window w_cta02m25
display  v_hora_fim," ",v_hora_inc," ",v_hora_tot
  return w_tela.funmatatd,
         w_tela.mtvcod,
         v_hora_tot,
         w_tela.funnomatd

end function
