############################################################################
# Nome do Modulo: CTN05C03                                        Ruiz     #
#                                                                          #
# Mostra os Postos dos servicos graturitos                        Abr/2002 #
############################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'

define  b_ctn05c03 record
        discoddig  like   agckdisp.discoddig,
        disnom     like   agckdisp.disnom   ,
        srvcod     like   avckservico.srvcod,
        srvdes     like   avckservico.srvdes
end     record

#define i smallint
define gm_seqpesquisa smallint
define g_param     char (100)
define m_ctn05c03_prep smallint

function ctn05c03_prepare()

  define l_sql char(1000)
  
  let l_sql = 'select avcrdiservpost.discoddig ',
              'from  avcrdiservpost ',
              'where avcrdiservpost.vstpstcod = ? ',
              'and   avcrdiservpost.srvcod    = "IN-LOC" '         
  prepare p_ctn05c03_001 from l_sql
  declare c_ctn05c03_001 cursor for p_ctn05c03_001
  
  let l_sql = 'select agckdisp.dissgl ',
              'from agckdisp ',
              'where agckdisp.discoddig = ? '
              
  prepare p_ctn05c03_002 from l_sql
  declare c_ctn05c03_002 cursor for p_ctn05c03_002
  
  let m_ctn05c03_prep = true 
  
end function   


#---------------------------------------------------------------
 function ctn05c03( k_ctn05c03 )
#---------------------------------------------------------------

   define k_ctn05c03 record
          endcep     like   glaklgd.lgdcep
   end    record
   define ws  record
          confirma   char(01),
          sai        dec (1,0)
   end record



	initialize  ws.*  to  null

   open window w_ctn05c03 at 4,2 with form "ctn05c03"

   call get_param()
   let g_param = arg_val(15) 	

   declare c_ctn05c03_003   cursor for
     select discoddig
        from temp_cta08m00

   let b_ctn05c03.srvcod = "IN-LOC"

   foreach c_ctn05c03_003   into b_ctn05c03.discoddig
      call pesquisa_ctn05c03(k_ctn05c03.endcep,b_ctn05c03.discoddig)
      let  gm_seqpesquisa = 0
      if  i  >  1   then
      else
        while true
          let  gm_seqpesquisa = gm_seqpesquisa + 1
          if gm_seqpesquisa > 4 then
             call cts08g01("A","S",
                           "NAO HA POSTOS NESTA REGIAO PARA ESTE   ",
                           "SERVICO                                ",
                           "DESEJA IR PARA OUTRO SERVICO ??        ",
                           "")
                 returning ws.confirma
             if ws.confirma = "S" then
                exit while
             else
                exit foreach
             end if
          end if
          call proxreg_ctn05c03(k_ctn05c03.endcep,b_ctn05c03.discoddig)
                                returning ws.sai
          if  i      >  1 or
              ws.sai =  1 then
              exit while
          end if
        end while
        if ws.sai = 1 then
           exit foreach
        end if
      end if
   end foreach

   close window w_ctn05c03

end function  # ctn05c03

#-------------------------------------------------------------------
 function pesquisa_ctn05c03(k_ctn05c03)
#-------------------------------------------------------------------

   define k_ctn05c03   record
          endcep       like   glaklgd.lgdcep,
          discoddig    like   agckdisp.discoddig
   end record

   define ws           record
          dissgl       like agckdisp.dissgl       ,
          atddiatip    like avckhoratend.atddiatip,
          horario      char(65)                   ,
          tipo         char(03)                   ,
          cidnom       like avcrregposto.cidnom   ,
          c24libconflg like avcrregposto.cidnom   ,
          c24obs       like avckposto.c24obs      ,
          aviso        char(152)                  ,
          discoddig    like agckdisp.discoddig    ,
          f6           dec(1,0),
          f9           dec(1,0),
          f17          dec(1,0),
          vstinptip    dec(2,0)
   end    record

   define a_ctn05c03 array[100] of record
      pstsgl           like   avckposto.pstsgl    ,
      vstpstcod        like   avckposto.vstpstcod ,
      tpposto          char(09)                   ,
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
   define a_ctn05c03a array[100] of record
      discoddig        like   agckdisp.discoddig,
      disnom           like   agckdisp.disnom   ,
      descr            char   (12)
   end record



	define	w_pf1	integer

        define l_discoddig  like avcrdiservpost.discoddig
        
	for	w_pf1  =  1  to  100
		initialize  a_ctn05c03[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  100
		initialize  a_ctn05c03a[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
	let l_discoddig = null

  if m_ctn05c03_prep is null or
     m_ctn05c03_prep <> true then
     call ctn05c03_prepare()
  end if

   clear form

   let b_ctn05c03.discoddig = k_ctn05c03.discoddig
   display by name b_ctn05c03.discoddig attribute (reverse)
   select disnom
      into b_ctn05c03.disnom
      from agckdisp
     where discoddig = b_ctn05c03.discoddig
   display b_ctn05c03.discoddig to discoddig
   display b_ctn05c03.disnom    to descricao

   let int_flag = false

   while not int_flag
      declare c_ctn05c03_004 cursor for
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
                "   "               ,
                avckposto.vstinptip
           from avckposto, avcrdiservpost
          where avckposto.endcep         = k_ctn05c03.endcep    and
                avckposto.vstpststt      = "A"                  and

                avcrdiservpost.vstpstcod = avckposto.vstpstcod  and
                avcrdiservpost.srvcod    = b_ctn05c03.srvcod    and
                avcrdiservpost.discoddig = b_ctn05c03.discoddig
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
                avcrregposto.cidnom ,
                avckposto.vstinptip
           from avcrregposto, avcrdiservpost, avckposto
          where avcrregposto.endcep      = k_ctn05c03.endcep         and
                avcrregposto.srvcod      = b_ctn05c03.srvcod         and

                avcrdiservpost.vstpstcod = avcrregposto.vstpstcod    and
                avcrdiservpost.srvcod    = b_ctn05c03.srvcod         and
                avcrdiservpost.discoddig = b_ctn05c03.discoddig      and

                avckposto.vstpstcod      = avcrdiservpost.vstpstcod  and
                avckposto.vstpststt      = "A"
      let i = 1
      foreach c_ctn05c03_004 into a_ctn05c03[i].pstsgl    ,
                              a_ctn05c03[i].vstpstcod ,
                              a_ctn05c03[i].endlgd    ,
                              a_ctn05c03[i].endbrr    ,
                              a_ctn05c03[i].endcid    ,
                              a_ctn05c03[i].endufd    ,
                              a_ctn05c03[i].dddcod    ,
                              a_ctn05c03[i].teltxt    ,
                              ws.c24obs               ,
                              ws.tipo                 ,
                              ws.cidnom               ,
                              ws.vstinptip

         let a_ctn05c03[i].c24obs1 = ws.c24obs[01,64]
         let a_ctn05c03[i].c24obs2 = ws.c24obs[65,128]
         if  ws.vstinptip = 1 or
             ws.vstinptip = 2 or
             ws.vstinptip = 3 then
             let a_ctn05c03[i].tpposto = "PORTO    "
         else
             let a_ctn05c03[i].tpposto = "PRESTADOR"
         end if
                   
        whenever error continue 
        open c_ctn05c03_001 using  a_ctn05c03[i].vstpstcod                           
          foreach c_ctn05c03_001 into l_discoddig
             
             initialize  a_ctn05c03[i].disposit  to null   
             
             open c_ctn05c03_002 using l_discoddig          
                foreach  c_ctn05c03_002  into  ws.dissgl                
                   let a_ctn05c03[i].disposit =
                a_ctn05c03[i].disposit clipped, ws.dissgl clipped, ","                
                
                end foreach            
                close c_ctn05c03_002  
          end foreach        
          
        whenever error stop      
        close c_ctn05c03_001     

         declare c_ctn05c03_006 cursor for
            select avckhoratend.atddiatip,
                   avckhoratend.atdhordes
              from avckhoratend
             where avckhoratend.vstpstcod = a_ctn05c03[i].vstpstcod and
                   avckhoratend.srvcod    = b_ctn05c03.srvcod
             order by avckhoratend.atddiatip

         foreach c_ctn05c03_006 into ws.atddiatip, ws.horario
           if ws.horario is null then
              let ws.horario = "NAO CADASTRADO!"
           end if
           if ws.atddiatip = 1 then     ## Dia Util - Segunda a Sexta
              let a_ctn05c03[i].horsegsex = "SEG/SEX: ",ws.horario clipped
           else
              if ws.atddiatip = 2 then  ## Sabado, domingo e feriados
                 let a_ctn05c03[i].horsabdom = "SAB/DOM E FERIADOS: ",
                      ws.horario clipped
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
            a_ctn05c03[i].dddcod, " ", a_ctn05c03[i].teltxt
            let a_ctn05c03[i].aviso1 = ws.aviso[001,076]
            let a_ctn05c03[i].aviso2 = ws.aviso[077,152]
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
          if g_param[1,5] = "Benef" then
             message "(F17)Abandona,(F5)ExibServ.(F6)ProxServ.(F7)ServPosto ",
                     "(F8)Espelho"
          else
             message "(F17)Abandona,(F5)ExibServ.(F6)ProxServ.(F7)ServPosto ",
                     "(F8)Espelho,(F9)Hist."
          end if
          let ws.f6 = 0
          let ws.f9 = 0
          let ws.f17 = 0
          display array a_ctn05c03 to s_ctn05c03.*
             on key (F5)
                call ctn05c03_exibe_servico()

             on key (F6)
                let ws.f6 = 1
                exit display

             on key (F7)
                let i = arr_curr()
                call ctn05c04(a_ctn05c03[i].vstpstcod)

             on key (F8)
                call cta01m12_espelho(g_documento.ramcod,
                                      g_documento.succod,
                                      g_documento.aplnumdig,
                                      g_documento.itmnumdig,
                                      g_documento.prporg,
                                      g_documento.prpnumdig,
                                      g_documento.fcapacorg,
                                      g_documento.fcapacnum,
                                      g_documento.pcacarnum,
                                      g_documento.pcaprpitm,
                                      g_ppt.cmnnumdig,
                                      g_documento.crtsaunum,
                                      g_documento.bnfnum,
                                      g_documento.ciaempcod)
             on key (F9)  # tela de historico
                if g_param[1,5] = "Benef" then
                else
                   let ws.f9 = 1
                   call cta08m00_gera_ligacao()
                   exit display
                end if


             on key (interrupt,control-c)
                let ws.f17 = 1
                exit display
          end display
          if ws.f6  = 1 or
             ws.f9  = 1 or
             ws.f17 = 1 then
             exit while
          end if
      else
         #error " Nenhum posto localizado neste CEP - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false
   if ws.f9 = 1 then
      let int_flag = true # forca a saida na tela cta08m00
   end if

end function  #  ctn05c03

#-------------------------------------------------------------------
function proxreg_ctn05c03(k_ctn05c03 )
#-------------------------------------------------------------------

   define k_ctn05c03 record
      endcep         like  glaklgd.lgdcep,
      discoddig      like   agckdisp.discoddig
   end record

   define a_ctn05c03 array[100] of record
      pstsgl         like   avckposto.pstsgl    ,
      vstpstcod      like   avckposto.vstpstcod ,
      tpposto        char(09)                   ,
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
      dissgl         like agckdisp.dissgl       ,
      atddiatip      like avckhoratend.atddiatip,
      horario        char(65)                   ,
      tipo           char(03)                   ,
      cidnom         like avcrregposto.cidnom   ,
      c24obs         like avckposto.c24obs      ,
      aviso          char(152)                  ,
      f6             dec(1,0)                   ,
      f9             dec(1,0),
      f17            dec(1,0),
      vstinptip      like avckposto.vstinptip
   end    record

   define aux_cep    char(05)


	define	w_pf1	integer
	
	define l_discoddig  like avcrdiservpost.discoddig

	let	aux_cep  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn05c03[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
	let l_discoddig = null

   let  aux_cep = k_ctn05c03.endcep

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
   let ws.f17   = 0
   while not int_flag
      declare c_ctn05c03_005 cursor for
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
                "   "               ,
                avckposto.vstinptip
           from avckposto, avcrdiservpost
          where avckposto.endcep        matches  aux_cep       and
                avckposto.vstpststt     = "A"                  and

                avcrdiservpost.vstpstcod = avckposto.vstpstcod and
                avcrdiservpost.srvcod    = b_ctn05c03.srvcod   and
                avcrdiservpost.discoddig = b_ctn05c03.discoddig
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
                avcrregposto.cidnom ,
                avckposto.vstinptip
           from avcrregposto, avcrdiservpost, avckposto
          where avcrregposto.endcep        matches  aux_cep         and
                avcrregposto.srvcod        = b_ctn05c03.srvcod      and

                avcrdiservpost.vstpstcod = avcrregposto.vstpstcod   and
                avcrdiservpost.srvcod    = b_ctn05c03.srvcod        and
                avcrdiservpost.discoddig = b_ctn05c03.discoddig     and

                avckposto.vstpstcod     = avcrdiservpost.vstpstcod  and
                avckposto.vstpststt     = "A"
      let i = 1
      foreach c_ctn05c03_005 into a_ctn05c03[i].pstsgl    ,
                                 a_ctn05c03[i].vstpstcod ,
                                 a_ctn05c03[i].endlgd    ,
                                 a_ctn05c03[i].endbrr    ,
                                 a_ctn05c03[i].endcid    ,
                                 a_ctn05c03[i].endufd    ,
                                 a_ctn05c03[i].dddcod    ,
                                 a_ctn05c03[i].teltxt    ,
                                 ws.c24obs               ,
                                 ws.tipo                 ,
                                 ws.cidnom               ,
                                 ws.vstinptip

         let a_ctn05c03[i].c24obs1 = ws.c24obs[01,64]
         let a_ctn05c03[i].c24obs2 = ws.c24obs[65,128]
         if  ws.vstinptip = 1 or
             ws.vstinptip = 2 or
             ws.vstinptip = 3 then
             let a_ctn05c03[i].tpposto = "PORTO    "
         else
             let a_ctn05c03[i].tpposto = "PRESTADOR"
         end if

         
        whenever error continue 
        open c_ctn05c03_001 using  a_ctn05c03[i].vstpstcod                           
          foreach c_ctn05c03_001 into l_discoddig
             
             initialize  a_ctn05c03[i].disposit  to null   
             
             open c_ctn05c03_002 using l_discoddig          
                foreach  c_ctn05c03_002  into  ws.dissgl                
                   let a_ctn05c03[i].disposit =
                a_ctn05c03[i].disposit clipped, ws.dissgl clipped, ","                
                
                end foreach            
          end foreach        
          
        whenever error stop      
        close c_ctn05c03_001      
        close c_ctn05c03_002    
         
                  

         declare c_ctn05c03_007 cursor for
            select avckhoratend.atddiatip,
                   avckhoratend.atdhordes
              from avckhoratend
             where avckhoratend.vstpstcod = a_ctn05c03[i].vstpstcod and
                   avckhoratend.srvcod    = b_ctn05c03.srvcod
             order by avckhoratend.atddiatip

         foreach c_ctn05c03_007 into ws.atddiatip, ws.horario

           if ws.horario is null then
              let ws.horario = "NAO CADASTRADO!"
           end if
           if ws.atddiatip = 1 then     ## Dia Util - Segunda a Sexta
              let a_ctn05c03[i].horsegsex = "SEG/SEX: ",ws.horario clipped
           else
              if ws.atddiatip = 2 then  ## Sabado, domingo e feriados
                 let a_ctn05c03[i].horsabdom = "SAB/DOM E FERIADOS: ",
                       ws.horario clipped
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
            a_ctn05c03[i].dddcod, " ", a_ctn05c03[i].teltxt
            let a_ctn05c03[i].aviso1 = ws.aviso[001,076]
            let a_ctn05c03[i].aviso2 = ws.aviso[077,152]
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
          if g_param[1,5] = "Benef" then
             message "(F17)Abandona,(F5)ExibServ.(F6)ProxServ.(F7)ServPosto ",
                     "(F8)Espelho"
          else
             message "(F17)Abandona,(F5)ExibServ.(F6)ProxServ.(F7)ServPosto ",
                     "(F8)Espelho,(F9)Hist."
          end if
          let ws.f6  = 0
          let ws.f9  = 0
          let ws.f17 = 0
          display array a_ctn05c03 to s_ctn05c03.*
             on key (F5)
                call ctn05c03_exibe_servico()

             on key (F6)
                let ws.f6 = 1
                exit display

             on key (F7)
                let i = arr_curr()
                call ctn05c04(a_ctn05c03[i].vstpstcod)

             on key (F8)
                call cta01m12_espelho(g_documento.ramcod,
                                      g_documento.succod,
                                      g_documento.aplnumdig,
                                      g_documento.itmnumdig,
                                      g_documento.prporg,
                                      g_documento.prpnumdig,
                                      g_documento.fcapacorg,
                                      g_documento.fcapacnum,
                                      g_documento.pcacarnum,
                                      g_documento.pcaprpitm,
                                      g_ppt.cmnnumdig,
                                      g_documento.crtsaunum,
                                      g_documento.bnfnum,
                                      g_documento.ciaempcod)

             on key (F9)  # tela de historico
                if g_param[1,5] = "Benef" then
                else
                   let ws.f9 = 1
                   call cta08m00_gera_ligacao()
                   exit display
                end if

             on key (interrupt,control-c)
                let ws.f17 = 1
                exit display
          end display
          if ws.f6  = 1 or
             ws.f9  = 1 or
             ws.f17 = 1 then
             exit while
          end if
      else
          let int_flag =  true
      end if
   end while

   let int_flag = false
   if ws.f9 = 1 then
      let ws.f17 = 1
      let int_flag = true # forca a saida na tela cta08m00
   end if
   return ws.f17
end function  #  proxreg_ctn05c03 - Proxima Regiao do CEP

#------------------------------------------------------------------------------
function ctn05c03_exibe_servico()
#------------------------------------------------------------------------------
   define a_ctn05c03a array [100] of record
      discoddig      like agckdisp.discoddig,
      disnom         like agckdisp.disnom,
      descr          char (12)
   end record
   define i       integer


	define	w_pf1	integer

	let	i  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn05c03a[w_pf1].*  to  null
	end	for

   let i = 1
   declare c_ctn05c03_008 cursor for
      select *
       from temp_ctn05c03a
   foreach c_ctn05c03_008 into a_ctn05c03a[i].discoddig,
                            a_ctn05c03a[i].disnom   ,
                            a_ctn05c03a[i].descr
       let i  =  i + 1
   end foreach
   call set_count(i-1)
   open window w_ctn05c03a at 10,15 with form "ctn05c03a"
          attribute (border, form line 1)

   message " (F17)Abandona"
   display array a_ctn05c03a to s_ctn05c03a.*
          on key (interrupt,control-c)
          initialize a_ctn05c03a to null
          exit display
   end display

   let int_flag = false
   close window w_ctn05c03a

end function
