#----------------------------------------------------------------------------#
#                      Porto Seguro Cia Seguros Gerais                       #
#............................................................................#
# Sistema........: CRM                                                       #
# Modulo.........: ctz00m00                                                  #
# Objetivo.......: Verificar atendimento Siebel                              #
# Analista Resp. : Rafael Oliveira                                           #
# PSI            : PR-2011-2011-02439                                        #
#............................................................................#
# Desenvolvimento: Eduardo Marques, META                                     #
# Liberacao      :                                                           #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

#globals '/homedsa/projetos/geral/globals/apglglob.4gl'
globals '/homedsa/projetos/geral/globals/glseg.4gl'
globals "/homedsa/projetos/geral/globals/figrc012.4gl"

database porto

define m_prep        smallint

define m_prep_sql   smallint   # Alberto CRM
define m_prep_sql1  smallint   # Alberto CRM

define mr_sblatdver record
    mnnseqnum    integer
   ,sblatdnum    like datmifxmnn.sblatdnum
   ,acsdat       like datmifxmnn.acsdat
   ,usrmatcod    like datmifxmnn.usrmatcod
   ,acssisnom    like datmifxmnn.acssisnom
   ,acstlanom    like datmifxmnn.acstlanom
   ,trtastdes    like datmifxmnn.trtastdes
   ,trtdctcod    like datmifxmnn.trtdctcod
   ,trtdcttipnom like datmifxmnn.trtdcttipnom
end record

define m_host       like ibpkdbspace.srvnom
#---------------------------
function ctz00m00_prepare()
#---------------------------
   define l_sql char(700)

   let m_host = fun_dba_servidor("CT24HS")
   let l_sql =  "select ifxsblitgseqnum  "
               ,"      ,sblitenum        "
               ,"      ,sblatdnum        "
               ,"      ,atdclitipcod     "
               ,"      ,bcpclicod        "
               ,"      ,clinom           "
               ,"      ,clicpfnum        "
               ,"      ,clicnpnum        "
               ,"      ,suscod           "
               ,"      ,prscod           "
               ,"      ,fncclimatcod     "
               ,"      ,sblatdgrpnom     "
               ,"      ,trtdcttipnom     "
               ,"      ,trtdctcod        "
               ,"      ,refdcttipnom     "
               ,"      ,refdctcod        "
               ,"      ,atdasttipnom     "
               ,"      ,atdastdes        "
               ,"      ,atdsatdes        "
               ,"      ,atdusrmatcod     "
               ,"      ,legsisnom        "
               ,"      ,envdat           "
               ,"      ,legsisltrflg     "
              # ," from datmifxsblitg     "
               ," from porto@",m_host clipped,":datmifxsblitg "
               ," where atdusrmatcod = ? "
               ," and legsisnom = ?      "
               ," order by envdat desc   "

   prepare pctz00m00001 from l_sql
   declare cctz00m00001 cursor for pctz00m00001

   #let l_sql = "insert into datmifxmnn values(?,?,?,?,?,?,?,?,?)"
   #prepare pctz00m00002 from l_sql
   let l_sql = "insert into porto@",m_host clipped,":datmifxmnn "
              ," (mnnseqnum "
              ," ,sblatdnum "
              ," ,acsdat    "
              ," ,usrmatcod "
              ," ,acssisnom "
              ," ,acstlanom "
              ," ,trtastdes "
              ," ,trtdctcod "
              ," ,trtdcttipnom) "
              ,"values(?,?,?,?,?,?,?,?,?)"
   prepare pctz00m00002 from l_sql

   #let l_sql = "update datmifxsblitg set legsisltrflg = 1 where ifxsblitgseqnum = ?"
   #prepare pctz00m00003 from l_sql

   let l_sql = "update porto@",m_host clipped,":datmifxsblitg set legsisltrflg = 1 where sblitenum = ?"
   prepare pctz00m00003 from l_sql

   let l_sql = "select max(mnnseqnum) from porto@",m_host clipped,":datmifxmnn"
   prepare pctz00m00004 from l_sql
   declare cctz00m00004 cursor for pctz00m00004

   let m_prep = true
end function -- ctz00m00_prepare()


{função Verifica atendimento siebel}
#----------------------------------------------#
 function ctz00m00_verifica_atd_siebel(lr_param)
#----------------------------------------------#
   define lr_param         record
             funmat           like isskfunc.funmat
            ,legsisnom        like datmifxsblitg.legsisnom
          end record


   define l_ifxsblitgseqnum  like datmifxsblitg.ifxsblitgseqnum
         ,l_sblitenum        like datmifxsblitg.sblitenum
         ,l_sblatdnum        like datmifxsblitg.sblatdnum
         ,l_atdclitipcod     like datmifxsblitg.atdclitipcod
         ,l_bcpclicod        like datmifxsblitg.bcpclicod
         ,l_clinom           like datmifxsblitg.clinom
         ,l_clicpfnum        like datmifxsblitg.clicpfnum
         ,l_clicnpnum        like datmifxsblitg.clicnpnum
         ,l_suscod           like datmifxsblitg.suscod
         ,l_prscod           like datmifxsblitg.prscod
         ,l_fncclimatcod     like datmifxsblitg.fncclimatcod
         ,l_sblatdgrpnom     like datmifxsblitg.sblatdgrpnom
         ,l_trtdcttipnom     like datmifxsblitg.trtdcttipnom
         ,l_trtdctcod        like datmifxsblitg.trtdctcod
         ,l_refdcttipnom     like datmifxsblitg.refdcttipnom
         ,l_refdctcod        like datmifxsblitg.refdctcod
         ,l_atdasttipnom     like datmifxsblitg.atdasttipnom
         ,l_atdastdes        like datmifxsblitg.atdastdes
         ,l_atdsatdes        like datmifxsblitg.atdsatdes
         ,l_atdusrmatcod     like datmifxsblitg.atdusrmatcod
         ,l_legsisnom        like datmifxsblitg.legsisnom
         ,l_envdat           like datmifxsblitg.envdat
         ,l_legsisltrflg     like datmifxsblitg.legsisltrflg


 initialize l_ifxsblitgseqnum,l_sblitenum      ,l_sblatdnum      ,l_atdclitipcod   ,
            l_bcpclicod      ,l_clinom         ,l_clicpfnum      ,l_clicnpnum      ,
            l_suscod         ,l_prscod         ,l_fncclimatcod   ,l_sblatdgrpnom   ,
            l_trtdcttipnom   ,l_trtdctcod      ,l_refdcttipnom   ,l_refdctcod      ,
            l_atdasttipnom   ,l_atdastdes      ,l_atdsatdes      ,l_atdusrmatcod   ,
            l_legsisnom      ,l_envdat         ,l_legsisltrflg   to null





   if not m_prep or m_prep is null then
      call ctz00m00_prepare()
   end if


   #if g_issk.usrtip is null then
   #   error "Matricula Nula!" sleep 2
   #   return
   #end if

   {monta a matricula completa}
   call f_fungeral_junta_usrcod(g_issk.funmat
                               ,g_issk.empcod
                               ,g_issk.usrtip)
      returning l_atdusrmatcod
   #display "<154> ctz00m00-> l_atdusrmatcod < ", l_atdusrmatcod, "><", lr_param.legsisnom,">"
   whenever error continue
   open  cctz00m00001 using l_atdusrmatcod    {matricula completa}
                          , lr_param.legsisnom #Sistema Legado

   fetch cctz00m00001 into  l_ifxsblitgseqnum
                           ,l_sblitenum
                           ,l_sblatdnum
                           ,l_atdclitipcod
                           ,l_bcpclicod
                           ,l_clinom
                           ,l_clicpfnum
                           ,l_clicnpnum
                           ,l_suscod
                           ,l_prscod
                           ,l_fncclimatcod
                           ,l_sblatdgrpnom
                           ,l_trtdcttipnom
                           ,l_trtdctcod
                           ,l_refdcttipnom
                           ,l_refdctcod
                           ,l_atdasttipnom
                           ,l_atdastdes
                           ,l_atdsatdes
                           ,l_atdusrmatcod
                           ,l_legsisnom
                           ,l_envdat
                           ,l_legsisltrflg
   whenever error stop
   if sqlca.sqlcode <> 0 then    {nao achou}
      let l_legsisltrflg = false
      let l_sblatdnum = 0
   else                          {achou}
      if l_legsisltrflg = 1 then
      	 let l_legsisltrflg = true
      	 initialize
      	 l_ifxsblitgseqnum,l_sblitenum      ,l_sblatdnum      ,l_atdclitipcod   ,
         l_bcpclicod      ,l_clinom         ,l_clicpfnum      ,l_clicnpnum      ,
         l_suscod         ,l_prscod         ,l_fncclimatcod   ,l_sblatdgrpnom   ,
         l_trtdcttipnom   ,l_trtdctcod      ,l_refdcttipnom   ,l_refdctcod      ,
         l_atdasttipnom   ,l_atdastdes      ,l_atdsatdes      ,l_atdusrmatcod   ,
         l_legsisnom      ,l_envdat         ,l_legsisltrflg   to null

      else
        let l_legsisltrflg = true
        whenever error continue
        #execute pctz00m00003 using l_ifxsblitgseqnum
        execute pctz00m00003 using l_sblitenum
        whenever error stop

        if sqlca.sqlcode != 0 then
           return sqlca.sqlcode
        end if
      end if
   end if

   return  l_ifxsblitgseqnum
          ,l_sblitenum
          ,l_sblatdnum
          ,l_atdclitipcod
          ,l_bcpclicod
          ,l_clinom
          ,l_clicpfnum
          ,l_clicnpnum
          ,l_suscod
          ,l_prscod
          ,l_fncclimatcod
          ,l_sblatdgrpnom
          ,l_trtdcttipnom
          ,l_trtdctcod
          ,l_refdcttipnom
          ,l_refdctcod
          ,l_atdasttipnom
          ,l_atdastdes
          ,l_atdsatdes
          ,l_atdusrmatcod
          ,l_legsisnom
          ,l_envdat
          ,l_legsisltrflg

end function


#------------------------------------------#
 function ctz00m00_atualiza_siebel(lr_param)
#------------------------------------------#
   # funçao que vai enviar xml para mq
   define lr_param         record
          sblatdnum         like datmifxsblitg.sblatdnum     #Numero Siebel
         ,acssisnom         like datmifxmnn.acssisnom        #Nome Sistema Legado
         ,refdcttipnom      like datmifxsblitg.refdcttipnom  #Nome Doc. Ref.
         ,refdctcod         like datmifxsblitg.refdctcod     #Numero Doc. Ref.
         ,sblitenum         like datmifxsblitg.sblitenum     #Numero de Iteracao Siebel ?7
   end record

   define l_docHandle      smallint
        , l_valor          char(50)

   define l_xml   char(32500)


  define lr_put_mq record
         erro     integer,
         menserro char(30),
         msgid    char(24),
         correlid char(24)
  end record

  define lr_monitoramento  record
         sblatdnum         like datmifxmnn.sblatdnum
        ,usrmatcod         like datmifxmnn.usrmatcod
        ,acssisnom         like datmifxmnn.acssisnom
        ,acstlanom         like datmifxmnn.acstlanom
        ,trtastdes         like datmifxmnn.trtastdes
        ,trtdcttipnom      like datmifxmnn.trtdcttipnom
        ,trtdctcod         like datmifxmnn.trtdctcod
  end record

 define l_today       date,
        l_time        datetime hour to second

   initialize lr_put_mq.*, lr_monitoramento.* to null
   initialize l_today, l_time to null


   if not m_prep or m_prep is null then
      call ctz00m00_prepare()
   end if

   let l_docHandle = figrc011_novo_xml("mq")

   # let l_valor = current

   call cts40g03_data_hora_banco(1) returning l_today, l_time

   let l_valor = l_today clipped, " ", l_time

   call figrc011_atualiza_xml(l_docHandle
                             ,"/mq/dataAtualizacao"
                             ,l_valor)

   let l_valor = lr_param.acssisnom
   call figrc011_atualiza_xml(l_docHandle
                             ,"/mq/sistemaLegado"
                             ,l_valor)

   let l_valor = lr_param.refdctcod
   call figrc011_atualiza_xml(l_docHandle
                             ,"/mq/numeroReferencia"
                             ,l_valor)

   let l_valor = lr_param.refdcttipnom
   call figrc011_atualiza_xml(l_docHandle
                             ,"/mq/tipoReferencia"
                             ,l_valor)

   let l_valor = lr_param.sblatdnum
   call figrc011_atualiza_xml(l_docHandle
                             ,"/mq/numeroAtendimento"
                             ,l_valor)

   ## CRM Ajuste HDK-Funeral
   let l_valor = lr_param.sblitenum
   call figrc011_atualiza_xml(l_docHandle
                             ,"/mq/numeroIteracao"
                             ,l_valor)

   call setBigCharInOut()

   let l_xml = figrc011_retorna_xml_gerado(l_docHandle)

   call figrc006_enviar_datagrama_mq_rq("ATDCRMSNIFJAVA01D", l_xml,
                                        "",online())
    returning lr_put_mq.erro,
              lr_put_mq.menserro,
              lr_put_mq.msgid,
              lr_put_mq.correlid

   if lr_put_mq.erro != 0 then
      let lr_monitoramento.sblatdnum    = lr_param.sblatdnum
      let lr_monitoramento.usrmatcod    = 'F9999999'
      let lr_monitoramento.acssisnom    = lr_param.acssisnom
      let lr_monitoramento.acstlanom    = 'ctz00m00'
      let lr_monitoramento.trtastdes    = 'Atualizacao Siebel'
      let lr_monitoramento.trtdcttipnom = lr_param.refdcttipnom
      let lr_monitoramento.trtdctcod    = lr_param.refdctcod
      call ctz00m00_grava_monitoramento(lr_monitoramento.*)
         returning l_valor, l_valor

      return lr_put_mq.erro
   end if

   #libera o xml
   call unSetBigChar()
   call figrc011_fim_novo_xml(l_docHandle)

   return (lr_put_mq.erro = 0)
end function


#----------------------------------------------#
 function ctz00m00_grava_monitoramento(lr_param)
#----------------------------------------------#
   define lr_param         record
             sblatdnum         like datmifxmnn.sblatdnum
            ,usrmatcod         like datmifxmnn.usrmatcod
            ,acssisnom         like datmifxmnn.acssisnom
            ,acstlanom         like datmifxmnn.acstlanom
            ,trtastdes         like datmifxmnn.trtastdes
            ,trtdcttipnom      like datmifxmnn.trtdcttipnom
            ,trtdctcod         like datmifxmnn.trtdctcod
          end record

   define l_legsisnom      like datmifxsblitg.legsisnom    {sistema legado}
         ,l_num            integer

   define l_today       date,
          l_time        datetime hour to second

   if not m_prep or m_prep is null then
      call ctz00m00_prepare()
   end if

   initialize mr_sblatdver.* to null
   initialize l_today, l_time to null

   open cctz00m00004
   fetch cctz00m00004 into mr_sblatdver.mnnseqnum
   close cctz00m00004
   if mr_sblatdver.mnnseqnum is null or mr_sblatdver.mnnseqnum = 0 then
      let mr_sblatdver.mnnseqnum = 0
   end if

   call cts40g03_data_hora_banco(1) returning l_today, l_time

   let mr_sblatdver.mnnseqnum    = mr_sblatdver.mnnseqnum + 1
   let mr_sblatdver.acsdat       = l_time
   let mr_sblatdver.sblatdnum    = lr_param.sblatdnum
   let mr_sblatdver.usrmatcod    = lr_param.usrmatcod
   let mr_sblatdver.acssisnom    = lr_param.acssisnom
   let mr_sblatdver.acstlanom    = lr_param.acstlanom
   let mr_sblatdver.trtastdes    = lr_param.trtastdes
   let mr_sblatdver.trtdcttipnom = lr_param.trtdcttipnom
   let mr_sblatdver.trtdctcod    = lr_param.trtdctcod

   whenever error continue
   #execute pctz00m00002 using mr_sblatdver.*
   execute pctz00m00002 using mr_sblatdver.mnnseqnum
                             ,mr_sblatdver.sblatdnum
                             ,mr_sblatdver.acsdat
                             ,mr_sblatdver.usrmatcod
                             ,mr_sblatdver.acssisnom
                             ,mr_sblatdver.acstlanom
                             ,mr_sblatdver.trtastdes
                             ,mr_sblatdver.trtdctcod
                             ,mr_sblatdver.trtdcttipnom
   whenever error stop

   if sqlca.sqlcode = 0 then
      return 0, mr_sblatdver.mnnseqnum
   else
      return sqlca.sqlcode, 0
   end if

end function

