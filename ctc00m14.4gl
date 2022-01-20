#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema        : PORTO SOCORRO                                              #
# Modulo         : ctc00m14                                                   #
#                  Função para manutenção do Cadatsro de Tarifas              #
#                  Porto Socorro (dparpstsrvprc)                              #
# Analista Resp. : Sergio Burini                                              #
# PSI            : 208264                                                     #
#.............................................................................#
#                                                                             #
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data        Autor Fabrica  Data   Alteracao                                 #
# ----------  -------------  ------ ------------------------------------------#
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define ma_psttrf array[100] of record
                        empcod       like dparpstsrvprc.empcod,
                        empsgl       like gabkemp.empsgl,
                        atdsrvorg    like dparpstsrvprc.atdsrvorg,
                        srvtipabvdes like datksrvtip.srvtipabvdes,
                        asitipcod    like dparpstsrvprc.asitipcod,
                        asitipabvdes like datkasitip.asitipabvdes,
                        soctrfcod    like dparpstsrvprc.soctrfcod,
                        soctrfdes    like dbsktarifasocorro.soctrfdes
                    end record

   define mr_psttrf record
                        empcod       like dparpstsrvprc.empcod,
                        empsgl       like gabkemp.empsgl,
                        atdsrvorg    like dparpstsrvprc.atdsrvorg,
                        srvtipabvdes like datksrvtip.srvtipabvdes,
                        asitipcod    like dparpstsrvprc.asitipcod,
                        asitipabvdes like datkasitip.asitipabvdes,
                        soctrfcod    like dparpstsrvprc.soctrfcod,
                        soctrfdes    like dbsktarifasocorro.soctrfdes
                    end record

 define ma_psttrf_ax array[100] of record
                        empcod       like dparpstsrvprc.empcod,
                        empsgl       like gabkemp.empsgl,
                        atdsrvorg    like dparpstsrvprc.atdsrvorg,
                        srvtipabvdes like datksrvtip.srvtipabvdes,
                        asitipcod    like dparpstsrvprc.asitipcod,
                        asitipabvdes like datkasitip.asitipabvdes,
                        soctrfcod    like dparpstsrvprc.soctrfcod,
                        soctrfdes    like dbsktarifasocorro.soctrfdes
                    end record
                    
 define teste char(1)
                    
#---------------------------#
 function ctc00m14_prepare()
#---------------------------#

     define l_sql char(500)

     let l_sql = "select empcod, ",
                       " atdsrvorg, ",
                       " asitipcod, ",
                       " soctrfcod ",
                  " from dparpstsrvprc ",
                 " where pstcoddig = ? ",
                 " order by empcod desc, atdsrvorg desc, ",
                          " asitipcod desc, soctrfcod desc "

     prepare prctc00m14_01 from l_sql
     declare cqctc00m14_01 cursor for prctc00m14_01

     let l_sql = "select empsgl ",
                  " from gabkemp ",
                 " where empcod = ? "

     prepare prctc00m14_02 from l_sql
     declare cqctc00m14_02 cursor for prctc00m14_02

     let l_sql = "select srvtipabvdes ",
                  " from datksrvtip ",
                 " where atdsrvorg = ? "

     prepare prctc00m14_03 from l_sql
     declare cqctc00m14_03 cursor for prctc00m14_03

     let l_sql = "select asitipabvdes ",
                  " from datkasitip ",
                 " where asitipcod = ? "

     prepare prctc00m14_04 from l_sql
     declare cqctc00m14_04 cursor for prctc00m14_04

     let l_sql = "select soctrfdes ",
                 " from dbsktarifasocorro ",
                " where soctrfcod = ? "

     prepare prctc00m14_05 from l_sql
     declare cqctc00m14_05 cursor for prctc00m14_05

     let l_sql = "select empcod ",
                  " from gabkemp ",
                 " where empcod = ? "

     prepare prctc00m14_06 from l_sql
     declare cqctc00m14_06 cursor for prctc00m14_06

     let l_sql = "delete from dparpstsrvprc ",
                  "where pstcoddig = ? "
     prepare prctc00m14_07 from l_sql

     let l_sql = "insert into dparpstsrvprc values (?, ?, ?, ?, ?)"
     prepare prctc00m14_08 from l_sql


 end function

#------------------------#
 function ctc00m14(param)
#------------------------#

     define l_ind      smallint,
            l_ind2       smallint,
            l_count      smallint,
            l_scr        smallint,  
            l_ctrl       smallint,
            l_msg        char(500),
            l_mensagem   char(100),
            l_erro       smallint,
            n,x          integer
            
      define param record                                                  
            pstcoddig    like dpaksocor.pstcoddig       
      end record                                         

     call ctc00m14_prepare()

     initialize ma_psttrf    to null
     initialize ma_psttrf_ax to null
     
     let l_ind = 0

     open window w_ctc00m14 at 08,02 with form "ctc00m14"

     #display '(F1)Inclui (F2)Exclui (F8)Salva' at 13,2

     open cqctc00m14_01 using param.pstcoddig

     fetch cqctc00m14_01 into mr_psttrf.empcod,
                              mr_psttrf.atdsrvorg,
                              mr_psttrf.asitipcod,
                              mr_psttrf.soctrfcod

     if  sqlca.sqlcode = 0 then
         foreach cqctc00m14_01 into mr_psttrf.empcod,
                                    mr_psttrf.atdsrvorg,
                                    mr_psttrf.asitipcod,
                                    mr_psttrf.soctrfcod

             let l_ind = l_ind + 1

             let ma_psttrf[l_ind].empcod       = mr_psttrf.empcod
             let ma_psttrf[l_ind].atdsrvorg    = mr_psttrf.atdsrvorg
             let ma_psttrf[l_ind].asitipcod    = mr_psttrf.asitipcod
             let ma_psttrf[l_ind].soctrfcod    = mr_psttrf.soctrfcod

             if  ma_psttrf[l_ind].empcod = 0 then
                 let  ma_psttrf[l_ind].empsgl = 'TODAS'
             else
                 open cqctc00m14_02 using ma_psttrf[l_ind].empcod
                 fetch cqctc00m14_02 into ma_psttrf[l_ind].empsgl

                 if  sqlca.sqlcode <> 0 then
                     let ma_psttrf[l_ind].empsgl = ' '
                 end if
             end if

             if  ma_psttrf[l_ind].atdsrvorg <> 0 then
                 open cqctc00m14_03 using ma_psttrf[l_ind].atdsrvorg
                 fetch cqctc00m14_03 into ma_psttrf[l_ind].srvtipabvdes

                 if  sqlca.sqlcode <> 0 then
                     let ma_psttrf[l_ind].srvtipabvdes = ' '
                 end if
             else
                 let  ma_psttrf[l_ind].srvtipabvdes = 'TODAS'
             end if

              if  ma_psttrf[l_ind].asitipcod <> 0 then
                  open cqctc00m14_04 using ma_psttrf[l_ind].asitipcod
                  fetch cqctc00m14_04 into ma_psttrf[l_ind].asitipabvdes

                  if  sqlca.sqlcode <> 0 then
                      let ma_psttrf[l_ind].asitipabvdes = ' '
                  end if
              else
                  let  ma_psttrf[l_ind].asitipabvdes = 'TODAS'
              end if

              open cqctc00m14_05 using ma_psttrf[l_ind].soctrfcod
              fetch cqctc00m14_05 into ma_psttrf[l_ind].soctrfdes

              if  sqlca.sqlcode <> 0 then
                  let ma_psttrf[l_ind].soctrfdes = ' '
              end if

         end foreach
     else
         if  sqlca.sqlcode <> notfound then
             display "PROBLEMA CQCTC00M14_01 ERRO = ", sqlca.sqlcode,
                     ", PSTCODDIG = ", param.pstcoddig
         end if
     end if

     call set_count(l_ind)

     for n = 1 to 100
        if ma_psttrf[n].empcod is not null then
           let ma_psttrf_ax[n].empcod        = ma_psttrf[n].empcod    
           let ma_psttrf_ax[n].empsgl        = ma_psttrf[n].empsgl 
           let ma_psttrf_ax[n].atdsrvorg     = ma_psttrf[n].atdsrvorg 
           let ma_psttrf_ax[n].srvtipabvdes  = ma_psttrf[n].srvtipabvdes 
           let ma_psttrf_ax[n].asitipcod     = ma_psttrf[n].asitipcod 
           let ma_psttrf_ax[n].asitipabvdes  = ma_psttrf[n].asitipabvdes
           let ma_psttrf_ax[n].soctrfcod     = ma_psttrf[n].soctrfcod           
           let ma_psttrf_ax[n].soctrfdes     = ma_psttrf[n].soctrfdes               
        end if     
     end for
     
     input array ma_psttrf without defaults from s_ctc00m14.*

         before row
              options delete key f2,
                      insert key f1

              let l_ind   = arr_curr()
              let l_count = arr_count()
              let l_scr   = scr_line()

              let mr_psttrf.empcod       = ma_psttrf[l_ind].empcod
              let mr_psttrf.atdsrvorg    = ma_psttrf[l_ind].atdsrvorg
              let mr_psttrf.asitipcod    = ma_psttrf[l_ind].asitipcod
              let mr_psttrf.soctrfcod    = ma_psttrf[l_ind].soctrfcod

         after field empcod

              if  ma_psttrf[l_ind].empcod is null or
                  ma_psttrf[l_ind].empcod = ' ' then
                  let ma_psttrf[l_ind].empcod = 0
              end if

              if  ma_psttrf[l_ind].empcod <> 0 then
                  open cqctc00m14_06 using ma_psttrf[l_ind].empcod
                  fetch cqctc00m14_06 into ma_psttrf[l_ind].empcod

                  if  sqlca.sqlcode <> 0 then
                      if  sqlca.sqlcode = notfound then
                          error "Empresa nao cadastrada."
                          next field empcod
                      else
                          error "PROBLEMA CQCTC00M14_06, ERRO = ", sqlca.sqlcode,
                                ", EMPCOD = ", ma_psttrf[l_ind].empcod
                      end if
                  end if
              end if

              if  ma_psttrf[l_ind].empcod = 0 then
                  let  ma_psttrf[l_ind].empsgl = 'TODAS'
              else
                  open cqctc00m14_02 using ma_psttrf[l_ind].empcod
                  fetch cqctc00m14_02 into ma_psttrf[l_ind].empsgl

                  if  sqlca.sqlcode <> 0 then
                      let ma_psttrf[l_ind].empsgl = ' '
                  end if
              end if

              display  ma_psttrf[l_ind].empcod to s_ctc00m14[l_scr].empcod
              display  ma_psttrf[l_ind].empsgl to s_ctc00m14[l_scr].empsgl

         after field atdsrvorg

              if  ma_psttrf[l_ind].atdsrvorg is null or
                  ma_psttrf[l_ind].atdsrvorg = ' ' then
                  let ma_psttrf[l_ind].atdsrvorg = 0
              end if

              if  ma_psttrf[l_ind].atdsrvorg <> 0 then
                  open cqctc00m14_03 using ma_psttrf[l_ind].atdsrvorg
                  fetch cqctc00m14_03 into ma_psttrf[l_ind].srvtipabvdes

                  if  sqlca.sqlcode <> 0 then
                      if  sqlca.sqlcode = notfound then
                          error "Origem nao cadastrada para essa empresa."
                          next field atdsrvorg
                      else
                          error "PROBLEMA CQCTC00M14_03, ERRO = ", sqlca.sqlcode,
                                ", EMPCOD = ", ma_psttrf[l_ind].empcod,
                                "ATDSRVORG = ", ma_psttrf[l_ind].atdsrvorg
                          next field atdsrvorg
                      end if
                  end if
              else
                  let  ma_psttrf[l_ind].srvtipabvdes = 'TODAS'
              end if

              display  ma_psttrf[l_ind].atdsrvorg    to s_ctc00m14[l_scr].atdsrvorg
              display  ma_psttrf[l_ind].srvtipabvdes to s_ctc00m14[l_scr].srvtipabvdes

         after field asitipcod

              if  ma_psttrf[l_ind].asitipcod is null or
                  ma_psttrf[l_ind].asitipcod = ' ' then
                  let ma_psttrf[l_ind].asitipcod = 0
              end if

              if  ma_psttrf[l_ind].asitipcod <> 0 then
                  open cqctc00m14_04 using ma_psttrf[l_ind].asitipcod
                  fetch cqctc00m14_04 into ma_psttrf[l_ind].asitipabvdes

                  if  sqlca.sqlcode <> 0 then
                      if  sqlca.sqlcode = notfound then
                          error "Assitencia nao cadastrada para essa empresa."
                          next field asitipcod
                      else
                          error "PROBLEMA CQCTC00M14_03, ERRO = ", sqlca.sqlcode,
                                ", EMPCOD = ", ma_psttrf[l_ind].empcod,
                                "ATDSRVORG = ", ma_psttrf[l_ind].asitipcod
                          next field asitipcod
                      end if
                  end if
              else
                  let  ma_psttrf[l_ind].asitipabvdes = 'TODAS'
              end if

              let l_count = arr_count()

              for l_ind2 = 1 to l_count
                  if  l_ind2 <> l_ind then
                      if  ma_psttrf[l_ind].empcod     = ma_psttrf[l_ind2].empcod    and
                          ma_psttrf[l_ind].atdsrvorg  = ma_psttrf[l_ind2].atdsrvorg and
                          ma_psttrf[l_ind].asitipcod  = ma_psttrf[l_ind2].asitipcod then
                          error 'Parametros já cadastrados na linha ', l_ind2

                          let ma_psttrf[l_ind].empcod       = " "
                          let ma_psttrf[l_ind].empsgl       = " "
                          let ma_psttrf[l_ind].atdsrvorg    = " "
                          let ma_psttrf[l_ind].srvtipabvdes = " "
                          let ma_psttrf[l_ind].asitipcod    = " "
                          let ma_psttrf[l_ind].asitipabvdes = " "
                          let ma_psttrf[l_ind].soctrfcod    = " "
                          let ma_psttrf[l_ind].soctrfdes    = " "

                          display  ma_psttrf[l_ind].empcod        to s_ctc00m14[l_scr].empcod
                          display  ma_psttrf[l_ind].empsgl        to s_ctc00m14[l_scr].empsgl
                          display  ma_psttrf[l_ind].atdsrvorg     to s_ctc00m14[l_scr].atdsrvorg
                          display  ma_psttrf[l_ind].srvtipabvdes  to s_ctc00m14[l_scr].srvtipabvdes
                          display  ma_psttrf[l_ind].asitipcod     to s_ctc00m14[l_scr].asitipcod
                          display  ma_psttrf[l_ind].asitipabvdes  to s_ctc00m14[l_scr].asitipabvdes
                          display  ma_psttrf[l_ind].soctrfcod     to s_ctc00m14[l_scr].soctrfcod
                          display  ma_psttrf[l_ind].soctrfdes     to s_ctc00m14[l_scr].soctrfdes

                          next field empcod
                      end if
                  end if
              end for

              display  ma_psttrf[l_ind].asitipcod    to s_ctc00m14[l_scr].asitipcod
              display  ma_psttrf[l_ind].asitipabvdes to s_ctc00m14[l_scr].asitipabvdes

         after field soctrfcod

              if  ma_psttrf[l_ind].soctrfcod is null or
                  ma_psttrf[l_ind].soctrfcod = ' '   or
                  ma_psttrf[l_ind].soctrfcod = 0 then
                  call ctb10m05()  returning ma_psttrf[l_ind].soctrfcod
              end if

              open cqctc00m14_05 using ma_psttrf[l_ind].soctrfcod
              fetch cqctc00m14_05 into ma_psttrf[l_ind].soctrfdes

              if  sqlca.sqlcode <> 0 then
                  if  sqlca.sqlcode = notfound then
                      error "Tarifa nao cadastrada."
                      let ma_psttrf[l_ind].soctrfdes = " "
                      next field soctrfcod
                  else
                      error "PROBLEMA CQCTC00M14_05, ERRO = ", sqlca.sqlcode,
                            ", SOCTRFCOD = ", ma_psttrf[l_ind].soctrfcod
                      let ma_psttrf[l_ind].soctrfdes = " "
                      next field soctrfcod
                  end if
              end if

              display  ma_psttrf[l_ind].soctrfdes to s_ctc00m14[l_scr].soctrfdes

              if  not int_flag then

              end if

         on key (f8)

              let l_count = arr_count()

              execute prctc00m14_07 using param.pstcoddig
              
              for n = 1 to 100
                  if  ma_psttrf_ax[n].soctrfcod is not null    and
                      ma_psttrf_ax[n].soctrfcod <> ' '         then
                      let l_ctrl = 0
                      for x = 1 to l_count
                          if  ma_psttrf[x].empcod is not null    and   
                              ma_psttrf[x].empcod <> ' '         and   
                              ma_psttrf[x].atdsrvorg is not null and   
                              ma_psttrf[x].atdsrvorg <> ' '      and   
                              ma_psttrf[x].asitipcod is not null and   
                              ma_psttrf[x].asitipcod <> ' '      and                                     
                              ma_psttrf[x].soctrfcod is not null and                                     
                              ma_psttrf[x].soctrfcod <> ' '      then                                    
                                                                           
                             if (ma_psttrf_ax[n].empcod    = ma_psttrf[x].empcod      and 
                                 ma_psttrf_ax[n].atdsrvorg = ma_psttrf[x].atdsrvorg   and
                                 ma_psttrf_ax[n].asitipcod = ma_psttrf[x].asitipcod   and
                                 ma_psttrf_ax[n].soctrfcod = ma_psttrf[x].soctrfcod)  then
                                let l_ctrl = 1
                                exit for 
                             end if   
                          end if   
                      end for
                      if l_ctrl = 0 then 
                         let l_msg =  "Tarifas : [",ma_psttrf_ax[n].soctrfcod clipped,
                                  " - ", ma_psttrf_ax[n].soctrfdes clipped,"] Excluida !"
                                                  
                         let l_mensagem = 'Exclusao no cadastro do socorrista. Codigo : ',
		                       param.pstcoddig
                         call ctc00m02_grava_hist(param.pstcoddig,l_msg clipped,"E")    
                      end if 
                  end if
             end for 
      
              for l_ind2 = 1 to l_count

                  if  ma_psttrf[l_ind2].empcod is not null    and
                      ma_psttrf[l_ind2].empcod <> ' '         and
                      ma_psttrf[l_ind2].atdsrvorg is not null and
                      ma_psttrf[l_ind2].atdsrvorg <> ' '      and
                      ma_psttrf[l_ind2].asitipcod is not null and
                      ma_psttrf[l_ind2].asitipcod <> ' '      and
                      ma_psttrf[l_ind2].soctrfcod is not null and
                      ma_psttrf[l_ind2].soctrfcod <> ' '      then

                      if  sqlca.sqlcode <> 0 then
                          error "PROBLEMA prctc00m14_07, ERRO = ",sqlca.sqlcode,
                                "PSTCODDIG = ", param.pstcoddig
                          exit input
                      end if

                      execute prctc00m14_08 using param.pstcoddig,
                                                  ma_psttrf[l_ind2].empcod,
                                                  ma_psttrf[l_ind2].atdsrvorg,
                                                  ma_psttrf[l_ind2].asitipcod,
                                                  ma_psttrf[l_ind2].soctrfcod

                      if  sqlca.sqlcode <> 0 then
                          error "PROBLEMA prctc00m14_08, ERRO = ",sqlca.sqlcode,
                                "PSTCODDIG = ", param.pstcoddig
                          exit input
                      end if
                     
                      let l_ctrl = 0 
                      for x = 1 to 100
                        if (ma_psttrf_ax[x].empcod    = ma_psttrf[l_ind2].empcod     and 
                            ma_psttrf_ax[x].atdsrvorg = ma_psttrf[l_ind2].atdsrvorg  and
                            ma_psttrf_ax[x].asitipcod = ma_psttrf[l_ind2].asitipcod  and
                            ma_psttrf_ax[x].soctrfcod = ma_psttrf[l_ind2].soctrfcod)  then
                           let l_ctrl = 1
                           exit for
                        end if   
                      end for
                      if l_ctrl = 0 then
                         let l_msg =  "Tarifas : [",ma_psttrf[l_ind2].soctrfcod clipped,
                                       " - ", ma_psttrf[l_ind2].soctrfdes clipped,"] Incluida !"
                                                  
                         let l_mensagem = 'Inclusao no cadastro do socorrista. Codigo : ',
	  	                       param.pstcoddig
                         call ctc00m02_grava_hist(param.pstcoddig,l_msg clipped,"I")    
                      end if                                    
                  end if
              end for

              exit input

     end input

     close window w_ctc00m14

 end function