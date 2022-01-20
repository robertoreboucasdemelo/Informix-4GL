#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: ctx34g01                                                   #
# ANALISTA RESP..: Beatriz Araujo                                             #
# PSI/OSF........: PSI-2011-0258628/PR                                        #
# DATA...........: 15/07/2011                                                 #
# OBJETIVO.......: Criar uma inferface unica de atualizacao do historico do   #
#                  serivco na base do Oracle do Novo Acionamento              #
# Observacoes:                                                                #
# ........................................................................... #
#                        * * * Alteracoes * * *                               #
#                                                                             #
#    Data      Autor Fabrica    Origem      Alteracao                         #
#  ----------  -------------    ---------   --------------------------------  #
#                                                                             #
#  25/11/2015  Eliane K, Fornax Ch 736094   Inserir close para cada open      #
#                                                    cursor                   #
#-----------------------------------------------------------------------------#

database porto

define m_ctx34g01_prep smallint

#------------------------------------------#
function ctx34g01_prepare ()
#------------------------------------------#

define l_sql char(6000)

   let l_sql  =	"select atdsrvnum,    ",
                "       c24txtseq,    ",
                "       atdsrvano,    ",
                "       c24funmat,    ",
                "       c24srvdsc,    ",
                "       ligdat,       ",
                "       lighorinc,    ",
                "       c24empcod,    ",
                "       c24usrtip     ",
                "  from datmservhist  ",
                " where atdsrvnum = ? ",
                "   and atdsrvano = ? ",
                "   and c24txtseq = (select max(c24txtseq) ",
                "                      from datmservhist   ",
                "                     where atdsrvnum = ?  ",
                "                       and atdsrvano = ? )"
  prepare p_ctx34g01_001 from l_sql
  declare c_ctx34g01_001 cursor for p_ctx34g01_001


   let l_sql  =	"select datmservhist.c24txtseq,",
                "       datmservhist.ligdat,   ",
                "       datmservhist.lighorinc,",
                "       datmservhist.c24srvdsc,",
                "       datmservhist.c24funmat,",
                "       datmservhist.c24empcod,",
                "       datmservhist.c24usrtip ",
                "  from datmservhist, datmservhist hstseq",
                " where datmservhist.atdsrvnum = hstseq.atdsrvnum",
                "   and datmservhist.atdsrvano = hstseq.atdsrvano",
                "   and datmservhist.ligdat    = hstseq.ligdat",
                "   and datmservhist.lighorinc = hstseq.lighorinc",
                "   and hstseq.atdsrvnum = ? ",
                "   and hstseq.atdsrvano = ? ",
                "   and hstseq.c24txtseq = ? ",
                " order by datmservhist.c24txtseq"
  prepare p_ctx34g01_002 from l_sql
  declare c_ctx34g01_002 cursor for p_ctx34g01_002


  let l_sql  =	"select c24srvdsc    ",
                "  from datmservhist ",
                " where atdsrvnum = ?",
                "   and atdsrvano = ?",
                "   and ligdat = ?   ",
                "   and lighorinc = ?"
  prepare p_ctx34g01_003 from l_sql
  declare c_ctx34g01_003 cursor for p_ctx34g01_003

   let l_sql  =	"select c24txtseq,    ",
                "       ligdat,       ",
                "       lighorinc,    ",
                "       c24srvdsc,    ",
                "       c24funmat,    ",
                "       c24empcod,    ",
                "       c24usrtip     ",
                "  from datmservhist  ",
                " where atdsrvnum = ? ",
                "   and atdsrvano = ? ",
                " order by ligdat, lighorinc, c24funmat, c24empcod, c24usrtip, c24txtseq "
  prepare p_ctx34g01_004 from l_sql
  declare c_ctx34g01_004 cursor for p_ctx34g01_004

  let m_ctx34g01_prep = true

end function

#------------------------------------------#
function ctx34g01_apos_grvhistorico(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservhist.atdsrvnum,
   atdsrvano like datmservhist.atdsrvano,
   c24txtseq like datmservhist.c24txtseq,
   tipoEnvio smallint # 1- insert da ultima sequencia  2- update da sequencia
end record

 define l_xml record
    response char(32766),
    request  char(32766)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint
 define l_relpamtxt  like igbmparam.relpamtxt

 initialize l_xml.* to null

 if not m_ctx34g01_prep then
    call ctx34g01_prepare()
 end if

 if ctx34g00_NovoAcionamento() and
    ctx34g00_origem(param.atdsrvnum,param.atdsrvano)  and
    param.atdsrvnum > 0 and
    param.atdsrvnum is not null then

    #---------------------------------------------
    # Verifica se eh alteracao ou inclusao
    #---------------------------------------------

    case param.tipoEnvio
       when 1
          let l_xml.request = ctx34g01_novoHistorico(param.atdsrvnum,param.atdsrvano)
       when 2
          let l_xml.request = ctx34g01_altHistorico(param.atdsrvnum,param.atdsrvano,param.c24txtseq)
    end case

    if l_xml.request is not null and l_xml.request <> " "  then

       call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                        returning l_status,
                                  l_msg,
                                  l_xml.response

       if l_status <> 0 then

          let l_msg = "SRV_", param.atdsrvnum using "&&&&&&&", " ", l_msg clipped

          call ctx34g02_email_erro(l_xml.request,
                                   l_xml.response,
                                   "ERRO NO MQ - ctx34g01_apos_grvhistorico",
                                   l_msg)

          # Grava informacao para reprocessamento batch
          let l_relpamtxt = param.atdsrvnum using "#######", "|", param.atdsrvano using "##", "|", param.c24txtseq using "#####", "|", param.tipoEnvio using "#"
          call ctx34g00_grava_mq_AW_batch(3, l_relpamtxt)

       else
          if l_xml.response like "%<retorno><codigo>1</codigo>%" then
             if not l_xml.response like "%Servico %nao existe%" then
                call ctx34g02_email_erro(l_xml.request,
                                         l_xml.response,
                                         "ERRO NO SERVICO - ctx34g01_apos_grvhistorico",
                                         "")

                # Grava informacao para reprocessamento batch
                let l_relpamtxt = param.atdsrvnum using "#######", "|", param.atdsrvano using "##", "|", param.c24txtseq using "#####", "|", param.tipoEnvio using "#"
                call ctx34g00_grava_mq_AW_batch(3, l_relpamtxt)

             end if
          end if
       end if
    end if
 end if

end function

# busca todos os dados para realizar a inclusao e monta o XML
#------------------------------------------#
function ctx34g01_novoHistorico(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservhist.atdsrvnum,
   atdsrvano like datmservhist.atdsrvano
end record

define ctx34g01_hist record
   atdsrvnum   like datmservhist.atdsrvnum,
   c24txtseq   like datmservhist.c24txtseq,
   atdsrvano   like datmservhist.atdsrvano,
   c24funmat   like datmservhist.c24funmat,
   c24srvdsc   like datmservhist.c24srvdsc,
   ligdat      like datmservhist.ligdat   ,
   lighorinc   like datmservhist.lighorinc,
   c24empcod   like datmservhist.c24empcod,
   c24usrtip   like datmservhist.c24usrtip
  end record

  define l_xml record
      request char(32766)
   end record

  define texto char(20000)

 initialize ctx34g01_hist.* to null
 initialize l_xml.* to null
 let texto = null


whenever error continue
  open c_ctx34g01_001 using param.atdsrvnum,
                            param.atdsrvano,
                            param.atdsrvnum,
                            param.atdsrvano

  fetch c_ctx34g01_001  into  ctx34g01_hist.atdsrvnum,
                              ctx34g01_hist.c24txtseq,
                              ctx34g01_hist.atdsrvano,
                              ctx34g01_hist.c24funmat,
                              ctx34g01_hist.c24srvdsc,
                              ctx34g01_hist.ligdat   ,
                              ctx34g01_hist.lighorinc,
                              ctx34g01_hist.c24empcod,
                              ctx34g01_hist.c24usrtip

          open c_ctx34g01_003 using param.atdsrvnum,
                                    param.atdsrvano,
                                    ctx34g01_hist.ligdat,
                                    ctx34g01_hist.lighorinc

          foreach c_ctx34g01_003 into ctx34g01_hist.c24srvdsc

             let ctx34g01_hist.c24srvdsc = figrc005_conv_acento(ctx34g01_hist.c24srvdsc,1,7)

             if texto is null or texto = ' ' then
                let texto = ctx34g01_hist.c24srvdsc clipped
             else
                let texto = texto clipped,'<br>',ctx34g01_hist.c24srvdsc clipped
             end if

          end foreach

  close c_ctx34g01_001   # Ch. 736094
  close c_ctx34g01_003   # Ch. 736094

  if texto is not null and texto <> ' ' then
     let l_xml.request = ctx34g01_geraXML(ctx34g01_hist.atdsrvnum,
                                          ctx34g01_hist.atdsrvano,
                                          ctx34g01_hist.c24funmat,
                                          texto,
                                          ctx34g01_hist.ligdat   ,
                                          ctx34g01_hist.lighorinc,
                                          ctx34g01_hist.c24empcod,
                                          ctx34g01_hist.c24usrtip,
                                          "S")
  end if

  whenever error stop

  return l_xml.request

end function


# busca todos os dados para realizar a alteracao e monta o XML
#------------------------------------------#
function ctx34g01_altHistorico(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservhist.atdsrvnum,
   atdsrvano like datmservhist.atdsrvano,
   c24txtseq like datmservhist.c24txtseq
end record

define ctx34g01_hist record
   atdsrvnum   like datmservhist.atdsrvnum,
   c24txtseq   like datmservhist.c24txtseq,
   atdsrvano   like datmservhist.atdsrvano,
   c24funmat   like datmservhist.c24funmat,
   c24srvdsc   like datmservhist.c24srvdsc,
   ligdat      like datmservhist.ligdat   ,
   lighorinc   like datmservhist.lighorinc,
   c24empcod   like datmservhist.c24empcod,
   c24usrtip   like datmservhist.c24usrtip
  end record

  define l_xml record
      request char(10000)
  end record

  define l_c24srvdsc char(5000)

 initialize ctx34g01_hist.* to null
 initialize l_xml.* to null
 initialize l_c24srvdsc to null

whenever error continue
  open c_ctx34g01_002 using param.atdsrvnum,
                            param.atdsrvano,
                            param.c24txtseq

  foreach c_ctx34g01_002 into ctx34g01_hist.c24txtseq,
                              ctx34g01_hist.ligdat   ,
                              ctx34g01_hist.lighorinc,
                              ctx34g01_hist.c24srvdsc,
                              ctx34g01_hist.c24funmat,
                              ctx34g01_hist.c24empcod,
                              ctx34g01_hist.c24usrtip

      let ctx34g01_hist.c24srvdsc = figrc005_conv_acento(ctx34g01_hist.c24srvdsc,1,7)

      if l_c24srvdsc is null or l_c24srvdsc = ' ' then
         let l_c24srvdsc = ctx34g01_hist.c24srvdsc
      else
         let l_c24srvdsc = l_c24srvdsc clipped, '<br>', ctx34g01_hist.c24srvdsc
      end if

  end foreach

  close c_ctx34g01_002  # Ch. 736094

  if l_c24srvdsc is not null and l_c24srvdsc <> ' ' then
     let l_xml.request = ctx34g01_geraXML(param.atdsrvnum,
                                          param.atdsrvano,
                                          ctx34g01_hist.c24funmat,
                                          l_c24srvdsc,
                                          ctx34g01_hist.ligdat,
                                          ctx34g01_hist.lighorinc,
                                          ctx34g01_hist.c24empcod,
                                          ctx34g01_hist.c24usrtip,
                                          "S")
  end if

  whenever error stop

  return l_xml.request
end function

#------------------------------------------#
function ctx34g01_geraXML(param)
#------------------------------------------#

define param record
   atdsrvnum   like datmservhist.atdsrvnum,
   atdsrvano   like datmservhist.atdsrvano,
   c24funmat   like datmservhist.c24funmat,
   texto       char(20000),
   ligdat      like datmservhist.ligdat   ,
   lighorinc   like datmservhist.lighorinc,
   c24empcod   like datmservhist.c24empcod,
   c24usrtip   like datmservhist.c24usrtip,
   flgxmlcmp    char(1)                    # flag para gerar xml completo
  end record

  define l_hor_ligdat   char(50)

  define l_xml record
      request char(32766)
   end record

 initialize l_xml.* to null
 initialize l_hor_ligdat to null

 let l_hor_ligdat = param.ligdat clipped,' ',param.lighorinc

 let l_xml.request = '<ServicoHistorico>',
                        '<DataAtualizacao>',l_hor_ligdat clipped,'</DataAtualizacao>',
                        '<UsuarioAtualizacao>',
                           '<Matricula>',param.c24funmat using "<<<<<<&", '</Matricula>',
                           '<Empresa>',param.c24empcod using "<<<&", '</Empresa>',
                           '<TipoUsuario>',param.c24usrtip,'</TipoUsuario>',
                        '</UsuarioAtualizacao>',
                        '<TextoHistorico><![CDATA[', param.texto clipped,']]></TextoHistorico>',
                     '</ServicoHistorico>'

 if param.flgxmlcmp == 'S' then
    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST>',
                           '<SERVICO>ATUALIZACAO_HISTORICO</SERVICO>',
                           '<OBJETOS>',
                              '<ServicoCentral>',
                              '<NumeroServicoAtendimento>',param.atdsrvnum using "<<<<<<&", '</NumeroServicoAtendimento>',
                              '<AnoServicoAtendimento>',param.atdsrvano using "<&", '</AnoServicoAtendimento>',
                              '</ServicoCentral>',
                              '<Historico>', l_xml.request clipped, '</Historico>',
                           '</OBJETOS>',
                        '</REQUEST>'
 end if

 return l_xml.request

end function

# busca todos os dados para realizar a inclusao e monta o XML
#------------------------------------------#
function ctx34g01_xmlHistoricos(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservhist.atdsrvnum,
   atdsrvano like datmservhist.atdsrvano
end record

define ctx34g01_hist record
   c24txtseq   like datmservhist.c24txtseq,
   c24funmat   like datmservhist.c24funmat,
   c24srvdsc   like datmservhist.c24srvdsc,
   ligdat      like datmservhist.ligdat   ,
   lighorinc   like datmservhist.lighorinc,
   c24empcod   like datmservhist.c24empcod,
   c24usrtip   like datmservhist.c24usrtip
  end record

  define l_xml record
      request char(15000)
   end record

  define texto         char(2048),
         textoxml      char(2200),
         ligdat_ant    like datmservhist.ligdat,
         lighorinc_ant like datmservhist.lighorinc,
         c24funmat_ant like datmservhist.c24funmat,
         c24empcod_ant like datmservhist.c24empcod,
         c24usrtip_ant like datmservhist.c24usrtip,
         l_txt_xml     char(15000)

 initialize ctx34g01_hist.* to null
 initialize l_xml.* to null
 initialize texto, textoxml, ligdat_ant, lighorinc_ant
           ,c24funmat_ant, c24empcod_ant, c24usrtip_ant,l_txt_xml  to null

 if not m_ctx34g01_prep then
    call ctx34g01_prepare()
 end if

whenever error continue
  open c_ctx34g01_004 using param.atdsrvnum,
                            param.atdsrvano

  foreach c_ctx34g01_004 into ctx34g01_hist.c24txtseq,
                              ctx34g01_hist.ligdat   ,
                              ctx34g01_hist.lighorinc,
                              ctx34g01_hist.c24srvdsc,
                              ctx34g01_hist.c24funmat,
                              ctx34g01_hist.c24empcod,
                              ctx34g01_hist.c24usrtip

     let ctx34g01_hist.c24srvdsc = figrc005_conv_acento(ctx34g01_hist.c24srvdsc,1,7)
 
     if ligdat_ant is not null then

        if ligdat_ant    <> ctx34g01_hist.ligdat or
        	 lighorinc_ant <> ctx34g01_hist.lighorinc then

           let l_txt_xml =  ctx34g01_geraXML(param.atdsrvnum,
                                             param.atdsrvano,
                                             c24funmat_ant,
                                             texto,
                                             ligdat_ant   ,
                                             lighorinc_ant,
                                             c24empcod_ant,
                                             c24usrtip_ant,
                                             "N")
           if length(l_xml.request) + length(l_txt_xml) < 15000 then
              let l_xml.request = l_xml.request clipped, l_txt_xml
           end if
           let texto = ""
        end if
     end if

     if texto is null then
        let texto = ctx34g01_hist.c24srvdsc clipped
     else
        let texto = texto clipped,'<br>',ctx34g01_hist.c24srvdsc clipped
     end if

     let ligdat_ant = ctx34g01_hist.ligdat
     let lighorinc_ant = ctx34g01_hist.lighorinc
     let c24funmat_ant = ctx34g01_hist.c24funmat
     let c24empcod_ant = ctx34g01_hist.c24empcod
     let c24usrtip_ant = ctx34g01_hist.c24usrtip

  end foreach

  close c_ctx34g01_004   # Ch. 736094

  if texto is not null and texto <> ' ' then
     let l_txt_xml = ctx34g01_geraXML(param.atdsrvnum,
                                      param.atdsrvano,
                                      ctx34g01_hist.c24funmat,
                                      texto,
                                      ctx34g01_hist.ligdat   ,
                                      ctx34g01_hist.lighorinc,
                                      ctx34g01_hist.c24empcod,
                                      ctx34g01_hist.c24usrtip,
                                      "N")

     if length(l_xml.request) + length(l_txt_xml) < 15000 then
        let l_xml.request = l_xml.request clipped, l_txt_xml
     end if
  end if

  whenever error stop

  return l_xml.request

end function


