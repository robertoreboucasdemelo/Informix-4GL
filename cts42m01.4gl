#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: cts42m01                                                  #
# Objetivo.......: Informa o nr da autorizacao dos serviços PortoSeg         #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 211982                                                    #
#............................................................................#
# Liberacao      : 06/11/2007                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

function cts42m01(lr_param)

   define lr_param   record
          atdsrvnum  like datmsrvorc.atdsrvnum,
          atdsrvano  like datmsrvorc.atdsrvano
          end record

   define lr_cts42m01   record
          orcvlr        like datmsrvorc.orcvlr,
          atznum        like datmsrvorc.atznum
          end record

   define l_res       smallint,
          l_msg       char(60),
          l_socntzcod like datmsrvorc.socntzcod,
          l_espcod    like datmsrvre.espcod

   initialize lr_cts42m01.* to null
   let l_res       = null
   let l_msg       = null
   let l_socntzcod = null
   let l_espcod    = null

   open window w_cts42m01 at 10,40 with form "cts42m01"
        attribute (border, form line 1)

   display lr_param.atdsrvnum to atdsrvnum
   display lr_param.atdsrvano to atdsrvano

   call ctd09g00_sel_orc(2, lr_param.*)
        returning l_res, l_msg, lr_cts42m01.orcvlr, lr_cts42m01.atznum
   
   input by name lr_cts42m01.orcvlr
                ,lr_cts42m01.atznum without defaults

      before field orcvlr
         display by name lr_cts42m01.orcvlr attribute(reverse)

      after field orcvlr
         display by name lr_cts42m01.orcvlr

      before field atznum
         display by name lr_cts42m01.atznum attribute(reverse)

      after field atznum
         display by name lr_cts42m01.atznum 

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field orcvlr
         end if

   end input

   if l_res = 1 then ## altera orcamento

      call ctd09g00_alt_orc(2,lr_param.*, lr_cts42m01.*, today, today) 
           returning l_res, l_msg

   else ## inclui orcamento

      call cts26g00_obter_natureza(lr_param.*)
           returning l_res, l_msg, l_socntzcod, l_espcod

      call ctd09g00_inc_orc(lr_param.*, l_socntzcod, 
                            today, lr_cts42m01.orcvlr,
                            today, lr_cts42m01.atznum)
           returning l_res, l_msg
   end if

   if l_res <> 1 then
      error l_msg
   end if

   close window w_cts42m01 
   return

end function
