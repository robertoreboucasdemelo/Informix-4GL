############################################################################
# Nome do Modulo: CTN07C01                                           Pedro #
#                                                                          #
# Consulta Postos de Vistoria por CEP                             Out/1994 #
############################################################################

database porto

define i smallint
define gm_seqpesquisa smallint

define  b_ctn07c01 record
        srvcod     like   avckservico.srvcod,
        srvdes     like   avckservico.srvdes
end     record

#---------------------------------------------------------------
 function ctn07c01( k_ctn07c01 )
#---------------------------------------------------------------

   define k_ctn07c01 record
          endcep     like   glaklgd.lgdcep
   end    record



   open window w_ctn07c01 at 4,2 with form "ctn07c01"

   let  gm_seqpesquisa = 0

   menu "POSTOS DE VISTORIA"

   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"

           if k_ctn07c01.endcep is null     then
              error " Nenhum Cep Selecionado"
              next option "Encerra"
           else
              call pesquisa_ctn07c01(k_ctn07c01.*)
              let  gm_seqpesquisa = 0
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa Proxima  Regiao do Cep "
           if k_ctn07c01.endcep is null     then
              error " Nenhum Cep Selecionado"
              next option "Seleciona"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn07c01(k_ctn07c01.*)
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctn07c01

end function  # ctn07c01

#-------------------------------------------------------------------
 function pesquisa_ctn07c01(k_ctn07c01 )
#-------------------------------------------------------------------

   define k_ctn07c01 record
          endcep     like   glaklgd.lgdcep
   end record

   define a_ctn07c01 array[100] of record
      pstsgl         like   avckposto.pstsgl    ,
      vstpstcod      like   avckposto.vstpstcod ,
      endlgd         like   avckposto.endlgd    ,
      endbrr         like   avckposto.endbrr    ,
      endcid         like   avckposto.endcid    ,
      endufd         like   avckposto.endufd    ,
      dddcod         like   avckposto.dddcod    ,
      teltxt         like   avckposto.teltxt    ,
      horsegsex      char(65)                   ,
      horsabdom      char(65)                   ,
      c24obs1        char(64)                   ,
      c24obs2        char(64)                   ,
      aviso1         char(76)                   ,
      aviso2         char(76)
   end record

   define ws         record
          atddiatip  like avckhoratend.atddiatip    ,
          horario    char(65)                       ,
          cidnom     like avcrregposto.cidnom       ,
          c24libconflg like avckservico.c24libconflg,
          c24obs     like avckposto.c24obs          ,
          vstinptip  like avckposto.vstinptip       ,
          vstrgicod  like avckposto.vstrgicod       ,
          tipo       char(03)                       ,
          aviso      char(152)
   end    record


	define	w_pf1	integer


	for	w_pf1  =  1  to  100
		initialize  a_ctn07c01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   clear form

   input  by  name b_ctn07c01.srvcod

      before field srvcod
         display by name b_ctn07c01.srvcod attribute (reverse)

      after  field srvcod
         display by name b_ctn07c01.srvcod

         if b_ctn07c01.srvcod  is null   or
            b_ctn07c01.srvcod  = "  "    then
            error " Tipo de Vistoria e' obrigatorio!"
            call ctn07c02("VP") returning b_ctn07c01.srvcod
            next field srvcod
         else
            if b_ctn07c01.srvcod[1,2] <> "VP"   and
               b_ctn07c01.srvcod[1,2] <> "GM"   then
               error " Servico informado nao e' Vistoria!"
               next field srvcod
            end if
         end if

         select srvdes, c24libconflg
           into b_ctn07c01.srvdes, ws.c24libconflg
           from avckservico
          where srvcod = b_ctn07c01.srvcod

         if sqlca.sqlcode = notfound then
            error " Tipo de Vistoria nao cadastrado!"
            call ctn07c02("VP") returning b_ctn07c01.srvcod
            next field srvcod
         else
            if ws.c24libconflg <> "S"   then
               error " Tipo de Vistoria nao disponivel para consulta!"
               next field srvcod
            end if
         end if
         display by name b_ctn07c01.srvdes
   end input

   let int_flag = false

   while not int_flag
      declare c_ctn07c01 cursor for
         select avckposto.pstsgl    ,
                avckposto.vstpstcod ,
                avckposto.endlgd    ,
                avckposto.endbrr    ,
                avckposto.endcid    ,
                avckposto.endufd    ,
                avckposto.dddcod    ,
                avckposto.teltxt    ,
                avckposto.c24obs    ,
                " "                 ,
                "PST"
           from avckposto, avcrpostoserv
          where avckposto.endcep        = k_ctn07c01.endcep    and
                avckposto.vstpststt     = "A"                  and

                avcrpostoserv.vstpstcod = avckposto.vstpstcod  and
                avcrpostoserv.srvcod    = b_ctn07c01.srvcod

         union

         select avckposto.pstsgl    ,
                avckposto.vstpstcod ,
                avckposto.endlgd    ,
                avckposto.endbrr    ,
                avckposto.endcid    ,
                avckposto.endufd    ,
                avckposto.dddcod    ,
                avckposto.teltxt    ,
                avckposto.c24obs    ,
                avcrregposto.cidnom ,
                "PRS"
           from avcrregposto, avckposto
          where avcrregposto.endcep  =  k_ctn07c01.endcep       and
                avcrregposto.srvcod  =  b_ctn07c01.srvcod       and

                avckposto.vstpstcod  =  avcrregposto.vstpstcod  and
                avckposto.vstpststt  =  "A"

      let i = 1

      foreach c_ctn07c01 into a_ctn07c01[i].pstsgl    ,
                              a_ctn07c01[i].vstpstcod ,
                              a_ctn07c01[i].endlgd    ,
                              a_ctn07c01[i].endbrr    ,
                              a_ctn07c01[i].endcid    ,
                              a_ctn07c01[i].endufd    ,
                              a_ctn07c01[i].dddcod    ,
                              a_ctn07c01[i].teltxt    ,
                              ws.c24obs               ,
                              ws.cidnom               ,
                              ws.tipo

         if b_ctn07c01.srvcod  =  "VP-DOM"   then
            initialize  ws.vstinptip, ws.vstrgicod   to null
            select vstinptip, vstrgicod
              into ws.vstinptip, ws.vstrgicod
              from avckposto
             where vstpstcod = a_ctn07c01[i].vstpstcod

            if ws.vstinptip  <>  4   then       #-> Tipo Posto = Inspetoria
               if ((ws.vstinptip  =  40)  and   #-> Tipo Posto = Prestador
                   (ws.vstrgicod  =  7    or    #-> Regiao     = Interior
                    ws.vstrgicod  =  8))  then  #-> Regiao     = Litoral
                  initialize a_ctn07c01[i]  to null
                  continue foreach
               end if
            end if
         end if

         let a_ctn07c01[i].c24obs1 = ws.c24obs[01,64]
         let a_ctn07c01[i].c24obs2 = ws.c24obs[65,128]

         declare c_ctn07c01hor cursor for
            select avckhoratend.atddiatip,
                   avckhoratend.atdhordes
              from avckhoratend
             where avckhoratend.vstpstcod = a_ctn07c01[i].vstpstcod and
                   avckhoratend.srvcod    = b_ctn07c01.srvcod
             order by avckhoratend.atddiatip

         foreach c_ctn07c01hor into ws.atddiatip, ws.horario

           if ws.horario is null then
              let ws.horario = "NAO CADASTRADO!"
           end if
           if ws.atddiatip = 1 then     ## Dia Util - Segunda a Sexta
              let a_ctn07c01[i].horsegsex = "SEG/SEX: ",ws.horario clipped
           else
              if ws.atddiatip = 2 then  ## Sabado, domingo e feriados
                 let a_ctn07c01[i].horsabdom = "SAB/DOM E FERIADOS: ", ws.horario clipped
              else
                 error " Tipo do dia nao cadastrado. AVISE A INFORMATICA!"
                 return
              end if
           end if
           initialize ws.horario to null

         end foreach

         if ws.tipo = "PRS"   then   #--> Encontrou prestador
            let ws.aviso =
            "CONTATO P/ SERVICOS NA REGIAO (", ws.cidnom clipped, ") ",
            "REALIZAR C/ A CENTRAL DE ATENDIMENTO FONE : ",
            a_ctn07c01[i].dddcod, " ", a_ctn07c01[i].teltxt
            let a_ctn07c01[i].aviso1 = ws.aviso[001,076]
            let a_ctn07c01[i].aviso2 = ws.aviso[077,152]
         end if

         let i = i + 1

         if i > 100 then
	    error " Limite de consulta excedido. Foram encontrados mais ",
                  "de 100 postos de vistoria!"
	    exit foreach
         end if
      end foreach

      if  i  >  1  then
          call set_count(i-1)
          message " (F17)Abandona, (F3)Proximo, (F4)Anterior"
          display array a_ctn07c01 to s_ctn07c01.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error " Nenhum posto localizado neste CEP - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  ctn07c01

#-------------------------------------------------------------------
function proxreg_ctn07c01(k_ctn07c01 )
#-------------------------------------------------------------------

   define k_ctn07c01 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn07c01 array[100] of record
      pstsgl         like   avckposto.pstsgl    ,
      vstpstcod      like   avckposto.vstpstcod ,
      endlgd         like   avckposto.endlgd    ,
      endbrr         like   avckposto.endbrr    ,
      endcid         like   avckposto.endcid    ,
      endufd         like   avckposto.endufd    ,
      dddcod         like   avckposto.dddcod    ,
      teltxt         like   avckposto.teltxt    ,
      horsegsex      char(65)                   ,
      horsabdom      char(65)                   ,
      c24obs1        char(64)                   ,
      c24obs2        char(64)                   ,
      aviso1         char(76)                   ,
      aviso2         char(76)
   end    record

   define ws         record
          atddiatip  like avckhoratend.atddiatip,
          horario    char(65)                   ,
          cidnom     like avcrregposto.cidnom   ,
          c24obs     like avckposto.c24obs      ,
          vstinptip  like avckposto.vstinptip   ,
          vstrgicod  like avckposto.vstrgicod   ,
          tipo       char(03)                   ,
          aviso      char(152)
   end    record

   define aux_cep    char(05)


	define	w_pf1	integer

	let	aux_cep  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn07c01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   let  aux_cep = k_ctn07c01.endcep

   if   gm_seqpesquisa   =   1  then
        if aux_cep[4,5]     =   "00"  then
           let  gm_seqpesquisa   =   2
        end if
   end if

   case gm_seqpesquisa
     when  1
       let  aux_cep[5,5] = "*"
     when  2
       let  aux_cep[4,5] = "* "
     when  3
       let  aux_cep[3,5] = "*  "
     when  4
       let  aux_cep[2,5] = "*   "
     otherwise
       error " Nenhum posto localizado nesta regiao!"
       return
   end case

   message " Aguarde, pesquisando... ", aux_cep   attribute (reverse)

   let int_flag = false
   while not int_flag
      declare prim_ctn07c01 cursor for
         select avckposto.pstsgl    ,
                avckposto.vstpstcod ,
                avckposto.endlgd    ,
                avckposto.endbrr    ,
                avckposto.endcid    ,
                avckposto.endufd    ,
                avckposto.dddcod    ,
                avckposto.teltxt    ,
                avckposto.c24obs    ,
                " "                 ,
                "PST"
           from avckposto, avcrpostoserv
          where avckposto.endcep        matches  aux_cep       and
                avckposto.vstpststt     = "A"                  and

                avcrpostoserv.vstpstcod = avckposto.vstpstcod and
                avcrpostoserv.srvcod    = b_ctn07c01.srvcod

         union

         select avckposto.pstsgl    ,
                avckposto.vstpstcod ,
                avckposto.endlgd    ,
                avckposto.endbrr    ,
                avckposto.endcid    ,
                avckposto.endufd    ,
                avckposto.dddcod    ,
                avckposto.teltxt    ,
                avckposto.c24obs    ,
                avcrregposto.cidnom ,
                "PRS"
           from avcrregposto, avckposto
          where avcrregposto.endcep  matches  aux_cep           and
                avcrregposto.srvcod  =  b_ctn07c01.srvcod       and

                avckposto.vstpstcod  =  avcrregposto.vstpstcod  and
                avckposto.vstpststt  =  "A"

      let i = 1

      foreach prim_ctn07c01 into a_ctn07c01[i].pstsgl    ,
                                 a_ctn07c01[i].vstpstcod ,
                                 a_ctn07c01[i].endlgd    ,
                                 a_ctn07c01[i].endbrr    ,
                                 a_ctn07c01[i].endcid    ,
                                 a_ctn07c01[i].endufd    ,
                                 a_ctn07c01[i].dddcod    ,
                                 a_ctn07c01[i].teltxt    ,
                                 ws.c24obs               ,
                                 ws.cidnom               ,
                                 ws.tipo

         if b_ctn07c01.srvcod  =  "VP-DOM"   then
            initialize  ws.vstinptip, ws.vstrgicod   to null
            select vstinptip, vstrgicod
              into ws.vstinptip, ws.vstrgicod
              from avckposto
             where vstpstcod = a_ctn07c01[i].vstpstcod

            if ws.vstinptip  <>  4   then
               if ((ws.vstinptip  =  40)   and
                   (ws.vstrgicod  =  7     or
                    ws.vstrgicod  =  8))   then
                  initialize a_ctn07c01[i]  to null
                  continue foreach
               end if
            end if
         end if

         declare c_prxctn07c01hor cursor for
            select avckhoratend.atddiatip,
                   avckhoratend.atdhordes
              from avckhoratend
             where avckhoratend.vstpstcod = a_ctn07c01[i].vstpstcod and
                   avckhoratend.srvcod    = b_ctn07c01.srvcod
             order by avckhoratend.atddiatip

         let a_ctn07c01[i].c24obs1 = ws.c24obs[01,64]
         let a_ctn07c01[i].c24obs2 = ws.c24obs[65,128]

         foreach c_prxctn07c01hor into ws.atddiatip, ws.horario

           if ws.horario is null then
              let ws.horario = "NAO CADASTRADO!"
           end if
           if ws.atddiatip = 1 then     ## Dia Util - Segunda a Sexta
              let a_ctn07c01[i].horsegsex = "SEG/SEX: ",ws.horario clipped
           else
              if ws.atddiatip = 2 then  ## Sabado, domingo e feriados
                 let a_ctn07c01[i].horsabdom = "SAB/DOM E FERIADOS: ",ws.horario clipped
              else
                 error " Tipo do dia nao cadastrado. AVISE A INFORMATICA!"
                 return
              end if
           end if
           initialize ws.horario to null

         end foreach

         if ws.tipo = "PRS"   then   #--> Encontrou prestador
            let ws.aviso =
            "CONTATO P/ SERVICOS NA REGIAO (", ws.cidnom clipped, ") ",
            "REALIZAR C/ A CENTRAL DE ATENDIMENTO FONE : ",
            a_ctn07c01[i].dddcod, " ", a_ctn07c01[i].teltxt
            let a_ctn07c01[i].aviso1 = ws.aviso[001,076]
            let a_ctn07c01[i].aviso2 = ws.aviso[077,152]
         end if

         let i = i + 1

         if i > 100 then
	    error " Limite de consulta excedido. Foram encontrados mais ",
                  "de 100 postos de vistoria!"
	    exit foreach
         end if

      end foreach

      message ""

      if  i  >  1  then
          call set_count(i-1)
          message " (F17)Abandona"
          display array a_ctn07c01 to s_ctn07c01.*
             on key (interrupt,control-c)
                exit display
          end display
      else
          error " Nenhum posto localizado nesta regiao - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  proxreg_ctn07c01 - Proxima Regiao do CEP
