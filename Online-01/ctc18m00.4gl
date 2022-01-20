#############################################################################
# Nome do Modulo: CTC18M00                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao no Cadastro de Lojas de Locacao de Veiculos           Ago/1995 #
# ######################################################################### #
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 06/10/1998  PSI 7056-4   Gilberto     Gravar informacoes de cadastramento #
#                                       e ultima atualizacao.               #
#                                       Alterar situacao da loja de (A)tiva #
#                                       ou (C)ancelada para codificacao nu- #
#                                       merica: (1)Ativa;     (2)Bloqueada; #
#                                               (3)Cancelada; (4)Desativada #
#---------------------------------------------------------------------------#
# 01/02/1999  PSI 7670-8   Wagner       Gravar ultimo funcionario que fez   #
#                                       manutencao na situacao da loja e    #
#                                       pedir input de periodo para situacao#
#                                       (2)Bloqueada. tabela (datklcvsit)   #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 10631-3  Wagner       Inclusao tabela favorecido para     #
#                                       sistema pagamento carro_extra.      #
#---------------------------------------------------------------------------#
# 15/08/2000  PSI 11275-5  Wagner       Inclusao da manutencao do campo     #
#                                       cheque caucao (cahchqflg).          #
#---------------------------------------------------------------------------#
# 07/12/2000  PSI 10631-3  Wagner       Inclusao de mais um tipo de loja    #
#                                       Franquia/rede.                      #
#---------------------------------------------------------------------------#
# 24/05/2002  PSI 15455-5  Wagner       Inclusao descricao tarifa p/lojas   #
#                                       possibilidade de alteracao precos.  #
#---------------------------------------------------------------------------#
# 23/12/2002  PSI 15181-5  Wagner       Inclusao campo taxa aero portuaria. #
#---------------------------------------------------------------------------#
# 24/11/2003  PSI 17791-1  Paula        Inclusão do campo qualificação      #
#             OSF 29130                                                     #
# 13/01/2004                            Inclusao sa funcao ctc18m00_espelho #
# 22/06/2004  OSF 37184    Teresinha S. Alterar chamada funcao ctn18c00 pas #
#                                       sando zero como cod do motivo da lo #
#                                       cacao ao inves da flag de oficinas  #
#---------------------------------------------------------------------------#
# 21/02/2006  PSI 198390   Priscila     Inclusao menu Entrega - alteracao   #
#                                       chamada da funcao ctn18c00 inclusao #
#                                       parametro cidcep                    #
#---------------------------------------------------------------------------#
# 02/03/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
# --------   ------------- ------    ---------------------------------------#
# 22/02/2006 Andrei, Meta  PSI196878 Incluir campo email                    #
#---------------------------------------------------------------------------#
# 28/11/2006 Priscila      PSI205206    passar empresa como parametro para  #
#                                       ctn17c00 e ctn18c00                 #
#---------------------------------------------------------------------------#
# 06/08/2008 Diomar,Meta   PSI226300    Incluido gravacao do historico      #
#---------------------------------------------------------------------------#
# 25/05/2009  PSI 198404  Fabio Costa  Revisao qualificacao da loja, data de#
#                                      bloqueio da loja, sugerir sucursal   #
#---------------------------------------------------------------------------#
# 17/08/2010  PSI 259136  Robert Lima  Adicionado campos (cnpj, faixa renda #
#                                      mensal e patrimonio liquido) para    #
#                                      atender a Circular 380               #
#---------------------------------------------------------------------------#
# 17/08/2010  PSI-2012-31349EV Burini  Inclusão do relacionamento de        #
#                                      LOJA x EMPRESA                       #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/ffpgc368.4gl"  #Fornax-Quantum    
globals "/homedsa/projetos/geral/globals/ffpgc361.4gl" #Fornax-Quantum    

#Fornax-Quantum - Inicio                                                                
define m_ctc18m00 record                                           
   lcvcod       like datkavislocal.lcvcod      ,                 
   lcvnom       like datklocadora.lcvnom       ,                 
   aviestcod    like datkavislocal.aviestcod   ,                 
   lcvextcod    like datkavislocal.lcvextcod   ,                 
   aviestnom    like datkavislocal.aviestnom   ,                 
   lcvlojtip    like datkavislocal.lcvlojtip   ,                 
   lcvlojdes    char (13)                      ,                 
   lojqlfcod  char (01)                      ,#paula             
   lojqlfdes  char (13)                      ,#paula             
   endlgd       like datkavislocal.endlgd      ,                 
   endbrr       like datkavislocal.endbrr      ,                 
   endcid       like datkavislocal.endcid      ,                 
   endufd       like datkavislocal.endufd      ,                 
   endcep       like datkavislocal.endcep      ,                 
   endcepcmp    like datkavislocal.endcepcmp   ,                 
   refptodes    char(1)                        ,
   succod       like datkavislocal.succod,                       
   sucnom       like gabksuc.sucnom,                             
   dddcod       like datkavislocal.dddcod      ,                 
   teltxt       like datkavislocal.teltxt      ,                 
   facnum       like datkavislocal.facnum      ,                 
   horsegsexinc like datkavislocal.horsegsexinc,                 
   horsegsexfnl like datkavislocal.horsegsexfnl,                 
   horsabinc    like datkavislocal.horsabinc   ,                 
   horsabfnl    like datkavislocal.horsabfnl   ,                 
   hordominc    like datkavislocal.hordominc   ,                 
   hordomfnl    like datkavislocal.hordomfnl   ,                 
   lcvregprccod like datkavislocal.lcvregprccod,                 
   lcvregprcdes char (13)                      ,                 
   vclalglojstt like datkavislocal.vclalglojstt,                 
   lojsttdes    char (09)                      ,                 
   cauchqflg    like datkavislocal.cauchqflg   ,                 
   prtaertaxvlr like datkavislocal.prtaertaxvlr,                 
   maides       like datkavislocal.maides      ,                 
   caddat       like datkavislocal.caddat      ,                 
   cademp       like datkavislocal.cademp      ,                 
   cadmat       like datkavislocal.cadmat      ,                 
   cadnom       like isskfunc.funnom           ,                 
   atldat       like datkavislocal.atldat      ,                 
   atlemp       like datkavislocal.atlemp      ,                 
   atlmat       like datkavislocal.atlmat      ,                 
   atlnom       like isskfunc.funnom           ,                 
   obs          like datkavislocal.obs         ,
   dlvlojflg    char(1)                    
end record 
#Fornax-Quantum - Fim 

define m_refptodes char(255)

define m_res  smallint,
       m_msg  char(70),
       m_sql  char(200)
       
#------------------------------------------------------------
 function ctc18m00()
#------------------------------------------------------------

 define ctc18m00 record
    lcvcod           like datkavislocal.lcvcod         ,
    lcvnom           like datklocadora.lcvnom          ,
    aviestcod        like datkavislocal.aviestcod      ,
    lcvextcod        like datkavislocal.lcvextcod      ,
    aviestnom        like datkavislocal.aviestnom      ,
    lcvlojtip        like datkavislocal.lcvlojtip      ,
    lcvlojdes        char (13)                         ,
    lojqlfcod        char (01)                         ,#paula
    lojqlfdes        char (13)                         ,#paula
    endlgd           like datkavislocal.endlgd         ,
    endbrr           like datkavislocal.endbrr         ,
    endcid           like datkavislocal.endcid         ,
    endufd           like datkavislocal.endufd         ,
    endcep           like datkavislocal.endcep         ,
    endcepcmp        like datkavislocal.endcepcmp      ,
    refptodes        char(1)                           ,
    succod           like datkavislocal.succod         ,
    sucnom           like gabksuc.sucnom               ,
    dddcod           like datkavislocal.dddcod         ,
    teltxt           like datkavislocal.teltxt         ,
    facnum           like datkavislocal.facnum         ,
    horsegsexinc     like datkavislocal.horsegsexinc   ,
    horsegsexfnl     like datkavislocal.horsegsexfnl   ,
    horsabinc        like datkavislocal.horsabinc      ,
    horsabfnl        like datkavislocal.horsabfnl      ,
    hordominc        like datkavislocal.hordominc      ,
    hordomfnl        like datkavislocal.hordomfnl      ,
    lcvregprccod     like datkavislocal.lcvregprccod   ,
    lcvregprcdes     char (13)                         ,
    vclalglojstt     like datkavislocal.vclalglojstt   ,
    lojsttdes        char (09)                         ,
    cauchqflg        like datkavislocal.cauchqflg      ,
    prtaertaxvlr     like datkavislocal.prtaertaxvlr   ,
    maides           like datkavislocal.maides         ,
    caddat           like datkavislocal.caddat         ,
    cademp           like datkavislocal.cademp         ,
    cadmat           like datkavislocal.cadmat         ,
    cadnom           like isskfunc.funnom              ,
    atldat           like datkavislocal.atldat         ,
    atlemp           like datkavislocal.atlemp         ,
    atlmat           like datkavislocal.atlmat         ,
    atlnom           like isskfunc.funnom              ,
    aviestcgcnumdig  like datkavislocal.aviestcgcnumdig,#campo adicionado para atender a circular 380
    liqptrfxades     char(30)                          ,#campo adicionado para atender a circular 380
    anobrtoprrctdes  char(30)                          ,#campo adicionado para atender a circular 380    
    obs              like datkavislocal.obs            ,
    dlvlojflg        char(1)
 end record

 define k_ctc18m00 record
    lcvcod        like datkavislocal.lcvcod   ,
    lcvextcod     like datkavislocal.lcvextcod,
    aviestcod     like datkavislocal.aviestcod
 end record

 define  ws      record
    endcep      like glaklgd.lgdcep,
    endcepcmp   like glaklgd.lgdcepcmp,
    lcvcod      like datklocadora.lcvcod,
    aviestcod   like datkavislocal.aviestcod,
    vclpsqflg   smallint ,
    avivclcod   like datkavisveic.avivclcod
 end record

   define l_aux     char(10)
         ,l_lojades char(16)
         ,l_aux2    char(16)
         ,l_sql     char(200)

   let l_aux     = null
   let l_lojades = null
   let l_aux2    = null
   let m_res     = null
   let m_msg     = null
   let m_sql     = null

   if not get_niv_mod(g_issk.prgsgl, "ctc18m00") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if
   
   let l_sql = " select cpodes "
             , " from iddkdominio "
             , " where cponom = 'PSOLOCQLD' "
             , "   and cpocod = ? "
   prepare p_lojqlfdes_sel from l_sql
   declare c_lojqlfdes_sel cursor with hold for p_lojqlfdes_sel
   
   open window ctc18m00 at 04,02 with form "ctc18m00"

   let int_flag = false

   initialize ctc18m00.*   to  null
   initialize k_ctc18m00.* to  null

   menu "LOJAS"
       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior", "Situacao",
                            "prOposta", "eNtrega", "Empresa"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior", "Modifica",
                            "Inclui"  , "Responsaveis","Clausulas", "Situacao", "Favorecido",
                            "prOposta", "eNtrega", "Empresa"
          end if

          show option "Encerra"
          show option 'Historico'
         
   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
            call seleciona_ctc18m00() returning k_ctc18m00.*
            if k_ctc18m00.lcvcod    is not null  and
               k_ctc18m00.aviestcod is not null  then
               next option "Proximo"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("P") "Proximo" "Mostra proximo registro selecionado"
            if k_ctc18m00.lcvcod    is not null  and
               k_ctc18m00.aviestcod is not null  then
               call proximo_ctc18m00(k_ctc18m00.*)
                    returning k_ctc18m00.*
            else
               error " Nao ha' mais registros nesta direcao!"
               next option "Seleciona"
            end if

   command key ("A") "Anterior" "Mostra registro anterior selecionado"
            if k_ctc18m00.lcvcod    is not null  and
               k_ctc18m00.aviestcod is not null  then
               call anterior_ctc18m00(k_ctc18m00.*)
                    returning k_ctc18m00.*
            else
               error " Nao ha' mais registros nesta direcao!"
               next option "Seleciona"
            end if

   command key ("D") "moDifica" "Modifica registro corrente selecionado"
            if k_ctc18m00.lcvcod    is not null  and
               k_ctc18m00.aviestcod is not null  then
               call modifica_ctc18m00(k_ctc18m00.*)
                    returning k_ctc18m00.*
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("R") "Remove" "Remove registro corrente selecionado"
            message ""
            if k_ctc18m00.lcvcod    is not null  and
               k_ctc18m00.aviestcod is not null  then
               call remove_ctc18m00(k_ctc18m00.*)
                    returning k_ctc18m00.*
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("I") "Inclui" "Inclui registro na tabela"
            call inclui_ctc18m00()
            next option "Seleciona"
            
   command key ("K") "Responsaveis"
               "Mantem as informações do prestador exigidas pela circular 380"
               message ""

               if k_ctc18m00.lcvcod    is not null  and
                  k_ctc18m00.aviestcod is not null  then
                  call ctc00m20('A',k_ctc18m00.aviestcod,k_ctc18m00.lcvcod) #PSI circular 380
               else
                  error " Nenhum registro selecionado!"
               end if               
               next option "Seleciona"         

   command key ("C") "Clausulas" "Clausulas atendidas pela loja selecionada"
            if k_ctc18m00.lcvcod    is not null  and
               k_ctc18m00.aviestcod is not null  then
               call ctc18m01(k_ctc18m00.lcvcod, k_ctc18m00.aviestcod)
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("T") "siTuacao" "Situacao da loja selecionada"
            if k_ctc18m00.lcvcod    is not null  and
               k_ctc18m00.aviestcod is not null  then
               call ctc18m03(k_ctc18m00.lcvcod, k_ctc18m00.aviestcod)
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("F") "Favorecido" "Favorecido da loja selecionada"
            if k_ctc18m00.lcvcod    is not null  and
               k_ctc18m00.aviestcod is not null  then
               call ctc18m04(k_ctc18m00.lcvcod, k_ctc18m00.aviestcod)
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if


   command key ("O") "prOposta"
           "Consulta lojas em proposta"
           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  or
              ws.endcep  =  0    then
              error "Nenhum criterio foi selecionado!"
           else
             #call ctn18c00("", ws.endcep, "", "", 2, false) -- OSF 37184
             #call ctn18c00("", ws.endcep, "", "", 2, 0)     -- OSF 37184
             #call ctn18c00("", ws.endcep, ws.endcepcmp, "", "", 2, 0)  -- PSI 198390
             call ctn18c00("", ws.endcep, ws.endcepcmp, "", "", 2, 0, "") #PSI205206
                   returning ws.lcvcod, ws.aviestcod, ws.vclpsqflg

              if ws.vclpsqflg = TRUE  then
                 call ctn17c00 (ws.lcvcod, ws.aviestcod, "N", "", #PSI 205206
                      "","" )                                        #PSI 244.813 Cadastro Veiculo - Carro Extra
                      returning ws.avivclcod
              end if
           end if

   command key ("N") "eNtrega"
           "Locais de entrega da Loja"
               call ctc18m05(k_ctc18m00.lcvcod, k_ctc18m00.aviestcod)
               next option "Seleciona"
               
   command key ("M") "eMpresa"  "Mantem o cadastro das empresas atendidas pela Loja"
            if k_ctc18m00.lcvcod    is not null  and 
               k_ctc18m00.aviestcod is not null  then
               call ctc18m00_empresa(k_ctc18m00.lcvcod, k_ctc18m00.aviestcod,"A")
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if               
   
   command key ("H") 'Historico' 'Consulta o historico'
         if k_ctc18m00.lcvcod    is not null  and 
            k_ctc18m00.aviestcod is not null  then
            let l_aux     = k_ctc18m00.lcvcod using '<<<<<' ,"|",k_ctc18m00.aviestcod using '<<<<'
            let l_lojades = 'Cadastro de loja'                                                    
            let l_aux2    = 'Loja de Locadora'                                                    
            call ctb85g00(3                                                                       
                         ,l_aux2                                                                  
                         ,l_aux                                                                   
                         ,l_lojades) 
         else                                     
            error " Nenhum registro selecionado!" 
            next option "Seleciona"               
         end if                                   

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc18m00

end function  ###  ctc18m00

#------------------------------------------------------------
 function seleciona_ctc18m00()
#------------------------------------------------------------

  define ctc18m00 record
     lcvcod           like datkavislocal.lcvcod         ,
     lcvnom           like datklocadora.lcvnom          ,
     aviestcod        like datkavislocal.aviestcod      ,
     lcvextcod        like datkavislocal.lcvextcod      ,
     aviestnom        like datkavislocal.aviestnom      ,
     lcvlojtip        like datkavislocal.lcvlojtip      ,
     lcvlojdes        char (13)                         ,
     lojqlfcod        char (01)                         ,#paula
     lojqlfdes        char (13)                         ,#paula
     endlgd           like datkavislocal.endlgd         ,
     endbrr           like datkavislocal.endbrr         ,
     endcid           like datkavislocal.endcid         ,
     endufd           like datkavislocal.endufd         ,
     endcep           like datkavislocal.endcep         ,
     endcepcmp        like datkavislocal.endcepcmp      ,
     refptodes        char(1)                           ,
     succod           like datkavislocal.succod         ,
     sucnom           like gabksuc.sucnom               ,
     dddcod           like datkavislocal.dddcod         ,
     teltxt           like datkavislocal.teltxt         ,
     facnum           like datkavislocal.facnum         ,
     horsegsexinc     like datkavislocal.horsegsexinc   ,
     horsegsexfnl     like datkavislocal.horsegsexfnl   ,
     horsabinc        like datkavislocal.horsabinc      ,
     horsabfnl        like datkavislocal.horsabfnl      ,
     hordominc        like datkavislocal.hordominc      ,
     hordomfnl        like datkavislocal.hordomfnl      ,
     lcvregprccod     like datkavislocal.lcvregprccod   ,
     lcvregprcdes     char (13)                         ,
     vclalglojstt     like datkavislocal.vclalglojstt   ,
     lojsttdes        char (09)                         ,
     cauchqflg        like datkavislocal.cauchqflg      ,
     prtaertaxvlr     like datkavislocal.prtaertaxvlr   ,
     maides           like datkavislocal.maides         ,
     caddat           like datkavislocal.caddat         ,
     cademp           like datkavislocal.cademp         ,
     cadmat           like datkavislocal.cadmat         ,
     cadnom           like isskfunc.funnom              ,
     atldat           like datkavislocal.atldat         ,
     atlemp           like datkavislocal.atlemp         ,
     atlmat           like datkavislocal.atlmat         ,
     atlnom           like isskfunc.funnom              ,         
     obs              like datkavislocal.obs            ,
     dlvlojflg        char(01)
  end record
     
  define k_ctc18m00 record
     lcvcod        like datkavislocal.lcvcod   ,
     lcvextcod     like datkavislocal.lcvextcod,
     aviestcod     like datkavislocal.aviestcod
  end record

  define l_auxcgcNum  char(12),                                                                             
         l_auxcgcOrd  char(4) ,                                                                             
         l_auxcgcDig  char(2) ,                                                                             
         l_aviestcgcnumdig  like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380
         
  clear form
         
  let int_flag = false
  
  let l_auxcgcNum = null
  let l_auxcgcOrd = null
  let l_auxcgcDig = null

  input by name k_ctc18m00.lcvcod, k_ctc18m00.lcvextcod

     before field lcvcod
        display by name k_ctc18m00.lcvcod    attribute (reverse)

     after  field lcvcod
        display by name k_ctc18m00.lcvcod

        if k_ctc18m00.lcvcod is null then
           error " Codigo da Locadora e' item obrigatorio!"
           call ctc30m01() returning k_ctc18m00.lcvcod
           next field lcvcod
        end if

        initialize ctc18m00.lcvnom to null

        select lcvnom into ctc18m00.lcvnom
          from datklocadora
         where lcvcod = k_ctc18m00.lcvcod

        if sqlca.sqlcode <> 0  then
           error " Locadora nao cadastrada!"
           next field lcvcod
        else
           display by name ctc18m00.lcvnom
        end if

     before field lcvextcod
        display by name k_ctc18m00.lcvextcod attribute (reverse)

     after  field lcvextcod
        display by name k_ctc18m00.lcvextcod

        if k_ctc18m00.lcvextcod is null then
           select min(lcvextcod)
             into k_ctc18m00.lcvextcod
             from datkavislocal
            where lcvcod = k_ctc18m00.lcvcod

           if k_ctc18m00.lcvextcod is null  then
              error " Nenhuma loja foi cadastrada para esta locadora!"
              next field lcvcod
           end if
        end if

     on key (interrupt)
        exit input
  end input

  if int_flag  then
     let int_flag = false
     initialize ctc18m00.*   to null
     error " Operacao cancelada!"
     clear form
     return k_ctc18m00.*
  end if

  call sel_ctc18m00(k_ctc18m00.*)  returning  ctc18m00.*,
                                              l_auxcgcNum,
                                              l_auxcgcOrd,
                                              l_auxcgcDig


  if ctc18m00.lcvcod    is not null  and
     ctc18m00.aviestcod is not null  then
     display by name ctc18m00.*
     display by name l_auxcgcNum 
     display by name l_auxcgcOrd 
     display by name l_auxcgcDig 

  else
     error " Registro nao cadastrado!"
     initialize ctc18m00.*    to null
     initialize k_ctc18m00.*  to null
  end if
  
   #Fornax-Quantum - Cadastrar Fornecedor no sistema SAP - Inicio    
   let  m_ctc18m00.lcvcod        =  ctc18m00.lcvcod                  
   let  m_ctc18m00.lcvnom        =  ctc18m00.lcvnom                  
   let  m_ctc18m00.aviestcod     =  ctc18m00.aviestcod               
   let  m_ctc18m00.lcvextcod     =  ctc18m00.lcvextcod               
   let  m_ctc18m00.aviestnom     =  ctc18m00.aviestnom               
   let  m_ctc18m00.lcvlojtip     =  ctc18m00.lcvlojtip               
   let  m_ctc18m00.lcvlojdes     =  ctc18m00.lcvlojdes               
   let  m_ctc18m00.lojqlfcod     =  ctc18m00.lojqlfcod               
   let  m_ctc18m00.lojqlfdes     =  ctc18m00.lojqlfdes               
   let  m_ctc18m00.endlgd        =  ctc18m00.endlgd                  
   let  m_ctc18m00.endbrr        =  ctc18m00.endbrr                  
   let  m_ctc18m00.endcid        =  ctc18m00.endcid                  
   let  m_ctc18m00.endufd        =  ctc18m00.endufd                  
   let  m_ctc18m00.endcep        =  ctc18m00.endcep                  
   let  m_ctc18m00.endcepcmp     =  ctc18m00.endcepcmp               
   let  m_ctc18m00.refptodes     =  ctc18m00.refptodes               
   let  m_ctc18m00.succod        =  ctc18m00.succod                  
   let  m_ctc18m00.sucnom        =  ctc18m00.sucnom                  
   let  m_ctc18m00.dddcod        =  ctc18m00.dddcod                  
   let  m_ctc18m00.teltxt        =  ctc18m00.teltxt                  
   let  m_ctc18m00.facnum        =  ctc18m00.facnum                  
   let  m_ctc18m00.horsegsexinc  =  ctc18m00.horsegsexinc            
   let  m_ctc18m00.horsegsexfnl  =  ctc18m00.horsegsexfnl            
   let  m_ctc18m00.horsabinc     =  ctc18m00.horsabinc               
   let  m_ctc18m00.horsabfnl     =  ctc18m00.horsabfnl               
   let  m_ctc18m00.hordominc     =  ctc18m00.hordominc               
   let  m_ctc18m00.hordomfnl     =  ctc18m00.hordomfnl               
   let  m_ctc18m00.lcvregprccod  =  ctc18m00.lcvregprccod            
   let  m_ctc18m00.lcvregprcdes  =  ctc18m00.lcvregprcdes            
   let  m_ctc18m00.vclalglojstt  =  ctc18m00.vclalglojstt            
   let  m_ctc18m00.lojsttdes     =  ctc18m00.lojsttdes               
   let  m_ctc18m00.cauchqflg     =  ctc18m00.cauchqflg               
   let  m_ctc18m00.prtaertaxvlr  =  ctc18m00.prtaertaxvlr            
   let  m_ctc18m00.maides        =  ctc18m00.maides                  
   let  m_ctc18m00.caddat        =  ctc18m00.caddat                  
   let  m_ctc18m00.cademp        =  ctc18m00.cademp                  
   let  m_ctc18m00.cadmat        =  ctc18m00.cadmat                  
   let  m_ctc18m00.cadnom        =  ctc18m00.cadnom                  
   let  m_ctc18m00.atldat        =  ctc18m00.atldat                  
   let  m_ctc18m00.atlemp        =  ctc18m00.atlemp                  
   let  m_ctc18m00.atlmat        =  ctc18m00.atlmat                  
   let  m_ctc18m00.atlnom        =  ctc18m00.atlnom                  
   let  m_ctc18m00.obs           =  ctc18m00.obs     
   let  m_ctc18m00.dlvlojflg     =  ctc18m00.dlvlojflg
   
   #Fornax-Quantum - Cadastrar Fornecedor no sistema SAP - Inicio    
  

  let k_ctc18m00.aviestcod = ctc18m00.aviestcod

  return k_ctc18m00.*

end function ###  seleciona_ctc18m00

#------------------------------------------------------------
 function proximo_ctc18m00(k_ctc18m00)
#------------------------------------------------------------

 define ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod  char (01)                      ,#paula
    lojqlfdes  char (13)                      ,#paula
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod      ,
    sucnom       like gabksuc.sucnom            ,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

 define k_ctc18m00 record
    lcvcod        like datkavislocal.lcvcod   ,
    lcvextcod     like datkavislocal.lcvextcod,
    aviestcod     like datkavislocal.aviestcod
 end record   

 define l_auxcgcNum  char(12),                                                                             
        l_auxcgcOrd  char(4) ,                                                                             
        l_auxcgcDig  char(2) ,                                                                             
        l_aviestcgcnumdig  like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380
         
 let int_flag = false
        
 select min (lcvextcod)
   into ctc18m00.lcvextcod
   from datkavislocal
  where lcvcod    = k_ctc18m00.lcvcod    and
        lcvextcod > k_ctc18m00.lcvextcod

 if ctc18m00.lcvextcod is null  then
    error " Nao ha' mais registros nesta direcao!"
 else
    let k_ctc18m00.lcvextcod = ctc18m00.lcvextcod

    call sel_ctc18m00 (k_ctc18m00.*)  returning  ctc18m00.*,
                                                 l_auxcgcNum,
                                                 l_auxcgcOrd,
                                                 l_auxcgcDig

    if ctc18m00.lcvcod    is not null  and
       ctc18m00.aviestcod is not null  then
       let k_ctc18m00.lcvcod    = ctc18m00.lcvcod
       let k_ctc18m00.aviestcod = ctc18m00.aviestcod
       let k_ctc18m00.lcvextcod = ctc18m00.lcvextcod

       display by name ctc18m00.*
       display by name l_auxcgcNum 
       display by name l_auxcgcOrd 
       display by name l_auxcgcDig 
    else
       initialize ctc18m00.*    to null
    end if
 end if

 return k_ctc18m00.*

end function  ###  proximo_ctc18m00

#------------------------------------------------------------
 function anterior_ctc18m00(k_ctc18m00)
#------------------------------------------------------------

 define ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod  char (01)                      ,#paula
    lojqlfdes  char (13)                      ,#paula
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod      ,
    sucnom       like gabksuc.sucnom            ,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

 define k_ctc18m00 record
    lcvcod        like datkavislocal.lcvcod   ,
    lcvextcod     like datkavislocal.lcvextcod,
    aviestcod     like datkavislocal.aviestcod
 end record

 define l_auxcgcNum  char(12),                                                                             
        l_auxcgcOrd  char(4) ,                                                                             
        l_auxcgcDig  char(2) ,                                                                             
        l_aviestcgcnumdig  like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380

 let int_flag = false

 select max (lcvextcod)
   into ctc18m00.lcvextcod
   from datkavislocal
  where lcvcod    = k_ctc18m00.lcvcod    and
        lcvextcod < k_ctc18m00.lcvextcod

 if ctc18m00.lcvextcod is null  then
    error " Nao ha' mais registros nesta direcao!"
 else
    let k_ctc18m00.lcvextcod   = ctc18m00.lcvextcod

    call sel_ctc18m00 (k_ctc18m00.*)  returning  ctc18m00.*,
                                                 l_auxcgcNum,
                                                 l_auxcgcOrd,
                                                 l_auxcgcDig    

    if ctc18m00.lcvcod    is not null  and
       ctc18m00.aviestcod is not null  then
       let k_ctc18m00.lcvcod    = ctc18m00.lcvcod
       let k_ctc18m00.aviestcod = ctc18m00.aviestcod
       let k_ctc18m00.lcvextcod = ctc18m00.lcvextcod

       display by name ctc18m00.*
       display by name l_auxcgcNum 
       display by name l_auxcgcOrd 
       display by name l_auxcgcDig
    else
       initialize ctc18m00.*    to null
    end if
 end if

 return k_ctc18m00.*

end function  ###  anterior_ctc18m00

#------------------------------------------------------------
function modifica_ctc18m00(k_ctc18m00)
#------------------------------------------------------------

 define ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod    char (01)                      ,#paula
    lojqlfdes    char (13)                      ,#paula
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod      ,
    sucnom       like gabksuc.sucnom            ,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,        
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

 define lr_ctc18m00_ant record
        lcvcod        like datkavislocal.lcvcod
       ,lcvextcod     like datkavislocal.lcvextcod
       ,aviestnom     like datkavislocal.aviestnom
       ,lcvlojtip     like datkavislocal.lcvlojtip
       ,lojqlfcod   char(01)
       ,lojqlfdes   char(13)                     
       ,endlgd        like datkavislocal.endlgd
       ,endbrr        like datkavislocal.endbrr
       ,endcid        like datkavislocal.endcid
       ,endufd        like datkavislocal.endufd
       ,endcep        like datkavislocal.endcep
       ,endcepcmp     like datkavislocal.endcepcmp
       ,refptodes     char(1)                        
       ,succod        like datkavislocal.succod      
       ,sucnom        like gabksuc.sucnom            
       ,dddcod        like datkavislocal.dddcod
       ,teltxt        like datkavislocal.teltxt
       ,facnum        like datkavislocal.facnum
       ,horsegsexinc  like datkavislocal.horsegsexinc
       ,horsegsexfnl  like datkavislocal.horsegsexfnl
       ,horsabinc     like datkavislocal.horsabinc
       ,horsabfnl     like datkavislocal.horsabfnl
       ,hordominc     like datkavislocal.hordominc
       ,hordomfnl     like datkavislocal.hordomfnl
       ,lcvregprccod  like datkavislocal.lcvregprccod
       ,vclalglojstt  like datkavislocal.vclalglojstt
       ,cauchqflg     like datkavislocal.cauchqflg
       ,prtaertaxvlr  like datkavislocal.prtaertaxvlr
       ,maides        like datkavislocal.maides                                                    
       ,obs           like datkavislocal.obs
       ,dlvlojflg     char(1)
 end record

 define k_ctc18m00 record
    lcvcod        like datkavislocal.lcvcod   ,
    lcvextcod     like datkavislocal.lcvextcod,
    aviestcod     like datkavislocal.aviestcod
 end record

 define ws_situacao record
    viginc          like datklcvsit.viginc,
    vigfnl          like datklcvsit.vigfnl
 end record

 define l_data     date,
        l_hora2    datetime hour to minute,
        l_auxcgcNum  char(12),
        l_auxcgcOrd  char(4) ,
        l_auxcgcDig  char(2) ,
        l_auxcgc     char(14),
        l_aviestcgcnumdig_ant  like datkavislocal.aviestcgcnumdig, #campo adicionado para atender a circular 380
        l_aviestcgcnumdig  like datkavislocal.aviestcgcnumdig  #campo adicionado para atender a circular 380

 initialize lr_ctc18m00_ant to null
 let l_auxcgcNum = null
 let l_auxcgcOrd = null
 let l_auxcgcDig = null
 
 call sel_ctc18m00(k_ctc18m00.*)  returning  ctc18m00.*,
                                             l_auxcgcNum,
                                             l_auxcgcOrd,
                                             l_auxcgcDig
                                                                                      
 let l_auxcgc = l_auxcgcNum clipped,l_auxcgcOrd clipped,l_auxcgcDig clipped
 let l_aviestcgcnumdig_ant = l_auxcgc clipped 
 
 if ctc18m00.lcvcod    is not null  and
    ctc18m00.aviestcod is not null  
    then
    
    display by name ctc18m00.*
    
    if l_auxcgcNum is not null or l_auxcgcNum > 0 then
       display by name l_auxcgcNum
       display by name l_auxcgcOrd
       display by name l_auxcgcDig   
    end if   
    
    call input_ctc18m00("a", k_ctc18m00.*, ctc18m00.*,l_auxcgcNum,l_auxcgcOrd,l_auxcgcDig)
         returning ctc18m00.*, k_ctc18m00.*, ws_situacao.*,l_aviestcgcnumdig
         
       #Fornax-Quantum - Cadastrar Fornecedor no sistema SAP - Inicio           
       let  m_ctc18m00.lcvcod        =  ctc18m00.lcvcod                      
       let  m_ctc18m00.lcvnom        =  ctc18m00.lcvnom                      
       let  m_ctc18m00.aviestcod     =  ctc18m00.aviestcod                   
       let  m_ctc18m00.lcvextcod     =  ctc18m00.lcvextcod                   
       let  m_ctc18m00.aviestnom     =  ctc18m00.aviestnom                   
       let  m_ctc18m00.lcvlojtip     =  ctc18m00.lcvlojtip                   
       let  m_ctc18m00.lcvlojdes     =  ctc18m00.lcvlojdes                   
       let  m_ctc18m00.lojqlfcod     =  ctc18m00.lojqlfcod                   
       let  m_ctc18m00.lojqlfdes     =  ctc18m00.lojqlfdes                   
       let  m_ctc18m00.endlgd        =  ctc18m00.endlgd                      
       let  m_ctc18m00.endbrr        =  ctc18m00.endbrr                      
       let  m_ctc18m00.endcid        =  ctc18m00.endcid                      
       let  m_ctc18m00.endufd        =  ctc18m00.endufd                      
       let  m_ctc18m00.endcep        =  ctc18m00.endcep                      
       let  m_ctc18m00.endcepcmp     =  ctc18m00.endcepcmp                      
       let  m_ctc18m00.refptodes     =  ctc18m00.refptodes                      
       let  m_ctc18m00.succod        =  ctc18m00.succod                         
       let  m_ctc18m00.sucnom        =  ctc18m00.sucnom                         
       let  m_ctc18m00.dddcod        =  ctc18m00.dddcod                         
       let  m_ctc18m00.teltxt        =  ctc18m00.teltxt                         
       let  m_ctc18m00.facnum        =  ctc18m00.facnum                         
       let  m_ctc18m00.horsegsexinc  =  ctc18m00.horsegsexinc                   
       let  m_ctc18m00.horsegsexfnl  =  ctc18m00.horsegsexfnl                   
       let  m_ctc18m00.horsabinc     =  ctc18m00.horsabinc                      
       let  m_ctc18m00.horsabfnl     =  ctc18m00.horsabfnl                      
       let  m_ctc18m00.hordominc     =  ctc18m00.hordominc                      
       let  m_ctc18m00.hordomfnl     =  ctc18m00.hordomfnl                      
       let  m_ctc18m00.lcvregprccod  =  ctc18m00.lcvregprccod                   
       let  m_ctc18m00.lcvregprcdes  =  ctc18m00.lcvregprcdes                   
       let  m_ctc18m00.vclalglojstt  =  ctc18m00.vclalglojstt                   
       let  m_ctc18m00.lojsttdes     =  ctc18m00.lojsttdes                      
       let  m_ctc18m00.cauchqflg     =  ctc18m00.cauchqflg                      
       let  m_ctc18m00.prtaertaxvlr  =  ctc18m00.prtaertaxvlr                   
       let  m_ctc18m00.maides        =  ctc18m00.maides                         
       let  m_ctc18m00.caddat        =  ctc18m00.caddat                         
       let  m_ctc18m00.cademp        =  ctc18m00.cademp                         
       let  m_ctc18m00.cadmat        =  ctc18m00.cadmat                         
       let  m_ctc18m00.cadnom        =  ctc18m00.cadnom                         
       let  m_ctc18m00.atldat        =  ctc18m00.atldat                         
       let  m_ctc18m00.atlemp        =  ctc18m00.atlemp                         
       let  m_ctc18m00.atlmat        =  ctc18m00.atlmat                         
       let  m_ctc18m00.atlnom        =  ctc18m00.atlnom                         
       let  m_ctc18m00.obs           =  ctc18m00.obs                            
       #Fornax-Quantum - Cadastrar Fornecedor no sistema SAP - Inicio           
                                                           
    if int_flag  then                                      
       let int_flag = false
       initialize ctc18m00.*  to null
       error " Operacao cancelada!"
       clear form
       return k_ctc18m00.*
    end if
    
    call cts40g03_data_hora_banco(2) returning l_data, l_hora2
    # Remove os Caracteres especiais das strings na atualizacao do cadastro
    call ctc30m00_remove_caracteres(ctc18m00.lcvextcod)
            returning ctc18m00.lcvextcod
      
    call ctc30m00_remove_caracteres(ctc18m00.aviestnom)
            returning ctc18m00.aviestnom
       
    call ctc30m00_remove_caracteres(ctc18m00.aviestnom)
            returning ctc18m00.aviestnom  
    
    call ctc30m00_remove_caracteres(ctc18m00.endlgd)
            returning ctc18m00.endlgd
      
    call ctc30m00_remove_caracteres(ctc18m00.endbrr)
            returning ctc18m00.endbrr
       
    call ctc30m00_remove_caracteres(ctc18m00.endcid)
            returning ctc18m00.endcid  
    
    call ctc30m00_remove_caracteres(ctc18m00.endcepcmp)
            returning ctc18m00.endcepcmp  
    
    
    update datkavislocal set ( lcvextcod   , aviestnom   ,
                               lcvlojtip   , endlgd      ,
                               endbrr      , endcid      ,
                               endufd      , endcep      ,
                               endcepcmp   , refptodes   ,
                               dddcod      ,
                               teltxt      , facnum      ,
                               horsegsexinc, horsegsexfnl,
                               horsabinc   , horsabfnl   ,
                               hordominc   , hordomfnl   ,
                               lcvregprccod, vclalglojstt,
                               atlemp      , atlmat      ,
                               atldat      , obs         ,
                               cauchqflg   , prtaertaxvlr,
                               lojqlfcod, maides, succod ,
                               aviestcgcnumdig)
                          =  ( ctc18m00.lcvextcod   ,
                               ctc18m00.aviestnom   ,
                               ctc18m00.lcvlojtip   ,
                               ctc18m00.endlgd      ,
                               ctc18m00.endbrr      ,
                               ctc18m00.endcid      ,
                               ctc18m00.endufd      ,
                               ctc18m00.endcep      ,
                               ctc18m00.endcepcmp   ,
                               m_refptodes          ,
                               ctc18m00.dddcod      ,
                               ctc18m00.teltxt      ,
                               ctc18m00.facnum      ,
                               ctc18m00.horsegsexinc,
                               ctc18m00.horsegsexfnl,
                               ctc18m00.horsabinc   ,
                               ctc18m00.horsabfnl   ,
                               ctc18m00.hordominc   ,
                               ctc18m00.hordomfnl   ,
                               ctc18m00.lcvregprccod,
                               ctc18m00.vclalglojstt,
                               g_issk.empcod        ,
                               g_issk.funmat        ,
                               l_data               ,
                               ctc18m00.obs         ,
                               ctc18m00.cauchqflg   ,
                               ctc18m00.prtaertaxvlr,
                               ctc18m00.lojqlfcod ,
                               ctc18m00.maides,
                               ctc18m00.succod,
                               l_aviestcgcnumdig)
                         where lcvcod    = k_ctc18m00.lcvcod     and
                               aviestcod = k_ctc18m00.aviestcod

    if sqlca.sqlcode <> 0
       then
       error " Erro (", sqlca.sqlcode, ") na alteracao do registro. AVISE A INFORMATICA!"
       initialize ctc18m00.*   to null
       initialize k_ctc18m00.* to null
       return k_ctc18m00.*
       
    else
    
       if ws_situacao.viginc >= '31/12/1899'
          then
       else
          let ws_situacao.viginc = '31/12/1899'
       end if
       
       if ws_situacao.vigfnl >= '31/12/1899'
          then
       else
          let ws_situacao.vigfnl = '31/12/1899'
       end if
       
       select lcvcod
         from datklcvsit
        where lcvcod    = ctc18m00.lcvcod
          and aviestcod = ctc18m00.aviestcod

       if sqlca.sqlcode = notfound
          then
          
          insert into datklcvsit ( lcvcod   ,aviestcod ,
                                   viginc   ,vigfnl    ,
                                   atldat   ,atlemp    ,
                                   atlmat   )
                          values ( ctc18m00.lcvcod   ,
                                   ctc18m00.aviestcod,
                                   ws_situacao.viginc,
                                   ws_situacao.vigfnl,
                                   l_data            ,
                                   g_issk.empcod     ,
                                   g_issk.funmat     )

          if sqlca.sqlcode <>  0  then
             error " Erro (", sqlca.sqlcode, ") na inclusao da tab.situacao AVISE A INFORMATICA!"
             return
          end if
          
       else
       
          update datklcvsit set  ( viginc   , vigfnl,
                                   atldat   , atlemp,
                                   atlmat   )
                              =  ( ws_situacao.viginc,
                                   ws_situacao.vigfnl,
                                   l_data            ,
                                   g_issk.empcod     ,
                                   g_issk.funmat     )
                 where lcvcod    = ctc18m00.lcvcod
                   and aviestcod = ctc18m00.aviestcod

          if sqlca.sqlcode <>  0  then
             error " Erro (", sqlca.sqlcode, ") na alteracao da tab.situacao AVISE A INFORMATICA!"
             return
          end if
          
       end if
       error " Alteracao efetuada com sucesso!"
    end if
    
    call ctc18m00_verifica_mod(lr_ctc18m00_ant.*,l_aviestcgcnumdig_ant, ctc18m00.*,l_aviestcgcnumdig)
    
 else
 
    error " Registro nao localizado!"
    
 end if

 return k_ctc18m00.*

end function  ###  modifica_ctc18m00

#--------------------------------------------------------------------
 function remove_ctc18m00(k_ctc18m00)
#--------------------------------------------------------------------

 define ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod  char (01)                      ,#paula
    lojqlfdes  char (13)                      ,#paula
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod      ,
    sucnom       like gabksuc.sucnom            ,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

 define k_ctc18m00 record
    lcvcod        like datkavislocal.lcvcod   ,
    lcvextcod     like datkavislocal.lcvextcod,
    aviestcod     like datkavislocal.aviestcod
 end record
   
   define l_mensagem  char(60)
         ,l_mensagem2 char(60)
         ,l_aux       char(10)
         ,l_stt       smallint

 define l_auxcgcNum  char(12),                                                                             
        l_auxcgcOrd  char(4) ,                                                                             
        l_auxcgcDig  char(2) ,                                                                             
        l_aviestcgcnumdig  like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380      
   
   initialize l_aviestcgcnumdig to null
   let l_auxcgcNum = null
   let l_auxcgcOrd = null
   let l_auxcgcDig = null
   let l_mensagem  = null
   let l_mensagem2 = null
   let l_aux       = null
   let l_stt       = null
   
   
   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do registro."
              clear form
              initialize ctc18m00.*   to null
              initialize k_ctc18m00.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_ctc18m00(k_ctc18m00.*) returning ctc18m00.*,
                                                        l_auxcgcNum,
                                                        l_auxcgcOrd,
                                                        l_auxcgcDig
                                                                                                  
              if ctc18m00.lcvcod    is null  and
                 ctc18m00.aviestcod is null  then
                 initialize ctc18m00.*   to null
                 initialize k_ctc18m00.* to null
                 let l_auxcgcNum = null
                 let l_auxcgcOrd = null
                 let l_auxcgcDig = null
                 error " Registro nao localizado!"
              else
                 begin work

                 delete from datkavislocal
                  where lcvcod    = k_ctc18m00.lcvcod  and
                        aviestcod = k_ctc18m00.aviestcod

                 if sqlca.sqlcode <> 0  then
                    error " Erro (",sqlca.sqlcode,") na exclusao da loja. AVISE A INFORMATICA!"
                    rollback work
                    initialize ctc18m00.*   to null
                    initialize k_ctc18m00.* to null
                    let l_auxcgcNum = null
                    let l_auxcgcOrd = null
                    let l_auxcgcDig = null
                    return k_ctc18m00.*
                 end if

                 delete from datrclauslocal
                  where lcvcod    = k_ctc18m00.lcvcod  and
                        aviestcod = k_ctc18m00.aviestcod

                 if sqlca.sqlcode <> 0  then
                    error " Erro (",sqlca.sqlcode,") na exclusao da clausula. AVISE A INFORMATICA!"
                    rollback work
                    initialize ctc18m00.*   to null
                    initialize k_ctc18m00.* to null
                    let l_auxcgcNum = null
                    let l_auxcgcOrd = null
                    let l_auxcgcDig = null
                    return k_ctc18m00.*
                 end if

                 commit work
                 
                 let l_mensagem  = "Deletada a loja ","[",k_ctc18m00.lcvextcod,"]"," da Locadora de veiculo","[",k_ctc18m00.lcvcod,"]"
                 let l_mensagem2 = "Delecao no cadastro de loja de locadora.",
		     "Codigo : ", k_ctc18m00.lcvcod using '<<<<<' ,"-",
                     k_ctc18m00.aviestcod using '<<<<'
                 let l_aux = k_ctc18m00.lcvcod using '<<<<<' ,"|",k_ctc18m00.aviestcod using '<<<<'                                   
                                                                                                                                   
                 let l_stt = ctc18m00_grava_hist(l_aux  
                                                ,l_mensagem2
                                                ,today    
                                                ,l_mensagem,"D")                                                                     
                 
                 initialize ctc18m00.*   to null
                 initialize k_ctc18m00.* to null
                 error " Registro excluido!"
                 clear form
              end if
              exit menu
   end menu

   return k_ctc18m00.*

end function  ###  remove_ctc18m00

#------------------------------------------------------------
function inclui_ctc18m00()
#------------------------------------------------------------

 define ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod  char (01)                      ,#paula
    lojqlfdes  char (13)                      ,#paula
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod,
    sucnom       like gabksuc.sucnom,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

 define k_ctc18m00 record
    lcvcod        like datkavislocal.lcvcod   ,
    lcvextcod     like datkavislocal.lcvextcod,
    aviestcod     like datkavislocal.aviestcod
 end record

 define ws_situacao record
    viginc          like datklcvsit.viginc,
    vigfnl          like datklcvsit.vigfnl
 end record

 define l_data      date,
        l_hora2     datetime hour to minute
       ,l_mensagem  char(60)
       ,l_mensagem2 char(70)
       ,l_aux       char(10)
       ,l_stt       smallint
       ,l_aviestcgcnumdig  like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380 




 clear form

 initialize ctc18m00.*   to null
 initialize k_ctc18m00.* to null

 let l_mensagem  = null
 let l_mensagem2 = null
 let l_aux       = null
 let l_stt       = null

 call input_ctc18m00("i",k_ctc18m00.*, ctc18m00.*,
                         0,0,0) returning ctc18m00.*,
                                          k_ctc18m00.*,
                                          ws_situacao.*,
                                          l_aviestcgcnumdig
 
 if int_flag  then
    let int_flag = false
    initialize ctc18m00.*  to null
    error " Operacao cancelada!"
    clear form
    return
 end if

 call cts40g03_data_hora_banco(2) returning l_data, l_hora2

 # Remove os Caracteres especiais das strings no cadastro
 call ctc30m00_remove_caracteres(ctc18m00.lcvextcod)
         returning ctc18m00.lcvextcod
   
 call ctc30m00_remove_caracteres(ctc18m00.aviestnom)
         returning ctc18m00.aviestnom
    
 call ctc30m00_remove_caracteres(ctc18m00.aviestnom)
         returning ctc18m00.aviestnom  
 
 call ctc30m00_remove_caracteres(ctc18m00.endlgd)
         returning ctc18m00.endlgd
   
 call ctc30m00_remove_caracteres(ctc18m00.endbrr)
         returning ctc18m00.endbrr
    
 call ctc30m00_remove_caracteres(ctc18m00.endcid)
         returning ctc18m00.endcid  
 
 call ctc30m00_remove_caracteres(ctc18m00.endcepcmp)
         returning ctc18m00.endcepcmp         
 
 
 
 insert into datkavislocal ( lcvcod      , lcvextcod   ,
                             aviestcod   , lcvlojtip   ,
                             aviestnom   , endlgd      ,
                             endbrr      , endcid      ,
                             endufd      , endcep      ,
                             endcepcmp   , refptodes   ,
                             dddcod      ,
                             teltxt      , facnum      ,
                             horsegsexinc, horsegsexfnl,
                             horsabinc   , horsabfnl   ,
                             hordominc   , hordomfnl   ,
                             lcvregprccod, vclalglojstt,
                             cademp      , cadmat      ,
                             caddat      , atlemp      ,
                             atlmat      , atldat      ,
                             obs         , cauchqflg   ,
                             prtaertaxvlr, lojqlfcod,
                             maides, succod,
                             aviestcgcnumdig)
                    values ( ctc18m00.lcvcod      ,
                             ctc18m00.lcvextcod   ,
                             ctc18m00.aviestcod   ,
                             ctc18m00.lcvlojtip   ,
                             ctc18m00.aviestnom   ,
                             ctc18m00.endlgd      ,
                             ctc18m00.endbrr      ,
                             ctc18m00.endcid      ,
                             ctc18m00.endufd      ,
                             ctc18m00.endcep      ,
                             ctc18m00.endcepcmp   ,
                             m_refptodes   ,
                             ctc18m00.dddcod      ,
                             ctc18m00.teltxt      ,
                             ctc18m00.facnum      ,
                             ctc18m00.horsegsexinc,
                             ctc18m00.horsegsexfnl,
                             ctc18m00.horsabinc   ,
                             ctc18m00.horsabfnl   ,
                             ctc18m00.hordominc   ,
                             ctc18m00.hordomfnl   ,
                             ctc18m00.lcvregprccod,
                             ctc18m00.vclalglojstt,
                             g_issk.empcod        ,
                             g_issk.funmat        ,
                             l_data               ,
                             g_issk.empcod        ,
                             g_issk.funmat        ,
                             l_data               ,
                             ctc18m00.obs         ,
                             ctc18m00.cauchqflg   ,
                             ctc18m00.prtaertaxvlr,
                             ctc18m00.lojqlfcod,
                             ctc18m00.maides,
                             ctc18m00.succod,
                             l_aviestcgcnumdig)

 if sqlca.sqlcode <>  0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao do registro. AVISE A INFORMATICA!"
    return
 end if
 
  
 let l_mensagem  = "Incluida a loja ","[",ctc18m00.lcvextcod,"]",
                   " da Locadora de veiculo","[",ctc18m00.lcvcod,"]"
                   
 let l_mensagem2 = "Inclusao no cadastro de loja de locadora de  veiculos. ",
     "Codigo : ",ctc18m00.lcvcod using '<<<<<' ,"-",
      ctc18m00.aviestcod using '<<<<'
 let l_aux = ctc18m00.lcvcod using '<<<<<' ,"|",ctc18m00.aviestcod using '<<<<'
 
 let l_stt = ctc18m00_grava_hist(l_aux ,l_mensagem2 ,l_data ,l_mensagem,"I")
 
 if ws_situacao.viginc >= '31/12/1899'
    then
 else
    let ws_situacao.viginc = '31/12/1899'
 end if
 
 if ws_situacao.vigfnl >= '31/12/1899'
    then
 else
    let ws_situacao.vigfnl = '31/12/1899'
 end if
 
 select lcvcod
   from datklcvsit
  where lcvcod    = ctc18m00.lcvcod
    and aviestcod = ctc18m00.aviestcod
 
 if sqlca.sqlcode = notfound 
    then
    
    insert into datklcvsit ( lcvcod   ,aviestcod ,
                             viginc   ,vigfnl    ,
                             atldat   ,atlemp    ,
                             atlmat   )
                    values ( ctc18m00.lcvcod   ,
                             ctc18m00.aviestcod,
                             ws_situacao.viginc,
                             ws_situacao.vigfnl,
                             l_data            ,
                             g_issk.empcod     ,
                             g_issk.funmat     )

    if sqlca.sqlcode <>  0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao da tab.situacao AVISE A INFORMATICA!"
       return
    end if
    
 else

    update datklcvsit set  ( viginc   , vigfnl,
                             atldat   , atlemp,
                             atlmat   )
                        =  ( ws_situacao.viginc,
                             ws_situacao.vigfnl,
                             l_data            ,
                             g_issk.empcod     ,
                             g_issk.funmat     )
           where lcvcod    = ctc18m00.lcvcod
             and aviestcod = ctc18m00.aviestcod

    if sqlca.sqlcode <>  0  then
       error " Erro (", sqlca.sqlcode, ") na alteracao da tab.situacao AVISE A INFORMATICA!"
       return
    end if
    
 end if
     #Fornax-Quantum - Cadastrar Fornecedor no sistema SAP - Inicio             
     let  m_ctc18m00.lcvcod        =  ctc18m00.lcvcod         
     let  m_ctc18m00.lcvnom        =  ctc18m00.lcvnom         
     let  m_ctc18m00.aviestcod     =  ctc18m00.aviestcod      
     let  m_ctc18m00.lcvextcod     =  ctc18m00.lcvextcod      
     let  m_ctc18m00.aviestnom     =  ctc18m00.aviestnom      
     let  m_ctc18m00.lcvlojtip     =  ctc18m00.lcvlojtip      
     let  m_ctc18m00.lcvlojdes     =  ctc18m00.lcvlojdes      
     let  m_ctc18m00.lojqlfcod     =  ctc18m00.lojqlfcod      
     let  m_ctc18m00.lojqlfdes     =  ctc18m00.lojqlfdes      
     let  m_ctc18m00.endlgd        =  ctc18m00.endlgd         
     let  m_ctc18m00.endbrr        =  ctc18m00.endbrr         
     let  m_ctc18m00.endcid        =  ctc18m00.endcid         
     let  m_ctc18m00.endufd        =  ctc18m00.endufd         
     let  m_ctc18m00.endcep        =  ctc18m00.endcep         
     let  m_ctc18m00.endcepcmp     =  ctc18m00.endcepcmp      
     let  m_ctc18m00.refptodes     =  ctc18m00.refptodes      
     let  m_ctc18m00.succod        =  ctc18m00.succod         
     let  m_ctc18m00.sucnom        =  ctc18m00.sucnom         
     let  m_ctc18m00.dddcod        =  ctc18m00.dddcod         
     let  m_ctc18m00.teltxt        =  ctc18m00.teltxt         
     let  m_ctc18m00.facnum        =  ctc18m00.facnum         
     let  m_ctc18m00.horsegsexinc  =  ctc18m00.horsegsexinc   
     let  m_ctc18m00.horsegsexfnl  =  ctc18m00.horsegsexfnl   
     let  m_ctc18m00.horsabinc     =  ctc18m00.horsabinc      
     let  m_ctc18m00.horsabfnl     =  ctc18m00.horsabfnl      
     let  m_ctc18m00.hordominc     =  ctc18m00.hordominc      
     let  m_ctc18m00.hordomfnl     =  ctc18m00.hordomfnl      
     let  m_ctc18m00.lcvregprccod  =  ctc18m00.lcvregprccod   
     let  m_ctc18m00.lcvregprcdes  =  ctc18m00.lcvregprcdes   
     let  m_ctc18m00.vclalglojstt  =  ctc18m00.vclalglojstt   
     let  m_ctc18m00.lojsttdes     =  ctc18m00.lojsttdes      
     let  m_ctc18m00.cauchqflg     =  ctc18m00.cauchqflg      
     let  m_ctc18m00.prtaertaxvlr  =  ctc18m00.prtaertaxvlr   
     let  m_ctc18m00.maides        =  ctc18m00.maides         
     let  m_ctc18m00.caddat        =  ctc18m00.caddat         
     let  m_ctc18m00.cademp        =  ctc18m00.cademp         
     let  m_ctc18m00.cadmat        =  ctc18m00.cadmat         
     let  m_ctc18m00.cadnom        =  ctc18m00.cadnom         
     let  m_ctc18m00.atldat        =  ctc18m00.atldat         
     let  m_ctc18m00.atlemp        =  ctc18m00.atlemp         
     let  m_ctc18m00.atlmat        =  ctc18m00.atlmat         
     let  m_ctc18m00.atlnom        =  ctc18m00.atlnom         
     let  m_ctc18m00.obs           =  ctc18m00.obs            
 
 error " Inclusao efetuada com sucesso!"

end function  ###  inclui_ctc18m00

#--------------------------------------------------------------------
function input_ctc18m00(operacao, k_ctc18m00, ctc18m00,l_auxcgcNum,l_auxcgcOrd,l_auxcgcDig)
#--------------------------------------------------------------------

 define ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod  char (01)                      ,#paula
    lojqlfdes  char (13)                      ,#paula
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod,
    sucnom       like gabksuc.sucnom,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

 define k_ctc18m00 record
    lcvcod         like datkavislocal.lcvcod   ,
    lcvextcod      like datkavislocal.lcvextcod,
    aviestcod      like datkavislocal.aviestcod
 end record

 define operacao   char (01)

 define ws         record
    lcvextcod      like datkavislocal.lcvextcod,
    lcvstt         like datklocadora.lcvstt    ,
    retlgd         char (40)                   ,
    contador       smallint
 end record

 define ws_situacao record
    viginc          like datklcvsit.viginc,
    vigfnl          like datklcvsit.vigfnl
 end record

 define l_sql        char(200)  #paula
       ,l_erro       smallint
       ,l_lojqlfcod  char(11)
       ,l_err        integer
       ,l_aux        smallint
       ,l_auxcgc     char(14)
       ,l_auxcgcNum  char(12)
       ,l_auxcgcOrd  char(4)
       ,l_auxcgcDig  char(2)
       ,l_count      smallint
       ,l_aviestcgcnumdig like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380

 define l_data     date,
        l_hora2    datetime hour to minute

   let int_flag = false

   if operacao = "a"  then
      let ws.lcvextcod = ctc18m00.lcvextcod
   end if

   input by name ctc18m00.lcvcod       ,
                 ctc18m00.lcvextcod    ,
                 ctc18m00.aviestnom    ,
                 ctc18m00.lcvlojtip    ,
                 #ctc18m00.aviestcgcnumdig,
                 l_auxcgcNum           ,
                 l_auxcgcOrd           ,
                 l_auxcgcDig           ,
                 ctc18m00.lojqlfcod    ,#paula
                 ctc18m00.endlgd       ,
                 ctc18m00.endbrr       ,
                 ctc18m00.endcid       ,
                 ctc18m00.endufd       ,
                 ctc18m00.refptodes    ,
                 ctc18m00.endcep       ,
                 ctc18m00.endcepcmp    ,
                 ctc18m00.succod       ,
                 ctc18m00.dddcod       ,
                 ctc18m00.teltxt       ,
                 ctc18m00.facnum       ,
                 ctc18m00.horsegsexinc ,
                 ctc18m00.horsegsexfnl ,
                 ctc18m00.horsabinc    ,
                 ctc18m00.horsabfnl    ,
                 ctc18m00.hordominc    ,
                 ctc18m00.hordomfnl    ,
                 ctc18m00.lcvregprccod ,
                 ctc18m00.vclalglojstt ,
                 ctc18m00.cauchqflg    ,
                 ctc18m00.prtaertaxvlr ,
                 ctc18m00.maides       ,
                 ctc18m00.obs            without defaults

   before field lcvcod
      if operacao = "a"  then
         next field lcvextcod
      else
         display by name ctc18m00.lcvcod attribute (reverse)
      end if

   after  field lcvcod
      display by name ctc18m00.lcvcod

      if ctc18m00.lcvcod = 0     or
         ctc18m00.lcvcod is null then
         error " Codigo da Locadora deve ser informado!"
         call ctc30m01()  returning ctc18m00.lcvcod
         next field lcvcod
      end if

      select lcvnom, lcvstt
        into ctc18m00.lcvnom,
             ws.lcvstt
        from datklocadora
       where lcvcod = ctc18m00.lcvcod

      if sqlca.sqlcode = notfound  then
         error " Locadora nao cadastrada!"
         next field lcvcod
      else
         display by name ctc18m00.lcvnom

         if ws.lcvstt <> "A"  then
            error " Nao e' possivel cadastrar loja pertencente a locadora cancelada!"
            next field lcvcod
         end if
      end if

   before field lcvextcod
      display by name ctc18m00.lcvextcod attribute (reverse)

   after  field lcvextcod
      display by name ctc18m00.lcvextcod

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.lcvextcod is null or
            ctc18m00.lcvextcod =  "  " then
            error " Codigo da Loja deve ser informado!"
            next field lcvextcod
         end if
      end if

      if ( operacao = "i" ) or ( operacao = "a"   and
           ctc18m00.lcvextcod <> ws.lcvextcod )   then

         select lcvcod, aviestcod
           from datkavislocal
          where lcvcod    = ctc18m00.lcvcod     and
                lcvextcod = ctc18m00.lcvextcod

         if sqlca.sqlcode = 0  then
            error " Codigo de Loja ja' existente!"
            next field lcvextcod
         end if
      end if

   before field aviestnom
      display by name ctc18m00.aviestnom attribute (reverse)

   after  field aviestnom
      display by name ctc18m00.aviestnom

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.aviestnom is null or
            ctc18m00.aviestnom =  "  " then
            error " Razao Social deve ser informado!"
            next field aviestnom
         end if
      end if

   before field lcvlojtip
      display by name ctc18m00.lcvlojtip attribute (reverse)
      
   after  field lcvlojtip
      display by name ctc18m00.lcvlojtip
      
      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.lcvlojtip is null or
            ctc18m00.lcvlojtip =  "  " then
            error " Tipos de loja 1-CORPORACAO, 2-FRANQUIA ou 3-FRANQUIA/REDE deve ser informado!"
            next field lcvlojtip
         end if

         case ctc18m00.lcvlojtip
            when 1 let ctc18m00.lcvlojdes = "CORPORACAO"
            when 2 let ctc18m00.lcvlojdes = "FRANQUIA"
            when 3 let ctc18m00.lcvlojdes = "FRANQUIA/REDE"
            otherwise
                 error " Tipos de loja deve ser 1-CORPORACAO, 2-FRANQUIA ou 3-FRANQUIA/REDE!"
                 next field lcvlojtip
         end case
         display by name ctc18m00.lcvlojdes
      end if
   
   before field l_auxcgcNum
        display by name l_auxcgcNum  attribute(reverse) 
                    
   after field l_auxcgcNum
        display by name l_auxcgcNum
        
        if fgl_lastkey() = fgl_keyval("up") or
         fgl_lastkey() = fgl_keyval("left")
         then
         if l_auxcgcNum is null or
            l_auxcgcNum = ' '
            then
            initialize l_auxcgcNum to null
            display by name l_auxcgcNum
         end if
         next field lcvlojtip
        end if
        
        if l_auxcgcNum is null or
            l_auxcgcNum = ' '
            then
            error "CNPJ E' OBRIGATORIO"
            next field l_auxcgcNum
        end if

   before field l_auxcgcOrd
        display by name l_auxcgcOrd attribute(reverse) 
                    
   after field l_auxcgcOrd
        display by name l_auxcgcOrd
        
        if fgl_lastkey() = fgl_keyval("up") or
         fgl_lastkey() = fgl_keyval("left")
         then
         if l_auxcgcOrd is null or
            l_auxcgcOrd = ' '
            then
            initialize l_auxcgcOrd to null
            display by name l_auxcgcOrd
         end if
         next field l_auxcgcNum
        end if 
        
        if l_auxcgcOrd is null or
            l_auxcgcOrd = ' '
            then
            error "CNPJ E' OBRIGATORIO"
            next field l_auxcgcOrd
        end if

   before field l_auxcgcDig
        display by name l_auxcgcDig attribute(reverse) 
                    
   after field l_auxcgcDig
        display by name l_auxcgcDig
        
        if fgl_lastkey() = fgl_keyval("up") or
         fgl_lastkey() = fgl_keyval("left")
         then
         if l_auxcgcDig is null or
            l_auxcgcDig = ' '
            then
            initialize l_auxcgcDig to null
            display by name l_auxcgcDig
         end if
         next field l_auxcgcOrd
        end if 
        
        if l_auxcgcDig is null or
            l_auxcgcDig = ' '
            then
            error "CNPJ E' OBRIGATORIO"
            next field l_auxcgcDig
        end if
	
        call F_FUNDIGIT_DIGITOCGC(l_auxcgcNum,
                                  l_auxcgcOrd)
             returning l_aux
        if l_aux is null or l_auxcgcDig <> l_aux  then
           error " Digito do CNPJ incorreto!"
           next field l_auxcgcDig
        else
           let l_auxcgc = l_auxcgcNum clipped,l_auxcgcOrd clipped,l_auxcgcDig clipped
           let l_aviestcgcnumdig = l_auxcgc
        end if
       
   before field lojqlfcod #paula
      display by name ctc18m00.lojqlfcod attribute (reverse)
      
   after field lojqlfcod
      display by name ctc18m00.lojqlfcod
      
      if fgl_lastkey() = fgl_keyval("up") or
         fgl_lastkey() = fgl_keyval("left")
         then
         if ctc18m00.lojqlfcod is null or
            ctc18m00.lojqlfcod = ' '
            then
            initialize ctc18m00.lojqlfdes to null
            display by name ctc18m00.lojqlfdes
         end if
         next field l_auxcgcDig
      end if
      
      if ctc18m00.lojqlfcod is null or
         ctc18m00.lojqlfcod =  "  " 
         then
         error " Codigo de qualificação deve ser informado!"
         
         let l_sql = "select cpocod,cpodes       ",
                     "  from iddkdominio         ",
                     " where cponom = 'PSOLOCQLD'"
                     
         call ofgrc001_popup(10,
                             15,
                            "Qualificacoes",
                            "Codigo",
                            "Descricao",
                            "N",
                            l_sql,
                            "",
                            "D")
                  returning l_erro,
                            l_lojqlfcod,
                            ctc18m00.lojqlfdes
                            
         let ctc18m00.lojqlfcod = l_lojqlfcod[11,11]
         
         if ctc18m00.lojqlfcod is null and
            ctc18m00.lojqlfdes is null 
            then
            next field lojqlfcod
         end if
      end if
      
      if ctc18m00.lojqlfcod is not null and
         ctc18m00.lojqlfcod != ' '
         then
         call ctc18m00_id_lojqlfdes(ctc18m00.lojqlfcod)
              returning l_err, ctc18m00.lojqlfdes
              
         if l_err != 0
            then
            error " Qualificação não localizada no domínio, erro: ",
                  l_err using "<<<<<<<<"
            next field lojqlfcod
         end if
      end if
      
      display by name ctc18m00.lojqlfcod
      display by name ctc18m00.lojqlfdes
      
      if ctc18m00.lojqlfcod is null or
         ctc18m00.lojqlfcod =  "  " 
         then
         next field lojqlfcod
      end if
      
   before field endlgd
      display by name ctc18m00.endlgd attribute (reverse)

   after  field endlgd
      display by name ctc18m00.endlgd

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.endlgd    is null or
            ctc18m00.endlgd    =  "  " then
            error " Endereco da Loja deve ser informado!"
            next field endlgd
         end if
      end if

   before field endbrr
      display by name ctc18m00.endbrr attribute (reverse)

   after  field endbrr
      display by name ctc18m00.endbrr

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.endbrr    is null or
            ctc18m00.endbrr    =  "  " then
            error " Bairro deve ser informado!"
            next field endbrr
         end if
      end if

   before field endcid
      display by name ctc18m00.endcid attribute (reverse)

   after  field endcid
      display by name ctc18m00.endcid

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.endcid    is null or
            ctc18m00.endcid    =  "  " then
            error " Cidade deve ser informada!"
            next field endcid
         end if
      end if

   before field endufd
      display by name ctc18m00.endufd attribute (reverse)

   after  field endufd
      display by name ctc18m00.endufd

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         select ufdcod
           from glakest
          where ufdcod = ctc18m00.endufd

         if sqlca.sqlcode = notfound  then
            error " Unidade Federativa nao cadastrada!"
            next field endufd
         end if
      end if

   before field refptodes
      display by name ctc18m00.refptodes attribute (reverse)
   
   after field refptodes
      if ctc18m00.refptodes = "S" then
           call cts08g05_61("Cadastro de Ponto de Referencia de Lojas", m_refptodes)
               returning m_refptodes
      else
          let m_refptodes = null
      end if
      
      if m_refptodes is null or
          m_refptodes clipped = "" then
               let m_refptodes = null
               let ctc18m00.refptodes = "N"
      end if
      
      display by name ctc18m00.refptodes
      
   before field endcep
      display by name ctc18m00.endcep attribute (reverse)

   after  field endcep
      display by name ctc18m00.endcep

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then

         let ws.contador = 0

         select count(*)
           into ws.contador
           from glakcid
          where cidcep = ctc18m00.endcep

         if ws.contador  =  0  then
            let ws.contador = 0

            select count(*)
              into ws.contador
              from glaklgd
             where lgdcep = ctc18m00.endcep

            if ws.contador = 0  then
               call C24GERAL_TRATSTR(ctc18m00.endlgd, 40)
                                     returning ws.retlgd

               error " CEP nao cadastrado - Consulte pelo logradouro!"

               call ctn11c02 (ctc18m00.endufd, ctc18m00.endcid, ws.retlgd)
                              returning ctc18m00.endcep,
                                        ctc18m00.endcepcmp

               if ctc18m00.endcep is null then
                  error " Consulte CEP por cidade!"

                  call  ctn11c03(ctc18m00.endcid) returning ctc18m00.endcep
               end if

               next  field endcep
            end if
         end if
      end if

   before field endcepcmp
      display by name ctc18m00.endcepcmp attribute (reverse)

   after  field endcepcmp
      display by name ctc18m00.endcepcmp

   before field succod
      display by name ctc18m00.succod attribute (reverse)
      if ctc18m00.succod is null
         then
         let ctc18m00.succod = ctb00g01_sugere_sucursal(ctc18m00.endufd,
                                                        ctc18m00.endcid)
         call cty10g00_nome_sucursal(ctc18m00.succod)
              returning m_res, m_msg, ctc18m00.sucnom
         error " Sucursal sugerida conforme a cidade "
         display by name ctc18m00.succod, ctc18m00.sucnom
      end if
      
   after  field succod
      display by name ctc18m00.succod

      if fgl_lastkey() = fgl_keyval("up")  or
         fgl_lastkey() = fgl_keyval("left")
         then
         if ctc18m00.succod is null
            then
            initialize ctc18m00.sucnom to null
            display by name ctc18m00.succod, ctc18m00.sucnom
         end if
         next field endcepcmp
      end if
      
      if ctc18m00.succod is null
         then
         let m_sql = " select succod, sucnom from gabksuc ",
                     " order by 2 "
         call ofgrc001_popup(08, 13, 'ESCOLHA A SUCURSAL',
                            'Codigo', 'Descricao', 'N', m_sql, '', 'D')
              returning m_res, ctc18m00.succod, ctc18m00.sucnom
         next field succod
      end if
      
      if ctc18m00.succod is not null then
         call cty10g00_nome_sucursal(ctc18m00.succod)
              returning m_res, m_msg, ctc18m00.sucnom

         if m_res <> 1 then
            error m_msg
            next field succod
         end if
      end if
      
      display by name ctc18m00.succod, ctc18m00.sucnom
      
   before field dddcod
      display by name ctc18m00.dddcod attribute (reverse)

   after  field dddcod
      display by name ctc18m00.dddcod

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.dddcod    is null or
            ctc18m00.dddcod    =  "  " then
            error " Codigo do DDD deve ser informado!"
            next field dddcod
         end if
      end if

   before field teltxt
      display by name ctc18m00.teltxt attribute (reverse)

   after  field teltxt
      display by name ctc18m00.teltxt

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.teltxt    is null or
            ctc18m00.teltxt    =  "  " then
            error " Telefone deve ser informado!"
            next field teltxt
         end if
      end if

   before field facnum
      display by name ctc18m00.facnum attribute (reverse)

   after  field facnum
      display by name ctc18m00.facnum

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc18m00.facnum is not null then
            if ctc18m00.facnum <= 99999  then
               error " Numero do FAX invalido!"
               next field facnum
            end if
         end if
      end if

   before field horsegsexinc
      display by name ctc18m00.horsegsexinc attribute (reverse)

   after  field horsegsexinc
      display by name ctc18m00.horsegsexinc

   before field horsegsexfnl
      display by name ctc18m00.horsegsexfnl attribute (reverse)

   after  field horsegsexfnl
      display by name ctc18m00.horsegsexfnl

      if ctc18m00.horsegsexinc is null      and
         ctc18m00.horsegsexfnl is not null  then
         error " Horario de funcionamento invalido!"
         next field horsegsexinc
      end if

      if ctc18m00.horsegsexinc is not null  and
         ctc18m00.horsegsexfnl is null      then
         error " Horario de funcionamento invalido!"
         next field horsegsexfnl
      end if

      if ctc18m00.horsegsexinc is not null  and
         ctc18m00.horsegsexfnl is not null  and
         ctc18m00.horsegsexfnl <= ctc18m00.horsegsexinc then
         error " Horario de funcionamento incorreto!"
         next field horsegsexinc
      end if

      if ctc18m00.horsegsexinc <> "00:00"   and
         ctc18m00.horsegsexinc is not null  and
         ctc18m00.horsegsexfnl =  "00:00"   then
         error " Horario de funcionamento incorreto!"
         next field horsegsexinc
      end if

   before field horsabinc
      display by name ctc18m00.horsabinc  attribute (reverse)

   after  field horsabinc
      display by name ctc18m00.horsabinc

   before field horsabfnl
      display by name ctc18m00.horsabfnl  attribute (reverse)

   after  field horsabfnl
      display by name ctc18m00.horsabfnl

      if (ctc18m00.horsabinc = "00:00" or ctc18m00.horsabinc is null) and
         (ctc18m00.horsabfnl = "00:00" or ctc18m00.horsabfnl is null) then
         display by name ctc18m00.horsabinc
         display by name ctc18m00.horsabfnl
      else
         if ctc18m00.horsabinc is null      and
            ctc18m00.horsabfnl is not null  then
            error " Horario de funcionamento invalido!"
            next field horsabinc
         end if

         if ctc18m00.horsabinc is not null  and
            ctc18m00.horsabfnl is null      then
            error " Horario de funcionamento invalido!"
            next field horsabfnl
         end if

         if ctc18m00.horsabinc is not null  and
            ctc18m00.horsabfnl is not null  and
            ctc18m00.horsabfnl <= ctc18m00.horsabinc then
            error " Horario de funcionamento incorreto!"
            next field horsabinc
         end if
      end if

      if ctc18m00.horsabinc <> "00:00"   and
         ctc18m00.horsabinc is not null  and
         ctc18m00.horsabfnl =  "00:00"   then
         error " Horario de funcionamento incorreto!"
         next field horsabinc
      end if

   before field hordominc
      display by name ctc18m00.hordominc  attribute (reverse)

   after  field hordominc
      display by name ctc18m00.hordominc

   before field hordomfnl
      display by name ctc18m00.hordomfnl  attribute (reverse)

   after  field hordomfnl
      display by name ctc18m00.hordomfnl

      if (ctc18m00.hordominc = "00:00" or ctc18m00.hordominc is null) and
         (ctc18m00.hordomfnl = "00:00" or ctc18m00.hordomfnl is null) then
         display by name ctc18m00.hordominc
         display by name ctc18m00.hordomfnl
      else
         if ctc18m00.hordominc is null      and
            ctc18m00.hordomfnl is not null  then
            error " Horario de funcionamento invalido!"
            next field hordominc
         end if

         if ctc18m00.hordominc is not null  and
            ctc18m00.hordomfnl is null      then
            error " Horario de funcionamento invalido!"
            next field hordomfnl
         end if

         if ctc18m00.hordominc is not null  and
            ctc18m00.hordomfnl is not null  and
            ctc18m00.hordomfnl <= ctc18m00.hordominc then
            error " Horario de funcionamento incorreto!"
            next field hordominc
         end if

         if ctc18m00.hordominc <> "00:00"   and
            ctc18m00.hordominc is not null  and
            ctc18m00.hordomfnl =  "00:00"   then
            error " Horario de funcionamento incorreto!"
            next field hordominc
         end if
      end if

   before field lcvregprccod
      display by name ctc18m00.lcvregprccod  attribute (reverse)

   after  field lcvregprccod
      display by name ctc18m00.lcvregprccod
      case ctc18m00.lcvregprccod
         when 1    let ctc18m00.lcvregprcdes = "PADRAO       "
         when 2    let ctc18m00.lcvregprcdes = "REGIAO II    "
         when 3    let ctc18m00.lcvregprcdes = "** LIVRE **  "
         otherwise error " Tarifa Regional deve ser: (1-2-3) "
                   next field lcvregprccod
      end case
      display by name ctc18m00.lcvregprcdes

   before field vclalglojstt
      if operacao = "i"  then
         let ctc18m00.vclalglojstt = 1
         let ctc18m00.lojsttdes    = "ATIVA"
         display by name ctc18m00.vclalglojstt
         display by name ctc18m00.lojsttdes
         next field cauchqflg
      else
         display by name ctc18m00.vclalglojstt  attribute (reverse)
      end if

   after  field vclalglojstt
      display by name ctc18m00.vclalglojstt

      if ctc18m00.vclalglojstt is null  then
         error " Situacao deve ser informada!"
         next field vclalglojstt
      end if
      
      initialize ws_situacao.viginc to null
      initialize ws_situacao.vigfnl to null
      
      case ctc18m00.vclalglojstt
         when  1   let ctc18m00.lojsttdes = "ATIVA"
         when  2   let ctc18m00.lojsttdes = "BLOQUEADA"
                   call ctc18m02(ctc18m00.lcvcod, ctc18m00.aviestcod)
                        returning ws_situacao.viginc, ws_situacao.vigfnl
         when  3   let ctc18m00.lojsttdes = "CANCELADA"
         when  4   let ctc18m00.lojsttdes = "DESATIVADA"
         otherwise error " Situacao deve ser: (1)Ativa, (2)Bloqueada, (3)Cancelada ou (4)Desativada!"
                   next field vclalglojstt
      end case

      display by name ctc18m00.lojsttdes

   before field cauchqflg
       display by name ctc18m00.cauchqflg attribute (reverse)

   after  field cauchqflg
       display by name ctc18m00.cauchqflg

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc18m00.cauchqflg is null then
             error " Cheque Caucao deve ser informado!"
             next field cauchqflg
           else
             if ctc18m00.cauchqflg <> "S"  and
                ctc18m00.cauchqflg <> "N"  then
                error " Cheque Caucao aceita somente (S)im ou (N)ao!"
                next field cauchqflg
             end if
          end if
       end if

   before field prtaertaxvlr
       display by name ctc18m00.prtaertaxvlr  attribute (reverse)

   after  field prtaertaxvlr
       display by name ctc18m00.prtaertaxvlr

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc18m00.prtaertaxvlr is not null then
             if ctc18m00.prtaertaxvlr >= 1 and ctc18m00.prtaertaxvlr <= 100 then
                # taxa correta
             else
                error " Taxa nao pode ser superior a 100%!"
                next field prtaertaxvlr
             end if
          end if
       end if
   
   before field maides
      display by name ctc18m00.maides  attribute (reverse)

   after field maides
      display by name ctc18m00.maides

   before field obs
      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
      if operacao = "i"  then
         let ctc18m00.caddat = l_data
         let ctc18m00.cademp = g_issk.empcod
         let ctc18m00.cadmat = g_issk.funmat

         call ctc18m00_func(ctc18m00.cademp, ctc18m00.cadmat)
              returning ctc18m00.cadnom
      end if

      let ctc18m00.atldat = l_data
      let ctc18m00.atlemp = g_issk.empcod
      let ctc18m00.atlmat = g_issk.funmat

      call ctc18m00_func(ctc18m00.atlemp, ctc18m00.atlmat)
           returning ctc18m00.atlnom

      display by name ctc18m00.caddat,
                      ctc18m00.cademp,
                      ctc18m00.cadmat,
                      ctc18m00.cadnom,
                      ctc18m00.atldat,
                      ctc18m00.atlemp,
                      ctc18m00.atlmat,
                      ctc18m00.atlnom

      display by name ctc18m00.obs    attribute (reverse)

   after  field obs
      display by name ctc18m00.obs

      if operacao = "i"  then
         select max(aviestcod)
           into ctc18m00.aviestcod
           from datkavislocal

         if ctc18m00.aviestcod is null then
            let ctc18m00.aviestcod = 0
         end if

         let ctc18m00.aviestcod   = ctc18m00.aviestcod + 1
         display by name ctc18m00.aviestcod
      end if

      let k_ctc18m00.lcvcod    = ctc18m00.lcvcod
      let k_ctc18m00.lcvextcod = ctc18m00.lcvextcod
      let k_ctc18m00.aviestcod = ctc18m00.aviestcod

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc18m00.* , k_ctc18m00.* to null
   end if

   return ctc18m00.* , k_ctc18m00.*, ws_situacao.*,l_aviestcgcnumdig

end function  ###  input_ctc18m00

#---------------------------------------------------------
 function sel_ctc18m00(k_ctc18m00)
#---------------------------------------------------------

 define ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod    char (01)                      ,#paula
    lojqlfdes    char (13)                      ,#paula
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod      ,
    sucnom       like gabksuc.sucnom            ,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,   
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

 define k_ctc18m00 record
    lcvcod        like datkavislocal.lcvcod   ,
    lcvextcod     like datkavislocal.lcvextcod,
    aviestcod     like datkavislocal.aviestcod
 end record
 
 define l_err              integer,
        l_auxcgcNum        char(12),
        l_auxcgcOrd        char(4) ,
        l_auxcgcDig        char(2) ,
        l_auxcgc           char(14),
        l_indice           smallint,
        l_aviestcgcnumdig  like datkavislocal.aviestcgcnumdig, #campo adicionado para atender a circular 380
        c_aviestcod        char(7),
	l_countlocadora    smallint
        
 initialize ctc18m00.*  to null
 initialize l_aviestcgcnumdig to null
 
 let c_aviestcod = null
 let l_countlocadora = 0
        
 select lcvcod      ,
        lcvextcod   ,
        aviestcod   ,
        aviestnom   ,
        lcvlojtip   ,
        endlgd      ,
        endbrr      ,
        endcid      ,
        endufd      ,
        endcep      ,
        endcepcmp   ,
        refptodes   ,
        dddcod      ,
        teltxt      ,
        facnum      ,
        horsegsexinc,
        horsegsexfnl,
        horsabinc   ,
        horsabfnl   ,
        hordominc   ,
        hordomfnl   ,
        lcvregprccod,
        vclalglojstt,
        caddat      ,
        cademp      ,
        cadmat      ,
        atldat      ,
        atlemp      ,
        atlmat      ,
        obs         ,
        cauchqflg   ,
        prtaertaxvlr,
        lojqlfcod   ,
        maides	    ,
        succod      ,
        aviestcgcnumdig
   into ctc18m00.lcvcod      ,
        ctc18m00.lcvextcod   ,
        ctc18m00.aviestcod   ,
        ctc18m00.aviestnom   ,
        ctc18m00.lcvlojtip   ,
        ctc18m00.endlgd      ,
        ctc18m00.endbrr      ,
        ctc18m00.endcid      ,
        ctc18m00.endufd      ,
        ctc18m00.endcep      ,
        ctc18m00.endcepcmp   ,
        m_refptodes   ,
        ctc18m00.dddcod      ,
        ctc18m00.teltxt      ,
        ctc18m00.facnum      ,
        ctc18m00.horsegsexinc,
        ctc18m00.horsegsexfnl,
        ctc18m00.horsabinc   ,
        ctc18m00.horsabfnl   ,
        ctc18m00.hordominc   ,
        ctc18m00.hordomfnl   ,
        ctc18m00.lcvregprccod,
        ctc18m00.vclalglojstt,
        ctc18m00.caddat      ,
        ctc18m00.cademp      ,
        ctc18m00.cadmat      ,
        ctc18m00.atldat      ,
        ctc18m00.atlemp      ,
        ctc18m00.atlmat      ,
        ctc18m00.obs         ,
        ctc18m00.cauchqflg   ,
        ctc18m00.prtaertaxvlr,
        ctc18m00.lojqlfcod ,
        ctc18m00.maides	     ,
        ctc18m00.succod      ,
        l_aviestcgcnumdig
   from datkavislocal
  where lcvcod    = k_ctc18m00.lcvcod  and
        lcvextcod = k_ctc18m00.lcvextcod

 if m_refptodes is not null then
     let ctc18m00.refptodes = "S"
 else
     let ctc18m00.refptodes = "N"
 end if
 
 if sqlca.sqlcode <> 0  then
    initialize k_ctc18m00.*  to null
    initialize ctc18m00.*    to null
 else
    let ctc18m00.lcvnom = "NAO CADASTRADA!"

    select lcvnom into ctc18m00.lcvnom
      from datklocadora
     where lcvcod = k_ctc18m00.lcvcod
     
    call ctc18m00_id_lojqlfdes(ctc18m00.lojqlfcod)
         returning l_err, ctc18m00.lojqlfdes
    
    case ctc18m00.lcvlojtip
       when 1 let ctc18m00.lcvlojdes = "CORPORACAO"
       when 2 let ctc18m00.lcvlojdes = "FRANQUIA"
       when 3 let ctc18m00.lcvlojdes = "FRANQUIA/REDE"
    end case

    case ctc18m00.vclalglojstt
       when  1   let ctc18m00.lojsttdes = "ATIVA"
       when  2   let ctc18m00.lojsttdes = "BLOQUEADA"
       when  3   let ctc18m00.lojsttdes = "CANCELADA"
       when  4   let ctc18m00.lojsttdes = "DESATIVADA"
    end case

    case ctc18m00.lcvregprccod
       when 1    let ctc18m00.lcvregprcdes = "PADRAO       "
       when 2    let ctc18m00.lcvregprcdes = "REGIAO II    "
       when 3    let ctc18m00.lcvregprcdes = "** LIVRE **  "
    end case

    call ctc18m00_func(ctc18m00.cademp, ctc18m00.cadmat)
         returning ctc18m00.cadnom

    call ctc18m00_func(ctc18m00.atlemp, ctc18m00.atlmat)
         returning ctc18m00.atlnom
         
    call cty10g00_nome_sucursal(ctc18m00.succod)
         returning m_res, m_msg, ctc18m00.sucnom

 end if
 
 let l_auxcgcNum = null
 let l_auxcgcOrd = null
 let l_auxcgcDig = null

 if l_aviestcgcnumdig is not null or l_aviestcgcnumdig = ' ' then
    let l_auxcgc = l_aviestcgcnumdig clipped
    let l_indice = length(l_auxcgc)
    
    while(l_indice > 0)
       if l_indice > length(l_auxcgc) - 2 then
          let l_auxcgcDig = l_auxcgc[l_indice] clipped,l_auxcgcDig clipped
       else
          if l_indice > length(l_auxcgc) - 6 then
              let l_auxcgcOrd = l_auxcgc[l_indice] clipped,l_auxcgcOrd clipped
          else
	      let l_auxcgcNum = l_auxcgc[l_indice] clipped,l_auxcgcNum clipped
          end if
       end if
       let l_indice = l_indice - 1
    end while
 end if 
 
    let c_aviestcod = ctc18m00.aviestcod clipped

    select count(*)
      into l_countlocadora
      from datkdominio
     where cponom = 'LojaLocadoraDeliv'
       and cpodes = c_aviestcod
    
    if l_countlocadora > 0 then 
       let ctc18m00.dlvlojflg = 'S'
    else
       let ctc18m00.dlvlojflg = 'N'
    end if 
    
 return ctc18m00.*,l_auxcgcNum clipped,l_auxcgcOrd clipped,l_auxcgcDig clipped
 
end function  ###  sel_ctc18m00

#---------------------------------------------------------
 function ctc18m00_func(k_ctc18m00)
#---------------------------------------------------------

 define k_ctc18m00 record
    empcod         like isskfunc.empcod ,
    funmat         like isskfunc.funmat
 end record

 define ws         record
    funnom         like isskfunc.funnom
 end record

 let ws.funnom = "NAO CADASTRADO!"

 
 call cty08g00_nome_func(k_ctc18m00.empcod, k_ctc18m00.funmat, "F")
      returning m_res, m_msg, ws.funnom

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  ctc18m00_func

#------------------------------------------------------------
 function ctc18m00_espelho(param)
#------------------------------------------------------------
 define param record
    lcvcod        like datkavislocal.lcvcod   ,
    lcvextcod     like datkavislocal.lcvextcod,
    aviestcod     like datkavislocal.aviestcod
 end record

 define ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod  char (01)                      ,#paula
    lojqlfdes  char (13)                      ,#paula
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod,
    sucnom       like gabksuc.sucnom,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

 define l_auxcgcNum  char(12),                                                                             
        l_auxcgcOrd  char(4) ,                                                                             
        l_auxcgcDig  char(2) ,                                                                             
        l_aviestcgcnumdig  like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380
        
   let l_auxcgcNum = null
   let l_auxcgcOrd = null
   let l_auxcgcDig = null     

   open window ctc18m00 at 04,02 with form "ctc18m00"
   clear form

   call sel_ctc18m00 (param.*)  returning  ctc18m00.*,
                                           l_auxcgcNum,
                                           l_auxcgcOrd,
                                           l_auxcgcDig

   if ctc18m00.lcvcod    is not null  and
      ctc18m00.aviestcod is not null  then
      display by name ctc18m00.*
      
      
      display by name l_auxcgcNum 
      display by name l_auxcgcOrd 
      display by name l_auxcgcDig 

      input by name param.lcvcod without defaults

         before field lcvcod
            display by name param.lcvcod    attribute (reverse)

         after  field lcvcod
            display by name param.lcvcod

         on key (interrupt)
            exit input
      end input
   else
      error " Registro nao cadastrado!"
      initialize ctc18m00.*    to null
      let l_auxcgcNum = null
      let l_auxcgcOrd = null
      let l_auxcgcDig = null
                                  
      initialize param.*  to null
   end if

   close window ctc18m00

end function  ###  ctc18m00_espelho


#----------------------------------------------------------------
function ctc18m00_id_lojqlfdes(l_lojqlfcod)
#----------------------------------------------------------------

  define l_lojqlfcod  like datkavislocal.lojqlfcod ,
         l_lojqlfdes  char(13)
         
  initialize l_lojqlfdes to null
  
  whenever error continue
  open c_lojqlfdes_sel using l_lojqlfcod
  fetch c_lojqlfdes_sel into l_lojqlfdes
  whenever error stop
  
  return sqlca.sqlcode, l_lojqlfdes
  
end function

#--------------------------------------------------------
function ctc18m00_grava_hist(lr_param,l_mensagem,l_opcao)
#--------------------------------------------------------

   define lr_param record
          codigo     char(10)
         ,titulo     char(100)
         ,data       date
          end record

   define lr_retorno record
          stt       smallint
          ,msg char(50)
          end record

   define l_mensagem  char(3000)
         ,l_stt       smallint
         ,l_erro      smallint
         ,l_path      char(100)
         ,l_data      date 
	 ,l_hora      datetime hour to minute
	 ,l_prshstdes2  char(3000)
	 ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint
         ,l_opcao     char(1)
       

   call cts40g03_data_hora_banco(2)
	    returning l_data, l_hora 

   let l_stt  = true
   let l_path = null

   initialize lr_retorno to null
   
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
       
      call ctb85g01_grava_hist(3
                              ,lr_param.codigo
                              ,l_prshstdes2 
                              ,lr_param.data
                              ,g_issk.empcod
                              ,g_issk.funmat
                              ,g_issk.usrtip)
          returning lr_retorno.stt
                   ,lr_retorno.msg

   end for  
  
   if l_opcao <> "A" then
      if lr_retorno.stt = 0 then
   
        call ctb85g01_mtcorpo_email_html('CTC18M00',
	   			        lr_param.data,
				        l_hora,
				        g_issk.empcod,
				        g_issk.usrtip,
				        g_issk.funmat,
				        lr_param.titulo,
				        l_mensagem)
                         returning l_erro
        if l_erro  <> 0 then
           error 'Erro no envio do e-mail' sleep 2
           let l_stt = false
        end if  
                       
       else
          error 'Erro na gravacao do historico' sleep 2
          let l_stt = false
       end if
   end if
   
   return l_stt

end function

#---------------------------------------------------------
function ctc18m00_verifica_mod(lr_ctc18m00_ant,l_aviestcgcnumdig_ant,lr_ctc18m00,l_aviestcgcnumdig)
#---------------------------------------------------------

   define lr_ctc18m00 record
    lcvcod       like datkavislocal.lcvcod      ,
    lcvnom       like datklocadora.lcvnom       ,
    aviestcod    like datkavislocal.aviestcod   ,
    lcvextcod    like datkavislocal.lcvextcod   ,
    aviestnom    like datkavislocal.aviestnom   ,
    lcvlojtip    like datkavislocal.lcvlojtip   ,
    lcvlojdes    char (13)                      ,
    lojqlfcod  char (01)                      ,
    lojqlfdes  char (13)                      ,
    endlgd       like datkavislocal.endlgd      ,
    endbrr       like datkavislocal.endbrr      ,
    endcid       like datkavislocal.endcid      ,
    endufd       like datkavislocal.endufd      ,
    endcep       like datkavislocal.endcep      ,
    endcepcmp    like datkavislocal.endcepcmp   ,
    refptodes    char(1)                        ,
    succod       like datkavislocal.succod      ,
    sucnom       like gabksuc.sucnom            ,
    dddcod       like datkavislocal.dddcod      ,
    teltxt       like datkavislocal.teltxt      ,
    facnum       like datkavislocal.facnum      ,
    horsegsexinc like datkavislocal.horsegsexinc,
    horsegsexfnl like datkavislocal.horsegsexfnl,
    horsabinc    like datkavislocal.horsabinc   ,
    horsabfnl    like datkavislocal.horsabfnl   ,
    hordominc    like datkavislocal.hordominc   ,
    hordomfnl    like datkavislocal.hordomfnl   ,
    lcvregprccod like datkavislocal.lcvregprccod,
    lcvregprcdes char (13)                      ,
    vclalglojstt like datkavislocal.vclalglojstt,
    lojsttdes    char (09)                      ,
    cauchqflg    like datkavislocal.cauchqflg   ,
    prtaertaxvlr like datkavislocal.prtaertaxvlr,
    maides       like datkavislocal.maides      ,
    caddat       like datkavislocal.caddat      ,
    cademp       like datkavislocal.cademp      ,
    cadmat       like datkavislocal.cadmat      ,
    cadnom       like isskfunc.funnom           ,
    atldat       like datkavislocal.atldat      ,
    atlemp       like datkavislocal.atlemp      ,
    atlmat       like datkavislocal.atlmat      ,
    atlnom       like isskfunc.funnom           ,
    obs          like datkavislocal.obs         ,
    dlvlojflg    char(1)
 end record

   define lr_ctc18m00_ant record
          lcvcod        like datkavislocal.lcvcod
         ,lcvextcod     like datkavislocal.lcvextcod
         ,aviestnom     like datkavislocal.aviestnom
         ,lcvlojtip     like datkavislocal.lcvlojtip
         ,lojqlfcod   char(01)
         ,lojqlfdes  char (13)                      
         ,endlgd        like datkavislocal.endlgd
         ,endbrr        like datkavislocal.endbrr
         ,endcid        like datkavislocal.endcid
         ,endufd        like datkavislocal.endufd
         ,endcep        like datkavislocal.endcep
         ,endcepcmp     like datkavislocal.endcepcmp
         ,refptodes    char(1)                        
         ,succod       like datkavislocal.succod      
         ,sucnom       like gabksuc.sucnom                     
         ,dddcod        like datkavislocal.dddcod
         ,teltxt        like datkavislocal.teltxt
         ,facnum        like datkavislocal.facnum
         ,horsegsexinc  like datkavislocal.horsegsexinc
         ,horsegsexfnl  like datkavislocal.horsegsexfnl
         ,horsabinc     like datkavislocal.horsabinc
         ,horsabfnl     like datkavislocal.horsabfnl
         ,hordominc     like datkavislocal.hordominc
         ,hordomfnl     like datkavislocal.hordomfnl
         ,lcvregprccod  like datkavislocal.lcvregprccod
         ,vclalglojstt  like datkavislocal.vclalglojstt
         ,cauchqflg     like datkavislocal.cauchqflg
         ,prtaertaxvlr  like datkavislocal.prtaertaxvlr
         ,maides        like datkavislocal.maides
         ,obs           like datkavislocal.obs
         ,dlvlojflg     char(1)
   end record

   define l_mensagem  char(3000)
         ,l_mensagem2 char(100)
         ,l_aux       char(10)
         ,l_mensmail  char(3000)
         ,l_flg       smallint
         ,l_erro      smallint
         ,l_aviestcgcnumdig_ant  like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380 
         ,l_aviestcgcnumdig      like datkavislocal.aviestcgcnumdig #campo adicionado para atender a circular 380 
          
   let l_mensmail   =  null       
   let l_aux = lr_ctc18m00.lcvcod using '<<<<<' ,"|",lr_ctc18m00.aviestcod using '<<<<'
   let l_mensagem2 = 'Alteracao no cadastro de Lojas de Locacao de Veiculos'

   if (lr_ctc18m00_ant.lcvcod is null     and lr_ctc18m00.lcvcod is not null) or
      (lr_ctc18m00_ant.lcvcod is not null and lr_ctc18m00.lcvcod is null)     or
      (lr_ctc18m00_ant.lcvcod              <> lr_ctc18m00.lcvcod)             then
      let l_mensagem = "Codigo da Locadora alterado de [",lr_ctc18m00_ant.lcvcod clipped,"] para [",lr_ctc18m00.lcvcod clipped,"]"
      
      let l_mensmail = l_mensagem clipped
      let l_flg = 1
      
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.lcvextcod is null     and lr_ctc18m00.lcvextcod is not null) or
      (lr_ctc18m00_ant.lcvextcod is not null and lr_ctc18m00.lcvextcod is null)     or
      (lr_ctc18m00_ant.lcvextcod              <> lr_ctc18m00.lcvextcod)             then
      
      let l_mensagem = "codigo da Loja alterado de [",lr_ctc18m00_ant.lcvextcod clipped,"] para [",lr_ctc18m00.lcvextcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1      
     
      if not ctc18m00_grava_hist(l_aux                                                                   
                                ,l_mensagem2                                                                           
                                ,lr_ctc18m00.atldat                                                                   
                                ,l_mensagem,"A") then                                                                       
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped                                                                                                       
      end if                                                                                                          
   end if
   
   if (lr_ctc18m00_ant.aviestnom is null     and lr_ctc18m00.aviestnom is not null) or
      (lr_ctc18m00_ant.aviestnom is not null and lr_ctc18m00.aviestnom is null)     or
      (lr_ctc18m00_ant.aviestnom              <> lr_ctc18m00.aviestnom)             then
      let l_mensagem = "Nome da Loja alterado de [",lr_ctc18m00_ant.aviestnom clipped,"] para [",lr_ctc18m00.aviestnom clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux                                                                   
                                ,l_mensagem2                                                                           
                                ,lr_ctc18m00.atldat                                                                   
                                ,l_mensagem,"A") then                                                                       
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped                                                                                                       
      end if                                                                                                          
   end if
   
   if (lr_ctc18m00_ant.lcvlojtip is null     and lr_ctc18m00.lcvlojtip is not null) or
      (lr_ctc18m00_ant.lcvlojtip is not null and lr_ctc18m00.lcvlojtip is null)     or
      (lr_ctc18m00_ant.lcvlojtip              <> lr_ctc18m00.lcvlojtip)             then
      let l_mensagem = "Tipo da loja alterado de [",lr_ctc18m00_ant.lcvlojtip clipped,"] para [",lr_ctc18m00.lcvlojtip clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux                                                                   
                                ,l_mensagem2                                                                           
                                ,lr_ctc18m00.atldat                                                                   
                                ,l_mensagem,"A") then                                                                       
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped                                                                                                       
      end if                                                                                                          
   end if
   
   if (lr_ctc18m00_ant.lojqlfcod is null     and lr_ctc18m00.lojqlfcod is not null) or
      (lr_ctc18m00_ant.lojqlfcod is not null and lr_ctc18m00.lojqlfcod is null)     or
      (lr_ctc18m00_ant.lojqlfcod              <> lr_ctc18m00.lojqlfcod)             then
      let l_mensagem = "Qualificacao alterada de [",lr_ctc18m00_ant.lojqlfcod clipped,
                       "-",lr_ctc18m00_ant.lojqlfdes, "] para [",lr_ctc18m00.lojqlfcod clipped,
                       "-",lr_ctc18m00.lojqlfdes clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.endlgd is null     and lr_ctc18m00.endlgd is not null) or
      (lr_ctc18m00_ant.endlgd is not null and lr_ctc18m00.endlgd is null)     or
      (lr_ctc18m00_ant.endlgd              <> lr_ctc18m00.endlgd)             then
      let l_mensagem = "Endereco da Loja alterado de [",lr_ctc18m00_ant.endlgd clipped,"] para [",lr_ctc18m00.endlgd clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.endbrr is null     and lr_ctc18m00.endbrr is not null) or
      (lr_ctc18m00_ant.endbrr is not null and lr_ctc18m00.endbrr is null)     or
      (lr_ctc18m00_ant.endbrr              <> lr_ctc18m00.endbrr)             then
      let l_mensagem = "Bairro  alterado de [",lr_ctc18m00_ant.endbrr clipped,"] para [",lr_ctc18m00.endbrr clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.endcid is null     and lr_ctc18m00.endcid is not null) or
      (lr_ctc18m00_ant.endcid is not null and lr_ctc18m00.endcid is null)     or
      (lr_ctc18m00_ant.endcid              <> lr_ctc18m00.endcid)             then
      let l_mensagem = "Cidade  alterado de [",lr_ctc18m00_ant.endcid clipped,"] para [",lr_ctc18m00.endcid clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.endufd is null     and lr_ctc18m00.endufd is not null) or
      (lr_ctc18m00_ant.endufd is not null and lr_ctc18m00.endufd is null)     or
      (lr_ctc18m00_ant.endufd              <> lr_ctc18m00.endufd)             then
      let l_mensagem = "Sigla da Unidade alterado de [",lr_ctc18m00_ant.endufd clipped,"] para [",lr_ctc18m00.endufd clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.endcep is null     and lr_ctc18m00.endcep is not null) or
      (lr_ctc18m00_ant.endcep is not null and lr_ctc18m00.endcep is null)     or
      (lr_ctc18m00_ant.endcep              <> lr_ctc18m00.endcep)             then
      let l_mensagem = "CEP alterado de [",lr_ctc18m00_ant.endcep clipped,"] para [",lr_ctc18m00.endcep clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.endcepcmp is null     and lr_ctc18m00.endcepcmp is not null) or
      (lr_ctc18m00_ant.endcepcmp is not null and lr_ctc18m00.endcepcmp is null)     or
      (lr_ctc18m00_ant.endcepcmp              <> lr_ctc18m00.endcepcmp)             then
      let l_mensagem = "Complemento do Cep alterado de [",lr_ctc18m00_ant.endcepcmp clipped,"] para [",lr_ctc18m00.endcepcmp clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.dddcod is null     and lr_ctc18m00.dddcod is not null) or
      (lr_ctc18m00_ant.dddcod is not null and lr_ctc18m00.dddcod is null)     or
      (lr_ctc18m00_ant.dddcod              <> lr_ctc18m00.dddcod)             then
      let l_mensagem = "Codigo do DDD alterado de [",lr_ctc18m00_ant.dddcod clipped,"] para [",lr_ctc18m00.dddcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.teltxt is null     and lr_ctc18m00.teltxt is not null) or
      (lr_ctc18m00_ant.teltxt is not null and lr_ctc18m00.teltxt is null)     or
      (lr_ctc18m00_ant.teltxt              <> lr_ctc18m00.teltxt)             then
      let l_mensagem = "Telefonda da Loja alterado de [",lr_ctc18m00_ant.teltxt clipped,"] para [",lr_ctc18m00.teltxt clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.facnum is null     and lr_ctc18m00.facnum is not null) or
      (lr_ctc18m00_ant.facnum is not null and lr_ctc18m00.facnum is null)     or
      (lr_ctc18m00_ant.facnum              <> lr_ctc18m00.facnum)             then
      let l_mensagem = "Fax da Loja alterado de [",lr_ctc18m00_ant.facnum clipped,"] para [",lr_ctc18m00.facnum clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.horsegsexinc is null     and lr_ctc18m00.horsegsexinc is not null) or
      (lr_ctc18m00_ant.horsegsexinc is not null and lr_ctc18m00.horsegsexinc is null)     or
      (lr_ctc18m00_ant.horsegsexinc              <> lr_ctc18m00.horsegsexinc)             then
      let l_mensagem = "Horario Segunda inicial alterado de [",lr_ctc18m00_ant.horsegsexinc clipped,"] para [",lr_ctc18m00.horsegsexinc clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.horsegsexfnl is null     and lr_ctc18m00.horsegsexfnl is not null) or
      (lr_ctc18m00_ant.horsegsexfnl is not null and lr_ctc18m00.horsegsexfnl is null)     or
      (lr_ctc18m00_ant.horsegsexfnl              <> lr_ctc18m00.horsegsexfnl)             then
      let l_mensagem = "Horario Segunda Final alterado de [",lr_ctc18m00_ant.horsegsexfnl clipped,"] para [",lr_ctc18m00.horsegsexfnl clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.horsabinc is null     and lr_ctc18m00.horsabinc is not null) or
      (lr_ctc18m00_ant.horsabinc is not null and lr_ctc18m00.horsabinc is null)     or
      (lr_ctc18m00_ant.horsabinc              <> lr_ctc18m00.horsabinc)             then
      let l_mensagem = "Horario Sabado Inicial alterado de [",lr_ctc18m00_ant.horsabinc clipped,"] para [",lr_ctc18m00.horsabinc clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2                                
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.horsabfnl is null     and lr_ctc18m00.horsabfnl is not null) or
      (lr_ctc18m00_ant.horsabfnl is not null and lr_ctc18m00.horsabfnl is null)     or
      (lr_ctc18m00_ant.horsabfnl              <> lr_ctc18m00.horsabfnl)             then
      let l_mensagem = "Horario SAbado Final alterado de [",lr_ctc18m00_ant.horsabfnl clipped,"] para [",lr_ctc18m00.horsabfnl clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.hordominc is null     and lr_ctc18m00.hordominc is not null) or
      (lr_ctc18m00_ant.hordominc is not null and lr_ctc18m00.hordominc is null)     or
      (lr_ctc18m00_ant.hordominc              <> lr_ctc18m00.hordominc)             then
      let l_mensagem = "Horario Domingo Inicial alterado de [",lr_ctc18m00_ant.hordominc clipped,"] para [",lr_ctc18m00.hordominc clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.hordomfnl is null     and lr_ctc18m00.hordomfnl is not null) or
      (lr_ctc18m00_ant.hordomfnl is not null and lr_ctc18m00.hordomfnl is null)     or
      (lr_ctc18m00_ant.hordomfnl              <> lr_ctc18m00.hordomfnl)             then
      let l_mensagem = "Horario domingo Final alterado de [",lr_ctc18m00_ant.hordomfnl clipped,"] para [",lr_ctc18m00.hordomfnl clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.lcvregprccod is null     and lr_ctc18m00.lcvregprccod is not null) or
      (lr_ctc18m00_ant.lcvregprccod is not null and lr_ctc18m00.lcvregprccod is null)     or
      (lr_ctc18m00_ant.lcvregprccod              <> lr_ctc18m00.lcvregprccod)             then
      let l_mensagem = "Codigo da Tarifa Reginal alterado de [",lr_ctc18m00_ant.lcvregprccod clipped,"] para [",lr_ctc18m00.lcvregprccod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.vclalglojstt is null     and lr_ctc18m00.vclalglojstt is not null) or
      (lr_ctc18m00_ant.vclalglojstt is not null and lr_ctc18m00.vclalglojstt is null)     or
      (lr_ctc18m00_ant.vclalglojstt              <> lr_ctc18m00.vclalglojstt)             then
      let l_mensagem = "Situacao alterado de [",lr_ctc18m00_ant.vclalglojstt clipped,"] para [",lr_ctc18m00.vclalglojstt clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.cauchqflg is null     and lr_ctc18m00.cauchqflg is not null) or
      (lr_ctc18m00_ant.cauchqflg is not null and lr_ctc18m00.cauchqflg is null)     or
      (lr_ctc18m00_ant.cauchqflg              <> lr_ctc18m00.cauchqflg)             then
      let l_mensagem = "Cheque Calcao  alterado de [",lr_ctc18m00_ant.cauchqflg clipped,"] para [",lr_ctc18m00.cauchqflg clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.prtaertaxvlr is null     and lr_ctc18m00.prtaertaxvlr is not null) or
      (lr_ctc18m00_ant.prtaertaxvlr is not null and lr_ctc18m00.prtaertaxvlr is null)     or
      (lr_ctc18m00_ant.prtaertaxvlr              <> lr_ctc18m00.prtaertaxvlr)             then
      let l_mensagem = "Taxa Aeroportuaria alterada de [",lr_ctc18m00_ant.prtaertaxvlr clipped,"] para [",lr_ctc18m00.prtaertaxvlr clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc18m00_ant.maides is null     and lr_ctc18m00.maides is not null) or
      (lr_ctc18m00_ant.maides is not null and lr_ctc18m00.maides is null)     or
      (lr_ctc18m00_ant.maides              <> lr_ctc18m00.maides)             then
      let l_mensagem = "Endereco de email alterado de [",lr_ctc18m00_ant.maides clipped,"] para [",lr_ctc18m00.maides clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if
 
   if (lr_ctc18m00_ant.obs is null     and lr_ctc18m00.obs is not null) or
      (lr_ctc18m00_ant.obs is not null and lr_ctc18m00.obs is null)     or
      (lr_ctc18m00_ant.obs              <> lr_ctc18m00.obs)             then
      let l_mensagem = "Observacoes alterado de [",lr_ctc18m00_ant.obs clipped,"] para [",lr_ctc18m00.obs clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if
   
   if (l_aviestcgcnumdig_ant is null     and l_aviestcgcnumdig is not null) or
      (l_aviestcgcnumdig_ant is not null and l_aviestcgcnumdig is null)     or
      (l_aviestcgcnumdig_ant <> l_aviestcgcnumdig)             then
      let l_mensagem = "CNPJ alterado de [",l_aviestcgcnumdig_ant clipped,"] para [",
          l_aviestcgcnumdig clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1
      if not ctc18m00_grava_hist(l_aux
                                ,l_mensagem2
                                ,lr_ctc18m00.atldat
                                ,l_mensagem,"A") then   
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if
     
   if  l_mensmail is not null then     
       call ctb85g01_mtcorpo_email_html('CTC18M00',
                                    lr_ctc18m00.atldat,
                                    current hour to minute,
                                    g_issk.empcod,
                                    g_issk.usrtip,
                                    g_issk.funmat,
                                    l_mensagem2,
                                    l_mensmail)
               returning l_erro

      if l_erro  <> 0 then
	 error 'Erro no envio do e-mail' sleep 2
      end if
   end if   
    
end function  
                                               
                                               
                                               
                                               
# BURINI                                               
                                               
#---------------------------------#                                               
 function ctc18m00_empresa(param)                                               
#---------------------------------# 
                                               
    define param record
         lcvcod         like datkavislocal.lcvcod,
         aviestcod      like datkavislocal.aviestcod,
         tip            char(1) #Fornax-Quantum
    end record
                  
    define a_empresas array[15] of record
        ciaempcod   like gabkemp.empcod
    end record                  
                  
    define a_empresas_aux array[15] of record
        ciaempcod   like gabkemp.empcod
    end record
    
    define l_ret        smallint,
           l_mensagem   char(60),
           l_mensagem2  char(100),
           l_aux        smallint,
           l_stt        smallint,
           l_total      smallint,
           x,n          integer,
           l_ctrl       smallint,
           lr_qtdempant   smallint, #Fornax-Quantum
           lr_qtdempatual smallint  #Fornax-Quantum 
    
    initialize a_empresas to null
    initialize a_empresas_aux to null

    let l_ret       = 0
    let l_mensagem  = null
    let l_mensagem2 = null
    let l_aux       = 1
    let l_total     = 0     
    
    #Fornax-Quantum - Incio 
    #Verifica Quantidade de Empresa cadastrada anterior 
    select count(*)
      into lr_qtdempant
      from datrlcdljaemprlc                  
     where aviestcod = param.aviestcod   
       and lcvcod    = param.lcvcod      
    #Fornax-Quantum - Incio 
                  
    call ctd03g01_empresas(1, param.aviestcod, param.lcvcod)
         returning l_ret,
                   l_mensagem,
                   l_total,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_empresas[15].ciaempcod                  
                  
    let a_empresas_aux[1].ciaempcod   =  a_empresas[1].ciaempcod
    let a_empresas_aux[2].ciaempcod   =  a_empresas[2].ciaempcod
    let a_empresas_aux[3].ciaempcod   =  a_empresas[3].ciaempcod
    let a_empresas_aux[4].ciaempcod   =  a_empresas[4].ciaempcod
    let a_empresas_aux[5].ciaempcod   =  a_empresas[5].ciaempcod
    let a_empresas_aux[6].ciaempcod   =  a_empresas[6].ciaempcod
    let a_empresas_aux[7].ciaempcod   =  a_empresas[7].ciaempcod
    let a_empresas_aux[8].ciaempcod   =  a_empresas[8].ciaempcod
    let a_empresas_aux[9].ciaempcod   =  a_empresas[9].ciaempcod
    let a_empresas_aux[10].ciaempcod  =  a_empresas[10].ciaempcod
    let a_empresas_aux[11].ciaempcod  =  a_empresas[11].ciaempcod
    let a_empresas_aux[12].ciaempcod  =  a_empresas[12].ciaempcod
    let a_empresas_aux[13].ciaempcod  =  a_empresas[13].ciaempcod
    let a_empresas_aux[14].ciaempcod  =  a_empresas[14].ciaempcod
    let a_empresas_aux[15].ciaempcod  =  a_empresas[15].ciaempcod                  
                  
    #Abrir janela para atualizacao de empresas para o prestador
    call ctc00m03 (4,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_empresas[15].ciaempcod)
         returning l_ret,
                   l_mensagem,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_emprEsas[15].ciaempcod                  
                  
    if l_ret = 1 then
       #apagar empresas cadastradas ao prestador
       call ctd03g01_delete_datrlcdljaemprlc(param.aviestcod, param.lcvcod)
            returning l_ret,
                      l_mensagem

       #Verificar qual empresa  foi excluida e envia email - psi 226300
       for n = 1 to 15
	   if a_empresas_aux[n].ciaempcod is not null then
	      let l_ctrl = 0
	      for x = 1 to 15
	         if a_empresas[x].ciaempcod is not null then
                    if a_empresas[x].ciaempcod = a_empresas_aux[n].ciaempcod then
                       let l_ctrl = 1
                       exit for
                    end if
                 end if
              end for
              if l_ctrl = 0 then
	         #let l_mensagem2 = 'Exclusao de Empresa do Veiculo. Codigo : ',
	         #                  param.socvclcod
	         #let l_mensagem  = "Empresa  [",a_empresas_aux[n].ciaempcod,"] Excluida !"
	         #let l_stt = ctc34m01_grava_hist(param.socvclcod
                 #                               ,l_mensagem
                 #                               ,today
                 #                               ,l_mensagem2,"I")
              end if
            else
              exit for
           end if
       end for

       #inserir empresas cadastradas a locadora/veiculo
       if l_ret = 1 then
          #percorrer array de empresas e inserir para o prestador
          while l_aux <= 15    #tamanho do array
                if a_empresas[l_aux].ciaempcod is not null then
                    call ctd03g01_insert_datrlcdljaemprlc(param.aviestcod,
                                                          a_empresas[l_aux].ciaempcod,
                                                          param.lcvcod)
                         returning l_ret,
                                   l_mensagem
                    if l_ret <> 1 then
                       error l_mensagem
                       exit while
                    end if
                    #Verificar qual empresa  foi Incluida ou mantida e envia email - psi 226300
                    let l_ctrl = 0

                    for x = 1 to 15
                      if a_empresas[l_aux].ciaempcod = a_empresas_aux[x].ciaempcod then
                         # Nao eh para enviar email qdo a empresa for mantida
                         let l_mensagem  = "Empresa  [",a_empresas[l_aux].ciaempcod,
			                   "] Mantida !"
			 let l_ctrl = 1
			 exit for
                      end if
                    end for

                    if l_ctrl = 0 then
                       #let l_mensagem  = "Empresa  [",a_empresas[l_aux].ciaempcod,
			#                 "] Incluida !"
                       #let l_mensagem2 =
   		       #'Inclusao de Empresa do Veiculo. Codigo : ', param.socvclcod
                       #let l_stt = ctc34m01_grava_hist(param.socvclcod
                       #                                ,l_mensagem
                       #                                ,today
                       #                                ,l_mensagem2,"I")
                    end if

                    let l_aux = l_aux + 1
                else
                    #se é nulo mas não chegou no fim do array - continua
                    # pois em ctc00m03 se tentar inserir com f1, mas
                    # não informar ciaempcod e nem excluir a linha
                    let l_aux = l_aux + 1
                end if
          end while
          
            
       else
          error l_mensagem
       end if
    else
       error l_mensagem
    end if

    return                  
                  
 end function        
 
 
#Fornax-Qauntum  
function ctc18m00_carga_sap(lr_param)  
  define lr_param record 
           lcvcod        like datklcvfav.lcvcod    
          ,aviestcod     like datklcvfav.aviestcod 
  end record 
  
  define  lr_cgccpfnum    like datklcvfav.cgccpfnum   
  define  lr_cgccpfdig    like datklcvfav.cgccpfdig
  define  lr_bcocod       like datklcvfav.bcocod   
  define  lr_bcoagndig    like datklcvfav.bcoagndig
  define  lr_bcoctadig    like datklcvfav.bcoctadig             
  define  lr_cgcord       like datklcvfav.cgcord   
  define  lr_mncinscod    like datklcvfav.mncinscod
  define  lr_bcoagnnum    like datklcvfav.bcoagnnum
  define  lr_bcoctanum    like datklcvfav.bcoctanum
  define  lr_empcod       char(4)
  define  lr_ciaempcod    like datrlcdljaemprlc.ciaempcod

  initialize gr_034_cab_fcd_v1.*                                                                               
            ,gr_034_pesdad_v1.*                                                                                
            ,gr_034_pes_pf_v1.*                                                                                
            ,gr_034_pes_pj_v1.*                                                                                
            ,gr_034_end_v1.*                                                                                   
            ,gr_034_ctt_v1.*                                                                                   
            ,gr_034_doc_pj_v1.*                                                                                
            ,gr_034_doc_pf_v1.*                                                                                
            ,gr_034_fin_v1.*                                                                                   
            ,gr_034_req_v1.*                                                                                   
            ,gr_034_res_v1.*                                                                                   
            ,gr_034_cta_ctr_v1.*                                                                               
            ,gr_034_cpom_v1.* to null                                                                          
                                                                                                             
  #Entrada 
  display "Funcao Carga SAP"
  
  #Busca dados do favorecido para envio  
    select cgccpfnum   ,cgcord                      
          ,cgccpfdig   ,mncinscod                   
          ,bcocod      ,bcoagnnum                   
          ,bcoagndig   ,bcoctanum                   
          ,bcoctadig
      into lr_cgccpfnum   ,lr_cgcord      
          ,lr_cgccpfdig   ,lr_mncinscod   
          ,lr_bcocod      ,lr_bcoagnnum   
          ,lr_bcoagndig   ,lr_bcoctanum   
          ,lr_bcoctadig                
     from datklcvfav                   
    where lcvcod    = lr_param.lcvcod     
      and aviestcod = lr_param.aviestcod 
  
  
  # Dados de envio para a API da 034                                                                                                 
  let gr_aci_req_head.id_integracao   = "034PTSOC"                                                                
  let gr_aci_req_head.usuario         = g_issk.funmat  #Nao requerido                                        
                                                                                                             
  #Dados fixos de envio ao SAP                                                                                      
       let gr_034_cab_fcd_v1.tipo_pessoa   = "PJ"   #Tipo Pessoa                                            
       let gr_034_cab_fcd_v1.tip_pcr_neg   = "0001" #Tipo Parceiro de Negócios                              
       let gr_034_cab_fcd_v1.origem_dados  = "Z011" #Origem   
       let gr_034_cpom_v1.valido           = "N" 
       let gr_034_cta_ctr_v1.cat_ct_ctr    = "PR"  
       let gr_034_cta_ctr_v1.gr_prev_tes   = "PG"  
       let gr_034_cta_ctr_v1.visao_cta_ext = "E"                                                 
                                                                                                             
  #Dados Pessoa                                                                                              
       let gr_034_pesdad_v1.nome_parceiro = m_ctc18m00.aviestnom #Nome Parceiro                           
       let gr_034_ctt_v1.telefone         = m_ctc18m00.teltxt    #Telefone     
       let gr_034_pes_pj_v1.nome_fantasia = lr_cgccpfnum  using '&&&&&&&&', '/',lr_cgcord     using '&&&&', '-',         
                                            lr_cgccpfdig  using '&&'                
       
       let gr_034_pes_pj_v1.compl_nom_fant = m_ctc18m00.lcvextcod
                           
                                                                                                             
  #Dados Endereco                                                                                            
       let gr_034_end_v1.logradouro        = m_ctc18m00.endlgd                                        #Logradouro                                    
       let gr_034_end_v1.codigo_postal     = m_ctc18m00.endcep, "-",m_ctc18m00.endcepcmp using "&&&"  #Codigo Postal   (CEP)                         
       let gr_034_end_v1.bairro            = m_ctc18m00.endbrr                                       #Bairro                                        
       let gr_034_end_v1.cidade            = m_ctc18m00.endcid                                       #Cidade                                        
       let gr_034_end_v1.estado            = m_ctc18m00.endufd                                       #Estado (UF)                                   
                                               
  #Documento Pessoa Juridica                                                                                         
       let gr_034_doc_pj_v1.numero_cnpj       = lr_cgccpfnum using '&&&&&&&&'  #Numero CNPJ                                   
       let gr_034_doc_pj_v1.ordem_cnpj        = lr_cgcord    using '&&&&'      #Ordem CNPJ                                    
       let gr_034_doc_pj_v1.digito_cnpj       = lr_cgccpfdig using '&&'        #Digito CNPJ                                   
       let gr_034_doc_pj_v1.ins_municipal     = lr_mncinscod  #Inscricao Municipal                           
                                                                                                                    
  #Financeiro                                                                                                        
       let gr_034_fin_v1.codigo_banco     = lr_bcocod    using '<&&&'             #Codigo Banco               
       let gr_034_fin_v1.agencia          = lr_bcoagnnum using '<<&&&'            #Codigo Agencia             
       let gr_034_fin_v1.digito_agencia   = lr_bcoagndig using '&'                #Digito Agencia                  
       let gr_034_fin_v1.conta            = lr_bcoctanum using '<<<<<<<<<&&&&&'   #Numero da Conta Corrente        
       let gr_034_fin_v1.digito_conta     = lr_bcoctadig using '<&'               #Digito da Conta Corrente        
                                                                                                                          
  #Requisitante                                                                                                           
       let gr_034_req_v1.tipo_usuario     = g_issk.usrtip     #Tipo Usuario                                               
       let gr_034_req_v1.emp_matricula    = g_issk.empcod     #Codigo Empresa Matricula                                   
       let gr_034_req_v1.mat_responsavel  = g_issk.funmat     #Matricula Responsavel 

  whenever error continue                           
   declare c_opgitm_sel02 cursor with hold for     
   select ciaempcod    
     from datrlcdljaemprlc
    where aviestcod = lr_param.aviestcod                       
      and lcvcod    = lr_param.lcvcod                       
  whenever error stop         
  foreach c_opgitm_sel02 into lr_ciaempcod
     
     let lr_empcod = lr_ciaempcod using "&&&"                                                                  
     let gr_034_cab_fcd_v1.empresa       =  lr_empcod  
     
     display ""
     display "gr_034_cab_fcd_v1.tipo_pessoa     ",gr_034_cab_fcd_v1.tipo_pessoa   
     display "gr_034_cab_fcd_v1.tip_pcr_neg     ",gr_034_cab_fcd_v1.tip_pcr_neg   
     display "gr_034_cab_fcd_v1.origem_dados    ",gr_034_cab_fcd_v1.origem_dados  
     display "gr_034_cab_fcd_v1.empresa         ",gr_034_cab_fcd_v1.empresa       
     display "gr_034_pesdad_v1.nome_parceiro    ",gr_034_pesdad_v1.nome_parceiro  
     display "gr_034_pesdad_v1.sbn_parceiro     ",gr_034_pesdad_v1.sbn_parceiro   
     display "gr_034_pes_pf_v1.sexo             ",gr_034_pes_pf_v1.sexo           
     display "gr_034_pes_pf_v1.estado_civil     ",gr_034_pes_pf_v1.estado_civil   
     display "gr_034_pes_pf_v1.data_nascimento  ",gr_034_pes_pf_v1.data_nascimento
     display "gr_034_pes_pj_v1.nome_fantasia    ",gr_034_pes_pj_v1.nome_fantasia  
     display "gr_034_pes_pj_v1.data_fundacao    ",gr_034_pes_pj_v1.data_fundacao  
     display "gr_034_end_v1.logradouro          ",gr_034_end_v1.logradouro        
     display "gr_034_end_v1.numero              ",gr_034_end_v1.numero            
     display "gr_034_end_v1.comp_endereco       ",gr_034_end_v1.comp_endereco     
     display "gr_034_end_v1.codigo_postal       ",gr_034_end_v1.codigo_postal     
     display "gr_034_end_v1.bairro              ",gr_034_end_v1.bairro            
     display "gr_034_end_v1.cidade              ",gr_034_end_v1.cidade            
     display "gr_034_end_v1.estado              ",gr_034_end_v1.estado            
     display "gr_034_end_v1.caixa               ",gr_034_end_v1.caixa             
     display "gr_034_ctt_v1.telefone            ",gr_034_ctt_v1.telefone          
     display "gr_034_ctt_v1.celular             ",gr_034_ctt_v1.celular           
     display "gr_034_ctt_v1.fax                 ",gr_034_ctt_v1.fax               
     display "gr_034_ctt_v1.email               ",gr_034_ctt_v1.email             
     
     display ""                                                                             
     display "gr_034_doc_pj_v1.numero_cnpj    ",gr_034_doc_pj_v1.numero_cnpj      
     display "gr_034_doc_pj_v1.ordem_cnpj     ",gr_034_doc_pj_v1.ordem_cnpj       
     display "gr_034_doc_pj_v1.digito_cnpj    ",gr_034_doc_pj_v1.digito_cnpj      
     display "gr_034_doc_pj_v1.set_industrial ",gr_034_doc_pj_v1.set_industrial   
     display "gr_034_doc_pj_v1.ins_municipal  ",gr_034_doc_pj_v1.ins_municipal    
     display "gr_034_doc_pf_v1.numero_cpf     ",gr_034_doc_pf_v1.numero_cpf       
     display "gr_034_doc_pf_v1.digito_cpf     ",gr_034_doc_pf_v1.digito_cpf       
     display "gr_034_doc_pf_v1.identidade     ",gr_034_doc_pf_v1.identidade       
     display "gr_034_fin_v1.codigo_banco      ",gr_034_fin_v1.codigo_banco        
     display "gr_034_fin_v1.digito_banco      ",gr_034_fin_v1.digito_banco        
     display "gr_034_fin_v1.agencia           ",gr_034_fin_v1.agencia             
     display "gr_034_fin_v1.digito_agencia    ",gr_034_fin_v1.digito_agencia      
     display "gr_034_fin_v1.conta             ",gr_034_fin_v1.conta               
     display "gr_034_fin_v1.digito_conta      ",gr_034_fin_v1.digito_conta        
     display "gr_034_req_v1.tipo_usuario      ",gr_034_req_v1.tipo_usuario        
     display "gr_034_req_v1.emp_matricula     ",gr_034_req_v1.emp_matricula       
     display "gr_034_req_v1.mat_responsavel   ",gr_034_req_v1.mat_responsavel     
      
     if  lr_ciaempcod <> 35 and lr_ciaempcod <> 84 then 
        call ffpgc373_cadfrc_pj()                                                                      
     end if                                       
                                                                                                                                            
     #Retorno da global header                                                                                                            
     display "gr_aci_res_head.codigo_retorno ",gr_aci_res_head.codigo_retorno  # Codigo de retorno da integracao.                     
     display "gr_aci_res_head.mensagem       ",gr_aci_res_head.mensagem        # Mensagem de retorno da integracao.                   
     display "gr_aci_res_head.tipo_erro      ",gr_aci_res_head.tipo_erro       # Tipo de erro, caso ocorra.                           
     display "gr_aci_res_head.track_number   ",gr_aci_res_head.track_number    # Numero de rastreio para integr assincronas.          
                                                                                                                                          
     if gr_aci_res_head.codigo_retorno <> 1 then                                                                                          
         display "Erro na ffpgc373. ", "Tipo: ", gr_aci_res_head.tipo_erro, " Msg: ", gr_aci_res_head.mensagem                         
     end if                                                                                                                               
                                                                                                                                          
     #Retorno                                                                                                                              
     #Response                                                                                                                             
     display "gr_034_res_v1.origem_porto   : ",gr_034_res_v1.origem_porto   #Origem Porto                                             
     display "gr_034_res_v1.empresa        : ",gr_034_res_v1.empresa        #Empresa                                                  
     display "gr_034_res_v1.cod_fornecedor : ",gr_034_res_v1.cod_fornecedor #Codigo Fornecedor                                        
     display "gr_034_res_v1.tipo_pessoa    : ",gr_034_res_v1.tipo_pessoa    #Tipo Pessoa                                              
     display "gr_034_res_v1.cpf_cnpj       : ",gr_034_res_v1.cpf_cnpj       #Nº Documento CPF/CNPJ                                    
     display "gr_034_res_v1.data_geracao   : ",gr_034_res_v1.data_geracao   #Data da Geracao                                          
 end foreach                                            

end function                                                              