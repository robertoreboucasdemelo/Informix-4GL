###############################################################################
# Nome do Modulo: CTC18M04                                           Wagner   #
#                                                                             #
# Manutencao nos dados favorecido locadoras/lojas                    jun/2000 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 03/07/2001  PSI 13448-1  Wagner       Alterar digito agencia/conta para     #
#                                       aceitar nulo.                         #
#-----------------------------------------------------------------------------#
# 06/08/2008  PSI226300   Diomar, Meta Incluido gravacao do historico         #
# 25/05/2009  PSI 198404  Fabio Costa  Inscr. municipal no cad. favorecido    #
# 01/07/2009  PSI 198404  Fabio Costa  Acerto gravar CGC quando houver update #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/ffpgc368.4gl"  #Fornax-Quantum    
globals "/homedsa/projetos/geral/globals/ffpgc361.4gl" #Fornax-Quantum    

#-----------------------------------------------------------
function ctc18m04(param)
#-----------------------------------------------------------

  define param       record
     lcvcod          like datkavislocal.lcvcod   ,
     aviestcod       like datkavislocal.aviestcod
  end record
 
  define d_ctc18m04  record
     lcvcod          like datkavislocal.lcvcod,
     aviestcod       like datkavislocal.aviestcod,
     pgtopccod       like datklcvfav.pgtopccod,
     favnom          like datklcvfav.favnom,
     cgccpfnum       like datklcvfav.cgccpfnum,
     cgcord          like datklcvfav.cgcord,
     cgccpfdig       like datklcvfav.cgccpfdig,
     bcoctatip       like datklcvfav.bcoctatip,
     bcocod          like datklcvfav.bcocod,
     bcoagnnum       like datklcvfav.bcoagnnum,
     bcoagndig       like datklcvfav.bcoagndig,
     bcoctanum       like datklcvfav.bcoctanum,
     bcoctadig       like datklcvfav.bcoctadig,
     mncinscod       like datklcvfav.mncinscod,
     lcdnscdat       like datklcvfav.lcdnscdat, 
     lcdsexcod       like datklcvfav.lcdsexcod,
     pestip          like datklcvfav.pestip
  end record
  
  define lr_ctc18m04  record
     lcvcod          like datkavislocal.lcvcod,
     aviestcod       like datkavislocal.aviestcod,
     pgtopccod       like datklcvfav.pgtopccod,
     favnom          like datklcvfav.favnom,
     cgccpfnum       like datklcvfav.cgccpfnum,
     cgcord          like datklcvfav.cgcord,
     cgccpfdig       like datklcvfav.cgccpfdig,
     bcoctatip       like datklcvfav.bcoctatip,
     bcocod          like datklcvfav.bcocod,
     bcoagnnum       like datklcvfav.bcoagnnum,
     bcoagndig       like datklcvfav.bcoagndig,
     bcoctanum       like datklcvfav.bcoctanum,
     bcoctadig       like datklcvfav.bcoctadig,
     mncinscod       like datklcvfav.mncinscod,
     lcdnscdat       like datklcvfav.lcdnscdat, 
     lcdsexcod       like datklcvfav.lcdsexcod
  end record
  
  define ws          record
     pgtopcdes       char(10),
     aviestnom       like datkavislocal.aviestnom,
     bcoagnnum       like gcdkbancoage.bcoagnnum,
     bcoagndig       like gcdkbancoage.bcoagndig,
     bconom          like gcdkbanco.bconom      ,
     bcoagnnom       like gcdkbancoage.bcoagnnom,
     cgccpfdig       like datklcvfav.cgccpfdig,
     bcoctatipdes    char(10),
     confirma        char(01)
  end record
  
  define l_mensagem  char(75)
        ,l_mensagem2 char(75)
        ,l_aux       char(10)
        ,l_stt       smallint 
        ,l_ret       smallint
  
  let l_mensagem  = null
  let l_mensagem2 = null
  let l_aux       = null
  let l_stt       = null
  
  open window ctc18m04 at 10,22 with form "ctc18m04"
                          attribute (border, form line 1)
 
  let int_flag  =  false
  initialize d_ctc18m04.*  to null
  initialize ws.*          to null
 
  select lcvcod   , aviestcod, favnom   , cgccpfnum, cgcord   ,
         cgccpfdig, bcocod   , bcoagnnum, bcoagndig, bcoctatip,
         bcoctanum, bcoctadig, pgtopccod, mncinscod, lcdnscdat, 
         lcdsexcod, pestip
    into d_ctc18m04.lcvcod   , d_ctc18m04.aviestcod, d_ctc18m04.favnom   ,
         d_ctc18m04.cgccpfnum, d_ctc18m04.cgcord   , d_ctc18m04.cgccpfdig,
         d_ctc18m04.bcocod   , d_ctc18m04.bcoagnnum, d_ctc18m04.bcoagndig,
         d_ctc18m04.bcoctatip, d_ctc18m04.bcoctanum, d_ctc18m04.bcoctadig,
         d_ctc18m04.pgtopccod, d_ctc18m04.mncinscod, d_ctc18m04.lcdnscdat, 
         d_ctc18m04.lcdsexcod, d_ctc18m04.pestip
    from datklcvfav
   where lcvcod    = param.lcvcod
     and aviestcod = param.aviestcod

  if d_ctc18m04.pgtopccod  =  1   or     #-> Dep.Conta
     d_ctc18m04.pgtopccod  =  3   then   #-> Boleto Bancario
     select bconom into ws.bconom
       from gcdkbanco
      where gcdkbanco.bcocod = d_ctc18m04.bcocod

     if d_ctc18m04.bcoagnnum  is not null   then
        let ws.bcoagnnum = d_ctc18m04.bcoagnnum

        select bcoagnnom
          into ws.bcoagnnom
          from gcdkbancoage
         where gcdkbancoage.bcocod    = d_ctc18m04.bcocod      and
               gcdkbancoage.bcoagnnum = ws.bcoagnnum
     end if
     case d_ctc18m04.bcoctatip
          when  1
                let ws.bcoctatipdes = "C.CORRENTE"
          when  2
                let ws.bcoctatipdes = "POUPANCA"
     end case
  end if

  if d_ctc18m04.pgtopccod  =  2   then   #-> Cheque
     initialize  d_ctc18m04.bcoctatip, ws.bcoctatipdes,
                 d_ctc18m04.bcocod   , ws.bconom,
                 d_ctc18m04.bcoagnnum, d_ctc18m04.bcoagndig,
                 ws.bcoagnnom        , d_ctc18m04.bcoctanum,
                 d_ctc18m04.bcoctadig  to null
  end if
 
  case d_ctc18m04.pgtopccod
      when  1 let ws.pgtopcdes = "DEP. CONTA"
      when  2 let ws.pgtopcdes = "CHEQUE"
      when  3 let ws.pgtopcdes = "BOL. BANCO"
  end case
 
  let lr_ctc18m04.lcvcod     = d_ctc18m04.lcvcod      
  let lr_ctc18m04.aviestcod  = d_ctc18m04.aviestcod   
  let lr_ctc18m04.pgtopccod  = d_ctc18m04.pgtopccod   
  let lr_ctc18m04.favnom     = d_ctc18m04.favnom      
  let lr_ctc18m04.cgccpfnum  = d_ctc18m04.cgccpfnum   
  let lr_ctc18m04.cgcord     = d_ctc18m04.cgcord      
  let lr_ctc18m04.cgccpfdig  = d_ctc18m04.cgccpfdig   
  let lr_ctc18m04.bcoctatip  = d_ctc18m04.bcoctatip   
  let lr_ctc18m04.bcocod     = d_ctc18m04.bcocod      
  let lr_ctc18m04.bcoagnnum  = d_ctc18m04.bcoagnnum   
  let lr_ctc18m04.bcoagndig  = d_ctc18m04.bcoagndig   
  let lr_ctc18m04.bcoctanum  = d_ctc18m04.bcoctanum   
  let lr_ctc18m04.bcoctadig  = d_ctc18m04.bcoctadig
  let lr_ctc18m04.mncinscod  = d_ctc18m04.mncinscod
  let lr_ctc18m04.lcdnscdat  = d_ctc18m04.lcdnscdat
  let lr_ctc18m04.lcdsexcod  = d_ctc18m04.lcdsexcod
 
  while true

    display by name d_ctc18m04.pgtopccod, ws.pgtopcdes,
                    d_ctc18m04.bcoctatip, ws.bcoctatipdes,
                    d_ctc18m04.bcocod   , ws.bconom,
                    d_ctc18m04.bcoagnnum, d_ctc18m04.bcoagndig,
                    ws.bcoagnnom        , d_ctc18m04.bcoctanum,
                    d_ctc18m04.bcoctadig, d_ctc18m04.mncinscod


    input by name d_ctc18m04.pgtopccod,
                  d_ctc18m04.favnom,
                  d_ctc18m04.cgccpfnum,
                  d_ctc18m04.cgcord,
                  d_ctc18m04.cgccpfdig,
                  d_ctc18m04.lcdnscdat,
                  d_ctc18m04.lcdsexcod,
                  d_ctc18m04.mncinscod,
                  d_ctc18m04.bcoctatip,
                  d_ctc18m04.bcocod   ,
                  d_ctc18m04.bcoagnnum,
                  d_ctc18m04.bcoagndig,
                  d_ctc18m04.bcoctanum,
                  d_ctc18m04.bcoctadig  without defaults

       before field pgtopccod
          display by name d_ctc18m04.pgtopccod attribute (reverse)
          
       after  field pgtopccod
          display by name d_ctc18m04.pgtopccod
          
          case d_ctc18m04.pgtopccod
             when  1
                let ws.pgtopcdes = "DEP. CONTA"
                
             when  2
                let ws.pgtopcdes = "CHEQUE"
                initialize d_ctc18m04.bcoctatip, ws.bcoctatipdes,
                           d_ctc18m04.bcocod   , ws.bconom,
                           d_ctc18m04.bcoagnnum, d_ctc18m04.bcoagndig,
                           ws.bcoagnnom        , d_ctc18m04.bcoctanum,
                           d_ctc18m04.bcoctadig  to null
                            
                display by name d_ctc18m04.pgtopccod, ws.pgtopcdes,
                                d_ctc18m04.bcoctatip, ws.bcoctatipdes,
                                d_ctc18m04.bcocod   , ws.bconom,
                                d_ctc18m04.bcoagnnum, d_ctc18m04.bcoagndig,
                                ws.bcoagnnom        , d_ctc18m04.bcoctanum,
                                d_ctc18m04.bcoctadig
                                
             when  3
                let ws.pgtopcdes = "BOL. BANCO"
                
             otherwise
                error " Opcao Pagto : 1-Dep.Conta 2-Cheque ou 3-Bol.Banco:"
                next field pgtopccod
                
          end case
          
          display by name ws.pgtopcdes

       before field favnom
          if d_ctc18m04.favnom is null then
             select aviestnom
               into ws.aviestnom
               from datkavislocal
              where lcvcod    = param.lcvcod
                and aviestcod = param.aviestcod

              let d_ctc18m04.favnom = ws.aviestnom
          end if
          display by name d_ctc18m04.favnom attribute (reverse)
          
       after  field favnom
          display by name d_ctc18m04.favnom

            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field  pgtopccod
            end if
            
            if d_ctc18m04.favnom   is null    or
               d_ctc18m04.favnom   =  "  "    then
               error " Nome do favorecido deve ser informado!"
               next field favnom
            end if

       before field cgccpfnum
          display by name d_ctc18m04.cgccpfnum   attribute(reverse)

       after  field cgccpfnum
          display by name d_ctc18m04.cgccpfnum

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field  favnom
          end if

          if d_ctc18m04.cgccpfnum   is null   or
             d_ctc18m04.cgccpfnum   =  0      then
             error " Numero do Cgc/Cpf deve ser informado!"
             next field cgccpfnum
          end if

       before field cgcord
          display by name d_ctc18m04.cgcord   attribute(reverse)

       after  field cgcord
          display by name d_ctc18m04.cgcord

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field cgccpfnum
          end if

          if d_ctc18m04.cgcord   is null   or
             d_ctc18m04.cgcord   =  0      then
             error " Filial do Cgc/Cpf deve ser informada!"
             next field cgcord
          end if

       before field cgccpfdig
          display by name d_ctc18m04.cgccpfdig  attribute(reverse)

       after  field cgccpfdig
          display by name d_ctc18m04.cgccpfdig

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field cgcord
          end if

          if d_ctc18m04.cgccpfdig   is null   then
             error " Digito do Cgc/Cpf deve ser informado!"
             next field cgccpfdig
          end if

          call F_FUNDIGIT_DIGITOCGC(d_ctc18m04.cgccpfnum, d_ctc18m04.cgcord)
               returning ws.cgccpfdig

          if ws.cgccpfdig         is null           or
             d_ctc18m04.cgccpfdig <> ws.cgccpfdig   then
             error " Digito Cgc/Cpf incorreto!"
             next field cgccpfnum
          end if

       before field lcdnscdat
          if d_ctc18m04.pestip  <>  "F" or d_ctc18m04.pestip is null or d_ctc18m04.pestip = ' '  then
             next field mncinscod
          else
             display by name d_ctc18m04.lcdnscdat attribute (reverse)           
          end if 
                                  
       after field lcdnscdat
             display by name d_ctc18m04.lcdnscdat 
             
             if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field cgccpfdig
            end if
             
             if d_ctc18m04.lcdnscdat  is null   then
               error " Data de nascimento deve ser informada!"
               next field lcdnscdat
            end if
        
       before field lcdsexcod
          if d_ctc18m04.pestip  <>  "F" or d_ctc18m04.pestip is null or d_ctc18m04.pestip = ' '  then
               next field mncinscod
          else
             display by name d_ctc18m04.lcdsexcod attribute (reverse)
          end if 
                   
       after field lcdsexcod
             display by name d_ctc18m04.lcdsexcod
             
             if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field lcdnscdat
            end if
       
            if d_ctc18m04.lcdsexcod  is null   then
               error " Sexo deve ser informado!"
               next field lcdsexcod
            end if
            
            if d_ctc18m04.pgtopccod  =  2   then   #-> Cheque
               exit input
            end if
         
       before field mncinscod
          display by name d_ctc18m04.mncinscod  attribute(reverse)
          
       after field mncinscod
          display by name d_ctc18m04.mncinscod
          
          if fgl_lastkey() = fgl_keyval ("up")   or
             fgl_lastkey() = fgl_keyval ("left") 
             then
             next field cgccpfdig
          end if
          
          if d_ctc18m04.mncinscod is null or
             d_ctc18m04.mncinscod = ' ' or
             d_ctc18m04.mncinscod = 0
             then
             error " Inscricao municipal deve ser informada!"
             next field mncinscod
          end if
          
       before field bcoctatip
          display by name d_ctc18m04.bcoctatip attribute (reverse)

       after  field bcoctatip
          display by name d_ctc18m04.bcoctatip
          
          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field mncinscod
          end if
          
          if d_ctc18m04.bcoctatip is null and
             d_ctc18m04.pgtopccod != 2   # pagto em cheque nao requer dados bancarios
             then
             error " Tipo de conta deve ser informado: 1-Conta Corrente, 2-Poupanca "
             next field bcoctatip
          end if
          
          if d_ctc18m04.bcoctatip is not null and
             d_ctc18m04.bcoctatip > 2
             then
             error " Tipo de conta: 1-Conta Corrente, 2-Poupanca "
             next field bcoctatip
          else
             case d_ctc18m04.bcoctatip
                  when  1
                        let ws.bcoctatipdes = "C.CORRENTE"
                  when  2
                        let ws.bcoctatipdes = "POUPANCA"
                  otherwise
                        initialize ws.bcoctatipdes to null
             end case
          end if
          
          display by name ws.bcoctatipdes

       before field bcocod
          display by name d_ctc18m04.bcocod attribute (reverse)

       after  field bcocod
          display by name d_ctc18m04.bcocod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field bcoctatip
          end if
          
          if d_ctc18m04.pgtopccod != 2  # pagto em cheque nao requer dados bancarios
             then
             if d_ctc18m04.bcocod is null     or
                d_ctc18m04.bcocod =  " "      or
                d_ctc18m04.bcocod =  "0"      then
                error " Codigo do banco deve ser informado!"
                next field bcocod
             else
                select bconom into ws.bconom
                  from gcdkbanco
                 where gcdkbanco.bcocod = d_ctc18m04.bcocod
   
                if sqlca.sqlcode = notfound  then
                   error " Banco nao cadastrado!"
                   next field bcocod
                else
                   display by name ws.bconom
                end if
             end if
          end if

       before field bcoagnnum
          display by name d_ctc18m04.bcoagnnum attribute (reverse)

       after  field bcoagnnum
          display by name d_ctc18m04.bcoagnnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field bcocod
          end if
          
          if d_ctc18m04.pgtopccod != 2  # pagto em cheque nao requer dados bancarios
             then
             if d_ctc18m04.bcoagnnum is null   or
                d_ctc18m04.bcoagnnum =  " "    or
                d_ctc18m04.bcoagnnum =  0      then
                error " Numero da Agencia deve ser informado!"
                next field bcoagnnum
             end if
          end if
          
       before field bcoagndig
          display by name d_ctc18m04.bcoagndig attribute (reverse)

       after  field bcoagndig
          display by name d_ctc18m04.bcoagndig
          
          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field  bcoagnnum
          end if
          
          if d_ctc18m04.bcocod  <>  424   and    #-> Noroeste
             d_ctc18m04.bcocod  <>  320   and    #-> Bicbanco
             d_ctc18m04.bcocod  <>  399   and    #-> Bamerindus
             d_ctc18m04.bcocod  <>  409   and    #-> Unibanco
             d_ctc18m04.bcocod  <>  231   and    #-> Boa Vista
             d_ctc18m04.bcocod  <>  347   and    #-> Sudameris
             d_ctc18m04.bcocod  <>  8     and    #-> Meridional
             d_ctc18m04.bcocod  <>  33    and    #-> Banespa
             d_ctc18m04.bcocod  <>  388   and    #-> B.M.D.
             d_ctc18m04.bcocod  <>  21    and    #-> Banco do Espirito Santo
             d_ctc18m04.bcocod  <>  230   and    #-> Bandeirantes
             d_ctc18m04.bcocod  <>  31    and    #-> Banco do Estado de Goias
             d_ctc18m04.bcocod  <>  479   and    #-> Banco de Boston
             d_ctc18m04.bcocod  <>  745   then   #-> Citibank
             if d_ctc18m04.bcoagndig   is null   then
               # error " Digito da agencia deve ser informado!"
               # next field bcoagndig
             end if
          end if
          
          if d_ctc18m04.bcoagnnum is not null and
             d_ctc18m04.bcocod    is not null
             then
             select bcoagndig, bcoagnnom
               into ws.bcoagndig, ws.bcoagnnom
               from gcdkbancoage
              where gcdkbancoage.bcocod    = d_ctc18m04.bcocod
                and gcdkbancoage.bcoagnnum = d_ctc18m04.bcoagnnum
                    
             if sqlca.sqlcode <> notfound  then
                display by name ws.bcoagnnom
   
                if d_ctc18m04.bcoagndig <> ws.bcoagndig  then
                   error " ATENCAO: Digito da agencia nao confere!"
                   #  next field bcoagndig
                end if
             end if
          end if

       before field bcoctanum
          display by name d_ctc18m04.bcoctanum attribute (reverse)

       after  field bcoctanum
          display by name d_ctc18m04.bcoctanum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field bcoagndig
          end if
          
          if d_ctc18m04.pgtopccod != 2  # pagto em cheque nao requer dados bancarios
             then
             if d_ctc18m04.bcoctanum is null  or
                d_ctc18m04.bcoctanum =  0     then
                error " Numero da conta corrente deve ser informado!"
                next field bcoctanum
             end if
          end if
          
       before field bcoctadig
          display by name d_ctc18m04.bcoctadig attribute (reverse)

       after  field bcoctadig
          display by name d_ctc18m04.bcoctadig

       on key (interrupt)
             #Fornax-Quantum                                                             
             if d_ctc18m04.pgtopccod is null or d_ctc18m04.pgtopccod = " " then          
                error "Informe os Dados Bancario do Favorecido" sleep 2                  
                let int_flag = false                                                     
                next field pgtopccod                                                     
             end if                                                                      
                                                                                         
             if d_ctc18m04.bcoctadig is null or d_ctc18m04.bcoctadig = " " then          
                 error "Informe os Dados Bancario do Favorecido" sleep 2                 
                 let int_flag = false                                                    
                 next field pgtopccod                                                    
             end if                                                                      
             #Fornax-Quantum                                                             
          exit input

    end input

    if int_flag
       then
       exit while
    else
       call cts08g01("C","S","","DADOS ESTAO CORRETOS ?", "","")
           returning ws.confirma
           
       if ws.confirma = "S"
          then
          
          begin work
          
          select lcvcod
            from datklcvfav
           where lcvcod    = param.lcvcod
             and aviestcod = param.aviestcod
	   

          if sqlca.sqlcode = notfound 
             then
             insert into datklcvfav (lcvcod   , aviestcod,
                                     favnom   , pestip   ,
                                     cgccpfnum, cgcord   ,
                                     cgccpfdig, bcocod   ,
                                     bcoagnnum, bcoagndig,
                                     bcoctatip, bcoctanum,
                                     bcoctadig, pgtopccod,
                                     mncinscod, lcdnscdat,
                                     lcdsexcod )
                             values (param.lcvcod        ,
                                     param.aviestcod     ,
                                     d_ctc18m04.favnom   ,
                                     "J"                 ,
                                     d_ctc18m04.cgccpfnum,
                                     d_ctc18m04.cgcord   ,
                                     d_ctc18m04.cgccpfdig,
                                     d_ctc18m04.bcocod   ,
                                     d_ctc18m04.bcoagnnum,
                                     d_ctc18m04.bcoagndig,
                                     d_ctc18m04.bcoctatip,
                                     d_ctc18m04.bcoctanum,
                                     d_ctc18m04.bcoctadig,
                                     d_ctc18m04.pgtopccod,
                                     d_ctc18m04.mncinscod,
                                     d_ctc18m04.lcdnscdat,
                                     d_ctc18m04.lcdsexcod )

             if sqlca.sqlcode <> 0  then
                error " Erro (", sqlca.sqlcode, ") na inclusao favorecido. AVISE A INFORMATICA!"
                rollback work
                sleep 2
             else
                commit work
                call ctc18m00_carga_sap(param.lcvcod, param.aviestcod) #Fornax-Quantum
                error " Inclusao favorecido efetuada com sucesso!"
                sleep 1
             end if
             
             call ctc00m21(param.aviestcod,param.lcvcod,'J','I','L')
          
	     call ctc00m20('I',param.aviestcod,param.lcvcod) #PSI circular 380
             
             let l_mensagem  = "Cadastro de dados dos favorecidos locadora/loja [",param.lcvcod,"|",param.aviestcod,"] Incluido !"
             let l_mensagem2 = "Inclusao no cadastro de dados favorecido locadoras/lojas. Codigo :",param.lcvcod," - ",param.aviestcod
             let l_aux = param.lcvcod using '<<<<<' ,"|",param.aviestcod using '<<<<'                          
             let l_stt = ctc18m04_grava_hist(l_aux                                                             
                                            ,l_mensagem2                                                        
                                            ,today                                                            
                                            ,l_mensagem,"I")
             exit while
          else
             update datklcvfav set  (favnom   , cgccpfnum, cgcord   ,
                                     cgccpfdig, bcocod   , bcoagnnum,
                                     bcoagndig, bcoctatip, bcoctanum,
                                     bcoctadig, pgtopccod, mncinscod,
                                     lcdnscdat, lcdsexcod )
                                  = (d_ctc18m04.favnom   ,
                                     d_ctc18m04.cgccpfnum,
                                     d_ctc18m04.cgcord   ,
                                     d_ctc18m04.cgccpfdig,
                                     d_ctc18m04.bcocod   ,
                                     d_ctc18m04.bcoagnnum,
                                     d_ctc18m04.bcoagndig,
                                     d_ctc18m04.bcoctatip,
                                     d_ctc18m04.bcoctanum,
                                     d_ctc18m04.bcoctadig,
                                     d_ctc18m04.pgtopccod,
                                     d_ctc18m04.mncinscod,
                                     d_ctc18m04.lcdnscdat,
                                     d_ctc18m04.lcdsexcod  )
             where lcvcod    = param.lcvcod
               and aviestcod = param.aviestcod

             if sqlca.sqlcode <> 0  then
                error " Erro (", sqlca.sqlcode, ") na alteracao favorecido. AVISE A INFORMATICA!"
                rollback work
                sleep 2
             else
                commit work  
                #Fornax-Quantum
                call ctc18m00_carga_sap(param.lcvcod, param.aviestcod)
                call ctc00m02c()    
                #Fornax-Quantum
                
                error " Alteracao favorecido efetuada com sucesso!"
                sleep 1
             end if
             
             call ctc00m21(param.aviestcod,param.lcvcod,'J','A','L')         
             
             call ctc00m20('A',param.aviestcod,param.lcvcod) #PSI circular 380
             
             call ctc18m04_verific_alt(lr_ctc18m04.*,d_ctc18m04.*)
             
             exit while
          end if
            
       end if
    end if

  end while

 close window ctc18m04

 let int_flag = false

end function  ###  ctc18m04

#------------------------------------------------
function ctc18m04_grava_hist(lr_param,l_mensagem,l_opcao)
#------------------------------------------------

   define lr_param record
          codigo     char(10)
         ,titulo     char(100)
         ,data       date
   end record

   define lr_retorno record
                     stt smallint
                    ,msg char(50)
   end record

   define l_mensagem    char(3000)
         ,l_stt         smallint
         ,l_erro        smallint
         ,l_path        char(100)
         ,l_prshstdes2  char(3000)
         ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint
         ,l_opcao      char(1)
 
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
                               ,today
                               ,g_issk.empcod
                               ,g_issk.funmat
                               ,g_issk.usrtip)
          returning lr_retorno.stt
                   ,lr_retorno.msg
                   
       if lr_retorno.stt <> 0 then
          exit for        
       end if           
   end for

   if l_opcao <> "A" then
      if lr_retorno.stt = 0 then
  
         call ctb85g01_mtcorpo_email_html('CTC18M00',
                                          lr_param.data,
                                          current hour to minute,
                                          g_issk.empcod,
                                          g_issk.usrtip,
                                          g_issk.funmat,
                                          lr_param.titulo,     
                                          l_mensagem)
                                returning l_erro

         if l_erro  <> 0 then
            error 'Erro no envio do e-mail' sleep 2
            let l_stt = false
         else
            let l_stt = true
         end if
      else
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
      end if
   end if
   
   return l_stt

end function

-----------------------------------------------------------
function ctc18m04_verific_alt(lr_ctc18m04_ant,lr_ctc18m04)
#-----------------------------------------------------------

  define param       record
     lcvcod          like datkavislocal.lcvcod   ,
     aviestcod       like datkavislocal.aviestcod
  end record
 
  define lr_ctc18m04  record
     lcvcod          like datkavislocal.lcvcod,
     aviestcod       like datkavislocal.aviestcod,
     pgtopccod       like datklcvfav.pgtopccod,
     favnom          like datklcvfav.favnom,
     cgccpfnum       like datklcvfav.cgccpfnum,
     cgcord          like datklcvfav.cgcord,
     cgccpfdig       like datklcvfav.cgccpfdig,
     bcoctatip       like datklcvfav.bcoctatip,
     bcocod          like datklcvfav.bcocod,
     bcoagnnum       like datklcvfav.bcoagnnum,
     bcoagndig       like datklcvfav.bcoagndig,
     bcoctanum       like datklcvfav.bcoctanum,
     bcoctadig       like datklcvfav.bcoctadig,
     mncinscod       like datklcvfav.mncinscod,
     lcdnscdat       like datklcvfav.lcdnscdat, 
     lcdsexcod       like datklcvfav.lcdsexcod     
  end record
 
  define lr_ctc18m04_ant  record
     lcvcod          like datkavislocal.lcvcod,
     aviestcod       like datkavislocal.aviestcod,
     pgtopccod       like datklcvfav.pgtopccod,
     favnom          like datklcvfav.favnom,
     cgccpfnum       like datklcvfav.cgccpfnum,
     cgcord          like datklcvfav.cgcord,
     cgccpfdig       like datklcvfav.cgccpfdig,
     bcoctatip       like datklcvfav.bcoctatip,
     bcocod          like datklcvfav.bcocod,
     bcoagnnum       like datklcvfav.bcoagnnum,
     bcoagndig       like datklcvfav.bcoagndig,
     bcoctanum       like datklcvfav.bcoctanum,
     bcoctadig       like datklcvfav.bcoctadig,
     mncinscod       like datklcvfav.mncinscod,
     lcdnscdat       like datklcvfav.lcdnscdat, 
     lcdsexcod       like datklcvfav.lcdsexcod,
     pestip          like datklcvfav.pestip 
  end record
 
  define l_mensagem  char(3000)
        ,l_mensagem2 char(100)
        ,l_aux       char(10)
        ,l_mensmail  char(3000)
        ,l_flg       smallint
        ,l_erro      smallint
        ,l_stt       smallint
 
  let l_aux       = null        
  let l_mensmail  = null
  let l_aux       = lr_ctc18m04.lcvcod using '<<<<<' ,"|",lr_ctc18m04.aviestcod using '<<<<' 
  let l_mensagem2 = "Alteracao no cadastro de dados favorecido locadoras/lojas. Locadora|loja", l_aux 
  
  if (lr_ctc18m04_ant.pgtopccod is null     and lr_ctc18m04.pgtopccod is not null) or
     (lr_ctc18m04_ant.pgtopccod is not null and lr_ctc18m04.pgtopccod is null)     or
     (lr_ctc18m04_ant.pgtopccod              <> lr_ctc18m04.pgtopccod)             then
     let l_mensagem = "Opcao de Pagamento alterado de [",lr_ctc18m04_ant.pgtopccod clipped,
                    "] para [",lr_ctc18m04.pgtopccod clipped,"]"
     
     let l_mensmail = l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
  
  if (lr_ctc18m04_ant.favnom is null     and lr_ctc18m04.favnom is not null) or
     (lr_ctc18m04_ant.favnom is not null and lr_ctc18m04.favnom is null)     or
     (lr_ctc18m04_ant.favnom              <> lr_ctc18m04.favnom)             then
     let l_mensagem = "Nome do Favorecido alterado de [",lr_ctc18m04_ant.favnom clipped,
                      "] para [",lr_ctc18m04.favnom clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
  
  if (lr_ctc18m04_ant.cgccpfnum is null     and lr_ctc18m04.cgccpfnum is not null) or
     (lr_ctc18m04_ant.cgccpfnum is not null and lr_ctc18m04.cgccpfnum is null)     or
     (lr_ctc18m04_ant.cgccpfnum              <> lr_ctc18m04.cgccpfnum)             then
     let l_mensagem = "CGC/CPF alterado de [",lr_ctc18m04_ant.cgccpfnum clipped,
                      "] para [",lr_ctc18m04.cgccpfnum clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
     
  if (lr_ctc18m04_ant.cgcord is null     and lr_ctc18m04.cgcord is not null) or
     (lr_ctc18m04_ant.cgcord is not null and lr_ctc18m04.cgcord is null)     or
     (lr_ctc18m04_ant.cgcord              <> lr_ctc18m04.cgcord)             then
     let l_mensagem = "Codigo da Filial alterado de [",lr_ctc18m04_ant.cgcord clipped,
                      "] para [",lr_ctc18m04.cgcord clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
      
  if (lr_ctc18m04_ant.cgccpfdig is null     and lr_ctc18m04.cgccpfdig is not null) or
     (lr_ctc18m04_ant.cgccpfdig is not null and lr_ctc18m04.cgccpfdig is null)     or
     (lr_ctc18m04_ant.cgccpfdig              <> lr_ctc18m04.cgccpfdig)             then
     let l_mensagem = "digito GCC/CPF alterado de [",lr_ctc18m04_ant.cgccpfdig clipped,
                      "] para [",lr_ctc18m04.cgccpfdig clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
  
  if (lr_ctc18m04_ant.bcoctatip is null     and lr_ctc18m04.bcoctatip is not null) or
     (lr_ctc18m04_ant.bcoctatip is not null and lr_ctc18m04.bcoctatip is null)     or
     (lr_ctc18m04_ant.bcoctatip              <> lr_ctc18m04.bcoctatip)             then
     let l_mensagem = "tipo de Conta alterado de [",lr_ctc18m04_ant.bcoctatip clipped,
                      "] para [",lr_ctc18m04.bcoctatip clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
         
  if (lr_ctc18m04_ant.bcocod is null     and lr_ctc18m04.bcocod is not null) or
     (lr_ctc18m04_ant.bcocod is not null and lr_ctc18m04.bcocod is null)     or
     (lr_ctc18m04_ant.bcocod              <> lr_ctc18m04.bcocod)             then
     let l_mensagem = "Banco do Favorecido alterado de [",lr_ctc18m04_ant.bcocod clipped,
                      "] para [",lr_ctc18m04.bcocod clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
     
  if (lr_ctc18m04_ant.bcoagnnum is null     and lr_ctc18m04.bcoagnnum is not null) or
     (lr_ctc18m04_ant.bcoagnnum is not null and lr_ctc18m04.bcoagnnum is null)     or
     (lr_ctc18m04_ant.bcoagnnum              <> lr_ctc18m04.bcoagnnum)             then
     let l_mensagem = "Agencia do Favorecido alterado de [",lr_ctc18m04_ant.bcoagnnum clipped,
                      "] para [",lr_ctc18m04.bcoagnnum clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
        
  if (lr_ctc18m04_ant.bcoagndig is null     and lr_ctc18m04.bcoagndig is not null) or
     (lr_ctc18m04_ant.bcoagndig is not null and lr_ctc18m04.bcoagndig is null)     or
     (lr_ctc18m04_ant.bcoagndig              <> lr_ctc18m04.bcoagndig)             then
     let l_mensagem = "Digito da Agencia do Favorecido alterado de [",lr_ctc18m04_ant.bcoagndig clipped,
                      "] para [",lr_ctc18m04.bcoagndig clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
      
  if (lr_ctc18m04_ant.bcoctanum is null     and lr_ctc18m04.bcoctanum is not null) or
     (lr_ctc18m04_ant.bcoctanum is not null and lr_ctc18m04.bcoctanum is null)     or
     (lr_ctc18m04_ant.bcoctanum              <> lr_ctc18m04.bcoctanum)             then
     let l_mensagem = "Numero da Conta do Favorecido alterado de [",lr_ctc18m04_ant.bcoctanum clipped,
                      "] para [",lr_ctc18m04.bcoctanum clipped,"]"
     
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
         
  if (lr_ctc18m04_ant.bcoctatip is null     and lr_ctc18m04.bcoctatip is not null) or
     (lr_ctc18m04_ant.bcoctatip is not null and lr_ctc18m04.bcoctatip is null)     or
     (lr_ctc18m04_ant.bcoctatip              <> lr_ctc18m04.bcoctatip)             then
     let l_mensagem = "Digito da Conta do Favorecido alterado de [",lr_ctc18m04_ant.bcoctatip clipped,
                      "] para [",lr_ctc18m04.bcoctatip clipped,"]"
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
      
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
  
  if (lr_ctc18m04_ant.mncinscod is null and 
      lr_ctc18m04.mncinscod is not null) or
     (lr_ctc18m04_ant.mncinscod is not null and 
      lr_ctc18m04.mncinscod is null) or
     (lr_ctc18m04_ant.mncinscod != lr_ctc18m04.mncinscod)
     then
     let l_mensagem = "Inscricao municipal alterada de [",
                      lr_ctc18m04_ant.mncinscod clipped,
                      "] para [",
                      lr_ctc18m04.mncinscod clipped, "]"
     let l_mensmail = l_mensmail clipped, " ", l_mensagem clipped
     let l_flg = 1
     
     if not ctc18m04_grava_hist(l_aux, l_mensagem2, today, l_mensagem, "A")
        then
        let l_mensagem = "Erro gravacao historico: "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
  
  if (lr_ctc18m04_ant.lcdnscdat is null     and lr_ctc18m04.lcdnscdat is not null) or
     (lr_ctc18m04_ant.lcdnscdat is not null and lr_ctc18m04.lcdnscdat is null)     or
     (lr_ctc18m04_ant.lcdnscdat              <> lr_ctc18m04.lcdnscdat)             then
     let l_mensagem = "Data de Nascimento do Favorecido alterado de [",lr_ctc18m04_ant.lcdnscdat clipped,
                      "] para [",lr_ctc18m04.lcdnscdat clipped,"]"
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
      
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
  
  if (lr_ctc18m04_ant.lcdsexcod is null     and lr_ctc18m04.lcdsexcod is not null) or
     (lr_ctc18m04_ant.lcdsexcod is not null and lr_ctc18m04.lcdsexcod is null)     or
     (lr_ctc18m04_ant.lcdsexcod              <> lr_ctc18m04.lcdsexcod)             then
     let l_mensagem = "Sexo do Favorecido alterado de [",lr_ctc18m04_ant.lcdsexcod clipped,
                      "] para [",lr_ctc18m04.lcdsexcod clipped,"]"
     let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
     let l_flg = 1
      
     if not ctc18m04_grava_hist(l_aux
                               ,l_mensagem2
                               ,today
                               ,l_mensagem,"A") then   
        let l_mensagem = "Erro gravacao Historico "
        let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
     end if
  end if
  
  
  if l_mensmail is not null 
     then
     call ctb85g01_mtcorpo_email_html('CTC18M00',
                                      today,
                                      current hour to minute,
                                      g_issk.empcod,
                                      g_issk.usrtip,
                                      g_issk.funmat,
                                      l_mensagem2,     
                                      l_mensmail)
                            returning l_erro   
                            
     if l_erro  <> 0 then
        error 'Erro no envio do e-mail' sleep 2
        let l_stt = false
     else
        let l_stt = true
    end if
  end if 
  
end function

