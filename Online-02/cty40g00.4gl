#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty40g00                                                    #
# Objetivo.......: Envio do Protocolo de Atendimento via SMS                   #
# Analista Resp. : Humberto Benedito                                           #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 10/01/2015                                                  #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint
define m_envio   smallint


define mr_param record
	dddtel  integer,
	numtel  integer,
	envio   smallint
end record


define mr_permitido array[500] of record
	c24astcod    like datkassunto.c24astcod
end record


#----------------------------------------------#
 function cty40g00_prepare()
#----------------------------------------------#

  define l_sql char(500)

  let l_sql = ' select count(*)         '
          ,  '  from datkdominio        '
          ,  '  where cponom = ?        '
          ,  '  and   cpodes = ?        '
  prepare pcty40g00001 from l_sql
  declare ccty40g00001 cursor for pcty40g00001

  let l_sql = ' select c.celteldddcod, ',
              '        c.celtelnum,    ',
              '        c.atdsrvano,    ',
              '        c.atdsrvnum     ',
              ' from datrligapol a,    ',
              '      datmligacao b,	   ',
              '      datmlcl c         ',
              ' where a.lignum  = b.lignum    ',
              ' and b.atdsrvano = c.atdsrvano ',
              ' and b.atdsrvnum = c.atdsrvnum ',
              ' and a.succod = ?              ',
              ' and a.ramcod = ?              ',
              ' and a.aplnumdig = ?           ',
              ' and a.itmnumdig = ?           ',
              ' and celteldddcod is not null  ',
              ' and celtelnum is not null     ',
              ' order by c.atdsrvano desc,    ',
              '          c.atdsrvnum desc     '
   prepare pcty40g00002 from l_sql
   declare ccty40g00002 cursor for pcty40g00002

   let l_sql = ' select dddnum,          '
           ,  '         telnum  	       '
           ,  '  from gsaktel            '
           ,  '  where segnumdig = ?     '
           ,  '  and   teltipcod = 11    '
   prepare pcty40g00003 from l_sql
   declare ccty40g00003 cursor for pcty40g00003


   let l_sql = ' select cpodes           '
           ,  '  from datkdominio        '
           ,  '  where cponom = ?        '
   prepare pcty40g00004 from l_sql
   declare ccty40g00004 cursor for pcty40g00004



  let m_prepare = true

end function


#----------------------------------------------#
 function cty40g00(lr_param)
#----------------------------------------------#

define lr_param record
	c24astcod    like datkassunto.c24astcod
end record

define lr_retorno record
    confirma char(01)
end record

initialize lr_retorno.*, mr_param.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty40g00_prepare()
    end if

    let mr_param.envio = false

    if g_documento.atdnum is null or
    	 g_documento.atdnum = 0    then
    	 	return
     end if


    if cty40g00_verifica_assunto(lr_param.c24astcod) then

        call cts08g01('C','S'                         ,
                      ''                              ,
                      'DESEJA ENVIAR O'               ,
                      'NUMERO DO PROTOCOLO POR SMS?'  ,
                      '')
        returning lr_retorno.confirma

        if lr_retorno.confirma = "S" then
        	 call cty40g00_input()
        end if

  	end if

end function


#----------------------------------------------#
 function cty40g00_verifica_assunto(lr_param)
#----------------------------------------------#

define lr_param record
	c24astcod    like datkassunto.c24astcod
end record

define lr_retorno record
  cont         smallint,
  chave        char(20)
end record


initialize lr_retorno.* to null


    let lr_retorno.chave = "cty40g00_assunto"

    #--------------------------------------------------------
    # Verifica se Assunto tem Permissao
    #--------------------------------------------------------

    open ccty40g00001  using  lr_retorno.chave     ,
                              lr_param.c24astcod
    whenever error continue
    fetch ccty40g00001 into lr_retorno.cont
    whenever error stop

    if lr_retorno.cont > 0 then
    	 return true
    end if

    return false


end function


#----------------------------------------------#
 function cty40g00_input()
#----------------------------------------------#

define lr_cty40g00 record
  dddtel  integer,
  numtel  integer
end record

define lr_retorno record
  cont         smallint,
  chave        char(20),
  tamanho      smallint,
  numtel       char(9)
end record


initialize lr_retorno.* to null


     open window cty40g00 at 09,07 with form "cty40g00"
     attribute (border)

     call cty40g00_recupera_celular()
     returning lr_cty40g00.dddtel ,
               lr_cty40g00.numtel


     input by name lr_cty40g00.* without defaults


     #-----------------------------------------------------------------------------------
     # BEFORE DDDTEL
     #-----------------------------------------------------------------------------------

           before field dddtel
              display by name lr_cty40g00.dddtel attribute (reverse)

     #-----------------------------------------------------------------------------------
     # AFTER DDDTEL
     #-----------------------------------------------------------------------------------

           after field dddtel
              display by name lr_cty40g00.dddtel

              if lr_cty40g00.dddtel is null then
                 error "Informe o DDD do Telefone Celular "
                 next field dddtel
              end if



     #-----------------------------------------------------------------------------------
     # BEFORE NUMTEL
     #-----------------------------------------------------------------------------------

           before field numtel
              display by name lr_cty40g00.numtel attribute (reverse)

     #-----------------------------------------------------------------------------------
     # AFTER NUMTEL
     #-----------------------------------------------------------------------------------

           after field numtel
              display by name lr_cty40g00.numtel

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field dddtel
              end if


              if lr_cty40g00.numtel is null then
                 error "Informe o Numero do Telefone Celular "
                 next field numtel
              end if

             let lr_retorno.numtel  = lr_cty40g00.numtel
             let lr_retorno.tamanho = (length (lr_retorno.numtel))

             if lr_retorno.tamanho < 8 then
                error "Informe um Numero de Telefone Celular Valido "
                next field numtel
             end if



     on key(f17, interrupt,control-c)
        let int_flag = false
        exit input


     end input

     if lr_cty40g00.dddtel is not null and
     	  lr_cty40g00.numtel is not null then

        call cty40g00_envia_sms(lr_cty40g00.dddtel,
                                lr_cty40g00.numtel)

     end if

     close window cty40g00

end function

#----------------------------------------------#
 function cty40g00_recupera_celular()
#----------------------------------------------#

define lr_retorno record
   dddtel     integer                    ,
   numtel     integer                    ,
   resultado  integer                    ,
   mensagem   char(50)                   ,
   atdsrvano  like datmservico.atdsrvano ,
   atdsrvnum  like datmservico.atdsrvnum ,
   segnumdig  like abbmdoc.segnumdig     ,
   sgrorg     like rsamseguro.sgrorg     ,
   sgrnumdig  like rsamseguro.sgrnumdig
end record


initialize lr_retorno.* to null



    #--------------------------------------------------------
    # Verifica se Ha Algum Servico que Contenha o Celular
    #--------------------------------------------------------

    open ccty40g00002  using  g_documento.succod    ,
                              g_documento.ramcod    ,
                              g_documento.aplnumdig ,
                              g_documento.itmnumdig

    whenever error continue
    fetch ccty40g00002 into lr_retorno.dddtel    ,
                            lr_retorno.numtel    ,
                            lr_retorno.atdsrvano ,
                            lr_retorno.atdsrvnum
    whenever error stop

    if lr_retorno.dddtel is null or
    	 lr_retorno.numtel is null then


       if g_documento.ciaempcod = 1 then


          if g_documento.ramcod = 31  or
           	g_documento.ramcod = 531 then

             #--------------------------------------------------------
             # Recupera Segurado Automovel
             #--------------------------------------------------------

             call cty05g00_segnumdig(g_documento.succod    ,
                                     g_documento.aplnumdig ,
                                     g_documento.itmnumdig ,
                                     g_funapol.dctnumseq   ,
                                     g_documento.prporg    ,
                                     g_documento.prpnumdig )
             returning lr_retorno.resultado,
                  lr_retorno.mensagem ,
                  lr_retorno.segnumdig


          else

             #--------------------------------------------------------
             # Recupera Segurado RE
             #--------------------------------------------------------

             call cty06g00_obter_seguro(g_documento.ramcod   ,
                                        g_documento.succod   ,
                                        g_documento.aplnumdig)
  returning lr_retorno.resultado ,
            lr_retorno.mensagem  ,
                       lr_retorno.sgrorg    ,
            lr_retorno.sgrnumdig


             call cty06g00_segnumdig(lr_retorno.sgrorg    ,
                                     lr_retorno.sgrnumdig ,
                                     g_documento.prporg   ,
                                     g_documento.prpnumdig)
  returning lr_retorno.resultado,
                       lr_retorno.mensagem ,
                       lr_retorno.segnumdig

          end if

   		end if

      if lr_retorno.segnumdig is not null then


         #--------------------------------------------------------
         # Recupera o Celular do Segurado
         #--------------------------------------------------------

         open ccty40g00003  using  lr_retorno.segnumdig
         whenever error continue
         fetch ccty40g00003 into lr_retorno.dddtel,
                                 lr_retorno.numtel
         whenever error stop


      end if


    end if

    return lr_retorno.dddtel,
           lr_retorno.numtel


end function

#----------------------------------------------#
 function cty40g00_envia_sms(lr_param)
#----------------------------------------------#

define lr_param record
	dddtel     integer   ,
	numtel     integer
end record


define lr_retorno record
	 sissgl     like pccmcorsms.sissgl     ,
prioridade smallint                   ,
expiracao  integer                    ,
   msgtxt     like dbsmenvmsgsms.msgtxt  ,
   resultado  integer                    ,
   mensagem   char(50)
end record

initialize lr_retorno.* to null


     let lr_retorno.sissgl     = "psg_ctsacdec76786"
     let lr_retorno.prioridade = figrc007_prioridade_alta()
    let lr_retorno.expiracao  = figrc007_expiracao_1h()

     if g_documento.ciaempcod = 1 then
         let lr_retorno.msgtxt = "Porto Seguro Informa: Protocolo de Atendimento ", g_documento.atdnum using '<<<<<<<<&&'
     end if
     if g_documento.ciaempcod = 35 then
         let lr_retorno.msgtxt = "Azul Seguros Informa: Protocolo de Atendimento ", g_documento.atdnum using '<<<<<<<<&&'
     end if
     if g_documento.ciaempcod = 84 then
         let lr_retorno.msgtxt = "Itau Seguros Informa: Protocolo de Atendimento ", g_documento.atdnum using '<<<<<<<<&&'
     end if

     #--------------------------------------------------------
     # Faz o Envio da Mensagem
     #--------------------------------------------------------

     call figrc007_sms_send1 (lr_param.dddtel        ,
                              lr_param.numtel        ,
                              lr_retorno.msgtxt      ,
                              lr_retorno.sissgl      ,
                              lr_retorno.prioridade  ,
                              lr_retorno.expiracao   )
                    returning lr_retorno.resultado,
                              lr_retorno.mensagem

     if lr_retorno.resultado = 0 then
     	  let mr_param.envio  = true
     	  let mr_param.dddtel = lr_param.dddtel
     	  let mr_param.numtel = lr_param.numtel
     end if


end function

#----------------------------------------------#
 function cty40g00_carrega_assunto()
#----------------------------------------------#


define lr_retorno record
  chave        char(20)
end record

define arr_aux smallint

for  arr_aux  =  1  to  500
   initialize  mr_permitido[arr_aux].* to  null
end  for

	  initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty40g00_prepare()
    end if

    let lr_retorno.chave = "cty40g00_assunto"
    let arr_aux = 1

    #--------------------------------------------------------
    # Carrega os Assuntos que tem Permissao
    #--------------------------------------------------------

    open ccty40g00004  using  lr_retorno.chave
    foreach ccty40g00004 into mr_permitido[arr_aux].c24astcod
         let arr_aux = arr_aux + 1
    end foreach


end function

#----------------------------------------------#
 function cty40g00_valida_assunto(lr_param)
#----------------------------------------------#

define lr_param record
	c24astcod    like datkassunto.c24astcod
end record

define arr_aux smallint

    for  arr_aux  =  1  to  500

    	   if mr_permitido[arr_aux].c24astcod is null or
    	   	  mr_permitido[arr_aux].c24astcod = " "   then
    	   	  	return false
    	   end if

         if  mr_permitido[arr_aux].c24astcod = lr_param.c24astcod then
        	  return true
         end if
    end  for

    return false


end function

#--------------------------------------------------#
 function cty40g00_grava_historico_ligacao(lr_param)
#--------------------------------------------------#

define lr_param record
	lignum     like datmlighist.lignum
end record

define lr_retorno record
	  c24ligdsc   like datmlighist.c24ligdsc ,
	  ligdat      like datmservico.atddat    ,
	  lighor      like datmservico.atdhor    ,
	  time        char(11)                   ,
	  resultado   integer                    ,
	  mensagem    char(50)
end record

    initialize lr_retorno.* to null

    if mr_param.envio then

    	   #--------------------------------------------------------
    	   # Recupera a Mensagem a Ser Enviada
    	   #--------------------------------------------------------

    	   call cty40g00_msg_historico()
    	   returning lr_retorno.c24ligdsc

    	   let lr_retorno.time   = time
    	   let lr_retorno.lighor = lr_retorno.time[1,5]
    	   let lr_retorno.ligdat = today

    	   #--------------------------------------------------------
    	   # Grava no Historico da Ligacao
    	   #--------------------------------------------------------

         call ctd06g01_ins_datmlighist(lr_param.lignum        ,
                                  g_issk.funmat          ,
                                  lr_retorno.c24ligdsc   ,
                                  lr_retorno.ligdat      ,
                                  lr_retorno.lighor      ,
                                  g_issk.usrtip          ,
                                  g_issk.empcod          )
    returning lr_retorno.resultado ,
              lr_retorno.mensagem


    end if



end function

#----------------------------------------------#
 function cty40g00_msg_historico()
#----------------------------------------------#

define lr_retorno record
	c24ligdsc      like datmlighist.c24ligdsc
end record

initialize lr_retorno.* to null


    let lr_retorno.c24ligdsc = "Protocolo de Atendimento Enviado via SMS para o Telefone :", mr_param.dddtel using "&&","-",
                                                                                             mr_param.numtel using "<&&&&&&&&"


    return lr_retorno.c24ligdsc


end function


#--------------------------------------------------#
 function cty40g00_grava_historico_servico(lr_param)
#--------------------------------------------------#

define lr_param record
	atdsrvnum      like datmservhist.atdsrvnum ,
	atdsrvano      like datmservhist.atdsrvano ,
	canal          smallint
end record

define lr_retorno record
	  c24srvdsc   like datmservhist.c24srvdsc ,
	  ligdat      like datmservico.atddat     ,
	  lighor      like datmservico.atdhor     ,
	  c24txtseq   like datmservhist.c24txtseq ,
	  time        char(11)                    ,
	  resultado   integer                     ,
	  mensagem    char(50)
end record

    initialize lr_retorno.* to null

    if mr_param.envio then

         #--------------------------------------------------------
         # Canal Historico do Servico
         #--------------------------------------------------------

    	   if lr_param.canal = 1 then

    	       #--------------------------------------------------------
    	       # Buscar a Ultima Sequencia da Ligacao
    	       #--------------------------------------------------------

             call ctd07g01_ult_seq_datmservhist(lr_param.atdsrvnum,
                                                lr_param.atdsrvano)
             returning lr_retorno.resultado ,
                       lr_retorno.mensagem  ,
                       lr_retorno.c24txtseq

         end if

         #--------------------------------------------------------
         # Canal Reenvio do SMS
         #--------------------------------------------------------

         if lr_param.canal = 2 then
         	  let lr_retorno.resultado = 2
         end if

         if lr_retorno.resultado = 2 then


    	       #--------------------------------------------------------
    	       # Recupera a Mensagem a Ser Enviada
    	       #--------------------------------------------------------

    	       call cty40g00_msg_historico()
    	       returning lr_retorno.c24srvdsc

    	       let lr_retorno.time   = time
    	       let lr_retorno.lighor = lr_retorno.time[1,5]
    	       let lr_retorno.ligdat = today


    	       #--------------------------------------------------------
    	       # Grava no Historico do Servico
    	       #--------------------------------------------------------

    	       call ctd07g01_ins_datmservhist(lr_param.atdsrvnum   ,
    	                                      lr_param.atdsrvano   ,
    	                                      g_issk.funmat        ,
    	                                      lr_retorno.c24srvdsc ,
    	                                      lr_retorno.ligdat    ,
    	                                      lr_retorno.lighor    ,
    	                                      g_issk.empcod        ,
    	                                      g_issk.usrtip)
    	       returning lr_retorno.resultado ,
                       lr_retorno.mensagem

    	   end if

    end if


end function


#--------------------------------------------------#
 function cty40g00_grava_historico(lr_param)
#--------------------------------------------------#

define lr_param record
	atdsrvnum      like datmservhist.atdsrvnum ,
	atdsrvano      like datmservhist.atdsrvano ,
	lignum         like datmlighist.lignum
end record


    if lr_param.atdsrvnum is not null and
    	 lr_param.atdsrvano is not null then

       call cty40g00_grava_historico_servico(lr_param.atdsrvnum,
                                             lr_param.atdsrvano,
                                             2                 )

    else
    	 call cty40g00_grava_historico_ligacao(lr_param.lignum)
    end if


end function