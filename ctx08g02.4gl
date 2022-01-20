#############################################################################
# Nome do Modulo: CTX08G02                                             Ruiz #
#                                                                      Akio #
# Atendimento ao corretor - Funcao que retorna dados do URA        Jun/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Alterado caminho da global,         #
#                                         alterado de systables para dual     #
###############################################################################
#.............................................................................#
#                                                                             #
#                          * * * ALTERACAO * * *                              #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ---------------------------------------#
# 22/08/2007  Saulo, Meta    AS146056  Inclusao da chamada da funcao figrc012 #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glcte.4gl"
globals  "/homedsa/projetos/geral/globals/figrc012.4gl"

#-------------------------------------------------------------------------------
 function ctx08g02( p_ctx08g02 )
#-------------------------------------------------------------------------------

   define p_ctx08g02      record
          corlignum       like dacmlig.corlignum,
          deleta          char(1)
   end record

   define r_ctx08g02      record
          ret             smallint,
          corsus          like gcaksusep.corsus,
          c24paxnum       like dacmlig.c24paxnum,
          c24solnom       like dacmlig.c24solnom,
          cobertura       smallint
   end record
   define ws              record
          comando         char (600),
          relpamtxt       like igbmparam.relpamtxt,
          suslnhqtd       like gcaksusep.suslnhqtd,
          corligano       like dacrligsus.corligano
   end record
   define l_host          like ibpkdbspace.srvnom #Saymon ambnovo
#--------------------------------------preprare-----------------------------


	initialize  r_ctx08g02.*  to  null

	initialize  ws.*  to  null

   #------------Saymon---------------------#
   # Carrega host do banco de dados        #
   #---------------------------------------#
   #ambnovo
   let l_host = fun_dba_servidor("ORCAMAUTO")
   #ambnovo

   let ws.comando = "select relpamtxt                      ",
                    "  from porto@",l_host clipped,":IGBMPARAM ",
                    "  where relsgl    = 'URAATENDPREVIO'  ",
                    "    and relpamseq = ?                 "

   prepare s_igbmparam from   ws.comando
   declare c_igbmparam cursor for s_igbmparam

   let ws.comando = "select corsus         ",
                    "  from DACRLIGSUS     ",
                    "  where corlignum = ? ",
                    "    and corligano = ? "
   prepare s_dacrligsus from   ws.comando
   declare c_dacrligsus cursor for s_dacrligsus

   let ws.comando = " select c24paxnum,c24solnom ",
                    "      from dacmlig          ",
                    "      where corlignum = ?   ",
                    "        and corligano = ?   "
   prepare s_dacmlig  from  ws.comando
   declare c_dacmlig cursor for s_dacmlig

#---------------------------------------------inicio---------------------------
   let r_ctx08g02.ret = true
   let ws.corligano   = year(today)

   if p_ctx08g02.corlignum is null then
      initialize r_ctx08g02 to null
      let r_ctx08g02.ret = false
      return r_ctx08g02.*
   end if

   open c_dacmlig using p_ctx08g02.corlignum,
                        ws.corligano
   fetch c_dacmlig  into r_ctx08g02.c24paxnum,
                         r_ctx08g02.c24solnom
   if status = notfound then
      initialize r_ctx08g02 to null
      let r_ctx08g02.ret = false
      return r_ctx08g02.*
   end if

   open  c_dacrligsus using p_ctx08g02.corlignum,
                            ws.corligano
   fetch c_dacrligsus into  r_ctx08g02.corsus
   if sqlca.sqlcode   =   notfound then
      initialize r_ctx08g02.corsus  to null
   end if

   open  c_igbmparam using r_ctx08g02.c24paxnum
   fetch c_igbmparam into  ws.relpamtxt
   if sqlca.sqlcode   =   0  then
      case ws.relpamtxt[1,4]
           when "0101" let r_ctx08g02.cobertura =  1
           when "0102" let r_ctx08g02.cobertura =  2
           when "0103" let r_ctx08g02.cobertura =  3
           when "0200" let r_ctx08g02.cobertura =  null
           when "0300" let r_ctx08g02.cobertura =  null
           when "0400" let r_ctx08g02.cobertura =  null
      end case
      if p_ctx08g02.deleta  =  "S"  or
         p_ctx08g02.deleta  =  "s"  then

         let ws.comando = 'delete from porto@',l_host clipped,':igbmparam '
                         ,'      where relsgl = "URAATENDPREVIO" '
                         ,'        and relpamseq = ? '

         prepare s_dacmlig_del from ws.comando

         execute s_dacmlig_del using r_ctx08g02.c24paxnum

      end if
   end if
   return r_ctx08g02.*
end function

