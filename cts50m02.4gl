#############################################################################
# Nome do Modulo: cts50m02                                             Nilo #
#                                                                           #
# CALL BACK - INCLUSAO DE HISTORICO DE ABANDONO                    Abr/2008 #
#############################################################################
#-----------------------------------------------------------------------------#
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- -------------------------------------- #
#                                                                             #
#                                                                             #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define mr_inp          record
       abnsit          like datkabn.abnsit
      ,abnsitdesc      char(50)
      ,abndes          char(50)
end record

define mr_param      record
       abntel        like datmabnhst.abntel
      ,abndat        like datmabnhst.abndat
      ,abnhor        like datmabnhst.abnhor
      ,abnfil        like datmabnhst.abnfil
end record

define m_sql_pop       char(300)

define m_erro          smallint

#------------------------------------------------------------
function cts50m02_input(lr_param)
#------------------------------------------------------------

 define lr_param      record
        abntel        like datmabnhst.abntel
       ,abndat        like datmabnhst.abndat
       ,abnhor        like datmabnhst.abnhor
       ,abnfil        like datmabnhst.abnfil
 end record

 define lr_out        record     # Parametros retornados
        erro          smallint   # Resultado da operacao:
                                 # 0 - Selecionou
                                 # 1 - Nenhum registro selecionado
                                 # < 0 - Erro Sql
       ,cod           char (011) # Codigo
       ,dsc           char (040) # Descricao
 end record

 initialize mr_inp.* to null
 initialize mr_param.* to null
 initialize lr_out.* to null

 open window cts50m02 at 12,03 with form "cts50m02"
                         attribute (border,
                                    white,
                                    form    line 01,
                                    message line last,
                                    comment line last - 01)

 let mr_param.abntel = lr_param.abntel
 let mr_param.abndat = lr_param.abndat
 let mr_param.abnhor = lr_param.abnhor
 let mr_param.abnfil = lr_param.abnfil

 let int_flag = false

 input by name mr_inp.abnsit
              ,mr_inp.abndes without defaults

   before field abnsit
      initialize mr_inp.abnsit to null
      initialize mr_inp.abnsitdesc to null
      let int_flag = false

   after field abnsit

      display by name mr_inp.abnsit

      let m_sql_pop = null
      let m_sql_pop = "select cpocod ",
                           " ,cpodes ",
                       " from iddkdominio ",
                      " where cponom = 'abnsit' "

      if mr_inp.abnsit is null then

         let mr_inp.abnsitdesc = null

         call ofgrc001_popup(10
                            ,12
                            ,'Situacao Abandono'
                            ,'Codigo'
                            ,'Desc.'
                            ,'A'
                            ,m_sql_pop
                            ,''
                            ,'D')
              returning lr_out.erro
                       ,mr_inp.abnsit
                       ,mr_inp.abnsitdesc
      else
          let mr_inp.abnsitdesc = null
          select cpodes
            into mr_inp.abnsitdesc
            from iddkdominio
           where cponom = 'abnsit'
             and cpocod = mr_inp.abnsit
      end if

      if mr_inp.abnsit is null then
         error " Informar o codigo da situacao do Abandono."
         next field abnsit
      end if

      display by name mr_inp.abnsit
      display by name mr_inp.abnsitdesc

   before field abndes
      initialize mr_inp.abndes to null

   after field abndes
      display by name mr_inp.abndes

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field abnsit
      end if

      if mr_inp.abndes is null or
         mr_inp.abndes = ' '   then
         error " Informar a descricao do Historico do Abandono."
         next field abndes
      end if

      display by name mr_inp.abndes

      exit input

      on key (interrupt,control-c)

         error " A Informacao dos campos e' obrigatoria."
         next field abnsit

 end input

 let m_erro = 0

 call cts50m02_insere_historico()

 if m_erro <> 0 then
    close window cts50m02
    return mr_inp.abnsit
 end if

 if mr_inp.abnsit = 4 or
    mr_inp.abnsit = 3 then

    let m_erro = 0

    call cts50m02_gera_espelho(lr_param.abntel
                              ,lr_param.abndat)

    sleep 2
 else
    call cts50m02_muda_status(lr_param.abntel,lr_param.abndat)
 end if

 close window cts50m02

 return mr_inp.abnsit

end function  ###  cts50m02

#------------------------------------------------------------------
function cts50m02_insere_historico()
#------------------------------------------------------------------

   define aux_abntelseq smallint
   define aux_cttdathor like datmabnhst.cttdathor

   let aux_abntelseq = null
   let aux_cttdathor = null

   let aux_cttdathor = current

   select max(abntelseq)
     into aux_abntelseq
     from datmabnhst
    where abntel = mr_param.abntel
      -- and abndat = mr_param.abndat

   if aux_abntelseq is null or
      aux_abntelseq = 0     then
      let aux_abntelseq = 1
   else
      let aux_abntelseq = aux_abntelseq + 1
   end if

   begin work

   insert into datmabnhst values (mr_param.abntel
                                 ,aux_abntelseq
                                 ,mr_param.abndat
                                 ,mr_param.abnhor
                                 ,mr_param.abnfil
                                 ,mr_inp.abnsit
                                 ,g_lignum_abn
                                 ,mr_inp.abndes
                                 ,g_issk.empcod
                                 ,g_issk.usrtip
                                 ,g_issk.funmat
                                 ,aux_cttdathor)

   if sqlca.sqlcode <> 0 then
      error " Erro ao inserir Historico do Abandono. Erro " ,sqlca.sqlcode clipped
      rollback work
      let m_erro = 1
      return
   end if

   error " Historico do Abandono inserido com sucesso."

   commit work

   return

end function  ###  cts50m02_insere_historico
#------------------------------------------------------------------
function cts50m02_gera_espelho(lr_param2)
#------------------------------------------------------------------

   define lr_param2    record
          abntel       like datkabn.abntel
         ,inidat       like datkabn.inidat
   end record

   define lr_espelho   record
          abnide       like datkabn.abnide
         ,abntel       like datkabn.abntel
         ,condat       like datkabn.condat
         ,filinidat    like datkabn.filinidat
         ,inidat       like datkabn.inidat
         ,pades        like datkabn.pades
         ,filtmp       like datkabn.filtmp
         ,ligdur       like datkabn.ligdur
         ,abnfil       like datkabn.abnfil
         ,abnsit       like datkabn.abnsit
         ,abncont      like datkabn.abncont
         ,conthor      like datkabn.conthor
         ,lignum       like datkabn.lignum
         ,empcod       like datkabn.empcod
         ,usrtip       like datkabn.usrtip
         ,funmat       like datkabn.funmat
         ,abninihor    like datkabn.abninihor
         ,abnfilinihor like datkabn.abnfilinihor
   end record

   define lr_aux       record
          abnespide    like datkabnesp.abnespide
   end record

   define l_sql2       char(300)

   let l_sql2 = null

   initialize lr_aux.* to null

   let l_sql2 = ' insert into datkabnesp ( abnespide, '
                                       ,' abntel, '
                                       ,' condat, '
                                       ,' filinidat, '
                                       ,' inidat, '
                                       ,' pades, '
                                       ,' filtmp, '
                                       ,' ligdur, '
                                       ,' abnfil, '
                                       ,' abnsit, '
                                       ,' abncont, '
                                       ,' conthor, '
                                       ,' lignum, '
                                       ,' empcod, '
                                       ,' usrtip, '
                                       ,' funmat, '
                                       ,' abninihor, '
                                       ,' abnfilinihor, '
                                       ,' abnide ) '
                              ,' values(?,?,today,?,?,?,?,?,?,?,"S",current,?,?,?,?,?,?,?) '

   prepare p_cts50m02_001 from l_sql2

   begin work

   select max(abnespide)
     into lr_aux.abnespide
     from datkabnesp

   set isolation to dirty read

   declare c_cts50m02_001 cursor for
     select abnide
           ,abntel
           ,condat
           ,filinidat
           ,inidat
           ,pades
           ,filtmp
           ,ligdur
           ,abnfil
           ,abnsit
           ,abncont
           ,conthor
           ,lignum
           ,empcod
           ,usrtip
           ,funmat
           ,abninihor
           ,abnfilinihor
       from datkabn
      where abntel = lr_param2.abntel
        and inidat = lr_param2.inidat

   foreach c_cts50m02_001 into lr_espelho.*

      if lr_aux.abnespide is null or
         lr_aux.abnespide = 0     then
         let lr_aux.abnespide = 1
      else
         let lr_aux.abnespide = lr_aux.abnespide + 1
      end if

      execute p_cts50m02_001 using lr_aux.abnespide
                                ,lr_espelho.abntel
                                ,lr_espelho.filinidat
                                ,lr_espelho.inidat
                                ,lr_espelho.pades
                                ,lr_espelho.filtmp
                                ,lr_espelho.ligdur
                                ,lr_espelho.abnfil
                                ,mr_inp.abnsit
                                ,g_lignum_abn
                                ,g_issk.empcod
                                ,g_issk.usrtip
                                ,g_issk.funmat
                                ,lr_espelho.abninihor
                                ,lr_espelho.abnfilinihor
                                ,lr_espelho.abnide

      if sqlca.sqlcode <> 0 then
         let m_erro = sqlca.sqlcode
         exit foreach
      end if

   end foreach

   if m_erro <> 0 then
      rollback work
      error " Erro na inclusao do Espelho. Erro " ,m_erro
      let m_erro = 1
      return
   end if

   #-----------------------------
   #---> Limpa Tabela de Abandono
   #-----------------------------
   delete from datkabn
    where abntel = lr_param2.abntel
      and inidat = lr_param2.inidat

   if sqlca.sqlcode <> 0 then
      error " Erro na Limpeza da tabela de Abandono. Erro " ,sqlca.sqlcode
      rollback work
      let m_erro = 1
      return
   end if

   error " Inclusao do Espelho e Limpeza da Tabela Abandono efetuado com sucesso."
   commit work

   return

end function  ###  cts50m01_gera_espelho
#------------------------------------------------------------------
function cts50m02_muda_status(lr_param3)
#------------------------------------------------------------------

   define lr_param3    record
          abntel       like datkabn.abntel
         ,inidat       like datkabn.inidat
   end record

   begin work

   update datkabn set abnsit = mr_inp.abnsit
                     ,condat = today
                     ,abncont = 'S'
                     ,empcod = g_issk.empcod
                     ,usrtip = g_issk.usrtip
                     ,funmat = g_issk.funmat
    where abntel = lr_param3.abntel
      and inidat = lr_param3.inidat

   if sqlca.sqlcode <> 0 then
      error " Erro ao atualizar Satatus do Abandono. Erro " ,sqlca.sqlcode clipped
      rollback work
      let m_erro = 1
      return
   end if

   error " Status do Abandono alterado com sucesso."

   commit work

   return

end function  ###  cts50m02_insere_historico
