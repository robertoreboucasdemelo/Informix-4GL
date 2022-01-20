#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        : Central 24h                                  #
#  Modulo         : cta11m00.4gl                                 #
#                   Popup de motivos de recusa                   #
#  Analista Resp. : Carlos Zyon                                  #
#  PSI            : 177903  - OSF 31682                          #
#................................................................#
#................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE, Mariana Gimenez         #
#  Liberacao      : 04/02/2004                                   #
#............................................................................#
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 01/09/2004 Robson, Meta      PSI186406  Alterada chamada a cts10g04_max_seq#
# 08/04/2005 Helio (Meta)      PSI 189790 Atualizar dados para o servico,    #
#                                         Obter  servicos multiplos,         #
#                                         Atualizar dados para os servicos   #
#                                         multiplos.                         #
#----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl" #PSI186406 -Robson

define  m_prepare        char(01)

{
main

defer interrupt

let g_issk.funmat = 603418
let g_issk.empcod = 1

call cta11m00(2,1465636,3,'','N')

end main
}
#---------------------------#
function cta11m00_prepare()
#---------------------------#

define l_comando        char(600)


  let l_comando = "select srvrcumtvcod,srvrcumtvdes ",
                  "  from datksrvrcumtv ",
                  " where atdsrvorg = ? ",
                  " order by srvrcumtvcod "

  prepare p_cta11m00_001 from l_comando
  declare c_cta11m00_001 cursor for p_cta11m00_001

  let l_comando = "select srvtipdes ",
                  "  from datksrvtip ",
                  " where atdsrvorg = ? "

  prepare p_cta11m00_002 from l_comando
  declare c_cta11m00_002 cursor for p_cta11m00_002

  let l_comando = "update datmsrvacp  ",
                  "   set srvrcumtvcod = ? ",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? ",
                  "   and atdsrvseq = ? "

  prepare p_cta11m00_003 from l_comando

  let l_comando = "update datmservico " ,
                  "   set atdprscod = '',",
                  "       atdvclsgl = '',",
                  "       socvclcod = '',",
                  "       srrcoddig = '',",
                  "       c24nomctt = '',",
                  "       c24opemat = '',",
                  "       atdfnlhor = '',",
                  "       cnldat    = '',",
                  "       atdcstvlr = '',",
                  "       atdprvdat = '',",
                  "       atdfnlflg = 'N'",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? "

  prepare p_cta11m00_004 from l_comando

  let m_prepare = "S"

end function
#---------------------------#
function cta11m00(l_param)
#---------------------------#

define l_param                record
       atdsrvorg              like datksrvtip.atdsrvorg
      ,atdsrvnum              like datmsrvacp.atdsrvnum
      ,atdsrvano              like datmsrvacp.atdsrvano
      ,pstcoddig              dec(6,0)
      ,grava                  char(01)
                              end record

define l_tela                 record
       atdsrvorg              like datksrvtip.atdsrvorg
      ,srvtipdes              like datksrvtip.srvtipdes
                              end record

define la_cta11m00            array[100] of record
       srvrcumtvcod           like datksrvrcumtv.srvrcumtvcod
      ,srvrcumtvdes           like datksrvrcumtv.srvrcumtvdes
                              end record
define l_i                    integer
      ,l_scr                  integer
      ,l_ret                  smallint
      ,l_nullo                smallint #PSI186406 -Robson
      ,l_resultado            smallint #PSI186406 -Robson
      ,l_mensagem             char(60) #PSI186406 -Robson

define l_seq                  like datmsrvacp.atdsrvseq
define l_srvrcumtvcod         like datksrvrcumtv.srvrcumtvcod

define larr_cta11m0001 array[10] of record
   atdmltsrvnum        like datratdmltsrv.atdmltsrvnum
  ,atdmltsrvano        like datratdmltsrv.atdmltsrvano
  ,socntzdes           like datksocntz.socntzdes
  ,espdes              like dbskesp.espdes
  ,atddfttxt           like datmservico.atddfttxt
end record

define l_sai           char(01)

   let l_sai = "N"

   initialize larr_cta11m0001 to null

   if m_prepare is null then
      call cta11m00_prepare()
   end if

   let int_flag = false
   let l_srvrcumtvcod = null
   let l_nullo     = null #PSI186406 -Robson
   let l_resultado = null #PSI186406 -Robson
   let l_mensagem  = null #PSI186406 -Robson

   open window w_cta11m00 at 05,02 with form "cta11m00"
     attribute (message line last)


     let l_tela.atdsrvorg = l_param.atdsrvorg

     whenever error continue
     open c_cta11m00_002 using l_tela.atdsrvorg
     fetch c_cta11m00_002 into l_tela.srvtipdes
     whenever error stop

     if sqlca.sqlcode < 0 then
        error "Problemas no acesso a tabela datksrvtip.(funcao cta11m00)",
              " Erro : ", sqlca.sqlcode
        sleep 1
        return l_srvrcumtvcod
     end if

     display by name l_tela.*

     open  c_cta11m00_001 using l_param.atdsrvorg

     let l_i = 1

     foreach c_cta11m00_001 into la_cta11m00[l_i].srvrcumtvcod
                              ,la_cta11m00[l_i].srvrcumtvdes

        let l_i = l_i + 1

        if l_i > 100 then
           error "Limite do array estourado, avise a Informatica"
           exit foreach
        end if

     end foreach

     call set_count(l_i -1)
     let l_i = l_i - 1

     display array la_cta11m00 to s_cta11m00.*


        on key (control-c, interrupt)
           clear form
           let int_flag = true
           exit display

        on key (f8)
           let l_i   = arr_curr()
           let l_scr = scr_line()
           let l_srvrcumtvcod = la_cta11m00[l_i].srvrcumtvcod
           exit display

     end display

     if l_param.grava = "S"   and
        int_flag      = false then

        begin work

	   #PSI 189790
	   #Atualizar os dados para o servico
	   call cta11m00_atu_dados(l_param.atdsrvnum
				  ,l_param.atdsrvano
				  ,l_param.pstcoddig
				  ,la_cta11m00[l_i].srvrcumtvcod)
              returning l_resultado, l_mensagem

	   if l_resultado <> 1 then
	      error l_mensagem
	      rollback work
	      close window w_cta11m00
	      return l_srvrcumtvcod
	   end if

	   #Obter os servicos multiplos
	   call cts29g00_obter_multiplo (2,l_param.atdsrvnum,l_param.atdsrvano)
	      returning l_resultado, l_mensagem, larr_cta11m0001[1].*
		       ,larr_cta11m0001[2].*
		       ,larr_cta11m0001[3].*
		       ,larr_cta11m0001[4].*
		       ,larr_cta11m0001[5].*
		       ,larr_cta11m0001[6].*
		       ,larr_cta11m0001[7].*
		       ,larr_cta11m0001[8].*
		       ,larr_cta11m0001[9].*
		       ,larr_cta11m0001[10].*

	   if l_resultado = 3 then
	      error l_mensagem
	      rollback work
	      close window w_cta11m00
	      return l_srvrcumtvcod
	   end if

	   #Atualizar os dados para os servicos multiplos
	   for l_i = 1 to 10
	      if larr_cta11m0001[l_i].atdmltsrvnum is not null then
	         call cta11m00_atu_dados(larr_cta11m0001[l_i].atdmltsrvnum
				        ,larr_cta11m0001[l_i].atdmltsrvano
				        ,l_param.pstcoddig
				        ,la_cta11m00[l_i].srvrcumtvcod)
	         returning l_resultado, l_mensagem

	         if l_resultado <> 1 then
	            error l_mensagem
		    rollback work
		    close window w_cta11m00
		    let l_sai = "S"
		    exit for
	         end if
	      end if
           end for
	   if l_sai = "S" then
              return l_srvrcumtvcod
	   end if

	   #Fim PSI 189790


        commit work

     else
        let int_flag = false
     end if

   close window w_cta11m00

   return l_srvrcumtvcod


end function

#PSI 189790
#------------------------------------------------------------------------------
function cta11m00_atu_dados(lr_cta11m0001)
#------------------------------------------------------------------------------
#Atualizar os dados para o motino de recusa
#Retorna 1 e mensagem nula se atualizou
#        2 e mensagem <> nula se deu erro

define lr_cta11m0001   record
   atdsrvnum           like datmsrvacp.atdsrvnum
  ,atdsrvano           like datmsrvacp.atdsrvano
  ,pstcoddig           dec(6,0)
  ,srvrcumtvcod        like datksrvrcumtv.srvrcumtvcod
end record

define l_resultado     smallint
define l_mensagem      char(60)
define l_nullo         smallint
define l_seq           like datmsrvacp.atdsrvseq
define l_ret           smallint

   let l_resultado = 0
   let l_mensagem = ""
   let l_nullo = null
   let l_ret = 0

   let l_resultado = cts10g04_insere_etapa(lr_cta11m0001.atdsrvnum
					  ,lr_cta11m0001.atdsrvano
                                          ,38,lr_cta11m0001.pstcoddig,'','','')

   if l_resultado <> 0 then
      let l_mensagem = "Erro na gravacao da etapa de acompanhamento. ",
                       "(funcao cts10g04) .Erro : ", sqlca.sqlcode
      return l_resultado, l_mensagem
   end if

   #PSI186406 -Robson -Inicio
   call cts10g04_max_seq(lr_cta11m0001.atdsrvnum
                        ,lr_cta11m0001.atdsrvano
                        ,l_nullo)
      returning l_resultado
               ,l_mensagem
               ,l_seq
   if l_resultado <> 1 then
      let int_flag = false
      return l_resultado, l_mensagem
   end if
   #PSI186406 -Robson -Fim

   whenever error continue
      execute p_cta11m00_003 using lr_cta11m0001.srvrcumtvcod
                                ,lr_cta11m0001.atdsrvnum
                                ,lr_cta11m0001.atdsrvano
                                ,l_seq
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_mensagem = "Problemas ao atualizar tabela de etapas .",
                       "(funcao cta11m00_atu_dados). Erro : ", sqlca.sqlcode
      return l_resultado, l_mensagem
   else
      call ctx34g00_apos_grvetapa(lr_cta11m0001.atdsrvnum,
                                  lr_cta11m0001.atdsrvano,
                                  l_seq,2)
   end if

   let l_ret = cts10g04_insere_etapa(lr_cta11m0001.atdsrvnum
				    ,lr_cta11m0001.atdsrvano
                                    ,1,'','','','')

   if l_ret <> 0 then
      let l_mensagem = "Erro na gravacao da etapa de acompanhamento.",
                       "(funcao cts10g04) Erro : ", sqlca.sqlcode
      return l_resultado, l_mensagem
   end if

   whenever error continue
      execute p_cta11m00_004 using lr_cta11m0001.atdsrvnum
                                ,lr_cta11m0001.atdsrvano
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let l_mensagem = "Erro ao atualizar tabela de servicos.",
                       "(funcao cta11m00_atu_dados) Erro : ", sqlca.sqlcode
      let l_resultado = 2
   else
      call cts00g07_apos_grvlaudo(lr_cta11m0001.atdsrvnum,lr_cta11m0001.atdsrvano)
   end if

   return l_resultado, l_mensagem

end function #cta11m00_atu_dados


