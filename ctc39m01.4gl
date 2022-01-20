#-----------------------------------------------------------------------------#
# Porto Seguro Seguradora                                                     #
#.............................................................................#
# Sistema.......: Radar / Porto Socorro                                       #
# Modulo........: ctc39m01                                                    #
# Analista Resp.: Ligia Maria Mattge
# PSI...........: 220710                                                      #
# Objetivo......: Buscar informacoes sobre o candidato a socorrista           #
#.............................................................................#
# Desenvolvimento: Ligia Mattge                                               #
# Liberacao......: 12/05/2008                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

   define m_prep_sql smallint

#---------------------------
function ctc39m01_prepare()
#---------------------------
   
   define l_sql char(400)

   let l_sql = 'select * from dpakcnd '
              ,' where cgccpfnum = ? '
              ,'   and (cgcord = ? or cgcord is null)'
              ,'   and cgccpfdig = ? '

   prepare pctc39m01000 from l_sql             
   declare cctc39m01000 cursor for pctc39m01000

   let l_sql = 'select * from datksrr '
              ,' where cgccpfnum = ? '
              ,'   and (cgcord = ? or cgcord is null)'
              ,'   and cgccpfdig = ? '

   prepare pctc39m01002 from l_sql             
   declare cctc39m01002 cursor for pctc39m01002
   
   let l_sql = 'update dpakcnd '
              ,'   set pstcndsitcod = ? '
              ,' where cgccpfnum = ? '
              ,'   and (cgcord = ? or cgcord is null)'
              ,'   and cgccpfdig = ? '

   prepare pctc39m01001 from l_sql             

   let l_sql = 'update datksrr '
              ,'   set rdranlsitcod = ? '
              ,' where cgccpfnum = ? '
              ,'   and (cgcord = ? or cgcord is null)'
              ,'   and cgccpfdig = ? '

   prepare pctc39m01003 from l_sql             
   
   let m_prep_sql = true

end function

#--------------------------------------------
function ctc39m01_alt_candidato(lr_param)
#--------------------------------------------

   define lr_param record
          cgccpfnum  like dpakcnd.cgccpfnum,
          cgcord     like dpakcnd.cgcord,
          cgccpfdig  like dpakcnd.cgccpfdig,
          situacao   smallint
   end record
   
   define l_res smallint 
         ,l_msg char(100)
         ,l_sit_can smallint
         ,l_sit_srr smallint
   
   let l_res = 1 
   let l_msg = null
   let l_sit_can  = null
   let l_sit_srr  = null

   let m_prep_sql = false
   
   if lr_param.cgccpfnum is null then
      let l_res = 3  
      let l_msg = 'Parametro nulo'
      return l_res,l_msg 
   end if
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc39m01_prepare()
   end if

   if lr_param.situacao = 4 then
      let l_sit_can = 5  ##LIBERADO PELO RADAR
      let l_sit_srr = 1  ##LIBERADO
   else   ###lr_param.situacao =  3 
      let l_sit_can = 6  ##RECUSADO PELO RADAR
      let l_sit_srr = 3  ##RECUSADO
   end if

   whenever error continue

   open cctc39m01000 using lr_param.cgccpfnum
                             ,lr_param.cgcord
                             ,lr_param.cgccpfdig
   fetch cctc39m01000

   if sqlca.sqlcode <> notfound then
      execute pctc39m01001 using l_sit_can
                                ,lr_param.cgccpfnum
                                ,lr_param.cgcord
                                ,lr_param.cgccpfdig
   end if

   whenever error stop
   if sqlca.sqlcode <> 0 and sqlca.sqlcode <> notfound then
     let l_res = 2                                       
     let l_msg = 'ERRO ', sqlca.sqlcode, ' em dpakcnd'
   else
      let l_res = 1
   end if

   if l_res = 1 then

      whenever error continue
   
      open cctc39m01002 using lr_param.cgccpfnum
                             ,lr_param.cgcord
                             ,lr_param.cgccpfdig
      fetch cctc39m01002
   
      if sqlca.sqlcode <> notfound then
         execute pctc39m01003 using l_sit_srr
                                   ,lr_param.cgccpfnum
                                   ,lr_param.cgcord
                                   ,lr_param.cgccpfdig
   
         whenever error stop
         if sqlca.sqlcode <> 0 then
           let l_res = 2                                       
           let l_msg = 'ERRO ', sqlca.sqlcode, ' em datksrr'
         else
            let l_res = 1
         end if

      end if
   end if

   return l_res ,l_msg
   
end function   
