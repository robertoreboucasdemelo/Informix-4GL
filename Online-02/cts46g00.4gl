#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: cts46g00                                                   #
# ANALISTA RESP..: Ligia Maria Mattge                                         #
# PSI/OSF........: PSI 208892                                                 #
#                  Modulo p/solicitar placa/veiculo do terceiro na abertura do#
#                  C01, G11,G12,G15 e G21 e gravar da datmlighist             #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 21/05/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define mr_ret  record
          res     smallint,
          msg     char(70)
          end record

#----------------------------------------------------------------------------- 
function cts46g00(lr_param)
#----------------------------------------------------------------------------- 

   define lr_param  record
       lignum       like datmlighist.lignum,
       c24funmat    like datmlighist.c24funmat,
       ligdat       like datmlighist.ligdat,
       lighorinc    like datmlighist.lighorinc,
       c24astcod    like datmligacao.c24astcod,
       rcuccsmtvcod like datrligrcuccsmtv.rcuccsmtvcod,
       c24usrtip    like datmlighist.c24usrtip,
       c24empcod    like datmligacao.c24empcod,
       succod       like datrligapol.succod,
       aplnumdig    like datrligapol.aplnumdig,
       itmnumdig    like datrligapol.itmnumdig,
       ramcod       like datrligapol.ramcod,
       edsnumref    like datrligapol.edsnumref
   end record

   define lr_retorno     record
          resultado      smallint,
          mensagem       char(80),
          rcuccsmtvcod   like datrligrcuccsmtv.rcuccsmtvcod,
          c24astcod      like datrligrcuccsmtv.c24astcod
          end record

   define l_abre_tela smallint,
          l_res       smallint,
          l_msg       char(70),
          l_conf      char(1),
          l_indice    integer,
          l_lignum    like datmligacao.lignum

   initialize lr_retorno.* to null

   let l_abre_tela = null
   let l_conf      = null
   let l_res       = null
   let l_msg       = null
   let l_lignum    = null

   for l_indice = 1 to 100
       initialize g_hist[l_indice].* to null
   end for

   let l_indice    = 1

   if (lr_param.c24astcod = "C01"  and
       (lr_param.rcuccsmtvcod = 4 or
        lr_param.rcuccsmtvcod = 7 or
        lr_param.rcuccsmtvcod = 2 or
        lr_param.rcuccsmtvcod = 3)) or
      (lr_param.c24astcod = "G11" or
       lr_param.c24astcod = "G12" or
       lr_param.c24astcod = "G15" or
       lr_param.c24astcod = "G21") then

       if lr_param.c24astcod = "C01" then

          call cts10g10_ass_apol(lr_param.ramcod, lr_param.succod,
                                 lr_param.aplnumdig, lr_param.itmnumdig,
                                 lr_param.edsnumref, lr_param.c24astcod,
                                 lr_param.lignum)
                     returning l_res, l_msg, l_lignum

          if l_res = 1 then
             ## Carrega o g_hist[].historico
             call cts20g14_historico(l_lignum)
                  returning l_res, l_msg, l_indice

          end if
       end if

       call cts46g00_abre_tela(lr_param.lignum, lr_param.c24funmat,
                               lr_param.ligdat, lr_param.lighorinc,
                               lr_param.c24astcod, lr_param.rcuccsmtvcod,
                               lr_param.c24usrtip, lr_param.c24empcod, "M",
                               l_indice)
   end if
end function

#----------------------------------------------------------------------------- 
function cts46g00_abre_tela(lr_param)
#----------------------------------------------------------------------------- 

   define lr_param  record
       lignum       like datmlighist.lignum,
       c24funmat    like datmlighist.c24funmat,
       ligdat       like datmlighist.ligdat,
       lighorinc    like datmlighist.lighorinc,
       c24astcod    like datmligacao.c24astcod,
       rcuccsmtvcod like datrligrcuccsmtv.rcuccsmtvcod,
       c24usrtip    like datmlighist.c24usrtip,
       c24empcod    like datmligacao.c24empcod,
       ope          char(1),
       linha        integer
   end record

   define l_conta   smallint,
          l_linha   smallint,
          l_linha2  smallint,
          l_titulo1 char(75),
          l_titulo2 char(75),
          l_count   integer,
          l_res     smallint,
          l_msg     char(70),
          l_rcuccsmtvdes like datkrcuccsmtv.rcuccsmtvdes

   let l_res          = null
   let l_msg          = null
   let l_conta        = null
   let l_linha        = null
   let l_linha2       = null
   let l_titulo1      = null
   let l_titulo2      = null
   let l_count        = null
   let l_rcuccsmtvdes = null
   let l_linha = lr_param.linha

   initialize mr_ret.* to null

   open window t_cts46g00 at 10,2 with form "cts46g00"
        attribute (border, form line 1)

   if lr_param.ope = "M" then
      let l_titulo1 = "Confirme a(s) placa(s) e veiculo(s) do(s) terceiro(s) ",
                      "em caso de"
      let l_titulo2 = "evento novo:"
   else
      call cts20g14_desc_motivo(lr_param.rcuccsmtvcod, lr_param.c24astcod)
           returning l_res, l_msg, l_rcuccsmtvdes
      let l_titulo1 = "          MOTIVO: ", l_rcuccsmtvdes
   end if

   display l_titulo1 to titulo1
   display l_titulo2 to titulo2
   display g_documento.atdnum to atdnum attribute (reverse)

   call set_count(l_linha)

   if lr_param.ope = "M" then

      input array g_hist without defaults from s_hist.*

         before row
                let l_linha = arr_curr()
                let l_linha2 = scr_line()
                let l_count = arr_count()
         
         before field historico
                display g_hist[l_linha].historico to
                        s_hist[l_linha2].historico   attribute (reverse)
         
         after field historico
               display g_hist[l_linha].historico to
                       s_hist[l_linha2].historico
              if fgl_lastkey() <> fgl_keyval("left")  and
                 fgl_lastkey() <> fgl_keyval("up")    then
                 if g_hist[l_linha].historico is null then
                    next field historico
                 end if
              end if
         
         on key (interrupt)
            if g_hist[1].historico is null then
               next field historico
            end if
            let l_count = arr_count()
            exit input
      end input
      
      if lr_param.lignum is not null then
         for l_conta = 1 to l_count
             if g_hist[l_conta].historico is not null then
                call cts20g14_grava_hist(lr_param.lignum,
                                         g_hist[l_conta].historico)
                     returning mr_ret.*
                if mr_ret.res <> 1 then
                   error mr_ret.msg sleep 1
                   exit for
                end if
             end if
         end for
      end if
   
   else
      display array g_hist to s_hist.*
         on key (interrupt)
            exit display
      end display
   end if

   close window t_cts46g00

end function

#----------------------------------------------------------------------------- 
function cts46g00_grava(lr_param)
#----------------------------------------------------------------------------- 

   define lr_param  record
       atdsrvnum    like datmservhist.atdsrvnum,
       atdsrvano    like datmservhist.atdsrvano,
       c24funmat    like datmlighist.c24funmat,
       ligdat       like datmlighist.ligdat,
       lighorinc    like datmlighist.lighorinc,
       c24astcod    like datmligacao.c24astcod,
       c24usrtip    like datmlighist.c24usrtip,
       c24empcod    like datmligacao.c24empcod
   end record

   define l_conta smallint
   let l_conta = null

   for l_conta = 1 to 100
       if g_hist[l_conta].historico is not null then
          call ctd07g01_ins_datmservhist(lr_param.atdsrvnum,
                                         lr_param.atdsrvano,
                                         lr_param.c24funmat,
                                         g_hist[l_conta].historico,
                                         lr_param.ligdat,
                                         lr_param.lighorinc,
                                         lr_param.c24empcod,
                                         lr_param.c24usrtip)
               returning mr_ret.*

          if mr_ret.res <> 1 then
             error mr_ret.msg sleep 1
             exit for
          end if

       end if
   end for

end function

#----------------------------------------------------------------------------- 
function cts46g00_consulta(l_lignum)
#----------------------------------------------------------------------------- 

   define l_lignum          like datmhstligrcuccsmt.lignum,
          l_res             smallint,
          l_msg             char(70),
          l_conf            char(1),
          l_indice          integer,
          l_assunto         like datkrcuccsmtv.c24astcod,
          l_assunto_2       like datkrcuccsmtv.c24astcod,
          l_rcuccsmtvcod    like datrligrcuccsmtv.rcuccsmtvcod,
          l_rcuccsmtvcod_2  like datrligrcuccsmtv.rcuccsmtvcod,
          l_rcuccsmtvdes    like datkrcuccsmtv.rcuccsmtvdes,
          l_rcuccsmtvdes_2  like datkrcuccsmtv.rcuccsmtvdes,
          l_rcuccsmtvsubcod like datkrcuccsmtvsub.rcuccsmtvsubcod,
          l_rcuccsmtvsubdes like datkrcuccsmtvsub.rcuccsmtvsubdes,
          l_linha1          char(40),
          l_linha2          char(40),
          l_linha3          char(40),
          l_linha4          char(40),
          l_linha5          char(40),
          l_linha6          char(40)
   
   let l_res            = null
   let l_msg            = null
   let l_conf           = null
   let l_linha1         = null
   let l_linha2         = null
   let l_linha3         = null
   let l_linha4         = null
   let l_linha5         = null
   let l_linha6         = null
   let l_assunto        = null
   let l_assunto_2      = null
   let l_rcuccsmtvcod   = null
   let l_rcuccsmtvcod_2 = null
   let l_rcuccsmtvdes   = null
   let l_rcuccsmtvdes_2 = null
   let l_indice         = null

   for l_indice = 1 to 100
       initialize g_hist[l_indice].* to null
   end for

   let l_linha1 = "MOTIVO"
   let l_linha5 = "SUBMOTIVO"
   
   
   call cts20g14_motivo_con(l_lignum)
        returning l_res, l_msg, l_rcuccsmtvcod, l_assunto

   if l_res = 1 then

      if l_assunto = "C01" and
         (l_rcuccsmtvcod = 4 or l_rcuccsmtvcod = 7 or
          l_rcuccsmtvcod = 2 or l_rcuccsmtvcod = 3) then

         ## Carrega o g_hist[].historico
         call cts20g14_historico(l_lignum)
              returning l_res, l_msg, l_indice

         call cts46g00_abre_tela(l_lignum, g_issk.funmat, today, current,
                                 l_assunto, l_rcuccsmtvcod,
                                 g_issk.usrtip, g_issk.empcod, "C", l_indice)
      else

         call cts20g14_desc_motivo(l_rcuccsmtvcod,l_assunto)
              returning l_res, l_msg, l_rcuccsmtvdes

         if l_res = 1 then
            let l_linha2 = l_rcuccsmtvdes[1,40]
	         let l_linha3 = l_rcuccsmtvdes[41,50]
         end if


         ---> Verifica se ha outro motivo cadastrado (CAPS)
         call cts20g14_motivo_con2(l_lignum)
              returning l_res, l_msg, l_rcuccsmtvcod_2, l_assunto_2

         if l_res = 1 then

            ---> Verifica se ha outro Motivo e se sao Diferentes
            if l_rcuccsmtvcod_2 is not null       and
               l_rcuccsmtvcod_2 <> 0              and
               l_rcuccsmtvcod_2 <> l_rcuccsmtvcod then


               call cts20g14_desc_motivo(l_rcuccsmtvcod_2,l_assunto_2)
                    returning l_res, l_msg, l_rcuccsmtvdes_2

               if l_res = 1 then
                  if l_linha3 is null or
                     l_linha3 =  " "  then
                     let l_linha3 = l_rcuccsmtvdes_2[1,40]
	             let l_linha4 = l_rcuccsmtvdes_2[41,50]
                  else
                     let l_linha3 = l_linha3  clipped
                                   ,"*****"   clipped
                                   ,l_rcuccsmtvdes_2[1,35]
	                   let l_linha4 = l_rcuccsmtvdes_2[36,50]
                  end if
               end if
            end if
         end if
         
         # Recupera o Submotivo
         
         call cts20g14_submotivo_con(l_lignum,l_rcuccsmtvcod)                    
              returning l_res, l_msg, l_rcuccsmtvsubcod
         
         if l_res = 1 and 
            l_rcuccsmtvsubcod is not null then
         
            call cts20g14_desc_submotivo(l_assunto,l_rcuccsmtvcod,l_rcuccsmtvsubcod)
                 returning l_res, l_msg, l_rcuccsmtvsubdes        
            
            if l_res = 1 then                      
               let l_linha6 = l_rcuccsmtvsubdes [1,40] 
            end if                                 
         end if

         if l_linha2 is not null and
            l_linha2 <> " "      then
            call cts08g01_6l("A", "N", l_linha1 , l_linha2, l_linha3, l_linha4, l_linha5, l_linha6)
                 returning l_conf
         end if
      end if
   end if

end function
