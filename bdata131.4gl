#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : Bdata131                                                   #
# Analista Resp : Roberto Reboucas                                           #
#                 Carga dos telefones para Para a base do Marketing          #
#............................................................................#
# Desenvolvimento: Amilton Pinto / Meta                                      #
# Liberacao      : 08/06/2009                                                #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica  Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#

define m_prep smallint,
       m_data_inicial date,
       m_data_final date,
       m_mens char(200),
       m_seq  integer,
       m_qtde integer,
       m_lidos  integer,
       m_enviados integer
globals
   define g_ismqconn smallint
end globals

database porto

globals "/homedsa/projetos/geral/globals/sg_glob2.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"

main

  # -> CRIA O ARQUIVO DE LOG DO PROGRAMA
  call bdata131_cria_log()


  call fun_dba_abre_banco("CT24HS")

  set lock mode to wait 10
  set isolation to dirty read

  let m_prep = false
  let m_seq  = 0
  # Cria tabela Work

  call bdata131_cria_tab_work()

  call bdata131()

end main

#--------------------------------
function bdata131_prepare()
#--------------------------------

  define l_sql char(800)

  let l_sql = null

  let l_sql = "select a.atdsrvnum,a.atdsrvano,c.ramcod,c.succod,c.aplnumdig, ",
              " c.itmnumdig,b.dddcod, b.lcltelnum,a.atddat ",
              " from datmservico a, datmlcl b, datrservapol c " ,
              " where a.atdsrvano = b.atdsrvano " ,
              " and a.atdsrvnum = b.atdsrvnum " ,
              " and a.atdsrvano = c.atdsrvano " ,
              " and a.atdsrvnum = c.atdsrvnum " ,
              " and a.atddat between ? and ?",
              " and b.lcltelnum is not null  ",
              " and a.ciaempcod = 1 "
  prepare p_datmlcl01 from l_sql
  declare c_datmlcl01 cursor with hold for p_datmlcl01

  let l_sql = "update datkdominio set cpodes = ? where cponom = 'bdata131_data'  "
  prepare p_upt001 from l_sql

  let l_sql = " select cpodes from datkdominio where cponom = 'bdata131_data' "
  prepare p_bdata131001 from l_sql
  declare c_bdata131001 cursor with hold for p_bdata131001

  let l_sql = "select a.atdsrvnum,a.atdsrvano,c.ramcod,c.succod,c.aplnumdig, ",
              " c.itmnumdig,b.dddcod, b.ctttel,a.atddat ",
              " from datmservico a, datmreclam b, datrservapol c ",
              " where a.atdsrvano = b.atdsrvano ",
              " and a.atdsrvnum = b.atdsrvnum   ",
              " and a.atdsrvano = c.atdsrvano   ",
              " and a.atdsrvnum = c.atdsrvnum   ",
              " and a.atddat between ? and ?  ",
              " and b.ctttel is not null ",
              " and a.ciaempcod = 1 "
  prepare p_datmreclam01 from l_sql
  declare c_datmreclam01 cursor with hold for p_datmreclam01

  let l_sql = "select  a.atdsrvnum,a.atdsrvano,c.ramcod,c.succod,c.aplnumdig, ",
               " c.itmnumdig,b.dddcod, b.telnum,a.atddat ",
               " from datmservico a, datmrpt b, datrservapol c ",
               " where a.atdsrvano = b.atdsrvano ",
               " and a.atdsrvnum = b.atdsrvnum ",
               " and a.atdsrvano = c.atdsrvano ",
               " and a.atdsrvnum = c.atdsrvnum ",
               " and a.atddat between ? and ? ",
               " and b.telnum is not null ",
               " and a.ciaempcod = 1 "
  prepare p_datmrpt01 from l_sql
  declare c_datmrpt01 cursor with hold for p_datmrpt01

  let l_sql = "select sinvstnum,sinvstano,ramcod,succod,aplnumdig,itmnumdig,dddcod,teltxt, ",
              " atddat ",
              " from datmvstsin ",
              " where teltxt is not null ",
              " and teltxt <> ' ' ",
              " and atddat between ? and ? "
  prepare p_datmvstsin01 from l_sql
  declare c_datmvstsin01 cursor with hold for p_datmvstsin01

  let l_sql = " select a.atdsrvnum,a.atdsrvano,c.ramcod,c.succod,",
              " c.aplnumdig,c.itmnumdig,b.cttdddcod, ",
              " b.ctttelnum,a.atddat ",
              " from datmservico a, datmavisrent b, datrservapol c ",
              " where a.atdsrvano = b.atdsrvano ",
              " and a.atdsrvnum = b.atdsrvnum ",
              " and a.atdsrvano = c.atdsrvano ",
              " and a.atdsrvnum = c.atdsrvnum ",
              " and a.atddat between ? and ? ",
              " and b.ctttelnum is not null "
   prepare p_datmavisrent01 from l_sql
   declare c_datmavisrent01 cursor with hold for p_datmavisrent01

   let l_sql = " select a.atdsrvnum,a.atdsrvano,c.ramcod,c.succod,",
               " c.aplnumdig,c.itmnumdig,'', ",
               " b.cttteltxt,a.atddat ",
               " from datmservico a, datmfnrsrv b, datrservapol c ",
               " where a.atdsrvano = b.atdsrvano ",
               " and a.atdsrvnum = b.atdsrvnum ",
               " and a.atdsrvano = c.atdsrvano ",
               " and a.atdsrvnum = c.atdsrvnum ",
               " and a.atddat between ? and ? ",
               " and b.cttteltxt is not null "
   prepare p_datmfnrsrv01 from l_sql
   declare c_datmfnrsrv01 cursor with hold for p_datmfnrsrv01


   let l_sql = " select atdsrvnum,atdsrvano,ramcod,succod,aplnumdig, ",
               " itmnumdig,segdddcod, segteltxt,ligdat ",
               " from datmsrvext1 ",
               " where segteltxt is not null ",
               " and ligdat between ? and ? "

   prepare p_datmsrvext01 from l_sql
   declare c_datmsrvext01 cursor with hold for p_datmsrvext01

   let l_sql = " select count(*) from datmligacao ",
               " where atdsrvnum = ? ",
               " and atdsrvano = ? ",
               " and c24astcod not in ",
               "('760','860','C00','C11','C12','G11','G13','G14','H11',",
               " 'N11','Q12','RCF','V11','V12','V13','ALT','CON')"
   prepare p_bdata13103 from l_sql
   declare c_bdata13103 cursor with hold for p_bdata13103

   let l_sql = " select count(*) from datrligsinvst a, datmligacao b ",
               " where a.lignum = b.lignum and ",
               " a.sinvstnum = ? and ",
               " a.sinvstano = ? and ",
               " b.c24astcod not in ",
               "('760','860','C00','C11','C12','G11','G13','G14','H11',",
               " 'N11','Q12','RCF','V11','V12','V13','ALT','CON')"
   prepare p_bdata13104 from l_sql
   declare c_bdata13104 cursor with hold for p_bdata13104




   let m_prep = true


end function

#-------------------------------
function bdata131()
#-------------------------------

 define lr_retorno record
       erro integer,
       mens   char(200)
 end record

 define l_retorno smallint

 initialize lr_retorno.* to null
 let l_retorno = 0
 let m_data_final = today - 1 units day

 call bdata131_data_proc("S")
 returning lr_retorno.erro,
            lr_retorno.mens

 if lr_retorno.erro = 0 then
           call bdata131_exibe_info("I")
           # -> CARREGA OS TELEFONES NA TABELA AUXILIAR DO BANCO WORK
           call bdata131_carga_tmp()
              returning l_retorno
           if l_retorno = 0 then
              call bdata131_data_proc("G")
              returning lr_retorno.erro,
                        lr_retorno.mens
              let m_enviados = 0
              call bdata131_montaxml()
              call bdata131_exibe_info(" ")
           end if
 else
    call errorlog(lr_retorno.mens)
 end if

end function

#------------------------------
function bdata131_cria_log()
#------------------------------


  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdata131.log"

  call startlog(l_path)

end function

#---------------------------------------------
function bdata131_exibe_info(lr_parametro)
#---------------------------------------------

  define lr_parametro record
         tipo         char(01)
  end record

  define l_data                date,
         l_hora                datetime hour to second


  let l_data = today
  let l_hora = current

  if lr_parametro.tipo = "I" then # INICIO DO PROCESSAMENTO
     display " "
     display "-----------------------------------------------------------"
     display " INICIO bdata131 - EXPORTAÇÃO DOS TELEFONES P/ MARKETING   "
     display "-----------------------------------------------------------"
     display " "
     display " INICIO DO PROCESSAMENTO.: ", l_data, " ", l_hora
     display " PERIODO DE PROCESSAMENTO  .: ", m_data_inicial, " HÁ ", m_data_final
     display " "
     call errorlog("------------------------------------------------------")
     let m_mens = "INICIO DO PROCESSAMENTO.: ", l_data, " ", l_hora
     call errorlog(m_mens)
     let m_mens = " PERIODO DE PROCESSAMENTO  .: ", m_data_inicial, " HÁ ", m_data_final
     call errorlog(m_mens)
  else # FIM DO PROCESSAMENTO
     display " "
     display " TERMINO DO PROCESSAMENTO: ", l_data, " ", l_hora
     display " "
     let m_mens = " TERMINO DO PROCESSAMENTO: ", l_data, " ", l_hora
     call errorlog(m_mens)
     call errorlog("------------------------------------------------------")
  end if

end function


#-------------------------------#
function bdata131_cria_tab_work()
#-------------------------------#

  define l_sql char(800)


  let m_mens = null

  close database
  database work

  let l_sql =  " create table tb_tel_mkt ( ",
               " id           integer, ",
               " atdsrvnum    decimal(10,0), ",
               " atdsrvano    decimal(2,0),  ",
               " sinvstnum    decimal(6,0), ",
               " sinvstano    datetime year to year,",
               " cgccpfnum    decimal(12,0), ",
               " cgcord       decimal(4,0), " ,
               " cgccpfdig    decimal(2,0), " ,
               " succod       decimal(2,0), " ,
               " ramcod       smallint ,",
               " aplnumdig    decimal(9,0), " ,
               " itmnumdig    decimal(7,0), " ,
               " dddnum       char(4),  ",
               " telnum       char(20), ",
               " atldat       date,     ",
               " atlstt       char(1)); "

   prepare pbdata131002 from l_sql

   whenever error continue
   let l_sql = " select count(*) from tb_tel_mkt"
   prepare pbdata13105 from l_sql
   declare c_bdata13105 cursor with hold for pbdata13105
   whenever error stop

   whenever error continue
   open c_bdata13105
   whenever error stop

   if sqlca.sqlcode <> 0 then
     whenever error continue
     execute pbdata131002
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let m_mens = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
                 " ao tentar criar a tabela tb_tel_mkt. "
        call errorlog(m_mens)
     else
        whenever error continue
        create index tb_tel_mkt_ind1 on tb_tel_mkt(id,cgccpfnum,cgcord,cgccpfdig)
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let m_mens = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
                   " ao tentar criar o ind1 na tabela tb_tel_mkt."
           call errorlog(m_mens)
        end if
     end if
   end if
close database
database porto

end function

#--------------------------------
function bdata131_carga_tmp()
#--------------------------------

   define lr_dados  record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         sinvstnum like datmvstsin.sinvstnum,
         sinvstano like datmvstsin.sinvstano,
         ramcod    like datrservapol.ramcod,
         succod    like datrservapol.succod,
         aplnumdig like datrservapol.aplnumdig,
         itmnumdig like datrservapol.itmnumdig,
         ddd       like datmlcl.dddcod,
         telnum    char(20),
         atddat    like datmservico.atddat
   end record

   define lr_ramo record
       resultado smallint,
       mensagem  char(60),
       ramnom    char(30),
       ramsgl    char(15)
   end record

   define lr_dados_ret record
      cgccpfnum  like gsakpes.cgccpfnum ,
      cgcord     like gsakpes.cgcord    ,
      cgccpfdig  like gsakpes.cgccpfdig ,
      pestip     like gsakpes.pestip    ,
      pesnom     like gsakpes.pesnom
   end record

   define l_retorno1 smallint
   define l_data_inicio date,
          l_sql         char(800),
          l_qtde        integer


   let l_data_inicio = null
   let m_mens        = null
   let l_qtde        = 0
   let l_retorno1 = 0

   initialize lr_dados.*     to null
   initialize lr_ramo.*        to null
   initialize lr_dados_ret.* to null

   if m_prep is null or
      m_prep = false then
      call bdata131_prepare()
   end if


  let l_sql = "Select max(id) from work:tb_tel_mkt "
  prepare p_bdata13101 from l_sql
  declare c_bdata13101 cursor with hold for p_bdata13101

  whenever error continue
  open c_bdata13101
  fetch c_bdata13101 into m_seq
  close c_bdata13101
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let m_mens = " Erro ao selecionar sequencia "
     display m_mens
     call errorlog(m_mens)
     #exit program(1)
     call bdata131_envia_email_erro("AVISO DE ERRO BATCH - bdata131 ",m_mens)
     let l_retorno1 = 1
     return l_retorno1
  else
    if m_seq is null then
       let m_seq = 0
    end if
    let m_seq = m_seq + 1
  end if

  let l_sql = "insert into work:tb_tel_mkt values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
  prepare p_ins01 from l_sql

   # DATMLCL

   open c_datmlcl01 using m_data_inicial,m_data_final

   foreach  c_datmlcl01 into lr_dados.atdsrvnum,
                             lr_dados.atdsrvano,
                             lr_dados.ramcod,
                             lr_dados.succod,
                             lr_dados.aplnumdig,
                             lr_dados.itmnumdig,
                             lr_dados.ddd,
                             lr_dados.telnum,
                             lr_dados.atddat

            call cty10g00_descricao_ramo(lr_dados.ramcod,1)
                returning lr_ramo.resultado
                         ,lr_ramo.mensagem
                         ,lr_ramo.ramnom
                         ,lr_ramo.ramsgl

                if lr_ramo.resultado = 3 then
                   call errorlog(lr_ramo.mensagem)
                   #exit program(1)
                    call bdata131_envia_email_erro("AVISO DE ERRO BATCH - bdata131 ",lr_ramo.mensagem)
                    let l_retorno1 = 1
                    return l_retorno1
                else
                   if lr_ramo.resultado = 2 then
                      call errorlog(lr_ramo.mensagem)
                   end if
                end if


       if lr_dados.ramcod = 31 or
          lr_dados.ramcod = 531 then
             call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                               lr_dados.ramcod    ,
                                               lr_dados.aplnumdig ,
                                               lr_dados.itmnumdig ,
                                               lr_ramo.ramsgl )
              returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip

              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMLCL",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem
                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                          end if

                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"
                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                       sqlca.sqlerrd[2],
                                      " ao tentar inserir na tabela tb_tel_mkt.<datmlcl>"
                                   call errorlog(m_mens)
                                end if
                             else
                               let m_seq = m_seq + 1
                             end if
                          end if
              end if
       else
            call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                              lr_dados.ramcod    ,
                                              lr_dados.aplnumdig ,
                                              lr_dados.itmnumdig ,
                                              lr_ramo.ramsgl )
             returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip


              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMLCL",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem

                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"

                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                       sqlca.sqlerrd[2],
                                       " ao tentar inserir na tabela tb_tel_mkt.<datmlcl>"
                                    call errorlog(m_mens)
                                end if
                             else
                                 let m_seq = m_seq + 1
                             end if
                          end if
              end if
       end if
   end foreach

   close c_datmlcl01

   # datmreclam

   initialize lr_dados.*     to null
   open c_datmreclam01 using m_data_inicial,m_data_final

   foreach  c_datmreclam01 into lr_dados.atdsrvnum,
                                lr_dados.atdsrvano,
                                lr_dados.ramcod,
                                lr_dados.succod,
                                lr_dados.aplnumdig,
                                lr_dados.itmnumdig,
                                lr_dados.ddd,
                                lr_dados.telnum,
                                lr_dados.atddat

            call cty10g00_descricao_ramo(lr_dados.ramcod,1)
                returning lr_ramo.resultado
                         ,lr_ramo.mensagem
                         ,lr_ramo.ramnom
                         ,lr_ramo.ramsgl

                if lr_ramo.resultado = 3 then
                   call errorlog(lr_ramo.mensagem)
                   #exit program(1)
                    call bdata131_envia_email_erro("AVISO DE ERRO BATCH - bdata131 ",lr_ramo.mensagem)
                    let l_retorno1 = 1
                    return l_retorno1
                else
                   if lr_ramo.resultado = 2 then
                      call errorlog(lr_ramo.mensagem)
                   end if
                end if


       if lr_dados.ramcod = 31 or
          lr_dados.ramcod = 531 then
             call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                               lr_dados.ramcod    ,
                                               lr_dados.aplnumdig ,
                                               lr_dados.itmnumdig ,
                                               lr_ramo.ramsgl )
              returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip

              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMRECLAM",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem

                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                             end if

                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"
                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                 if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                       sqlca.sqlerrd[2],
                                       " ao tentar inserir na tabela tb_tel_mkt.<datmreclam>"
                                   call errorlog(m_mens)
                                 end if
                             else
                                 let m_seq = m_seq + 1
                             end if
                          end if
              end if
       else
            call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                              lr_dados.ramcod    ,
                                              lr_dados.aplnumdig ,
                                              lr_dados.itmnumdig ,
                                              lr_ramo.ramsgl )
             returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip


              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMRECLAM",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem

                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                             end if
                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"

                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                       sqlca.sqlerrd[2],
                                       " ao tentar inserir na tabela tb_tel_mkt.<datmreclam>"
                                    call errorlog(m_mens)
                                 end if
                             else
                                let m_seq = m_seq + 1
                             end if
                          end if
              end if
       end if
   end foreach
   close c_datmreclam01

   # datmrpt

   initialize lr_dados.*     to null
   open c_datmrpt01 using m_data_inicial,m_data_final

   foreach  c_datmrpt01 into lr_dados.atdsrvnum,
                             lr_dados.atdsrvano,
                             lr_dados.ramcod,
                             lr_dados.succod,
                             lr_dados.aplnumdig,
                             lr_dados.itmnumdig,
                             lr_dados.ddd,
                             lr_dados.telnum,
                             lr_dados.atddat

            call cty10g00_descricao_ramo(lr_dados.ramcod,1)
                returning lr_ramo.resultado
                         ,lr_ramo.mensagem
                         ,lr_ramo.ramnom
                         ,lr_ramo.ramsgl

                if lr_ramo.resultado = 3 then
                   call errorlog(lr_ramo.mensagem)
                   #exit program(1)
                   call bdata131_envia_email_erro("AVISO DE ERRO BATCH - bdata131 ",lr_ramo.mensagem)
                   let l_retorno1 = 1
                   return l_retorno1
                else
                   if lr_ramo.resultado = 2 then
                      call errorlog(lr_ramo.mensagem)
                   end if
                end if


       if lr_dados.ramcod = 31 or
          lr_dados.ramcod = 531 then
             call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                               lr_dados.ramcod    ,
                                               lr_dados.aplnumdig ,
                                               lr_dados.itmnumdig ,
                                               lr_ramo.ramsgl )
              returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip

              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMRPT",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem


                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                             end if
                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"
                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                       sqlca.sqlerrd[2],
                                       " ao tentar inserir na tabela tb_tel_mkt.<datmrpt>"
                                    call errorlog(m_mens)
                                end if
                             else
                               let m_seq = m_seq + 1
                             end if
                          end if
              end if
       else
            call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                              lr_dados.ramcod    ,
                                              lr_dados.aplnumdig ,
                                              lr_dados.itmnumdig ,
                                              lr_ramo.ramsgl )
             returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip


              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMRPT",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem

                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                             end if
                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"

                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                       sqlca.sqlerrd[2],
                                       " ao tentar inserir na tabela tb_tel_mkt.<datmrpt>"
                                    call errorlog(m_mens)
                                 end if
                             else
                                let m_seq = m_seq + 1
                             end if
                           end if
              end if
       end if
   end foreach
   close c_datmrpt01

   # DATMVSTSIN

   initialize lr_dados.*     to null
   open c_datmvstsin01 using m_data_inicial,m_data_final

   foreach  c_datmvstsin01 into lr_dados.sinvstnum,
                                lr_dados.sinvstano,
                                lr_dados.ramcod,
                                lr_dados.succod,
                                lr_dados.aplnumdig,
                                lr_dados.itmnumdig,
                                lr_dados.ddd,
                                lr_dados.telnum,
                                lr_dados.atddat

             if lr_dados.ramcod = 553 or
                lr_dados.ramcod = 53  then
                let lr_dados.ramcod = 531
             end if


            call cty10g00_descricao_ramo(lr_dados.ramcod,1)
                returning lr_ramo.resultado
                         ,lr_ramo.mensagem
                         ,lr_ramo.ramnom
                         ,lr_ramo.ramsgl

                if lr_ramo.resultado = 3 then
                   call errorlog(lr_ramo.mensagem)
                   #exit program(1)
                    call bdata131_envia_email_erro("AVISO DE ERRO BATCH - bdata131 ",lr_ramo.mensagem)
                    let l_retorno1 = 1
                    return l_retorno1
                else
                   if lr_ramo.resultado = 2 then
                      call errorlog(lr_ramo.mensagem)
                   end if
                end if


       if lr_dados.ramcod = 31 or
          lr_dados.ramcod = 531 then
             call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                               lr_dados.ramcod    ,
                                               lr_dados.aplnumdig ,
                                               lr_dados.itmnumdig ,
                                               lr_ramo.ramsgl )
              returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip

              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMVSTSIN",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem
                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                             end if
                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"
                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                    let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                        sqlca.sqlerrd[2],
                                        " ao tentar inserir na tabela tb_tel_mkt.<datmvstsin>"
                                     call errorlog(m_mens)
                                end if
                             else
                                let m_seq = m_seq + 1
                             end if
                           end if
              end if
       else
            call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                              lr_dados.ramcod    ,
                                              lr_dados.aplnumdig ,
                                              lr_dados.itmnumdig ,
                                              lr_ramo.ramsgl )
             returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip


              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMVSTSIN",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem

                   call errorlog (m_mens)
              else
                 call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                               lr_dados.atdsrvano,
                                               lr_dados.sinvstnum,
                                               lr_dados.sinvstano)
                  returning l_qtde
                      if l_qtde <> 0 then
                         if lr_dados_ret.cgcord is null or
                            lr_dados_ret.cgcord = " " then
                            let lr_dados_ret.cgcord = 0
                          end if
                         whenever error continue
                         execute p_ins01 using m_seq,
                                               lr_dados.atdsrvnum,
                                               lr_dados.atdsrvano,
                                               lr_dados.sinvstnum,
                                               lr_dados.sinvstano,
                                               lr_dados_ret.cgccpfnum,
                                               lr_dados_ret.cgcord,
                                               lr_dados_ret.cgccpfdig,
                                               lr_dados.succod,
                                               lr_dados.ramcod,
                                               lr_dados.aplnumdig,
                                               lr_dados.itmnumdig,
                                               lr_dados.ddd,
                                               lr_dados.telnum,
                                               lr_dados.atddat,
                                               "N"

                         whenever error stop

                         if sqlca.sqlcode <> 0 then
                            if sqlca.sqlcode <> -268 and
                               sqlca.sqlcode <> -239 then
                               let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2],
                                   " ao tentar inserir na tabela tb_tel_mkt.<datmvstsin>"
                               call errorlog(m_mens)
                            end if
                         else
                           let m_seq = m_seq + 1
                         end if
                       end if
              end if
       end if
   end foreach

   close c_datmvstsin01

   # DATMAVISRENT

   initialize lr_dados.*     to null
   open c_datmavisrent01 using m_data_inicial,m_data_final

   foreach  c_datmavisrent01 into lr_dados.atdsrvnum,
                                  lr_dados.atdsrvano,
                                  lr_dados.ramcod,
                                  lr_dados.succod,
                                  lr_dados.aplnumdig,
                                  lr_dados.itmnumdig,
                                  lr_dados.ddd,
                                  lr_dados.telnum,
                                  lr_dados.atddat

             if lr_dados.ramcod = 553 or
                lr_dados.ramcod = 53  then
                let lr_dados.ramcod = 531
             end if


            call cty10g00_descricao_ramo(lr_dados.ramcod,1)
                returning lr_ramo.resultado
                         ,lr_ramo.mensagem
                         ,lr_ramo.ramnom
                         ,lr_ramo.ramsgl

                if lr_ramo.resultado = 3 then
                   call errorlog(lr_ramo.mensagem)
                   #exit program(1)
                   call bdata131_envia_email_erro("AVISO DE ERRO BATCH - bdata131 ",lr_ramo.mensagem)
                   let l_retorno1 = 1
                   return l_retorno1
                else
                   if lr_ramo.resultado = 2 then
                      call errorlog(lr_ramo.mensagem)
                   end if
                end if


       if lr_dados.ramcod = 31 or
          lr_dados.ramcod = 531 then
             call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                               lr_dados.ramcod    ,
                                               lr_dados.aplnumdig ,
                                               lr_dados.itmnumdig ,
                                               lr_ramo.ramsgl )
              returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip

              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMAVISRENT",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem
                   call errorlog (m_mens)
              else
                 call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                               lr_dados.atdsrvano,
                                               lr_dados.sinvstnum,
                                               lr_dados.sinvstano)
                  returning l_qtde
                      if l_qtde <> 0 then
                         if lr_dados_ret.cgcord is null or
                            lr_dados_ret.cgcord = " " then
                            let lr_dados_ret.cgcord = 0
                         end if
                         whenever error continue
                         execute p_ins01 using m_seq,
                                               lr_dados.atdsrvnum,
                                               lr_dados.atdsrvano,
                                               lr_dados.sinvstnum,
                                               lr_dados.sinvstano,
                                               lr_dados_ret.cgccpfnum,
                                               lr_dados_ret.cgcord,
                                               lr_dados_ret.cgccpfdig,
                                               lr_dados.succod,
                                               lr_dados.ramcod,
                                               lr_dados.aplnumdig,
                                               lr_dados.itmnumdig,
                                               lr_dados.ddd,
                                               lr_dados.telnum,
                                               lr_dados.atddat,
                                               "N"

                         whenever error stop

                         if sqlca.sqlcode <> 0 then
                           if sqlca.sqlcode <> -268 and
                              sqlca.sqlcode <> -239 then
                               let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2],
                                   " ao tentar inserir na tabela tb_tel_mkt.<datmavisrent>"
                               call errorlog(m_mens)
                            end if
                         end if
                      end if
              end if
       else
            call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                              lr_dados.ramcod    ,
                                              lr_dados.aplnumdig ,
                                              lr_dados.itmnumdig ,
                                              lr_ramo.ramsgl )
             returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip


              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMAVISRENT",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem

                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                             end if
                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"

                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                      sqlca.sqlerrd[2],
                                      " ao tentar inserir na tabela tb_tel_mkt.<DATMAVISRENT>"
                                   call errorlog(m_mens)
                                 end if
                             else
                                let m_seq = m_seq + 1
                             end if
                           end if
              end if
       end if
   end foreach

   close c_datmavisrent01

   # DATMFNRSRV

   initialize lr_dados.*     to null
   open c_datmfnrsrv01 using m_data_inicial,m_data_final

   foreach  c_datmfnrsrv01 into lr_dados.atdsrvnum,
                                lr_dados.atdsrvano,
                                lr_dados.ramcod,
                                lr_dados.succod,
                                lr_dados.aplnumdig,
                                lr_dados.itmnumdig,
                                lr_dados.ddd,
                                lr_dados.telnum,
                                lr_dados.atddat

             if lr_dados.ramcod = 553 or
                lr_dados.ramcod = 53  then
                let lr_dados.ramcod = 531
             end if


            call cty10g00_descricao_ramo(lr_dados.ramcod,1)
                returning lr_ramo.resultado
                         ,lr_ramo.mensagem
                         ,lr_ramo.ramnom
                         ,lr_ramo.ramsgl

                if lr_ramo.resultado = 3 then
                   call errorlog(lr_ramo.mensagem)
                   #exit program(1)
                    call bdata131_envia_email_erro("AVISO DE ERRO BATCH - bdata131 ",lr_ramo.mensagem)
                    let l_retorno1 = 1
                    return l_retorno1
                else
                   if lr_ramo.resultado = 2 then

                      call errorlog(lr_ramo.mensagem)
                   end if
                end if


       if lr_dados.ramcod = 31 or
          lr_dados.ramcod = 531 then
             call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                               lr_dados.ramcod    ,
                                               lr_dados.aplnumdig ,
                                               lr_dados.itmnumdig ,
                                               lr_ramo.ramsgl )
              returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip

              if lr_ramo.resultado <> 0 then

                   let m_mens = " Tabela DATMFRNSRV",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem
                   call errorlog (m_mens)
              else
                 call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                               lr_dados.atdsrvano,
                                               lr_dados.sinvstnum,
                                               lr_dados.sinvstano)
                  returning l_qtde
                      if l_qtde <> 0 then
                         if lr_dados_ret.cgcord is null or
                            lr_dados_ret.cgcord = " " then
                            let lr_dados_ret.cgcord = 0
                         end if
                         whenever error continue
                         execute p_ins01 using m_seq,
                                               lr_dados.atdsrvnum,
                                               lr_dados.atdsrvano,
                                               lr_dados.sinvstnum,
                                               lr_dados.sinvstano,
                                               lr_dados_ret.cgccpfnum,
                                               lr_dados_ret.cgcord,
                                               lr_dados_ret.cgccpfdig,
                                               lr_dados.succod,
                                               lr_dados.ramcod,
                                               lr_dados.aplnumdig,
                                               lr_dados.itmnumdig,
                                               lr_dados.ddd,
                                               lr_dados.telnum,
                                               lr_dados.atddat,
                                               "N"
                         whenever error stop

                         if sqlca.sqlcode <> 0 then
                            if sqlca.sqlcode <> -268 and
                               sqlca.sqlcode <> -239 then
                                let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2],
                                   " ao tentar inserir na tabela tb_tel_mkt.<DATMFNRSRV>"
                                call errorlog(m_mens)
                            end if
                         else
                             let m_seq = m_seq + 1
                         end if
                       end if
              end if
       else
            call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                              lr_dados.ramcod    ,
                                              lr_dados.aplnumdig ,
                                              lr_dados.itmnumdig ,
                                              lr_ramo.ramsgl )
             returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip


              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMFRNSRV",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem

                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                             end if
                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"

                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                       sqlca.sqlerrd[2],
                                       " ao tentar inserir na tabela tb_tel_mkt.<DATMFNRSRV>"
                                    call errorlog(m_mens)
                                end if
                             else
                                let m_seq = m_seq + 1
                             end if
                           end if
              end if
       end if
   end foreach

   close c_datmfnrsrv01

   # DATMSRVEXT

   initialize lr_dados.*     to null
   open c_datmsrvext01 using m_data_inicial,m_data_final

   foreach  c_datmsrvext01 into lr_dados.atdsrvnum,
                                lr_dados.atdsrvano,
                                lr_dados.ramcod,
                                lr_dados.succod,
                                lr_dados.aplnumdig,
                                lr_dados.itmnumdig,
                                lr_dados.ddd,
                                lr_dados.telnum,
                                lr_dados.atddat

             if lr_dados.ramcod = 553 or
                lr_dados.ramcod = 53  then
                let lr_dados.ramcod = 531
             end if


            call cty10g00_descricao_ramo(lr_dados.ramcod,1)
                returning lr_ramo.resultado
                         ,lr_ramo.mensagem
                         ,lr_ramo.ramnom
                         ,lr_ramo.ramsgl

                if lr_ramo.resultado = 3 then
                   call errorlog(lr_ramo.mensagem)
                   #exit program(1)
                    call bdata131_envia_email_erro("AVISO DE ERRO BATCH - bdata131 ",lr_ramo.mensagem)
                    let l_retorno1 = 1
                    return l_retorno1
                else
                   if lr_ramo.resultado = 2 then
                      call errorlog(lr_ramo.mensagem)
                   end if
                end if


       if lr_dados.ramcod = 31 or
          lr_dados.ramcod = 531 then
             call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                               lr_dados.ramcod    ,
                                               lr_dados.aplnumdig ,
                                               lr_dados.itmnumdig ,
                                               lr_ramo.ramsgl )
              returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip

              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMSRVEXT1",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem
                   call errorlog (m_mens)
              else
                 call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                               lr_dados.atdsrvano,
                                               lr_dados.sinvstnum,
                                               lr_dados.sinvstano)
                  returning l_qtde
                      if l_qtde <> 0 then
                         if lr_dados_ret.cgcord is null or
                            lr_dados_ret.cgcord = " " then
                            let lr_dados_ret.cgcord = 0
                         end if
                         whenever error continue
                         execute p_ins01 using m_seq,
                                               lr_dados.atdsrvnum,
                                               lr_dados.atdsrvano,
                                               lr_dados.sinvstnum,
                                               lr_dados.sinvstano,
                                               lr_dados_ret.cgccpfnum,
                                               lr_dados_ret.cgcord,
                                               lr_dados_ret.cgccpfdig,
                                               lr_dados.succod,
                                               lr_dados.ramcod,
                                               lr_dados.aplnumdig,
                                               lr_dados.itmnumdig,
                                               lr_dados.ddd,
                                               lr_dados.telnum,
                                               lr_dados.atddat,
                                               "N"
                         whenever error stop

                         if sqlca.sqlcode <> 0 then
                            if sqlca.sqlcode <> -268 and
                               sqlca.sqlcode <> -239 then
                               let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2],
                                   " ao tentar inserir na tabela tb_tel_mkt.<DATMSRVEXT1>"
                                call errorlog(m_mens)
                            end if
                         else
                            let m_seq = m_seq + 1
                         end if
                       end if
              end if
       else
            call bdata131_rec_cliente_apolice(lr_dados.succod    ,
                                              lr_dados.ramcod    ,
                                              lr_dados.aplnumdig ,
                                              lr_dados.itmnumdig ,
                                              lr_ramo.ramsgl )
             returning lr_ramo.resultado        ,
                        lr_ramo.mensagem         ,
                        lr_dados_ret.cgccpfnum ,
                        lr_dados_ret.cgcord    ,
                        lr_dados_ret.cgccpfdig ,
                        lr_dados_ret.pesnom    ,
                        lr_dados_ret.pestip


              if lr_ramo.resultado <> 0 then
                   let m_mens = " Tabela DATMSRVEXT1",
                                " Sucursal = ",lr_dados.succod using '<&' , "/ " ,
                                " Apolice =  ",lr_dados.aplnumdig using '<<<<&&&&&&&' , "/ " ,
                                " item =     ",lr_dados.itmnumdig using '<<<<<<&', "/ " ,
                                " ramcod =   ",lr_dados.ramcod using '<<&', "/ " ,
                                " Erro =     ",lr_ramo.mensagem

                   call errorlog (m_mens)
              else
                     call bdata131_retiraterceiros(lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano)
                      returning l_qtde
                          if l_qtde <> 0 then
                             if lr_dados_ret.cgcord is null or
                                lr_dados_ret.cgcord = " " then
                                let lr_dados_ret.cgcord = 0
                             end if
                             whenever error continue
                             execute p_ins01 using m_seq,
                                                   lr_dados.atdsrvnum,
                                                   lr_dados.atdsrvano,
                                                   lr_dados.sinvstnum,
                                                   lr_dados.sinvstano,
                                                   lr_dados_ret.cgccpfnum,
                                                   lr_dados_ret.cgcord,
                                                   lr_dados_ret.cgccpfdig,
                                                   lr_dados.succod,
                                                   lr_dados.ramcod,
                                                   lr_dados.aplnumdig,
                                                   lr_dados.itmnumdig,
                                                   lr_dados.ddd,
                                                   lr_dados.telnum,
                                                   lr_dados.atddat,
                                                   "N"

                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                if sqlca.sqlcode <> -268 and
                                   sqlca.sqlcode <> -239 then
                                   let m_mens = "Erro: ", sqlca.sqlcode, "/",
                                       sqlca.sqlerrd[2],
                                       " ao tentar inserir na tabela tb_tel_mkt.<DATMSRVEXT1>"
                                    call errorlog(m_mens)
                                end if
                             else
                                let m_seq = m_seq + 1
                             end if
                           end if
              end if
       end if
   end foreach

   close c_datmsrvext01

   return l_retorno1


end function

#-------------------------------------------
function bdata131_data_proc(lr_tipo)
#-------------------------------------------

   define lr_tipo char(1)

   define lr_retorno record
         result  integer,
         mens char(200)
   end record

   let lr_retorno.result = 0
   let lr_retorno.mens = null

   if m_prep is null or
      m_prep = false then
      call bdata131_prepare()
   end if

   #call bdata131_prepare()

   if lr_tipo = "S" then
      open c_bdata131001
      whenever error continue
      fetch c_bdata131001 into m_data_inicial
      whenever error stop
      if sqlca.sqlcode <> 0 then
         let lr_retorno.mens = "Erro: ", sqlca.sqlcode, "/",
                               sqlca.sqlerrd[2],
                               " ao selecionar datkdominio"
         let lr_retorno.result = sqlca.sqlcode
         call errorlog(m_mens)
      else
        if m_data_inicial is null then
           let lr_retorno.result = 100
           let lr_retorno.mens = "Erro ao selecionar data na tabela datkdominio"
        else
          if m_data_inicial > m_data_final then
             let lr_retorno.result = 2
             let lr_retorno.mens = "Data inicial > ",m_data_inicial, " maior que a data final > ",
                                    m_data_final
          end if
        end if
      end if

      close c_bdata131001
   end if

   if lr_tipo = "G" then
      if m_data_final is null or
         m_data_final = " " then
         let m_mens = "Paramentro data final do processamento nulo "
         call errorlog(m_mens)

      else
        let m_data_final = today
        whenever error continue
        execute p_upt001 using m_data_final
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let lr_retorno.mens = "Erro: ", sqlca.sqlcode, "/",
                                sqlca.sqlerrd[2],
                                " ao Gravar datkdominio"
           let lr_retorno.result = sqlca.sqlcode
           let m_mens = lr_retorno.mens
           call errorlog(m_mens)
        end if
      end if
   end if

   return lr_retorno.*

end function

#--------------------------------------------------------------------------
function bdata131_rec_cliente_apolice(lr_param)
#--------------------------------------------------------------------------

define lr_param record
  succod    like gabksuc.succod          ,
  ramcod    like gtakram.ramcod          ,
  aplnumdig like abamdoc.aplnumdig       ,
  itmnumdig like abbmveic.itmnumdig      ,
  ramsgl    char(15)
end record

define lr_bdata131 record
  erro      smallint                      ,
  mens      char(70)                      ,
  emsdat    like abamdoc.emsdat           ,
  aplstt    like abamapol.aplstt          ,
  vigfnl    like abamapol.vigfnl          ,
  segnumdig like abbmdoc.segnumdig        ,
  pesnum    like gsakpes.pesnum           ,
  sgrorg    like rsamseguro.sgrorg        ,
  sgrnumdig like rsamseguro.sgrnumdig     ,
  prporg    like rsdmdocto.prporg         ,
  prpnumdig like rsdmdocto.prpnumdig      ,
  edsnumref like rsdmdocto.edsnumdig
end record


define lr_retorno record
       erro      smallint              ,
       mens      char(70)              ,
       cgccpfnum like gsakpes.cgccpfnum,
       cgcord    like gsakpes.cgcord   ,
       cgccpfdig like gsakpes.cgccpfdig,
       pesnom    like gsakpes.pesnom   ,
       pestip    like gsakpes.pestip
end record

 define lr_funapol   record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record

initialize lr_bdata131.* to null
initialize lr_retorno.* to null
initialize lr_funapol.* to null

   # Recupero as Apolices da Porto


  if lr_param.ramcod = 31  or
     lr_param.ramcod = 531 then

      # Obter Dados da Apolice de Auto

      call f_funapol_ultima_situacao
      (lr_param.succod, lr_param.aplnumdig, lr_param.itmnumdig)
       returning lr_funapol.*


       select segnumdig, edstip, clalclcod,
              viginc   , vigfnl, vclcircid
         into lr_bdata131.segnumdig
         from abbmdoc
         where abbmdoc.succod    =  lr_param.succod      and
               abbmdoc.aplnumdig =  lr_param.aplnumdig   and
               abbmdoc.itmnumdig =  lr_param.itmnumdig   and
               abbmdoc.dctnumseq =  lr_funapol.dctnumseq


        if sqlca.sqlcode = 0 then

              call osgtf550_busca_pesnum_por_unfclisegcod(lr_bdata131.segnumdig)
              returning lr_retorno.erro,
                        lr_bdata131.pesnum

              if lr_retorno.erro = 100 then
                call osgtk1001_pesquisarSeguradoPorCodigo(lr_bdata131.segnumdig)
                returning lr_retorno.erro

                if lr_retorno.erro = 0 then
                    let lr_retorno.cgccpfnum = g_r_gsakseg.cgccpfnum
                    let lr_retorno.cgcord    = g_r_gsakseg.cgcord
                    let lr_retorno.cgccpfdig = g_r_gsakseg.cgccpfdig
                    let lr_retorno.pesnom    = g_r_gsakseg.segnom
                    let lr_retorno.pestip    = g_r_gsakseg.pestip
                end if
              else
                 if lr_retorno.erro = 0 then
                      call osgtf550_busca_cliente_por_pesnum(lr_bdata131.pesnum)
                      returning lr_retorno.erro

                      if lr_retorno.erro = 0 then
                         let lr_retorno.cgccpfnum = gr_gsakpes.cgccpfnum
                         let lr_retorno.cgcord    = gr_gsakpes.cgcord
                         let lr_retorno.cgccpfdig = gr_gsakpes.cgccpfdig
                         let lr_retorno.pesnom    = gr_gsakpes.pesnom
                         let lr_retorno.pestip    = gr_gsakpes.pestip
                      end if
                 end if
              end if
        end if
  else

       # Obter dados apolice RE

       call cty06g00_dados_apolice(lr_param.succod
                                  ,lr_param.ramcod
                                  ,lr_param.aplnumdig
                                  ,lr_param.ramsgl)
       returning lr_bdata131.erro      ,
                 lr_bdata131.mens      ,
                 lr_bdata131.sgrorg    ,
                 lr_bdata131.sgrnumdig ,
                 lr_bdata131.vigfnl    ,
                 lr_bdata131.aplstt    ,
                 lr_bdata131.prporg    ,
                 lr_bdata131.prpnumdig ,
                 lr_bdata131.segnumdig ,
                 lr_bdata131.edsnumref

        if lr_bdata131.erro = 1 then
              call osgtf550_busca_pesnum_por_unfclisegcod(lr_bdata131.segnumdig)
              returning lr_retorno.erro,
                        lr_bdata131.pesnum

              if lr_retorno.erro = 100 then
                call osgtk1001_pesquisarSeguradoPorCodigo(lr_bdata131.segnumdig)
                returning lr_retorno.erro

                if lr_retorno.erro = 0 then
                    let lr_retorno.cgccpfnum = g_r_gsakseg.cgccpfnum
                    let lr_retorno.cgcord    = g_r_gsakseg.cgcord
                    let lr_retorno.cgccpfdig = g_r_gsakseg.cgccpfdig
                    let lr_retorno.pesnom    = g_r_gsakseg.segnom
                    let lr_retorno.pestip    = g_r_gsakseg.pestip
                end if
              else
                 if lr_retorno.erro = 0 then
                      call osgtf550_busca_cliente_por_pesnum(lr_bdata131.pesnum)
                      returning lr_retorno.erro

                      if lr_retorno.erro = 0 then
                         let lr_retorno.cgccpfnum = gr_gsakpes.cgccpfnum
                         let lr_retorno.cgcord    = gr_gsakpes.cgcord
                         let lr_retorno.cgccpfdig = gr_gsakpes.cgccpfdig
                         let lr_retorno.pesnom    = gr_gsakpes.pesnom
                         let lr_retorno.pestip    = gr_gsakpes.pestip
                      end if
                 end if
              end if
        end if
  end if


   if lr_retorno.cgccpfnum is null then
      let lr_retorno.mens = "Dados da Apolice nao Encontrada"
      let lr_retorno.erro = 1
   else
      let lr_retorno.erro = 0
   end if


   return lr_retorno.*

end function

#--------------------------------
function bdata131_montaxml()
#--------------------------------


   define lr_dados_work record
          id          integer,
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano,
          sinvstnum   like datmvstsin.sinvstnum,
          sinvstano   like datmvstsin.sinvstano,
          cgccpfnum   like gsakpes.cgccpfnum,
          cgcord      like gsakpes.cgcord,
          cgccpfdig   like gsakpes.cgccpfdig,
          succod      like datrservapol.succod,
          ramcod      like datrligapol.ramcod,
          aplnumdig   like datrservapol.aplnumdig,
          itmnumdig   like datrservapol.itmnumdig,
          dddnum      char(4),
          telnum      char(20)
    end record


    define lr_work_ant record
          cgccpfnum   like gsakpes.cgccpfnum,
          cgcord      like gsakpes.cgcord,
          cgccpfdig   like gsakpes.cgccpfdig
    end record


    define l_sql       char(500),
           l_xml       char(32000),
           l_qtde      integer,
           l_erro      integer,
           l_docngcdes char(60),
           l_primeiravez smallint,
           l_exist     smallint


    initialize lr_dados_work.* to null
    initialize lr_work_ant.* to null

    let l_sql         = null
    let l_xml         = null
    let m_qtde        = 0
    let m_lidos       = 0
    let l_erro        = 0
    let l_docngcdes = null
    let l_primeiravez = true
    let l_exist = false


    # Abre database Work
    close database
    database work

    let l_sql = " select id,atdsrvnum,atdsrvano,sinvstnum,sinvstano,",
                " cgccpfnum,cgcord,cgccpfdig,succod,ramcod,aplnumdig, ",
                " itmnumdig,dddnum,telnum from tb_tel_mkt ",
                " where atlstt = 'N' ",
                "order by cgccpfnum,cgcord,cgccpfdig "
    prepare p_bdata13102 from l_sql
    declare c_bdata13102 cursor with hold for p_bdata13102

    whenever error continue
    select count(*) into m_qtde from tb_tel_mkt
    whenever error stop

    open c_bdata13102

    foreach c_bdata13102 into lr_dados_work.id,
                              lr_dados_work.atdsrvnum,
                              lr_dados_work.atdsrvano,
                              lr_dados_work.sinvstnum,
                              lr_dados_work.sinvstano,
                              lr_dados_work.cgccpfnum,
                              lr_dados_work.cgcord,
                              lr_dados_work.cgccpfdig,
                              lr_dados_work.succod,
                              lr_dados_work.ramcod,
                              lr_dados_work.aplnumdig,
                              lr_dados_work.itmnumdig,
                              lr_dados_work.dddnum,
                              lr_dados_work.telnum

      let l_exist = true
      let m_lidos = m_lidos + 1
      let l_docngcdes = lr_dados_work.succod using '<&', "|",
                        lr_dados_work.ramcod using '<<&', "|",
                        lr_dados_work.aplnumdig using '<<<<&&&&&&&', "|",
                        lr_dados_work.itmnumdig using '<<<<<<&', "|"
       let l_docngcdes = l_docngcdes clipped

      if  l_primeiravez = true or
          (lr_dados_work.cgccpfnum <> lr_work_ant.cgccpfnum) or
          (lr_dados_work.cgcord    <> lr_work_ant.cgcord)    or
          (lr_dados_work.cgccpfdig <> lr_work_ant.cgccpfdig) then


            if l_primeiravez = false then
                call bdata131_finalizaxml(l_xml)
                    returning l_xml


                call bdata131_enviaxml(l_xml)
                   returning l_erro

                if l_erro = 0 then
                  let l_xml = null
                  call bdata131_exportado(lr_dados_work.cgccpfnum,
                                          lr_dados_work.cgcord,
                                          lr_dados_work.cgccpfdig)
                end if
                      call bdata131_monta_cabecalho(lr_dados_work.cgccpfnum,
                                                    lr_dados_work.cgcord,
                                                    lr_dados_work.cgccpfdig,
                                                    l_docngcdes,
                                                    lr_dados_work.dddnum,
                                                    lr_dados_work.telnum )
                       returning l_xml
                       let l_primeiravez = false
                       let lr_work_ant.cgccpfnum = lr_dados_work.cgccpfnum
                       let lr_work_ant.cgcord    = lr_dados_work.cgcord
                       let lr_work_ant.cgccpfdig = lr_dados_work.cgccpfdig

            else
               call bdata131_monta_cabecalho(lr_dados_work.cgccpfnum,
                                             lr_dados_work.cgcord,
                                             lr_dados_work.cgccpfdig,
                                             l_docngcdes,
                                             lr_dados_work.dddnum,
                                             lr_dados_work.telnum )
               returning l_xml
               let l_primeiravez = false
            end if
      else
           let l_xml = l_xml clipped
                        ,"<telefone>"  clipped
                        ,"<pesteltip>4</pesteltip>" clipped
                        ,"<dddnum>",lr_dados_work.dddnum clipped ,"</dddnum>" clipped
                        ,"<telnum>",lr_dados_work.telnum clipped ,"</telnum>" clipped
                        ,"<optintel>N</optintel>" clipped
                        ,"</telefone>" clipped
      end if

      let lr_work_ant.cgccpfnum = lr_dados_work.cgccpfnum
      let lr_work_ant.cgcord    = lr_dados_work.cgcord
      let lr_work_ant.cgccpfdig = lr_dados_work.cgccpfdig

    end foreach
    if l_exist = false then
       call errorlog("---------Não existem registros-----------")
    end if

    #call bdata131_exportado(lr_dados_work.cgccpfnum,
    #                        lr_dados_work.cgcord,
    #                        lr_dados_work.cgccpfdig)

    call bdata131_exclui_work()

    let m_mens = " TOTAL DE REGISTROS = ",m_qtde
    call errorlog(m_mens)
    let m_mens = " TOTAL DE REGISTROS LIDOS = ",m_lidos
    call errorlog(m_mens)
    let m_mens = " TOTAL DE REGISTROS ENVIADOS = ",m_enviados
    call errorlog(m_mens)

    close database
    database porto

end function

#-----------------------------------------------
function bdata131_retiraterceiros(lr_param)
#-----------------------------------------------

  define lr_param record
      atdsrvnum like datmservico.atdsrvnum,
      atdsrvano like datmservico.atdsrvano,
      sinvstnum like datmvstsin.sinvstnum,
      sinvstano like datmvstsin.sinvstano
  end record

  define l_qtde integer
  define l_sql char(500)


  let l_qtde = 0
  let l_sql = null
    if lr_param.atdsrvnum is not null then
        open c_bdata13103 using lr_param.atdsrvnum,
                                lr_param.atdsrvano
        fetch c_bdata13103 into l_qtde
    else
        open c_bdata13104 using lr_param.sinvstnum,
                                lr_param.sinvstano
        fetch c_bdata13104 into l_qtde
    end if

   return l_qtde


end function

#---------------------------------------------
function bdata131_monta_cabecalho(lr_param)
#---------------------------------------------

    define lr_param record
       cgccpfnum   like gsakpes.cgccpfnum,
       cgcord      like gsakpes.cgcord,
       cgccpfdig   like gsakpes.cgccpfdig,
       docngcdes   like gsakdocngcseg.docngcdes,
       dddnum      char(4),
       telnum      char(20)
    end record

    define l_xml char(32766)

    let l_xml = null


    let l_xml = "<?xml version='1.0' encoding='UTF-8' ?>"
               ,"<mq>" clipped
               ,"<servico>atulizardadoscadatraisclienteunificado</servico> " clipped
               ,"<chave> " clipped
                 ,"<sisorgcod>1</sisorgcod> " clipped
                 ,"<pesnum></pesnum>" clipped
                 ,"<docngcdes>", lr_param.docngcdes clipped ,"</docngcdes>" clipped
                 ,"<unfprdcod></unfprdcod>" clipped
                 ,"<cgccpfnum>",lr_param.cgccpfnum using '<<<&&&&&&&&'  ,"</cgccpfnum>" clipped
                 ,"<cgcord>"   ,lr_param.cgcord    using '<<<&' ,"</cgcord>" clipped
                 ,"<cgccpfdig>",lr_param.cgccpfdig using '&&'  ,"</cgccpfdig>" clipped
               ,"</chave>"   clipped
               ,"<cliente>"   clipped
                 ,"<pesnom></pesnom>"   clipped
                 ,"<pestip></pestip>"   clipped
                 ,"<nscdat></nscdat>"   clipped
                 ,"<pesatvcod></pesatvcod>"   clipped
                 ,"<pessexcod></pessexcod>"   clipped
                 ,"<estcvlcod></estcvlcod>"   clipped
               ,"</cliente>"   clipped
               ,"<telefones>"  clipped
                 ,"<telefone>"   clipped
                   ,"<pesteltip>4</pesteltip>"   clipped
                   ,"<dddnum>",lr_param.dddnum clipped,"</dddnum>" clipped
                   ,"<telnum>",lr_param.telnum clipped,"</telnum>" clipped
                   ,"<optintel>N</optintel>"   clipped
                 ,"</telefone>"   clipped
  return l_xml


end function

#-----------------------------------
function bdata131_enviaxml(l_xml)
#-----------------------------------

    define l_xml char(32766)

    define lr_retorno       record
          coderro         integer,
          menserro        char(30),
          mensagemRet     char(1),
          msgid           char(24),
          correlid        char(24)
    end    record

    initialize lr_retorno.* to null


 # Fila do kennedy
 # GCLCLIENTUNIJAVA01D

  call figrc006_enviar_datagrama_mq_rq('GCLCLIENTUNIJAVA01D', l_xml, '', online())
       returning lr_retorno.coderro,
                 lr_retorno.menserro,
                 lr_retorno.msgid,
                 lr_retorno.correlid


  let m_enviados = m_enviados + 1
  if lr_retorno.coderro <> 0 then
     if lr_retorno.coderro = 2033  then
       let m_mens = "ERRO MQ - Aplicacao Java fora do ar."
       call errorlog(m_mens)
     else
       let m_mens = "ERRO MQ - Envio de xml para o listener: " ,lr_retorno.coderro
                   ," mensagem = ",lr_retorno.menserro
       call errorlog(m_mens)
     end if
  end if


  return lr_retorno.coderro

end function

#---------------------------------------
function bdata131_finalizaxml(l_xml)
#---------------------------------------

define l_xml char(32766)

let l_xml = l_xml clipped, "</telefones> " clipped
                         ,"<email>" clipped
                           ,"<maides></maides>" clipped
                           ,"<pesmaitip></pesmaitip>" clipped
                           ,"<optinmail></optinmail>" clipped
                         ,"</email>" clipped
                         ,"<enderecos>" clipped
                            ,"<endereco>" clipped
                               ,"<pesendtip></pesendtip>" clipped
                               ,"<endlgdtip></endlgdtip>" clipped
                               ,"<endlgd></endlgd>" clipped
                               ,"<endnum></endnum>" clipped
                               ,"<endcmp></endcmp>" clipped
                               ,"<endcep></endcep>" clipped
                               ,"<endcepcmp></endcepcmp>" clipped
                               ,"<endbrr></endbrr>" clipped
                               ,"<endcid></endcid>" clipped
                               ,"<endufd></endufd>" clipped
                               ,"<optinend></optinend>" clipped
                            ,"</endereco>" clipped
                         ,"</enderecos>" clipped
                         ,"</mq>"    clipped

   return l_xml

end function

#---------------------------------
function bdata131_exclui_work()
#---------------------------------

 define l_sql char(100)

    let l_sql = null


    # Elimina dados com mais de 5 dias na tabela por outros erros
    let l_sql = " delete from tb_tel_mkt where atlstt = 'S' or ",
                " atldat <= today - 5  "
    prepare p_del01 from l_sql

     whenever error continue
     execute p_del01
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let m_mens = "Erro: ", sqlca.sqlcode, "/",
                      sqlca.sqlerrd[2],
                      " ao tentar deletar da tabela tb_tel_mkt."
        call errorlog(m_mens)
     else
     call errorlog("-------excluido-------")
     end if

end function

#---------------------------------------
function bdata131_exportado(lr_param)
#---------------------------------------

 define lr_param record
     cgccpfnum   like gsakpes.cgccpfnum,
     cgcord      like gsakpes.cgcord,
     cgccpfdig   like gsakpes.cgccpfdig
 end record

 define l_sql char(100)

    let l_sql = null
    let l_sql = "update tb_tel_mkt set atlstt = 'S' where cgccpfnum = ? ",
                "and cgcord = ? and cgccpfdig = ? "
    prepare p_del02 from l_sql


     if lr_param.cgcord is null or
        lr_param.cgcord = " " then
        let lr_param.cgcord = 0
     end if

     whenever error continue
     execute p_del02 using lr_param.cgccpfnum,
                           lr_param.cgcord,
                           lr_param.cgccpfdig
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let m_mens = "Erro: ", sqlca.sqlcode, "/",
                      sqlca.sqlerrd[2],
                      " ao tentar alterar da tabela tb_tel_mkt."
        call errorlog(m_mens)
     end if

end function
#------------------------------------------------#
function bdata131_envia_email_erro(lr_parametro)
#------------------------------------------------#
  define lr_parametro record
         assunto      char(150),
         msg          char(400)
  end record
 define lr_mail record
          rem     char(50),
          des     char(250),
          ccp     char(250),
          cco     char(250),
          ass     char(150),
          msg     char(32000),
          idr     char(20),
          tip     char(4)
   end record
  define l_cod_erro      integer,
         l_msg_erro      char(20)
 initialize lr_mail.* to null
     let lr_mail.des = "sistemas.madeira@portoseguro.com.br"
     let lr_mail.rem = "ZeladoriaMadeira"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = lr_parametro.assunto
     let lr_mail.idr = "bdata131"
     let lr_mail.tip = "text"
     let lr_mail.msg = lr_parametro.msg
        call figrc009_mail_send1(lr_mail.*)
           returning l_cod_erro, l_msg_erro
  if l_cod_erro = 0  then
    display l_msg_erro
  else
    display l_msg_erro
  end if
end function