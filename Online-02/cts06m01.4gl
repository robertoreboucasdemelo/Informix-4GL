#############################################################################
# Nome do Modulo: CTS06M01                                            Pedro #
#                                                                   Marcelo #
# Cancelamento de Marcacao de Vistoria Previa Domiciliar           Jan/1995 #
#---------------------------------------------------------------------------#
# 02/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 17/10/2000  PSI 10911-8  Ruiz         Tratar o cancelamento para          #
#                                       vistoria previa roterizada.         #
#---------------------------------------------------------------------------#
#                                                                           #
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor  Fabrica  Origem    Alteracao                            #
# ---------- ------ -------  -------   -------------------------------------#
# 21/10/2004 Daniel, Meta    PSI188514 Nas chamadas da funcao cto00m00      #
#                                      passar como parametro o numero 1     #
#---------------------------------------------------------------------------#
# 15/09/2006 Zyon,Porto      PSI203637 Gravar vp mesmo dia tab consulta     #
#---------------------------------------------------------------------------#
# 30/09/2009 Eloisa,Porto    PSI242233 Envia email de cancelamento da vis-  #
#                                      toria para prestador                 #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------
 function cts06m01(par_cts06m01)
#----------------------------------------------------------

 define par_cts06m01  record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    vstc24tip         like datmvistoria.vstc24tip,
    vstdat            like datmvistoria.vstdat,
    succod            like datmvistoria.succod,
    corlignum         like dacmligass.corlignum,
    corligitmseq      like dacmligass.corligitmseq,
    vstnumdig         like datmvistoria.vstnumdig
 end record

 define d_cts06m01    record
    c24solnom         like datmvstcanc.solnom,
    c24soltipcod      like datmvstcanc.c24soltipcod,
    c24soltipdes      like datksoltip.c24soltipdes,
    canmtvdes         like datmvstcanc.canmtvdes,
    cabec             char(09),
    registro          char(43)
 end record

 define ws            record
    operacao          char(01),
    data              char(10),
    time              char(08),
    hora              char(05),
    atdhor            like datmvstcanc.atdhor,
    atddat            like datmvstcanc.atddat,
    funmat            like datmvstcanc.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    vstqtdvol         like datmvstagen.vstqtdvol,
    vstqtdc24         like datmvstagen.vstqtdc24,
    soltip            like datmvstcanc.soltip,
    erro              smallint,
    msg               char(40),
    base              smallint
 end record
 
 define l_retorno     smallint
       ,l_msgpalm     char(70)

        initialize  d_cts06m01.*  to  null

        initialize  ws.*  to  null

 open window w_cts06m01 at  12,16 with form "cts06m01"
            attribute(border, form line 1)

 initialize d_cts06m01.*   to null
 initialize ws.*           to null
 let ws.data   = today
 let ws.time   = time
 let ws.hora   = ws.time[1,05]

#---------------------------------------------
# VERIFICA SE JA EXISTE O CANCELAMENTO
#---------------------------------------------
 select canmtvdes, solnom, c24soltipcod,
        atdhor   , atddat, funmat
   into d_cts06m01.canmtvdes   , d_cts06m01.c24solnom,
        d_cts06m01.c24soltipcod, ws.atdhor           ,
        ws.atddat              , ws.funmat
   from datmvstcanc
  where atdsrvnum = par_cts06m01.atdsrvnum    and
        atdsrvano = par_cts06m01.atdsrvano

if sqlca.sqlcode = notfound   then
   let ws.operacao = "I"
else
   let ws.operacao = "M"

   initialize ws.dptsgl to null
   let ws.funnom = "** NAO CADASTRADO **"

   select funnom, dptsgl
     into ws.funnom, ws.dptsgl
     from isskfunc
    where empcod = g_issk.empcod
      and funmat = ws.funmat

   let d_cts06m01.cabec    = "Atualiz.:"
   let d_cts06m01.registro = ws.atddat," ", ws.atdhor, " ",
                             ws.dptsgl," ", ws.funnom

   select c24soltipdes
     into d_cts06m01.c24soltipdes
     from datksoltip
          where c24soltipcod = d_cts06m01.c24soltipcod

end if


input by name d_cts06m01.*   without defaults

   before field c24solnom
      display by name d_cts06m01.c24solnom attribute (reverse)

   after field c24solnom
      display by name d_cts06m01.c24solnom

      if d_cts06m01.c24solnom  is null   then
         error " Informe o nome do solicitante!"
         next field c24solnom
      end if

   before field c24soltipcod
      display by name d_cts06m01.c24soltipcod attribute (reverse)

   after field c24soltipcod
      display by name d_cts06m01.c24soltipcod

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field c24solnom
      end if

      if  d_cts06m01.c24soltipcod  is null   then
          error " Tipo do solicitante deve ser informado!"
          let d_cts06m01.c24soltipcod = cto00m00(1)
          next field c24soltipcod
      end if

      select c24soltipdes
        into d_cts06m01.c24soltipdes
        from datksoltip
             where c24soltipcod = d_cts06m01.c24soltipcod

      if  sqlca.sqlcode = notfound  then
          error " Tipo de solicitante nao cadastrado!"
          let d_cts06m01.c24soltipcod = cto00m00(1)
          next field c24soltipcod
      end if

      if  d_cts06m01.c24soltipcod < 3 then
          let ws.soltip = d_cts06m01.c24soltipdes[1,1]
      else
          let ws.soltip = "O"
      end if

      display by name d_cts06m01.c24soltipdes

   before field canmtvdes
      display by name d_cts06m01.canmtvdes    attribute (reverse)

   after field canmtvdes
      display by name d_cts06m01.canmtvdes

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field c24soltipcod
      end if

      if d_cts06m01.canmtvdes  is null   then
         error " Informe motivo do cancelamento!"
         next field canmtvdes
      end if

      #-------------------------------------------------------
      #   INCLUSAO/ALTERACAO DO CANCELAMENTO
      #-------------------------------------------------------
      if ws.operacao  =  "I"   then
        begin work
            insert into datmvstcanc (atdsrvnum, atdsrvano, canmtvdes,
                                     solnom   , soltip, c24soltipcod, atdhor   ,
                                     atddat   , funmat)
                   values  (par_cts06m01.atdsrvnum, par_cts06m01.atdsrvano,
                            d_cts06m01.canmtvdes  , d_cts06m01.c24solnom  ,
                            ws.soltip,
                            d_cts06m01.c24soltipcod  , ws.hora,   ws.data    ,
                            g_issk.funmat)

            if sqlca.sqlcode <> 0 then
               error " Erro (", sqlca.sqlcode, ") no cancelamento",
                     " da vistoria. AVISE A INFORMATICA!"
               rollback work
               exit input
            end if
            #-------------------------------------------------
            # Subtrai vistoria cancelada da quantidade do dia
            #-------------------------------------------------
            if par_cts06m01.vstc24tip  =  1  then  #nao roterizada
               declare  c_agenda  cursor for
                  select vstqtdvol, vstqtdc24
                    from datmvstagen
                   where vstdat = par_cts06m01.vstdat
                     and succod = par_cts06m01.succod
                     for update  of vstqtdvol, vstqtdc24

               foreach  c_agenda  into  ws.vstqtdvol, ws.vstqtdc24
                  exit foreach
               end foreach

               if ws.vstqtdvol  is null   then
                 error " Agenda de vistorias nao encontrada, AVISE INFORMATICA!"
                  sleep 4
                  commit work
                  exit input
               end if
            end if
            if par_cts06m01.vstc24tip  =  0    then   # roterizada
              #let ws.vstqtdvol = ws.vstqtdvol - 1
               call fvpia100(par_cts06m01.vstnumdig,
                             par_cts06m01.vstdat   ,
                             "0"                   ,
                             "C" ) returning  ws.erro, ws.msg , ws.base
            else

                #--- PSI 203637 - Cancelar tambem VP mesmo dia
                call fvpia100(par_cts06m01.vstnumdig,
                              par_cts06m01.vstdat   ,
                              "0"                   ,
                              "C" ) returning  ws.erro, ws.msg , ws.base
                #--- PSI 203637 - Cancelar tambem VP mesmo dia

               let ws.vstqtdc24 = ws.vstqtdc24 - 1
               update datmvstagen set vstqtdvol = ws.vstqtdvol,
                                      vstqtdc24 = ws.vstqtdc24
                                where vstdat    = par_cts06m01.vstdat
                                  and succod    = par_cts06m01.succod
               if sqlca.sqlcode <> 0 then
                  error " Erro (", sqlca.sqlcode, ") na alteracao da agenda.",
                        " AVISE A INFORMATICA!"
                  rollback work
                  exit input
               else
                  error " Cancelamento efetuado com sucesso!"
               end if
            end if
            #Chamada funcao para enviar vistoria via e-mail para prestadores
            ###call fvpic004_verifica_email(par_cts06m01.vstnumdig,
            ###                             par_cts06m01.atdsrvnum,
            ###                             par_cts06m01.atdsrvano,
            ###                             0)
            ###     returning l_retorno
            
            call fvpic004_envia_email(
                              par_cts06m01.atdsrvnum
                             ,par_cts06m01.atdsrvano
                             ,'C')
                    returning l_retorno
                             ,l_msgpalm
                    if l_retorno <> 0 then
                        error l_msgpalm clipped
                        sleep 2
                    end if
                    
            if  par_cts06m01.corlignum    is not null  and
                par_cts06m01.corligitmseq is not null  then
                if  not ctx08g01( par_cts06m01.corlignum   ,
                                  par_cts06m01.corligitmseq,
                                  par_cts06m01.atdsrvnum   ,
                                  par_cts06m01.atdsrvano   ,
                                  par_cts06m01.vstnumdig    )  then
                    error " Erro na gravacao do",
                    " relacionamento servico x vistoria. AVISE A INFORMATICA!"
                    rollback work
                    exit input
                end if
            end if
        commit work
      end if

      if ws.operacao  =  "M"   then
        begin work
            update datmvstcanc set (canmtvdes, solnom , soltip,c24soltipcod   ,
                                    atdhor   , atddat   , funmat)
                                 = (d_cts06m01.canmtvdes, d_cts06m01.c24solnom,
                                    ws.soltip,
                                    d_cts06m01.c24soltipcod, ws.hora, ws.data ,
                                    g_issk.funmat)
                              where atdsrvnum = par_cts06m01.atdsrvnum    and
                                    atdsrvano = par_cts06m01.atdsrvano
            if sqlca.sqlcode <> 0 then
               error " Erro (", sqlca.sqlcode, ") na alteracao",
                     " do cancelamento. AVISE A INFORMATICA!"
               rollback work
               exit input
            end if
            if  par_cts06m01.corlignum    is not null  and
                par_cts06m01.corligitmseq is not null  then
                if  not ctx08g01( par_cts06m01.corlignum   ,
                                  par_cts06m01.corligitmseq,
                                  par_cts06m01.atdsrvnum   ,
                                  par_cts06m01.atdsrvano   ,
                                  par_cts06m01.vstnumdig    )  then
                    error " Erro na gravacao do",
                    " relacionamento servico x vistoria. AVISE A INFORMATICA!"
                    rollback work
                    exit input
                end if
            end if
       commit work
      end if

   on key (interrupt)
      exit input

end input

let int_flag = false
close window  w_cts06m01

end function  #  cts06m01
