#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTC34M16                                                   #
# ANALISTA RESP..: CRISTIANE BARBOSA DA SILVA                                 #
# PSI/OSF........: 197602 - CADASTRO CELULAR FROTA PORTO SOCORRO.             #
#                  MANUTENCAO DO CADASTRO DE TECNOLOGIA DO VEICULO.           #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 02/03/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 06/08/2008 Diomar,Meta     PSI226300  Incluido gravacao do historico        #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctc34m16_prep smallint,
         m_msg           char(33),
         teste           char(1)

  define mr_tecnologia   record
         socvclcod       like datkveiculo.socvclcod,
         pstcoddig       like datkveiculo.pstcoddig,
         nomgrr          like dpaksocor.nomgrr,
         prrsemnum       like datkveiculo.prrsemnum,
         mdtwvtfxoatvnum like datkveiculo.mdtwvtfxoatvnum,
         mdtwvtsernum    like datkveiculo.mdtwvtsernum,
         simcardnum      like datkveiculo.simcardnum,
         dadnxtnum       like datkveiculo.dadnxtnum,
         voznxtnum       like datkveiculo.voznxtnum,
         eqptip          like datkveiculo.eqptip,
         rstnum          like datkveiculo.rstnum,
         eqpdes          char(10)
  end record
  
  define mr_tecnologia_ant   record
         nomgrr          like dpaksocor.nomgrr,
         prrsemnum       like datkveiculo.prrsemnum,
         mdtwvtfxoatvnum like datkveiculo.mdtwvtfxoatvnum,
         mdtwvtsernum    like datkveiculo.mdtwvtsernum,
         simcardnum      like datkveiculo.simcardnum,
         dadnxtnum       like datkveiculo.dadnxtnum,
         voznxtnum       like datkveiculo.voznxtnum,
         eqptip          like datkveiculo.eqptip,
         rstnum          like datkveiculo.rstnum,
         eqpdes          char(10)
  end record
  

#-------------------------#
function ctc34m16_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select socvclcod, ",
                     " pstcoddig, ",
                     " prrsemnum, ",
                     " mdtwvtfxoatvnum, ",
                     " mdtwvtsernum, ",
                     " simcardnum, ",
                     " dadnxtnum, ",
                     " voznxtnum, ",
                     " eqptip, ",
                     " rstnum ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare pctc34m16001 from l_sql
  declare cctc34m16001 cursor for pctc34m16001

  let l_sql = " select min(socvclcod) ",
                " from datkveiculo ",
               " where socvclcod > ? "

 prepare pctc34m16002 from l_sql
 declare cctc34m16002 cursor for pctc34m16002

  let l_sql = " select max(socvclcod) ",
                " from datkveiculo ",
               " where socvclcod < ? "

  prepare pctc34m16003 from l_sql
  declare cctc34m16003 cursor for pctc34m16003

  let l_sql = " update ",
                     " datkveiculo ",
                " set (prrsemnum, ",
                     " mdtwvtfxoatvnum, ",
                     " mdtwvtsernum, ",
                     " simcardnum, ",
                     " dadnxtnum, ",
                     " voznxtnum, ",
                     " eqptip, ",
                     " rstnum) = (?, ?, ?, ?, ?, ?, ?, ?) ",
               " where socvclcod = ? "

  prepare pctc34m16004 from l_sql

  let m_ctc34m16_prep = true

end function

#----------------------------#
function ctc34m16(l_socvclcod)
#----------------------------#

  define l_socvclcod like datkveiculo.socvclcod

  if m_ctc34m16_prep is null or
     m_ctc34m16_prep <> true then
     call ctc34m16_prepare()
  end if

  initialize mr_tecnologia to null

  let m_msg = null

  let mr_tecnologia.socvclcod = l_socvclcod

  call ctc34m16_menu()

end function

#----------------------#
function ctc34m16_menu()
#----------------------#

  define l_salva_cod like datkveiculo.socvclcod,
         l_resposta  char(01)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let     l_salva_cod  =  null
  let     l_resposta  =  null

  let l_salva_cod = null
  let l_resposta  = null

  open window w_ctc34m16 at 4,2 with form "ctc34m16"

  call ctc34m16_operacao("S","S")

  menu "TECNOLOGIA"

     command key("S") "Selecionar" "Seleciona a tecnologia do veiculo"
                                       
             initialize mr_tecnologia to null
             initialize mr_tecnologia_ant to null

             call ctc34m16_display()

             call ctc34m16_entra_dados("S")

             if mr_tecnologia.socvclcod is not null then
                call ctc34m16_operacao("S","S")
             else
                error "Selecao cancelada"
                clear form
             end if

     command key("A") "Anterior" "Seleciona a tecnologia do veiculo anterior"

             if mr_tecnologia.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else
                let l_salva_cod = mr_tecnologia.socvclcod

                open cctc34m16003 using mr_tecnologia.socvclcod
                fetch cctc34m16003 into mr_tecnologia.socvclcod

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MAX cctc34m16003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m16_menu() / ", mr_tecnologia.socvclcod sleep 3
                end if

                close cctc34m16003

                if mr_tecnologia.socvclcod is not null then
                   call ctc34m16_operacao("S","S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_tecnologia.socvclcod = l_salva_cod
                   next option "Proximo"
                end if

             end if

     command key("P") "Proximo" "Seleciona a tecnologia do proximo veiculo"

             if mr_tecnologia.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else
                let l_salva_cod = mr_tecnologia.socvclcod

                open cctc34m16002 using mr_tecnologia.socvclcod
                whenever error continue
                fetch cctc34m16002 into mr_tecnologia.socvclcod
                whenever error stop

                if sqlca.sqlcode <> 0 and
                   sqlca.sqlcode <> notfound then
                   error "Erro SELECT MIN cctc34m16002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                   error "ctc34m16_menu() / ", mr_tecnologia.socvclcod sleep 3
                end if

                close cctc34m16002

                if mr_tecnologia.socvclcod is not null then
                   call ctc34m16_operacao("S","S")
                else
                   error "Nao existem registros nesta direcao"
                   let mr_tecnologia.socvclcod = l_salva_cod
                   next option "Anterior"
                end if

             end if

     command key("M") "Modificar" "Modifica a tecnologia do veiculo selecionado"

             if mr_tecnologia.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else
               let l_salva_cod = mr_tecnologia.socvclcod

               if mr_tecnologia.prrsemnum       is null and
                     mr_tecnologia.mdtwvtfxoatvnum is null and
                    (mr_tecnologia.mdtwvtsernum    is null or
                     mr_tecnologia.mdtwvtsernum = " ")     and
                     mr_tecnologia.simcardnum      is null and
                     mr_tecnologia.dadnxtnum       is null and
                     mr_tecnologia.voznxtnum       is null and
                     mr_tecnologia.eqptip          is null and
                    (mr_tecnologia.eqpdes          is null or
                     mr_tecnologia.eqpdes = " ")           and
                    (mr_tecnologia.rstnum          is null or
                     mr_tecnologia.rstnum = " ") then
                     let m_msg = "Tecnologia incluida com sucesso"
                  else
                     let m_msg = "Tecnologia modificada com sucesso"
                  end if

               call ctc34m16_entra_dados("M")

               if mr_tecnologia.socvclcod is not null then

                  call ctc34m16_operacao("M","M")

               else
                  let mr_tecnologia.socvclcod = l_salva_cod
                  error "Modificacao cancelada"
               end if

               call ctc34m16_operacao("S","S")

             end if

     command key("I") "Incluir" "Inclui uma tecnologia para o veiculo selecionado"

             if mr_tecnologia.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else
                if mr_tecnologia.prrsemnum       is null and
                   mr_tecnologia.mdtwvtfxoatvnum is null and
                  (mr_tecnologia.mdtwvtsernum    is null or
                   mr_tecnologia.mdtwvtsernum = " ")     and
                   mr_tecnologia.simcardnum      is null and
                   mr_tecnologia.dadnxtnum       is null and
                   mr_tecnologia.voznxtnum       is null and
                   mr_tecnologia.eqptip          is null and
                  (mr_tecnologia.eqpdes          is null or
                   mr_tecnologia.eqpdes = " ")           and
                  (mr_tecnologia.rstnum          is null or
                   mr_tecnologia.rstnum = " ") then

                   call ctc34m16_entra_dados("M")

                   if mr_tecnologia.socvclcod is not null then
                      let m_msg = "Tecnologia incluida com sucesso"
                      call ctc34m16_operacao("M","I")
                      call ctc34m16_operacao("S","S")
                   else
                      error "Inclusao cancelada"
                      let mr_tecnologia.prrsemnum       = null
                      let mr_tecnologia.mdtwvtfxoatvnum = null
                      let mr_tecnologia.mdtwvtsernum    = null
                      let mr_tecnologia.simcardnum      = null
                      let mr_tecnologia.dadnxtnum       = null
                      let mr_tecnologia.voznxtnum       = null
                      let mr_tecnologia.eqptip          = null
                      let mr_tecnologia.eqpdes          = null
                      let mr_tecnologia.rstnum          = null
                      let mr_tecnologia.rstnum          = null

                      call ctc34m16_display()

                   end if

                else
                   error "Ja existe uma tecnologia cadastrada p/este veiculo, va para opcao 'Modificar'"
                   next option "Modificar"
                end if

             end if

     command key("X") "Excluir" "Exclui a tecnologia do veiculo selecionado"

             if mr_tecnologia.socvclcod is null then
                error "Selecione um veiculo"
                next option "Selecionar"
             else

                if mr_tecnologia.prrsemnum       is null and
                   mr_tecnologia.mdtwvtfxoatvnum is null and
                  (mr_tecnologia.mdtwvtsernum    is null or
                   mr_tecnologia.mdtwvtsernum = " ")     and
                   mr_tecnologia.simcardnum      is null and
                   mr_tecnologia.dadnxtnum       is null and
                   (mr_tecnologia.eqpdes          is null or
                    mr_tecnologia.eqpdes = " ")           and
                   mr_tecnologia.voznxtnum       is null and
                   mr_tecnologia.eqptip          is null and
                  (mr_tecnologia.rstnum          is null or
                   mr_tecnologia.rstnum = " ") then
                   error "Nao existe uma tecnologia cadastrada para este veiculo"
                   next option "Modificar"
                else
                   let l_resposta = "E"

                   while l_resposta <> "S" and
                         l_resposta <> "N"

                      prompt "Deseja excluir a tecnologia do veiculo selecionado ?" for l_resposta
                      let l_resposta = upshift(l_resposta)

                      if l_resposta is null or
                         l_resposta = " " then
                         let l_resposta = "E"
                      end if

                   end while

                   if l_resposta = "S" then
                      let mr_tecnologia.prrsemnum       = null
                      let mr_tecnologia.mdtwvtfxoatvnum = null
                      let mr_tecnologia.mdtwvtsernum    = null
                      let mr_tecnologia.simcardnum      = null
                      let mr_tecnologia.dadnxtnum       = null
                      let mr_tecnologia.voznxtnum       = null
                      let mr_tecnologia.eqptip          = null
                      let mr_tecnologia.eqpdes          = null
                      let mr_tecnologia.rstnum          = null

                      let m_msg = "Tecnologia excluida com sucesso"

                      call ctc34m16_operacao("M","E")
                      call ctc34m16_display()
                   end if

                end if

             end if

     command key("E") "Encerrar" "Volta ao menu anterior"
             exit menu

  end menu

  close window w_ctc34m16

  let int_flag = false

end function

#--------------------------------------------#
function ctc34m16_entra_dados(l_tipo_operacao)
#--------------------------------------------#

  define l_tipo_operacao char(01)

  input mr_tecnologia.socvclcod,
        mr_tecnologia.prrsemnum,
        mr_tecnologia.simcardnum,
        mr_tecnologia.dadnxtnum,
        mr_tecnologia.voznxtnum,
        mr_tecnologia.eqptip,
        mr_tecnologia.mdtwvtfxoatvnum,
        mr_tecnologia.mdtwvtsernum,
        mr_tecnologia.rstnum without defaults from socvclcod,
                                                   prrsemnum,
                                                   simcardnum,
                                                   dadnxtnum,
                                                   voznxtnum,
                                                   eqptip,
                                                   mdtwvtfxoatvnum,
                                                   mdtwvtsernum,
                                                   rstnum
     before field socvclcod

        if l_tipo_operacao = "M" then
           next field prrsemnum
        end if

        display by name mr_tecnologia.socvclcod attribute(reverse)

     after field socvclcod
        display by name mr_tecnologia.socvclcod

        if mr_tecnologia.socvclcod is null then
           error "Informe o codigo do veiculo"
           next field socvclcod
        end if

        if l_tipo_operacao = "S" then
           exit input
        end if

     before field prrsemnum
        display by name mr_tecnologia.prrsemnum attribute(reverse)

     after field prrsemnum
        display by name mr_tecnologia.prrsemnum

         if fgl_lastkey() = fgl_keyval ("up") or
            fgl_lastkey() = fgl_keyval ("left") then
            next field prrsemnum
        end if

     before field simcardnum
        display by name mr_tecnologia.simcardnum attribute(reverse)

     after field simcardnum
        display by name mr_tecnologia.simcardnum

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field prrsemnum
        end if

     before field dadnxtnum
        display by name mr_tecnologia.dadnxtnum attribute(reverse)

     after field dadnxtnum
        display by name mr_tecnologia.dadnxtnum

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field simcardnum
        end if

     before field voznxtnum
        display by name mr_tecnologia.voznxtnum attribute(reverse)

     after field voznxtnum
        display by name mr_tecnologia.voznxtnum

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field dadnxtnum
        end if

     before field eqptip
        display by name mr_tecnologia.eqptip attribute(reverse)

     after field eqptip
        display by name mr_tecnologia.eqptip

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field voznxtnum
        end if

        if mr_tecnologia.eqptip <> 1 and
           mr_tecnologia.eqptip <> 2 and
           mr_tecnologia.eqptip <> 3 and
           mr_tecnologia.eqptip <> 4 and
           mr_tecnologia.eqptip <> 5 then
           error "Informe: (1)MDT RADIO  (2)MDT GPRS  (3)WVT NEXTEL  (4)WVT GPRS  (5)WVT MULTI"
           next field eqptip
        end if

        case mr_tecnologia.eqptip

           when(1)
              let mr_tecnologia.eqpdes = "MDT RADIO"
           when(2)
              let mr_tecnologia.eqpdes = "MDT GPRS"
           when(3)
              let mr_tecnologia.eqpdes = "WVT NEXTEL"
           when(4)
              let mr_tecnologia.eqpdes = "WVT GPRS"
           when(5)
              let mr_tecnologia.eqpdes = "WVT MULTI"
           otherwise
              let mr_tecnologia.eqpdes = null

        end case

        display by name mr_tecnologia.eqpdes

     before field mdtwvtfxoatvnum
        display by name mr_tecnologia.mdtwvtfxoatvnum attribute(reverse)

     after field mdtwvtfxoatvnum
        display by name mr_tecnologia.mdtwvtfxoatvnum

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field eqptip
        end if

     before field mdtwvtsernum
        display by name mr_tecnologia.mdtwvtsernum attribute(reverse)

     after field mdtwvtsernum
        display by name mr_tecnologia.mdtwvtsernum

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field mdtwvtfxoatvnum
        end if

     before field rstnum
        display by name mr_tecnologia.rstnum attribute(reverse)

     after field rstnum
        display by name mr_tecnologia.rstnum

        if fgl_lastkey() = fgl_keyval ("up") or
           fgl_lastkey() = fgl_keyval ("left") then
           next field mdtwvtsernum
        end if

     on key(f17, control-c, interrupt)
        initialize mr_tecnologia to null
        exit input

  end input

end function

#-------------------------#
function ctc34m16_display()
#-------------------------#

  case mr_tecnologia.eqptip

     when(1)
        let mr_tecnologia.eqpdes = "MDT RADIO"
     when(2)
        let mr_tecnologia.eqpdes = "MDT GPRS"
     when(3)
        let mr_tecnologia.eqpdes = "WVT NEXTEL"
     when(4)
        let mr_tecnologia.eqpdes = "WVT GPRS"
     when(5)
        let mr_tecnologia.eqpdes = "WVT MULTI"
     otherwise
        let mr_tecnologia.eqpdes = null

  end case

  display by name mr_tecnologia.socvclcod,
                  mr_tecnologia.pstcoddig,
                  mr_tecnologia.nomgrr,
                  mr_tecnologia.prrsemnum,
                  mr_tecnologia.mdtwvtfxoatvnum,
                  mr_tecnologia.mdtwvtsernum,
                  mr_tecnologia.simcardnum,
                  mr_tecnologia.dadnxtnum,
                  mr_tecnologia.voznxtnum,
                  mr_tecnologia.eqptip,
                  mr_tecnologia.eqpdes,
                  mr_tecnologia.rstnum
end function

#------------------------------------------------#
function ctc34m16_operacao(l_tipo_operacao,l_oper)
#------------------------------------------------#

  define l_tipo_operacao char(01),
         l_oper          char(01)
  
  define lr_retorno record      
                    stt smallint
                   ,msg char(50)
         end record             
  
  define l_mensagem  char(3000)
        ,l_mensagem2 char(100)
        ,l_stt       smallint
        ,l_erro      smallint
        ,l_data      date
        ,l_hora2     datetime hour to minute
        ,l_prshstdes2  char(3000)
        ,l_count
        ,l_iter
        ,l_length
        ,l_length2    smallint
        
   initialize lr_retorno to null
   
   let l_mensagem  = null
   let l_mensagem2 = null
   let l_stt       = 0
   let l_data      = null
   let l_hora2     = null
   
  {TIPOS DE OPERACAO

   "S" SELECIONAR
   "M" MODIFICAR}

  case l_tipo_operacao

     when("S") # ---> SELECIONAR

        open cctc34m16001 using mr_tecnologia.socvclcod
        whenever error continue
        fetch cctc34m16001 into mr_tecnologia.socvclcod,
                                mr_tecnologia.pstcoddig,
                                mr_tecnologia.prrsemnum,
                                mr_tecnologia.mdtwvtfxoatvnum,
                                mr_tecnologia.mdtwvtsernum,
                                mr_tecnologia.simcardnum,
                                mr_tecnologia.dadnxtnum,
                                mr_tecnologia.voznxtnum,
                                mr_tecnologia.eqptip,
                                mr_tecnologia.rstnum

        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              error "Nenhum veiculo encontrado para o codigo informado"
              initialize mr_tecnologia to null
           else
              error "Erro SELECT cctc34m16001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "ctc34m16_operacao() / ", mr_tecnologia.socvclcod sleep 3
           end if
        else
           # --> BUSCA O NOME DE GUERRA DO PRESTADOR
           let mr_tecnologia.nomgrr = ctc34m15_pesq_nomgrr(mr_tecnologia.pstcoddig)
        end if
                       
        let  mr_tecnologia_ant.prrsemnum       =   mr_tecnologia.prrsemnum      
        let  mr_tecnologia_ant.mdtwvtfxoatvnum =   mr_tecnologia.mdtwvtfxoatvnum
        let  mr_tecnologia_ant.mdtwvtsernum    =   mr_tecnologia.mdtwvtsernum   
        let  mr_tecnologia_ant.simcardnum      =   mr_tecnologia.simcardnum     
        let  mr_tecnologia_ant.dadnxtnum       =   mr_tecnologia.dadnxtnum      
        let  mr_tecnologia_ant.voznxtnum       =   mr_tecnologia.voznxtnum      
        let  mr_tecnologia_ant.eqptip          =   mr_tecnologia.eqptip         
        let  mr_tecnologia_ant.rstnum          =   mr_tecnologia.rstnum          
        
        close cctc34m16001
        
        call ctc34m16_display()
        
     when("M") # ---> MODIFICAR
        
        whenever error continue
        execute pctc34m16004 using  mr_tecnologia.prrsemnum,
                                    mr_tecnologia.mdtwvtfxoatvnum,
                                    mr_tecnologia.mdtwvtsernum,
                                    mr_tecnologia.simcardnum,
                                    mr_tecnologia.dadnxtnum,
                                    mr_tecnologia.voznxtnum,
                                    mr_tecnologia.eqptip,
                                    mr_tecnologia.rstnum,
                                    mr_tecnologia.socvclcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc34m16004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "ctc34m16_operacao() / ", mr_tecnologia.prrsemnum,       "/",
                                           mr_tecnologia.mdtwvtfxoatvnum, "/",
                                           mr_tecnologia.mdtwvtsernum,    "/",
                                           mr_tecnologia.simcardnum,      "/",
                                           mr_tecnologia.dadnxtnum,       "/",
                                           mr_tecnologia.voznxtnum,       "/",
                                           mr_tecnologia.eqptip,          "/",
                                           mr_tecnologia.rstnum,          "/",
                                           mr_tecnologia.socvclcod sleep 3
        else
           error m_msg
        
            call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2  
            
            if l_oper = "M" then
                 let l_mensagem2 = 'Alteracao no cadastro de tecnologia do  ',
	    	                   ' veiculo. Codigo = ' clipped,mr_tecnologia.socvclcod
            end if
            
            if l_oper = "I" then
                 let l_mensagem2 = 'Inclusao no cadastro de tecnologia do  ',
	    	                   ' veiculo. Codigo = ' clipped,mr_tecnologia.socvclcod
            end if
            
            if l_oper = "E" then
                 let l_mensagem2 = 'Exclusao no cadastro de tecnologia do  ',
	    	                   ' veiculo. Codigo = ' clipped,mr_tecnologia.socvclcod
            end if
            
            let l_mensagem = null
            
            if (mr_tecnologia.prrsemnum is null      and mr_tecnologia_ant.prrsemnum is not null) or  
               (mr_tecnologia.prrsemnum is not null  and mr_tecnologia_ant.prrsemnum is null)    or
               (mr_tecnologia.prrsemnum      <>       mr_tecnologia_ant.prrsemnum)               then
                 let l_mensagem = "Numero Sem parar do Veiculo alterado de [" clipped,
                     mr_tecnologia_ant.prrsemnum clipped, "] para [",
                     mr_tecnologia.prrsemnum clipped,"]"
            end if
        
            if (mr_tecnologia.mdtwvtfxoatvnum is     null and mr_tecnologia_ant.mdtwvtfxoatvnum is not null)  or 
               (mr_tecnologia.mdtwvtfxoatvnum is not null and mr_tecnologia_ant.mdtwvtfxoatvnum is null)      or           
               (mr_tecnologia.mdtwvtfxoatvnum          <>     mr_tecnologia_ant.mdtwvtfxoatvnum)              then
               let l_mensagem = l_mensagem clipped," ","Numero do Ativo Fixo alterado de ["clipped,
                         mr_tecnologia_ant.mdtwvtfxoatvnum clipped, "] para [",
                         mr_tecnologia.mdtwvtfxoatvnum clipped,"]"
            end if
        
            if (mr_tecnologia.mdtwvtsernum  is     null and  mr_tecnologia_ant.mdtwvtsernum   is not null)  or  
               (mr_tecnologia.mdtwvtsernum is not null and   mr_tecnologia_ant.mdtwvtsernum  is null)      or  
               (mr_tecnologia.mdtwvtsernum             <>      mr_tecnologia_ant.mdtwvtsernum)            then 
               let l_mensagem = l_mensagem clipped," ","Numero de Serie do Veiculo alterado de ["clipped,
                         mr_tecnologia_ant.mdtwvtsernum clipped, "] para [",
                         mr_tecnologia.mdtwvtsernum clipped,"]"
            end if   
        
            if (mr_tecnologia.simcardnum is     null and   mr_tecnologia_ant.simcardnum   is not null)  or  
               (mr_tecnologia.simcardnum is not null and   mr_tecnologia_ant.simcardnum   is null)      or   
               (mr_tecnologia.simcardnum      <>      mr_tecnologia_ant.simcardnum)            then 
               let l_mensagem = l_mensagem clipped," ","Numero do Sincard do Veiculo alterado de ["clipped,
                         mr_tecnologia_ant.simcardnum clipped, "] para [",
                         mr_tecnologia.simcardnum clipped,"]"
            end if
        
            if (mr_tecnologia.dadnxtnum  is     null and    mr_tecnologia_ant.dadnxtnum  is not null)  or  
               (mr_tecnologia.dadnxtnum  is not null and    mr_tecnologia_ant.dadnxtnum  is null)      or  
               (mr_tecnologia.dadnxtnum       <>      mr_tecnologia_ant.dadnxtnum)                    then 
               let l_mensagem = l_mensagem clipped," ","Numero do Nextel  do Veiculo alterado de ["clipped,
               mr_tecnologia_ant.dadnxtnum clipped, "] para [",mr_tecnologia.dadnxtnum clipped,"]"
            end if
        
            if (mr_tecnologia.voznxtnum is     null and   mr_tecnologia_ant.voznxtnum is not null)  or  
               (mr_tecnologia.voznxtnum is not null and   mr_tecnologia_ant.voznxtnum is null)      or  
               (mr_tecnologia.voznxtnum       <>      mr_tecnologia_ant.voznxtnum)                 then 
               let l_mensagem = l_mensagem clipped," ","Numero do Nextel voz  do Veiculo alterado de ["clipped,
               mr_tecnologia_ant.voznxtnum clipped, "] para [",mr_tecnologia.voznxtnum clipped,"]"
            end if
        
            if (mr_tecnologia.eqptip  is     null and     mr_tecnologia_ant.eqptip  is not null)  or  
               (mr_tecnologia.eqptip  is not null and     mr_tecnologia_ant.eqptip  is null)      or  
               (mr_tecnologia.eqptip          <>      mr_tecnologia_ant.eqptip)                  then 
               let l_mensagem = l_mensagem clipped," ","Numero do Equipamento do Veiculo alterado de ["clipped,
               mr_tecnologia_ant.eqptip clipped, "] para [",mr_tecnologia.eqptip clipped,"]"
            end if
        
            if (mr_tecnologia.rstnum is     null and     mr_tecnologia_ant.rstnum  is not null)  or  
               (mr_tecnologia.rstnum is not null and     mr_tecnologia_ant.rstnum  is null)      or  
               (mr_tecnologia.rstnum          <>      mr_tecnologia_ant.rstnum)                 then 
                let l_mensagem = l_mensagem clipped," ","Numero do Rastreador do Veiculo alterado de ["clipped,
                mr_tecnologia_ant.rstnum clipped, "] para [",mr_tecnologia.rstnum clipped,"]"
            end if
                        
            let l_length = length(l_mensagem clipped)
            
            if  l_length mod 70 = 0 then
                 let l_iter = l_length / 70
             else
                 let l_iter = l_length / 70 + 1
            end if

            let l_length2     = 0
            let l_erro        = 0
   
            for l_count = 1 to l_iter
                 if  l_count = l_iter then
                     let l_prshstdes2 = l_mensagem[l_length2 + 1, l_length]
                 else
                     let l_length2 = l_length2 + 70
                     let l_prshstdes2 = l_mensagem[l_length2 - 69, l_length2]
                 end if
                               
                 call ctb85g01_grava_hist(1                                        
                                    ,mr_tecnologia.socvclcod   
                                    ,l_prshstdes2 clipped                        
                                    ,l_data                            
                                    ,g_issk.empcod                            
                                    ,g_issk.funmat                            
                                    ,g_issk.usrtip)                           
                   returning lr_retorno.stt                                       
                            ,lr_retorno.msg
            
            end for
             
            if lr_retorno.stt = 0 then                                        

		call ctb85g01_mtcorpo_email_html('CTC34M01',
	                                         l_data,
	                                         l_hora2, 
	                                         g_issk.empcod,
	                                         g_issk.usrtip,
	                                         g_issk.funmat,
	                                         l_mensagem2,
	                                         l_mensagem)
	                  returning l_erro

            else                                                              
               error 'Erro na gravacao do historico' sleep 2                          
            end if               
         end if
  end case

end function
