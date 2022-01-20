 ###########################################################################
 # Nome do Modulo: ctc42m01                                         Sergio #
 #                                                                  Burini #
 # Cadastro de SIMCards                                           Jun/2008 #
 ###########################################################################
 #                                                                         #
 #                  * * * Alteracoes * * *                                 #
 #                                                                         #
 # Data       Autor Fabrica  Origem    Alteracao                           #
 # ---------- -------------- --------- ----------------------------------- #
 # 29/04/2009 Sergio Burini            Retirada validação DDD x Operadora  #
 #-------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 database porto

 define ma_simcard array[100] of record
     recsinflgdes  char(10),
     celoprcoddes  char(10),
     cdssimintcod  like datkcdssim.cdssimintcod,
     dddcod        like datkcdssim.dddcod,
     celnum        like datkcdssim.celnum,
     sinutmdat     like datkcdssim.sinutmdat
 end record

 define ma_simcardaux array[100] of record
     recsinflg     like datkcdssim.recsinflg,
     celoprcod     like datkcdssim.celoprcod,
     celoprcoddes  char(10),
     cdssimintcod  like datkcdssim.cdssimintcod,
     dddcod        like datkcdssim.dddcod,
     celnum        like datkcdssim.celnum,
     sinutmdat     like datkcdssim.sinutmdat
 end record

 define  mr_ctc42m01a record
      recsinflg     like datkcdssim.recsinflg,
      recsinflgdes  char(30),
      celoprcod     like datkcdssim.celoprcod,
      celoprcoddes  char(10),
      cdssimintcod  like datkcdssim.cdssimintcod,
      dddcod        like datkcdssim.dddcod,
      celnum        like datkcdssim.celnum,
      funmat        like datkcdssim.funmat,
      atldat        like datkcdssim.atldat,
      sinutmdat     like datkcdssim.sinutmdat
 end record

 define  mr_ctc42m01ar record
      recsinflg     like datkcdssim.recsinflg,
      recsinflgdes  char(30),
      celoprcod     like datkcdssim.celoprcod,
      celoprcoddes  char(10),
      cdssimintcod  like datkcdssim.cdssimintcod,
      dddcod        like datkcdssim.dddcod,
      celnum        like datkcdssim.celnum,
      funmat        like datkcdssim.funmat,
      atldat        like datkcdssim.atldat,
      sinutmdat     like datkcdssim.sinutmdat
 end record

 define ws record
     erro smallint,
     aux  char(20)
 end record

 define m_mdtcod  like datkmdt.mdtcod,
        m_arr     smallint,
        m_prepare smallint

#---------------------------#
 function ctc42m01_prepare()
#---------------------------#

     define l_sql char(1000)

     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom = 'PSOCADSIMCARD' "

     prepare pctc42m0101  from l_sql
     declare cctc42m0101  cursor for pctc42m0101

     let l_sql = "select oprnom ",
                  " from pcckceltelopr ",
                 " where oprcod = ? "

     prepare pctc42m0102 from l_sql
     declare cctc42m0102 cursor for pctc42m0102

     let l_sql = "select dddnum ",
                  " from pccrceltelopr ",
                 " where oprcod = ? ",
                   " and dddnum = ? "

     prepare pctc42m0103 from l_sql
     declare cctc42m0103 cursor for pctc42m0103

     let l_sql = "insert into datkcdssim (recsinflg, ",
                                        " cdssimintcod, ",
                                        " celoprcod, ",
                                        " dddcod, ",
                                        " celnum, ",
                                        " funmat, ",
                                        " atldat, ",
                                        " sinutmdat) ",
                                " values (?,?,?,?,?,?,?,?)"

     prepare pctc42m0104 from l_sql

     let l_sql = "select cdssimide ",
                  " from datkcdssim ",
                 " where cdssimintcod = ? ",
                   " and celoprcod    = ? "

     prepare pctc42m0105 from l_sql
     declare cctc42m0105 cursor for pctc42m0105

     let l_sql = "insert into datksimmdt values(?,?)"

     prepare pctc42m0106 from l_sql

     let l_sql = "select recsinflg, ",
                       " cdssimintcod, ",
                       " celoprcod, ",
                       " dddcod, ",
                       " celnum, ",
                       " sinutmdat ",
                  " from datksimmdt mdt, ",
                       " datkcdssim sim ",
                 " where mdt.cdssimide = sim.cdssimide ",
                   " and mdtcod = ? "

     prepare pctc42m0107 from l_sql
     declare cctc42m0107 cursor for pctc42m0107

     let l_sql = "select mdt.cdssimide, ",
                       " funmat, ",
                       " atldat ",
                  " from datkcdssim sim, ",
                       " datksimmdt mdt ",
                 " where sim.cdssimide = mdt.cdssimide ",
                   " and cdssimintcod = ? ",
                   " and mdtcod       = ? "

     prepare pctc42m0108 from l_sql
     declare cctc42m0108 cursor for pctc42m0108

     let l_sql = "update datkcdssim ",
                   " set recsinflg    = ?, ",
                       " celoprcod    = ?, ",
                       " cdssimintcod = ?, ",
                       " dddcod       = ?, ",
                       " celnum       = ?, ",
                       " funmat       = ?, ",
                       " atldat       = ? ",
                 " where cdssimide = ? "

    prepare pctc42m0109 from l_sql

     let l_sql = "insert into datkcdssim (recsinflg, ",
                                        " celoprcod, ",
                                        " cdssimintcod, ",
                                        " dddcod, ",
                                        " celnum, ",
                                        " funmat, ",
                                        " atldat, ",
                                        " sinutmdat) ",
                               " values (?,?,?,?,?,?,?,?)"

    prepare pctc42m0110 from l_sql

     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom = ? ",
                   " and cpocod = ? "

     prepare pctc42m0111  from l_sql
     declare cctc42m0111  cursor for pctc42m0111

     let l_sql = "select mdtcod ",
                  " from datkcdssim sim, ",
                       " datksimmdt mdt ",
                 " where sim.cdssimide = mdt.cdssimide ",
                   " and cdssimintcod = ? ",
                   " and mdtcod      <> ? ",
                   " and recsinflg   in (3,2) "

     prepare pctc42m0113  from l_sql
     declare cctc42m0113  cursor for pctc42m0113

     let m_prepare = true

 end function

#---------------------------------------#
 function ctc42m01_verifica_usu(l_param)
#---------------------------------------#

     define l_funmat    like datmservico.funmat,
            l_param     like datmservico.funmat

     if  m_prepare is null or
         m_prepare <> true then
         call ctc42m01_prepare()
     end if

     open cctc42m0101
     foreach cctc42m0101 into l_funmat
         if  l_funmat = l_param then
             return true
         end if
     end foreach

     return false

 end function

#---------------------------#
 function ctc42m01(l_mdtcod)
#---------------------------#

     define l_mdtcod     like datkmdt.mdtcod,
            l_arr        smallint,
            l_scr        smallint,
            l_recsinflgr char(01),
            l_confirma   char(08),
            l_sql        char(500),
            l_cur        datetime year to second

     if  m_prepare is null or
         m_prepare <> true then
         call ctc42m01_prepare()
     end if

     let m_mdtcod = l_mdtcod

     # BUSCA OS DADOS DA TABELA
     open window ctc42m01 at 6,2 with form "ctc42m01"

     while true

         call ctc42m01_carrega_array()

         let int_flag = false

         display array ma_simcard to s_ctc42m01.*

               on key (F8)
                  let m_arr = arr_curr()
                  if  ma_simcard[m_arr].recsinflgdes is not null and
                      ma_simcard[m_arr].recsinflgdes <> " " then
                      call ctc42m01_entrada_dados("A")
                  else
                      error "Esse MDt nao possui nenhum SIMCard cadastrado."
                      sleep 1
                  end if
                  exit display

               on key (F1)
                  let m_arr = arr_curr()
                  call ctc42m01_entrada_dados("I")
                  exit display

               on key (f6)
                  exit display

               on key (f17, interrupt)
                  exit display

         end display

         if  int_flag then
             exit while
         end if

     end while

     close window ctc42m01

 end function

#---------------------------------#
 function ctc42m01_carrega_array()
#---------------------------------#

     define l_ind smallint,
            l_aux char(10)

     initialize ma_simcardaux to null

     let l_ind = 1

     open cctc42m0107 using m_mdtcod
     foreach cctc42m0107 into ma_simcardaux[l_ind].recsinflg,
                              ma_simcardaux[l_ind].cdssimintcod,
                              ma_simcardaux[l_ind].celoprcod,
                              ma_simcardaux[l_ind].dddcod,
                              ma_simcardaux[l_ind].celnum,
                              ma_simcardaux[l_ind].sinutmdat

         let l_aux = "RECSINFLG"
         open cctc42m0111 using l_aux,
                                ma_simcardaux[l_ind].recsinflg
         fetch cctc42m0111 into ma_simcard[l_ind].recsinflgdes

         open cctc42m0102 using ma_simcardaux[l_ind].celoprcod
         fetch cctc42m0102 into ma_simcardaux[l_ind].celoprcoddes

         let ma_simcardaux[l_ind].celoprcoddes = upshift(ma_simcardaux[l_ind].celoprcoddes)

         let ma_simcard[l_ind].cdssimintcod = ma_simcardaux[l_ind].cdssimintcod
         let ma_simcard[l_ind].celoprcoddes = ma_simcardaux[l_ind].celoprcoddes
         let ma_simcard[l_ind].dddcod       = ma_simcardaux[l_ind].dddcod
         let ma_simcard[l_ind].celnum       = ma_simcardaux[l_ind].celnum
         let ma_simcard[l_ind].sinutmdat    = ma_simcardaux[l_ind].sinutmdat

         open cctc42m0102 using ma_simcardaux[l_ind].celoprcod
         fetch cctc42m0102 into ma_simcardaux[l_ind].celoprcoddes

         let l_ind = l_ind + 1

     end foreach

     call set_count(l_ind-1)

 end function

#----------------------------------------#
 function ctc42m01_entrada_dados(l_opcao)
#----------------------------------------#

     define lr_retorno record
                           msg char(050),
                           err smallint
                       end record

     define l_opcao     char(001),
            l_cdssimide like datkcdssim.cdssimide,
            l_funmat    like datkcdssim.funmat,
            l_atldat    like datkcdssim.atldat,
            l_sql       char(500),
            l_aux       char(050),
            l_curr      datetime year to second

     initialize mr_ctc42m01a.*,
                mr_ctc42m01ar.* to null


     if  l_opcao = "A" then
         let mr_ctc42m01a.recsinflg     = ma_simcardaux[m_arr].recsinflg
         let mr_ctc42m01a.celoprcod     = ma_simcardaux[m_arr].celoprcod
         let mr_ctc42m01a.cdssimintcod  = ma_simcardaux[m_arr].cdssimintcod
         let mr_ctc42m01a.dddcod        = ma_simcardaux[m_arr].dddcod
         let mr_ctc42m01a.celnum        = ma_simcardaux[m_arr].celnum
         let mr_ctc42m01a.sinutmdat     = ma_simcardaux[m_arr].sinutmdat

         open cctc42m0108 using ma_simcardaux[m_arr].cdssimintcod,
                                m_mdtcod
         fetch cctc42m0108 into l_cdssimide,
                                l_funmat,
                                l_atldat

         let l_aux = "RECSINFLG"
         open cctc42m0111 using l_aux,
                                mr_ctc42m01a.recsinflg
         fetch cctc42m0111 into mr_ctc42m01a.recsinflgdes

         open cctc42m0102 using ma_simcardaux[m_arr].celoprcod
         fetch cctc42m0102 into mr_ctc42m01a.celoprcoddes

         let mr_ctc42m01a.celoprcoddes = upshift(mr_ctc42m01a.celoprcoddes)
         let mr_ctc42m01a.funmat        = l_funmat
         let mr_ctc42m01a.atldat        = l_atldat
     end if

     let mr_ctc42m01ar.* = mr_ctc42m01a.*

     open window ctc42m01a at 9,24 with form "ctc42m01a"
          attribute (form line 1, border, comment line last - 1)

     input by name mr_ctc42m01a.* without defaults

          before input
                let int_flag = false


          before field recsinflg
                display by name mr_ctc42m01a.recsinflg attribute(reverse)

                if  l_opcao = 'I' then
                    let mr_ctc42m01a.recsinflg = 2

                    let l_aux = "RECSINFLG"
                    open cctc42m0111 using l_aux,
                                           mr_ctc42m01a.recsinflg
                    fetch cctc42m0111 into mr_ctc42m01a.recsinflgdes


                    display by name mr_ctc42m01a.recsinflg
                    display by name mr_ctc42m01a.recsinflgdes

                    next field celoprcod
                end if

          after field recsinflg

                if  mr_ctc42m01a.recsinflg is null or mr_ctc42m01a.recsinflg = "" then

                    call cty09g00_popup_iddkdominio("RECSINFLG")
                         returning ws.erro,
                                   mr_ctc42m01a.recsinflg,
                                   mr_ctc42m01a.recsinflgdes

                    if  mr_ctc42m01a.recsinflg is null or mr_ctc42m01a.recsinflg = "" then
                        error 'O campo deve ser preenchido.'
                        next field recsinflg
                    end if
                else

                    call ctc42m01_consiste_sim() returning lr_retorno.msg,
                                                           lr_retorno.err

                    if  lr_retorno.err then
                        error lr_retorno.msg
                        let mr_ctc42m01a.recsinflg = ""
                        next field recsinflg
                    else
                        let l_aux = "RECSINFLG"

                        open cctc42m0111 using l_aux,
                                               mr_ctc42m01a.recsinflg
                        fetch cctc42m0111 into mr_ctc42m01a.recsinflgdes

                        if  mr_ctc42m01a.recsinflg is null or mr_ctc42m01a.recsinflg = "" then
                            error 'O campo deve ser preenchido.'
                            next field recsinflg
                        end if
                    end if

                end if

                display by name mr_ctc42m01a.recsinflg
                display by name mr_ctc42m01a.recsinflgdes

          before field celoprcod
               display by name mr_ctc42m01a.celoprcod attribute(reverse)

          after field celoprcod
               if  mr_ctc42m01a.celoprcod is null or mr_ctc42m01a.celoprcod = " " then

                   let l_sql = "select oprcod, ",
                                     " oprnom ",
                                " from pcckceltelopr "

                   call ofgrc001_popup(10
                                      ,12
                                      ,'Operadoras'
                                      ,'Codigo'
                                      ,'Operadora'
                                      ,'A'
                                      ,l_sql
                                      ,''
                                      ,'D')
                        returning ws.erro
                                 ,mr_ctc42m01a.celoprcod
                                 ,mr_ctc42m01a.celoprcoddes

                   if  mr_ctc42m01a.celoprcod is null or mr_ctc42m01a.celoprcod = "" then
                       error 'O campo deve ser preenchido'
                       next field celoprcod
                   end if
               else
                   open cctc42m0102 using mr_ctc42m01a.celoprcod
                   fetch cctc42m0102 into mr_ctc42m01a.celoprcoddes

                   if  sqlca.sqlcode <> 0 then
                       error 'Operadora nao cadastrada.'
                       let mr_ctc42m01a.celoprcod    = ""
                       let mr_ctc42m01a.celoprcoddes = ""
                       next field celoprcod
                   end if
               end if

               let mr_ctc42m01a.celoprcoddes = upshift(mr_ctc42m01a.celoprcoddes)

               display by name mr_ctc42m01a.celoprcod
               display by name mr_ctc42m01a.celoprcoddes

          before field cdssimintcod
               display by name mr_ctc42m01a.cdssimintcod attribute(reverse)

          after field cdssimintcod
               if  mr_ctc42m01a.cdssimintcod is null or mr_ctc42m01a.cdssimintcod = " " then
                   error "O campo SIMCard deve ser preenchido."
                   next field cdssimintcod
               end if

               display by name mr_ctc42m01a.cdssimintcod

          before field dddcod
               display by name mr_ctc42m01a.dddcod attribute(reverse)

          after field dddcod
               if  mr_ctc42m01a.dddcod is null or mr_ctc42m01a.dddcod = " " then
                   error "O campo DDD deve ser preenchido."
                   next field dddcod
               end if

               display by name mr_ctc42m01a.dddcod

          before field celnum
               display by name mr_ctc42m01a.celnum attribute(reverse)

          after field celnum

               if  mr_ctc42m01a.celnum is null or mr_ctc42m01a.celnum = " " then
                   error "O campo Telefone deve ser preenchido."
                   next field celnum
               end if

               display by name mr_ctc42m01a.celnum

          after input
              if  not int_flag then
                  if  mr_ctc42m01ar.recsinflg    <> mr_ctc42m01a.recsinflg or
                     (mr_ctc42m01ar.recsinflg    is null and mr_ctc42m01a.recsinflg    is not null) or
                      mr_ctc42m01ar.celoprcod    <> mr_ctc42m01a.celoprcod or
                     (mr_ctc42m01ar.celoprcod    is null and mr_ctc42m01a.celoprcod    is not null) or
                      mr_ctc42m01ar.cdssimintcod <> mr_ctc42m01a.cdssimintcod or
                     (mr_ctc42m01ar.cdssimintcod is null and mr_ctc42m01a.cdssimintcod is not null) or
                      mr_ctc42m01ar.dddcod       <> mr_ctc42m01a.dddcod or
                     (mr_ctc42m01ar.dddcod       is null and mr_ctc42m01a.dddcod       is not null) or
                      mr_ctc42m01ar.celnum       <> mr_ctc42m01a.celnum  or
                     (mr_ctc42m01ar.celnum       is null and mr_ctc42m01a.celnum       is not null) then
          
                      let l_curr = current
          
                      if  l_opcao = "A" then
          
                          execute pctc42m0109 using mr_ctc42m01a.recsinflg,
                                                    mr_ctc42m01a.celoprcod,
                                                    mr_ctc42m01a.cdssimintcod,
                                                    mr_ctc42m01a.dddcod,
                                                    mr_ctc42m01a.celnum,
                                                    g_issk.funmat,
                                                    l_curr,
                                                    l_cdssimide
                      else
                          execute pctc42m0110 using mr_ctc42m01a.recsinflg,
                                                    mr_ctc42m01a.celoprcod,
                                                    mr_ctc42m01a.cdssimintcod,
                                                    mr_ctc42m01a.dddcod,
                                                    mr_ctc42m01a.celnum,
                                                    g_issk.funmat,
                                                    l_curr,
                                                    l_curr
                          
                          let l_cdssimide  =  sqlca.sqlerrd[2]              
                                               
                          #open cctc42m0105 using mr_ctc42m01a.cdssimintcod,
                          #                       mr_ctc42m01a.celoprcod
                          #fetch cctc42m0105 into l_cdssimide
          
                          execute pctc42m0106 using l_cdssimide,
                                                    m_mdtcod
          
                      end if
          
                      if  sqlca.sqlcode <> 0 then
                          error "ERRO INCLUSAO "
                      end if
                  end if
              end if
     end input

     close window ctc42m01a

 end function

#--------------------------------#
 function ctc42m01_consiste_sim()
#--------------------------------#

     define l_aux    char(10),
            l_mdtcod like datksimmdt.mdtcod

     define lr_retorno record
         msg char(050),
         err smallint
     end record

     let lr_retorno.err = 0

     let l_aux = "RECSINFLG"
     open cctc42m0111 using l_aux,
                            mr_ctc42m01a.recsinflg
     fetch cctc42m0111 into mr_ctc42m01a.recsinflgdes

     if sqlca.sqlcode = notfound then
        let lr_retorno.msg = "Codigo invalido."
        let lr_retorno.err = 1
     else
         if  (mr_ctc42m01ar.recsinflg = 1 and mr_ctc42m01a.recsinflg = 2) or   # RECEBIDO / INFORMADO
             (mr_ctc42m01ar.recsinflg = 2 and mr_ctc42m01a.recsinflg = 1) or   # INFORMADO / RECEBIDO
             (mr_ctc42m01ar.recsinflg = 2 and mr_ctc42m01a.recsinflg = 3) or   # INFORMADO / REC.OK
             (mr_ctc42m01ar.recsinflg = 3 and mr_ctc42m01a.recsinflg = 2) or   # REC.Ok / INFORMADO
             (mr_ctc42m01ar.recsinflg = 3 and mr_ctc42m01a.recsinflg = 1) or   # REC.OK / RECEBIDO
             (mr_ctc42m01ar.recsinflg = 4 and mr_ctc42m01a.recsinflg = 1) or   # DESCONSIDERAR / RECEBIDO
             (mr_ctc42m01ar.recsinflg = 5 and mr_ctc42m01a.recsinflg = 1) then # SUBTITUIDO / RECEBIDO
             let lr_retorno.msg = 'OPERACAO NAO PERMITIDA'
             let lr_retorno.err = 1
         end if
     end if

     if (mr_ctc42m01a.recsinflg = 3 or mr_ctc42m01a.recsinflg = 2) then
         open cctc42m0113 using mr_ctc42m01a.cdssimintcod,
                                m_mdtcod
         fetch cctc42m0113 into l_mdtcod

         if  sqlca.sqlcode = 0 then
             let lr_retorno.msg = 'SIMCARD JÁ ANALISADO/INFORMADO NO MDT ', l_mdtcod using '<<<<&'
             let lr_retorno.err = 1
         end if
     end if
     
     return lr_retorno.* 

 end function

#----------------------------#
 function ctc42m01_consulta()
#----------------------------#

     define lr_ctc42m01 record
         vclsgl      like datkveiculo.atdvclsgl,
         simintcod   like datkcdssim.cdssimintcod
     end record

     define la_ctc42m01 array[2000] of record
         atdvclsgl    like datkveiculo.atdvclsgl,
         mdtcod       like datkmdt.mdtcod,
         cdssimintcod like datkcdssim.cdssimintcod,
         nomgrr       like dpaksocor.nomgrr,
         sinutmdat    like datkcdssim.sinutmdat
     end record

     define l_ind integer,
            l_sql char(1000)

     open window ctc42m01b at 6,2 with form "ctc42m01b"

     while true

          clear form
          initialize la_ctc42m01 to null

          input by name lr_ctc42m01.vclsgl,
                        lr_ctc42m01.simintcod

              before field vclsgl

                   display by name lr_ctc42m01.vclsgl attribute(reverse)

              after field vclsgl

                   display by name lr_ctc42m01.vclsgl

                   if  lr_ctc42m01.vclsgl is not null and
                       lr_ctc42m01.vclsgl <> " " then
                       exit input
                   end if

              before field simintcod

                   display by name lr_ctc42m01.simintcod attribute(reverse)

              after field simintcod

                   display by name lr_ctc42m01.simintcod

                   if  lr_ctc42m01.simintcod is not null and
                       lr_ctc42m01.simintcod <> " " then
                       exit input
                   end if

                   if  lr_ctc42m01.simintcod is null or
                       lr_ctc42m01.simintcod = " "   or
                       lr_ctc42m01.simintcod is null or
                       lr_ctc42m01.simintcod = " "   then
                       error "Informe algum parametro para que possa ser realizada a consulta"
                       next field vclsgl
                   end if

              on key (f17, interrupt)
                 exit while

          end input

          let l_sql = "select vcl.atdvclsgl, ",
                            " mdt.mdtcod, ",
                            " sim.cdssimintcod, ",
                            " pst.nomgrr, ",
                            " sim.sinutmdat ",
                      " from datkcdssim sim, ",
                           " datksimmdt mdt, ",
                           " datkveiculo vcl, ",
                           " dpaksocor pst ",
                     " where sim.cdssimide = mdt.cdssimide ",
                       " and mdt.mdtcod    = vcl.mdtcod ",
                       " and pst.pstcoddig = vcl.pstcoddig "

           if  lr_ctc42m01.vclsgl is not null and
               lr_ctc42m01.vclsgl <> " " then
               let l_sql = l_sql clipped, " and vcl.atdvclsgl = '", lr_ctc42m01.vclsgl clipped,"'"
           end if

           if  lr_ctc42m01.simintcod is not null and
               lr_ctc42m01.simintcod <> " " then
               let l_sql = l_sql clipped, " and cdssimintcod matches '*", lr_ctc42m01.simintcod clipped, "*'"
           end if

           prepare pctc42m0112  from l_sql
           declare cctc42m0112  cursor for pctc42m0112

           open cctc42m0112

           let l_ind = 1

           foreach cctc42m0112 into la_ctc42m01[l_ind].atdvclsgl,
                                    la_ctc42m01[l_ind].mdtcod,
                                    la_ctc42m01[l_ind].cdssimintcod,
                                    la_ctc42m01[l_ind].nomgrr,
                                    la_ctc42m01[l_ind].sinutmdat
               let l_ind = l_ind + 1
           end foreach

           if  l_ind > 1 then

               call set_count(l_ind)
               display array la_ctc42m01 to s_ctc42m01b.*

           else
               error "Nenhum SIMcard selecionado."
           end if

     end while

     close window ctc42m01b

 end function
 