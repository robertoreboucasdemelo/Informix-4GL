############################################################################
# Nome do Modulo: CTS00G01                                         Marcelo #
#                                                                 Gilberto #
# Funcoes gerais da impressao remota                              Jun/1996 #
############################################################################
#                                                                          #
#  07/06/2000  PSI  108650  Ruiz  Alteracao da numercao de servicos de 6 p/#
#                                 10 posicoes.                             #
#--------------------------------------------------------------------------#
#  07/03/2006 Zeladoria    Priscila  Buscar data e hora do banco de dados  #
############################################################################
database porto

#-------------------------------------------------------------------------------
 function cts00g01_fila(param)
#-------------------------------------------------------------------------------

 define param       record
   atdsrvnum        like datmtrxfila.atdsrvnum ,
   atdsrvano        like datmtrxfila.atdsrvano ,
   atdtrxsit        like datmtrxfila.atdtrxsit
 end record

 define d_cts00g01  record
   atdtrxnum        like datmtrxfila.atdtrxnum ,
   atdtrxdat        like datmtrxfila.atdtrxdat ,
   atdtrxhor        like datmtrxfila.atdtrxhor
 end record

 define l_data      date,
        l_hora1     datetime hour to second

	initialize  d_cts00g01.*  to  null

  initialize d_cts00g01.* to null

  declare c_cts00g01_001 cursor for
    select * from datmtrxfila
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano  and
           (atdtrxsit = 1 or atdtrxsit = 2)

  open  c_cts00g01_001
  fetch c_cts00g01_001

  if sqlca.sqlcode <> NOTFOUND  then
     if sqlca.sqlcode = 0 then
        error " Ja' existe uma transmissao pendente para este servico!"
     else
        error " Erro (", sqlca.sqlcode, ") na gravacao da transmissao. ",
              "AVISE A INFORMATICA!"
     end if
  else
     declare c_cts00g01_002 cursor with hold for
       select max(atdtrxnum) from datmtrxfila

     foreach c_cts00g01_002 into d_cts00g01.atdtrxnum
        if d_cts00g01.atdtrxnum is null then
           let d_cts00g01.atdtrxnum = 0
        end if
        exit foreach
     end foreach

     let d_cts00g01.atdtrxnum = d_cts00g01.atdtrxnum + 1

     call cts40g03_data_hora_banco(1)
          returning l_data, l_hora1
     let d_cts00g01.atdtrxdat = l_data
     let d_cts00g01.atdtrxhor = l_hora1

     insert into datmtrxfila ( atdtrxnum , atdtrxsit ,
                               atdtrxdat , atdtrxhor ,
                               atdsrvnum , atdsrvano )
                      values ( d_cts00g01.atdtrxnum  ,
                               param.atdtrxsit       ,
                               d_cts00g01.atdtrxdat  ,
                               d_cts00g01.atdtrxhor  ,
                               param.atdsrvnum       ,
                               param.atdsrvano       )

     if sqlca.sqlcode <> 0 then
        error " Erro (", sqlca.sqlcode, ") na inclusao da transmissao na fila. ",
              "AVISE A INFORMATICA!"
     else
        error " *** SERVICO SENDO TRANSMITIDO PARA O PAGER, PROSSIGA ***"
     end if
  end if

end function ### cts00g01_fila


#-------------------------------------------------------------------------------
 function cts00g01_remove(param)
#-------------------------------------------------------------------------------

 define param       record
   atdsrvnum        like datmtrxfila.atdsrvnum ,
   atdsrvano        like datmtrxfila.atdsrvano ,
   atdtrxsit        like datmtrxfila.atdtrxsit
 end record

 #=====================================#
 #   LISTA DE SITUACOES DISPONIVEIS    #
 #=====================================#
 #  0  -  Transmitida com sucesso      #
 #  1  -  Aguardando transmissao       #
 #  2  -  Aguardando re-transmissao    #
 #  3  -  Erro na transmissao          #
 #  4  -  Mais de n tentativas         #
 #  5  -  Transmissao cancelada        #
 #=====================================#



  declare c_cts00g01_003 cursor for
     select * from datmtrxfila
      where atdsrvnum = param.atdsrvnum  and
            atdsrvano = param.atdsrvano  and
            (atdtrxsit = 1 or atdtrxsit = 2)
        for update of atdtrxsit

  BEGIN WORK
     open  c_cts00g01_003
     fetch c_cts00g01_003
     if sqlca.sqlcode = NOTFOUND then
      # error "Nao ha nenhuma transmissao pendente para este servico!"
     else
        if sqlca.sqlcode < 0 then
           error " Erro (", sqlca.sqlcode, ") durante acesso `a fila de transmissoes. AVISE A INFORMATICA!"
        else
           whenever error continue

           update datmtrxfila
              set atdtrxsit = param.atdtrxsit
            where current of c_cts00g01_003

           whenever error stop
           if sqlca.sqlcode <> 0 then
              error " Erro (", sqlca.sqlcode, ") na retirada do servico da fila de transmissoes. AVISE A INFORMATICA!"
              rollback work
              return
           else
              if param.atdtrxsit = 5 then
                 error " Transmissao cancelada!"
              end if
           end if
        end if
     end if
     close c_cts00g01_003
  COMMIT WORK

end function  ### cts00g01_remove


#-------------------------------------------------------------------------------
 function cts00g01_log(param)
#-------------------------------------------------------------------------------

 define param       record
   atdtrxnum        like datmtrxlog.atdtrxnum ,
   atdtrxretcod     like datmtrxlog.atdtrxretcod
 end record

 define l_data      date,
        l_hora1     datetime hour to second

 call cts40g03_data_hora_banco(1)
      returning l_data, l_hora1

   BEGIN WORK
      insert into datmtrxlog ( atdtrxnum    ,
                               atdtrxlogdat ,
                               atdtrxloghor ,
                               atdtrxretcod )
                      values ( param.atdtrxnum    ,
                               l_data             ,
                               l_hora1            ,
                               param.atdtrxretcod )
      if sqlca.sqlcode <> 0 then
         error " Erro (", sqlca.sqlcode, ") durante a gravacao do log de ",
               "transmissao. AVISE A INFORMATICA!"
         rollback work
      end if
   COMMIT WORK

end function ###  cts00g01_log
