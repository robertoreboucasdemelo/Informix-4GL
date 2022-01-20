#############################################################################
# Nome do Modulo: cts50m01                                             Nilo #
#                                                                           #
# CALL BACK - LIGAÇÕES EM ABANDONO                                 Mar/2008 #
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

define am_cts50m01      array[5000] of record
       inidat           like datkabn.inidat
      ,abninihor        like datkabn.abninihor
      ,abntel           like datkabn.abntel
      ,pades            like datkabn.pades
      ,lignum           like datkabn.lignum
      ,abncont          like datkabn.abncont
      ,status           char(50)
end record

define mr_inp          record
       datlig          date
      ,telefone        char(12)
      ,abnsit          like datkabn.abnsit
      ,abnsitdesc      char(50)
end record

define m_sql_pop       char(300)
define m_cont          smallint

define mr_abnsit       like datkabn.abnsit

#--------------------------
function cts50m01_prepara()
#--------------------------

    define l_sql         char(300)

    let l_sql = "select inidat ",
                     " ,abninihor ",
                     " ,abntel ",
                     " ,pades ",
                     " ,lignum ",
                     " ,abncont ",
                     " ,abnsit ",
                     " ,empcod ",
                     " ,usrtip ",
                     " ,funmat ",
                 " from datkabnesp ",
                " where inidat = " ,'"',mr_inp.datlig ,'"'

    if mr_inp.telefone is not null and
       mr_inp.telefone <> ' '      then
       let l_sql = l_sql clipped ," and abntel = " ,'"',mr_inp.telefone,'"'
    end if

    if mr_inp.abnsit is not null and
       mr_inp.abnsit <> 0        then
       let l_sql = l_sql clipped ," and abnsit = " ,mr_inp.abnsit
    end if

    let l_sql = l_sql clipped ," order by inidat desc ,abninihor desc "

    prepare p_cts50m01_001 from l_sql
    declare c_cts50m01_001 cursor for p_cts50m01_001

    let l_sql = "select funnom ",
                 " from isskfunc ",
                " where empcod = ? ",
                  " and usrtip = ? ",
                  " and funmat = ? "
    prepare p_cts50m01_002 from l_sql
    declare c_cts50m01_002 cursor for p_cts50m01_002

    let l_sql = "select abntelseq ",
                     " ,abndes ",
                     " ,abnsit ",
                     " ,cttdathor ",
                     " ,empcod ",
                     " ,usrtip ",
                     " ,funmat ",
                 " from datmabnhst ",
                " where abndat = ? ",
                  " and abntel = ? ",
                " order by abntelseq desc "
    prepare p_cts50m01_003 from l_sql
    declare c_cts50m01_003 cursor for p_cts50m01_003

    let l_sql = "select cpodes ",
                 " from iddkdominio ",
                 " where cponom = 'abnsit' ",
                   " and cpocod = ? "
    prepare p_cts50m01_004 from l_sql
    declare c_cts50m01_004 cursor for p_cts50m01_004

end function

#------------------------------------------------------------
function cts50m01_input()
#------------------------------------------------------------

 define lr_out        record     # Parametros retornados
        erro          smallint   # Resultado da operacao:
                                 # 0 - Selecionou
                                 # 1 - Nenhum registro selecionado
                                 # < 0 - Erro Sql
       ,cod           char (011) # Codigo
       ,dsc           char (040) # Descricao
 end record

 initialize mr_inp.* to null
 initialize lr_out.* to null

 open window cts50m01 at 06,02 with form "cts50m01"
                      attribute(form line 1)

 input by name mr_inp.datlig
              ,mr_inp.telefone
              ,mr_inp.abnsit without defaults

   before field datlig
      display by name mr_inp.datlig

   after field datlig
      display by name mr_inp.datlig

      if mr_inp.datlig is null or
         mr_inp.datlig = ' '   then
         let mr_inp.datlig = today

         error " Data do Abandono deve ser informada."
         next field datlig
      end if
      if mr_inp.datlig > today then
         error " Data para consulta nao pode ser maior que hoje."
         next field datlig
      end if

      display by name mr_inp.datlig

      next field telefone

   before field telefone
      initialize mr_inp.telefone to null

   after field telefone
      display by name mr_inp.telefone
      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field datlig
      end if

      next field abnsit

   before field abnsit
      initialize mr_inp.abnsitdesc to null
      let int_flag = false

   after field abnsit
      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field telefone
      end if

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

              let int_flag = false
      end if

      call cts50m01_prepara()

      if mr_inp.abnsit is null or
         mr_inp.abnsit = ' '   then
         let mr_inp.abnsit = 0
         let mr_inp.abnsitdesc = 'TODOS'
      else
         if mr_inp.abnsit = 0 then
            let mr_inp.abnsitdesc = 'TODOS'
         else
            open c_cts50m01_004 using mr_inp.abnsit
            fetch c_cts50m01_004 into mr_inp.abnsitdesc
         end if
      end if

      display by name mr_inp.abnsit
      display by name mr_inp.abnsitdesc

     on key (interrupt,control-c)

        exit input

 end input

 if int_flag then
    close window cts50m01
    return
 end if

 call cts50m01_historico()

 message "        (F8)Descricao Historico, (CTRL-C)Retorna"

 call set_count(m_cont)
 display array am_cts50m01 to s_cts50m01.*

    on key (f8)

      let m_cont = arr_curr()
      let mr_abnsit = null

      call cts50m01_descricao(am_cts50m01[m_cont].inidat
                             ,am_cts50m01[m_cont].abninihor
                             ,am_cts50m01[m_cont].abntel
                             ,am_cts50m01[m_cont].lignum)

    on key (interrupt,control-c)

      exit display

 end display

 close window cts50m01

 return

end function  ###  cts50m01
#------------------------------------------------------------------
function cts50m01_historico()
#------------------------------------------------------------------

   define lr_aux       record
          abnsit       like datkabn.abnsit
         ,empcod       like datkabn.empcod
         ,usrtip       like datkabn.usrtip
         ,funmat       like datkabn.funmat
   end record

   define l_arraycont  integer

   initialize am_cts50m01 to null
   initialize lr_aux.* to null

   let m_cont      = null
   let l_arraycont = null
   let m_cont      = 1

   set isolation to dirty read

   foreach c_cts50m01_001 into am_cts50m01[m_cont].inidat
                            ,am_cts50m01[m_cont].abninihor
                            ,am_cts50m01[m_cont].abntel
                            ,am_cts50m01[m_cont].pades
                            ,am_cts50m01[m_cont].lignum
                            ,am_cts50m01[m_cont].abncont
                            ,lr_aux.abnsit
                            ,lr_aux.empcod
                            ,lr_aux.usrtip
                            ,lr_aux.funmat

      open c_cts50m01_004 using lr_aux.abnsit
      fetch c_cts50m01_004 into am_cts50m01[m_cont].status

      if m_cont = 1000 then
         error "O Limite de consulta de ligacoes estourou."
         exit foreach
      end if

      let m_cont = m_cont + 1

   end foreach

   if am_cts50m01[1].inidat is null then
      error " Nenhum registro encontrado para essa pesquisa."
   end if

   return

end function  ###  cts50m01_historico
#------------------------------------------------------------------
function cts50m01_descricao(lr_param)
#------------------------------------------------------------------

   define lr_param         record
          inidat           like datkabn.inidat
         ,abninihor        like datkabn.abninihor
         ,abntel           like datkabn.abntel
         ,lignum           like datkabn.lignum
   end record

   define al_desc          array[5000] of record
          abntelseq        like datmabnhst.abntelseq
         ,abndes           like datmabnhst.abndes
         ,status_desc      char(50)
         ,por              char(04)
         ,funnom           like isskfunc.funnom
         ,cttdathor        like datmabnhst.cttdathor
   end record

   define lr_aux2      record
          abnsit       like datmabnhst.abnsit
         ,empcod       like datkabn.empcod
         ,usrtip       like datkabn.usrtip
         ,funmat       like datkabn.funmat
   end record

   define i            integer

   initialize al_desc to null
   initialize lr_aux2.* to null

   open window cts50m01a at 10,04 with form "cts50m01a"
                         attribute (border,
                                    white,
                                    form    line 01,
                                    message line last,
                                    comment line last - 01)

   let i = null
   let i = 1

   display by name lr_param.*

   set isolation to dirty read

   open c_cts50m01_003 using lr_param.inidat
                         ,lr_param.abntel
   foreach c_cts50m01_003 into al_desc[i].abntelseq
                            ,al_desc[i].abndes
                            ,lr_aux2.abnsit
                            ,al_desc[i].cttdathor
                            ,lr_aux2.empcod
                            ,lr_aux2.usrtip
                            ,lr_aux2.funmat


      open c_cts50m01_002 using lr_aux2.empcod
                             ,lr_aux2.usrtip
                             ,lr_aux2.funmat
      fetch c_cts50m01_002 into al_desc[i].funnom
      open c_cts50m01_004 using lr_aux2.abnsit
      fetch c_cts50m01_004 into al_desc[i].status_desc

      if m_cont = 1000 then
         error "O Limite de consulta de ligacoes estourou."
         exit foreach
      end if

      let al_desc[i].por = 'Por:'

      let i = i + 1
      initialize lr_aux2.* to null

   end foreach

   if al_desc[1].abntelseq is null then
      error " Nenhum registros encontrado para essa pesquisa."
   end if

 call set_count(i)
 message "        (CTRL-C)Retorna"

 display array al_desc to s_cts50m01a.*

    on key (interrupt,control-c)

      exit display

 end display

 close window cts50m01a

 return

end function  ###  cts50m01_descricao
