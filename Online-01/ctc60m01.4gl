#-----------------------------------------------------------------------------#
#              *** Porto  Seguro  Cia.  de  Seguros  Gerais ***               #
#.............................................................................#
#                                                                             #
# Sistema.: Ct24hs   - Central 24hs e Pronto Socorro                          #
# Modulo..: ctc60m01 - Manutencao prestadores                                 #
# Analista: Wagner Agostinho                                                  #
# PSI.....:                  OSF: 10570                                       #
#                                                                             #
# Desenvolvimento: Fabrica de Software  -  Talita Menezes - DEZ/02            #
#-----------------------------------------------------------------------------#

#globals "/homedsa/projetos/ramos/producao/glre.4gl" RGLOBALS By Robi
#globals  "glre.4gl"

#globals  "/homedsa/projetos/geral/globals/glre.4gl"

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------------#
function ctc60m01()
#-----------------------------------------------------------------------------#

   define l_ctc60m01       record
          pstcoddig        like dpaksocor.pstcoddig
         ,nomrazsoc        like dpaksocor.nomrazsoc
         ,nomgrr           like dpaksocor.nomgrr
         ,dddcod           like dpaksocor.dddcod
         ,teltxt           like dpaksocor.teltxt
         ,faxnum           like dpaksocor.faxnum
         ,intsrvrcbflg     like dpaksocor.intsrvrcbflg
         ,intdescr         char(08)
   end record

   define l_posicao        smallint
         ,l_cmd            char(150)
         ,ant_pstcoddig    like dpaksocor.pstcoddig


	let	l_posicao  =  null
	let	l_cmd  =  null
	let	ant_pstcoddig  =  null

	initialize  l_ctc60m01.*  to  null

   initialize l_ctc60m01.* to null

   open window ctc60m01 at 4,2 with form "ctc60m01"
     attribute (form line 1, message  line last)

   let int_flag    = false

   clear form

   let l_cmd = " select pstcoddig "
                    ," ,nomrazsoc "
                    ," ,nomgrr "
                    ," ,dddcod "
                    ," ,teltxt "
                    ," ,faxnum "
                    ," ,intsrvrcbflg "
                ," from dpaksocor "
               ," where pstcoddig >= ? "
   prepare pctc60m01001 from l_cmd
   declare cctc60m01001 scroll cursor for pctc60m01001
   
    let l_cmd = " insert into dbsmhstprs (pstcoddig, dbsseqcod, prshstdes,"
               ,"                         caddat   , cademp   , cadusrtip, cadmat)"
               ," values(?,?,?, ?,?,?, ?) "
    prepare pctc60m01002 from l_cmd
   

   menu "PRESTADOR"

      command key ("S") "Seleciona"   "Consulta Prestadores"
              call seleciona_ctc60m01()
                 returning l_ctc60m01.*

      command key ("P") "Proximo"     "Consulta o Proximo Prestador"
              if l_ctc60m01.pstcoddig is null or
                 l_ctc60m01.pstcoddig =  0    then
                 error "Nenhum Prestador selecionado !"
                 next option "Seleciona"
              else
                 call scroll_ctc60m01(l_ctc60m01.pstcoddig,+1)
                    returning l_ctc60m01.*
                             ,int_flag

                 if int_flag then
                    let int_flag = false
                    error "Voce ja esta no ultimo Prestador"
                    next option "Anterior"
                 else
                    display by name l_ctc60m01.*
                 end if
              end if

      command key ("A") "Anterior"    "Consulta o Prestador Anterior"
              if l_ctc60m01.pstcoddig is null or
                 l_ctc60m01.pstcoddig =  0    then
                 error "Nenhum Prestador selecionado !"
                 next option "Seleciona"
              else
                 call scroll_ctc60m01(l_ctc60m01.pstcoddig,-1)
                    returning l_ctc60m01.*
                             ,int_flag

                 if int_flag then
                    let int_flag = false
                    error "Voce ja esta no primeiro Prestador"
                    if l_ctc60m01.pstcoddig is null then
                       let l_ctc60m01.pstcoddig = ant_pstcoddig
                    end if
                    next option "Proximo"
                 else
                    display by name l_ctc60m01.*
                 end if

                 let ant_pstcoddig = l_ctc60m01.pstcoddig

              end if


      command key ("M") "Manutencao"  "Manutencao de Prestadores"
              if l_ctc60m01.pstcoddig is null or
                 l_ctc60m01.pstcoddig =  0    then
                 error "Nenhum Prestador selecionado !"
                 next option "Seleciona"
              else
                 call manutenir_ctc60m01(l_ctc60m01.*)
              end if

      command key (interrupt, "E") "Encerra" "Retorna ao menu anterior "
                   message " "
                   exit menu
   end menu

   close window ctc60m01

   return

end function

#-----------------------------------------------------------------------------#
function seleciona_ctc60m01()
#-----------------------------------------------------------------------------#

   define l_ctc60m01       record
          pstcoddig        like dpaksocor.pstcoddig
         ,nomrazsoc        like dpaksocor.nomrazsoc
         ,nomgrr           like dpaksocor.nomgrr
         ,dddcod           like dpaksocor.dddcod
         ,teltxt           like dpaksocor.teltxt
         ,faxnum           like dpaksocor.faxnum
         ,intsrvrcbflg     like dpaksocor.intsrvrcbflg
         ,intdescr         char(08)
   end record



	initialize  l_ctc60m01.*  to  null

   initialize l_ctc60m01.* to null
   clear form

   call ctc60m01_input("S",l_ctc60m01.*)
      returning l_ctc60m01.*

   if int_flag then
      error " Operacao Cancelada! "
      let int_flag = false
      return l_ctc60m01.*
   end if

   open cctc60m01001 using l_ctc60m01.pstcoddig

   return l_ctc60m01.*

end function

#-----------------------------------------------------------------------------#
function ctc60m01_input(aux_manut,l_ctc60m01)
#-----------------------------------------------------------------------------#

   define l_ctc60m01       record
          pstcoddig        like dpaksocor.pstcoddig
         ,nomrazsoc        like dpaksocor.nomrazsoc
         ,nomgrr           like dpaksocor.nomgrr
         ,dddcod           like dpaksocor.dddcod
         ,teltxt           like dpaksocor.teltxt
         ,faxnum           like dpaksocor.faxnum
         ,intsrvrcbflg     like dpaksocor.intsrvrcbflg
         ,intdescr         char(08)
   end record

   define aux_manut        char(01)



   input by name l_ctc60m01.pstcoddig
                ,l_ctc60m01.dddcod
                ,l_ctc60m01.teltxt
                ,l_ctc60m01.faxnum
                ,l_ctc60m01.intsrvrcbflg without defaults

      before field pstcoddig
         if aux_manut = "M" then
            next field dddcod
         end if
         display by name l_ctc60m01.pstcoddig attribute(reverse)

      after field pstcoddig
         display by name l_ctc60m01.pstcoddig

         if l_ctc60m01.pstcoddig is null or
            l_ctc60m01.pstcoddig =  0    then
            error " Informe o Codigo do Prestador! "
            next field pstcoddig
         end if

         #---[ Valida Codigo do Prestador ]---#
         ######################################
         declare cctc60m01002 cursor with hold for
            select pstcoddig
                  ,nomrazsoc
                  ,nomgrr
                  ,dddcod
                  ,teltxt
                  ,faxnum
                  ,intsrvrcbflg
              from dpaksocor
             where pstcoddig = l_ctc60m01.pstcoddig

         open cctc60m01002
         fetch cctc60m01002 into l_ctc60m01.pstcoddig
                                ,l_ctc60m01.nomrazsoc
                                ,l_ctc60m01.nomgrr
                                ,l_ctc60m01.dddcod
                                ,l_ctc60m01.teltxt
                                ,l_ctc60m01.faxnum
                                ,l_ctc60m01.intsrvrcbflg

         if sqlca.sqlcode <> 0 then
            error " Prestador nao cadastrado! "
            initialize l_ctc60m01.* to null
            clear form
            next field pstcoddig
         end if

         if l_ctc60m01.intsrvrcbflg = 1 then
            let l_ctc60m01.intdescr = "Internet"
         end if

         display by name l_ctc60m01.*

         if aux_manut = "S" then
            exit input
         end if

      before field dddcod
         display by name l_ctc60m01.dddcod attribute(reverse)

      after field dddcod
         display by name l_ctc60m01.dddcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field pstcoddig
         end if

         if (l_ctc60m01.teltxt is not null and l_ctc60m01.teltxt <> 0) and
            (l_ctc60m01.dddcod is null      or l_ctc60m01.dddcod =  0) then
            error " Informe o DDD do telefone! "
            next field dddcod
         end if

      before field teltxt
         display by name l_ctc60m01.teltxt attribute(reverse)

      after field teltxt
         display by name l_ctc60m01.teltxt

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field dddcod
         end if

         if (l_ctc60m01.dddcod is not null and l_ctc60m01.dddcod <> 0) and
            (l_ctc60m01.teltxt is null      or l_ctc60m01.teltxt =  0) then
            error " Informe o Numero do Telefone! "
            next field teltxt
         end if

      before field faxnum
         display by name l_ctc60m01.faxnum attribute(reverse)

      after field faxnum
         display by name l_ctc60m01.faxnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field teltxt
         end if

      before field intsrvrcbflg
         display by name l_ctc60m01.intsrvrcbflg attribute(reverse)

      after field intsrvrcbflg
         display by name l_ctc60m01.intsrvrcbflg

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field faxnum
         end if

         if l_ctc60m01.intsrvrcbflg is not null and
            l_ctc60m01.intsrvrcbflg <> 0        and
            l_ctc60m01.intsrvrcbflg <> 1        then
            error " Informe 0 ou 1 para o Acionamento! "
            next field intsrvrcbflg
         end if

         if l_ctc60m01.intsrvrcbflg = 1 then
            let l_ctc60m01.intdescr = "Internet"
            display by name l_ctc60m01.intdescr
         end if

      on key (interrupt, control-c)
         let int_flag = false
         exit input

   end input

   return l_ctc60m01.*

end function

#-----------------------------------------------------------------------------#
function scroll_ctc60m01(l_pstcoddig,i)
#-----------------------------------------------------------------------------#

   define l_pstcoddig      like dpaksocor.pstcoddig
   define i                smallint

   define l_ctc60m01       record
          pstcoddig        like dpaksocor.pstcoddig
         ,nomrazsoc        like dpaksocor.nomrazsoc
         ,nomgrr           like dpaksocor.nomgrr
         ,dddcod           like dpaksocor.dddcod
         ,teltxt           like dpaksocor.teltxt
         ,faxnum           like dpaksocor.faxnum
         ,intsrvrcbflg     like dpaksocor.intsrvrcbflg
         ,intdescr         char(08)
   end record



	initialize  l_ctc60m01.*  to  null

   fetch relative i cctc60m01001 into l_ctc60m01.pstcoddig
                                     ,l_ctc60m01.nomrazsoc
                                     ,l_ctc60m01.nomgrr
                                     ,l_ctc60m01.dddcod
                                     ,l_ctc60m01.teltxt
                                     ,l_ctc60m01.faxnum
                                     ,l_ctc60m01.intsrvrcbflg

   if sqlca.sqlcode <> 0 then
      return l_ctc60m01.*
            ,true
   else
      return l_ctc60m01.*
            ,false
   end if

end function

#-----------------------------------------------------------------------------#
function manutenir_ctc60m01(l_ctc60m01)
#-----------------------------------------------------------------------------#

   define l_ctc60m01       record
          pstcoddig        like dpaksocor.pstcoddig
         ,nomrazsoc        like dpaksocor.nomrazsoc
         ,nomgrr           like dpaksocor.nomgrr
         ,dddcod           like dpaksocor.dddcod
         ,teltxt           like dpaksocor.teltxt
         ,faxnum           like dpaksocor.faxnum
         ,intsrvrcbflg     like dpaksocor.intsrvrcbflg
         ,intdescr         char(08)
   end record
   
   define l_ctc60m01_ant   record
          pstcoddig        like dpaksocor.pstcoddig
         ,nomrazsoc        like dpaksocor.nomrazsoc
         ,nomgrr           like dpaksocor.nomgrr
         ,dddcod           like dpaksocor.dddcod
         ,teltxt           like dpaksocor.teltxt
         ,faxnum           like dpaksocor.faxnum
         ,intsrvrcbflg     like dpaksocor.intsrvrcbflg
         ,intdescr         char(08)
   end record
   
   define l_prshstdes  char(2000),
          l_length     smallint  
   
   let l_ctc60m01_ant.pstcoddig    = l_ctc60m01.pstcoddig     
   let l_ctc60m01_ant.nomrazsoc    = l_ctc60m01.nomrazsoc   
   let l_ctc60m01_ant.nomgrr       = l_ctc60m01.nomgrr      
   let l_ctc60m01_ant.dddcod       = l_ctc60m01.dddcod      
   let l_ctc60m01_ant.teltxt       = l_ctc60m01.teltxt      
   let l_ctc60m01_ant.faxnum       = l_ctc60m01.faxnum      
   let l_ctc60m01_ant.intsrvrcbflg = l_ctc60m01.intsrvrcbflg
   let l_ctc60m01_ant.intdescr     = l_ctc60m01.intdescr    
   
   call ctc60m01_input("M",l_ctc60m01.*)
      returning l_ctc60m01.*

   if int_flag then
      error " Operacao Cancelada! "
      let int_flag = false
      return
   end if

   if l_ctc60m01.pstcoddig is not null and
      l_ctc60m01.pstcoddig <> 0        then
      update dpaksocor set (dddcod
                           ,teltxt
                           ,faxnum
                           ,intsrvrcbflg
                           ,funmat
                           ,atldat)
                         = (l_ctc60m01.dddcod
                           ,l_ctc60m01.teltxt
                           ,l_ctc60m01.faxnum
                           ,l_ctc60m01.intsrvrcbflg
                           ,g_issk.funmat
                           ,today)
       where pstcoddig = l_ctc60m01.pstcoddig

      if sqlca.sqlcode <> 0 then
         error " Erro na alteracao do Prestador! "
         return
      end if
   end if
   
   let l_prshstdes = null
   
   if (l_ctc60m01.dddcod is     null and l_ctc60m01_ant.dddcod is not null) or
      (l_ctc60m01.dddcod is not null and l_ctc60m01_ant.dddcod is null)     or
      (l_ctc60m01.dddcod <> l_ctc60m01_ant.dddcod)                          then
       let l_prshstdes = l_prshstdes clipped,
          " DDD alterado de [",
          l_ctc60m01_ant.dddcod clipped,"] para [",
          l_ctc60m01.dddcod     clipped,"],"
   end if
   
    if (l_ctc60m01.teltxt is     null and l_ctc60m01_ant.teltxt is not null) or
       (l_ctc60m01.teltxt is not null and l_ctc60m01_ant.teltxt is null)     or
       (l_ctc60m01.teltxt <> l_ctc60m01_ant.teltxt)                          then
        let l_prshstdes = l_prshstdes clipped,
           " Telefone alterado de [",
           l_ctc60m01_ant.teltxt clipped,"] para [",
           l_ctc60m01.teltxt     clipped,"],"
   end if
   
    if (l_ctc60m01.intsrvrcbflg is     null and l_ctc60m01_ant.intsrvrcbflg is not null) or
       (l_ctc60m01.intsrvrcbflg is not null and l_ctc60m01_ant.intsrvrcbflg is null)     or
       (l_ctc60m01.intsrvrcbflg <> l_ctc60m01_ant.intsrvrcbflg)                          then
        let l_prshstdes = l_prshstdes clipped,
           " Acionamento alterado de [",
           l_ctc60m01_ant.intsrvrcbflg clipped, "] para [",
           l_ctc60m01.intsrvrcbflg     clipped, "],"
   end if
   
   let l_length = length(l_prshstdes clipped)
   if  l_prshstdes is not null and l_length > 0 then
       if  l_prshstdes[1] = " " then
           let l_prshstdes = l_prshstdes[2,l_length]
           let l_length = length(l_prshstdes clipped)
       end if
   
       if  l_prshstdes[l_length] = "," then
           let l_prshstdes = l_prshstdes[1,l_length - 1], "."
       end if
   
       call ctc60m01_grava_hist(l_ctc60m01.pstcoddig,l_prshstdes)
   end if
  
   error " Alteracao efetuada com sucesso! "
   return

end function

#-------------------------------------#
function ctc60m01_grava_hist(lr_param)
#-------------------------------------#
  define lr_param record
         pstcoddig   like dpaksocor.pstcoddig,
         prshstdes   char(2000)
  end record
  
  define lr_ret record
         texto1  char(70)
        ,texto2  char(70)
        ,texto3  char(70)
        ,texto4  char(70)
        ,texto5  char(70)
        ,texto6  char(70)
        ,texto7  char(70)
        ,texto8  char(70)
        ,texto9  char(70)
        ,texto10 char(70)
  end record

  define l_stt       smallint
        ,l_path      char(100)
        ,l_cmd2      char(4000)
        ,l_texto2    char(3000)

  define l_dbsseqcod  like dbsmhstprs.dbsseqcod,
         l_prshstdes2 like dbsmhstprs.prshstdes,
         l_texto      like dbsmhstprs.prshstdes,
         l_cmtnom     like isskfunc.funnom,
         l_data       date,
         l_hora       datetime hour to minute,
         l_count,
         l_iter,
         l_length,
         l_length2    smallint,
         l_msg        char(50),
         l_erro       smallint,
         l_cmd        char(100),
         l_corpo_email char(1000),
         teste         char(1)

  let l_msg = null

 #Buscar ultimo item de historico cadastrado para o prestador
  let l_dbsseqcod = 0
  select max(dbsseqcod) into l_dbsseqcod
    from dbsmhstprs
   where pstcoddig = lr_param.pstcoddig
  
  if l_dbsseqcod is null or l_dbsseqcod = 0 then
     let l_dbsseqcod = 1
  else
     let l_dbsseqcod = l_dbsseqcod + 1
  end if

  #Busca data e hora do banco
  call cts40g03_data_hora_banco(2) returning l_data, l_hora
  
  let l_length = length(lr_param.prshstdes clipped)
  if  l_length mod 70 = 0 then
      let l_iter = l_length / 70
  else
      let l_iter = l_length / 70 + 1
  end if

  let l_corpo_email = null
  let l_length2     = 0
  let l_erro        = 0

  for l_count = 1 to l_iter
      if  l_count = l_iter then
          let l_prshstdes2 = lr_param.prshstdes[l_length2 + 1, l_length]
      else
          let l_length2 = l_length2 + 70
          let l_prshstdes2 = lr_param.prshstdes[l_length2 - 69, l_length2]
      end if

      #Grava historico para o prestador
      execute pctc60m01002 using lr_param.pstcoddig,
                                 l_dbsseqcod,
                                 l_prshstdes2,
                                 l_data,
                                 g_issk.empcod,
                                 g_issk.usrtip,
                                 g_issk.funmat

      if sqlca.sqlcode <> 0  then
          error "Erro (", sqlca.sqlcode, ") na inclusao do historico (dbsmhstprs). "
          let l_erro = sqlca.sqlcode
      end if

      if l_erro <> 0 then
         exit for
      end if

      let l_dbsseqcod  = l_dbsseqcod + 1

  end for

  if l_erro = 0 then
     #Envia Email para o prestador

     let l_msg = 'Alteracao no Cadastro do Prestador: Codigo  ', lr_param.pstcoddig

     initialize l_cmtnom   to null

     select funnom  into  l_cmtnom
     from isskfunc
     where funmat = g_issk.funmat
      and empcod  = g_issk.empcod

     call ctb85g01_mtcorpo_email_html("CTC00M02", # Utiliza os mesmos parametros do Pso_ct24h
                                      l_data,
                                      l_hora,
                                      g_issk.empcod,
                                      g_issk.usrtip,
                                      g_issk.funmat,
                                      l_msg,
                                      lr_param.prshstdes clipped)
                            returning l_erro

     if l_erro <> 0 then
        error "Erro Envio do Email ", l_erro
     end if
  end if

end function


#-----------------------------------------------------------------------------#