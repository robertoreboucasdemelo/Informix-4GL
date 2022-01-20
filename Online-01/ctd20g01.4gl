#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g01                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DBSMOPGITM         #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 27/05/2009 Fabio Costa     PSI 198404 Incluir update da TRB e update da NFS #
#-----------------------------------------------------------------------------#

database porto

define m_ctd20g01_prep smallint

#---------------------------#
function ctd20g01_prepare()
#---------------------------#
   define l_sql  char(1000)
   
   let l_sql = " update dbsmopgitm set                ",
               " (socitmtrbflg, socitmdspcod) = (?,?) ",
               "  where socopgnum = ?  and  socopgitmnum = ? "
   prepare pctd20g01001 from l_sql

   let l_sql = " select * from dbsmopgitm  ",
               "  where socopgnum = ?  ",
               "  and   nfsnum is null  "
   prepare pctd20g01002 from l_sql
   declare cctd20g01002 cursor for pctd20g01002
   
   # itens da OP
   let l_sql = " select socopgitmnum ",
               " from dbsmopgitm ",
               " where socopgnum = ? "
   prepare p_opgitm_sel from l_sql
   declare c_opgitm_sel cursor with hold for p_opgitm_sel
   
   # update numero da NF em todos os itens
   let l_sql = ' update dbsmopgitm set (nfsnum) = (?) ',
               ' where socopgnum = ? '
   prepare p_upd_nfs_opgitm from l_sql
   
   # inserir item
   let l_sql = ' insert into dbsmopgitm(socopgnum   , ',  # NN
               '                        socopgitmnum, ',  # NN
               '                        atdsrvnum   , ',  # NN
               '                        atdsrvano   , ',  # NN
               '                        socopgitmvlr, ',  # NN
               '                        nfsnum      , ',
               '                        vlrfxacod   , ',
               '                        funmat      , ',  # NN
               '                        socconlibflg, ',  # NN
               '                        socitmtrbflg, ',
               '                        socitmdspcod, ',
               '                        c24utidiaqtd, ',
               '                        c24pagdiaqtd, ',
               '                        rsrincdat   , ',
               '                        rsrfnldat   ) ',
               '                values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
   prepare p_dbsmopgitm_ins from l_sql
   
   let m_ctd20g01_prep = true

end function

#-------------------------------------------------------#
function ctd20g01_upd_trb_opgitm(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          socopgnum        like dbsmopgitm.socopgnum
         ,socopgitmnum     like dbsmopgitm.socopgitmnum
         ,socitmtrbflg     like dbsmopgitm.socitmtrbflg
         ,socitmdspcod     like dbsmopgitm.socitmdspcod
   end record
   
   if m_ctd20g01_prep is null or
      m_ctd20g01_prep <> true then
      call ctd20g01_prepare()
   end if
   
   whenever error continue
   execute pctd20g01001 using lr_param.socitmtrbflg,
                              lr_param.socitmdspcod,
                              lr_param.socopgnum   ,
                              lr_param.socopgitmnum  
   whenever error stop
   
   return sqlca.sqlcode, sqlca.sqlerrd[3]

end function

#-------------------------------------------------------#
function ctd20g01_tem_item_nf(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          socopgnum        like dbsmopgitm.socopgnum
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_ctd20g01_prep is null or
      m_ctd20g01_prep <> true then
      call ctd20g01_prepare()
   end if  

   let l_resultado = 1
   let l_mensagem  = null

   whenever error continue
   open cctd20g01002 using lr_param.socopgnum
   fetch cctd20g01002 
   whenever error stop

   if sqlca.sqlcode = 0 then
      let l_resultado = 1
      let l_mensagem = null
   else
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "OP nao tem item cadastrado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro ",sqlca.sqlcode," no acesso a dbsmopgitm"
      end if
   end if

   close cctd20g01002 
   return l_resultado, l_mensagem

end function

#----------------------------------------------------------------
function ctd20g01_upd_nfs_opgitm(lr_param)
#----------------------------------------------------------------
  define lr_param record
         socopgnum     like dbsmopgitm.socopgnum ,
         socopgsitcod  like dbsmopg.socopgsitcod ,
         nfsnum        like dbsmopgitm.nfsnum
  end record
  
  if lr_param.socopgsitcod = 7  or  # emitida
     lr_param.socopgsitcod = 8  or  # cancelada
     lr_param.socopgsitcod = 10     # aguardando People
     then
     return 99, 0
  end if
  
  if m_ctd20g01_prep is null or
     m_ctd20g01_prep <> true then
     call ctd20g01_prepare()
  end if
  
  whenever error continue
  execute p_upd_nfs_opgitm using lr_param.nfsnum   ,
                                 lr_param.socopgnum
  whenever error stop
  
  return sqlca.sqlcode, sqlca.sqlerrd[3]
  
end function

