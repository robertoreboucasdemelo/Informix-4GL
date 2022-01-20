#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       : Ct24h                                                        #
# Modulo        : cty27g00.4gl                                                 #
# Analista Resp.: Alberto                                                      #
# PSI           : 2012-22101                                                   #
# Dados de Cobranca do servico                                                 #
#..............................................................................#
# Desenvolvimento: CDS Egeu, Alberto Rodrigues                                 #
# Liberacao      :                                                             #
#..............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor Fabrica  Origem    Alteracao                               #
#------------------------------------------------------------------------------#
# 08/08/2013  Merge                                                            #
#------------------------------------------------------------------------------#
# 20/08/2014   Josiane Almeida   CT-2014-19985/RQ    Adequação para recebimento#
#                                                   dos serviços do E-Commerce #
#------------------------------------------------------------------------------#
# 16/01/2015  BIZTalking,MMP SPR-2014-28503  REFAZER O MODULO!                 #
#                                            Passa a ser apenas um complemento #
#                                            da tela de Venda (opsfa006) para  #
#                                            digitacao dos dados do cartao e   #
#                                            para gravacao das tabelas:        #
#                                            "datmcrdcrtinf" e "datmpgtinf".   #
#------------------------------------------------------------------------------#
# 16/01/2015  BIZTalking,MMP SPR-2015-10068  Tratar campo Flag Pontos Cartao   #
#                                            (PALIATIVO)                       #
#------------------------------------------------------------------------------#
# 22/06/2015  INTERA,MarcosMP SPR-2015-13411 Tratar 'Flag Desc. Pontos Cartao' #
#------------------------------------------------------------------------------#
# 04/12/2015  INTERA,MarcosMP SPR-2015-23955 Guardar na base o numero do       #
#                                            cartao Porto a ser utilizado para #
#                                            pagamento.                        #
#------------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_confirma   char (01)
define m_prepflg    smallint
define m_out record
       res          dec(1),
       msg          char(50),
       pgtfrm       integer,
       flag_pvisa   char(1),
       nome_band    char(20),
       cod_band     char(1)
end record
define m_erro       integer
define mr_cty27g00  record
       orgnum       like datmpgtinf.orgnum,
       prpnum       like datmpgtinf.prpnum,
       atdsrvnum    like datmpgtinf.atdsrvnum,
       atdsrvano    like datmpgtinf.atdsrvano,
       pgtfrmcod    like datmpgtinf.pgtfrmcod,
       funtipcod    like datmpgtinf.funtipcod,
       empcod       like datmpgtinf.empcod,
       usrmatnum    like datmpgtinf.usrmatnum,
       atldat       like datmpgtinf.atldat,
       pgtseqnum    like datmcrdcrtinf.pgtseqnum,
       clinom       like datmcrdcrtinf.clinom,
       crtnum       like datmcrdcrtinf.crtnum,
       bndcod       like datmcrdcrtinf.bndcod,
       crtvlddat    like datmcrdcrtinf.crtvlddat,
       cbrparqtd    like datmcrdcrtinf.cbrparqtd,
       ptorgtflg    like datmpgtinf.ptorgtflg,  #=> SPR-2015-13411
       numcar1      char(04),
       numcar2      char(04),
       numcar3      char(04),
       numcar4      char(04)
end record
define d_cty27g00   record
       clinom       like datmcrdcrtinf.clinom,
       numcar1      char(04),
       numcar2      char(04),
       numcar3      char(04),
       numcar4      char(04),
       crtnum       like datmcrdcrtinf.crtnum,
       bndcod       like datmcrdcrtinf.bndcod,
       bnddes       like fcokcarbnd.carbndnom,
       crtvlddat    like datmcrdcrtinf.crtvlddat
end record
define dx_cty27g00  record
       orgnum       like datmpgtinf.orgnum,
       prpnum       like datmpgtinf.prpnum,
       servico      char(13),
       pgtfrmcod    like datmpgtinf.pgtfrmcod,
       l_pgtfrmdes  char(21),
       clinom       like datmcrdcrtinf.clinom,
       numcar1      char(04),
       numcar2      char(04),
       numcar3      char(04),
       numcar4      char(04),
       crtnum       like datmcrdcrtinf.crtnum,
       bndcod       like datmcrdcrtinf.bndcod,
       l_bnddes     like fcokcarbnd.carbndnom,
       crtvlddat    like datmcrdcrtinf.crtvlddat,
       cbrparqtd    like datmcrdcrtinf.cbrparqtd
end record


#------------------------------------------------------------------------------#
function cty27g00_prepara()
#------------------------------------------------------------------------------#
 define l_sql   char(1500)

 whenever error continue

 #-------CT-2014-19985/RQ------#                      #=> SPR-2015-13411
 let l_sql = 'select atdsrvnum, atdsrvano, pgtfrmcod, ptorgtflg'
            ,'  from datmpgtinf '
            ,' where orgnum = 29'
            ,'   and prpnum = ?'
 prepare p_cty27g00_001 from l_sql
 if sqlca.sqlcode <> 0 then
    return false
 end if
 declare c_cty27g00_001 cursor for p_cty27g00_001
 if sqlca.sqlcode <> 0 then
    return false
 end if
 #------fim CT-2014-19985/RQ ------#

 #------[INSERE PROPOSTA]----
 # datmpgtinf - (Armazena informações da forma de pagamento)
 let l_sql = " insert into datmpgtinf( "
             ,"  orgnum    , "
             ,"  prpnum    , "
             ,"  atdsrvnum , "
             ,"  atdsrvano , "
             ,"  pgtfrmcod , "
             ,"  ptorgtflg , "                   #=> SPR-2015-13411
             ,"  funtipcod , "
             ,"  empcod    , "
             ,"  usrmatnum , "
             ,"  atldat    ) "
             ,"  values (?,?,?,?,?,?,?,?,?,?) "  #=> SPR-2015-13411
 prepare p_cty27g00_002 from l_sql
 if sqlca.sqlcode <> 0 then
    return false
 end if

 #------[INSERE PROPOSTA]----
 # datmcrdcrtinf - (Armazena informacao dos cartoes outras bandeiras)
 let l_sql = " insert into datmcrdcrtinf( "
            ," orgnum    , "
            ," prpnum    , "
            ," pgtseqnum , "
            ," clinom    , "
            ," crtnum    , "
            ," bndcod    , "
            ," crtvlddat , "
            ," cbrparqtd ) "
            ," values (?,?,?,?,?,?,?,?) "
 prepare p_cty27g00_002a from l_sql
 if sqlca.sqlcode <> 0 then
    return false
 end if

 #------[ATUALIZA PROPOSTA]----
 let l_sql = " update datmpgtinf set( "
            ," pgtfrmcod, "
            ," ptorgtflg, "         #=> SPR-2015-13411
            ," funtipcod, "
            ," empcod, "
            ," usrmatnum,  "
            ," atldat)  "
            ," = (?,?,?,?,?,?)"     #=> SPR-2015-13411
            ," where orgnum = ?"
            ,"   and prpnum = ? "
 prepare p_cty27g00_003 from l_sql
 if sqlca.sqlcode <> 0 then
    return false
 end if

 #------[BUSCA NOVO NUMERO DE PROPOSTA]----
 let l_sql = ' select grlinf[01,10] ',
             ' from datkgeral ',
             ' where grlchv = "NUMULTPRP" ',
             ' for update of grlinf '
 prepare p_cty27g00_005 from l_sql
 if sqlca.sqlcode <> 0 then
    return false
 end if
 declare c_cty27g00_005 cursor for p_cty27g00_005
 if sqlca.sqlcode <> 0 then
    return false
 end if

 #------[ATUALIZA NUMERO DE PROPOSTA]----
 let l_sql = ' update ',
             ' datkgeral ',
             ' set (grlinf, ',
             ' atldat, ',
             ' atlhor) = (?, ?, ?) ',
             ' where grlchv = "NUMULTPRP" '
 prepare p_cty27g00_006 from l_sql
 if sqlca.sqlcode <> 0 then
    return false
 end if

 #------------CT-2014-19985/RQ-------------#
 let l_sql = 'select b.pgtseqnum, b.clinom, b.crtnum, b.bndcod, '
            ,'       b.crtvlddat, b.cbrparqtd, c.carbndnom    '
            ,'  from datmcrdcrtinf b, outer fcokcarbnd c      '
            ,' where b.orgnum = ?                             '
            ,'   and b.prpnum = ?                             '
            ,'   and b.pgtseqnum = (select max(d.pgtseqnum)   '
                                  ,'  from datmcrdcrtinf d    '
                                  ,' where d.orgnum = ?       '
                                  ,'   and d.prpnum = ?)      '
            ,'   and b.bndcod = c.carbndcod                   '
 prepare p_cty27g00_008 from l_sql
 if sqlca.sqlcode <> 0 then
    return false
 end if
 declare c_cty27g00_008 cursor for p_cty27g00_008
 if sqlca.sqlcode <> 0 then
    return false
 end if
 #------------fim CT-2014-19985/RQ---------------#

 whenever error stop

 return true

end function


#------------------------------------------------------------------------------#
function cty27g00_inicializa()
#------------------------------------------------------------------------------#
   initialize mr_cty27g00.* to null
end function


#------------------------------------------------------------------------------#
function cty27g00_exibe_dados()
#------------------------------------------------------------------------------#
   define l_prompt_key char(01)

   open window w_cty27g00 at 4,2 with form 'cty27g00'
        attribute(border, form line 1 )
{
   open window w_cty27g00
            at 7,2
          with form 'cty27g00'
     attribute(border, form line 1)
}

   display by name dx_cty27g00.*

   error  " Digite Ctrl+C para encerrar a consulta!"
   prompt "" for char l_prompt_key

   close window w_cty27g00

   let int_flag = false

end function


#------------------------------------------------------------------------------#
function cty27g00_entrada_dados(lr_param)
#------------------------------------------------------------------------------#
   define lr_param     record
          atdsrvnum    like datmpgtinf.atdsrvnum,
          atdsrvano    like datmpgtinf.atdsrvano,
          prpnum       like datmpgtinf.prpnum,
          pgtfrmcod    like datmpgtinf.pgtfrmcod,
          cbrparqtd    like datmcrdcrtinf.cbrparqtd,
          ptorgtflg    like datmpgtinf.ptorgtflg,  #=> SPR-2015-13411
          numcarpor    char(16)                    #=> SPR-2015-23955:C.PORTO
   end record
   define lr_ret       record                      #=> SPR-2015-13411
          cod          smallint,
          ptorgtflg    like datmpgtinf.ptorgtflg,
          numcar4      char(04),                   #=> SPR-2015-23955
          bnddes       like fcokcarbnd.carbndnom   #=> SPR-2015-23955
   end record
   define l_atdsrvnum  like datmpgtinf.atdsrvnum,
          l_atdsrvano  like datmpgtinf.atdsrvano
   define lr_retorno   record
          coderro      smallint,
          msgerro      char(10000),
          pcapticrpcod like fcomcaraut.pcapticrpcod
   end record
   define l_cartao     char(100)
   define n_cartao     decimal(19,0)

   initialize lr_retorno.*,
              lr_ret.*      to  null   #=> SPR-2015-23955
   let l_cartao = ""
   let n_cartao = 0

   #=> MONTA VARIAVEL PARA INCLUSAO NA BASE
   call cty27g00_select(lr_param.*)  #=> SPR-2015-13411
        returning lr_ret.*           #=> SPR-2015-13411
   if not lr_ret.cod then
      return lr_ret.*     #=> SPR-2015-23955
   end if
   if lr_param.pgtfrmcod <> 1 then
      return lr_ret.*     #=> SPR-2015-23955
   end if

#-------------------------------------------------------------------------------

   open window w_cty27g00a
            at 7,2
          with form 'cty27g00a'
     attribute(border)

   display by name d_cty27g00.*

   input by name d_cty27g00.* without defaults
      before field clinom
         display by name d_cty27g00.clinom attribute(reverse)

      after field clinom
         display by name d_cty27g00.clinom
         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            next field clinom
         end if
         if d_cty27g00.clinom is null or
            d_cty27g00.clinom = " " then
            error "Nome obrigatorio !" sleep 1
            next field clinom
         end if
         if length(d_cty27g00.clinom) < 7 then
            error "Campo Nome deve ter no minimo 07 caracteres" sleep 1
            next field clinom
         end if

      before field numcar1
         display by name d_cty27g00.numcar1 attribute(reverse)

      after field numcar1
         if d_cty27g00.numcar1 != 'XXXX' then
            let mr_cty27g00.numcar1 = d_cty27g00.numcar1
         end if
         let d_cty27g00.numcar1 = 'XXXX'
         display by name d_cty27g00.numcar1
         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            next field clinom
         end if
         if d_cty27g00.numcar1 is null then
            next field numcar1
         end if
         if length(d_cty27g00.numcar1) <= 3 then
            error "Numero invalido !" sleep 1
            next field numcar1
         end if

      before field numcar2
         display by name d_cty27g00.numcar2 attribute(reverse)

      after field numcar2
         if d_cty27g00.numcar2 != 'XXXX' then
            let mr_cty27g00.numcar2 = d_cty27g00.numcar2
         end if
         let d_cty27g00.numcar2 = 'XXXX'
         display by name d_cty27g00.numcar2
         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            let d_cty27g00.numcar1 = 'XXXX'
            next field numcar1
         end if
         if d_cty27g00.numcar2 is null then
            next field numcar2
         end if
         if length(d_cty27g00.numcar2)<= 3 then
            error "Numero invalido !" sleep 1
            next field numcar2
         end if

      before field numcar3
         display by name d_cty27g00.numcar3 attribute(reverse)

      after field numcar3
         if d_cty27g00.numcar3 != 'XXXX' then
            let mr_cty27g00.numcar3 = d_cty27g00.numcar3
         end if
         let d_cty27g00.numcar3 = 'XXXX'
         display by name d_cty27g00.numcar3
         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            let d_cty27g00.numcar2 = 'XXXX'
            next field numcar2
         end if
         if d_cty27g00.numcar3 is null then
            next field numcar3
         end if
         if length(d_cty27g00.numcar3)<= 3 then
            error "Numero invalido !" sleep 1
            next field numcar3
         end if

      before field numcar4
         display by name d_cty27g00.numcar4 attribute(reverse)

      after field numcar4
         display by name d_cty27g00.numcar4
         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            let d_cty27g00.numcar3 = 'XXXX'
            next field numcar3
         end if
         if d_cty27g00.numcar4 is null then
            next field numcar4
         end if
         if length(d_cty27g00.numcar4)<= 3 then
            error "Numero invalido !" sleep 1
            next field numcar4
         end if

         let d_cty27g00.numcar1 = mr_cty27g00.numcar1
         let d_cty27g00.numcar2 = mr_cty27g00.numcar2
         let d_cty27g00.numcar3 = mr_cty27g00.numcar3

         initialize l_cartao to null
         let l_cartao = d_cty27g00.numcar1,
                        d_cty27g00.numcar2,
                        d_cty27g00.numcar3,
                        d_cty27g00.numcar4

         let n_cartao = l_cartao

         call ffcoc001_valid(n_cartao)
              returning  m_out.res
                        ,m_out.msg
                        ,m_out.pgtfrm
         if m_out.res <> 0 then
            error m_out.msg
            next field numcar1
         end if

         call ffcoc001_band(n_cartao) -- param.pcacarnum
              returning  m_out.res
                        ,m_out.msg
                        ,m_out.pgtfrm
                        ,m_out.flag_pvisa
                        ,m_out.nome_band
                        ,m_out.cod_band
         if m_out.res <> 0 then
            error m_out.msg
            next field numcar1
         end if
         if m_out.cod_band <> 4 and
            m_out.cod_band <> 5 then
            error "Bandeira Invalida. Somente VISA OU MASTERCARD " sleep 2
            next field numcar1
         end if
         let d_cty27g00.bndcod = m_out.cod_band
         let d_cty27g00.bnddes = m_out.nome_band

         # Criptografa o numero do Cartao
         call ffctc890("C", n_cartao )
              returning lr_retorno.*
         let l_cartao = lr_retorno.pcapticrpcod
         let d_cty27g00.crtnum = l_cartao

         display by name d_cty27g00.bndcod attribute(reverse)
         display by name d_cty27g00.bnddes attribute(reverse)

      before field crtvlddat
         display by name d_cty27g00.crtvlddat attribute(reverse)

      after field crtvlddat
         display by name d_cty27g00.crtvlddat
         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            next field numcar4
         end if
         if d_cty27g00.crtvlddat is null then
            error "Data Invalida!"
            next field crtvlddat
         end if
         let mr_cty27g00.clinom    = d_cty27g00.clinom
         let mr_cty27g00.numcar1   = d_cty27g00.numcar1
         let mr_cty27g00.numcar2   = d_cty27g00.numcar2
         let mr_cty27g00.numcar3   = d_cty27g00.numcar3
         let mr_cty27g00.numcar4   = d_cty27g00.numcar4
         let mr_cty27g00.crtnum    = d_cty27g00.crtnum
         let mr_cty27g00.bndcod    = d_cty27g00.bndcod
         let mr_cty27g00.crtvlddat = d_cty27g00.crtvlddat

      on key (f17,control-c, interrupt)
         exit input

   end input

   close window w_cty27g00a

   if int_flag then
      let int_flag = false
      let lr_ret.cod = false  #=> SPR-2015-23955
      return lr_ret.*         #=> SPR-2015-23955
   end if

   #=> SPR-2015-23955: RETORNA CARTAO PARA EXIBICAO NA VENDA (OPSFA006)
   let lr_ret.numcar4 = d_cty27g00.numcar4
   let lr_ret.bnddes  = d_cty27g00.bnddes

   return lr_ret.*            #=> SPR-2015-23955

end function


#------------------------------------------------------------------------------#
function cty27g00_select(lr_param)
#------------------------------------------------------------------------------#
   define lr_param     record
          atdsrvnum    like datmpgtinf.atdsrvnum,
          atdsrvano    like datmpgtinf.atdsrvano,
          prpnum       like datmpgtinf.prpnum,
          pgtfrmcod    like datmpgtinf.pgtfrmcod,
          cbrparqtd    like datmcrdcrtinf.cbrparqtd,
          ptorgtflg    like datmpgtinf.ptorgtflg,  #=> SPR-2015-13411
          numcarpor    char(16)                    #=> SPR-2015-23955
   end record
   define lr_retorno   record
          coderro      smallint,
          msgerro      char(10000),
          pcapticrpcod like fcomcaraut.pcapticrpcod
   end record
   define l_atdsrvnum  like datmpgtinf.atdsrvnum,
          l_atdsrvano  like datmpgtinf.atdsrvano,
          l_pgtfrmcod  like datmpgtinf.pgtfrmcod,
          l_ptorgtflg  like datmpgtinf.ptorgtflg,  #=> SPR-2015-13411
          l_cbrparqtd  like datmcrdcrtinf.cbrparqtd,
          l_crtnum     like datmcrdcrtinf.crtnum,  #=> SPR-2015-23955
          l_bndcod     like datmcrdcrtinf.bndcod,  #=> SPR-2015-23955
          l_bnddes     like fcokcarbnd.carbndnom   #=> SPR-2015-23955
   define l_cartao     char(100)
   define l_lixo       char(200)

   initialize lr_retorno.*,
              l_atdsrvnum,
              l_atdsrvano,
              l_pgtfrmcod,
              l_ptorgtflg,                         #=> SPR-2015-13411
              l_crtnum,            #=> SPR-2015-23955
              l_bndcod,            #=> SPR-2015-23955
              l_bnddes,            #=> SPR-2015-23955
              l_cbrparqtd  to null
   let l_cartao = ""

   if not m_prepflg then
      let m_prepflg = cty27g00_prepara()
      if not m_prepflg then
         error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
               " AO PREPARAR COMANDOS SQL (CTY27G00)!!!"
         return false,
                lr_param.ptorgtflg, #=> SPR-2015-13411
                mr_cty27g00.numcar4, #=> SPR-2015-23955
                d_cty27g00.bnddes    #=> SPR-2015-23955
      end if
   end if

   #=> MANTEM ULTIMAS INFORMACOES DIGITADAS
   if mr_cty27g00.orgnum is not null              and
      mr_cty27g00.pgtfrmcod = lr_param.pgtfrmcod  and
      mr_cty27g00.pgtfrmcod = 1                   and
     ((mr_cty27g00.atdsrvnum is null and
       lr_param.atdsrvnum is null) or
      mr_cty27g00.atdsrvnum = lr_param.atdsrvnum) then

      #=> SPR-2015-13411 - OBEDECE ULTIMAS INFORMACOES DIGITADAS NA VENDA
      let mr_cty27g00.cbrparqtd = lr_param.cbrparqtd
      let mr_cty27g00.ptorgtflg = lr_param.ptorgtflg

      return true,
             mr_cty27g00.ptorgtflg, #=> SPR-2015-13411
             mr_cty27g00.numcar4, #=> SPR-2015-23955
             d_cty27g00.bnddes    #=> SPR-2015-23955
   end if

   initialize mr_cty27g00.*,
              d_cty27g00.* to null

   let mr_cty27g00.orgnum    = 29
   let mr_cty27g00.prpnum    = lr_param.prpnum
   let mr_cty27g00.atdsrvnum = lr_param.atdsrvnum
   let mr_cty27g00.atdsrvano = lr_param.atdsrvano
   let mr_cty27g00.pgtfrmcod = lr_param.pgtfrmcod
   let mr_cty27g00.cbrparqtd = lr_param.cbrparqtd
   let mr_cty27g00.ptorgtflg = lr_param.ptorgtflg  #=> SPR-2015-13411
   let mr_cty27g00.pgtseqnum = 0
   let mr_cty27g00.funtipcod = g_issk.usrtip
   let mr_cty27g00.empcod    = g_issk.empcod
   let mr_cty27g00.usrmatnum = g_issk.funmat
   let mr_cty27g00.atldat    = current

   #=> SPR-2015-23955 - CARTAO PORTO ESCOLHIDO NA VENDA (OPSFA006)
   if lr_param.numcarpor is not null then

      if lr_param.numcarpor <> " " then
         # Criptografa o numero do cartao
         call ffctc890("C",
                       lr_param.numcarpor)
              returning lr_retorno.*

         let mr_cty27g00.crtnum = lr_retorno.pcapticrpcod

         let l_cartao = lr_param.numcarpor

         let mr_cty27g00.numcar1 = l_cartao[1 , 4]
         let mr_cty27g00.numcar2 = l_cartao[5 , 8]
         let mr_cty27g00.numcar3 = l_cartao[9 ,12]
         let mr_cty27g00.numcar4 = l_cartao[13,16]
      else
         let mr_cty27g00.crtnum  = " "
         let mr_cty27g00.numcar4 = " "
      end if

      let mr_cty27g00.bndcod = 6  #=> BANDEIRA CARTAO PORTO
      let d_cty27g00.bnddes  = "CARTAO PORTO SEGURO"

   else
      let mr_cty27g00.crtnum  = " "
      let mr_cty27g00.numcar4 = " "
   end if

   #=> SPR-2015-13411 - EFETUA CONSULTA A BASE, INDEPENDENTE DA F.PAGTO
   if mr_cty27g00.prpnum is not null then  #=> ALTERACAO: BUSCA DADOS

      whenever error continue
      open c_cty27g00_001 using mr_cty27g00.prpnum
      fetch c_cty27g00_001 into l_atdsrvnum,
                                l_atdsrvano,
                                l_pgtfrmcod,
                                l_ptorgtflg  #=> SPR-2015-13411
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                  " AO ACESSAR 'datmpgtinf' (_001)!!"
         else
            error "PROPOSTA (", mr_cty27g00.prpnum, ")/PGTFRM NAO ENCONTRADA!!!"
         end if
         sleep 2
         return false,
                lr_param.ptorgtflg, #=> SPR-2015-13411
                mr_cty27g00.numcar4, #=> SPR-2015-23955
                d_cty27g00.bnddes    #=> SPR-2015-23955
      end if
      if mr_cty27g00.atdsrvnum is null        or
         mr_cty27g00.atdsrvano is null        or
         mr_cty27g00.atdsrvnum <> l_atdsrvnum or
         mr_cty27g00.atdsrvano <> l_atdsrvano then
         error "SERVICO (", mr_cty27g00.atdsrvnum,"/",mr_cty27g00.atdsrvano,")",
               " DIVERGENTE DO DA PROPOSTA (", l_atdsrvnum,"/",l_atdsrvano,")!"
         sleep 2
         return false,
                lr_param.ptorgtflg, #=> SPR-2015-13411
                mr_cty27g00.numcar4, #=> SPR-2015-23955
                d_cty27g00.bnddes    #=> SPR-2015-23955
      end if
      if mr_cty27g00.pgtfrmcod is null then
         let mr_cty27g00.pgtfrmcod = l_pgtfrmcod
      end if
      #=> SPR-2015-13411 - TRATA FLAG
      if mr_cty27g00.ptorgtflg is null then
         let mr_cty27g00.ptorgtflg = l_ptorgtflg
      end if

      whenever error continue
      open c_cty27g00_008 using mr_cty27g00.orgnum,
                                mr_cty27g00.prpnum,
                                mr_cty27g00.orgnum,
                                mr_cty27g00.prpnum
      fetch c_cty27g00_008 into mr_cty27g00.pgtseqnum,
                                mr_cty27g00.clinom,
                                l_crtnum,            #=> SPR-2015-23955
                                l_bndcod,            #=> SPR-2015-23955
                                mr_cty27g00.crtvlddat,
                                l_cbrparqtd,
                                l_bnddes             #=> SPR-2015-23955
      whenever error stop
      if sqlca.sqlcode <> 0 or
         l_pgtfrmcod <> 1   then
         if sqlca.sqlcode < 0 then
            error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                  " AO ACESSAR 'datmcrdcrtinf' (_008-1)!!"
            sleep 2
            return false,
                   lr_param.ptorgtflg, #=> SPR-2015-13411
                   mr_cty27g00.numcar4, #=> SPR-2015-23955
                   d_cty27g00.bnddes    #=> SPR-2015-23955
         end if
         let mr_cty27g00.clinom    = " "
         let mr_cty27g00.crtvlddat = null
         let l_cbrparqtd           = null
      end if
      #=> SPR-2015-23955
      if mr_cty27g00.bndcod is null then
         let mr_cty27g00.crtnum = l_crtnum
         let mr_cty27g00.bndcod = l_bndcod
         let d_cty27g00.bnddes  = l_bnddes
      end if

      #=> SPR-2015-23955: APURA CARTAO E BANDEIRA (CARTAO PORTO)

      call cto00m12_nome_frmpgto(l_pgtfrmcod," ")
           returning lr_retorno.coderro,
                     lr_retorno.msgerro,
                     dx_cty27g00.l_pgtfrmdes

      if mr_cty27g00.crtnum = " "   or
         mr_cty27g00.crtnum is null then  #=> SPR-2015-23955
         let mr_cty27g00.numcar1 = " "
         let mr_cty27g00.numcar2 = " "
         let mr_cty27g00.numcar3 = " "
         let mr_cty27g00.numcar4 = " "
      else
         # Descriptografa o numero do cartao
         call ffctc890("D",mr_cty27g00.crtnum )
              returning lr_retorno.*

         let l_cartao = lr_retorno.pcapticrpcod

         let mr_cty27g00.numcar1 = l_cartao[1 , 4]
         let mr_cty27g00.numcar2 = l_cartao[5 , 8]
         let mr_cty27g00.numcar3 = l_cartao[9 ,12]
         let mr_cty27g00.numcar4 = l_cartao[13,16]
      end if
   end if

   if lr_param.pgtfrmcod is not null and
      lr_param.pgtfrmcod <> 1        then
      let mr_cty27g00.clinom    = " "
      if lr_param.pgtfrmcod = 2 then #=> CARTAO PORTO SEGURO
         let mr_cty27g00.bndcod = 6  #=> BANDEIRA CARTAO PORTO
      else
         let mr_cty27g00.bndcod = 0
         let mr_cty27g00.crtnum  = " "  #=> SPR-2015-23955: GRAVA CARTAO PORTO
         let mr_cty27g00.numcar4 = " "  #=> SPR-2015-23955: GRAVA CARTAO PORTO
         let d_cty27g00.bnddes   = " "  #=> SPR-2015-23955: GRAVA CARTAO PORTO
      end if
      let mr_cty27g00.crtvlddat = "01/01/1900"
      return true,
             mr_cty27g00.ptorgtflg, #=> SPR-2015-13411
             mr_cty27g00.numcar4, #=> SPR-2015-23955
             d_cty27g00.bnddes    #=> SPR-2015-23955
   end if

   #=> ATRIBUI VALORES DOS CAMPOS PARA INPUT
   let d_cty27g00.clinom    = mr_cty27g00.clinom
   let d_cty27g00.numcar1   = mr_cty27g00.numcar1
   let d_cty27g00.numcar2   = mr_cty27g00.numcar2
   let d_cty27g00.numcar3   = mr_cty27g00.numcar3
   let d_cty27g00.numcar4   = mr_cty27g00.numcar4
   let d_cty27g00.crtnum    = mr_cty27g00.crtnum
   let d_cty27g00.bndcod    = mr_cty27g00.bndcod
   let d_cty27g00.crtvlddat = mr_cty27g00.crtvlddat
   if mr_cty27g00.numcar1 is not null and
      mr_cty27g00.numcar1 <> " "      then
      let d_cty27g00.numcar1 = "XXXX"
      let d_cty27g00.numcar2 = "XXXX"
      let d_cty27g00.numcar3 = "XXXX"
   end if

   #=> ATRIBUI VALORES DOS CAMPOS PARA EXIBICAO
   let dx_cty27g00.orgnum      = mr_cty27g00.orgnum
   let dx_cty27g00.prpnum      = mr_cty27g00.prpnum
   let dx_cty27g00.servico     = mr_cty27g00.atdsrvnum using "&&&&&&&&", "-",
                                 mr_cty27g00.atdsrvano using "&&"
   let dx_cty27g00.pgtfrmcod   = l_pgtfrmcod
   let dx_cty27g00.clinom      = d_cty27g00.clinom
   let dx_cty27g00.numcar1     = d_cty27g00.numcar1
   let dx_cty27g00.numcar2     = d_cty27g00.numcar2
   let dx_cty27g00.numcar3     = d_cty27g00.numcar3
   let dx_cty27g00.numcar4     = d_cty27g00.numcar4
   let dx_cty27g00.crtnum      = d_cty27g00.crtnum
   let dx_cty27g00.bndcod      = d_cty27g00.bndcod
   let dx_cty27g00.l_bnddes    = d_cty27g00.bnddes
   let dx_cty27g00.crtvlddat   = d_cty27g00.crtvlddat
   let dx_cty27g00.cbrparqtd   = l_cbrparqtd

   return true,
          mr_cty27g00.ptorgtflg, #=> SPR-2015-13411
          mr_cty27g00.numcar4, #=> SPR-2015-23955
          d_cty27g00.bnddes    #=> SPR-2015-23955

end function


#----------------------------#
function cty27g00_numprP()
#----------------------------#

  define retorno record
         prpnum  like datmpgtinf.prpnum,
         sqlcode integer,
         msg     char(80)
  end record

  define ws      record
         prpnum  like datmpgtinf.prpnum,
         atldat  like datkgeral.atldat,
         atlhor  like datkgeral.atlhor
  end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  retorno.*  to  null

  initialize  ws.*  to  null

  if not m_prepflg then
     let m_prepflg = cty27g00_prepara()
     if not m_prepflg then
        error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
              " AO PREPARAR COMANDOS SQL (CTY27G00)!!!"
        return false
     end if
  end if

  initialize retorno, ws to null
  whenever error continue
  open c_cty27g00_005
  if  sqlca.sqlcode <> 0  then
      let retorno.sqlcode = sqlca.sqlcode
      let retorno.msg     = " Erro na busca do numero da proposta(open)! "
      let retorno.prpnum  = null
      return retorno.*
  end if

  fetch c_cty27g00_005 into ws.prpnum
  whenever error stop

  if  sqlca.sqlcode <> 0  then
      let retorno.sqlcode = sqlca.sqlcode
      let retorno.msg     = " Erro na busca do numero da proposta! "
      let retorno.prpnum  = null
      return retorno.*
  end if

  let ws.prpnum = ws.prpnum + 1

  # ---> BUSCA A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning ws.atldat, ws.atlhor

  whenever error continue
  execute p_cty27g00_006 using ws.prpnum, ws.atldat, ws.atlhor
  whenever error stop

  if  sqlca.sqlcode <> 0  then
      let retorno.sqlcode = sqlca.sqlcode
      let retorno.msg     = " Erro na atualizacao do numero da proposta! "
      let ws.prpnum       = null
  end if

  let retorno.prpnum = ws.prpnum

  return retorno.*

end function


# Funcionalidadade para verificar os Grupos de Assuntos, 'PSA','RCS' e 'RVC'
# Caso faca parte, retornara verdadeiro para abrir a tela de Forma de Pagto
#---------------------------------------------------------------------------
function cty27g00_consiste_ast(l_c24astcod)
#---------------------------------------------------------------------------

 define l_c24astcod like datmligacao.c24astcod

 define l_result integer

 initialize l_result to null

 let l_result = 0

 whenever error continue

 if cty27g00_validaAssunto(l_c24astcod) then
   return 2
 end if

 declare c_cty27g00_007 cursor for
 select  1
 from    datkassunto
 where   c24astagp in ('PSA') and c24aststt = 'A' and  c24astcod = l_c24astcod
 union all
 select  1
 from datkassunto
 where c24astcod in ('RCS','RVC') and c24aststt = 'A' and  c24astcod = l_c24astcod

 whenever error continue

 open  c_cty27g00_007

 whenever error stop

 whenever error continue
 fetch c_cty27g00_007 into l_result
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let l_result = 0
    else
       error "Grupo de Assuntos nao encontrado<PSA,RCS e RVC>"
       let l_result = null
    end if
 else
    let l_result = 1
 end if

 return l_result

end function


# Busca Numero de proposta
#-----------------------------------------------------------------
 function cty27g00_proposta(l_param)
#-----------------------------------------------------------------

 define l_param record
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
 end record

 define cty27g00_prpnum like datmpgtinf.prpnum

 initialize cty27g00_prpnum to null

 whenever error continue
 select a.prpnum
 into   cty27g00_prpnum
 from   datmpgtinf a, outer datmcrdcrtinf b
 where  a.orgnum    = b.orgnum
 and    a.prpnum    = b.prpnum
 and    a.atdsrvnum = l_param.atdsrvnum
 and    a.atdsrvano = l_param.atdsrvano
 and    b.pgtseqnum = (select max(d.pgtseqnum)
                         from datmcrdcrtinf d
                        where d.prpnum = b.prpnum )
 whenever error stop

 if sqlca.sqlcode <> 0 then
    error " Problemas na pesquisa do servico <datmpgtinf> ", sqlca.sqlcode
    let cty27g00_prpnum = null
 end if

 whenever error continue

 return cty27g00_prpnum

end function


# Carrega Globais qdo chamado da tela radiO_cartao
#-------------------------------------------------------------------------------
function cty27g00_pesq_prp(param)
#-------------------------------------------------------------------------------
 define param record
        atdsrvnum like datmpgtinf.atdsrvnum,
        atdsrvano like datmpgtinf.atdsrvano
 end record

 define lr_assunto record
        resultado smallint
       ,mensagem  char(100)
       ,c24astcod like datmligacao.c24astcod
       ,lignum    like datmligacao.lignum
 end record

 define cty27g00_ret integer

 initialize lr_assunto.* to null
 let cty27g00_ret = 0

 # Obter o Ligacao Original do Assunto pelo Servico
 select min(lignum) into lr_assunto.lignum
 from   datmligacao
 where  atdsrvnum = param.atdsrvnum
 and    atdsrvano = param.atdsrvano

 ##-- Obter o assunto da ligacao  --##
 call cts20g03_dados_ligacao( 2, lr_assunto.lignum  )
 returning lr_assunto.resultado
          ,lr_assunto.mensagem
          ,lr_assunto.c24astcod

 # consistir se faz parte do agrupamento.
 # Se sim, buscar numero de proposta e armazenar na global.
 call cty27g00_consiste_ast(lr_assunto.c24astcod)
      returning cty27g00_ret

 if cty27g00_ret = 1 then
    let g_documento.prpnum    = cty27g00_proposta(param.atdsrvnum,
                                                  param.atdsrvano)
    let g_documento.c24astcod = lr_assunto.c24astcod
    let g_documento.lignum    = lr_assunto.lignum
 end if

end function


function cty27g00_validaAssunto(param)

   define param record
      c24astcod like datkassunto.c24astcod
   end record

   whenever error continue
     select 1 from datkdominio
      where cponom = 'ASSUNTOSSEMCARTAO'
        and cpodes = param.c24astcod
     if sqlca.sqlcode = 0 then
        return true
     else
        select 1 from iddkdominio
         where cponom = 'ASSUNTOSSEMCARTAO'
           and cpodes = param.c24astcod
        if sqlca.sqlcode = 0 then
           return true
        else
           return false
        end if
     end if

   whenever error stop

end function


#-------------------------------------------------------------------------------
function cty27g00_insert(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          atdsrvnum      like datmsrvvnd.atdsrvnum,
          atdsrvano      like datmsrvvnd.atdsrvano,
          prpnum         like datmpgtinf.prpnum
   end record

   #=> CRITICA PARAMETROS E VALORES
   if lr_param.atdsrvnum is null    or
      lr_param.atdsrvano is null    or
      lr_param.prpnum is null       or
      mr_cty27g00.pgtfrmcod is null then
      error "Parametros para inclusao pgtfrm invalidos!"
      sleep 2
      return false
   end if

   #=> GRAVA TABELA 'datmpgtinf'
   whenever error continue
   execute p_cty27g00_002 using mr_cty27g00.orgnum,
                                lr_param.prpnum,
                                lr_param.atdsrvnum,
                                lr_param.atdsrvano,
                                mr_cty27g00.pgtfrmcod,
                                mr_cty27g00.ptorgtflg,  #=> SPR-2015-13411
                                mr_cty27g00.funtipcod,
                                mr_cty27g00.empcod   ,
                                mr_cty27g00.usrmatnum,
                                mr_cty27g00.atldat
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error "Problemas ao Inserir <p_cty27g00_002 datmpgtinf>. Erro <",
            sqlca.sqlcode, "/", sqlca.sqlerrd[2], ">"
      sleep 2
      return false
   end if

   #=> GRAVA TABELA 'datmcrdcrtinf'
   let mr_cty27g00.pgtseqnum = mr_cty27g00.pgtseqnum + 1
   whenever error continue
   execute p_cty27g00_002a using mr_cty27g00.orgnum,
                                 lr_param.prpnum,
                                 mr_cty27g00.pgtseqnum,
                                 mr_cty27g00.clinom,
                                 mr_cty27g00.crtnum,
                                 mr_cty27g00.bndcod,
                                 mr_cty27g00.crtvlddat,
                                 mr_cty27g00.cbrparqtd
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error "Problemas ao Inserir <p_cty27g00_002a datmcrdcrtinf>. Erro <",
            sqlca.sqlcode, "/", sqlca.sqlerrd[2], ">"
      sleep 2
      return false
   end if

   initialize mr_cty27g00.*,
              d_cty27g00.* to null

   return true

end function


#-------------------------------------------------------------------------------
function cty27g00_update(l_prpnum,m_flagonline)
#-------------------------------------------------------------------------------
   define l_prpnum       like datmpgtinf.prpnum,
          m_flagonline   smallint

   #=> CRITICA PARAMETROS E VALORES
   if l_prpnum is null               or
      mr_cty27g00.prpnum is null     or
      mr_cty27g00.prpnum <> l_prpnum then
      error "Chave da F.Pagto nao confere, ou F.Pagto nao selecionada!"
      sleep 2
      return false
   end if

   #=> ATUALIZA REGISTRO EM 'datmpgtinf'
   whenever error continue
   execute p_cty27g00_003 using mr_cty27g00.pgtfrmcod,
                                mr_cty27g00.ptorgtflg,  #=> SPR-2015-13411
                                mr_cty27g00.funtipcod,
                                mr_cty27g00.empcod   ,
                                mr_cty27g00.usrmatnum,
                                mr_cty27g00.atldat,
                                mr_cty27g00.orgnum,
                                l_prpnum
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error "Problemas ao Atualizar <p_cty27g00_003 datmpgtinf>. Erro <",
            sqlca.sqlcode, "/", sqlca.sqlerrd[2], ">"
      sleep 2
      return false
   end if

   #=> GRAVA TABELA 'datmcrdcrtinf'
   let mr_cty27g00.pgtseqnum = mr_cty27g00.pgtseqnum + 1
   whenever error continue
   execute p_cty27g00_002a using mr_cty27g00.orgnum,
                                 l_prpnum,
                                 mr_cty27g00.pgtseqnum,
                                 mr_cty27g00.clinom,
                                 mr_cty27g00.crtnum,
                                 mr_cty27g00.bndcod,
                                 mr_cty27g00.crtvlddat,
                                 mr_cty27g00.cbrparqtd
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error "Problemas ao Inserir <p_cty27g00_002a datmcrdcrtinf(upd)>. Erro <",
            sqlca.sqlcode, "/", sqlca.sqlerrd[2], ">"
      sleep 2
      return false
   end if

   if not m_flagonline then
      initialize mr_cty27g00.*,
                 d_cty27g00.* to null
   end if

   return true

end function
