#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts19m08                                                   #
# Analista Resp : Roberto Reboucas                                           #
#                 Verifica limites e saldo de utilizações nos B14            #
#............................................................................#
# Desenvolvimento: Amilton Pinto / Meta                                      #
# Liberacao      : 21/08/2009                                                #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica  Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#
# 04/01/2010 Amilton                   projeto succod  smallint              #
#----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail  #
##############################################################################
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"



   define m_prep     smallint
   define m_pbsvig   smallint
   define m_lateral  smallint
   define m_retrov   smallint
   define m_farol    smallint
   define m_laternas smallint
   define m_utiliz   smallint
   define m_mens     char(100)

function cts19m08_prepare()

   define l_sql char(500)
   let l_sql = null
   let l_sql = "select b.atdsrvnum,b.atdsrvano ",
               " from datrligapol a,           ",
               "      datmligacao b            ",
               " where a.succod = ?           ",
               "  and a.ramcod = ?           ",
               "  and a.aplnumdig = ?      ",
               "  and a.itmnumdig = ?         ",
               "  and b.lignum = a.lignum      ",
               "  and b.c24astcod = 'B14'      ",
               "group by 1,2                  "
   prepare p_cts19m08001 from l_sql
   declare c_cts19m08001 cursor with hold for p_cts19m08001
   let l_sql = "select max(lignum)  ",
               "from datmsrvext1    ",
               "where atdsrvnum = ? ",
               "and atdsrvano = ?   "
   prepare p_cts19m08002 from l_sql
   declare c_cts19m08002 cursor with hold for p_cts19m08002
   let l_sql = " select "
               ," vdrpbsavrfrqvlr,vdrvgaavrfrqvlr "
               ,",vdresqavrfrqvlr,vdrdiravrfrqvlr "
               ,",ocudiravrfrqvlr,ocuesqavrfrqvlr "
               ,",dirrtravrvlr,esqrtravrvlr "
               ,",drtfrlvlr,esqfrlvlr,drtmlhfrlvlr "
               ,",esqmlhfrlvlr,drtnblfrlvlr "
               ,",esqnblfrlvlr,drtpscvlr "
               ,",esqpscvlr,drtlntvlr,esqlntvlr "
               ,"from datmsrvext1 "
               ,"where lignum = ? "
               ,"and   atdsrvnum = ? "
               ,"and   atdsrvano = ? "
   prepare p_cts19m08003 from l_sql
   declare c_cts19m08003 cursor with hold for p_cts19m08003
   let l_sql = "select cpodes from datkdominio ",
               " where cponom = ? "
   prepare pcts19m08004 from l_sql
   declare c_cts19m08004 cursor with hold for pcts19m08004
   let l_sql = " select lignum,ligdat,lighorinc,c24solnom  ",
               " ,succod,ramcod,aplnumdig,itmnumdig        ",
               " ,viginc,vigfnl,segnom,segdddcod,segteltxt ",
               " ,clscod,clsdes,cgccpfnum,cgcord,cgccpfdig ",
               " ,atdsrvnum,atdsrvano,vdrrprempcod         ",
               " from datmsrvext1                          ",
               " where atdsrvnum = ?                       ",
               " and atdsrvano = ?                         ",
               " and lignum    = ?                         "
   prepare pcts19m08005 from l_sql
   declare c_cts19m08005 cursor with hold for pcts19m08005
   let l_sql = " select funnom     "
               ," from isskfunc    "
               ," where empcod = ? "
               ," and funmat = ?   "
   prepare pcts19m08006 from l_sql
   declare c_cts19m08006 cursor with hold for pcts19m08006
   let l_sql = ' select empnom ',
                 ' from gabkemp ',
                ' where empcod = ? '
   prepare pcts19m08007 from l_sql
   declare c_cts19m08007 cursor for pcts19m08007
let m_prep = true
end function

function cts19m08_utilizacao()


   define l_datmsrvext1 record
       vdrpbsavrfrqvlr like datmsrvext1.vdrpbsavrfrqvlr,
       vdrvgaavrfrqvlr like datmsrvext1.vdrvgaavrfrqvlr,
       vdresqavrfrqvlr like datmsrvext1.vdresqavrfrqvlr,
       vdrdiravrfrqvlr like datmsrvext1.vdrdiravrfrqvlr,
       ocudiravrfrqvlr like datmsrvext1.ocudiravrfrqvlr,
       ocuesqavrfrqvlr like datmsrvext1.ocuesqavrfrqvlr,
       dirrtravrvlr    like datmsrvext1.dirrtravrvlr,
       esqrtravrvlr    like datmsrvext1.esqrtravrvlr,
       drtfrlvlr       like datmsrvext1.drtfrlvlr,
       esqfrlvlr       like datmsrvext1.esqfrlvlr,
       drtmlhfrlvlr    like datmsrvext1.drtmlhfrlvlr,
       esqmlhfrlvlr    like datmsrvext1.esqmlhfrlvlr,
       drtnblfrlvlr    like datmsrvext1.drtnblfrlvlr,
       esqnblfrlvlr    like datmsrvext1.esqnblfrlvlr,
       drtpscvlr       like datmsrvext1.drtpscvlr,
       esqpscvlr       like datmsrvext1.esqpscvlr,
       drtlntvlr       like datmsrvext1.drtlntvlr,
       esqlntvlr       like datmsrvext1.esqlntvlr
   end record
   define ws record
        lignum    like datmligacao.lignum,
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
   end record
   define l_existe smallint
   initialize ws.* to null
   initialize l_datmsrvext1.* to null
   let l_existe = false

   if m_prep = false or
      m_prep is null then
      call cts19m08_prepare()
   end if
   # Busca Servicos da apolice
   whenever error continue
   open c_cts19m08001 using g_documento.succod,
                            g_documento.ramcod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig
   whenever error stop
   foreach c_cts19m08001 into ws.atdsrvnum,
                              ws.atdsrvano
        let l_existe = true
        # Despresa Alteracao
        if g_documento.atdsrvnum = ws.atdsrvnum and
           g_documento.atdsrvano = ws.atdsrvano then
           continue foreach
        end if
        # busca ligacao original do servico
        whenever error continue
        open c_cts19m08002 using ws.atdsrvnum,
                                 ws.atdsrvano
        fetch c_cts19m08002 into ws.lignum
        whenever error stop
        whenever error continue
        open c_cts19m08003 using ws.lignum,
                                 ws.atdsrvnum,
                                 ws.atdsrvano
        whenever error stop
        fetch c_cts19m08003 into   l_datmsrvext1.vdrpbsavrfrqvlr
                                  ,l_datmsrvext1.vdrvgaavrfrqvlr
                                  ,l_datmsrvext1.vdresqavrfrqvlr
                                  ,l_datmsrvext1.vdrdiravrfrqvlr
                                  ,l_datmsrvext1.ocudiravrfrqvlr
                                  ,l_datmsrvext1.ocuesqavrfrqvlr
                                  ,l_datmsrvext1.dirrtravrvlr
                                  ,l_datmsrvext1.esqrtravrvlr
                                  ,l_datmsrvext1.drtfrlvlr
                                  ,l_datmsrvext1.esqfrlvlr
                                  ,l_datmsrvext1.drtmlhfrlvlr
                                  ,l_datmsrvext1.esqmlhfrlvlr
                                  ,l_datmsrvext1.drtnblfrlvlr
                                  ,l_datmsrvext1.esqnblfrlvlr
                                  ,l_datmsrvext1.drtpscvlr
                                  ,l_datmsrvext1.esqpscvlr
                                  ,l_datmsrvext1.drtlntvlr
                                  ,l_datmsrvext1.esqlntvlr
            if sqlca.sqlcode = 0 then
                 call cts19m08_soma_util(l_datmsrvext1.*)
           end if
   end foreach
   close c_cts19m08001
   close c_cts19m08002
   close c_cts19m08003
end function

function cts19m08_permissao(lr_vidros,l_clscod)

    define lr_vidros record
       vdrpbsavrfrqvlr like datmsrvext1.vdrpbsavrfrqvlr,
       vdrvgaavrfrqvlr like datmsrvext1.vdrvgaavrfrqvlr,
       vdrdiravrfrqvlr like datmsrvext1.vdrdiravrfrqvlr,
       vdresqavrfrqvlr like datmsrvext1.vdresqavrfrqvlr,
       ocudiravrfrqvlr like datmsrvext1.ocudiravrfrqvlr,
       ocuesqavrfrqvlr like datmsrvext1.ocuesqavrfrqvlr,
       dirrtravrvlr    like datmsrvext1.dirrtravrvlr,
       esqrtravrvlr    like datmsrvext1.esqrtravrvlr,
       drtfrlvlr       like datmsrvext1.drtfrlvlr,
       esqfrlvlr       like datmsrvext1.esqfrlvlr,
       drtmlhfrlvlr    like datmsrvext1.drtmlhfrlvlr,
       esqmlhfrlvlr    like datmsrvext1.esqmlhfrlvlr,
       drtnblfrlvlr    like datmsrvext1.drtnblfrlvlr,
       esqnblfrlvlr    like datmsrvext1.esqnblfrlvlr,
       drtpscvlr       like datmsrvext1.drtpscvlr,
       esqpscvlr       like datmsrvext1.esqpscvlr,
       drtlntvlr       like datmsrvext1.drtlntvlr,
       esqlntvlr       like datmsrvext1.esqlntvlr
   end record
   define l_clscod  like aackcls.clscod
   define lr_limite record
        pbsvig    smallint,
        lateral   smallint,
        retrov    smallint,
        farol     smallint,
        laterna   smallint
    end record
    define lr_selecionados record
        pbsvig    smallint,
        lateral   smallint,
        retrov    smallint,
        farol     smallint,
        laterna   smallint
    end record
   define l_retorno smallint
    initialize lr_limite.* to null
    initialize lr_selecionados.* to null
    let m_pbsvig   = 0
    let m_lateral  = 0
    let m_retrov   = 0
    let m_farol    = 0
    let m_laternas = 0
    let m_utiliz   = 0
    let l_retorno = false
    call cts19m08_buscalimite(l_clscod)
         returning lr_limite.*
    call cts19m08_utilizacao()
    call cts19m08_soma_util(lr_vidros.*)
    let m_utiliz = m_pbsvig + m_lateral
    call cts19m08_vidros_selecionados(lr_vidros.*)
       returning lr_selecionados.*
    if l_clscod = 71 or
       l_clscod = 77 then
       if m_utiliz > lr_limite.pbsvig then
          let l_retorno = true
          return l_retorno
       else
          let l_retorno = false
          return l_retorno
       end if
    end if
   if (l_clscod  = 75  or l_clscod  = "75R" ) then
       if lr_selecionados.pbsvig = true then
          if m_pbsvig   > lr_limite.pbsvig then
             let l_retorno = true
             return l_retorno
          end if
       end if
       if lr_selecionados.lateral = true then
          if m_lateral   > lr_limite.lateral then
             let l_retorno = true
             return l_retorno
          end if
       end if
       if lr_selecionados.retrov = true then
          if m_retrov   > lr_limite.retrov then
             let l_retorno = true
             return l_retorno
          end if
       end if
    end if
    if (l_clscod  = 76  or l_clscod  = "76R" ) then
       if lr_selecionados.pbsvig = true then
          if m_pbsvig   > lr_limite.pbsvig then
             let l_retorno = true
             return l_retorno
          end if
       end if
       if lr_selecionados.lateral = true then
          if m_lateral   > lr_limite.lateral then
             let l_retorno = true
             return l_retorno
          end if
       end if
       if lr_selecionados.retrov = true then
          if m_retrov   > lr_limite.retrov then
             let l_retorno = true
             return l_retorno
          end if
       end if
       if lr_selecionados.farol = true then
          if m_farol   > lr_limite.farol then
             let l_retorno = true
             return l_retorno
          end if
       end if
       if lr_selecionados.laterna = true then
          if m_laternas   > lr_limite.laterna then
             let l_retorno = true
             return l_retorno
          end if
       end if
    end if
  return l_retorno
end function

function cts19m08_buscalimite(l_clscod)

   define l_clscod like aackcls.clscod
   define l_dominio char(15)
   define l_chave   char(50)
    define lr_limite record
        pbsvig    char(2),
        lateral   char(2),
        retrov    char(2),
        farol     char(2),
        laterna   char(2)
    end record
    define l_sql char(200)
    let l_dominio = null
    let l_chave  = null
    initialize lr_limite.* to null
    if m_prep = false or
       m_prep is null then
       call cts19m08_prepare()
    end if
    if l_clscod = 71 or
       l_clscod = 77 then
       let l_dominio = "limite_71_77"
    end if
    if (l_clscod  = 75  or l_clscod  = "75R" ) then
       let l_dominio = "limite_75"
    end if
    if (l_clscod  = 76  or l_clscod  = "76R" ) then
       let l_dominio = "limite_76"
    end if
    let l_dominio = l_dominio clipped

    whenever error continue
    open  c_cts19m08004 using l_dominio
    fetch c_cts19m08004 into l_chave
    whenever error stop
    if sqlca.sqlcode <> 0 then
       error "ERRO (",sqlca.sqlcode, ") AO SELECIONAR LIMITES DE VIDRO NA DATKDOMINIO " sleep 3
       display "Erro = ",sqlca.sqlcode
       return lr_limite.*
    end if
    #
    let lr_limite.pbsvig   = l_chave[1,2]
    let lr_limite.lateral  = l_chave[3,4]
    let lr_limite.retrov   = l_chave[5,6]
    let lr_limite.farol    = l_chave[7,8]
    let lr_limite.laterna  = l_chave[9,10]
    return lr_limite.*
end function

function cts19m08_soma_util(lr_param)

    define lr_param record
       vdrpbsavrfrqvlr like datmsrvext1.vdrpbsavrfrqvlr,
       vdrvgaavrfrqvlr like datmsrvext1.vdrvgaavrfrqvlr,
       vdrdiravrfrqvlr like datmsrvext1.vdrdiravrfrqvlr,
       vdresqavrfrqvlr like datmsrvext1.vdresqavrfrqvlr,
       ocudiravrfrqvlr like datmsrvext1.ocudiravrfrqvlr,
       ocuesqavrfrqvlr like datmsrvext1.ocuesqavrfrqvlr,
       dirrtravrvlr    like datmsrvext1.dirrtravrvlr,
       esqrtravrvlr    like datmsrvext1.esqrtravrvlr,
       drtfrlvlr       like datmsrvext1.drtfrlvlr,
       esqfrlvlr       like datmsrvext1.esqfrlvlr,
       drtmlhfrlvlr    like datmsrvext1.drtmlhfrlvlr,
       esqmlhfrlvlr    like datmsrvext1.esqmlhfrlvlr,
       drtnblfrlvlr    like datmsrvext1.drtnblfrlvlr,
       esqnblfrlvlr    like datmsrvext1.esqnblfrlvlr,
       drtpscvlr       like datmsrvext1.drtpscvlr,
       esqpscvlr       like datmsrvext1.esqpscvlr,
       drtlntvlr       like datmsrvext1.drtlntvlr,
       esqlntvlr       like datmsrvext1.esqlntvlr
   end record
    # Para-Brisa
    if lr_param.vdrpbsavrfrqvlr is not null then
       let m_pbsvig = m_pbsvig + 1
    end if
    # Vigia / Traseiro
    if lr_param.vdrvgaavrfrqvlr is not null then
       let m_pbsvig = m_pbsvig + 1
    end if
    #Lateral Esquerdo
    if lr_param.vdresqavrfrqvlr is not null then
       let m_lateral = m_lateral + 1
    end if
    #Lateral Direito
    if lr_param.vdrdiravrfrqvlr is not null then
       let m_lateral = m_lateral + 1
    end if
    #Oculo Direito
    if lr_param.ocudiravrfrqvlr is not null then
      let m_lateral = m_lateral + 1
    end if
    #Oculo Esquerdo
    if lr_param.ocuesqavrfrqvlr is not null then
       let m_lateral = m_lateral + 1
    end if
    #Retrovisor Direito
    if lr_param.dirrtravrvlr    is not null then
       let m_retrov = m_retrov + 1
    end if
    # Retrovisor Esquerdo
    if lr_param.esqrtravrvlr    is not null then
       let m_retrov = m_retrov + 1
    end if
    # Farol Direito
    if lr_param.drtfrlvlr       is not null then
       let m_farol = m_farol + 1
    end if
    #Farol Esquerdo
    if lr_param.esqfrlvlr       is not null then
       let m_farol = m_farol + 1
    end if
    # Farol de Milha Direito
    if lr_param.drtmlhfrlvlr    is not null then
       let m_farol = m_farol + 1
    end if
    # Farol de Milha Esquerdo
    if lr_param.esqmlhfrlvlr    is not null then
       let m_farol = m_farol + 1
    end if
    # Farol de neblina Direito
    if lr_param.drtnblfrlvlr    is not null then
       let m_farol = m_farol + 1
    end if
    # Farol de neblina Esquerdo
    if lr_param.esqnblfrlvlr    is not null then
       let m_farol = m_farol + 1
    end if
    # Pisca Direito
    if lr_param.drtpscvlr       is not null then
       let m_laternas = m_laternas + 1
    end if
    # Pisca Esquerdo
    if lr_param.esqpscvlr       is not null then
       let m_laternas = m_laternas + 1
    end if
    #Laterna Direita
    if lr_param.drtlntvlr       is not null then
       let m_laternas = m_laternas + 1
    end if
    # Laterna Esquerda
    if lr_param.esqlntvlr       is not null then
       let m_laternas = m_laternas + 1
    end if
   return
end function

function cts19m08_verifica_saldo(l_clscod,lr_param)
     define l_clscod like aackcls.clscod
     define lr_param record
          vdrpbsavrfrqvlr like datmsrvext1.vdrpbsavrfrqvlr,
          vdrvgaavrfrqvlr like datmsrvext1.vdrvgaavrfrqvlr,
          vdrdiravrfrqvlr like datmsrvext1.vdrdiravrfrqvlr,
          vdresqavrfrqvlr like datmsrvext1.vdresqavrfrqvlr,
          ocudiravrfrqvlr like datmsrvext1.ocudiravrfrqvlr,
          ocuesqavrfrqvlr like datmsrvext1.ocuesqavrfrqvlr,
          dirrtravrvlr    like datmsrvext1.dirrtravrvlr,
          esqrtravrvlr    like datmsrvext1.esqrtravrvlr,
          drtfrlvlr       like datmsrvext1.drtfrlvlr,
          esqfrlvlr       like datmsrvext1.esqfrlvlr,
          drtmlhfrlvlr    like datmsrvext1.drtmlhfrlvlr,
          esqmlhfrlvlr    like datmsrvext1.esqmlhfrlvlr,
          drtnblfrlvlr    like datmsrvext1.drtnblfrlvlr,
          esqnblfrlvlr    like datmsrvext1.esqnblfrlvlr,
          drtpscvlr       like datmsrvext1.drtpscvlr,
          esqpscvlr       like datmsrvext1.esqpscvlr,
          drtlntvlr       like datmsrvext1.drtlntvlr,
          esqlntvlr       like datmsrvext1.esqlntvlr
     end record
     let m_pbsvig   = 0
     let m_lateral  = 0
     let m_retrov   = 0
     let m_farol    = 0
     let m_laternas = 0
     call cts19m08_utilizacao()
     call cts19m08_soma_util(lr_param.*)
     return m_pbsvig  ,
            m_lateral ,
            m_retrov  ,
            m_farol   ,
            m_laternas

end function


function cts19m08_enviaEmail(lr_param)
   define lr_param record
     atdsrvnum    like datmservico.atdsrvnum,
     atdsrvano    like datmservico.atdsrvano,
     lignum       like datmligacao.lignum,
     empcod       like isskfunc.empcod,
     funmat       like isskfunc.funmat
   end record
   define l_clscod  like aackcls.clscod
   define lr_rel   record
         lignum           dec (10,0),
         ligdat           date      ,
         lighorinc        datetime hour to minute,
         c24solnom        char(15),
         succod           smallint, # projeto succod
         ramcod           dec (4,0),
         aplnumdig        dec (9,0),
         itmnumdig        dec (7,0),
         viginc           date      ,
         vigfnl           date      ,
         segnom           char(50),
         segdddcod        char(04),
         segteltxt        char(20),
         clscod           char(03),
         clsdes           char(40),
         cgccpfnum        dec(12,0),
         cgcord           dec(04,0),
         cgccpfdig        dec(02,0),
         atdsrvnum        dec(10,0),
         atdsrvano        dec(02,0),
         vdrrprempcod     dec(05,0)
    end record
    define ws           record
        nomeloja         like adikvdrrpremp.vdrrprempnom,
        endereco         char (65),
        lgdtip           like datmlcl.lgdtip,
        lgdnom           like datmlcl.lgdnom,
        lgdnum           like datmlcl.lgdnum,
        brrnom           like datmlcl.brrnom,
        lclbrrnom        like datmlcl.lclbrrnom,
        cidnom           like datmlcl.cidnom,
        ufdcod           like datmlcl.ufdcod,
        lclcttnom        like datmlcl.lclcttnom,
        c24astcod        like datmligacao.c24astcod,
        funnom           like isskfunc.funnom,
        empnom           like gabkemp.empnom
     end record
    define lr_cts19m08 record
           erro        smallint                 ,
           chave       like datkdominio.cponom  ,
           email       like datkdominio.cpodes  ,
           funmat      like isskfunc.funmat     ,
           codigo      char(200)                ,
           remetentes  char(5000)
    end record
   define lr_limite record
       pbsvig    integer,
       lateral   integer,
       retrov    integer,
       farol     integer,
       laterna   integer
    end record
    define lr_saldo record
        pbsvig    integer,
        lateral   integer,
        retrov    integer,
        farol     integer,
        laterna   integer,
        saldo_71  integer
    end record
    define lr_execedido record
        pbsvig    integer,
        lateral   integer,
        retrov    integer,
        farol     integer,
        laterna   integer,
        saldo_71  integer
    end record

  define l_comando       char(15000),
         l_msg           char(10000),
         l_assunto       char(100),
         l_remetente     char(50),
         l_para          char(1000),
         l_status        smallint,
         l_espera        smallint,
         l_sinistro      char (100),
         ls_laudo        char (60),
         ws_laudo        char (60)

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
 define l_coderro  smallint
 define msg_erro char(500)
  let l_para      = null
  let l_comando   = null
  let l_msg       = null
  let l_assunto   = null
  let l_remetente = null
  let l_status    = null
  let l_espera    = null
  let l_sinistro = null
  initialize lr_rel.* to null
  initialize ws.* to null
  initialize lr_cts19m08.* to null
  initialize lr_execedido.* to null
  initialize lr_limite.* to null
  initialize lr_saldo.* to null

    if m_prep = false or
      m_prep is null then
      call cts19m08_prepare()
   end if
   #recupera dados do laudo
    whenever error continue
    open c_cts19m08005 using lr_param.atdsrvnum,
                             lr_param.atdsrvano,
                             lr_param.lignum
    fetch c_cts19m08005 into lr_rel.*
    whenever error stop
    close c_cts19m08005
    # recupera nome do Autorizador
    whenever error continue
    open c_cts19m08006 using lr_param.empcod,
                             lr_param.funmat
    fetch c_cts19m08006 into ws.funnom
    whenever error stop
    close c_cts19m08006
    # Recupera nome da empresa
    whenever error continue
      open c_cts19m08007 using lr_param.empcod
      fetch c_cts19m08007 into ws.empnom
    whenever error stop
    close c_cts19m08007
    let ws.endereco = ws.lgdtip clipped, " ",
                      ws.lgdnom clipped, " ",
                      ws.lgdnum using "<<<<#"
    let m_pbsvig   = 0
    let m_lateral  = 0
    let m_retrov   = 0
    let m_farol    = 0
    let m_laternas = 0
    let m_utiliz   = 0
    call cts19m08_buscalimite(lr_rel.clscod)
          returning lr_limite.*
    call cts19m08_utilizacao()
    let m_utiliz = m_pbsvig + m_lateral + m_retrov + m_farol + m_laternas
   let lr_saldo.saldo_71 = lr_limite.pbsvig - m_utiliz
   let lr_saldo.pbsvig   = lr_limite.pbsvig  - m_pbsvig
   let lr_saldo.lateral  = lr_limite.lateral - m_lateral
   let lr_saldo.retrov   = lr_limite.retrov  - m_retrov
   let lr_saldo.farol    = lr_limite.farol   - m_farol
   let lr_saldo.laterna  = lr_limite.laterna - m_laternas

   let lr_execedido.pbsvig   = m_pbsvig   - lr_limite.pbsvig
   let lr_execedido.lateral  = m_lateral  - lr_limite.lateral
   let lr_execedido.retrov   = m_retrov   - lr_limite.retrov
   let lr_execedido.farol    = m_farol    - lr_limite.farol
   let lr_execedido.laterna  = m_laternas - lr_limite.laterna
   let lr_execedido.saldo_71 = m_utiliz    - lr_limite.pbsvig
   if lr_saldo.pbsvig < 0 then
      let lr_saldo.pbsvig = 0
   end if
   if lr_saldo.lateral < 0 then
      let lr_saldo.lateral = 0
   end if
   if lr_saldo.retrov < 0 then
      let lr_saldo.retrov = 0
   end if
   if lr_saldo.farol < 0 then
      let lr_saldo.farol = 0
   end if
   if lr_saldo.laterna < 0 then
      let lr_saldo.laterna = 0
   end if
   if lr_saldo.saldo_71 < 0 then
      let lr_saldo.saldo_71 = 0
   end if
   # Execedido
   if lr_execedido.pbsvig < 0 then
      let lr_execedido.pbsvig = 0
   end if
   if lr_execedido.lateral < 0 then
      let lr_execedido.lateral = 0
   end if
   if lr_execedido.retrov < 0 then
      let lr_execedido.retrov = 0
   end if
   if lr_execedido.farol < 0 then
      let lr_execedido.farol = 0
   end if
   if lr_execedido.laterna < 0 then
      let lr_execedido.laterna = 0
   end if
   if lr_execedido.saldo_71 < 0 then
      let lr_execedido.saldo_71 = 0
   end if
    let ls_laudo = "Vidros_sinistro.txt"
    let ws_laudo = f_path('ONLTEL', 'RELATO')

    if ws_laudo is null or
       ws_laudo = ' ' then
       let ws_laudo = '.'
    end if

    let ls_laudo = ws_laudo clipped,'/', ls_laudo clipped

       start report  rep_sinis1  to ls_laudo
       output to report rep_sinis1 ( lr_rel.ligdat
                                    ,lr_rel.lighorinc
                                    ,lr_rel.c24solnom
                                    ,lr_rel.succod
                                    ,lr_rel.ramcod
                                    ,lr_rel.aplnumdig
                                    ,lr_rel.itmnumdig
                                    ,lr_rel.viginc
                                    ,lr_rel.vigfnl
                                    ,lr_rel.segnom
                                    ,lr_rel.segdddcod
                                    ,lr_rel.segteltxt
                                    ,lr_rel.clscod
                                    ,lr_rel.clsdes
                                    ,lr_rel.cgccpfnum
                                    ,lr_rel.cgcord
                                    ,lr_rel.cgccpfdig
                                    ,lr_rel.atdsrvnum
                                    ,lr_rel.atdsrvano
                                    ,lr_param.empcod
                                    ,lr_param.funmat
                                    ,ws.funnom
                                    ,ws.empnom
                                    ,lr_saldo.*
                                    ,lr_execedido.*)
       finish report rep_sinis1
  let lr_cts19m08.chave = "VDR_SINISTRO"
  open c_cts19m08004 using lr_cts19m08.chave
  foreach c_cts19m08004 into lr_cts19m08.email
     if l_para is null then
        let l_para = lr_cts19m08.email
     else
        let l_para = l_para clipped, " ", lr_cts19m08.email
     end if
  end foreach
  close c_cts19m08004
  let l_assunto   = "Limite_Excedido_B14"
  #PSI-2013-23297 - Inicio
  let l_mail.de = "ct24hs.email@portoseguro.com.br"
  #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
  let l_mail.para = l_para
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = l_assunto
  let l_mail.mensagem = ""
  let l_mail.id_remetente = "CT24H"
  let l_mail.tipo = "text"

  call figrc009_attach_file(ls_laudo)
  call figrc009_mail_send1 (l_mail.*)
   returning l_coderro,msg_erro
  #PSI-2013-23297 - Fim

end function

function cts19m08_vidros_selecionados(lr_param)

define lr_param record
       vdrpbsavrfrqvlr like datmsrvext1.vdrpbsavrfrqvlr,
       vdrvgaavrfrqvlr like datmsrvext1.vdrvgaavrfrqvlr,
       vdrdiravrfrqvlr like datmsrvext1.vdrdiravrfrqvlr,
       vdresqavrfrqvlr like datmsrvext1.vdresqavrfrqvlr,
       ocudiravrfrqvlr like datmsrvext1.ocudiravrfrqvlr,
       ocuesqavrfrqvlr like datmsrvext1.ocuesqavrfrqvlr,
       dirrtravrvlr    like datmsrvext1.dirrtravrvlr,
       esqrtravrvlr    like datmsrvext1.esqrtravrvlr,
       drtfrlvlr       like datmsrvext1.drtfrlvlr,
       esqfrlvlr       like datmsrvext1.esqfrlvlr,
       drtmlhfrlvlr    like datmsrvext1.drtmlhfrlvlr,
       esqmlhfrlvlr    like datmsrvext1.esqmlhfrlvlr,
       drtnblfrlvlr    like datmsrvext1.drtnblfrlvlr,
       esqnblfrlvlr    like datmsrvext1.esqnblfrlvlr,
       drtpscvlr       like datmsrvext1.drtpscvlr,
       esqpscvlr       like datmsrvext1.esqpscvlr,
       drtlntvlr       like datmsrvext1.drtlntvlr,
       esqlntvlr       like datmsrvext1.esqlntvlr
   end record
   define lr_selec record
        pbsvig    smallint,
        lateral   smallint,
        retrov    smallint,
        farol     smallint,
        laterna   smallint
    end record
    initialize lr_selec.* to null
    # Para-Brisa
    if lr_param.vdrpbsavrfrqvlr is not null then
       let lr_selec.pbsvig = true
    end if
    # Vigia / Traseiro
    if lr_param.vdrvgaavrfrqvlr is not null then
       let lr_selec.pbsvig = true
    end if
    #Lateral Esquerdo
    if lr_param.vdresqavrfrqvlr is not null then
       let lr_selec.lateral = true
    end if
    #Lateral Direito
    if lr_param.vdrdiravrfrqvlr is not null then
       let lr_selec.lateral = true
    end if
    #Oculo Direito
    if lr_param.ocudiravrfrqvlr is not null then
      let lr_selec.lateral = true
    end if
    #Oculo Esquerdo
    if lr_param.ocuesqavrfrqvlr is not null then
       let lr_selec.lateral = true
    end if
    #Retrovisor Direito
    if lr_param.dirrtravrvlr    is not null then
       let lr_selec.retrov = true
    end if
    # Retrovisor Esquerdo
    if lr_param.esqrtravrvlr    is not null then
       let lr_selec.retrov = true
    end if
    # Farol Direito
    if lr_param.drtfrlvlr       is not null then
       let lr_selec.farol = true
    end if
    #Farol Esquerdo
    if lr_param.esqfrlvlr       is not null then
       let lr_selec.farol = true
    end if
    # Farol de Milha Direito
    if lr_param.drtmlhfrlvlr    is not null then
       let lr_selec.farol = true
    end if
    # Farol de Milha Esquerdo
    if lr_param.esqmlhfrlvlr    is not null then
       let lr_selec.farol = true
    end if
    # Farol de neblina Direito
    if lr_param.drtnblfrlvlr    is not null then
       let lr_selec.farol = true
    end if
    # Farol de neblina Esquerdo
    if lr_param.esqnblfrlvlr    is not null then
       let lr_selec.farol = true
    end if
    # Pisca Direito
    if lr_param.drtpscvlr       is not null then
       let lr_selec.laterna = true
    end if
    # Pisca Esquerdo
    if lr_param.esqpscvlr       is not null then
       let lr_selec.laterna = true
    end if
    #Laterna Direita
    if lr_param.drtlntvlr       is not null then
       let lr_selec.laterna = true
    end if
    # Laterna Esquerda
    if lr_param.esqlntvlr       is not null then
       let lr_selec.laterna = true
    end if
   return lr_selec.*
end function

#--------------------------------------------#
report rep_sinis1(r_cts19m08,lr_saldo,lr_execedido)
#--------------------------------------------#

 define r_cts19m08   record
    ligdat           date      ,
    lighorinc        datetime hour to minute,
    c24solnom        char(15),
    succod           smallint, # projeto succod
    ramcod           dec (4,0),
    aplnumdig        dec (9,0),
    itmnumdig        dec (7,0),
    viginc           date      ,
    vigfnl           date      ,
    segnom           char(50),
    segdddcod        char(04),
    segteltxt        char(20),
    clscod           char(03),
    clsdes           char(40),
    cgccpfnum        dec(12,0),
    cgcord           dec(04,0),
    cgccpfdig        dec(02,0),
    atdsrvnum        dec(10,0),
    atdsrvano        dec(02,0),
    empcod           like isskfunc.empcod,
    funmat           like isskfunc.funmat,
    funnom           like isskfunc.funnom,
    empnom           like gabkemp.empnom
 end record
 define lr_saldo record
     pbsvig    integer,
     lateral   integer,
     retrov    integer,
     farol     integer,
     laterna   integer,
     saldo_71  integer
 end record
 define lr_execedido record
     pbsvig    integer,
     lateral   integer,
     retrov    integer,
     farol     integer,
     laterna   integer,
     saldo_71  integer
 end record
 define ws2          record
    servico          char (13),
    apolice          char (30),
    cgccpf           char(40)
 end record
 output
    left   margin  00
    right  margin  80
    top    margin  00
    bottom margin  00
    page   length  70

 format

 on every row

    initialize ws2.*   to null
    let ws2.servico = r_cts19m08.atdsrvnum using "&&&&&&&",
                  "-",r_cts19m08.atdsrvano using "&&"
    let ws2.apolice = r_cts19m08.succod    using "<<<&&", "/", #"&&"        , "/", projeto succod
                      r_cts19m08.aplnumdig using "<<<<<<<& &", "/",
                      r_cts19m08.itmnumdig using "<<<<<& &"

    let ws2.cgccpf = r_cts19m08.cgccpfnum using "<<<<<<<<<<<&",
                     "/", r_cts19m08.cgcord using "&&&&",
                     "-", r_cts19m08.cgccpfdig using "&&"
    print column 001, "______________________________DADOS DA LIBERACAO _________________________"
    skip 1 line
    print column 001, "Solicitante: ", r_cts19m08.c24solnom
    print column 001, "No. Servico: ", ws2.servico,"  "
    print column 001, "Data/Hora..: ", r_cts19m08.ligdat,
                                "   ", r_cts19m08.lighorinc
    skip 1 line
    print column 001, "______________________________ DADOS DO SEGURADO _______________________________"
    skip 1 line
    print column 001, "Apolice....: ",r_cts19m08.succod    using "<<<&&", "/", #"&&"        , "/", projeto succod
                                      r_cts19m08.aplnumdig using "<<<<<<<& &", "/",
                                      r_cts19m08.itmnumdig using "<<<<<& &",
                column 040, "Vigencia...: ", r_cts19m08.viginc,
                                      " a ", r_cts19m08.vigfnl
    print column 001, "Segurado...: ",r_cts19m08.segnom
    print column 001, "CGC/CPF....: ",ws2.cgccpf
    print column 001, "Telefone...: ",r_cts19m08.segdddcod, " ", r_cts19m08.segteltxt

    skip 1 lines

    print column 001, "_________________________________ CONDICOES ____________________________________"
    skip 1 line

    print column 001, "Clausula...: ", r_cts19m08.clscod,    " - ",
                                       r_cts19m08.clsdes
    skip 1 line
    print column 025, "Saldo",
          column 042, "Excedido"
    if r_cts19m08.clscod  = "071" or
       r_cts19m08.clscod  = "077" then
       print column 001, "VIDROS.........:", lr_saldo.saldo_71 ,
             column 038, lr_execedido.saldo_71
    else
         print column 001, "Para-brisa/vigia....: ",lr_saldo.pbsvig,
               column 038,                          lr_execedido.pbsvig
         print column 001, "Lateral/oculo.......: ",lr_saldo.lateral,
               column 038,                          lr_execedido.lateral
         print column 001, "Retrovisores........: ",lr_saldo.retrov,
               column 038,                          lr_execedido.retrov
         if r_cts19m08.clscod = "076" or
            r_cts19m08.clscod = "76R" then
            print column 001, "Farol/neblina/milha.: ", lr_saldo.farol
                 ,column 038,                           lr_execedido.farol
            print column 001, "Lanterna/Pisca......: ", lr_saldo.laterna
                 ,column 038,                           lr_execedido.laterna
         end if
      end if

      skip 1 line
       print column 001, "________________________________AUTORIZADO POR _________________________________"
       skip 1 line
       print column 001,"Empresa....: ",r_cts19m08.empcod using "###" , "  " ,r_cts19m08.empnom
       print column 001,"Matricula..: ",r_cts19m08.funmat
       print column 001,"Nome.......: ",r_cts19m08.funnom
       skip 1 line

  on last row
    print ascii(12)

 end report
