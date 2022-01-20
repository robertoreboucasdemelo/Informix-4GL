#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: auto /orcamento                                             #
# Modulo.........: cte05m00                                                   #
# Analista Resp..: Leticia Pereira                                             #
# PSI/OSF........:                                                             #
# Objetivo.......: Cadastro de integracao de assunto CRM x Informix.           #
#                                                                              #
# ............................................................................ #
# Desenvolvimento: Saymon Silva - Meta                                         #
# Liberacao......: 27/09/2012                                                  #
# ............................................................................ #
#                                                                              #
#                        * * * Alteracoes * * *                                #
#                                                                              #
# Data       Autor Fabrica  Origem     Alteracao                               #
# ---------- -------------- ---------- ----------------------------------------#
#                                                                              #
#------------------------------------------------------------------------------#

database porto

define mr_cte05m00 record
   astnom        char(50)
  ,suanom        char(50)
  ,viginidat     date
  ,vigfimdat     date
  ,rccflg        char(1)
  ,edstipcod     dec(3,0)
  ,txttpe        char(50)
  ,edstxtcod     dec(3,0)
end record

define m_ind        smallint
define m_acao       char(1)
define m_prompt     char(1)

function cte05m00()

   call cte05m00_menu()

end function

#-------------------------------------#
function cte05m00_menu()
#-------------------------------------#

   call cte05m00_prepare()

   open window w_cte05m00 at 2,2 with form "cte05m00"
      attribute (border
                ,prompt  line 21
                ,message line 22
                )

   menu "CRM_Informix "
      before menu
         hide option "Modificar"
      command "Selecionar"
         call cte05m00_seleciona()

         if mr_cte05m00.astnom is not null or
            mr_cte05m00.astnom <> ''  then
            show option "Modificar"
         else
            hide option "Modificar"
         end if

      command "Modificar"
         call cte05m00_modifica()
      command "Incluir"
         call cte05m00_inclui()

         if mr_cte05m00.astnom is not null or
            mr_cte05m00.astnom <> ''  then
            show option "Modificar"
         end if

      command "Encerrar"
         exit menu
   end menu

close window w_cte05m00

end function

#-------------------------------------#
function cte05m00_prepare()
#-------------------------------------#
   define l_sql char(500)

   let l_sql = "select astnom          "
             ,"       ,suanom          "
             ,"       ,viginidat       "
             ,"       ,vigfimdat       "
             ,"       ,rccflg          "
             ,"       ,edstipcod       "
             ,"       ,edstxtcod       "
             ,"  from datkatdsuaastint " # ???
             ," where intseqnum = ?    "
   prepare p_cte05m00_01 from l_sql
   declare c_cte05m00_01 cursor with hold for p_cte05m00_01

   let l_sql = "select suanom          "
             ,"  from datkatdsuaastint " # ???
             ," where intseqnum = ?    "
   prepare p_cte05m00_01s from l_sql
   declare c_cte05m00_01s cursor with hold for p_cte05m00_01s
   let l_sql = "select intseqnum        "
             ,"       ,astnom           "
             ,"   from datkatdsuaastint " # ???

   prepare p_cte05m00_02 from l_sql
   declare c_cte05m00_02 cursor with hold for p_cte05m00_02
   let l_sql = "select  viginidat       "
             ,"       , vigfimdat       "
             ,"       , rccflg          "
             ,"       , edstipcod       "
             ,"       , edstxtcod       "
             ,"   from datkatdsuaastint "
             ,"  where astnom = ?       "
             ,"    and suanom = ?       "
   prepare p_cte05m00_02s from l_sql
   declare c_cte05m00_02s cursor with hold for p_cte05m00_02s

   let l_sql = "select suanom          "
             ,"       ,viginidat       "
             ,"       ,vigfimdat       "
             ,"       ,rccflg          "
             ,"       ,edstipcod       "
             ,"       ,edstxtcod       "
             ,"  from datkatdsuaastint " # ???
             ," where astnom  = ?  "

   prepare p_cte05m00_03 from l_sql
   declare c_cte05m00_03 cursor with hold for p_cte05m00_03

   let l_sql = "select suanom            "
             ,"       ,viginidat         "
             ,"       ,vigfimdat         "
             ,"       ,rccflg            "
             ,"       ,edstipcod         "
             ,"       ,edstxtcod         "
             ,"  from datkatdsuaastint " # ???
             ," where suanom  = ?  "
             ,"   and astnom  = ?  "

   prepare p_cte05m00_03s from l_sql
   declare c_cte05m00_03s cursor with hold for p_cte05m00_03s

   let l_sql =" insert into datkatdsuaastint" # ???
             ,"       (astnom               "
             ,"       ,suanom               "
             ,"       ,viginidat            "
             ,"       ,vigfimdat            "
             ,"       ,rccflg               "
             ,"       ,edstipcod            "
             ,"       ,edstxtcod      )     "
             ,"   values(?,?,?,?            "
             ,"         ,?,?,?)             "

   prepare p_cte05m00_04 from l_sql

   let l_sql =" update datkatdsuaastint" # ???
             ,"    set viginidat     = ?"
             ,"       ,vigfimdat     = ?"
             ,"       ,rccflg        = ?"
             ,"       ,edstipcod     = ?"
             ,"       ,edstxtcod     = ?"
             ,"  where astnom        = ?"
             ,"    and suanom        = ?"

   prepare p_cte05m00_05 from l_sql

   let l_sql =  "select edstipdes  "
               ,"  from agdktip    "
               ," where edstip = ? "

   prepare p_cte05m00_06 from l_sql
   declare c_cte05m00_06 cursor with hold for p_cte05m00_06

   let l_sql =  "select 1               "
               ,"  from agdktiptxt      "
               ," where edstip      = ? "
               ,"   and edstxt      = ? "
               ,"   and clctip in (1,2) "

   prepare p_cte05m00_07 from l_sql
   declare c_cte05m00_07 cursor with hold for p_cte05m00_07


   let l_sql = "select intseqnum         "
             ,"       ,suanom            "
             ,"   from datkatdsuaastint  "
             ," where upper(astnom) = ?  "

   prepare p_cte05m00_08 from l_sql
   declare c_cte05m00_08 cursor with hold for p_cte05m00_08
   let l_sql = "select suanom"
             ,"   from datkatdsuaastint "
             ," where intseqnum = ?     "
   prepare p_cte05m00_09 from l_sql
   declare c_cte05m00_09 cursor with hold for p_cte05m00_09

end function

#-------------------------------------#
function cte05m00_seleciona()
#-------------------------------------#

   initialize mr_cte05m00 to null
   clear form

   input by name mr_cte05m00.astnom thru
                 mr_cte05m00.suanom without defaults

      after field astnom
         if mr_cte05m00.astnom is null or
            mr_cte05m00.astnom = '' then

            let m_ind = cte05m00_popup('A')

            open c_cte05m00_01 using m_ind

            whenever error continue
            fetch c_cte05m00_01 into  mr_cte05m00.astnom
         else
            open c_cte05m00_03 using mr_cte05m00.astnom
            whenever error continue
            fetch c_cte05m00_03
            whenever error stop
            if sqlca.sqlcode <> 0 then
               message "Assunto não Cadastrado" attribute (reverse) sleep 2
               next field astnom
            end if
         end if
         display by name mr_cte05m00.astnom
      before field suanom
         if mr_cte05m00.astnom is null or
            mr_cte05m00.astnom = '' then
            next field suanom
         end if
      after field suanom
         let m_ind = cte05m00_popup('S')
         open c_cte05m00_01s using m_ind
         whenever error continue
         fetch c_cte05m00_01s into  mr_cte05m00.suanom
         whenever error stop
         if sqlca.sqlcode <> 0 then
            next field suanom
         end if
         open c_cte05m00_02s using mr_cte05m00.astnom
                                  ,mr_cte05m00.suanom
         whenever error continue
         fetch c_cte05m00_02s into  mr_cte05m00.viginidat
                                   ,mr_cte05m00.vigfimdat
                                   ,mr_cte05m00.rccflg
                                   ,mr_cte05m00.edstipcod
                                   ,mr_cte05m00.edstxtcod



         open c_cte05m00_06 using mr_cte05m00.edstipcod

         whenever error continue
         fetch c_cte05m00_06 into mr_cte05m00.txttpe
         whenever error stop
         if sqlca.sqlcode = 0 then

         end if

         display by name mr_cte05m00.astnom
                        ,mr_cte05m00.suanom
                        ,mr_cte05m00.viginidat
                        ,mr_cte05m00.vigfimdat
                        ,mr_cte05m00.rccflg
                        ,mr_cte05m00.edstipcod
                        ,mr_cte05m00.txttpe
                        ,mr_cte05m00.edstxtcod


   end input

   if int_flag then
      initialize mr_cte05m00 to null
      clear form
   end if

end function

#-------------------------------------#
function cte05m00_modifica()
#-------------------------------------#

   input by name mr_cte05m00.astnom thru
                 mr_cte05m00.edstxtcod without defaults
     after field suanom
     if mr_cte05m00.suanom is null or
        mr_cte05m00.suanom = '' then
        let m_ind = cte05m00_popup('S')
        if m_ind <> 0 then
           open c_cte05m00_09 using m_ind
           whenever error continue
           fetch c_cte05m00_09 into  mr_cte05m00.suanom
           whenever error continue
           if sqlca.sqlcode = 0 then
              display by name mr_cte05m00.suanom
           else
              error "Problema ao capturar subassunto"
           end if
        end if
     end if

     after field viginidat

        if mr_cte05m00.viginidat is null or
           mr_cte05m00.viginidat = '' then
           next field viginidat
        else
           if mr_cte05m00.viginidat < today then
              prompt "Vigencia inicial é anterior a data de hoje tem certeza ? " for char m_prompt

              if not m_prompt matches "[sS]" then
                 next field viginidat
              end if
           end if
        end if

     after field vigfimdat

        if mr_cte05m00.vigfimdat is null or
           mr_cte05m00.vigfimdat = '' then
           next field vigfimdat
        else
           if mr_cte05m00.vigfimdat < mr_cte05m00.viginidat then
              prompt "Vigencia final é anterior a data de inicio tem certeza ? " for char m_prompt

              if not m_prompt matches "[sS]" then
                 next field vigfimdat
              end if
           end if
        end if


     after field rccflg
        if mr_cte05m00.rccflg = 'S' then
           let mr_cte05m00.edstipcod  = null
           let mr_cte05m00.edstxtcod  = null
           let mr_cte05m00.txttpe     = null
           display by name mr_cte05m00.edstipcod
                          ,mr_cte05m00.edstxtcod
                          ,mr_cte05m00.txttpe
           exit input
        else
           if mr_cte05m00.rccflg is null or
              mr_cte05m00.rccflg = '' then
              next field rccflg
           end if
        end if


     after field edstipcod
        let m_acao = 'E'
        call cte05m00_endossos(mr_cte05m00.edstipcod
                               ,mr_cte05m00.edstxtcod)

        returning mr_cte05m00.edstipcod
                 ,mr_cte05m00.edstxtcod
                 ,mr_cte05m00.txttpe

        if mr_cte05m00.edstipcod is null then
           next field edstipcod
        end if

        display by name mr_cte05m00.edstipcod
                       ,mr_cte05m00.edstxtcod
                       ,mr_cte05m00.txttpe


        if not mr_cte05m00.edstipcod = 3 then
           exit input
        end if

     after field edstxtcod
         let m_acao = 'T'
         call cte05m00_endossos(mr_cte05m00.edstipcod
                                ,mr_cte05m00.edstxtcod)

         returning mr_cte05m00.edstipcod
                  ,mr_cte05m00.edstxtcod
                  ,mr_cte05m00.txttpe

         display by name mr_cte05m00.edstipcod
                        ,mr_cte05m00.edstxtcod
                        ,mr_cte05m00.txttpe


   end input

   if  mr_cte05m00.astnom    is not null and
       mr_cte05m00.viginidat is not null and
       mr_cte05m00.vigfimdat is not null and
       mr_cte05m00.rccflg    is not null then

       whenever error continue
       execute p_cte05m00_05 using mr_cte05m00.viginidat
                                  ,mr_cte05m00.vigfimdat
                                  ,mr_cte05m00.rccflg
                                  ,mr_cte05m00.edstipcod
                                  ,mr_cte05m00.edstxtcod
                                  ,mr_cte05m00.astnom
                                  ,mr_cte05m00.suanom

       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Problema ao atualizar assunto"
          initialize mr_cte05m00 to null
       else
          message "Cadastro Modificado com Sucesso"
       end if
   end if

end function

#-------------------------------------#
function cte05m00_inclui()
#-------------------------------------#


  initialize mr_cte05m00 to null
  clear form

  input by name mr_cte05m00.astnom thru
                mr_cte05m00.edstxtcod without defaults

     after field astnom

     if mr_cte05m00.astnom is null or
        mr_cte05m00.astnom = '' then

        let m_ind = cte05m00_popup('A')
        open c_cte05m00_01 using m_ind

        whenever error continue

        fetch c_cte05m00_01 into  mr_cte05m00.astnom
        display by name mr_cte05m00.astnom
     end if

     after field suanom

     if mr_cte05m00.suanom is not null or
        mr_cte05m00.suanom <> '' then

        open c_cte05m00_03s using mr_cte05m00.suanom
                                 ,mr_cte05m00.astnom

        whenever error continue
        fetch c_cte05m00_03s
        whenever error stop
        if sqlca.sqlcode = 0 then
           message "Subassunto já Cadastrado" sleep 1
           next field suanom
        else
           message ""
        end if
     else
        next field suanom
     end if

     after field viginidat

        if mr_cte05m00.viginidat is null or
           mr_cte05m00.viginidat = '' then
           next field viginidat
        else
           if mr_cte05m00.viginidat < today then
              prompt "Vigencia inicial é anterior a data de hoje tem certeza ? " for char m_prompt

              if not m_prompt matches "[sS]" then
                 next field viginidat
              end if
           end if
        end if

     after field vigfimdat

        if mr_cte05m00.vigfimdat is null or
           mr_cte05m00.vigfimdat = '' then
           next field vigfimdat
        else
           if mr_cte05m00.vigfimdat < mr_cte05m00.viginidat then
              prompt "Vigencia final é anterior a data de inicio tem certeza ? " for char m_prompt

              if not m_prompt matches "[sS]" then
                 next field vigfimdat
              end if
           end if
        end if

     after field rccflg
        if mr_cte05m00.rccflg = 'S' then
           let mr_cte05m00.edstipcod  = null
           let mr_cte05m00.edstxtcod  = null
           let mr_cte05m00.txttpe     = null
           display by name mr_cte05m00.edstipcod
                          ,mr_cte05m00.edstxtcod
                          ,mr_cte05m00.txttpe
           exit input
        else
           if mr_cte05m00.rccflg is null or
              mr_cte05m00.rccflg = '' then
              next field rccflg
           end if
        end if



     after field edstipcod
         let m_acao = 'E'
         call cte05m00_endossos( mr_cte05m00.edstipcod
                                ,mr_cte05m00.edstxtcod
                                )

         returning mr_cte05m00.edstipcod
                  ,mr_cte05m00.edstxtcod
                  ,mr_cte05m00.txttpe

         if mr_cte05m00.edstipcod is null then
            next field edstipcod
         end if

         display by name mr_cte05m00.edstipcod
                        ,mr_cte05m00.edstxtcod
                        ,mr_cte05m00.txttpe

        if not mr_cte05m00.edstipcod = 3 then
           exit input
        end if


     after field edstxtcod
         let m_acao = 'T'
         call cte05m00_endossos( mr_cte05m00.edstipcod
                                ,mr_cte05m00.edstxtcod
                                )

         returning mr_cte05m00.edstipcod
                  ,mr_cte05m00.edstxtcod
                  ,mr_cte05m00.txttpe

         display by name mr_cte05m00.edstipcod
                        ,mr_cte05m00.edstxtcod
                        ,mr_cte05m00.txttpe

  end input

  if  mr_cte05m00.astnom    is not null and
      mr_cte05m00.viginidat     is not null and
      mr_cte05m00.vigfimdat     is not null and
      mr_cte05m00.rccflg  is not null then

      whenever error continue
      execute p_cte05m00_04 using  mr_cte05m00.astnom
                                  ,mr_cte05m00.suanom
                                  ,mr_cte05m00.viginidat
                                  ,mr_cte05m00.vigfimdat
                                  ,mr_cte05m00.rccflg
                                  ,mr_cte05m00.edstipcod
                                  ,mr_cte05m00.edstxtcod

      whenever error stop
      if sqlca.sqlcode <> 0 then
         error "Problema ao inserir assunto"
         initialize mr_cte05m00 to null
      else
         message "Cadastro Realizado com Sucesso"
      end if
  end if

end function


#-------------------------------------#
function cte05m00_popup(l_tipo)
#-------------------------------------#
  define l_tipo       char(1)

  define la_cte05m00 array[500] of record
         intseqnum          smallint
        ,astnom      char(40)
  end record

  define l_ind        smallint
        ,l_teste      smallint


  let l_ind = 1
  case
     when l_tipo = 'A'  #ASSUNTOS

        foreach c_cte05m00_02 into la_cte05m00[l_ind].intseqnum
                                  ,la_cte05m00[l_ind].astnom
           let l_ind = l_ind + 1

        end foreach

     when l_tipo = 'S'  #SUBASSUNTOS

        let mr_cte05m00.astnom = upshift(mr_cte05m00.astnom)
        open c_cte05m00_08 using mr_cte05m00.astnom
        foreach c_cte05m00_08 into la_cte05m00[l_ind].intseqnum
                                  ,la_cte05m00[l_ind].astnom
           let l_ind = l_ind + 1

        end foreach


  end case

  let l_ind = l_ind - 1

  open window w_assunto at 3,34 with form "cte05m00a"
     attribute (border)
  if  l_tipo = 'S' then
     display 'SUBASSUNTOS DO CRM SIEBEL' at 3,1
     display 'SUBASSUNTO' at 5,6
  end if

  call set_count(l_ind)

  display array la_cte05m00 to sa_cte05m00a.*

     on key (f8)

     let l_ind = arr_curr()
     case
        when l_tipo = 'A'  #ASSUNTOS
           let mr_cte05m00.astnom = la_cte05m00[l_ind].astnom

        when l_tipo = 'S'  #SUBASSUNTOS
           let mr_cte05m00.suanom = la_cte05m00[l_ind].astnom

     end case

     let l_ind = la_cte05m00[l_ind].intseqnum
     exit display

     on key(interrupt)
     let l_ind = 0
     let int_flag = false
     exit display

  end display

  close window w_assunto

  return l_ind

end function

#-------------------------------------#
function cte05m00_endossos(lr_param)
#-------------------------------------#
   define lr_param    record
      edstip          like apbmitem.edstip
     ,edstxt          like apbmitem.edstxt

   end record

   define l_edstipdes like agdktip.edstipdes

   define l_clctip    smallint

   if m_acao = 'E' then

      if lr_param.edstip = 5  or
         lr_param.edstip = 6  or
         lr_param.edstip = 7  or
         lr_param.edstip = 11 or
         lr_param.edstip = 12 or
         lr_param.edstip = 13 or
         lr_param.edstip = 14 or
         lr_param.edstip = 16 or
         lr_param.edstip = 17 or
         lr_param.edstip = 18 or
         lr_param.edstip = 19 or
         lr_param.edstip = 20 or
         lr_param.edstip = 21 or
         lr_param.edstip = 22 or
         lr_param.edstip = 23 or
         lr_param.edstip = 27 or
         lr_param.edstip = 29 or
         lr_param.edstip = 30 or
         lr_param.edstip = 31 then

         error "Tipo de documento invalido para o orcamento"
         let lr_param.edstip = null
      end if

      if lr_param.edstip is null then
         call aggutipd_orc()
         returning lr_param.edstip
      end if

   else

      open c_cte05m00_07 using  lr_param.edstip
                                ,lr_param.edstxt
      whenever error continue
      fetch c_cte05m00_07
      whenever error stop
      if sqlca.sqlcode = notfound then
         error "Informe um tipo de texto valido para este endosso/calculo" sleep 3
         call aggutipt(lr_param.edstip)
         returning l_clctip
                  ,lr_param.edstxt
         if lr_param.edstxt is null then
            let lr_param.edstxt = 0
         end if
      end if
   end if

   open c_cte05m00_06 using lr_param.edstip

   whenever error continue
   fetch c_cte05m00_06 into l_edstipdes
   whenever error stop
   if sqlca.sqlcode = notfound then
      let lr_param.edstip = null
      error "Tipo de Endosso Inválido"
      call aggutipd_orc()
      returning lr_param.edstip
   end if
   if lr_param.edstip <> 3 then
      let  lr_param.edstxt = lr_param.edstip
   end if

   return lr_param.edstip
         ,lr_param.edstxt
         ,l_edstipdes

end function

#---------------------------------------#
function cte05m00_crm_assunto(l_assunto,l_subassunto)
#---------------------------------------#
   define l_assunto    char(30)
         ,l_subassunto char(30)
         ,l_sql        char(600)

   define lr_assuntos record
      edstipcod       char(3)
     ,txttpe          char(50)
     ,edstxtcod       char(3)
     ,rccflg          char(1)
   end record

   define l_codigo smallint
   define l_host like ibpkdbspace.srvnom #Saymon ambnovo
   let l_host = fun_dba_servidor("CT24HS")
   let l_assunto    = upshift(l_assunto)
   let l_subassunto = upshift(l_subassunto)
   initialize lr_assuntos.* to null

   let l_sql =" select edstipcod       "
             ,"       ,edstxtcod       "
             ,"       ,rccflg          "
             ,"  from porto@",l_host clipped,":datkatdsuaastint " #???
             ," where upper(astnom)  = ?      "
             ,"   and upper(suanom)  = ?      "
             ,"   and today between viginidat and vigfimdat "

   prepare p_oaoca000_01 from l_sql
   declare c_oaoca000_01 cursor for p_oaoca000_01

   let l_sql =  "select edstipdes  "
               ,"  from agdktip    "
               ," where edstip = ? "
   prepare p_oaoca000_02 from l_sql
   declare c_oaoca000_02 cursor with hold for p_oaoca000_02
   open c_oaoca000_01 using l_assunto
                           ,l_subassunto

   whenever error continue
   fetch c_oaoca000_01 into lr_assuntos.edstipcod
                           ,lr_assuntos.edstxtcod
                           ,lr_assuntos.rccflg
   whenever error stop

   if sqlca.sqlcode = 0 then
      let l_codigo = 0
   else
      let l_codigo = 100
   end if
   if  lr_assuntos.edstipcod is not null and upshift(lr_assuntos.rccflg) = 'N' then
      open c_oaoca000_02 using lr_assuntos.edstipcod

      whenever error continue
      fetch c_oaoca000_02 into lr_assuntos.txttpe
      whenever error stop
      if sqlca.sqlcode <> 0 then
         error "Problema ao capturar texto do tipo de endosso"
      end if
   end if

   return lr_assuntos.edstipcod
         ,lr_assuntos.txttpe
         ,lr_assuntos.edstxtcod
         ,lr_assuntos.rccflg
         ,l_codigo

end function