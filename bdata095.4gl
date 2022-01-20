#==============================================================================#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : bdata095                                                     #
# Analista Resp : Ligia Mattge                                                 #
# PSI           : 202206                                                       #
# OSF           : Gera arquivo .xls com as ligacoes da Azul Seguros do dia     #
#                 anterior e envia por email.                                  #
# .............................................................................#
# Desenvolvimento : Ligia Mattge                                               #
# Liberacao       : 17/01/2007                                                 #
#..............................................................................#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 17/08/2007 Saulo, Meta       AS146056   Inclusao da funcao fun_dba_abre_banco#
#------------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297              Alteração da utilização do sendmail  #
################################################################################

database porto

define m_data date, m_arq, m_dir char(100), m_hora datetime hour to second,
       m_rel smallint
globals
   define g_ismqconn smallint
end globals

main
   call fun_dba_abre_banco('CT24HS')
   let m_arq = null
   let m_dir = null
   let m_hora = null
   let m_rel = false

   let m_data = today - 1

   whenever error continue

   call bdata095_cria_temp()

   call bdata095_com_apolice()

   call bdata095_com_matricula()

   call bdata095_com_telefone()

   call bdata095_com_cgccpf()

   call bdata095_gera()

   call bdata095_envia_email()

end main

function bdata095_cria_temp()

   create temp table bdata095_tmp
          (  c24astcod  char(3),
             c24astdes  char(40),
             ligdat     date,
             lighorinc  datetime hour to minute,
             c24solnom  char(15),
             succod     dec(2),
             aplnumdig  dec(9),
             itmnumdig  dec(7),
             funmat     dec(6),
             funnom     char(20),
             dddcod     char(4),
             telreg     char(20),
             cgccpfnum  dec(12),
             cgcord     dec(4),
             cgccpfdig  dec(2),
             nomeseg    char(50),
             telseg     char(20),
             atdsrvnum  dec(10),
             atdsrvano  dec(2),
             matatend   dec(6),
             nomatend   char(20))

end function

function bdata095_com_apolice()

   define bdata095     record
          c24astcod  like datmligacao.c24astcod,
          c24astdes  like datkassunto. c24astdes,
          ligdat     like datmligacao.ligdat,
          lighorinc  like datmligacao.lighorinc,
          c24solnom  like datmligacao.c24solnom,
          succod     like datrligapol.succod,
          aplnumdig  like datrligapol.aplnumdig,
          itmnumdig  like datrligapol.itmnumdig,
          edsnumdig  like datrligapol.edsnumref,
          atdsrvnum  like datmservico.atdsrvnum,
          atdsrvano  like datmservico.atdsrvano,
          c24funmat  like datmligacao.c24funmat
          end record

   define res integer, msg char(40), doc_handle integer , tel char(40)
   define seg record
          nome        char(60),
          cgccpf      char(15),
          pessoa      char(01),
          dddfone     char(05),
          numfone     char(15),
          email       char(100)
          end record

    define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        funnom         like isskfunc.funnom
    end record


   initialize bdata095.* to null
   initialize seg.* to null
   initialize lr_retorno.* to null

   let res = null
   let msg = null
   let doc_handle = null
   let tel = null

   let m_hora = current
   display 'Gerando os atendimentos com apolice ', m_hora

   declare cur1 cursor for
      select a.c24astcod ass, b.c24astdes d,
             a.ligdat dat, a.lighorinc hor, a.c24solnom,
             c.succod suc, c.aplnumdig apl, c.itmnumdig it,
             c.edsnumref eds,
             d.atdsrvnum, d.atdsrvano,
             a.c24funmat
      from datmligacao a, datkassunto b, outer datmservico d, datrligapol c
      where a.c24astcod = b.c24astcod
      and a.lignum = c.lignum
      and a.atdsrvano  = d.atdsrvano
      and b.c24astagp <> '8'
      and a.atdsrvnum = d.atdsrvnum
      and a.ciaempcod = 35
      and d.ciaempcod = 35
      and a.c24astcod not in("CON","ALT","CAN")
      and a.ligdat = m_data
      order by 3,4,1

   foreach cur1 into bdata095.*

           let res = null
           let msg = null
           let doc_handle = null
           initialize seg.* to null

           if bdata095.aplnumdig is not null then
              call  cts42g00_doc_handle(bdata095.succod, 531,
                                        bdata095.aplnumdig,
                                        bdata095.itmnumdig,
                                        bdata095.edsnumdig)
                    returning res, msg, doc_handle

              if doc_handle is null then
                 display 'Nao achou doc_handle p/apolice: ',
                         bdata095.succod, bdata095.aplnumdig, bdata095.itmnumdig
                 continue foreach
              end if

              call cts40g02_extraiDoXML(doc_handle, "SEGURADO")
                   returning seg.*
              let tel = seg.dddfone clipped, ' ', seg.numfone
           end if

           initialize lr_retorno.* to null
           call cty08g00_nome_func(1,bdata095.c24funmat,"F")
                returning lr_retorno.*

           insert into bdata095_tmp values
                  ( bdata095.c24astcod, bdata095.c24astdes,
                    bdata095.ligdat,    bdata095.lighorinc,
                    bdata095.c24solnom, bdata095.succod,
                    bdata095.aplnumdig, bdata095.itmnumdig,
                    "","","","","","","", seg.nome, tel,
                    bdata095.atdsrvnum, bdata095.atdsrvano,
                    bdata095.c24funmat, lr_retorno.funnom)

   end foreach

end function

function bdata095_com_matricula()

   define bdata095   record
          c24astcod  like datmligacao.c24astcod,
          c24astdes  like datkassunto. c24astdes,
          ligdat     like datmligacao.ligdat,
          lighorinc  like datmligacao.lighorinc,
          c24solnom  like datmligacao.c24solnom,
          atdsrvnum  like datmservico.atdsrvnum,
          atdsrvano  like datmservico.atdsrvano,
          funmat     like isskfunc.funmat,
          funnom     like isskfunc.funnom,
          c24funmat  like datmligacao.c24funmat
          end record

    define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        funnom         like isskfunc.funnom
    end record

   initialize bdata095.* to null
   initialize lr_retorno.* to null

   let m_hora = current
   display 'Gerando os atendimentos com matricula do solicitante ', m_hora

   declare cur2 cursor for
           select unique a.c24astcod ast, b.c24astdes des,
                  a.ligdat dat, a.lighorinc hor, a.c24solnom,
                  c.atdsrvnum srv, c.atdsrvano ano,
                  d.funmat, funnom, a.c24funmat
                  from datmligacao a,
                       datkassunto b,
                       outer datmservico c,
                       datrligmat d,
                       isskfunc e
                  where a.c24astcod = b.c24astcod
                  and b.c24astagp <> '8'
                  and a.atdsrvano  = c.atdsrvano
                  and a.atdsrvnum = c.atdsrvnum
                  and a.lignum = d.lignum
                  and a.ligdat = m_data
                  and d.funmat = e.funmat
                  and e.empcod = d.empcod
                  and a.ciaempcod = 35
                  and c.ciaempcod = 35
                  and a.c24astcod not in("CON","ALT","CAN")
                  order by 3,4,1

   foreach cur2 into bdata095.*

           initialize lr_retorno.* to null
           call cty08g00_nome_func(1,bdata095.c24funmat,"F")
                returning lr_retorno.*

           insert into bdata095_tmp values
                  ( bdata095.c24astcod, bdata095.c24astdes,
                    bdata095.ligdat,    bdata095.lighorinc,
                    bdata095.c24solnom, "", "","",
                    bdata095.funmat, bdata095.funnom,
                    "","","","","","","",
                    bdata095.atdsrvnum, bdata095.atdsrvano,
                    bdata095.c24funmat, lr_retorno.funnom)

   end foreach

end function

function bdata095_com_telefone()

   define bdata095   record
          c24astcod  like datmligacao.c24astcod,
          c24astdes  like datkassunto. c24astdes,
          ligdat     like datmligacao.ligdat,
          lighorinc  like datmligacao.lighorinc,
          c24solnom  like datmligacao.c24solnom,
          atdsrvnum  like datmservico.atdsrvnum,
          atdsrvano  like datmservico.atdsrvano,
          dddcod     like datrligtel.dddcod,
          teltxt     like datrligtel.teltxt,
          c24funmat  like datmligacao.c24funmat
          end record

    define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        funnom         like isskfunc.funnom
    end record

   initialize bdata095.* to null
   initialize lr_retorno.* to null

   let m_hora = current
   display 'Gerando os atendimentos com telefone do solicitante ', m_hora

   declare cur3 cursor for
           select unique a.c24astcod ass, b.c24astdes d,
                  a.ligdat dat, a.lighorinc hor, a.c24solnom,
                  c.atdsrvnum, c.atdsrvano,
                  d.dddcod, d.teltxt, a.c24funmat
                 from datmligacao a,
                      datkassunto b,
                      outer datmservico c,
                      datrligtel d
                 where a.c24astcod = b.c24astcod
                 and b.c24astagp <> '8'
                 and a.atdsrvano  = c.atdsrvano
                 and a.atdsrvnum = c.atdsrvnum
                 and a.lignum = d.lignum
                 and a.ligdat = m_data
                 and a.ciaempcod = 35
                 and c.ciaempcod = 35
                 and a.c24astcod not in("CON","ALT","CAN")
                 order by 3,4,1

   foreach cur3 into bdata095.*

           initialize lr_retorno.* to null
           call cty08g00_nome_func(1,bdata095.c24funmat,"F")
                returning lr_retorno.*

           insert into bdata095_tmp values
                  ( bdata095.c24astcod, bdata095.c24astdes,
                    bdata095.ligdat,    bdata095.lighorinc,
                    bdata095.c24solnom, "", "","",
                    "","", bdata095.dddcod, bdata095.teltxt,
                    "","","","","",
                    bdata095.atdsrvnum, bdata095.atdsrvano,
                    bdata095.c24funmat, lr_retorno.funnom)

   end foreach

end function

function bdata095_com_cgccpf()

   define bdata095   record
          c24astcod  like datmligacao.c24astcod,
          c24astdes  like datkassunto. c24astdes,
          ligdat     like datmligacao.ligdat,
          lighorinc  like datmligacao.lighorinc,
          c24solnom  like datmligacao.c24solnom,
          atdsrvnum  like datmservico.atdsrvnum,
          atdsrvano  like datmservico.atdsrvano,
          cgccpfnum  like datrligcgccpf.cgccpfnum,
          cgcord     like datrligcgccpf.cgcord,
          cgccpfdig  like datrligcgccpf.cgccpfdig,
          c24funmat  like datmligacao.c24funmat
          end record

    define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        funnom         like isskfunc.funnom
    end record

   initialize bdata095.* to null
   initialize lr_retorno.* to null

   let m_hora = current
   display 'Gerando os atendimentos com cgc/cpf do solicitante ', m_hora

   declare cur4 cursor for
           select unique a.c24astcod ass, b.c24astdes d,
                  a.ligdat dat, a.lighorinc hor, a.c24solnom,
                  c.atdsrvnum, c.atdsrvano,
                  d.cgccpfnum, d.cgcord, d.cgccpfdig, a.c24funmat
                  from datmligacao a,
                       datkassunto b,
                       outer datmservico c,
                       datrligcgccpf d
                  where a.c24astcod = b.c24astcod
                  and b.c24astagp <> '8'
                  and a.atdsrvano  = c.atdsrvano
                  and a.atdsrvnum = c.atdsrvnum
                  and a.lignum = d.lignum
                  and a.ligdat = m_data
                  and a.ciaempcod = 35
                  and c.ciaempcod = 35
                  and a.c24astcod not in("CON","ALT","CAN")
                  order by 3,4,1

   foreach cur4 into bdata095.*

           initialize lr_retorno.* to null
           call cty08g00_nome_func(1,bdata095.c24funmat,"F")
                returning lr_retorno.*

           insert into bdata095_tmp values
                  ( bdata095.c24astcod, bdata095.c24astdes,
                    bdata095.ligdat,    bdata095.lighorinc,
                    bdata095.c24solnom, "", "","", "","","","",
                    bdata095.cgccpfnum, bdata095.cgcord, bdata095.cgccpfdig,
                    "","", bdata095.atdsrvnum, bdata095.atdsrvano,
                    bdata095.c24funmat, lr_retorno.funnom)

   end foreach

end function

function bdata095_gera()

   define bdata095 record
          c24astcod  char(3),
          c24astdes  char(40),
          ligdat     date,
          lighorinc  datetime hour to minute,
          c24solnom  char(15),
          succod     dec(2),
          aplnumdig  dec(9),
          itmnumdig  dec(7),
          funmat     dec(6),
          funnom     char(20),
          dddcod     char(4),
          telreg     char(20),
          cgccpfnum  dec(12),
          cgcord     dec(4),
          cgccpfdig  dec(2),
          nomeseg    char(50),
          telseg     char(20),
          atdsrvnum  dec(10),
          atdsrvano  dec(2),
          matatend   dec(6),
          nomatend   char(20)
   end record

   call f_path("DAT", "ARQUIVO") returning m_dir

   if m_dir is null then
      let m_dir = '.'
   end if

   let m_arq  = m_dir clipped, "/ADAT095001.xls"

   let m_hora = current
   display 'Gerando o arquivo ', m_arq clipped, ' ', m_hora

   start report r_bdata095 to m_arq

   declare cur5 cursor for
           select * from bdata095_tmp
                order by ligdat, lighorinc, c24astcod

   foreach cur5 into bdata095.*
      output to report r_bdata095 (bdata095.*)
      let m_rel = true
   end foreach

   finish report r_bdata095

end function


report r_bdata095(r_bdata095)

   define r_bdata095 record
          c24astcod  char(3),
          c24astdes  char(40),
          ligdat     date,
          lighorinc  datetime hour to minute,
          c24solnom  char(15),
          succod     dec(2),
          aplnumdig  dec(9),
          itmnumdig  dec(7),
          funmat     dec(6),
          funnom     char(20),
          dddcod     char(4),
          telreg     char(20),
          cgccpfnum  dec(12),
          cgcord     dec(4),
          cgccpfdig  dec(2),
          nomeseg    char(50),
          telseg     char(20),
          atdsrvnum  dec(10),
          atdsrvano  dec(2),
          matatend   dec(6),
          nomatend   char(20)
   end record

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   format
     first page header

        print "ASSUNTO",             ASCII(09),
              "DESCRICAO",           ASCII(09),
              "DATA ATEND",          ASCII(09),
              "HORA ATEND",          ASCII(09),
              "SOLICITANTE",         ASCII(09),
              "SUCURSAL",            ASCII(09),
              "APOLICE",             ASCII(09),
              "ITEM",                ASCII(09),
              "MATR FUNCIONARIO",    ASCII(09),
              "NOME FUNCIONARIO",    ASCII(09),
              "DDD REGISTRO",        ASCII(09),
              "TEL REGISTRO",        ASCII(09),
              "CGC/CPF SOLICITANTE", ASCII(09),
              "ORDEM CGC",           ASCII(09),
              "DIGITO CGC/CPF",      ASCII(09),
              "SEGURADO",            ASCII(09),
              "TEL SEGURADO",        ASCII(09),
              "SERVICO",             ASCII(09),
              "ANO",                 ASCII(09),
              "MATR ATENDENTE",      ASCII(09),
              "NOME ATENDENTE"

     on every row
           print r_bdata095.c24astcod,  ASCII(09),
                 r_bdata095.c24astdes,  ASCII(09),
                 r_bdata095.ligdat,     ASCII(09),
                 r_bdata095.lighorinc,  ASCII(09),
                 r_bdata095.c24solnom,  ASCII(09),
                 r_bdata095.succod,     ASCII(09),
                 r_bdata095.aplnumdig,  ASCII(09),
                 r_bdata095.itmnumdig,  ASCII(09),
                 r_bdata095.funmat,     ASCII(09),
                 r_bdata095.funnom,     ASCII(09),
                 r_bdata095.dddcod,     ASCII(09),
                 r_bdata095.telreg,     ASCII(09),
                 r_bdata095.cgccpfnum,  ASCII(09),
                 r_bdata095.cgcord,     ASCII(09),
                 r_bdata095.cgccpfdig,  ASCII(09),
                 r_bdata095.nomeseg,    ASCII(09),
                 r_bdata095.telseg,     ASCII(09),
                 r_bdata095.atdsrvnum,  ASCII(09),
                 r_bdata095.atdsrvano,  ASCII(09),
                 r_bdata095.matatend,   ASCII(09),
                 r_bdata095.nomatend
end report

function bdata095_envia_email()

  define lr_mens        record
         sistema        char(10)
        ,remet          char(50)
        ,para           char(1000)
        ,cc             char(400)
        ,msg            char(400)
        ,subject        char(400)
  end record

  define  l_mail             record
          de                 char(500)   # De
         ,para               char(5000)  # Para
         ,cc                 char(500)   # cc
         ,cco                char(500)   # cco
         ,assunto            char(500)   # Assunto do e-mail
         ,mensagem           char(32766) # Nome do Anexo
         ,id_remetente       char(20)
         ,tipo               char(4)     #
  end  record
  define l_assunto char(100)
        ,l_cmd     char(500)
        ,l_ret     smallint
        ,l_des     char(50)
        ,l_erro    char(500)

  initialize l_mail.* to null
  let l_cmd = null
  let l_ret = null
  let l_des = null
  let l_assunto = null

  let l_assunto = 'Atendimentos da Azul Seguros'

  let l_mail.de = "EmailCorr.ct24hs"
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = l_assunto
  let l_mail.mensagem = "<html><body><font face = Times New Roman>Atendimento da Azul Seguros"
                       ,"<br><br></font></body></html>"
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "html"

  declare cur6 cursor for
          select cpodes, cpocod from iddkdominio
                 where cponom = 'Azul'
                 order by 2

  foreach cur6 into l_des
          if lr_mens.para is null then
             let lr_mens.para = l_des
          else
             let lr_mens.para = lr_mens.para  clipped, ',', l_des
          end if
  end foreach

  display 'Enviando e-mail para: ', l_mail.para  clipped

  display "Arquivo: ",m_arq

  if m_rel = true then
     call figrc009_attach_file(m_arq)
  else
     let l_mail.mensagem = "Nao existem registros a serem processados."
  end if

  display "Arquivo anexado com sucesso"
  call figrc009_mail_send1 (l_mail.*)
     returning l_ret, l_erro

  let m_hora = current

  if l_ret = 0  then
     let l_assunto = 'Email ', l_assunto clipped,' enviado com sucesso ', m_hora
  else
     let l_assunto = 'Email ', l_assunto clipped,' nao enviado ', m_hora
  end if

  display l_assunto

end function

