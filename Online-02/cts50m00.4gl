#############################################################################
# Nome do Modulo: cts50m00                                             Nilo #
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

define m_prep_sql smallint
define mr_abnsit  like datkabn.abnsit

#--------------------------
function cts50m00_prepara()
#--------------------------

    define l_sql         char(300)

    let l_sql = "select inidat ",
                     " ,abninihor ",
                     " ,abntel ",
                     " ,pades ",
                     " ,abncont ",
                     " ,abnsit ",
                 " from datkabn ",
                " where (abnsit is null ",
                  "  or abnsit not in (3,4)) ",
                  " and inidat = today ",
                " order by inidat desc ,abninihor desc "
    prepare p_cts50m00_001 from l_sql
    declare c_cts50m00_001 cursor for p_cts50m00_001

    let l_sql = "select count(*) ",
                 " from datkabn ",
                " where abntel = ? ",
                  " and inidat = ? "
    prepare p_cts50m00_002 from l_sql
    declare c_cts50m00_002 cursor for p_cts50m00_002

    let m_prep_sql = true

end function

#------------------------------------------------------------
function cts50m00()
#------------------------------------------------------------

 define l_ws            record
        srrcoddig       like dattfrotalocal.srrcoddig
       ,pstcoddig       like datkveiculo.pstcoddig
       ,socvclcod       like dattfrotalocal.socvclcod
       ,atdetpcod       like datmsrvacp.atdetpcod
 end record

 define l_status        integer

 define i smallint
 define i2 smallint

 define aux_tamanho smallint
 define aux_entrada char(05)
 define aux_saida   char(04)
 define aux_char   char(01)
 define w_data     date

 let aux_tamanho = null
 let aux_entrada = null
 let aux_saida   = null
 let aux_char    = null
 let w_data      = null

 if   m_prep_sql = false or
      m_prep_sql is null
 then
      call cts50m00_prepara()
 end if

 call get_param()

 open window cts50m00 at 04,02 with form "cts50m00"

     menu "ABANDONO "

     before menu
        hide option all

        show option "Ligacoes"
        show option "Historico"
        show option "eNcerra"

        command key ("L")  "Ligacoes"    "Consulta Ligacoes em Abandono"
           clear form
           call cts50m00_consulta_ligacoes()

        command key ("H")  "Historico" "Historico das Ligacoes em Abandono"
           clear form
           call cts50m01_input()

        command key (interrupt, E )  "Encerra"
           "Encerra Atendimento de Ligacoes em Abandono"
           exit menu
     end menu

     let int_flag = false
     close window cts50m00

 end function  ###  cts50m00

#------------------------------------------------------------------
 function cts50m00_consulta_ligacoes()
#------------------------------------------------------------------

   define al_cts50m00      array[5000] of record
          inidat           like datkabn.inidat
         ,abninihor        like datkabn.abninihor
         ,abntel           like datkabn.abntel
         ,qtd_lig          smallint
         ,pades            like datkabn.pades
         ,abncont          like datkabn.abncont
         ,abnsitdesc       char(50)
   end    record
   define aux_abnsit   integer
   define l_flag       smallint
   define l_cont       integer
   define l_arraycont  integer

   define w_apoio      char(01)
   define w_empcodatd  like isskfunc.empcod
   define w_funmatatd  like isskfunc.funmat
   define w_usrtipatd  like isskfunc.usrtip
   initialize al_cts50m00 to null
   let l_cont      = null
   let l_arraycont = null
   let aux_abnsit  = null
   let l_cont      = 1

   set isolation to dirty read

   open c_cts50m00_001
   foreach c_cts50m00_001 into al_cts50m00[l_cont].inidat
                            ,al_cts50m00[l_cont].abninihor
                            ,al_cts50m00[l_cont].abntel
                            ,al_cts50m00[l_cont].pades
                            ,al_cts50m00[l_cont].abncont
                            ,aux_abnsit
      case aux_abnsit
           when 1
              let al_cts50m00[l_cont].abnsitdesc = 'NAO FOI POSSIVEL A LIGACAO'
           when 2
              let al_cts50m00[l_cont].abnsitdesc = 'PENDENTE'
           when 3
              let al_cts50m00[l_cont].abnsitdesc = 'LIGOU - DEU ENCAMINHAMENTO NO ATENDIMENTO'
           when 4
              let al_cts50m00[l_cont].abnsitdesc = 'CONCLUIU - FINALIZOU A LIGACAO'
           when 5
              let al_cts50m00[l_cont].abnsitdesc = 'DEIXOU RECADO'
           when 6
              let al_cts50m00[l_cont].abnsitdesc = 'SEGURADO ENTRARA EM CONTATO'
      end case

      if al_cts50m00[l_cont].abncont is null then
         let al_cts50m00[l_cont].abncont = 'N'
      end if

      let al_cts50m00[l_cont].qtd_lig = 0
      open c_cts50m00_002 using al_cts50m00[l_cont].abntel
                             ,al_cts50m00[l_cont].inidat
      fetch c_cts50m00_002 into al_cts50m00[l_cont].qtd_lig
      if aux_abnsit is null then
         let al_cts50m00[l_cont].abnsitdesc = 'PENDENTE'
      end if

      if l_cont = 1000 then
         error "O Limite de consulta de ligacoes estourou."
         exit foreach
      end if

      let l_cont = l_cont + 1

   end foreach

   message "    (F2)Altera Status, (F8)Atendimento, (CTRL-C)Retorna"

   call set_count(l_cont)
   display array al_cts50m00 to s_cts50m00.*

   on key (f8)

        let l_cont = arr_curr()

        initialize g_documento.* to null
        let g_lignum_abn  = null
        let g_abntel_abn = null
        let g_inidat_abn = null

        #-- Chamada da classe de controle de atendimento --#
        let g_documento.ciaempcod = '1'
        let g_abntel_abn = al_cts50m00[l_cont].abntel
        let g_inidat_abn = al_cts50m00[l_cont].inidat

        let l_flag = cta00m05_controle(w_apoio,
                                       w_empcodatd,
                                       w_funmatatd,
                                       w_usrtipatd,
                                       g_c24paxnum)

      current window is cts50m00

        call cts50m02_input(al_cts50m00[l_cont].abntel
                           ,al_cts50m00[l_cont].inidat
                           ,al_cts50m00[l_cont].abninihor
                           ,al_cts50m00[l_cont].pades)
             returning mr_abnsit

    on key (f2)

      let l_cont = arr_curr()
      let mr_abnsit = null

      call cts50m02_input(al_cts50m00[l_cont].abntel
                         ,al_cts50m00[l_cont].inidat
                         ,al_cts50m00[l_cont].abninihor
                         ,al_cts50m00[l_cont].pades)
           returning mr_abnsit

      current window is cts50m00

    on key (interrupt,control-c)

        exit display
   end display

   return

end function  ###  cts50m00_consulta_ligacoes
