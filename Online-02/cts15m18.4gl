#---------------------------------------------------------------------------#
# Menu de Modulo: CTS15M18                                         Ligia    #
#                                                                  Fornax   #
# Consulta do Resumo das reservas                                  Jun/2011 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"
#globals  "/projetos/metodologia/D0609511/ligia/glct.4gl"

define m_prep smallint

#--------------------------------------------------------------------
function cts15m18_prepare()
#--------------------------------------------------------------------

   define l_sql char(1000)
   let l_sql = null

   let l_sql = ' select a.retdat, a.dvldat, a.diaqtd, b.cctcod, ',
               ' a.empcod, b.aviprostt, a.aviproseq, a.atdsrvseq ',
               ' from datmrsrsrvrsm a, datmprorrog b ',
               ' where a.atdsrvano = b.atdsrvano ',
               '   and a.atdsrvnum = b.atdsrvnum ',
               '   and a.aviproseq = b.aviproseq ',
               '   and a.atdsrvano = ? ',
               '   and a.atdsrvnum = ? ',
               '   order by a.aviproseq, a.atdsrvseq '

   prepare p_cts15m18_001 from l_sql
   declare c_cts15m18_001 cursor for p_cts15m18_001

   let m_prep = true

end function

#--------------------------------------------------------------------
 function cts15m18(lr_param)
#--------------------------------------------------------------------

  define lr_param        record
     atdsrvano        like datmprorrog.atdsrvano,
     atdsrvnum        like datmprorrog.atdsrvnum
  end record

  define a_cts15m18   array[20] of record
         retdat       char(10),
         rethor       datetime hour to minute,
         dvldat       char(10),
         dvlhor       datetime hour to minute,
         diaqtd       like datmrsrsrvrsm.diaqtd,
         cctcod       like datmprorrog.cctcod,
         fat          char(20),
         aviprostt    like datmprorrog.aviprostt
  end record

  define d_cts15m18   record
         retdat       like datmrsrsrvrsm.retdat,
         dvldat       like datmrsrsrvrsm.dvldat,
         empcod       like datmrsrsrvrsm.empcod
  end record

  define lr_cty14g00  record
         empnom       like gabkemp.empnom,
         ret          smallint,
         mensagem     char(80)
  end record

  define arr_aux      smallint
  define scr_aux      smallint

  let  arr_aux     =  null
  let  scr_aux     =  null

  initialize  a_cts15m18     to null
  initialize  d_cts15m18.*   to null
  initialize  lr_cty14g00.*  to null

  if lr_param.atdsrvnum is null or
     lr_param.atdsrvano is null then
     return
  end if

  if m_prep <> true then
     call cts15m18_prepare()
  end if

  open window w_cts15m18 at 10,02 with form "cts15m18"
       attribute(form line first)

  let arr_aux = 1

  open c_cts15m18_001 using lr_param.atdsrvano, lr_param.atdsrvnum

  foreach c_cts15m18_001 into d_cts15m18.retdat,
                              d_cts15m18.dvldat,
                              a_cts15m18[arr_aux].diaqtd,
                              a_cts15m18[arr_aux].cctcod,
                              d_cts15m18.empcod,
                              a_cts15m18[arr_aux].aviprostt

        let a_cts15m18[arr_aux].retdat =day(d_cts15m18.retdat) using "&&","/",
                                        month(d_cts15m18.retdat) using "&&","/",
                                        year(d_cts15m18.retdat) using "&&&&"

        let a_cts15m18[arr_aux].rethor = extend(d_cts15m18.retdat, 
                                                hour to minute)

        let a_cts15m18[arr_aux].dvldat =day(d_cts15m18.dvldat) using "&&","/",
                                        month(d_cts15m18.dvldat) using "&&","/",
                                        year(d_cts15m18.dvldat) using "&&&&"

        let a_cts15m18[arr_aux].dvlhor = extend(d_cts15m18.dvldat, 
                                                hour to minute)
        if d_cts15m18.empcod = 0 then
           let a_cts15m18[arr_aux].fat = "USUARIO"
        else
           call cty14g00_empresa_nome(d_cts15m18.empcod)
                returning lr_cty14g00.*
           let a_cts15m18[arr_aux].fat = lr_cty14g00.empnom
        end if

        let arr_aux = arr_aux + 1

   end foreach

   call set_count(arr_aux-1)

   if arr_aux = 1 then
      error "Nao existem prorrogacoes para esta reserva!"
   end if

   display array a_cts15m18 to s_cts15m18.*

         on key (interrupt,control-c)
            initialize a_cts15m18   to null
            exit display

   end display

   close window w_cts15m18
   let int_flag = false

end function

