############################################################################
# Menu de Modulo: CTA03M00                                           Pedro #
#                                                                  Marcelo #
# Implementacao de Dados no Historico da Ligacao                  Jan/1995 #
############################################################################
#                           MANUTENCOES
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#---------------------------------------------------------------------------
#..........................................................................#
#                                                                          #
#                          * * * Alteracoes * * *                          #
#                                                                          #
# Data       Autor   Fabrica     Origem    Alteracao                       #
# ---------- ----------------- ----------  --------------------------------#
# 18/03/2005 James, Meta       PSI 191094  Chamar a funcao cta01m12()      #
#--------------------------------------------------------------------------#
# 22/09/2006 Ruiz              PSI 202720  Inclusao de parametros na funcao#
#                                          cta01m12(cartao saude).         #
# 16/011/2006 Ligia            PSI 205206  ciaempcod                       #
#--------------------------------------------------------------------------#
# 03/11/2010 Carla Rampazzo    PSI 000762  Chama funcao que direciona fluxo#
#                                          de atendimento do Help Desk Casa#
#--------------------------------------------------------------------------#


 globals  "/homedsa/projetos/geral/globals/glct.4gl"


 define ws         record
    ligdat         like datmservico.atddat   ,
    lighor         like datmservico.atdhor   ,
    funmat         like datmlighist.c24funmat,
    c24txtseq      like datmlighist.c24txtseq,
    c24ligdsc      like datmlighist.c24ligdsc,
    prpflg         char (01),
    lignum         like datmligacao.lignum,
    c24soltipcod   like datmligacao.c24soltipcod,
    c24solnom      like datmligacao.c24solnom,
    c24astcod      like datmligacao.c24astcod,
    c24paxnum      like datmligacao.c24paxnum,
    c24soltipdes   like datksoltip.c24soltipdes,
    srvnome        char (50),
    srvjustif      char (55)
 end record

 define l_ret      smallint,
        l_mensagem char(50)

#---------------------------------------------------------------
 function cta03m00(param)
#---------------------------------------------------------------

 define param      record
    lignum         like datmlighist.lignum   ,
    funmat         like datmlighist.c24funmat,
    data           like datmlighist.ligdat   ,
    hora           like datmlighist.lighorinc
 end record

 define a_cta03m00 array[200] of record
    c24ligdsc      like datmlighist.c24ligdsc
 end record

 define arr_aux    smallint
 define scr_aux    smallint
 define aux_times  char(11)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	aux_times  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cta03m00[w_pf1].*  to  null
	end	for

 if param.data is null then
    let aux_times = time
    let ws.lighor = aux_times[1,5]
    let ws.ligdat = today
    let ws.funmat = g_issk.funmat
 else
    let ws.lighor = param.hora
    let ws.ligdat = param.data
    let ws.funmat = param.funmat
 end if


 select c24astcod,ciaempcod
   into g_documento.c24astcod,
        g_documento.ciaempcod
   from datmligacao
  where lignum = param.lignum


 if g_documento.c24astcod <> "S51" then
    call cta03m00_tab_temp(param.*)  # tabela criada no modulo cta02m00
 end if

 let arr_aux = 1

 while true
    let int_flag = false

    call set_count(arr_aux - 1)

    options insert key f35 ,
            delete key f36

    input array a_cta03m00 without defaults from s_cta03m00.*
       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

       before insert
          initialize a_cta03m00[arr_aux].c24ligdsc  to null

          display a_cta03m00[arr_aux].c24ligdsc  to
                  s_cta03m00[scr_aux].c24ligdsc

       before field c24ligdsc
          display a_cta03m00[arr_aux].c24ligdsc to
                  s_cta03m00[scr_aux].c24ligdsc attribute (reverse)

       after  field c24ligdsc
          display a_cta03m00[arr_aux].c24ligdsc to
                  s_cta03m00[scr_aux].c24ligdsc

          if fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("up")    then
             error " Alteracoes e/ou correcoes nao sao permitidas!"
             next field c24ligdsc
          else
             if a_cta03m00[arr_aux].c24ligdsc is null  or
                a_cta03m00[arr_aux].c24ligdsc =  "  "  then
                error " Complemento deve ser informado!"
                next field c24ligdsc
             end if
          end if

       on key (F1)
          if g_documento.c24astcod is not null then
             call ctc58m00_vis(g_documento.c24astcod)
          end if

       on key (F5)
          let g_monitor.horaini = current ## Flexvision
          call cta01m12_espelho(g_documento.ramcod
                               ,g_documento.succod
                               ,g_documento.aplnumdig
                               ,g_documento.itmnumdig
                               ,g_documento.prporg
                               ,g_documento.prpnumdig
                               ,g_documento.fcapacorg
                               ,g_documento.fcapacnum
                               ,g_documento.pcacarnum
                               ,g_documento.pcaprpitm
                               ,g_ppt.cmnnumdig
                               ,g_documento.crtsaunum
                               ,g_documento.bnfnum
                               ,g_documento.ciaempcod) ##psi 205206

       on key (interrupt)
          exit input


       after row

          call ctd06g01_ult_seq_datmlighist(param.lignum)
               returning l_ret,
                         l_mensagem,
                         ws.c24txtseq

          if l_ret = 2 then   #se nao encontrou registro em datmlighist
             select lignum,
                    c24soltipcod,
                    c24solnom,
                    c24astcod,
                    c24paxnum
               into ws.lignum,
                    ws.c24soltipcod,
                    ws.c24solnom,
                    ws.c24astcod,
                    ws.c24paxnum
               from datmligacao
              where lignum = param.lignum

             if sqlca.sqlcode = 0 then
                select c24soltipdes
                   into ws.c24soltipdes
                   from datksoltip
                  where c24soltipcod = ws.c24soltipcod
             end if

             let ws.c24ligdsc = "Lig.:",ws.lignum using "<<<<<<<<<&"," ",
                                "Sol.:",ws.c24solnom clipped," ",
                                "Tip.:",ws.c24soltipdes clipped," ",
                                "Ass.:",ws.c24astcod," ",
                                "PA:",ws.c24paxnum

             call ctd06g01_ins_datmlighist(param.lignum,
                                           ws.funmat,
                                           ws.c24ligdsc,
                                           ws.ligdat,
                                           ws.lighor,
                                           g_issk.usrtip,
                                           g_issk.empcod )
                  returning l_ret,
                            l_mensagem
              if l_ret <> 1 then
                 error l_mensagem
              end if
              call cty40g00_grava_historico_ligacao(param.lignum)
          end if


          call ctd06g01_ins_datmlighist(param.lignum,
                                        ws.funmat,
                                        a_cta03m00[arr_aux].c24ligdsc,
                                        ws.ligdat,
                                        ws.lighor,
                                        g_issk.usrtip,
                                        g_issk.empcod )
               returning l_ret,
                         l_mensagem

           if l_ret <> 1 then
              error l_mensagem
              next field c24ligdsc
           end if

          initialize g_documento.acao to null

    end input

    if int_flag  then
       exit while
    end if

 end while

 ---> Se Assunto for de Help Desk o tratamento sera diferenciado
 if g_documento.c24astcod = "HDK" or
    g_documento.c24astcod = "S68" then   ---> Cortesia

    call cta15m00_hdk(param.lignum
                     ,ws.c24solnom)
         returning l_ret
                  ,l_mensagem

 end if
 
 #---------------------------------------  
 # Help Desk Itau    
 #---------------------------------------  
 
 if g_documento.c24astcod = "RDK" or
    g_documento.c24astcod = "R68" or 
    g_documento.c24astcod = "R78" then 

    call cty45g00_rdk(param.lignum
                     ,ws.c24solnom)
    returning l_ret
             ,l_mensagem

 end if

 let int_flag = false

clear form

end function  ###  cta03m00

#---------------------------------------------------------------------------
function cta03m00_tab_temp(param)
#---------------------------------------------------------------------------
   define param      record
      lignum         like datmlighist.lignum   ,
      funmat         like datmlighist.c24funmat,
      data           like datmlighist.ligdat   ,
      hora           like datmlighist.lighorinc
   end record


   whenever error continue
   select srvnome,
          srvjustif
      into ws.srvnome,
           ws.srvjustif
      from tmp_autorizasrv
     where srvfunmat = g_issk.funmat
       and srvempcod = g_issk.empcod
       and srvmaqsgl = g_issk.maqsgl
   whenever error stop

   if sqlca.sqlcode = 0  then


      call ctd06g01_ult_seq_datmlighist(param.lignum)
           returning l_ret,
                     l_mensagem,
                     ws.c24txtseq


      if l_ret  = 2 then   #se nao encontrou historico para ligacao
         select lignum,
                c24soltipcod,
                c24solnom,
                c24astcod,
                c24paxnum
           into ws.lignum,
                ws.c24soltipcod,
                ws.c24solnom,
                ws.c24astcod,
                ws.c24paxnum
           from datmligacao
          where lignum = param.lignum

          if sqlca.sqlcode = 0 then

             select c24soltipdes
                into ws.c24soltipdes
                from datksoltip
               where c24soltipcod = ws.c24soltipcod
          end if

          let ws.c24ligdsc = "Lig.:",ws.lignum using "<<<<<<<<<&"," ",
                             "Sol.:",ws.c24solnom clipped," ",
                             "Tip.:",ws.c24soltipdes clipped," ",
                             "Ass.:",ws.c24astcod," ",
                             "PA:",ws.c24paxnum


          call ctd06g01_ins_datmlighist(param.lignum,
                                        ws.funmat,
                                        ws.c24ligdsc,
                                        ws.ligdat,
                                        ws.lighor,
                                        g_issk.usrtip,
                                        g_issk.empcod )
               returning l_ret,
                         l_mensagem
           if l_ret <> 1 then
              error l_mensagem
           end if
      end if

      if ws.srvnome is not null then

         let ws.c24ligdsc = "Nome autorizou: ",ws.srvnome clipped

         call ctd06g01_ins_datmlighist(param.lignum,
                                       ws.funmat,
                                       ws.c24ligdsc,
                                       ws.ligdat,
                                       ws.lighor,
                                       g_issk.usrtip,
                                       g_issk.empcod )
              returning l_ret,
                        l_mensagem
         if l_ret <> 1 then
            error l_mensagem
         end if
      end if

      if ws.srvjustif is not null then

         let ws.c24ligdsc = "Justificativa: ",ws.srvjustif clipped

         call ctd06g01_ins_datmlighist(param.lignum,
                                       ws.funmat,
                                       ws.c24ligdsc,
                                       ws.ligdat,
                                       ws.lighor,
                                       g_issk.usrtip,
                                       g_issk.empcod )
              returning l_ret,
                        l_mensagem
         if l_ret <> 1 then
            error l_mensagem
         end if
      end if
   end if
end function
