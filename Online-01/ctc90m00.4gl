#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: BDBSR130                                                   #
# ANALISTA RESP..: SERGIO BURINI                                              #
# PSI/OSF........: DESBLOQUEIO DE VIATURAS COM PENDENCIAS NA VISTORIA         #
# ........................................................................... #
# DESENVOLVIMENTO: SERGIO BURINI                                              #
# LIBERACAO......: 23/04/2010                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
#  DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                            #
# --------   --------------  ---------- ------------------------------------- #
# 02/03/2011  Ueslei Santos		Mudanca da descricao motivo de        #
#					bloqueio para N - SEM VISTORIA        #	
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

 define ma_vst array[5000] of record
     aux    char(01),
     socvclcod like datkveiculo.socvclcod,
     atdvclsgl like datkveiculo.atdvclsgl,
     nomgrr char(100),
     vstnum char(20),
     vstdat date,
     dbqmtvtip char(01),
     evtseq smallint,
     qtdfot smallint
 end record

 define mr_aux record
     dbqobs  char(200)
 end record

 define m_arr_curr smallint,
        m_scr_curr smallint

#---------------------------#
 function ctc90m00_prepare()
#---------------------------#

     define l_sql char(5000)

     let l_sql = "select socvclcod, ",
                       " evtseq, ",
                       " vstnum, ",
                       " vstdat, ",
                       " dbqmtvtip ",
                  " from datmvstsemvcl ",
                 " where evttip = 1 ",
                 " order by socvclcod "

     prepare pctc90m00_01 from l_sql
     declare cctc90m00_01 cursor for pctc90m00_01

     let l_sql = "select count(*) ",
                  " from avlmfoto ",
                 " where vstnumdig = ? "

     prepare pctc90m00_02 from l_sql
     declare cctc90m00_02 cursor for pctc90m00_02

     let l_sql = "select pst.nomgrr, ",
                       " vcl.atdvclsgl ",
                  " from datkveiculo vcl, ",
                       " dpaksocor   pst ",
                 " where vcl.socvclcod = ? ",
                   " and vcl.pstcoddig = pst.pstcoddig "

     prepare pctc90m00_03 from l_sql
     declare cctc90m00_03 cursor for pctc90m00_03

     let l_sql = "select count(*) ",
                   "from avlmavar ",
                  "where vstnumdig = ? "

     prepare pctc90m00_04 from l_sql
     declare cctc90m00_04 cursor for pctc90m00_04

     let l_sql = "update datmvstsemvcl ",
                   " set evttip = 2, ",
                       " dbqobs = ? ",
                 " where socvclcod = ? ",
                   " and evtseq = ? "

     prepare pctc90m00_05 from l_sql

     let l_sql = "update datkveiculo ",
                   " set socoprsitcod = 1 ", #Desbloqueia viatura.
                 " where socvclcod = ? "

     prepare pctc90m00_06 from l_sql

     let l_sql = "delete from datkvclsit ",
                 " where datkvclsit.socvclcod = ? "

     prepare pctc90m00_07 from l_sql


 end function

#-------------------#
 function ctc90m00()
#-------------------#

     define l_ind      smallint,
            l_vst      smallint,
            l_count    smallint,
            l_rodape   char(50),
            l_rodape2   char(100)

     initialize ma_vst to null

     call ctc90m00_prepare()

     open window w_ctc90m00 at 6,2 with form 'ctc90m00'
       attribute(form line 1, border)

     while true

         let l_ind = 1
         clear form
         initialize ma_vst to null

         error 'Buscando viaturas.'

         open cctc90m00_01
         fetch cctc90m00_01 into ma_vst[l_ind].socvclcod,
                                 ma_vst[l_ind].evtseq,
                                 ma_vst[l_ind].vstnum,
                                 ma_vst[l_ind].vstdat,
                                 ma_vst[l_ind].dbqmtvtip

         if  sqlca.sqlcode = 0 then

             foreach cctc90m00_01 into ma_vst[l_ind].socvclcod,
                                       ma_vst[l_ind].evtseq,
                                       ma_vst[l_ind].vstnum,
                                       ma_vst[l_ind].vstdat,
                                       ma_vst[l_ind].dbqmtvtip

                 if  ma_vst[l_ind].vstnum = 0 then
                     let ma_vst[l_ind].vstnum =  "NAO ENCONTRADO"
                     let ma_vst[l_ind].vstdat = ""
                 else
                     open cctc90m00_02 using ma_vst[l_ind].vstnum
                     fetch cctc90m00_02 into ma_vst[l_ind].qtdfot
                 end if

                 open cctc90m00_03 using ma_vst[l_ind].socvclcod
                 fetch cctc90m00_03 into ma_vst[l_ind].nomgrr,
                                         ma_vst[l_ind].atdvclsgl

                 let l_ind = l_ind + 1

             end foreach

             call set_count(l_ind - 1)
             error ""
 
             input array ma_vst without defaults from s_vistorias.*

                 before row
                     let m_arr_curr = arr_curr()
                     let m_scr_curr = scr_line()

                     if  ma_vst[m_arr_curr].vstnum <> "NAO ENCONTRADO" then
                         let l_vst = true
                     else
                         let l_vst = false
                     end if

                     let l_rodape = "F8 - Desbloquear"
                     let l_rodape2 = "N - Sem vistoria / E - Excedido / F - Fora da norma / D - Devolvida"

                     if  l_vst then
                         let l_rodape = l_rodape clipped, "    F6 - Status"

                         open cctc90m00_04 using ma_vst[m_arr_curr].vstnum
                         fetch cctc90m00_04 into l_count

                         if  l_count > 0 then
                             let l_rodape = l_rodape clipped ,"    F7 - Avarias"
                         end if
                     end if

                     display l_rodape to rodape
                     display l_rodape2 to rodape2 attribute (reverse)

                     let ma_vst[m_arr_curr].aux = ">"
                     display ma_vst[m_arr_curr].* to
                             s_vistorias[m_scr_curr].* attribute (reverse)

                 after row
                     let m_arr_curr = arr_curr()
                     let m_scr_curr = scr_line()
                     let ma_vst[m_arr_curr].aux = ""
                     display ma_vst[m_arr_curr].* to
                             s_vistorias[m_scr_curr].*

                 on key (f7)
                     if  l_vst <> "NAO ENCONTRADO" then
                         call avltc030(ma_vst[m_arr_curr].vstnum)
                     end if

                 on key (f6)
                     if  l_vst then
                         call avltc040(ma_vst[m_arr_curr].vstnum)
                     end if

                 on key (f8)
                     call ctx00m00_texto_padrao("","")
                          returning mr_aux.dbqobs

                     if  mr_aux.dbqobs is not null and
                         mr_aux.dbqobs <> " " then
                         if  ctc90m00_atualiza() then
                             exit input
                         end if
                     end if

             end input

             if  int_flag then
                 exit while
             end if
         else
             error "Nao existem veiculos pendenctes na Vistoria."
             sleep 2
         end if

     end while

     close window w_ctc90m00

 end function

#----------------------------#
 function ctc90m00_atualiza()
#----------------------------#

     define lr_retorno record
         cod_erro  integer,
         msg_erro  char(250)
     end record

     define l_titulo   char(050),
            l_mensagem char(500)

     execute pctc90m00_05 using mr_aux.dbqobs,
                                ma_vst[m_arr_curr].socvclcod,
                                ma_vst[m_arr_curr].evtseq

     if  sqlca.sqlcode <> 0 then
         error 'Problema na atualização da tabela (1): ', sqlca.sqlcode
         return false
     end if

     execute pctc90m00_07 using ma_vst[m_arr_curr].socvclcod

     if  sqlca.sqlcode <> 0 then
         error 'Problema na atualização da tabela (2): ', sqlca.sqlcode
         return false
     end if

     execute pctc90m00_06 using ma_vst[m_arr_curr].socvclcod

     if  sqlca.sqlcode <> 0 then
         error 'Problema na atualização da tabela (3): ', sqlca.sqlcode
         return false
     end if

     let l_titulo = 'DESBLOQUEIO DE VEICULO ', ma_vst[m_arr_curr].socvclcod using '<<<<&',
                    ' NAO CONFORMIDADE COM A VISTORIA'

     let l_mensagem = 'O veiculo ', ma_vst[m_arr_curr].socvclcod using '<<<<&', 
                      ' foi desbloqueado. Motivo: ', mr_aux.dbqobs clipped      
     
     
     call ctc34m02_grava_hist(ma_vst[m_arr_curr].socvclcod
                             ,l_titulo
                             ,today
                             ,l_mensagem)
                    returning lr_retorno.cod_erro

     return true

 end function
