############################################################################
# Nome do Modulo: CTN05C02                                        Marcelo  #
#                                                                 Gilberto #
# Consulta Postos por Instalacao de Dispositivos por CEP          Fev/1996 #
############################################################################

database porto

define  b_ctn05c02 record
        discoddig  like   agckdisp.discoddig,
        disnom     like   agckdisp.disnom   ,
        srvcod     like   avckservico.srvcod,
        srvdes     like   avckservico.srvdes
end     record

define i smallint
define gm_seqpesquisa smallint
define m_ctn05c02_prep smallint

function ctn05c02_prepare()

  define l_sql char(1000)
  
  let l_sql = 'select avcrdiservpost.discoddig ',
              'from  avcrdiservpost ',
              'where avcrdiservpost.vstpstcod = ? ',
              'and   avcrdiservpost.srvcod    = "IN-LOC" '         
  prepare p_ctn05c02_001 from l_sql
  declare c_ctn05c02_001 cursor for p_ctn05c02_001
  
  let l_sql = 'select agckdisp.dissgl ',
              'from agckdisp ',
              'where agckdisp.discoddig = ? '
              
  prepare p_ctn05c02_002 from l_sql
  declare c_ctn05c02_002 cursor for p_ctn05c02_002
  
  let m_ctn05c02_prep = true 
  
end function   



#---------------------------------------------------------------
 function ctn05c02( k_ctn05c02 )
#---------------------------------------------------------------

   define k_ctn05c02 record
          endcep     like   glaklgd.lgdcep
   end    record



   open window w_ctn05c02 at 4,2 with form "ctn05c02"

   let  gm_seqpesquisa = 0

   menu "INSTALACAO DISPOSITIVOS"

   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"

           if k_ctn05c02.endcep is null     then
              error " Nenhum Cep Selecionado"
              next option "Encerra"
           else
              call pesquisa_ctn05c02(k_ctn05c02.*)
              let  gm_seqpesquisa = 0
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa Proxima  Regiao do Cep "
           if k_ctn05c02.endcep is null     then
              error " Nenhum Cep Selecionado"
              next option "Seleciona"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn05c02(k_ctn05c02.*)
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctn05c02

end function  # ctn05c02

#-------------------------------------------------------------------
 function pesquisa_ctn05c02(k_ctn05c02 )
#-------------------------------------------------------------------

   define k_ctn05c02   record
          endcep       like   glaklgd.lgdcep
   end record

   define ws           record
          dissgl       like agckdisp.dissgl       ,
          atddiatip    like avckhoratend.atddiatip,
          horario      char(65)                   ,
          tipo         char(03)                   ,
          cidnom       like avcrregposto.cidnom   ,
          c24libconflg like avcrregposto.cidnom   ,
          c24obs       like avckposto.c24obs      ,
          aviso        char(152)
   end    record

   define a_ctn05c02 array[100] of record
      pstsgl           like   avckposto.pstsgl    ,
      vstpstcod        like   avckposto.vstpstcod ,
      endlgd           like   avckposto.endlgd    ,
      endbrr           like   avckposto.endbrr    ,
      endcid           like   avckposto.endcid    ,
      endufd           like   avckposto.endufd    ,
      dddcod           like   avckposto.dddcod    ,
      teltxt           like   avckposto.teltxt    ,
      horsegsex        char(65)                   ,
      horsabdom        char(65)                   ,
      disposit         char(78)                   ,
      c24obs1          char(64)                   ,
      c24obs2          char(64)                   ,
      aviso1           char(76)                   ,
      aviso2           char(76)
   end record

	define	w_pf1	integer
	define l_discoddig  like avcrdiservpost.discoddig

   if  m_ctn05c02_prep <> true or
       m_ctn05c02_prep is null then
       call ctn05c02_prepare()
   end if


	for	w_pf1  =  1  to  100
		initialize  a_ctn05c02[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
	let l_discoddig = null

   clear form

   input  by  name b_ctn05c02.srvcod   ,
                   b_ctn05c02.discoddig

      before field srvcod
         display by name b_ctn05c02.srvcod attribute (reverse)
         let b_ctn05c02.srvcod = "IN-LOC"
         select srvdes                  
            into b_ctn05c02.srvdes                     
            from avckservico
           where srvcod = b_ctn05c02.srvcod

         display by name b_ctn05c02.srvcod
         display by name b_ctn05c02.srvdes
         next field discoddig

      after  field srvcod
         display by name b_ctn05c02.srvcod
         
         if b_ctn05c02.srvcod  is null   or
            b_ctn05c02.srvcod  = "  "    then
            error " Tipo de instalacao e' obrigatorio!"
            call ctn07c02("IN") returning b_ctn05c02.srvcod
            next field srvcod
         else
            if b_ctn05c02.srvcod[1,2] <> "IN"   then
               error " Servico informado nao e' Instalacao!"
               next field srvcod
            end if
         end if

         select srvdes, c24libconflg
           into b_ctn05c02.srvdes, ws.c24libconflg
           from avckservico
          where srvcod = b_ctn05c02.srvcod

         if sqlca.sqlcode = notfound then
            error " Tipo de Instalacao nao cadastrado!"
            call ctn07c02("IN") returning b_ctn05c02.srvcod
            next field srvcod
         else
            if ws.c24libconflg <> "S"   then
               error " Tipo de Instalacao nao disponivel para consulta!"
               next field srvcod
            end if
         end if
         display by name b_ctn05c02.srvdes

      before field discoddig
         display by name b_ctn05c02.discoddig attribute (reverse)

      after  field discoddig
         display by name b_ctn05c02.discoddig

         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            next field srvcod
         end if

         if  b_ctn05c02.discoddig   is not null then
             select discoddig, disnom
               into b_ctn05c02.discoddig, b_ctn05c02.disnom
               from agckdisp
               where discoddig = b_ctn05c02.discoddig

             if sqlca.sqlcode = notfound then
                error " Dispositivo nao cadastrado, escolha o desejado!"
                call  ctn05c01() returning b_ctn05c02.discoddig,
                                           b_ctn05c02.disnom
                if b_ctn05c02.discoddig  is null  then
                   error "Tipo de dispositivo e' obrigatorio!"
                   next field discoddig
                end if
             end if
         end if

         if  b_ctn05c02.discoddig   is  null   or
             b_ctn05c02.discoddig   <   1   then
             error " Dispositivo e' obrigatorio, escolha o desejado!"
             call  ctn05c01() returning b_ctn05c02.discoddig,
                                        b_ctn05c02.disnom

             if b_ctn05c02.discoddig  is null  then
                error " Tipo de dispositivo e' obrigatorio!"
                next field discoddig
             end if
         end if

         display b_ctn05c02.discoddig to discoddig
         display b_ctn05c02.disnom    to descricao

   end input

   let int_flag = false

   while not int_flag
      declare c_ctn05c02 cursor for
         select avckposto.pstsgl    ,
                avckposto.vstpstcod ,
                avckposto.endlgd    ,
                avckposto.endbrr    ,
                avckposto.endcid    ,
                avckposto.endufd    ,
                avckposto.dddcod    ,
                avckposto.teltxt    ,
                avckposto.c24obs    ,
                "PST"               ,
                "   "
           from avckposto, avcrdiservpost
          where avckposto.endcep         = k_ctn05c02.endcep    and
                avckposto.vstpststt      = "A"                  and

                avcrdiservpost.vstpstcod = avckposto.vstpstcod  and
                avcrdiservpost.srvcod    = b_ctn05c02.srvcod    and
                avcrdiservpost.discoddig = b_ctn05c02.discoddig

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
                "PRS"               ,
                avcrregposto.cidnom
           from avcrregposto, avcrdiservpost, avckposto
          where avcrregposto.endcep      = k_ctn05c02.endcep         and
                avcrregposto.srvcod      = b_ctn05c02.srvcod         and

                avcrdiservpost.vstpstcod = avcrregposto.vstpstcod    and
                avcrdiservpost.srvcod    = b_ctn05c02.srvcod         and
                avcrdiservpost.discoddig = b_ctn05c02.discoddig      and

                avckposto.vstpstcod      = avcrdiservpost.vstpstcod  and
                avckposto.vstpststt      = "A"

      let i = 1

      foreach c_ctn05c02 into a_ctn05c02[i].pstsgl    ,
                              a_ctn05c02[i].vstpstcod ,
                              a_ctn05c02[i].endlgd    ,
                              a_ctn05c02[i].endbrr    ,
                              a_ctn05c02[i].endcid    ,
                              a_ctn05c02[i].endufd    ,
                              a_ctn05c02[i].dddcod    ,
                              a_ctn05c02[i].teltxt    ,
                              ws.c24obs               ,
                              ws.tipo                 ,
                              ws.cidnom

         let a_ctn05c02[i].c24obs1 = ws.c24obs[01,64]
         let a_ctn05c02[i].c24obs2 = ws.c24obs[65,128]
                   
         whenever error continue 
         open c_ctn05c02_001 using  a_ctn05c02[i].vstpstcod
         foreach c_ctn05c02_001 into l_discoddig
             
             initialize  a_ctn05c02[i].disposit  to null
             
             open c_ctn05c02_002 using l_discoddig     
             foreach  c_ctn05c02_002  into  ws.dissgl
             
                 let a_ctn05c02[i].disposit =
                 a_ctn05c02[i].disposit clipped, ws.dissgl clipped, ","
             
             end foreach
             close c_ctn05c02_002    
         end foreach
         whenever error stop
         
         close c_ctn05c02_001
             

         declare c_ctn05c02hor cursor for
            select avckhoratend.atddiatip,
                   avckhoratend.atdhordes
              from avckhoratend
             where avckhoratend.vstpstcod = a_ctn05c02[i].vstpstcod and
                   avckhoratend.srvcod    = b_ctn05c02.srvcod
             order by avckhoratend.atddiatip

         foreach c_ctn05c02hor into ws.atddiatip, ws.horario

           if ws.horario is null then
              let ws.horario = "NAO CADASTRADO!"
           end if
           if ws.atddiatip = 1 then     ## Dia Util - Segunda a Sexta
              let a_ctn05c02[i].horsegsex = "SEG/SEX: ",ws.horario clipped
           else
              if ws.atddiatip = 2 then  ## Sabado, domingo e feriados
                 let a_ctn05c02[i].horsabdom = "SAB/DOM E FERIADOS: ",ws.horario clipped
              else
                 error " Tipo do dia nao cadastrado. AVISE A INFORMATICA!"
                 return
              end if
           end if

         end foreach

         initialize ws.horario to null

         if ws.tipo = "PRS"   then   #--> Encontrou prestador
            let ws.aviso =
            "SOLICITAR CONTATO COM A CENTRAL DE ATENDIMENTO DA CIDADE (",
            ws.cidnom clipped, ") ", "PELO TELEFONE : ",
            a_ctn05c02[i].dddcod, " ", a_ctn05c02[i].teltxt
            let a_ctn05c02[i].aviso1 = ws.aviso[001,076]
            let a_ctn05c02[i].aviso2 = ws.aviso[077,152]
         end if

         let i = i + 1

         if i > 100 then
	    error " Limite de consulta excedido. Foram encontrados mais ",
                  "de 100 postos de instalacao!"
	    exit foreach
         end if
      end foreach

      if  i  >  1  then
          call set_count(i-1)
          message " (F17)Abandona, (F3)Proximo, (F4)Anterior"
          display array a_ctn05c02 to s_ctn05c02.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error " Nenhum posto localizado neste CEP - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  ctn05c02

#-------------------------------------------------------------------
function proxreg_ctn05c02(k_ctn05c02 )
#-------------------------------------------------------------------

   define k_ctn05c02 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn05c02 array[100] of record
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
      disposit       char(78)                   ,
      c24obs1        char(64)                   ,
      c24obs2        char(64)                   ,
      aviso1         char(76)                   ,
      aviso2         char(76)
   end    record

   define ws         record
          dissgl     like agckdisp.dissgl       ,
          atddiatip  like avckhoratend.atddiatip,
          horario    char(65)                   ,
          tipo       char(03)                   ,
          cidnom     like avcrregposto.cidnom   ,
          c24obs     like avckposto.c24obs      ,
          aviso      char(152)
   end    record

   define aux_cep    char(05)


	define	w_pf1	integer
        define l_discoddig  like avcrdiservpost.discoddig
	
	let	aux_cep  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn05c02[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
	let l_discoddig = null

   let  aux_cep = k_ctn05c02.endcep

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
      declare prim_ctn05c02 cursor for
         select avckposto.pstsgl    ,
                avckposto.vstpstcod ,
                avckposto.endlgd    ,
                avckposto.endbrr    ,
                avckposto.endcid    ,
                avckposto.endufd    ,
                avckposto.dddcod    ,
                avckposto.teltxt    ,
                avckposto.c24obs    ,
                "PST"               ,
                "   "
           from avckposto, avcrdiservpost
          where avckposto.endcep        matches  aux_cep       and
                avckposto.vstpststt     = "A"                  and

                avcrdiservpost.vstpstcod = avckposto.vstpstcod and
                avcrdiservpost.srvcod    = b_ctn05c02.srvcod   and
                avcrdiservpost.discoddig = b_ctn05c02.discoddig

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
                "PRS"               ,
                avcrregposto.cidnom
           from avcrregposto, avcrdiservpost, avckposto
          where avcrregposto.endcep        matches  aux_cep         and
                avcrregposto.srvcod        = b_ctn05c02.srvcod      and

                avcrdiservpost.vstpstcod = avcrregposto.vstpstcod   and
                avcrdiservpost.srvcod    = b_ctn05c02.srvcod        and
                avcrdiservpost.discoddig = b_ctn05c02.discoddig     and

                avckposto.vstpstcod     = avcrdiservpost.vstpstcod  and
                avckposto.vstpststt     = "A"

      let i = 1

      foreach prim_ctn05c02 into a_ctn05c02[i].pstsgl    ,
                                 a_ctn05c02[i].vstpstcod ,
                                 a_ctn05c02[i].endlgd    ,
                                 a_ctn05c02[i].endbrr    ,
                                 a_ctn05c02[i].endcid    ,
                                 a_ctn05c02[i].endufd    ,
                                 a_ctn05c02[i].dddcod    ,
                                 a_ctn05c02[i].teltxt    ,
                                 ws.c24obs               ,
                                 ws.tipo                 ,
                                 ws.cidnom

         let a_ctn05c02[i].c24obs1 = ws.c24obs[01,64]
         let a_ctn05c02[i].c24obs2 = ws.c24obs[65,128]

          
         whenever error continue 
         open c_ctn05c02_001 using  a_ctn05c02[i].vstpstcod
         foreach c_ctn05c02_001 into l_discoddig
             
             initialize  a_ctn05c02[i].disposit  to null             
             
             open c_ctn05c02_002 using l_discoddig     
             foreach  c_ctn05c02_002  into  ws.dissgl
             
                 let a_ctn05c02[i].disposit =
                 a_ctn05c02[i].disposit clipped, ws.dissgl clipped, ","
             
             end foreach
         end foreach
         whenever error stop 
         
         close c_ctn05c02_001
         close c_ctn05c02_002                                            

         declare c_prxctn05c02hor cursor for
            select avckhoratend.atddiatip,
                   avckhoratend.atdhordes
              from avckhoratend
             where avckhoratend.vstpstcod = a_ctn05c02[i].vstpstcod and
                   avckhoratend.srvcod    = b_ctn05c02.srvcod
             order by avckhoratend.atddiatip

         foreach c_prxctn05c02hor into ws.atddiatip, ws.horario

           if ws.horario is null then
              let ws.horario = "NAO CADASTRADO!"
           end if
           if ws.atddiatip = 1 then     ## Dia Util - Segunda a Sexta
              let a_ctn05c02[i].horsegsex = "SEG/SEX: ",ws.horario clipped
           else
              if ws.atddiatip = 2 then  ## Sabado, domingo e feriados
                 let a_ctn05c02[i].horsabdom = "SAB/DOM E FERIADOS: ", ws.horario clipped
              else
                 error " Tipo do dia nao cadastrado. AVISE A INFORMATICA!"
                 return
              end if
           end if
           initialize ws.horario to null

         end foreach

         if ws.tipo = "PRS"   then   #--> Encontrou prestador
            let ws.aviso =
            "SOLICITAR CONTATO COM A CENTRAL DE ATENDIMENTO DA CIDADE (",
            ws.cidnom clipped, ") ", "PELO TELEFONE : ",
            a_ctn05c02[i].dddcod, " ", a_ctn05c02[i].teltxt
            let a_ctn05c02[i].aviso1 = ws.aviso[001,076]
            let a_ctn05c02[i].aviso2 = ws.aviso[077,152]
         end if

         let i = i + 1

         if i > 100 then
	    error " Limite de consulta excedido. Foram encontrados mais ",
                  "de 100 postos de instalacao!"
	    exit foreach
         end if

      end foreach

      message ""

      if  i  >  1  then
          call set_count(i-1)
          message " (F17)Abandona "
          display array a_ctn05c02 to s_ctn05c02.*
             on key (interrupt,control-c)
                exit display
          end display
      else
          error " Nenhum posto localizado nesta regiao - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  proxreg_ctn05c02 - Proxima Regiao do CEP
