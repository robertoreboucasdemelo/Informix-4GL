#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: CENTRAL 24H                                                #
# Modulo.........: ctc61m01                                                   #
# Analista Resp..: Alberto Rodrigues                                          #
# PSI/OSF........: 192015                                                     #
#                  Modulo para manutencao das informacoes de condicoes do     #
#                  veiculo                                                    #
# ........................................................................... #
# Desenvolvimento: Vinicius, Meta                                             #
# Liberacao......: 29/07/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 07/04/06   Priscila        PSI198714  Inclusao campo atmacnflg, alteracao   #
#                                       layout tela, inclusao tratamento para #
#                                       datrlclcndvclgch,inclusao menu        #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql    smallint,
        m_count       smallint,
        m_modifica    smallint

 define m_ctc61m01     record
        vclcndlclcod  like datkvclcndlcl.vclcndlclcod
       ,vclcndlcldes  like datkvclcndlcl.vclcndlcldes
       ,atmacnflg     like datkvclcndlcl.atmacnflg
       ,vclcndlclsit  like datkvclcndlcl.vclcndlclsit	
       ,descricaosit  char(10)
       ,caddat        like datkvclcndlcl.caddat
       ,cadmat        like datkvclcndlcl.cadmat
       ,cadnomefunc   like isskfunc.funnom
       ,atldat        like datkvclcndlcl.atldat
       ,atlmat        like datkvclcndlcl.atlmat
       ,atlnomefunc   like isskfunc.funnom
 end record

 define am_ctc61m01   array[100] of record
       soceqpcod     like datrlclcndvclgch.soceqpcod
       ,soceqpdes     like datkvcleqp.soceqpdes
 end record

#--------------------------
function ctc61m01_prepare()
#--------------------------
  define l_sql     char(500)
  
  let m_prep_sql = true
  
  #seleciona informações sobre local/condicao veiculo
  let l_sql = " select vclcndlclcod, vclcndlcldes, atmacnflg, vclcndlclsit,"
             ,"  caddat, cademp, cadusrtip, cadmat, "
             ,"  atldat, atlemp, atlusrtip, atlmat  "
             ," from datkvclcndlcl "
             ," where vclcndlclcod = ?"
  prepare pctc61m01001 from l_sql
  declare cctc61m01001 cursor for pctc61m01001

  #seleciona tipos de guincho de um local/condicao veiculo
  let l_sql = " select a.soceqpcod, b.soceqpdes "
             ," from datrlclcndvclgch a, datkvcleqp b "
             ," where a.vclcndlclcod = ? "
             ,"   and a.soceqpcod = b.soceqpcod "
  prepare pctc61m01002 from l_sql
  declare cctc61m01002 cursor for pctc61m01002
  
  #busca descricao de um codigo de guincho
  let l_sql = "select soceqpcod, soceqpdes from datkvcleqp where soceqpcod = ?" 
  prepare pctc61m01003 from l_sql
  declare cctc61m01003 scroll cursor for pctc61m01003
  
  #seleciona o menor codigo do local/condicao veiculo
  let l_sql = " select min(vclcndlclcod) from datkvclcndlcl"
  prepare pctc61m01004 from l_sql                    
  declare cctc61m01004 scroll cursor for pctc61m01004
  
  #verifica se existe descricao do local/condicao veiculo
  let l_sql = "select vclcndlclcod from datkvclcndlcl where vclcndlclcod = ?"
  prepare pctc61m01005 from l_sql                    
  declare cctc61m01005 scroll cursor for pctc61m01005
  
  #busca o código do local/condicao veiculo anterior
  let l_sql = "select max(vclcndlclcod) from datkvclcndlcl where vclcndlclcod < ?"
  prepare pctc61m01006 from l_sql                    
  declare cctc61m01006 scroll cursor for pctc61m01006
  
  #busca o proximo codigo do local/condicao veiculo
  let l_sql = "select min(vclcndlclcod) from datkvclcndlcl where vclcndlclcod > ?"
  prepare pctc61m01007 from l_sql                    
  declare cctc61m01007 scroll cursor for pctc61m01007
  
  #verifica se ja existe a descricao
  let l_sql = "select vclcndlclcod from datkvclcndlcl where vclcndlcldes = ? "
  prepare pctc61m01008 from l_sql                    
  declare cctc61m01008 scroll cursor for pctc61m01008
  
  #busca nome do funcionario
  let l_sql = " select funnom from isskfunc "
             ," where funmat = ? "
             ,"   and usrtip = ? "
  prepare pctc61m01009 from l_sql                    
  declare cctc61m01009 scroll cursor for pctc61m01009
  
   #seleciona o maior codigo do local/condicao veiculo
  let l_sql = " select max(vclcndlclcod) from datkvclcndlcl"
  prepare pctc61m01010 from l_sql                    
  declare cctc61m01010 scroll cursor for pctc61m01010
  
  #insere informações em local/condicao veiculo
  let l_sql = "insert into datkvclcndlcl (vclcndlclcod, vclcndlcldes, "
             ," vclcndlclsit, atmacnflg, cademp, cadusrtip, cadmat, caddat,"
             ," atlemp, atlusrtip, atlmat, atldat) "
             ," values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  prepare pctc61m01011 from l_sql  
  
  #insere tipos de guincho de um determinado local/condicao veiculo
  let l_sql = "insert into datrlclcndvclgch(vclcndlclcod, soceqpcod) "
             ," values(?,?)  "
  prepare pctc61m01012 from l_sql     
  
  #limpa registros
  let l_sql = "delete from datrlclcndvclgch where vclcndlclcod = ?"
  prepare pctc61m01013 from l_sql      
  
  let l_sql = "delete from datkvclcndlcl where vclcndlclcod = ?"
  prepare pctc61m01014 from l_sql   
  
  #atualiza registro
  let l_sql = "update datkvclcndlcl set (vclcndlcldes,vclcndlclsit, atmacnflg, "
             ," atldat, atlemp, atlusrtip, atlmat) = (?,?,?,?,?,?,?)"
             ," where vclcndlclcod = ?"
  prepare pctc61m01015 from l_sql   
  
  #exclui registro do array
  let l_sql = "delete from datrlclcndvclgch where vclcndlclcod = ? and soceqpcod = ?"
  prepare pctc61m01016 from l_sql     
  
  
end function

#------------------------------------------------------------
function ctc61m01()
#------------------------------------------------------------
  options
    prompt line last,
    delete key control-y
    
  let int_flag = false
  initialize m_ctc61m01.*  to null
  initialize am_ctc61m01  to null
 
  open window ctc61m01 at 04,02 with form "ctc61m01"

  if m_prep_sql is null or
     m_prep_sql <> true then
     call ctc61m01_prepare()
  end if

  menu "local_condicaoes_veicUlo"

    before menu
      show option "Seleciona", "Proximo", "Anterior", "Modifica", "Inclui" ,
                  "Exclui", "Encerra"
 
    command key ("S") "Seleciona"
                   "Pesquisa Local e condicao do veiculo"
          call ctc61m01_seleciona()
          if m_ctc61m01.vclcndlclcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum tipo de assistencia selecionado!"
             message ""
             next option "Seleciona"
          end if

    command key ("P") "Proximo"
                   "Mostra proximo Local e condicao do veiculo"
          message ""
          if m_ctc61m01.vclcndlclcod  is not null  then
             call ctc61m01_proximo()
          else
             next option "Seleciona"
          end if 

    command key ("A") "Anterior"
                   "Mostra Local e condicao do veiculo anterior"
          message ""
          if m_ctc61m01.vclcndlclcod  is not null  then
             call ctc61m01_anterior()
          else
             next option "Seleciona"
          end if

    command key ("M") "Modifica"
                   "Modifica local condicao veiculo selecionado"
          message ""
          if m_ctc61m01.vclcndlclcod  is not null then
             call ctc61m01_modifica()
             next option "Seleciona"
          else
             error " Nenhum registro selecionado!"
             next option "Seleciona"
          end if

    command key ("I") "Inclui"
                   "Inclui local condicao veiculo"
          message ""
          call ctc61m01_inclui()
          next option "Seleciona"

    command key ("X") "eXclui"
                   "Exclui registro local condicao veiculo"
          if m_ctc61m01.vclcndlclcod  is not null then
             call ctc61m01_exclui()
             next option "Seleciona"
          else
             error " Nenhum registro selecionado!"
             next option "Seleciona"
          end if

    command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
  end menu

  close window ctc61m01

end function  ###  ctc61m01


#------------------------------------------------------------
 function ctc61m01_seleciona()
#------------------------------------------------------------
 let int_flag = false

 initialize m_ctc61m01.*  to null
 initialize am_ctc61m01  to null

 clear form

 #permite a digitação de um item para a busca
 input by name m_ctc61m01.vclcndlclcod 

    before field vclcndlclcod
        display by name m_ctc61m01.vclcndlclcod attribute (reverse)

    after  field vclcndlclcod
        display by name m_ctc61m01.vclcndlclcod

        if m_ctc61m01.vclcndlclcod is null  then
           #caso nao tenha digitado busca - seleciona o primeiro registro
           open cctc61m01004
           fetch cctc61m01004 into m_ctc61m01.vclcndlclcod
                       
           if m_ctc61m01.vclcndlclcod is null  then
              error " Nao existe nenhum local condicao veiculo cadastrado!"
              exit input
           end if
        else 
           #caso tenha digitado busca - verifica se extiste registro
           open cctc61m01005 using m_ctc61m01.vclcndlclcod 
           fetch cctc61m01005 into m_ctc61m01.vclcndlclcod
             
           if sqlca.sqlcode = notfound  then
              error " Local condicao veiculo nao cadastrado!"
              next field vclcndlclcod
           end if
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize m_ctc61m01.*   to null
    display by name m_ctc61m01.*
    error " Operacao cancelada!"
 end if
 
 call ctc61m01_le_dados()
 
end function  ###  ctc61m01_seleciona

#---------------------------------------------------------
function ctc61m01_proximo()
#---------------------------------------------------------
  define l_vclcndlclcod  like datkvclcndlcl.vclcndlclcod

  let int_flag = false

  open cctc61m01007 using m_ctc61m01.vclcndlclcod
  fetch cctc61m01007 into l_vclcndlclcod 
  
  if l_vclcndlclcod is not null then
    #se encontrou registro - limpa dados do antigo e busca dados do novo
    initialize m_ctc61m01.* to null
    initialize am_ctc61m01 to null
    let m_ctc61m01.vclcndlclcod = l_vclcndlclcod 
    call ctc61m01_le_dados() 
  else
    error "Nao existe mais registros nessa direcao!"
  end if

end function


#---------------------------------------------------------
function ctc61m01_anterior()
#---------------------------------------------------------
  define l_vclcndlclcod  like datkvclcndlcl.vclcndlclcod
 
  let int_flag = false

  open cctc61m01006 using m_ctc61m01.vclcndlclcod 
  fetch cctc61m01006 into l_vclcndlclcod

  if l_vclcndlclcod is not null then
    #se encontrou registro - limpa dados do antigo e busca dados do novo
    initialize m_ctc61m01.* to null
    initialize am_ctc61m01 to null
    let m_ctc61m01.vclcndlclcod = l_vclcndlclcod 
    call ctc61m01_le_dados()
  else
    error "Nao existe mais registros nessa direcao!"
  end if
  
end function



#---------------------------------------------------------
 function ctc61m01_le_dados()
#---------------------------------------------------------
  #funcao para buscar e exibir todas as informacoes de um local/condicao veiculo
  define l_cademp     like datkvclcndlcl.cademp,
         l_atlemp     like datkvclcndlcl.atlemp,
         l_cadusrtip  like datkvclcndlcl.cadusrtip,
         l_atlusrtip  like datkvclcndlcl.atlusrtip
  define l_aux   smallint   
  define l_tela  smallint  
  
  let l_aux = 1    

  #selecionar todas as informações necessarias de um local/condicao veiculo
  open cctc61m01001 using m_ctc61m01.vclcndlclcod
  whenever error continue
  fetch cctc61m01001 into m_ctc61m01.vclcndlclcod,
                          m_ctc61m01.vclcndlcldes,
                          m_ctc61m01.atmacnflg,
                          m_ctc61m01.vclcndlclsit,
                          m_ctc61m01.caddat,
                          l_cademp,
                          l_cadusrtip,
                          m_ctc61m01.cadmat,
                          m_ctc61m01.atldat,
                          l_atlemp,
                          l_atlusrtip,
                          m_ctc61m01.atlmat
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound  then
        error " Local condicao veiculo nao cadastrado!"
        initialize m_ctc61m01.*    to null
        return 
     else
        error "Erro SELECT cctc61m01001 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
        error "CTC61M01 / ctc61m01_ler() / ", m_ctc61m01.vclcndlclcod sleep 2
        exit program(1)
     end if
  end if
         
  #formata a situação encontrada      
  if m_ctc61m01.vclcndlclsit = "A"  then
     let m_ctc61m01.descricaosit = "ATIVO"
  else
     let m_ctc61m01.descricaosit = "CANCELADO"
  end if
     
  #busca nome do funcionário criação/alteração   
  call ctc61m01_func(l_cademp, l_cadusrtip, m_ctc61m01.cadmat)
       returning m_ctc61m01.cadnomefunc
  call ctc61m01_func(l_atlemp, l_atlusrtip, m_ctc61m01.atlmat)
       returning m_ctc61m01.atlnomefunc
             
  #exibe as informações encontradas           
  display by name m_ctc61m01.*
   
  #buscar e exibir dados do equipamento (guincho) de um local/condicao veiculo
  open cctc61m01002 using m_ctc61m01.vclcndlclcod
  whenever error continue
  foreach cctc61m01002 into am_ctc61m01[l_aux].soceqpcod,
                            am_ctc61m01[l_aux].soceqpdes
      let l_aux = l_aux + 1
      if l_aux > 100 then
         error 'Limite de Array excedido !!' sleep 2
         exit foreach
      end if
  end foreach
  
  
  #armazena em m_count o total de registros do array
  let m_count = l_aux - 1
   
  #exibe apenas os 6 primeiros em tela 
  let l_aux = 1
  for l_tela = 1 to 6
     display am_ctc61m01[l_aux].soceqpcod to s_ctc61m01[l_tela].soceqpcod
     display am_ctc61m01[l_aux].soceqpdes to s_ctc61m01[l_tela].soceqpdes
     let l_aux = l_aux + 1
  end for 

end function                
     


#---------------------------------------------------------
function ctc61m01_inclui()
#---------------------------------------------------------
  define l_cademp     like datkvclcndlcl.cademp,
         l_cadusrtip  like datkvclcndlcl.cadusrtip
                  
  define l_hora2     datetime hour to minute

  define l_nulo  smallint,
         l_aux   smallint,
         l_ok    smallint 
  
  initialize m_ctc61m01.* to null
  initialize am_ctc61m01 to null
   
  clear form
   
  #chama funcao para entrar com dados do local/condicao veiculo
  call ctc61m01_entrada_dados("I")
  if int_flag = true then
     return
  end if
  
  ## insere/visualiza dados do array
  call ctc61m01_array("I")
     
  ## busca/visualiza dados de cadastro
  call cts40g03_data_hora_banco(2)
        returning m_ctc61m01.caddat, l_hora2
  let l_cademp = g_issk.empcod
  let l_cadusrtip = g_issk.usrtip
  let m_ctc61m01.cadmat = g_issk.funmat
  let m_ctc61m01.cadnomefunc = g_issk.funnom
   
  display by name m_ctc61m01.caddat
  display by name m_ctc61m01.cadmat
  display by name m_ctc61m01.cadnomefunc
  display by name m_ctc61m01.atldat
  display by name m_ctc61m01.atlmat
  display by name m_ctc61m01.atlnomefunc
  
  let l_nulo = null       
  let l_aux = 1
  let l_ok = true
             
  begin work           
             
  #insere na tabela local/condicao veiculo (datkvclcndlcl)
  whenever error continue
  execute pctc61m01011 using m_ctc61m01.vclcndlclcod
                               ,m_ctc61m01.vclcndlcldes
                               ,m_ctc61m01.vclcndlclsit   
                               ,m_ctc61m01.atmacnflg     
                               ,l_cademp
                               ,l_cadusrtip 
                               ,m_ctc61m01.cadmat
                               ,m_ctc61m01.caddat        
                               ,l_nulo       
                               ,l_nulo
                               ,l_nulo
                               ,l_nulo
  whenever error stop
  if sqlca.sqlcode <> 0 then
          error "Erro INSERT pctc61m01011 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
          error "CTC61M01 ctc61m01_grava() ", m_ctc61m01.vclcndlclcod 
          let l_ok = false
  else
          #insere na tabela de relacionamento local/condicao veiculo X guincho (datrlclcndvclgch)
          while l_aux < m_count
              whenever error continue
              execute pctc61m01012 using m_ctc61m01.vclcndlclcod
                                        ,am_ctc61m01[l_aux].soceqpcod
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 error "Erro INSERT pctc61m01012 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
                 let l_ok = false
                 exit while
              end if     
              let l_aux = l_aux + 1
          end while
  end if
    
  if l_ok = true then
     commit work
     error "Registros incluidos com sucesso!"
  else
     rollback work
  end if

end function

           
#---------------------------------------------------------
function ctc61m01_modifica()
#---------------------------------------------------------
  define l_atlemp     like datkvclcndlcl.atlemp,
         l_atlusrtip  like datkvclcndlcl.atlusrtip
         
  define l_hora2   datetime hour to minute

  let m_modifica = false

  #chama funcao para entrar com dados do local/condicao veiculo
  call ctc61m01_entrada_dados("M")
         
  #nao foi pressionado CTRL+C       
  if int_flag = true then
     return
  end if
  
  #chama funcao para alteracao array
  call ctc61m01_array("M")
             
  if m_modifica = true then
     #houve alteração - atualiza base de dados
     call cts40g03_data_hora_banco(2)
          returning m_ctc61m01.atldat, l_hora2
     let l_atlemp = g_issk.empcod
     let l_atlusrtip = g_issk.usrtip
     let m_ctc61m01.atlmat = g_issk.funmat
     let m_ctc61m01.atlnomefunc = g_issk.funnom
     
     display by name m_ctc61m01.atldat
     display by name m_ctc61m01.atlmat
     display by name m_ctc61m01.atlnomefunc
     
     begin work
     
     whenever error continue
     execute pctc61m01015 using m_ctc61m01.vclcndlcldes
                               ,m_ctc61m01.vclcndlclsit   
                               ,m_ctc61m01.atmacnflg  
                               ,m_ctc61m01.atldat   
                               ,l_atlemp       
                               ,l_atlusrtip
                               ,m_ctc61m01.atlmat
                               ,m_ctc61m01.vclcndlclcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
         error "Erro INSERT pctc61m01011 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
         error "CTC61M01 ctc61m01_grava() ", m_ctc61m01.vclcndlclcod 
         rollback work
     else
         commit work    
     end if
  end if
  
end function

           

#---------------------------------------------------------
 function ctc61m01_entrada_dados(l_opcao)
#---------------------------------------------------------
  # funcao para entrada de dados do local/condicao veiculo
  define l_opcao    char(1)
  
  define l_altdes   like datkvclcndlcl.vclcndlcldes
  define l_altflag  like datkvclcndlcl.atmacnflg
  define l_altsit   like datkvclcndlcl.vclcndlclsit
  define l_aux_cod  like datkvclcndlcl.vclcndlclcod
  
  let int_flag = false
  
  input by name m_ctc61m01.vclcndlcldes,
                m_ctc61m01.atmacnflg,
                m_ctc61m01.vclcndlclsit without defaults
  
  
  before field vclcndlcldes
      if l_opcao = "M" then
         let l_altdes = m_ctc61m01.vclcndlcldes 
      end if
      display by name m_ctc61m01.vclcndlcldes attribute (reverse)

  after field vclcndlcldes    
      display by name m_ctc61m01.vclcndlcldes
      
      if m_ctc61m01.vclcndlcldes is null then
          error "Descricao local/condicao veiculo obrigatoria!"
          next field vclcndlcldes
      end if
      
      #Se for insercao ou uma alteração onde já mudou a descricao
      if l_opcao = "I" or
         l_altdes <> m_ctc61m01.vclcndlcldes then
         let m_modifica = true
         #verifica se nova descricao ja existe
         open cctc61m01008 using m_ctc61m01.vclcndlcldes 
         fetch cctc61m01008 into l_aux_cod
      
         if sqlca.sqlcode <> 0 then
            # se for uma insercao
            if l_opcao = "I" then
               #descricao nao existe - buscar novo código - caso seja uma insercao
               open cctc61m01010
               fetch cctc61m01010 into m_ctc61m01.vclcndlclcod
         
               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode = notfound then
                     #caso seja o primeiro registro
                     let m_ctc61m01.vclcndlclcod = 1
                  else
                     error "Erro ao buscar novo código de local/condicao veiculo!"
                  end if
               else
                  #calcula o proximo codigo disponivel na sequencia
                  let m_ctc61m01.vclcndlclcod = m_ctc61m01.vclcndlclcod + 1
               end if
            end if
         else
            error "Descricao para local/condicao veiculo existente!"
            let m_ctc61m01.vclcndlcldes = l_altdes
            next field vclcndlcldes   
         end if
      end if
      display by name m_ctc61m01.vclcndlclcod
      
   
  before field atmacnflg
        if l_opcao = "M" then
           let l_altflag = m_ctc61m01.atmacnflg 
        end if
        display by name m_ctc61m01.atmacnflg attribute (reverse)
      
  after field atmacnflg   
      display by name m_ctc61m01.atmacnflg
      if m_ctc61m01.atmacnflg is null then
         error "Informe se local/condicao veiculo e acionado automaticamente."
         next field atmacnflg
      end if  
      if m_ctc61m01.atmacnflg is not null and
         m_ctc61m01.atmacnflg <> "S" and
         m_ctc61m01.atmacnflg <> "N" then
          error "Informe 'S' ou 'N'!"
          next field atmacnflg
      end if
      if l_altflag <> m_ctc61m01.atmacnflg then
         let m_modifica = true
      end if
   
   
  before field vclcndlclsit 
        if l_opcao = "M" then
           let l_altsit = m_ctc61m01.vclcndlclsit 
        end if
        display by name m_ctc61m01.vclcndlclsit attribute (reverse)
     
  after field vclcndlclsit
     display by name m_ctc61m01.vclcndlclsit
     if m_ctc61m01.vclcndlclsit is null then
        error "informe a situação do local/condicao veiculo!"
        next field vclcndlclsit
     end if
     if m_ctc61m01.vclcndlclsit is not null and
        m_ctc61m01.vclcndlclsit <> "A" and
        m_ctc61m01.vclcndlclsit <> "C" then
          error "Informe A(Ativo) ou C(Cancelado)"
          next field vclcndlclsit
     end if
     if l_altsit <> m_ctc61m01.vclcndlclsit then
        let m_modifica = true
     end if
     if m_ctc61m01.vclcndlclsit = "A"  then
        let m_ctc61m01.descricaosit = "ATIVO"
     else
        let m_ctc61m01.descricaosit = "CANCELADO"
     end if
     display by name m_ctc61m01.descricaosit
    
  on key(F17,control-c,interrupt)
       let int_flag = true
       exit input   

  end input   
  
end function


#---------------------------------------------------------
 function ctc61m01_array(l_opcao)
#---------------------------------------------------------
  #funcao para entrada dos dados dos equipamentos (guincho) de um local/condicao veiculo
  define l_opcao  char(1)
  define l_sql    char(100)
  define l_arr    smallint
  define l_scr    smallint
  define l_result smallint
  define l_alteqpcod  like datrlclcndvclgch.soceqpcod
  
  call set_count(m_count)
  
  while true

     let int_flag = false

    input array am_ctc61m01 without defaults from s_ctc61m01.*
     
       before row
         let l_arr  = arr_curr()
         let l_scr  = scr_line() 
          
       before field soceqpcod
          if l_opcao = "M" then
             let l_alteqpcod = am_ctc61m01[l_arr].soceqpcod
          end if
          display am_ctc61m01[l_arr].soceqpcod to s_ctc61m01[l_scr].soceqpcod attribute(reverse)
          
          
       after field soceqpcod
          if am_ctc61m01[l_arr].soceqpcod is null then
             #chamar pop-up com opcoes de guincho
             let l_sql = "select soceqpcod, soceqpdes from datkvcleqp order by soceqpdes"
             call ofgrc001_popup(10, 15, "Tipos de Guincho", "Codigo", "Descricao", "N",
                                 l_sql, "", "D")
                  returning l_result, am_ctc61m01[l_arr].soceqpcod, am_ctc61m01[l_arr].soceqpdes
              #se nao selecionou nenhum tipo de guincho continua na linha corrente
             if am_ctc61m01[l_arr].soceqpcod is null then
                next field soceqpcod
             end if
          else
             #busca se codigo digitado é valido
             open cctc61m01003 using am_ctc61m01[l_arr].soceqpcod
             fetch  cctc61m01003 into am_ctc61m01[l_arr].soceqpcod, 
                                      am_ctc61m01[l_arr].soceqpdes
             if sqlca.sqlcode <> 0 then
                error "Codigo de guincho invalido!"
                next field soceqpcod
             end if                                          
          end if
          #se for uma modificacao E
          # alterou o codigo de equipamento de um array OU
          # inseriu um novo codigo de equipamento no array - anterior estava nulo
          if l_opcao = "M" and
             (l_alteqpcod <> am_ctc61m01[l_arr].soceqpcod) or
             (l_alteqpcod is null and am_ctc61m01[l_arr].soceqpcod is not null) then
             begin work
             # se alterou um item - mudou o codigo de um item do array
             # deve-se exluir o item anterior e incluir um novo
             if l_alteqpcod <> am_ctc61m01[l_arr].soceqpcod and
                am_ctc61m01[l_arr].soceqpcod is not null then
                whenever error continue
                execute pctc61m01016 using m_ctc61m01.vclcndlclcod,
                                           l_alteqpcod
             end if
             #inserir item
             whenever error continue
             execute pctc61m01012 using m_ctc61m01.vclcndlclcod,
                                        am_ctc61m01[l_arr].soceqpcod
             if sqlca.sqlcode = 0 then
                 #commit
                 commit work
                 error "Inclusao de item efetuada!"
                 let m_modifica = true
             else
                 #rollback
                 rollback work
                 exit input
             end if
          end if
          display am_ctc61m01[l_arr].soceqpcod to s_ctc61m01[l_scr].soceqpcod
          display am_ctc61m01[l_arr].soceqpdes to s_ctc61m01[l_scr].soceqpdes

       on key(F17,control-c,interrupt)
              let int_flag = true
              exit input
              
       on key (f2)
          if l_opcao = "M" then
             #apagar linha corrente da tabela
             begin work
             whenever error continue
             execute pctc61m01016 using m_ctc61m01.vclcndlclcod,
                                     am_ctc61m01[l_arr].soceqpcod
             if sqlca.sqlcode = 0 then
                 #commit
                 commit work
                 error "Exclusao efetuada!"
                 call ctc61m01_apaga_linha_tela(l_arr, l_scr)
                 let m_modifica = true
             else
                 #rollback
                 rollback work
                 exit input
             end if
          end if
          
     end input

     #armazena em m_count o total de registros do array
     let m_count = l_arr

     if int_flag = true then
        exit while
     end if

  end while

end function


#---------------------------------------------------------
function ctc61m01_func(param)
#---------------------------------------------------------
 define param         record
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip,
    funmat            like isskfunc.funmat
 end record

 define l_funnom            like isskfunc.funnom

 let l_funnom = null

  open cctc61m01009 using param.funmat,
                          param.usrtip
  fetch cctc61m01009 into l_funnom

 return upshift(l_funnom)

end function  ###  ctc15m01_func


#---------------------------------------------------------
function ctc61m01_exclui()
#---------------------------------------------------------
   define l_confirma  char(1),
          l_ok     smallint
        

   call cts08g01("C","S","", "CONFIRMA EXCLUSAO ?","","")
                 returning l_confirma


   if l_confirma = "S" then
       let l_ok = true 
       whenever error continue
       execute pctc61m01013 using m_ctc61m01.vclcndlclcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Erro DELETE pctc61m01013 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
          error "CTC61M01 ctc61m01_exclui() ", m_ctc61m01.vclcndlclcod sleep 2
          let l_ok = false
       else
          whenever error continue
          execute pctc61m01014 using m_ctc61m01.vclcndlclcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             error "Erro DELETE pctc61m01014 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
             error "CTC61M01 ctc61m01_exclui() ", m_ctc61m01.vclcndlclcod sleep 2
             let l_ok = false
          end if
       end if    
   end if   
   
   if l_ok = true then
      clear form
      initialize m_ctc61m01.* to null
      initialize am_ctc61m01 to null
      error "Registro excluido com sucesso!", m_ctc61m01.vclcndlclcod
   end if 
   
   

end function


#---------------------------------------#
function ctc61m01_apaga_linha_tela(l_arr, l_scr)
#---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint

  for l_cont = l_arr to 99
     if am_ctc61m01[l_arr].soceqpcod is not null then
        let am_ctc61m01[l_cont].* = am_ctc61m01[l_cont + 1].*
     else
        initialize am_ctc61m01[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 6
     display am_ctc61m01[l_arr].soceqpcod    to s_ctc61m01[l_cont].soceqpcod
     display am_ctc61m01[l_arr].soceqpdes    to s_ctc61m01[l_cont].soceqpdes
     let l_arr = l_arr + 1
  end for

end function




