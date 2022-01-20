#------------------------------------------------------------------------------#           
# Porto Seguro Cia Seguros Gerais                                              #           
#..............................................................................#           
# Sistema........: Central 24 Horas                                            #           
# Modulo.........: ctx37g00                                                    #           
# Objetivo.......: Menu de manutencao do motivo do bloqueio do socorrista.     #           
# Analista Resp. : Beatriz Araujo                                              #           
# PSI            : 21950                                                       #           
#..............................................................................#           
# Desenvolvimento: Fornax Tecnologia                                           #           
# Liberacao      : 01/10/2014                                                  #           
#..............................................................................#           
                                                                                           
globals "/homedsa/projetos/geral/globals/glct.4gl"                                        
                                                           
database porto                                                                             
                                                                                           
define m_prepare       smallint    

define m_ctx37g00      record
       srrcoddig       like datmsrratmblqpgm.srrdigcod
     , srrblqseq       like datmsrratmblqpgm.blqpgmseqnum
     , srrblqmtv       like datmsrratmblqpgm.blqmtvcod
     , srrblqdathorini like datmsrratmblqpgm.blqincdat
     , srrblqdathorfnl like datmsrratmblqpgm.blqfnldat
     , srrblqtxt       like datmsrratmblqpgm.blqpgmobstxt
     , srrblqstt       like datmsrratmblqpgm.blqpgmsitcod
     , caddat          like datmsrratmblqpgm.regcaddat
     , cademp          like datmsrratmblqpgm.regcadusrempcod
     , cadmat          like datmsrratmblqpgm.regcadusrmatnum
     , cadusrtip       like datmsrratmblqpgm.regcadusrtipcod
     , atldat          like datmsrratmblqpgm.regatldat
     , atlemp          like datmsrratmblqpgm.regatlusrempcod
     , atlmat          like datmsrratmblqpgm.regatlusrmatnum
     , atlusrtip       like datmsrratmblqpgm.regatlusrtipcod
     , srrblqsttdes    char(100)
     , srrblqmtvdes    char(100)
     , srrblqdatini    date
     , srrblqhorini    datetime hour to minute
     , srrblqdatfnl    date
     , srrblqhorfnl    datetime hour to minute
     , tempo           char(50)
     , srrblqtxt1      char(75)
     , srrblqtxt2      char(75)
     , srrblqtxt3      char(75)
     , cadfunnom       char(20)
     , funnom          char(20)
end    record

define m_cabec         record 
       srrcoddig       like datksrr.srrcoddig
     , srrnom          like datksrr.srrnom   
     , l_qual_srr      char(7)
end    record

#------------------------------------------------------------------------------#
 function ctx37g00_prepare()                        
#------------------------------------------------------------------------------#
                                                    
  define l_sql char(500)                            
                                                    
  #--> Lista de bloqueios do socorrista

  let l_sql = "select blqpgmseqnum, 1, blqincdat "
            , "  from datmsrratmblqpgm "
            , " where srrdigcod    = ? "
            , "   and blqpgmsitcod = 3 " #--> Bloqueios finalizados
            , " UNION "
            , "select blqpgmseqnum, 2, blqincdat "
            , "  from datmsrratmblqpgm "
            , " where srrdigcod    = ? "
            , "   and blqpgmsitcod = 2 " #--> Bloqueio efetivado (em curso)
            , " UNION "
            , "select blqpgmseqnum, 3, blqincdat "
            , "  from datmsrratmblqpgm "
            , " where srrdigcod    = ? "
            , "   and blqpgmsitcod = 1 " #--> Bloqueios agendados (futuro)
            , " order by 2, 3, 1       "
  prepare pctx37g00000 from l_sql                  
  declare cctx37g00000 scroll cursor for pctx37g00000 

  #--> Pesquisa ultimo bloqueio

  let l_sql = "select blqpgmseqnum "
            , "  from datmsrratmblqpgm     "
            , " where srrdigcod = ?        "
            , " order by blqpgmseqnum desc "
  prepare pctx37g00001 from l_sql                  
  declare cctx37g00001 cursor for pctx37g00001 

  #--> Pesquisa bloqueio anterior

  let l_sql = "select max(blqpgmseqnum) "
            , "  from datmsrratmblqpgm  "
            , " where srrdigcod = ?     "
            , "   and blqpgmseqnum < ?  "
  prepare pctx37g00002 from l_sql                  
  declare cctx37g00002 cursor for pctx37g00002 

  #--> Pesquisa proximo bloqueio

  let l_sql = "select min(blqpgmseqnum) "
            , "  from datmsrratmblqpgm  "
            , " where srrdigcod = ?     "
            , "   and blqpgmseqnum > ?  "
  prepare pctx37g00003 from l_sql                  
  declare cctx37g00003 cursor for pctx37g00003 

  #--> Leitura dos dados do bloqueio

  let l_sql = "select *                "
            , "  from datmsrratmblqpgm "
            , " where srrdigcod    = ? "
            , "   and blqpgmseqnum = ? "
  prepare pctx37g00004 from l_sql                  
  declare cctx37g00004 cursor for pctx37g00004 

  #--> Inclui bloqueio

  let l_sql = "insert into datmsrratmblqpgm "
	    , "values (?,0,?,?,?,?,?,?,?,?,?,?,?,?,?) "
  prepare pctx37g00005 from l_sql                  

  #--> Altera bloqueio

  let l_sql = "update datmsrratmblqpgm    "
	    , "   set blqincdat       = ? "
	    , "     , blqfnldat       = ? "
	    , "     , blqpgmobstxt    = ? "
	    , "     , regatldat       = ? "
	    , "     , regatlusrempcod = ? "
	    , "     , regatlusrmatnum = ? "
	    , "     , regatlusrtipcod = ? "
            , " where srrdigcod    = ? "
	    , "   and blqpgmseqnum = ? "
  prepare pctx37g00006 from l_sql                  

  #--> Exclui bloqueio

  let l_sql = "delete from datmsrratmblqpgm "
            , " where srrdigcod    = ? "
	    , "   and blqpgmseqnum = ? "
  prepare pctx37g00007 from l_sql                  

  let m_prepare = true          
                                
end function 

#------------------------------------------------------------------------------#
function ctx37g00_bloqueio(lr_param)
#------------------------------------------------------------------------------#

 define lr_param        record
        srrcoddig       like datksrr.srrcoddig
      , srrnom          like datksrr.srrnom
      , l_qual_srr      char(7)
 end    record

 let int_flag = false
 
 initialize m_ctx37g00.* to null

#if not get_niv_mod(g_issk.prgsgl, "ctx37g00") then
#   error " Modulo sem nivel de consulta e atualizacao!"
#   return
#end if

 if m_prepare is null or m_prepare <> true then
   call ctx37g00_prepare()
 end if

 open window ctx37g00 at 04,02 with form "ctx37g00"

 message ""

 clear form

 let m_cabec.srrcoddig  = lr_param.srrcoddig
 let m_cabec.srrnom     = lr_param.srrnom   
 let m_cabec.l_qual_srr = lr_param.l_qual_srr

 open cctx37g00000 using lr_param.srrcoddig, lr_param.srrcoddig, lr_param.srrcoddig

 call ctx37g00_ler(lr_param.srrcoddig,'')

 call ctx37g00_display()

 menu "BLOQUEIO"

 before menu
        hide option all
        if g_issk.acsnivcod >= g_issk.acsnivcns  then
           show option "Proximo", "Anterior"
        end if
        if g_issk.acsnivcod >= g_issk.acsnivatl  then
           show option "Inclui", "eXclui", "Modifica", "Proximo", "Anterior"
        end if
        show option "Encerra"

 command key ("I") "Inclui"
                   "Inclui bloqueio para o socorrista"
         message ""
         initialize m_ctx37g00.* to null
	 call ctx37g00_display()
         call ctx37g00_inclui(lr_param.srrcoddig)

 command key ("X") "eXclui" 
                   "Exclui bloqueio do socorrista"
         message ""
         call ctx37g00_exclui(lr_param.srrcoddig,m_ctx37g00.srrblqseq)

 command key ("M") "Modifica"
                   "Modifica bloqueio do socorrista"
         message ""
         call ctx37g00_modifica(lr_param.srrcoddig,m_ctx37g00.srrblqseq)

 command key ("P") "Proximo"
                   "Mostra proximo bloqueio do socorrista"
         message ""
         call ctx37g00_proximo(lr_param.srrcoddig,m_ctx37g00.srrblqseq)

 command key ("A") "Anterior"
                   "Mostra bloqueio anterior do socorrista"
         message ""
         call ctx37g00_anterior(lr_param.srrcoddig,m_ctx37g00.srrblqseq)

 command key (interrupt,E) "Encerra"
                           "Retorna ao menu anterior"
         exit menu

 end menu

 close window ctx37g00

end function

#------------------------------------------------------------------------------#
 function ctx37g00_ler(param)
#------------------------------------------------------------------------------#

 define param         record
        srrcoddig     like datmsrratmblqpgm.srrdigcod
      , srrblqseq     like datmsrratmblqpgm.blqpgmseqnum
 end    record

 define lr_aux        record
        srrblqseq     like datmsrratmblqpgm.blqpgmseqnum
      , srrblqstt     like datmsrratmblqpgm.blqpgmsitcod
 end    record

 define l_data_hora   char(16)
 define l_data        char(10)
 define l_hora        char(05)

 if param.srrblqseq is null then

    whenever error continue
    fetch FIRST cctx37g00000 into lr_aux.srrblqseq
    whenever error stop

    if sqlca.sqlcode = notfound then
       initialize m_ctx37g00.* to null 
       let m_ctx37g00.srrcoddig = param.srrcoddig
       error " Nenhum bloqueio encontrado para o socorrista!"
       return 
    end if 

    let param.srrblqseq = lr_aux.srrblqseq
 end if 

 open cctx37g00004 using param.srrcoddig
                       , param.srrblqseq
 whenever error continue
 fetch cctx37g00004 into m_ctx37g00.*
 whenever error stop

 if sqlca.sqlcode <> 0 then
    error " Erro na leitura do bloqueio!"
	, " (Erro:",  sqlca.sqlcode   using "<<<<<<"
	, " , Soc.:", param.srrcoddig using "<<<<<<"
	, " , Seq.:", param.srrblqseq using "<<<<<<"
	, ")"
    return
 end if 

 let l_data_hora = m_ctx37g00.srrblqdathorini
 let l_data = l_data_hora[09,10],"/",l_data_hora[06,07],"/",l_data_hora[01,04]
 let l_hora = l_data_hora[12,13],":",l_data_hora[15,16]
 let m_ctx37g00.srrblqdatini = l_data
 let m_ctx37g00.srrblqhorini = l_hora

 let l_data_hora = m_ctx37g00.srrblqdathorfnl
 let l_data = l_data_hora[09,10],"/",l_data_hora[06,07],"/",l_data_hora[01,04]
 let l_hora = l_data_hora[12,13],":",l_data_hora[15,16]
 let m_ctx37g00.srrblqdatfnl = l_data
 let m_ctx37g00.srrblqhorfnl = l_hora

 let m_ctx37g00.srrblqtxt1 = m_ctx37g00.srrblqtxt[001,075]
 let m_ctx37g00.srrblqtxt2 = m_ctx37g00.srrblqtxt[076,150]
 let m_ctx37g00.srrblqtxt3 = m_ctx37g00.srrblqtxt[151,225]

end function

#------------------------------------------------------------------------------#
 function ctx37g00_proximo(param)
#------------------------------------------------------------------------------#

 define param        record
        srrcoddig    like datmsrratmblqpgm.srrdigcod
      , srrblqseq    like datmsrratmblqpgm.blqpgmseqnum
 end    record

 whenever error continue
 fetch NEXT cctx37g00000 into param.srrblqseq
 whenever error stop

 if sqlca.sqlcode = 0 then
    call ctx37g00_ler(param.srrcoddig,param.srrblqseq)
 else
    error " Nao ha' bloqueio nesta direcao!"
 end if

 call ctx37g00_display()

end function

#------------------------------------------------------------------------------#
 function ctx37g00_anterior(param)
#------------------------------------------------------------------------------#

 define param        record
        srrcoddig    like datmsrratmblqpgm.srrdigcod
      , srrblqseq    like datmsrratmblqpgm.blqpgmseqnum
 end    record

 whenever error continue
 fetch PREVIOUS cctx37g00000 into param.srrblqseq
 whenever error stop

 if sqlca.sqlcode = 0 then
    call ctx37g00_ler(param.srrcoddig,param.srrblqseq)
 else
    error " Nao ha' bloqueio nesta direcao!"
 end if

 call ctx37g00_display()

end function

#------------------------------------------------------------------------------#
 function ctx37g00_posiciona(param)
#------------------------------------------------------------------------------#

 define param        record
        srrcoddig    like datksrr.srrcoddig
      , srrblqseq    like datmsrratmblqpgm.blqpgmseqnum
 end    record

 define l_srrblqseq  like datmsrratmblqpgm.blqpgmseqnum

 let l_srrblqseq = ""

 if param.srrblqseq is not null then 

    close cctx37g00000

    open cctx37g00000 using param.srrcoddig, param.srrcoddig, param.srrcoddig

    while true

        whenever error continue
        fetch NEXT cctx37g00000 into l_srrblqseq
        whenever error stop
        if sqlca.sqlcode <> 0 then 
           exit while
        end if

        if l_srrblqseq <> param.srrblqseq then
           continue while
        end if 

        exit while

    end while

 end if 

 call ctx37g00_ler(param.srrcoddig,l_srrblqseq)

 call ctx37g00_display ()

end function

#------------------------------------------------------------------------------#
 function ctx37g00_display()
#------------------------------------------------------------------------------#

 define l_erro       smallint
      , l_mensagem   char(200)
      , l_lixo       char(100)

 display by name m_cabec.srrcoddig
 display by name m_cabec.srrnom
 display by name m_cabec.l_qual_srr

 display by name m_ctx37g00.srrblqmtv

 call cty38g00_datkdominio('blqmtvcod',m_ctx37g00.srrblqmtv)
      returning l_erro
              , l_mensagem
              , m_ctx37g00.srrblqmtvdes

 display by name m_ctx37g00.srrblqmtvdes

 if m_ctx37g00.srrblqstt is not null and m_ctx37g00.srrblqstt <> 0 then
    call cty38g00_datkdominio('blqpgmsitcod',m_ctx37g00.srrblqstt)
         returning l_erro
                 , l_mensagem
                 , m_ctx37g00.srrblqsttdes
    display by name m_ctx37g00.srrblqsttdes attribute (reverse)
 else
    display by name m_ctx37g00.srrblqsttdes
 end if 

 display by name m_ctx37g00.srrblqdatini
 display by name m_ctx37g00.srrblqhorini
 display by name m_ctx37g00.srrblqdatfnl
 display by name m_ctx37g00.srrblqhorfnl

 let m_ctx37g00.tempo = cty38g00_tempo ( m_ctx37g00.srrblqdathorini
                                       , m_ctx37g00.srrblqdathorfnl )

 display by name m_ctx37g00.tempo

 display by name m_ctx37g00.srrblqtxt1
 display by name m_ctx37g00.srrblqtxt2
 display by name m_ctx37g00.srrblqtxt3

 call F_FUNGERAL_USR (m_ctx37g00.cadmat
		     ,m_ctx37g00.cademp
                     ,m_ctx37g00.cadusrtip
                     ,'','')
      returning l_lixo
	      , l_lixo
	      , m_ctx37g00.cadfunnom 
	      , l_lixo

 display by name m_ctx37g00.caddat
 display by name m_ctx37g00.cadfunnom 

 call F_FUNGERAL_USR (m_ctx37g00.atlmat
		     ,m_ctx37g00.atlemp
                     ,m_ctx37g00.atlusrtip
                     ,'','')
      returning l_lixo
	      , l_lixo
	      , m_ctx37g00.funnom 
	      , l_lixo

 display by name m_ctx37g00.atldat
 display by name m_ctx37g00.funnom 

end function

#------------------------------------------------------------------------------#
 function ctx37g00_inclui(param)
#------------------------------------------------------------------------------#

 define param        record
        srrcoddig    like datksrr.srrcoddig
 end    record

 define lr_aux       record
        srrblqseq    like datmsrratmblqpgm.blqpgmseqnum
      , srrblqstt    like datmsrratmblqpgm.blqmtvcod
 end    record 

 define l_resp       char(1)

 initialize l_resp 
	  , lr_aux.*
	  , m_ctx37g00.* to null

 let m_ctx37g00.srrblqstt = 1 
 let m_ctx37g00.caddat    = today 
 let m_ctx37g00.cademp    = g_issk.empcod
 let m_ctx37g00.cadmat    = g_issk.funmat
 let m_ctx37g00.cadusrtip = g_issk.usrtip

 let int_flag = false

 call ctx37g00_input("i",param.srrcoddig,0)

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    call ctx37g00_posiciona (param.srrcoddig,"")
    return
 end if

 begin work

 whenever error continue 
 execute pctx37g00005 using param.srrcoddig
			  , m_ctx37g00.srrblqmtv
			  , m_ctx37g00.srrblqdathorini
			  , m_ctx37g00.srrblqdathorfnl
			  , m_ctx37g00.srrblqtxt
			  , m_ctx37g00.srrblqstt
			  , m_ctx37g00.caddat
			  , m_ctx37g00.cademp
			  , m_ctx37g00.cadmat
			  , m_ctx37g00.cadusrtip
			  , m_ctx37g00.atldat
			  , m_ctx37g00.atlemp
			  , m_ctx37g00.atlmat
			  , m_ctx37g00.atlusrtip
 whenever error stop

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode using '<<<<&' ,") na inclusao do bloqueio!"
    rollback work
    return
 end if

 let lr_aux.srrblqseq = sqlca.sqlerrd[2]

 commit work

 error " Inclusao de bloqueio efetuada com sucesso, tecle ENTER!"

 prompt "" for char l_resp

 call ctx37g00_posiciona (param.srrcoddig,lr_aux.srrblqseq)

end function

#------------------------------------------------------------------------------#
 function ctx37g00_modifica(param)
#------------------------------------------------------------------------------#

 define param        record
        srrcoddig    like datksrr.srrcoddig
      , srrblqseq    like datmsrratmblqpgm.blqpgmseqnum
 end    record

 define l_resp       char(1)

 initialize l_resp to null 

 if m_ctx37g00.srrblqstt = 3 then 
    error " Bloqueio finalizado nao pode ser alterado! "
    return 
 end if 

 let m_ctx37g00.atldat    = today 
 let m_ctx37g00.atlemp    = g_issk.empcod
 let m_ctx37g00.atlmat    = g_issk.funmat
 let m_ctx37g00.atlusrtip = g_issk.usrtip

 let int_flag = false

 call ctx37g00_input("a",param.srrcoddig,param.srrblqseq)

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    return
 end if

 begin work

 whenever error continue 
 execute pctx37g00006 using m_ctx37g00.srrblqdathorini
			  , m_ctx37g00.srrblqdathorfnl
			  , m_ctx37g00.srrblqtxt
			  , m_ctx37g00.atldat
			  , m_ctx37g00.atlemp
			  , m_ctx37g00.atlmat
			  , m_ctx37g00.atlusrtip
			  , param.srrcoddig
			  , param.srrblqseq 
 whenever error stop

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode using '<<<<&' ,") na alteracao do bloqueio!"
    rollback work
    return
 end if

 commit work

 error " Alteracao de bloqueio efetuada com sucesso, tecle ENTER!"

 prompt "" for char l_resp

 call ctx37g00_posiciona (param.srrcoddig,param.srrblqseq)

end function

#------------------------------------------------------------------------------#
 function ctx37g00_exclui(param)
#------------------------------------------------------------------------------#

 define param        record
        srrcoddig    like datksrr.srrcoddig
      , srrblqseq    like datmsrratmblqpgm.blqpgmseqnum
 end    record

 define l_resp       char(1)

 initialize l_resp to null 

 if m_ctx37g00.srrblqstt = 3 then 
    error " Bloqueio finalizado nao pode ser excluido! "
    return 
 end if

 if m_ctx37g00.srrblqstt = 2 then 
    error " Bloqueio em curso nao pode ser excluido! "
    return 
 end if

 while true 
     prompt "Confirma exclusao do bloqueio ? (S/N) " for char l_resp
     if l_resp = "S" or l_resp = "N" or l_resp = "s" or l_resp = "n" then 
	exit while
     end if 
 end while 

 if l_resp = "N" or l_resp = "n" then 
    error " Operacao cancelada!"
    return
 end if

 begin work

 whenever error continue 
 execute pctx37g00007 using param.srrcoddig
			  , param.srrblqseq 
 whenever error stop

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode using '<<<<&' ,") na exclusao do bloqueio!"
    rollback work
    return
 end if

 commit work

 error " Exclusao de bloqueio efetuada com sucesso, tecle ENTER!"

 prompt "" for char l_resp

 call ctx37g00_posiciona (param.srrcoddig,"")

end function

#------------------------------------------------------------------------------#
 function ctx37g00_input(param)
#------------------------------------------------------------------------------#

 define param        record
        operacao     char (01)
      , srrcoddig    like datksrr.srrcoddig
      , srrblqseq    like datmsrratmblqpgm.blqpgmseqnum
 end    record

 define l_erro       smallint
      , l_mensagem   char(200)
      , l_data_hora  char(16)
      , l_resp       char(1)

 define lr_ant       record
        srrblqmtv    like datmsrratmblqpgm.blqmtvcod
      , srrblqdatini date
      , srrblqhorini datetime hour to minute
 end    record 

 let lr_ant.srrblqmtv    = m_ctx37g00.srrblqmtv
 let lr_ant.srrblqdatini = m_ctx37g00.srrblqdatini
 let lr_ant.srrblqhorini = m_ctx37g00.srrblqhorini

 input by name m_ctx37g00.srrblqmtv
             , m_ctx37g00.srrblqdatini
             , m_ctx37g00.srrblqhorini
             , m_ctx37g00.srrblqdatfnl
             , m_ctx37g00.srrblqhorfnl
             , m_ctx37g00.srrblqtxt1
             , m_ctx37g00.srrblqtxt2
             , m_ctx37g00.srrblqtxt3 without defaults

    before input 
	   if param.operacao = 'a' then
	      if m_ctx37g00.srrblqstt = 2 then 
                 initialize l_resp to null 
                 error " Nao sera possivel alterar o motivo e data/hora inicial. Tecle enter!"
                 prompt "" for char l_resp
                 next field srrblqdatfnl
              end if
           end if

    before field srrblqmtv
           display by name m_ctx37g00.srrblqmtv attribute (reverse)

    after  field srrblqmtv
           display by name m_ctx37g00.srrblqmtv

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srrblqmtv 
           end if

	   if param.operacao = 'a' then
	      if m_ctx37g00.srrblqstt = 2 then 
	         if m_ctx37g00.srrblqmtv <> lr_ant.srrblqmtv then 
                    error " Nao e possivel alterar o motivo de um bloqueio em curso!" 
		    let m_ctx37g00.srrblqmtv = lr_ant.srrblqmtv
                    display by name m_ctx37g00.srrblqmtv
                    next field srrblqmtv 
                 end if
              end if
           end if 

           if m_ctx37g00.srrblqmtv is null then

              call cty38g00_popup_datkdominio("Motivo do bloqueio", "blqmtvcod")
                   returning m_ctx37g00.srrblqmtv

	      if m_ctx37g00.srrblqmtv is null then 
                 error " Motivo do bloqueio deve ser informado!"
		 next field srrblqmtv
              end if
           end if

           call cty38g00_datkdominio('blqmtvcod',m_ctx37g00.srrblqmtv)
		returning l_erro
                        , l_mensagem
                        , m_ctx37g00.srrblqmtvdes
	   if l_erro > 1 then 
	      error l_mensagem clipped
	      next field srrblqmtv
           end if 

	   display by name m_ctx37g00.srrblqmtv
	   display by name m_ctx37g00.srrblqmtvdes

    before field srrblqdatini
           display by name m_ctx37g00.srrblqdatini attribute (reverse)

    after  field srrblqdatini
           display by name m_ctx37g00.srrblqdatini

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srrblqmtv
           end if

           if m_ctx37g00.srrblqdatini is null then 
              error " O inicio do bloqueio deve ser informado, ou tecle (F5)!"
              next field srrblqdatini
           end if

	   if param.operacao = 'a' then
	      if m_ctx37g00.srrblqstt = 2 then 
	         if m_ctx37g00.srrblqdatini <> lr_ant.srrblqdatini then 
                    error " Nao e possivel alterar a data de inicio de um bloqueio em curso!" 
		    let m_ctx37g00.srrblqdatini = lr_ant.srrblqdatini
                    display by name m_ctx37g00.srrblqdatini
                    next field srrblqdatini
                 end if
              end if
           end if 

           if m_ctx37g00.srrblqdatini < today then 
	      if (param.operacao = 'i') or
		 (param.operacao = 'a' and m_ctx37g00.srrblqdatini <> lr_ant.srrblqdatini)
              then 
                 error " O inicio do bloqueio nao pode ser anterior a hoje!"
                 next field srrblqdatini
              end if
           end if

           let m_ctx37g00.tempo = ""

           display by name m_ctx37g00.tempo

    before field srrblqhorini
           display by name m_ctx37g00.srrblqhorini attribute (reverse)

    after  field srrblqhorini
           display by name m_ctx37g00.srrblqhorini

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srrblqdatini
           end if

           if m_ctx37g00.srrblqhorini is null then 
              error " O inicio do bloqueio deve ser informado, ou tecle (F5)!"
              next field srrblqhorini
           end if

	   if param.operacao = 'a' then
	      if m_ctx37g00.srrblqstt = 2 then 
	         if m_ctx37g00.srrblqhorini <> lr_ant.srrblqhorini then 
                    error " Nao e possivel alterar a hora de inicio de um bloqueio em curso!" 
		    let m_ctx37g00.srrblqhorini = lr_ant.srrblqhorini
                    display by name m_ctx37g00.srrblqhorini
                    next field srrblqhorini
                 end if
              end if
           end if 

           if m_ctx37g00.srrblqdatini = today then
	      if (m_ctx37g00.srrblqhorini + 1 units minute) < current then 
	         if (param.operacao = 'i') or
		    (param.operacao = 'a' and m_ctx37g00.srrblqhorini <> lr_ant.srrblqhorini)
                 then 
                    error " O inicio do bloqueio nao pode ser anterior a hora atual!"
                    next field srrblqhorini
                 end if
              end if
           end if

           let l_data_hora = year (m_ctx37g00.srrblqdatini) using "&&&&", "-"
                           , month(m_ctx37g00.srrblqdatini) using "&&"  , "-"
                           , day  (m_ctx37g00.srrblqdatini) using "&&"  , " "
                           , m_ctx37g00.srrblqhorini

           let m_ctx37g00.srrblqdathorini = l_data_hora

           if cty38g00_conflito_bloqueio(param.srrcoddig
				        ,param.srrblqseq
				        ,m_ctx37g00.srrblqdathorini)
	   then 
              error " O inicio deste bloqueio conflita com bloqueio ja cadastrado. Verifique!"
              next field srrblqdatini
           end if

    before field srrblqdatfnl
           display by name m_ctx37g00.srrblqdatfnl attribute (reverse)

    after  field srrblqdatfnl
           display by name m_ctx37g00.srrblqdatfnl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
	      if param.operacao = 'a' and m_ctx37g00.srrblqstt = 2 then 
                 error " Nao sera possivel alterar o motivo e data/hora inicial!"
                 next field srrblqdatfnl
              else
                 next field srrblqhorini
              end if
           end if

           if m_ctx37g00.srrblqdatfnl is null then 
              error " O final do bloqueio deve ser informado, ou tecle (F5)!"
              next field srrblqdatfnl
           end if

           if m_ctx37g00.srrblqdatfnl < m_ctx37g00.srrblqdatini then 
              error " O final do bloqueio nao pode ser anterior ao inicio!"
              next field srrblqdatfnl
           end if

    before field srrblqhorfnl
           display by name m_ctx37g00.srrblqhorfnl attribute (reverse)

    after  field srrblqhorfnl
           display by name m_ctx37g00.srrblqhorfnl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srrblqdatfnl
           end if

           if m_ctx37g00.srrblqhorfnl is null then 
              error " O final do bloqueio deve ser informado, ou tecle (F5)!"
              next field srrblqhorfnl
           end if

           if m_ctx37g00.srrblqdatfnl = m_ctx37g00.srrblqdatini then
	      if m_ctx37g00.srrblqhorfnl <= m_ctx37g00.srrblqhorini then 
                 error " O final do bloqueio deve ser maior do que o inicio!"
                 next field srrblqhorfnl
              end if
           end if

           let l_data_hora = year (m_ctx37g00.srrblqdatfnl) using "&&&&", "-"
                           , month(m_ctx37g00.srrblqdatfnl) using "&&"  , "-"
                           , day  (m_ctx37g00.srrblqdatfnl) using "&&"  , " "
                           , m_ctx37g00.srrblqhorfnl

           let m_ctx37g00.srrblqdathorfnl = l_data_hora

           let m_ctx37g00.tempo = cty38g00_tempo ( m_ctx37g00.srrblqdathorini
                                                 , m_ctx37g00.srrblqdathorfnl )

           display by name m_ctx37g00.tempo

           if cty38g00_conflito_bloqueio(param.srrcoddig
				        ,param.srrblqseq
				        ,m_ctx37g00.srrblqdathorfnl)
           then 
              error " O final deste bloqueio conflita com bloqueio ja cadastrado. Verifique!"
              next field srrblqdatfnl
           end if

    before field srrblqtxt1
           display by name m_ctx37g00.srrblqtxt1 attribute (reverse)

    after  field srrblqtxt1
           display by name m_ctx37g00.srrblqtxt1

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srrblqhorfnl
           end if

    before field srrblqtxt2
           display by name m_ctx37g00.srrblqtxt2 attribute (reverse)

    after  field srrblqtxt2
           display by name m_ctx37g00.srrblqtxt2

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srrblqtxt1
           end if

    before field srrblqtxt3
           display by name m_ctx37g00.srrblqtxt3 attribute (reverse)

    after  field srrblqtxt3
           display by name m_ctx37g00.srrblqtxt3

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field srrblqtxt2
           end if

           let m_ctx37g00.srrblqtxt[001,075] = m_ctx37g00.srrblqtxt1
           let m_ctx37g00.srrblqtxt[076,150] = m_ctx37g00.srrblqtxt2
           let m_ctx37g00.srrblqtxt[151,225] = m_ctx37g00.srrblqtxt3

    on key (f3)
           case
              when infield(srrblqdatini)
                   let m_ctx37g00.srrblqdatini = today
                   display by name m_ctx37g00.srrblqdatini

              when infield(srrblqdatfnl)
                   let m_ctx37g00.srrblqdatfnl = today
                   display by name m_ctx37g00.srrblqdatfnl

              when infield(srrblqhorini)
                   let m_ctx37g00.srrblqhorini = current
                   display by name m_ctx37g00.srrblqhorini

              when infield(srrblqhorfnl)
                   let m_ctx37g00.srrblqhorfnl = m_ctx37g00.srrblqhorini + 1 units minute
                   display by name m_ctx37g00.srrblqhorfnl
           end case

    on key (f4)
           case
              when infield(srrblqdatfnl)
                   let m_ctx37g00.srrblqdatfnl = '31/12/9999'
                   display by name m_ctx37g00.srrblqdatfnl

                   let m_ctx37g00.srrblqhorfnl = '00:00'
                   display by name m_ctx37g00.srrblqhorfnl

                   let l_data_hora = year (m_ctx37g00.srrblqdatfnl) using "&&&&", "-"
                                   , month(m_ctx37g00.srrblqdatfnl) using "&&"  , "-"
                                   , day  (m_ctx37g00.srrblqdatfnl) using "&&"  , " "
                                   , m_ctx37g00.srrblqhorfnl

                   let m_ctx37g00.srrblqdathorfnl = l_data_hora

                   let m_ctx37g00.tempo = cty38g00_tempo ( m_ctx37g00.srrblqdathorini
                                                         , m_ctx37g00.srrblqdathorfnl )

                   display by name m_ctx37g00.tempo

		   next field srrblqtxt1
           end case

    on key (interrupt)
       call ctx37g00_ler (param.srrcoddig,param.srrblqseq)
       exit input

 end input

 call ctx37g00_display()

end function 

#------------------------------------------------------------------------------#
