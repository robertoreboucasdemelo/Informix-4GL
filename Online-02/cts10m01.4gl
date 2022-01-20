#############################################################################
# Menu de Modulo: CTS10M01                                            Pedro #
#                                                                   Marcelo #
# Mostra Historico do Servico                                      Jan/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/01/1999  Probl.Ident  Gilberto     Correcao de casos onde dois funcio- #
#                                       narios digitam historico ao mesmo   #
#                                       tempo (data e hora).                #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
# 26/09/06    Ligia Mattge        PSI 202720     Chamar cta01m12            #
# 02/12/06    Ligia Mattge        PSI 202720     Desibinir cta01m12         #
# 28/10/10    Robert Lima         CT101024444    Aumentado tamanho do array #
#                                                a_cts10m01                 #
# 19/08/14    Rodolfo Massini     CH 14088130    Inicializar variavel funom #
#############################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'

#---------------------------------------------------------------
 function cts10m01(k_cts10m01)
#---------------------------------------------------------------

 define a_cts10m01 array[750] of record
    c24srvdsc      like datmservhist.c24srvdsc
 end record

 define k_cts10m01  record
    atdsrvnum       like datmservhist.atdsrvnum,
    atdsrvano       like datmservhist.atdsrvano
 end record

 define ws          record
    ligdat          like datmservhist.ligdat    ,
    lighor          like datmservhist.lighorinc ,
    c24txtseq       like datmservhist.c24txtseq ,
    c24funmat       like datmservhist.c24funmat ,
    c24srvdsc       like datmservhist.c24srvdsc ,
    ligdatant       like datmservhist.ligdat    ,
    lighorant       like datmservhist.lighorinc ,
    funmatant       like datmservhist.c24funmat ,
    funnom          like isskfunc.funnom,
    privez          smallint,
    prpflg          char(1),
    c24empcod       like datmservhist.c24empcod,
    ciaempcod       like datmservico.ciaempcod
 end record
 define w_retorno    record
        succod       like datksegsau.succod,
        ramcod       like datksegsau.ramcod,
        aplnumdig    like datksegsau.aplnumdig,
        crtsaunum    like datksegsau.crtsaunum,
        bnfnum       like datksegsau.bnfnum
 end record

 define arr_aux    smallint
 define scr_aux    smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  750
		initialize  a_cts10m01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
        initialize  w_retorno.* to null

 select ciaempcod
   into g_documento.ciaempcod
   from datmservico
  where atdsrvnum = k_cts10m01.atdsrvnum
    and atdsrvano = k_cts10m01.atdsrvano

 while true
    let int_flag = false

    declare c_cts10m01 cursor for
       select ligdat   , lighorinc,
              c24txtseq, c24funmat,
              c24srvdsc, c24empcod
         from datmservhist
        where atdsrvnum = k_cts10m01.atdsrvnum and
              atdsrvano = k_cts10m01.atdsrvano
        order by ligdat, lighorinc, c24txtseq

    initialize ws.* to null

    let arr_aux      = 1
    let ws.privez    = true

    let ws.ligdatant = "31/12/1899"
    let ws.lighorant = "00:00"
    let ws.funmatant = 999999

    initialize a_cts10m01  to null

    foreach c_cts10m01 into ws.ligdat   , ws.lighor   ,
                            ws.c24txtseq, ws.c24funmat,
                            ws.c24srvdsc, ws.c24empcod
     
       # Inicio - Rodolfo Massini (F0113761) - chamado 14088130
       let ws.funnom = null
       # Fim - Rodolfo Massini(F0113761) - chamado 14088130

       if arr_aux >= 750  then
          error " Limite excedido, historico com mais de 500 linhas. AVISE A INFORMATICA!"
          sleep 5
          exit foreach
       end if
              
       if ws.ligdatant <> ws.ligdat     or
          ws.lighorant <> ws.lighor     or
          ws.funmatant <> ws.c24funmat  then

          if ws.privez  =  true  then
             let ws.privez = false
          else
             let arr_aux = arr_aux + 2
          end if

          select funnom into ws.funnom
            from isskfunc
           where empcod = ws.c24empcod
             and funmat = ws.c24funmat
          
          let a_cts10m01[arr_aux].c24srvdsc = "Em: ",  ws.ligdat clipped, "  ",
                                              "As: ",  ws.lighor clipped, "  ",
                                              "Por: ", upshift(ws.funnom clipped)

          let ws.ligdatant = ws.ligdat
          let ws.lighorant = ws.lighor
          let ws.funmatant = ws.c24funmat
         
          let arr_aux      = arr_aux + 1
       end if

       let arr_aux = arr_aux + 1       
       let a_cts10m01[arr_aux].c24srvdsc = ws.c24srvdsc
       
    end foreach

    if arr_aux  >  1  then
       call set_count(arr_aux)
       display array a_cts10m01 to s_cts10m00.*

          on key (F5)
{
             if (g_documento.succod    is not null  and
                 g_documento.ramcod    is not null  and
                 g_documento.aplnumdig is not null) or
                 g_documento.crtsaunum is not null  then
                if g_documento.ramcod = 31   or
                   g_documento.ramcod = 531  then
                   call cta01m00()
                else
                   if g_documento.crtsaunum is not null then
                      call cta01m13(g_documento.crtsaunum,"","","")
                               returning w_retorno.succod,
                                         w_retorno.ramcod,
                                         w_retorno.aplnumdig,
                                         w_retorno.crtsaunum,
                                         w_retorno.bnfnum     # espelho saude
                   else
                      call cta01m20()
                   end if
                end if
             else
                if g_documento.prporg    is not null  and
                   g_documento.prpnumdig is not null  then
                   call opacc149(g_documento.prporg, g_documento.prpnumdig)
                        returning ws.prpflg
                else
                   if g_documento.pcacarnum is not null  and
                      g_documento.pcaprpitm is not null  then
                      call cta01m50(g_documento.pcacarnum,g_documento.pcaprpitm)
                   else
                      error " Espelho so' com documento localizado!"
                   end if
                end if
             end if
}
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
                              ,g_documento.ciaempcod)    #psi 205206

          on key (interrupt,control-c)
             exit display
       end display
    else
       error " Nenhum historico foi cadastrado para este servico!"
       let int_flag =  true
    end if

    if int_flag  then
       exit while
    end if

 end while

 let int_flag = false

end function  ###  cts10m01
