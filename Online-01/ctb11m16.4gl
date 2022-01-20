###############################################################################
# Nome do Modulo: CTB11m16                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Inclui nr NF nos itens da OP de acordo com os tipos de servico     Jan/2000 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 30/05/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
#-----------------------------------------------------------------------------#
# 26/08/2003  PSI 172332   Ale Souza    Critica automatica  por numero de     #
#             OSF 24740                 Nota Fiscal.                          #
###############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl" 
 
 database porto

#--------------------------------------------------------------
 function ctb11m16(param)
#--------------------------------------------------------------

 define param        record
    socopgnum        like dbsmopgitm.socopgnum
 end record

 define a_ctb11m16   array[20] of record
    atdsrvorg        like datmservico.atdsrvorg,
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    nfsnum           like dbsmopgitm.nfsnum
 end record

 define ws           record
    flgok            char (01)
   ,confirma         char (01)
   ,rowid            integer
   ,soctip           like dbsmopg.soctip
   ,pestip           like dbsmopg.pestip
   ,cgccpfnum        like dbsmopg.cgccpfnum
   ,cgcord           like dbsmopg.cgcord
   ,cgccpfdig        like dbsmopg.cgccpfdig
   ,socpgtdoctip     like dbsmopg.socpgtdoctip
 end record

 define arr_aux      integer
 define scr_aux      integer
 define l_erro       smallint
 define x            smallint
       ,l_ret       char(01)
       ,l_nfsnum    like dbsmopgitm.nfsnum
       
 define lr_retorno record
                       retorno   smallint,      
                       mensagem  char(60)         
                   end record        
       
 initialize a_ctb11m16  to null
 initialize ws.*        to null
 let arr_aux   = 1
#let  g_privez = true
 let  l_ret    = null
 let  l_nfsnum = null

 open window ctb11m16 at 13,34 with form "ctb11m16"
             attribute (form line 1, border, comment line last - 1)

 #---> Dados da OP <---#
 whenever error continue 
 select soctip
       ,pestip
       ,cgccpfnum
       ,cgcord
       ,cgccpfdig
       ,socpgtdoctip
   into ws.soctip 
       ,ws.pestip
       ,ws.cgccpfnum
       ,ws.cgcord
       ,ws.cgccpfdig
       ,ws.socpgtdoctip
   from dbsmopg
  where socopgnum = param.socopgnum
 whenever error stop  

 if sqlca.sqlcode <> 0    then
    error " Erro (",sqlca.sqlcode,") na leitura da ordem de pagamento!"
    let int_flag = false
    close window ctb11m16
    let ws.flgok = "1"
    return ws.flgok
 end if

 declare c_ctb11m16 cursor for
  select datmservico.atdsrvorg,
         datksrvtip.srvtipabvdes
    from dbsmopgitm, datmservico, datksrvtip
   where dbsmopgitm.socopgnum  = param.socopgnum
     and dbsmopgitm.nfsnum     is null
     and datmservico.atdsrvnum = dbsmopgitm.atdsrvnum
     and datmservico.atdsrvano = dbsmopgitm.atdsrvano
     and datksrvtip.atdsrvorg  = datmservico.atdsrvorg
   group by datmservico.atdsrvorg, datksrvtip.srvtipabvdes

 foreach c_ctb11m16 into a_ctb11m16[arr_aux].atdsrvorg,
                         a_ctb11m16[arr_aux].srvtipabvdes

    let arr_aux = arr_aux + 1
    if arr_aux > 20 then
       error " Limite excedido, existem mais de 20 tipos de servico"
       exit foreach
    end if

 end foreach

 if arr_aux = 1 then 
    let ws.flgok   = "0"
    return ws.flgok
 end if

 call set_count(arr_aux-1)
 options comment line last - 1

 message "(F17)Abandona"

 while true

    let ws.flgok   = "0"
    let int_flag   = false

    input array a_ctb11m16 without defaults from s_ctb11m16.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux >  arr_count()  then
             exit input
          end if

       before field nfsnum
          display a_ctb11m16[arr_aux].nfsnum to
                  s_ctb11m16[scr_aux].nfsnum attribute (reverse)

       after  field nfsnum
          display a_ctb11m16[arr_aux].nfsnum to
                  s_ctb11m16[scr_aux].nfsnum

          if a_ctb11m16[arr_aux].nfsnum is null then
             error " Numero da NF tem que ser informado!"
             next field nfsnum
          end if

          if a_ctb11m16[arr_aux].nfsnum = 0     then
             error " Numero da NF nao pode ser 0(zero)!"
             next field nfsnum
          end if


          if a_ctb11m16[arr_aux].nfsnum is not null and
             a_ctb11m16[arr_aux].nfsnum    <>  0    then

             let l_ret    = null
             let l_nfsnum = a_ctb11m16[arr_aux].nfsnum

             if param.socopgnum is null then 
                let param.socopgnum = 0 
             end if 

             call ctb00g01_vernfs(ws.soctip
                                 ,ws.pestip
                                 ,ws.cgccpfnum
                                 ,ws.cgcord
                                 ,ws.cgccpfdig
                                 ,param.socopgnum
                                 ,ws.socpgtdoctip
                                 ,l_nfsnum)
                returning l_ret

             if l_ret = "S" then
                error " Documento duplicado! "
                next field nfsnum
             end if
          end if

       on key (interrupt)
          let ws.flgok = "1"
          exit input

    end input

    if ws.flgok = "1" then
       exit while
    else
       for x = 1 to 20
          if a_ctb11m16[x].atdsrvorg is null then
             call cts08g01("C","S","","DADOS ESTAO CORRETOS ?", "","")
                  returning ws.confirma

             if ws.confirma = "S"  then
                message " Aguarde ...  atualizando itens!"
                begin work
                  for arr_aux = 1 to 20
                     if a_ctb11m16[arr_aux].atdsrvorg is null then
                        exit for
                     end if
                     declare c_updbsitm cursor for
                      select dbsmopgitm.rowid
                        from dbsmopgitm, datmservico
                       where dbsmopgitm.socopgnum  = param.socopgnum
                         and dbsmopgitm.nfsnum     is null
                         and datmservico.atdsrvnum = dbsmopgitm.atdsrvnum
                         and datmservico.atdsrvano = dbsmopgitm.atdsrvano
                         and datmservico.atdsrvorg = a_ctb11m16[arr_aux].atdsrvorg

                     let l_erro = false
                     
                     foreach c_updbsitm into ws.rowid

                        update dbsmopgitm set nfsnum
                                           =  a_ctb11m16[arr_aux].nfsnum
                           where dbsmopgitm.rowid = ws.rowid

                        if sqlca.sqlcode <> 0 then
                           error " Erro (", sqlca.sqlcode, ") na gravacao do nr.NF nos itens da OP. AVISE A INFORMATICA!"
                           rollback work
                           exit while
                           let l_erro = true
                        end if
                        
                        if not l_erro then
                           call cts50g00_atualiza_etapa(param.socopgnum, 3, g_issk.funmat)
                                returning lr_retorno.retorno,
                                          lr_retorno.mensagem
                           
                        end if

                     end foreach
                  end for
                commit work
                message ""
                exit while
             else
                exit for
             end if
          end if
          if a_ctb11m16[x].nfsnum is null or
             a_ctb11m16[x].nfsnum = 0     then
             error " Falta o preenchimento do nro.da NF para o tipo ",
                   a_ctb11m16[x].srvtipabvdes
          end if
       end for
    end if

 end while

 close window ctb11m16

 let int_flag = false

 return ws.flgok

end function  #  ctb11m16
