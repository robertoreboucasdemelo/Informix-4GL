#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctb01g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
#                  Tratar a data de pagamento da OP de Auto/RE.               #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

function ctb01g00(lr_param)

   define lr_param      record
          operacao      char(1),
          favtip        integer,
          pstcoddig     like dbsmopg.pstcoddig,
          socfatpgtdat  like dbsmopg.socfatpgtdat
          end record

   define l_res        smallint,
          l_msg        char(80),
          l_diasem     smallint,
          l_conf       char(1),
          l_data       date,    
          l_datai      date,    
          l_dataf      date,    
          l_hora       datetime hour to minute,
          l_socopgnum  like dbsmopg.socopgnum

   let l_res = 1
   let l_msg = null
   let l_conf = null
   let l_diasem = null
   let l_data = null
   let l_datai = null
   let l_dataf = null
   let l_hora = null
   let l_socopgnum = null

   if lr_param.socfatpgtdat is null then
      let l_res = 2
      let l_msg = ''
      return l_res, l_msg
   end if

   call cts40g03_data_hora_banco(2) returning l_data, l_hora

   if lr_param.socfatpgtdat  <  l_data  then
      let l_res = 2
      let l_msg = "Data de pagamento nao deve ser menor que data atual!"
      return l_res, l_msg
   end if

   let l_diasem = weekday(lr_param.socfatpgtdat)

   if l_diasem = 0 or l_diasem = 6 then
      let l_res = 2
      let l_msg = " Data de pagamento nao deve ser sabado ou domingo!"
      return l_res, l_msg
   end if

   if lr_param.socfatpgtdat  >=  l_data + 30 units day  then
      let l_res = 2
      let l_msg = " Data pagamento nao deve superior a 30 dias!"
      return l_res, l_msg
   end if

    if dias_entre_datas (l_data, lr_param.socfatpgtdat, "", "S", "S") <= 4  then
         call cts08g01("A", "N", "",
                       "PAGAMENTO DEVE SER PROGRAMADO COM",
                       "PELO MENOS QUATRO DIAS DE ANTECEDENCIA!","")
              returning l_conf

         let l_res = 2
         let l_msg= null
         return l_res, l_msg
   end if

   if dias_entre_datas (l_data, lr_param.socfatpgtdat, "", "S", "S") <= 4  then
      let l_res = 2
      let l_msg = " Pagamento deve ser programado c/ 4 DIAS DE ANTECEDENCIA!"

      if g_issk.acsnivcod < 6  then
      else
         call cts08g01("A", "N", "",
                       "DEPTO. FINANCEIRO DEVE SER AVISADO",
                       "ANTES DA GERACAO DA ORDEM DE PAGTO!","")
              returning l_conf
      end if
      return l_res, l_msg
   end if

   #------------------------------------------------------
   # Avisar se existe O.P. para o mesmo prestador/dt pagto
   #------------------------------------------------------
   if lr_param.operacao  = "i"  and
      lr_param.favtip    = 1    and
      lr_param.pstcoddig > 11   then

      let l_datai = lr_param.socfatpgtdat - 5 units day
      let l_dataf = lr_param.socfatpgtdat + 5 units day

      call ctd20g00_sel_op(l_datai, l_dataf, lr_param.pstcoddig)
           returning l_res, l_msg, l_socopgnum

      if l_res = 1 then
         let l_msg = "     VERIFIQUE O.P. NUMERO : ",
                     l_socopgnum using "&&&&&&&&"
         call cts08g01("A", "N",
                       "JA' EXISTE O.P. PARA PAGAMENTO EM UMA",
                       "DATA PROXIMA A DATA INFORMADA",
                       "",
                       l_msg)
              returning l_conf
         let l_msg = null
      else
         let l_res = 1
         let l_msg = ""
      end if
   end if

   return l_res, l_msg

end function
