
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24h                                                 #
# Modulo         : cts25m00                                                    #
#                  Consulta todas as viatura que estao em "REC". Mostra        #
#                  calculo de distancia percorrida e previsao de chegada.      #
# Analista Resp. : Marcus Costa                                                #
#..............................................................................#
# Desenvolvimento: Fabrica de Software, Lincoln                                #
# PSI            : 130249 - Parametrizacao Acion. por Distancia 2              #
# Liberacao      : 09/Mai/2001                                                 #
#..............................................................................#
#                           * * *  ALTERACOES  * * *                           #
# PSI       Autor            Data        Alteracao                             #
# --------  ---------------  ----------  --------------------------------------#
# 140082     JUNIOR          19/10/2001   Melhoria processo operacional        #
# 150584     WAGNER          01/08/2002   Mudanca no calculo do Tempo Restante #
#                                                                              #
#                                                                              #
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------
# Alteracoes : Amaury em 13/02/2004 - CT 174530 - Inclusao with no log
#------------------------------------------------------------------------------

database porto

define a_prev array[500] of record
   atdvclsgl char(03),
   atdhorpvt char(05),
   atdprvdat char(05),
   distacn   dec(16,8),
   distqti   dec(16,8),
   decorri   interval hour(2) to minute,
   previni   interval hour(2) to minute,
   prevtot   interval hour(2) to minute
end record

define r_total record
   resumo      char(76),
   previsao_ok integer ,
   previsao_ex integer ,
   previsao_pr integer
end record

define pr_cts00m03 record
   atdprscod dec(6,0),
   atdvclsgl char(03),
   srrcoddig dec(8,0),
   socvclcod decimal(5,0),
   flag      char(01)
end record

define i           integer
define v_sqlcode   integer
define v_sql       char(500)
define v_distancia dec(16,8)
define v_hora      datetime hour to minute
define v_ordena    interval hour(2) to minute


-----------------------------------------------------------------------
function cts25m00()
-----------------------------------------------------------------------

 define volta smallint


	let	volta  =  null

 while true

   if not cts25m00_processa() then
      return
   end if

   let i = 1

   declare c_cts25m00_001 cursor with hold for
    select atdvclsgl, atdhorpvt, atdprvdat, distacn, distqti
         , decorri  , previni  , prevtot  , ordena
      from tmp_previsao
     order by prevtot

   foreach c_cts25m00_001
      into a_prev[i].atdvclsgl
         , a_prev[i].atdhorpvt
         , a_prev[i].atdprvdat
         , a_prev[i].distacn
         , a_prev[i].distqti
         , a_prev[i].decorri
         , a_prev[i].previni
         , a_prev[i].prevtot
         , v_ordena

      let i = i + 1

      if i > 500 then
         error 'Existem mais que 500 veiculos - mostrando ate 500 '
         exit foreach
      end if

   end foreach

   call set_count(i-1)

   let r_total.resumo = 'Totais - Prev. Ok : ' , r_total.previsao_ok using '&&&'
                      , '  - Excedem Prev. : ' , r_total.previsao_ex using '&&&'
                      , '  - Problema Prev. : ', r_total.previsao_pr using '&&&'

   open window w_cts25m00 at 4, 2 with form 'cts25m00' attribute(form line 1)

   display by name r_total.resumo attribute(reverse)

   let volta = false
   display array a_prev to s_cts25m00.*

      on key(f8)
         let i = arr_curr()
         call cts00m03(2,2,'','',a_prev[i].atdvclsgl,'','','')
            returning pr_cts00m03.*


      on key(f6)

        for i = 1 to 500
           initialize  a_prev[i].atdvclsgl
                     , a_prev[i].atdhorpvt
                     , a_prev[i].atdprvdat
                     , a_prev[i].distacn
                     , a_prev[i].distqti
                     , a_prev[i].decorri
                     , a_prev[i].previni
                     , a_prev[i].prevtot
                     , v_ordena to null
        end for

        let volta = true
        exit display

   end display

   close window w_cts25m00
   if volta then
      let volta = false
      continue while
   else
      exit while
   end if

 end while


end function



function cts25m00_processa()

   define r_critica record
      atdvclsgl char(03)                      ,
      atdhorpvt char(05)                      ,
      atdprvdat char(05)                      ,
      distacn   dec(16,8)                     ,
      distqti   dec(16,8)                     ,
      decorri   interval hour(2) to minute    ,
      previni   interval hour(2) to minute    ,
      prevtot   interval hour(2) to minute    ,
      atdsrvnum like dattfrotalocal.atdsrvnum ,
      atdsrvano like dattfrotalocal.atdsrvano ,
      socvclcod like dattfrotalocal.socvclcod ,
      lclltt_1  like datmfrtpos.lclltt        ,
      lcllgt_1  like datmfrtpos.lcllgt        ,
      lclltt_2  like datmfrtpos.lclltt        ,
      lcllgt_2  like datmfrtpos.lcllgt        ,
      srrltt    like datmservico.srrltt       ,
      srrlgt    like datmservico.srrlgt       ,
      atdfnlhor like datmservico.atdfnlhor    ,
      ordena    interval hour(2) to minute
   end record



	initialize  r_critica.*  to  null

   initialize i              to null
   initialize v_sqlcode      to null
   initialize v_sql          to null
   initialize r_critica.*    to null
   initialize v_distancia    to null
   initialize v_hora         to null
   initialize pr_cts00m03.*  to null
   initialize r_total.*      to null
   initialize a_prev[1].*    to null

   for i = 1 to 500
      let a_prev[i].*    = a_prev[1].*
   end for

   whenever error continue
      drop table tmp_previsao
      create temp table tmp_previsao
         ( atdvclsgl char(03)                   ,
           atdhorpvt char(05)                   ,
           atdprvdat char(05)                   ,
           distacn   dec(16,8)                  ,
           distqti   dec(16,8)                  ,
           decorri   char(6)                    ,
           previni   char(6)                    ,
           prevtot   char(6)                    ,
           atdsrvnum decimal(10,0)              ,
           atdsrvano decimal(02,0)              ,
           socvclcod decimal(05,0)              ,
           lclltt_1  decimal(08,6)              ,
           lcllgt_1  decimal(09,6)              ,
           lclltt_2  decimal(08,6)              ,
           lcllgt_2  decimal(09,6)              ,
           srrltt    decimal(08,6)              ,
           srrlgt    decimal(09,6)              ,
           atdfnlhor char(6)                    ,
           ordena    interval hour(2) to minute ) with no log  #CT174530
   whenever error stop

   if sqlca.sqlcode != 0 then
      if sqlca.sqlcode = -310 or
         sqlca.sqlcode = -958 then
         whenever error continue
            delete from tmp_previsao
         whenever error stop
         if sqlca.sqlcode != 0 then
            error 'OCORREU UM ERRO EM DelTmpPrevisao - SqlCode ',sqlca.sqlcode
            sleep 2
            return false
         end if
      else
         error 'OCORREU UM ERRO EM CreateTmpPrevisao - SqlCode ',sqlca.sqlcode
         sleep 2
         return false
      end if
   else

      whenever error continue
         create index tmpprevisao_idx1 on tmp_previsao ( ordena )
      whenever error stop

      if sqlca.sqlcode != 0 then
         error 'OCORREU UM ERRO EM CreateIndex - SqlCode ',sqlca.sqlcode
         sleep 2
         return false
      end if

   end if

   let v_sql = 'insert into tmp_previsao'
             , ' values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
   prepare p_cts25m00_001 from v_sql

   let i                   = 1
   let v_sqlcode           = 0
   let r_total.previsao_ok = 0
   let r_total.previsao_ex = 0
   let r_total.previsao_pr = 0

   declare c_cts25m00_002 cursor for
    select vc.atdvclsgl, pf.atdsrvano, pf.atdsrvnum, pf.socvclcod
      from dattfrotalocal pf , datkveiculo vc
     where pf.c24atvcod = 'REC'
       and vc.socvclcod = pf.socvclcod

   open c_cts25m00_002

   while true

      whenever error continue
         fetch c_cts25m00_002
          into r_critica.atdvclsgl
             , r_critica.atdsrvano
             , r_critica.atdsrvnum
             , r_critica.socvclcod
      whenever error stop

      if sqlca.sqlcode != 0 then
         if sqlca.sqlcode != 100 then
            let v_sqlcode = sqlca.sqlcode
            error 'OCORREU UM ERRO EM c_cts25m00_002 = ', sqlca.sqlcode using '<<<<<<'
            sleep 2
         end if
         exit while
      end if

      whenever error continue
         select lclltt, lcllgt
           into r_critica.lclltt_1, r_critica.lcllgt_1
           from datmfrtpos
          where socvclcod    = r_critica.socvclcod
            and socvcllcltip = 1
      whenever error stop

      if sqlca.sqlcode != 0 then
         let v_sqlcode = sqlca.sqlcode
         error 'Erro ',sqlca.sqlcode using '<<<<<<<<'
             , ' no acesso DATMFRTPOS(1) - Veiculo =>> ',r_critica.socvclcod
         sleep 2
         exit while
      end if

      if r_critica.lclltt_1 is null or r_critica.lclltt_1 = 0 or
         r_critica.lcllgt_1 is null or r_critica.lcllgt_1 = 0 then
         continue while
      end if

      whenever error continue
         select lclltt, lcllgt
           into r_critica.lclltt_2, r_critica.lcllgt_2
           from datmfrtpos
          where socvclcod    = r_critica.socvclcod
            and socvcllcltip = 2
      whenever error stop

      if sqlca.sqlcode != 0 then
         let v_sqlcode = sqlca.sqlcode
         error 'Erro ',sqlca.sqlcode using '<<<<<<<<'
             , ' no acesso DATMFRTPOS(2) - Veiculo =>> ',r_critica.socvclcod
         sleep 2
         exit while
      end if

      if r_critica.lclltt_2 is null or r_critica.lclltt_2 = 0 or
         r_critica.lcllgt_2 is null or r_critica.lcllgt_2 = 0 then
         continue while
      end if


      whenever error continue
         select srrltt, srrlgt, atdfnlhor, atdhorpvt, atdprvdat
           into r_critica.srrltt
              , r_critica.srrlgt
              , r_critica.atdfnlhor
              , r_critica.atdhorpvt
              , r_critica.atdprvdat
           from datmservico
          where atdsrvano = r_critica.atdsrvano
            and atdsrvnum = r_critica.atdsrvnum
      whenever error continue

      if sqlca.sqlcode != 0 then
         let v_sqlcode = sqlca.sqlcode
         error 'Erro no acesso DATMSERVICO sqlcode =',sqlca.sqlcode using '<<<<'
         sleep 2
         continue while
      end if

      if r_critica.srrltt is null or r_critica.srrltt = 0 or
         r_critica.srrlgt is null or r_critica.srrlgt = 0 then
         continue while
      end if

      if r_critica.atdhorpvt is null or
         r_critica.atdhorpvt = 0 then
         continue while
      end if

      if r_critica.atdprvdat is null or
         r_critica.atdprvdat = 0 then
         continue while
      end if


      # Calculo 1
      # Distancia no Acionamento
      #

      call cts18g00
         ( r_critica.srrltt
         , r_critica.srrlgt
         , r_critica.lclltt_2
         , r_critica.lcllgt_2 ) returning r_critica.distacn


      # Calculo 2
      # Distancia atual em relacao ao servico
      #
      call cts18g00
         ( r_critica.lclltt_1
         , r_critica.lcllgt_1
         , r_critica.lclltt_2
         , r_critica.lcllgt_2 ) returning r_critica.distqti

      # Calculo 3
      # Tempo decorrido
      #
      let v_hora            = current
      let r_critica.decorri = v_hora-r_critica.atdfnlhor


      # Calculo 4
      # Tempo restante
      #
      call cts21g00_calc_rest
         ( r_critica.distqti
         , r_critica.decorri ) returning r_critica.previni


      # Calculo 5
      # Prev Total
      #
#WWWX let r_critica.prevtot = r_critica.atdprvdat - r_critica.decorri
      let r_critica.prevtot = r_critica.atdprvdat -
                             (r_critica.decorri + r_critica.previni)

      if (r_critica.decorri + r_critica.previni) <= r_critica.atdprvdat then
         let r_total.previsao_ok = r_total.previsao_ok + 1
      else
         if r_critica.atdprvdat < (r_critica.decorri + r_critica.previni) and
            (r_critica.decorri + r_critica.previni) <= r_critica.atdhorpvt then
            let r_total.previsao_ex = r_total.previsao_ex + 1
         else
            if (r_critica.decorri + r_critica.previni) > r_critica.atdhorpvt
             then
             let r_total.previsao_pr = r_total.previsao_pr + 1
            end if
         end if
      end if

      let r_critica.ordena = r_critica.atdhorpvt - r_critica.prevtot


      {
         display ' atdvclsgl ' ,r_critica.atdvclsgl
         display ' atdhorpvt ' ,r_critica.atdhorpvt
         display ' atdprvdat ' ,r_critica.atdprvdat
         display ' distacn   ' ,r_critica.distacn
         display ' distqti   ' ,r_critica.distqti
         display ' decorri   ' ,r_critica.decorri
         display ' previni   ' ,r_critica.previni
         display ' prevtot   ' ,r_critica.prevtot
         display ' atdsrvnum ' ,r_critica.atdsrvnum
         display ' atdsrvano ' ,r_critica.atdsrvano
         display ' socvclcod ' ,r_critica.socvclcod
         display ' lclltt_1  ' ,r_critica.lclltt_1
         display ' lcllgt_1  ' ,r_critica.lcllgt_1
         display ' lclltt_2  ' ,r_critica.lclltt_2
         display ' lcllgt_2  ' ,r_critica.lcllgt_2
         display ' srrltt    ' ,r_critica.srrltt
         display ' srrlgt    ' ,r_critica.srrlgt
         display ' atdfnlhor ' ,r_critica.atdfnlhor
         display ' ordena    ' ,r_critica.ordena
      }

      whenever error continue
         execute p_cts25m00_001 using r_critica.*
      whenever error stop

      if sqlca.sqlcode != 0 then
         let v_sqlcode = sqlca.sqlcode
         error 'OCORREU UM ERRO EM P_Ins_Previsao - SqlCode ',sqlca.sqlcode
         sleep 2
         exit while
      end if

      let i = i+1

   end while

   if v_sqlcode != 0 then
      return false
   end if

   if i = 1 then
      error 'Nao existem viaturas em "REC" !!!'
      return false
      sleep 2
   end if

   return true

end function
