#---------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                           #
#.......................................................................... #
# Sistema........: CT24H                                                    #
# Modulo         : CTS00M05                                                 #
#                  Desbloqueio de viaturas                                  #
# Analista Resp. : Glauce Lima                                              #
# PSI            : 179345                                                   #
# OSF            : 28851                                                    #
#...........................................................................#
# Desenvolvimento: Julianna, META                                           #
# Liberacao      : 17/11/2003                                               #
#.......................................................................... #
#                        * * * A L T E R A C A O * * *                      #
#  Analista Resp. : Kiandra Antonello                                       #
#  CT             : 205559                                                  #
#.......................................................................... #
#  Data        Autor Fabrica  Alteracao                                     #
#  03/05/2004  Gustavo(FSW)   Alterar   para   "C"   o   cabtip  e  incluir #
#                             lr_param.config  =  'S', antes  do  "end if", #
#                             acrescentar da linha 256 ate' 270.            #
#---------------------------------------------------------------------------#

## globals "/homedsa/fontes/ct24h/producao/glct.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"
   define m_prep_sql   smallint

   define am_cts00m05  array[300] of record
          atdvclsgl    like datkveiculo.atdvclsgl,    #codigo do veiculo
          srrcoddig    like dattfrotalocal.srrcoddig, #codigo do socorrista
          srrnom       like datksrr.srrnom,           #nome do socorrista
          c24opemat    like datkveiculo.c24opemat,    #matricula do operador
          funnom       like isskfunc.funnom           #nome do operador
   end record

   define am_cts00m05a array[300] of record
          socvclcod    like dattfrotalocal.socvclcod  #codigo do veiculo
   end record

   define m_cont   smallint

#----------------------------#
 function cts00m05_prepara()
#----------------------------#

   define l_sqlstmt  char(500)
{ CT 4096962
   let l_sqlstmt = ' select a.socvclcod, b.atdvclsgl,a.srrcoddig,b.c24opemat,',
                   '        b.c24opeempcod,b.c24opeusrtip ',
                   '   from dattfrotalocal a, datkveiculo b ',
                   '  where a.c24atvcod in ("QRV", "QRU") ',
                   '    and b.socacsflg = 1 ',
                   '    and a.socvclcod = b.socvclcod '
}
   let l_sqlstmt = ' select a.socvclcod, b.atdvclsgl,a.srrcoddig,b.c24opemat,',
                   '        b.c24opeempcod,b.c24opeusrtip ',
		   '   from dattfrotalocal a, datkveiculo b, dpaksocor c ',
		   '  where b.socacsflg = 1 ',
                   '    and a.socvclcod = b.socvclcod ',
                   '    and b.pstcoddig = c.pstcoddig'
 #CT 2012-05934/IN ,'    and c.frtrpnflg = 1' # Apenas Frota Porto Socorro


   prepare p_cts00m05_001 from l_sqlstmt
   declare c_cts00m05_001 cursor for p_cts00m05_001

   let l_sqlstmt = ' select srrnom  ',
                   '   from datksrr ',
                   '  where srrcoddig = ?'

   prepare p_cts00m05_002 from l_sqlstmt
   declare c_cts00m05_002 cursor for p_cts00m05_002

   let l_sqlstmt = ' select funnom  ',
                   '   from isskfunc ',
                   '  where funmat = ?',
                   '    and empcod = ? ',
                   '    and usrtip = ? '

   prepare p_cts00m05_003 from l_sqlstmt
   declare c_cts00m05_003 cursor for p_cts00m05_003

   let l_sqlstmt = " update datkveiculo "
                  ,"    set socacsflg = ? "
                  ,"       ,c24opemat = ? "
                  ,"       ,c24opeempcod = ? "
                  ,"       ,c24opeusrtip = ? "
                  ,"  where socvclcod = ? "

   prepare p_cts00m05_004 from l_sqlstmt

   let l_sqlstmt = " select atdsrvnum, atdsrvano "
                  ,"   from dattfrotalocal "
                  ,"  where socvclcod = ? "
   prepare pcts00m050005 from l_sqlstmt
   declare ccts00m050005 cursor for pcts00m050005

   let m_prep_sql = true

 end function
#---------------------#
 function cts00m05()
#----------------------#

   define l_bloqviat smallint,
          l_status   smallint,
          l_cademp   like datkveiculo.cademp,
          l_usrtip   like datkveiculo.atlusrtip

   if m_prep_sql is null or m_prep_sql <> true then
      call cts00m05_prepara()
   end if
   open window w_cts00m05 at 04,02 with form 'cts00m05'

   while true

      let m_cont          = 1
      let l_bloqviat      = 0

      initialize am_cts00m05   to null
      initialize am_cts00m05a  to null

      open c_cts00m05_001
      foreach c_cts00m05_001 into am_cts00m05a[m_cont].socvclcod,
                                 am_cts00m05[m_cont].atdvclsgl,
                                 am_cts00m05[m_cont].srrcoddig,
                                 am_cts00m05[m_cont].c24opemat,
                                 l_cademp,
                                 l_usrtip

           open c_cts00m05_002 using am_cts00m05[m_cont].srrcoddig
           whenever error continue
           fetch c_cts00m05_002 into am_cts00m05[m_cont].srrnom
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode < 0 then
                 error 'Erro SELECT datksrr:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
                 error 'cts00m05()/',am_cts00m05[m_cont].srrcoddig sleep 2
                 exit while
               end if
           end if

           open c_cts00m05_003 using am_cts00m05[m_cont].c24opemat,
                                    l_cademp,
                                    l_usrtip

           whenever error continue
           fetch c_cts00m05_003 into am_cts00m05[m_cont].funnom
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode < 0 then
                 error 'Erro SELECT isskfunc:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
                 error 'cts00m05()/',am_cts00m05[m_cont].c24opemat,'/',
                                     l_cademp,'/',
                                     l_usrtip  sleep 2
                 exit while
              end if
           end if

           let m_cont = m_cont + 1
           if m_cont > 300 then
              error 'Limite de array excedido' sleep 2
              exit foreach
           end if
      end foreach

      let m_cont = m_cont -  1

      if m_cont <= 0 then
         error 'Nao existem dados para serem mostrados' sleep 2
         exit while
      end if

      let l_bloqviat = m_cont

      display l_bloqviat to bloqviat

      call cts00m05_display()
           returning l_status

      if l_status then
         exit while
      end if

   end while

   let int_flag = false

   close window w_cts00m05

 end function

#-----------------------------#
 function cts00m05_display()
#-----------------------------#

   define l_arrcurr     smallint,
          l_status      smallint,
          l_retorno     char(001),
          l_atualiza    smallint
   define lr_param      record
          cabtip        char (01),  ###  Tipo do Cabecalho

          conflg        char (01),  ###  Flag Confirmacao

          linha1        char (40),

          linha2        char (40),

          linha3        char (40),

          linha4        char (40)

   end record

   define lr_veic       record
          socacsflg     like datkveiculo.socacsflg,
          c24opemat     like datkveiculo.c24opemat,
          c24opeempcod  like datkveiculo.c24opeempcod,
          c24opeusrtip  like datkveiculo.c24opeusrtip
   end record
   define lr_frota      record
          atdsrvnum     like dattfrotalocal.atdsrvnum
         ,atdsrvano     like dattfrotalocal.atdsrvano
   end record
   let int_flag         = false
   let l_status         = 0

   call set_count (m_cont)

   message "(F17)Abandona   (F8)Desbloqueia"

   display array am_cts00m05 to s_array.*

      on key(f8)
         let l_arrcurr = arr_curr()
         if g_issk.funmat = am_cts00m05[l_arrcurr].c24opemat or
            g_issk.acsnivcod > 6 then
            let lr_param.cabtip  = 'C'
            let lr_param.conflg  = 'S'
            let lr_param.linha1  = null
            let lr_param.linha2  = 'DESBLOQUEIA VIATURA'
            let lr_param.linha3  = 'SENDO ACIONADA'
            let lr_param.linha4  = null
            let l_retorno = cts08g01(lr_param.*)
            if  l_retorno = 'S' then
                let l_atualiza = false
                open ccts00m050005 using am_cts00m05a[l_arrcurr].socvclcod
                whenever error continue
                fetch ccts00m050005 into lr_frota.*
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode <> 100 then
                      error 'Problemas de acesso a tabela DATTFROTALOCAL, ',
                            sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                      error 'cts00m05()', am_cts00m05a[l_arrcurr].socvclcod sleep 2
                      exit display
                   end if
                else
                   if lr_frota.atdsrvnum is null then
                      let l_atualiza = true
                   end if
                end if
                if l_atualiza = false then
                   let lr_param.cabtip  = 'C'
                   let lr_param.conflg  = 'S'
                   let lr_param.linha1  = 'VIATURA EXECUTANDO SERVICO:'
                   let lr_param.linha2  = lr_frota.atdsrvnum using "&&&&&&&&&&", "-",
                                          lr_frota.atdsrvano using "&&"
                   let lr_param.linha3  = null
                   let lr_param.linha4  = null
                   let l_retorno = cts08g01(lr_param.*)
                end if

                initialize lr_veic  to  null
                let lr_veic.socacsflg = 0
                whenever error continue
                execute p_cts00m05_004 using lr_veic.socacsflg,
                                            lr_veic.c24opemat,
                                            lr_veic.c24opeempcod,
                                            lr_veic.c24opeusrtip,
                                            am_cts00m05a[l_arrcurr].socvclcod
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   error 'Erro UPDATE datkveiculo:',sqlca.sqlcode
                        ,'|',sqlca.sqlerrd[2] sleep 2
                   error 'cts00m05_display()/'
                        ,am_cts00m05a[l_arrcurr].socvclcod sleep 2
                   let l_status = 1
                   exit display
                end if
            end if
            let l_status = 0
            exit display
         else
            let lr_param.cabtip  = 'A'
            let lr_param.conflg  = null
            let lr_param.linha1  = 'VOCE NAO POSSUI ACESSO PARA LIBERAR'
            let lr_param.linha2  = 'ACIONAMENTO DE OUTROS OPERADORES!'
            let lr_param.linha3  = 'CONTATE SEU COORDENADOR!'
            let lr_param.linha4  = null
            let l_retorno = cts08g01(lr_param.*)
            let l_status = 0
            exit display
         end if
      on key(control-c,f17,interrupt)
        let l_status = 1
        exit display

   end display

   return l_status

 end function
