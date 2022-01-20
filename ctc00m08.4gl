###############################################################################
# Nome do Modulo: CTC00M08                                           Marcelo  #
#                                                                    Gilberto #
# Consulta ordens de pagamento pagas para o prestador                Jan/1998 #
#-----------------------------------------------------------------------------#
# 28/11/2006 Priscila       PSI 205206  Receber empresa como parametro e      #
#                                       permitir input de ciaempcod           #
#-----------------------------------------------------------------------------#
###############################################################################

database porto

#-----------------------------------------------------------
 function ctc00m08(param)
#-----------------------------------------------------------

 define param       record
    pstcoddig       like dpaksocor.pstcoddig
 end record

 define d_ctc00m08  record
    socpgtincdat    date,
    socpgtfnldat    date,
    ciaempcod       like datmservico.ciaempcod,   #PSI 205206
    empsgl          like gabkemp.empsgl,          #PSI 205206
    socopggrlqtd    dec(6,0),
    socpgtgrlqtd    like dbsmopg.socfatitmqtd,
    socpgtgrlvlr    like dbsmopg.socfattotvlr
 end record

 define a_ctc00m08 array[200] of record
    socfatpgtdat    like dbsmopg.socfatpgtdat,
    socopgnum       like dbsmopg.socopgnum,
    socfatitmqtd    like dbsmopg.socfatitmqtd,
    socfatpgtvlr    like dbsmopg.socfattotvlr
 end record

 define arr_aux     smallint
 define scr_aux     smallint
 
 define l_ret       smallint,    #PSI 205206
        l_mensagem  char(50),
        l_ciaempcod like datmservico.ciaempcod,
        l_sql       char(300)      


 initialize d_ctc00m08.*    to null
 initialize a_ctc00m08 to null
 let l_ret = null
 let l_mensagem = null


 open window ctc00m08 at 06,02 with form "ctc00m08"
             attribute (form line first)

 while true

   let int_flag = false
   initialize a_ctc00m08  to null
   let d_ctc00m08.socopggrlqtd = 00
   let d_ctc00m08.socpgtgrlqtd = 00
   let d_ctc00m08.socpgtgrlvlr = 0.00
   let arr_aux  = 1

   input by name d_ctc00m08.socpgtincdat,
                 d_ctc00m08.socpgtfnldat,
                 d_ctc00m08.ciaempcod     without defaults   #PSI 205206

      before field socpgtincdat
             display by name d_ctc00m08.socpgtincdat    attribute (reverse)

      after  field socpgtincdat
             display by name d_ctc00m08.socpgtincdat

             if d_ctc00m08.socpgtincdat   is null   then
                error " Data de pagamento inicial deve ser informada!"
                next field socpgtincdat
             end if

             if d_ctc00m08.socpgtincdat  >  today   then
                error " Data de pagamento inicial nao deve ser maior que data atual!"
                next field socpgtincdat
             end if

             if d_ctc00m08.socpgtincdat  <  "01/06/1997"  then
                error " Consulta disponivel a partir de 01/06/1997!"
                next field socpgtincdat
             end if

      before field socpgtfnldat
             display by name d_ctc00m08.socpgtfnldat      attribute (reverse)

      after  field socpgtfnldat
             display by name d_ctc00m08.socpgtfnldat

             if d_ctc00m08.socpgtfnldat   is null   then
                error " Data de pagamento final deve ser informada!"
                next field socpgtfnldat
             end if

             if d_ctc00m08.socpgtfnldat  >  today   then
                error " Data de pagamento final nao deve ser maior que data atual!"
                next field socpgtfnldat
             end if

             if d_ctc00m08.socpgtfnldat  <  d_ctc00m08.socpgtincdat   then
                error " Data de pagamento final nao deve ser menor que data pagamento inicial!"
                next field socpgtfnldat
             end if
     
      #PSI 205206 - incluir empresa no filtro de busca de OP´s do prestador
      before field ciaempcod
             display by name d_ctc00m08.ciaempcod      attribute (reverse)

      after  field ciaempcod
             display by name d_ctc00m08.ciaempcod
             if d_ctc00m08.ciaempcod is not null then
                call cty14g00_empresa(1, d_ctc00m08.ciaempcod)
                     returning l_ret,
                               l_mensagem,
                               d_ctc00m08.empsgl
                if l_ret <> 1 then
                   error l_mensagem
                   let d_ctc00m08.ciaempcod = null
                   next field ciaempcod
                end if    
             else
                let d_ctc00m08.empsgl = "TODAS"   
             end if
             display by name d_ctc00m08.empsgl               

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   #---------------------------------------------
   # Le todas as op's emitidas para o prestador
   #---------------------------------------------
   message " Aguarde, pesquisando..."  attribute(reverse)

   let l_sql = "select datmservico.ciaempcod "
              ," from dbsmopgitm, datmservico "
              ," where dbsmopgitm.socopgnum = ? "
              ,"   and dbsmopgitm.atdsrvnum = datmservico.atdsrvnum "
              ,"   and dbsmopgitm.atdsrvano = datmservico.atdsrvano "
   prepare pctc00m08001 from l_sql
   declare cctc00m08001 cursor for pctc00m08001          

   declare  c_ctc00m08  cursor for
      select socfatpgtdat,
             socopgnum,
             socfatitmqtd,
             socfattotvlr
        from dbsmopg
       where dbsmopg.socfatpgtdat
             between  d_ctc00m08.socpgtincdat and d_ctc00m08.socpgtfnldat
         and dbsmopg.pstcoddig     =  param.pstcoddig
         and dbsmopg.socopgsitcod  =  7

   foreach  c_ctc00m08  into  a_ctc00m08[arr_aux].socfatpgtdat,
                              a_ctc00m08[arr_aux].socopgnum,
                              a_ctc00m08[arr_aux].socfatitmqtd,
                              a_ctc00m08[arr_aux].socfatpgtvlr

      #PSI 205206
      #validar se OP encontrada para o prestador é da mesma empresa 
      # informada
      if d_ctc00m08.ciaempcod is not null then
         #buscar a empresa de um dos itens da OP
         open cctc00m08001 using a_ctc00m08[arr_aux].socopgnum
         #leio apenas a primeira linha, pois todos os itens da OP devem 
         # pertencer a mesma empresa
         fetch cctc00m08001 into l_ciaempcod
         if sqlca.sqlcode <> 0 then
            error "Problemas ao buscar itens da OP ", 
                   a_ctc00m08[arr_aux].socopgnum, "AVISE A INFORMATICA!"
         else
            #se empresa da OP é diferente da empresa solicitada
            # despreza OP
            if l_ciaempcod <> d_ctc00m08.ciaempcod then
               close cctc00m08001
               continue foreach
            end if       
         end if
         close cctc00m08001
      end if

      let d_ctc00m08.socopggrlqtd = d_ctc00m08.socopggrlqtd + 1

      let d_ctc00m08.socpgtgrlqtd =
          d_ctc00m08.socpgtgrlqtd + a_ctc00m08[arr_aux].socfatitmqtd

      let d_ctc00m08.socpgtgrlvlr =
          d_ctc00m08.socpgtgrlvlr + a_ctc00m08[arr_aux].socfatpgtvlr

      let arr_aux = arr_aux + 1
      if arr_aux > 200 then
         error " Limite excedido. Pesquisa com mais de 200 O.Ps.!"
         exit foreach
      end if
   end foreach

   if arr_aux  > 1   then
      message " (F17)Abandona"

      display by name d_ctc00m08.socopggrlqtd
      display by name d_ctc00m08.socpgtgrlqtd
      display by name d_ctc00m08.socpgtgrlvlr

      call set_count(arr_aux-1)

      display array  a_ctc00m08 to s_ctc00m08.*

         on key(interrupt)
            exit display

      end display

      initialize d_ctc00m08.socopggrlqtd  to null
      initialize d_ctc00m08.socpgtgrlqtd  to null
      initialize d_ctc00m08.socpgtgrlvlr  to null

      display by name d_ctc00m08.socopggrlqtd
      display by name d_ctc00m08.socpgtgrlqtd
      display by name d_ctc00m08.socpgtgrlvlr

      for scr_aux=1 to 9
          clear s_ctc00m08[scr_aux].*
      end for
   else
      error " Nao existem O.Ps. para pesquisa!"
   end if

end while

let int_flag = false
close window ctc00m08

end function   ##  ctc00m08
