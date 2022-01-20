#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd07g08                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
# Objetivo.......: Modulo responsavel pelo acesso a tabela DATMSERVICOCMP     #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 14/09/2009 Fabio Costa     PSI246174  Inclusao de funcao insert             #
# 08/11/2011 Alberto                    Alterado retorno da funcao,nao utili- #
#                                       zando o sqlca.sqlcode.                #
#-----------------------------------------------------------------------------#
database porto

define m_ctd07g08_prep smallint

#---------------------------#
function ctd07g08_prepare()
#---------------------------#
   define l_sql  char(1200)

   let l_sql = " select sindat ",
               " from datmservicocmp    ",
               " where atdsrvnum = ? ",
               "   and atdsrvano = ? "
   prepare pctd07g08001 from l_sql
   declare cctd07g08001 cursor with hold for pctd07g08001

   # insert em DATMSERVICOCMP
   let l_sql = ' insert into datmservicocmp(atdsrvnum, ',  # NN
               '                            atdsrvano, ',  # NN
               '                            vclcamtip, ',
               '                            vclcrcdsc, ',
               '                            vclcrgflg, ',
               '                            vclcrgpso, ',
               '                            sinvitflg, ',
               '                            bocflg   , ',
               '                            bocnum   , ',
               '                            bocemi   , ',
               '                            vcllibflg, ',
               '                            roddantxt, ',
               '                            rmcacpflg, ',
               '                            sindat   , ',
               '                            c24sintip, ',
               '                            c24sinhor, ',
               '                            vicsnh   , ',
               '                            sinhor   , ',
               '                            sgdirbcod, ',
               '                            smsenvflg) ',               
               ' values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
   prepare p_datmservicocmp_ins from l_sql

   let m_ctd07g08_prep = true

end function

#-------------------------------------------------------#
function ctd07g08_compl_srv(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmservicocmp.atdsrvnum
         ,atdsrvano        like datmservicocmp.atdsrvano
   end record

   define lr_retorno record
          sindat     like datmservicocmp.sindat
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_ctd07g08_prep is null or
      m_ctd07g08_prep <> true then
      call ctd07g08_prepare()
   end if

   let l_resultado = 0
   let l_mensagem  = null
   initialize lr_retorno.* to null

   whenever error continue
   open  cctd07g08001 using lr_param.atdsrvnum, lr_param.atdsrvano
   fetch cctd07g08001 into  lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em datmservicocmp "
      else
         let l_resultado = 3
         let l_mensagem = "Erro na selecao de datmservicocmp ", sqlca.sqlcode
      end if
   end if

   close cctd07g08001

   if lr_param.nivel_retorno = 1 then
      return l_resultado, l_mensagem, lr_retorno.sindat
   end if

end function

#----------------------------------------------------------------
function ctd07g08_srvcmp_ins(l_param)
#----------------------------------------------------------------

   define l_param record
          atdsrvnum  like  datmservicocmp.atdsrvnum ,
          atdsrvano  like  datmservicocmp.atdsrvano ,
          vclcamtip  like  datmservicocmp.vclcamtip ,
          vclcrcdsc  like  datmservicocmp.vclcrcdsc ,
          vclcrgflg  like  datmservicocmp.vclcrgflg ,
          vclcrgpso  like  datmservicocmp.vclcrgpso ,
          sinvitflg  like  datmservicocmp.sinvitflg ,
          bocflg     like  datmservicocmp.bocflg    ,
          bocnum     like  datmservicocmp.bocnum    ,
          bocemi     like  datmservicocmp.bocemi    ,
          vcllibflg  like  datmservicocmp.vcllibflg ,
          roddantxt  like  datmservicocmp.roddantxt ,
          rmcacpflg  like  datmservicocmp.rmcacpflg ,
          sindat     like  datmservicocmp.sindat    ,
          c24sintip  like  datmservicocmp.c24sintip ,
          c24sinhor  like  datmservicocmp.c24sinhor ,
          vicsnh     like  datmservicocmp.vicsnh    ,
          sinhor     like  datmservicocmp.sinhor    ,
          sgdirbcod  like  datmservicocmp.sgdirbcod ,
          smsenvflg  like  datmservicocmp.smsenvflg
   end record

   define l_retorno integer 

   let l_retorno = 0

   if m_ctd07g08_prep is null or
      m_ctd07g08_prep <> true then
      call ctd07g08_prepare()
   end if
 
   whenever error continue
 
   execute p_datmservicocmp_ins using l_param.atdsrvnum,
                                      l_param.atdsrvano,
                                      l_param.vclcamtip,
                                      l_param.vclcrcdsc,
                                      l_param.vclcrgflg,
                                      l_param.vclcrgpso,
                                      l_param.sinvitflg,
                                      l_param.bocflg   ,
                                      l_param.bocnum   ,
                                      l_param.bocemi   ,
                                      l_param.vcllibflg,
                                      l_param.roddantxt,
                                      l_param.rmcacpflg,
                                      l_param.sindat   ,
                                      l_param.c24sintip,
                                      l_param.c24sinhor,
                                      l_param.vicsnh   ,
                                      l_param.sinhor   ,
                                      l_param.sgdirbcod,
                                      l_param.smsenvflg
   whenever error stop

   let l_retorno  = sqlca.sqlcode
   if sqlca.sqlcode = 0 then
     call cts00g07_apos_grvlaudo(l_param.atdsrvnum,l_param.atdsrvano)
   end if
   #return sqlca.sqlcode
   return l_retorno
end function 