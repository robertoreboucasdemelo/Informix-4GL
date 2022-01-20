#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd15g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 214566                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datmmdtmvt           #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

define m_ctd15g00_prep smallint

#---------------------------#
function ctd15g00_prepare()
#---------------------------#
   define l_sql char(1000)

   let l_sql = ' insert into datmmdtmvt '
                        ,' (mdtmvtseq '
                        ,' ,caddat '
                        ,' ,cadhor '
                        ,' ,mdtcod '
                        ,' ,mdtmvttipcod '
                        ,' ,mdtbotprgseq '
                        ,' ,mdtmvtdigcnt '
                        ,' ,ufdcod '
                        ,' ,cidnom '
                        ,' ,brrnom '
                        ,' ,lclltt '
                        ,' ,lcllgt '
                        ,' ,mdtmvtdircod '
                        ,' ,mdtmvtvlc '
                        ,' ,mdtmvtstt '
                        ,' ,endzon '
                        ,' ,mdtmvtsnlflg '
                        ,' ,mdttrxnum '
                        ,' ,atdsrvnum '
                        ,' ,atdsrvano '
                        ,' ,empcod  '
                        ,' ,funmat  '
                        ,' ,usrtip) '
                 ,' values (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
   prepare pctd15g00001 from l_sql
   let l_sql = " select atdsrvnum,                ",
               "        atdsrvano                 ",
               "   from datkveiculo v,            ",
               "        dattfrotalocal l          ",
               "  where mdtcod = ?                ",
               "    and v.socvclcod = l.socvclcod "
   prepare pctd15g00002 from l_sql
   declare cctd15g00002 cursor for pctd15g00002
   let m_ctd15g00_prep = true

end function

#-------------------------------------------------------#
function ctd15g00_ins_datmmdtmvt(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          caddat           like datmmdtmvt.caddat,
          cadhor           like datmmdtmvt.cadhor,
          mdtcod           like datmmdtmvt.mdtcod,
          mdtmvttipcod     like datmmdtmvt.mdtmvttipcod,
          mdtbotprgseq     like datmmdtmvt.mdtbotprgseq,
          mdtmvtdigcnt     like datmmdtmvt.mdtmvtdigcnt,
          ufdcod           like datmmdtmvt.ufdcod,
          cidnom           like datmmdtmvt.cidnom,
          brrnom           like datmmdtmvt.brrnom,
          lclltt           like datmmdtmvt.lclltt,
          lcllgt           like datmmdtmvt.lcllgt,
          mdtmvtdircod     like datmmdtmvt.mdtmvtdircod,
          mdtmvtvlc        like datmmdtmvt.mdtmvtvlc,
          mdtmvtstt        like datmmdtmvt.mdtmvtstt,
          endzon           like datmmdtmvt.endzon,
          mdtmvtsnlflg     like datmmdtmvt.mdtmvtsnlflg,
          mdttrxnum        like datmmdtmvt.mdttrxnum,
          atdsrvnum        like datmmdtmvt.atdsrvnum,
          atdsrvano        like datmmdtmvt.atdsrvano,
          empcod           like datmmdtmvt.empcod,
          funmat           like datmmdtmvt.funmat,
          usrtip           like datmmdtmvt.usrtip
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_ctd15g00_prep is null or
      m_ctd15g00_prep <> true then
      call ctd15g00_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null
   if ((lr_param.atdsrvnum is null or lr_param.atdsrvnum = "")  or
       (lr_param.atdsrvano is null or lr_param.atdsrvano = "")) and
      (lr_param.mdtbotprgseq = 1 or lr_param.mdtbotprgseq = 2   or
       lr_param.mdtbotprgseq = 3) then
      open cctd15g00002 using lr_param.mdtcod
      fetch cctd15g00002 into lr_param.atdsrvnum,
                              lr_param.atdsrvano
   end if
   whenever error continue
   execute pctd15g00001 using lr_param.caddat,
                              lr_param.cadhor,
                              lr_param.mdtcod,
                              lr_param.mdtmvttipcod,
                              lr_param.mdtbotprgseq,
                              lr_param.mdtmvtdigcnt,
                              lr_param.ufdcod,
                              lr_param.cidnom,
                              lr_param.brrnom,
                              lr_param.lclltt,
                              lr_param.lcllgt,
                              lr_param.mdtmvtdircod,
                              lr_param.mdtmvtvlc,
                              lr_param.mdtmvtstt,
                              lr_param.endzon,
                              lr_param.mdtmvtsnlflg,
                              lr_param.mdttrxnum,
                              lr_param.atdsrvnum,
                              lr_param.atdsrvano,
                              lr_param.empcod,
                              lr_param.funmat,
                              lr_param.usrtip
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_resultado = 3
      let l_mensagem = "Erro na inclusao de datmmdtmvt ", sqlca.sqlcode
   end if

   return l_resultado, l_mensagem

end function
