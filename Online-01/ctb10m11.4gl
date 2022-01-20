###############################################################################
# Sistema........: Porto Socorro                                              #
# Modulo.........: ctb10m11                                                   #
# PSI............:                                                            #
# Objetivo.......: Parametrizar os funcionaros que fazem a liberacao dos      #
#                  servicos por Alcada                                        #
# Analista Resp..: Ligia Mattge                                               #
# Desenvolvimento: Ligia Mattge                                               #
# Liberacao......:                                                            #
# Data...........: 01/2016                                                    #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define am_ctb10m11     array[200] of record
       funmat          dec(6,0)
      ,funnom          char(30)
      ,valor           dec(12,2)
      ,percentual      dec(5,2)
end record

define m_indice     integer,
       m_totalarray integer

#------------------------------------------------------------------------------#
function ctb10m11_prp()
#------------------------------------------------------------------------------#

   define l_sql char(1000)

   let l_sql = "select funnom from isskfunc",
               " where funmat = ? ",
	       "   and empcod = ? "
   prepare p_ctb10m11001 from l_sql
   declare c_ctb10m11001 cursor for p_ctb10m11001

   let l_sql = " select cpodes[1,6], cpodes[8,19], cpodes[21,26] ",
	       " from datkdominio ",
               " where  cponom = 'ALCADA' "
   prepare p_ctb10m11002 from l_sql
   declare c_ctb10m11002 cursor for p_ctb10m11002

   let l_sql = " insert into datkdominio (cponom, cpocod, cpodes) ",
               " values('ALCADA',?,?)"
   prepare p_ctb10m11003 from l_sql

   let l_sql = " update datkdominio set cpodes = ? ",
               " where cponom = 'ALCADA' ",
	       "   and cpodes[1,6] = ? "
   prepare p_ctb10m11004 from l_sql

   let l_sql = " select * from datkdominio ",
               " where cponom = 'ALCADA' ",
	       "   and cpodes[1,6] = ? "
   prepare p_ctb10m11005 from l_sql
   declare c_ctb10m11005 cursor for p_ctb10m11005

   let l_sql = " delete from datkdominio ",
               " where cponom = 'ALCADA' ",
	       "   and cpodes[1,6] = ? "
   prepare p_ctb10m11006 from l_sql

   let l_sql = " select max(cpocod) ",
	       " from datkdominio ",
               " where  cponom = 'ALCADA' "
   prepare p_ctb10m11007 from l_sql
   declare c_ctb10m11007 cursor for p_ctb10m11007

end function

#------------------------------------------------------------------------------#
function ctb10m11()
#------------------------------------------------------------------------------#
   define l_dupl smallint
   define l_tela smallint
   define l_ind  integer

   let l_dupl = false
   let int_flag = false

   initialize am_ctb10m11 to null

   open window w_ctb10m11 at 7, 2 with form "ctb10m11"
        attribute (border, form line 1, prompt line last)

   call ctb10m11_prp()

   while int_flag = false

   call ctb10m11_sel()

   call set_count(m_indice - 1)
   let m_totalarray = m_indice

   options
      insert key f21,
      delete key f20

   input array am_ctb10m11 without defaults from s_ctb10m11.*

      before row
         let l_tela  = scr_line()
         let m_indice   = arr_curr()
         display am_ctb10m11[m_indice].* to s_ctb10m11[l_tela].*

      before insert
         let l_tela  = scr_line()
         let m_indice   = arr_curr()

      on key (f2)
         let m_indice   = arr_curr()
         display am_ctb10m11[m_indice].* to
              s_ctb10m11[l_tela].* attribute (reverse)
	 call ctb10m11_remove()
	 let int_flag = false
	 exit input

      on key (f8, interrupt,control-c,esc)
	 let int_flag = true
         let m_indice   = arr_curr()
         exit input

      before field funmat
         display am_ctb10m11[m_indice].funmat to
              s_ctb10m11[l_tela].funmat attribute (reverse)

      after field funmat
         display am_ctb10m11[m_indice].funmat to
              s_ctb10m11[l_tela].funmat

         if fgl_lastkey() <> fgl_keyval('up') then

	    if am_ctb10m11[m_indice].funmat is null then
	       next field funmat
            end if

            let m_totalarray = arr_count()
            let l_dupl = false
   
	    for l_ind = 1 to m_totalarray
	        if l_ind <> m_indice and
	           am_ctb10m11[l_ind].funmat = am_ctb10m11[m_indice].funmat then
                   let l_dupl = true
		   exit for
                end if
	    end for
   
	    if l_dupl = true then
               error "Matricula ja cadastrada, informe outra"
	       let am_ctb10m11[m_indice].funmat = null
	       next field funmat
	    end if
   
	    open c_ctb10m11001 using am_ctb10m11[m_indice].funmat, g_issk.empcod
	    fetch c_ctb10m11001 into am_ctb10m11[m_indice].funnom
   
	    if sqlca.sqlcode  = notfound then
	       error 'Matricula invalida'
	       next field funmat
            end if
   
	    display am_ctb10m11[m_indice].funnom to s_ctb10m11[l_tela].funnom

         end if

      before field valor
         display am_ctb10m11[m_indice].valor to
              s_ctb10m11[l_tela].valor attribute (reverse)

      after field valor
         display am_ctb10m11[m_indice].valor to
                 s_ctb10m11[l_tela].valor

         if fgl_lastkey() = fgl_keyval('left') then
            next field funmat
         end if

         if am_ctb10m11[m_indice].valor is null then
            let am_ctb10m11[m_indice].valor = 0
         end if

         display am_ctb10m11[m_indice].valor to
                 s_ctb10m11[l_tela].valor

      before field percentual
         display am_ctb10m11[m_indice].percentual to
                 s_ctb10m11[l_tela].percentual attribute (reverse)

      after field percentual
         display am_ctb10m11[m_indice].percentual to
                 s_ctb10m11[l_tela].percentual

         if fgl_lastkey() = fgl_keyval('left') then
            next field valor
         end if

         if am_ctb10m11[m_indice].percentual is null then
            let am_ctb10m11[m_indice].percentual = 0
            next field percentual
         end if

         let m_totalarray = arr_count()
	 call ctb10m11_grava()

   end input

   if int_flag = true then
      exit while
   end if

   end while

   close window w_ctb10m11
   return

end function

#------------------------------------------------------------------------------#
function ctb10m11_grava()
#------------------------------------------------------------------------------#

   define l_ind integer,
	  l_cpocod integer,
	  l_cpodes char(30)

   begin work

   for l_ind = 1 to m_totalarray

       if am_ctb10m11[l_ind].funmat is null then
	  continue for
       end if

       let l_cpodes[01,06] =  am_ctb10m11[l_ind].funmat using '######'
       let l_cpodes[08,19] =  am_ctb10m11[l_ind].valor using '########&.&&'
       let l_cpodes[21,26] =  am_ctb10m11[l_ind].percentual using '##&.&&'

       open c_ctb10m11005  using am_ctb10m11[l_ind].funmat
       fetch c_ctb10m11005

       if sqlca.sqlcode = notfound then

	  let l_cpocod = 0
	  open c_ctb10m11007 
	  fetch c_ctb10m11007 into l_cpocod
	  if l_cpocod is null or l_cpocod = 0 then
	     let l_cpocod = 1
          else
	     let l_cpocod = l_cpocod + 1
	  end if

          execute p_ctb10m11003 using l_cpocod, l_cpodes
       else
          execute p_ctb10m11004 using l_cpodes, am_ctb10m11[l_ind].funmat
       end if

       if sqlca.sqlcode <> 0 then
	  exit for
       end if

   end for

   if sqlca.sqlcode = 0 then
      commit work
   else
      error 'Erro na gravacao da alcada: ', sqlca.sqlcode
      rollback work
   end if

end function


#------------------------------------------------------------------------------#
function ctb10m11_sel()
#------------------------------------------------------------------------------#
    let m_indice    = 1

    foreach c_ctb10m11002 into am_ctb10m11[m_indice].funmat,
                               am_ctb10m11[m_indice].valor,
                               am_ctb10m11[m_indice].percentual

         open c_ctb10m11001 using am_ctb10m11[m_indice].funmat, g_issk.empcod
         fetch c_ctb10m11001 into am_ctb10m11[m_indice].funnom
         close c_ctb10m11001

         let m_indice = m_indice + 1

    end foreach

end function

#------------------------------------------------------------------------------#
function ctb10m11_remove()
#------------------------------------------------------------------------------#
   define l_resp char(1)

   while true
      prompt "Confirma a exclusao (S/N)? " for l_resp
      if l_resp matches "[sSnN]" then
         exit while
      end if
   end while

   if l_resp = "S" or l_resp = "s"  then
      begin work
      execute p_ctb10m11006 using am_ctb10m11[m_indice].funmat

      if sqlca.sqlcode = 0 then
         commit work
      else
         error 'Erro na gravacao da alcada: ', sqlca.sqlcode
         rollback work
      end if

   end if

end function
