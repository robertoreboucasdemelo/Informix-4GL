 #############################################################################
 # Nome do Modulo: ctn44c01                                          Marcelo #
 #                                                                  Gilberto #
 # Consulta dados recebidos dos MDT's                               Ago/1999 #
 #---------------------------------------------------------------------------#
 # 17/01/2001  PSI 12338-2  Marcus       Numero de transmissao msgs MDTs     #
 #                                                                           #
 # 02/02/2001  PSI 12337-4  Marcus       Tratar Botoes recebidos fora de     #
 #                                       ordem                               #
 #---------------------------------------------------------------------------#
 # 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32        #
 #                                                                           #
 # 13/07/2007 Ligia Mattge PSI 210838 - retorno param de ctn44c02/ctx25g01   #
 #############################################################################

 database porto

#-----------------------------------------------------------
 function ctn44c01(param)
#-----------------------------------------------------------

 define param          record
    mdtmvtseq          like datmmdtmvt.mdtmvtseq
 end record

 define d_ctn44c01     record
    mdtmvtseq          like datmmdtmvt.mdtmvtseq,
    caddat             like datmmdtmvt.caddat,
    cadhor             like datmmdtmvt.cadhor,
    mdtcod             like datmmdtmvt.mdtcod,
    atdvclsgl          like datkveiculo.atdvclsgl,
    socvclcod          like datkveiculo.socvclcod,
    vcldes             char (45),
    mdtmvttipcod       like datmmdtmvt.mdtmvttipcod,
    mdtmvttipdes       char (30),
    mdtbotprgseq       like datmmdtmvt.mdtbotprgseq,
    mdtbottxt          like datkmdtbot.mdtbottxt,
    mdtmvtdigcnt       like datmmdtmvt.mdtmvtdigcnt,
    ufdcod             like datmmdtmvt.ufdcod,
    cidnom             like datmmdtmvt.cidnom,
    brrnom             like datmmdtmvt.brrnom,
    endzon             like datmmdtmvt.endzon,
    mdtmvtsnlflg       like datmmdtmvt.mdtmvtsnlflg,
    lclltt             like datmmdtmvt.lclltt,
    lcllgt             like datmmdtmvt.lcllgt,
    mdtmvtdircod       like datmmdtmvt.mdtmvtdircod,
    mdtmvtvlc          like datmmdtmvt.mdtmvtvlc,
    mdtmvtstt          like datmmdtmvt.mdtmvtstt,
    mdtmvtsttdes       char (50),
    mdterrcod          like datmmdterr.mdterrcod,
    mdterrdes          char (50),
    mdttrxnum          like datmmdtmvt.mdttrxnum
 end record

 define ws             record
    promptq            char (01),
    vclcoddig          like datkveiculo.vclcoddig
 end record


 define l_resp char(1),
        l_res    smallint,
        l_mens   smallint,
        l_funnom like isskfunc.funnom,
        l_empcod like datmmdtmvt.empcod,
        l_funmat like datmmdtmvt.funmat,
        l_usrtip like datmmdtmvt.usrtip,

        l_msg  record
        msg1   char(40),
        msg2   char(40),
        msg3   char(40),
        msg4   char(40)
        end record

 initialize d_ctn44c01.*  to  null
 initialize ws.*  to  null

 initialize ws.*  to null
 initialize d_ctn44c01.*  to null
 initialize l_msg.*  to null
 let l_resp = null
 let l_empcod = null
 let l_funmat = null
 let l_usrtip = null

 #--------------------------------------------------------------------
 #  Le tabela de movimento dos MDTs
 #--------------------------------------------------------------------
 select caddat      , cadhor      ,
        mdtcod      , mdtmvttipcod,
        mdtbotprgseq, mdtmvtdigcnt,
        ufdcod      , cidnom      ,
        brrnom      , endzon      ,
        lclltt      , lcllgt      ,
        mdtmvtdircod, mdtmvtvlc   ,
        mdtmvtstt   , mdterrcod   ,
        mdtmvtsnlflg, mdttrxnum   , empcod, funmat, usrtip
   into d_ctn44c01.caddat      , d_ctn44c01.cadhor      ,
        d_ctn44c01.mdtcod      , d_ctn44c01.mdtmvttipcod,
        d_ctn44c01.mdtbotprgseq, d_ctn44c01.mdtmvtdigcnt,
        d_ctn44c01.ufdcod      , d_ctn44c01.cidnom      ,
        d_ctn44c01.brrnom      , d_ctn44c01.endzon      ,
        d_ctn44c01.lclltt      , d_ctn44c01.lcllgt      ,
        d_ctn44c01.mdtmvtdircod, d_ctn44c01.mdtmvtvlc   ,
        d_ctn44c01.mdtmvtstt   , d_ctn44c01.mdterrcod   ,
        d_ctn44c01.mdtmvtsnlflg, d_ctn44c01.mdttrxnum   ,
        l_empcod, l_funmat, l_usrtip
   from datmmdtmvt, outer datmmdterr
  where datmmdtmvt.mdtmvtseq  =  param.mdtmvtseq
    and datmmdterr.mdtmvtseq  =  datmmdtmvt.mdtmvtseq


 open window w_ctn44c01 at 06,02 with form "ctn44c01"
             attribute (form line 1)

 select cpodes
   into d_ctn44c01.mdtmvttipdes
   from iddkdominio
  where cponom  =  "mdtmvttipcod"
    and cpocod  =  d_ctn44c01.mdtmvttipcod

 if d_ctn44c01.mdtbotprgseq  is not null   then
    select mdtbottxt
      into d_ctn44c01.mdtbottxt
      from datkmdt, datrmdtbotprg, datkmdtbot
     where datkmdt.mdtcod              =  d_ctn44c01.mdtcod
       and datrmdtbotprg.mdtprgcod     =  datkmdt.mdtprgcod
       and datrmdtbotprg.mdtbotprgseq  =  d_ctn44c01.mdtbotprgseq
       and datkmdtbot.mdtbotcod        =  datrmdtbotprg.mdtbotcod
 end if

 select socvclcod,
        atdvclsgl,
        vclcoddig
   into d_ctn44c01.socvclcod,
        d_ctn44c01.atdvclsgl,
        ws.vclcoddig
   from datkveiculo
  where mdtcod  =  d_ctn44c01.mdtcod

 call cts15g00(ws.vclcoddig)  returning d_ctn44c01.vcldes

 select cpodes
   into d_ctn44c01.mdtmvtsttdes
   from iddkdominio
  where cponom  =  "mdtmvtstt"
    and cpocod  =  d_ctn44c01.mdtmvtstt

 if d_ctn44c01.mdterrcod  is not null   then
    select cpodes
      into d_ctn44c01.mdterrdes
      from iddkdominio
     where cponom  =  "mdterrcod"
       and cpocod  =  d_ctn44c01.mdterrcod
 end if

 let l_res     = null
 let l_mens    = null
 let l_funnom  = null

 call cty08g00_nome_func(l_empcod, l_funmat, l_usrtip)
      returning l_res, l_mens, l_funnom

 display by name d_ctn44c01.*
 display by name param.mdtmvtseq
 display l_funmat to funmat
 display l_funnom to funnom

 let ws.promptq = "L"
 input by name d_ctn44c01.mdttrxnum  without defaults
    on key (F8)
       error " Aguarde..."
       if ctx25g05_rota_ativa() then      # Verifica ambiente de ROTERIZACAO
          call ctx25g01( d_ctn44c01.lclltt      , d_ctn44c01.lcllgt, "O")
               returning l_msg.msg1, l_msg.msg2, l_msg.msg3, l_msg.msg4
       else
          call ctn44c02( d_ctn44c01.lclltt      , d_ctn44c01.lcllgt)
               returning l_msg.msg1, l_msg.msg2, l_msg.msg3, l_msg.msg4

       end if

       if l_msg.msg1 is not null then
          call cts08g01("A","", l_msg.msg1, l_msg.msg2, l_msg.msg3, l_msg.msg4 )
               returning l_resp
       end if

       error " "

    on Key (interrupt)
       exit input

 end input

 close window w_ctn44c01
 let int_flag  = false

end function   ###--- ctn44c01
