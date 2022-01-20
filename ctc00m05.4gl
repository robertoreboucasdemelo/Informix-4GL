###############################################################################
# Nome do Modulo: CTC00M05                                           Marcelo  #
#                                                                    Gilberto #
# Manutencao nos dados bancarios dos prestadores                     Jan/1997 #
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica CT        Alteracao                                #
# ---------- ------------- --------- -----------------------------------------#
# 30/07/2008 Andre Pinto   80714988  Retirada da verificação do bcoagndig     #
# 14/09/2010 Robert Lima  PSI00009EV Alterada a chamada de tela de cpf        #
#                                    ja cadastrado.                           #
###############################################################################

database porto
globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc00m05(d_ctc00m05)
#-----------------------------------------------------------

 define d_ctc00m05  record
    operacao        char(01),
    pstcoddig       like dpaksocor.pstcoddig,
    pestipprs       like dpaksocor.pestip,
    cgccpfnumprs    like dpaksocor.cgccpfnum,
    nomrazsoc       like dpaksocor.nomrazsoc,
    socpgtopccod    like dpaksocorfav.socpgtopccod,
    socpgtopcdes    char(10),
    socfavnom       like dpaksocorfav.socfavnom,
    pestip          like dpaksocorfav.pestip,
    cgccpfnum       like dpaksocorfav.cgccpfnum,
    cgcord          like dpaksocorfav.cgcord,
    cgccpfdig       like dpaksocorfav.cgccpfdig,
    nscdat          like dpaksocorfav.nscdat,
    sexcod          like dpaksocorfav.sexcod,
    bcoctatip       like dpaksocorfav.bcoctatip,
    bcocod          like dpaksocorfav.bcocod,
    bcoagnnum       like dpaksocorfav.bcoagnnum,
    bcoagndig       like dpaksocorfav.bcoagndig,
    bcoctanum       like dpaksocorfav.bcoctanum,
    bcoctadig       like dpaksocorfav.bcoctadig
 end record

 define ws          record
    bcoagnnum       like gcdkbancoage.bcoagnnum,
    bcoagndig       like gcdkbancoage.bcoagndig,
    bconom          like gcdkbanco.bconom      ,
    bcoagnnom       like gcdkbancoage.bcoagnnom,
    cgccpfdig       like dpaksocorfav.cgccpfdig,
    bcoctatipdes    char(10),
    fimok           char(01),
    confirma        char(01)
 end record


 open window ctc00m05 at 10,22 with form "ctc00m05"
                         attribute (border, form line 1)

 let int_flag  =  false
 let ws.fimok  = "n"
 initialize ws.*  to null

 if d_ctc00m05.operacao  =  "m"    then
    if d_ctc00m05.socpgtopccod  =  1   or     #-> Dep.Conta
       d_ctc00m05.socpgtopccod  =  3   then   #-> Boleto Bancario
       select bconom into ws.bconom
         from gcdkbanco
        where gcdkbanco.bcocod = d_ctc00m05.bcocod

       if d_ctc00m05.bcoagnnum  is not null   then
          let ws.bcoagnnum = d_ctc00m05.bcoagnnum

          select bcoagnnom
            into ws.bcoagnnom
            from gcdkbancoage
           where gcdkbancoage.bcocod    = d_ctc00m05.bcocod      and
                 gcdkbancoage.bcoagnnum = ws.bcoagnnum
       end if
       case d_ctc00m05.bcoctatip
            when  1
                  let ws.bcoctatipdes = "C.CORRENTE"
            when  2
                  let ws.bcoctatipdes = "POUPANCA"
       end case
       display by name ws.bcoctatipdes
    end if
 end if

 if d_ctc00m05.socpgtopccod  =  2   then   #-> Cheque
    initialize  d_ctc00m05.bcoctatip, ws.bcoctatipdes,
                d_ctc00m05.bcocod   , ws.bconom,
                d_ctc00m05.bcoagnnum, d_ctc00m05.bcoagndig,
                ws.bcoagnnom        , d_ctc00m05.bcoctanum,
                d_ctc00m05.bcoctadig  to null
 end if
 
  if d_ctc00m05.pestip <> 'F' then
     let d_ctc00m05.nscdat = null
     let d_ctc00m05.sexcod = null
  end if  

 display by name d_ctc00m05.nscdat,d_ctc00m05.sexcod,
                 d_ctc00m05.bcoctatip, ws.bcoctatipdes,
                 d_ctc00m05.bcocod   , ws.bconom,
                 d_ctc00m05.bcoagnnum, d_ctc00m05.bcoagndig,
                 ws.bcoagnnom        , d_ctc00m05.bcoctanum,
                 d_ctc00m05.bcoctadig

 display by name d_ctc00m05.socpgtopccod
 display by name d_ctc00m05.socpgtopcdes
 display by name ws.bconom
 display by name ws.bcoagnnom

    input by name d_ctc00m05.socfavnom,
                  d_ctc00m05.pestip,
                  d_ctc00m05.cgccpfnum,
                  d_ctc00m05.cgcord,
                  d_ctc00m05.cgccpfdig,
                  d_ctc00m05.nscdat,
                  d_ctc00m05.sexcod, 
                  d_ctc00m05.bcoctatip,
                  d_ctc00m05.bcocod   ,
                  d_ctc00m05.bcoagnnum,
                  d_ctc00m05.bcoagndig,
                  d_ctc00m05.bcoctanum,
                  d_ctc00m05.bcoctadig    without defaults
 
 
 
    before field socfavnom
       display by name d_ctc00m05.socfavnom attribute (reverse)

    after  field socfavnom
       display by name d_ctc00m05.socfavnom

         if d_ctc00m05.socfavnom   is null    or
            d_ctc00m05.socfavnom   =  "  "    then
            error " Nome do favorecido deve ser informado!"
            next field socfavnom
         end if

         if d_ctc00m05.socfavnom  <>  d_ctc00m05.nomrazsoc    then
            if g_issk.acsnivcod     <  8     and
               d_ctc00m05.operacao  =  "i"   then
               error " Nivel de acesso nao permite o cadastramento!"
               call cts08g01("A", "N", "",
                             "NOME DO FAVORECIDO DIFERENTE",
                             "DA RAZAO SOCIAL DO PRESTADOR!", "")
                    returning ws.confirma
               next field socfavnom
            else
               call cts08g01("A", "N", "",
                             "NOME DO FAVORECIDO DIFERENTE",
                             "DA RAZAO SOCIAL DO PRESTADOR!", "")
                    returning ws.confirma
            end if
         end if

      before field pestip
         display by name d_ctc00m05.pestip   attribute(reverse)

      after  field pestip
         display by name d_ctc00m05.pestip

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field  socfavnom
         end if

         if d_ctc00m05.pestip   is null   then
            error " Tipo de pessoa deve ser informado!"
            next field pestip
         end if

         if d_ctc00m05.pestip  <>  "F"   and
            d_ctc00m05.pestip  <>  "J"   then
            error " Tipo de pessoa invalido!"
            next field pestip
         end if

         if d_ctc00m05.pestip  =  "F"   then
            initialize d_ctc00m05.cgcord  to null
            display by name d_ctc00m05.cgcord
         end if

      before field cgccpfnum
         display by name d_ctc00m05.cgccpfnum   attribute(reverse)

      after  field cgccpfnum
         display by name d_ctc00m05.cgccpfnum

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field pestip
         end if

         if d_ctc00m05.cgccpfnum   is null   or
            d_ctc00m05.cgccpfnum   =  0      then
            error " Numero do Cgc/Cpf deve ser informado!"
            next field cgccpfnum
         end if

         if d_ctc00m05.pestip     <>  d_ctc00m05.pestipprs      or
            d_ctc00m05.cgccpfnum  <>  d_ctc00m05.cgccpfnumprs   then
            if g_issk.acsnivcod     <   8    and
               d_ctc00m05.operacao  =  "i"   then
               error " Nivel de acesso nao permite o cadastramento!"
               call cts08g01("A", "N", "",
                             "CGC/CPF DO FAVORECIDO DIFERENTE",
                             "DO CGC/CPF DO PRESTADOR!", "")
                    returning ws.confirma
               next field cgccpfnum
            else
               call cts08g01("A", "N", "",
                             "CGC/CPF DO FAVORECIDO DIFERENTE",
                             "DO CGC/CPF DO PRESTADOR!", "")
                    returning ws.confirma
            end if
         end if

         if d_ctc00m05.pestip  =  "F"   then
            next field cgccpfdig
         end if

      before field cgcord
         display by name d_ctc00m05.cgcord   attribute(reverse)

      after  field cgcord
         display by name d_ctc00m05.cgcord

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field cgccpfnum
         end if

         if d_ctc00m05.cgcord   is null   or
            d_ctc00m05.cgcord   =  0      then
            error " Filial do Cgc/Cpf deve ser informada!"
            next field cgcord
         end if

      before field cgccpfdig
         display by name d_ctc00m05.cgccpfdig  attribute(reverse)

      after  field cgccpfdig
         display by name d_ctc00m05.cgccpfdig

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            if d_ctc00m05.pestip  =  "J"  then
               next field cgcord
            else
               next field cgccpfnum
            end if
         end if

         if d_ctc00m05.cgccpfdig   is null   then
            error " Digito do Cgc/Cpf deve ser informado!"
            next field cgccpfdig
         end if

         if d_ctc00m05.pestip  =  "J"    then
            call F_FUNDIGIT_DIGITOCGC(d_ctc00m05.cgccpfnum, d_ctc00m05.cgcord)
                 returning ws.cgccpfdig
         else
            call F_FUNDIGIT_DIGITOCPF(d_ctc00m05.cgccpfnum)
                 returning ws.cgccpfdig
         end if

         if ws.cgccpfdig         is null           or
            d_ctc00m05.cgccpfdig <> ws.cgccpfdig   then
            error " Digito Cgc/Cpf incorreto!"
            next field cgccpfnum
         end if

         #------------------------------------------------------------
         # VERIFICA SE CGC/CPF DO FAVORECIDO JA' CADASTRADO
         #------------------------------------------------------------
         call ctc00m06_favorecido(2, d_ctc00m05.pestip, d_ctc00m05.pstcoddig,
                                  d_ctc00m05.cgccpfnum)

         if d_ctc00m05.socpgtopccod  =  2 and 
            d_ctc00m05.pestip  <>  "F"   then   #-> Cheque a nao for pessoa fisica
            exit input
         end if
         
    before field nscdat
       if d_ctc00m05.pestip  <>  "F"   then
          next field bcoctatip
       else
          display by name d_ctc00m05.nscdat attribute (reverse)
       end if 
                
    after field nscdat
          display by name d_ctc00m05.nscdat 
          
          if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cgccpfdig
         end if
          
          if d_ctc00m05.nscdat  is null   then
            error " Data de nascimento deve ser informada!"
            next field nscdat
         end if
     
    before field sexcod
       if d_ctc00m05.pestip  <>  "F"   then
            next field bcoctatip
       else
          display by name d_ctc00m05.sexcod attribute (reverse)
       end if 
                
    after field sexcod
          display by name d_ctc00m05.sexcod
          
          if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field nscdat
         end if
    
         if d_ctc00m05.sexcod  is null   then
            error " Sexo deve ser informado!"
            next field sexcod
         end if
         
         if d_ctc00m05.socpgtopccod  =  2   then   #-> Cheque
            exit input
         end if

    before field bcoctatip
       display by name d_ctc00m05.bcoctatip attribute (reverse)

    after  field bcoctatip
       display by name d_ctc00m05.bcoctatip

         if d_ctc00m05.pestip  <>  "F" then
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field cgccpfdig
            end if
         else
            if fgl_lastkey() = fgl_keyval("up")    or      
               fgl_lastkey() = fgl_keyval("left")  then    
               next field sexcod                        
            end if  
         end if  

         if d_ctc00m05.bcoctatip  is null   then
            error " Tipo de conta deve ser informado!"
            next field bcoctatip
         end if

         case d_ctc00m05.bcoctatip
              when  1
                    let ws.bcoctatipdes = "C.CORRENTE"
              when  2
                    let ws.bcoctatipdes = "POUPANCA"
              otherwise
                    error " Tipo Conta: 1-Conta Corrente, 2-Poupanca!"
                    next field bcoctatip
         end case
         display by name ws.bcoctatipdes

    before field bcocod
       display by name d_ctc00m05.bcocod attribute (reverse)

    after  field bcocod
       display by name d_ctc00m05.bcocod

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field bcoctatip
       end if

       if d_ctc00m05.bcocod is null     or
          d_ctc00m05.bcocod =  " "      or
          d_ctc00m05.bcocod =  "0"      then
          error " Codigo do banco deve ser informado!"
          next field bcocod
       else
          select bconom into ws.bconom
            from gcdkbanco
           where gcdkbanco.bcocod = d_ctc00m05.bcocod

          if sqlca.sqlcode = notfound  then
             error " Banco nao cadastrado!"
             next field bcocod
          else
             display by name ws.bconom
          end if
       end if

    before field bcoagnnum
       display by name d_ctc00m05.bcoagnnum attribute (reverse)

    after  field bcoagnnum
       display by name d_ctc00m05.bcoagnnum

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field bcocod
         end if

       if d_ctc00m05.bcoagnnum is null   or
          d_ctc00m05.bcoagnnum =  " "    or
          d_ctc00m05.bcoagnnum =  0      then
          error " Numero da Agencia deve ser informado!"
          next field bcoagnnum
       end if

    before field bcoagndig
       display by name d_ctc00m05.bcoagndig attribute (reverse)

    after  field bcoagndig
       display by name d_ctc00m05.bcoagndig

       # -> Trecho de codigo inibido a pedido da PortoSocorro
       #	no chamado numero: 80714988.
       
       #  if fgl_lastkey() = fgl_keyval ("up")     or
       #     fgl_lastkey() = fgl_keyval ("left")   then
       #     next field  bcoagnnum
       #  end if
       #
       #if d_ctc00m05.bcocod  <>  424   and    #-> Noroeste
       #   d_ctc00m05.bcocod  <>  320   and    #-> Bicbanco
       #   d_ctc00m05.bcocod  <>  399   and    #-> Bamerindus
       #   d_ctc00m05.bcocod  <>  409   and    #-> Unibanco
       #   d_ctc00m05.bcocod  <>  231   and    #-> Boa Vista
       #   d_ctc00m05.bcocod  <>  347   and    #-> Sudameris
       #   d_ctc00m05.bcocod  <>  8     and    #-> Meridional
       #   d_ctc00m05.bcocod  <>  33    and    #-> Banespa
       #   d_ctc00m05.bcocod  <>  388   and    #-> B.M.D.
       #   d_ctc00m05.bcocod  <>  21    and    #-> Banco do Espirito Santo
       #   d_ctc00m05.bcocod  <>  230   and    #-> Bandeirantes
       #   d_ctc00m05.bcocod  <>  31    and    #-> Banco do Estado de Goias
       #   d_ctc00m05.bcocod  <>  479   and    #-> Banco de Boston
       #   d_ctc00m05.bcocod  <>  745   then   #-> Citibank
       #   if g_issk.acsnivcod <  8            and
       #      d_ctc00m05.bcoagndig   is null   then
       #      error " Digito da agencia deve ser informado!"
       #      next field bcoagndig
       #   end if
       #end if
       #
       #let ws.bcoagnnum = d_ctc00m05.bcoagnnum
       #
       #select bcoagndig, bcoagnnom
       #  into ws.bcoagndig, ws.bcoagnnom
       #  from gcdkbancoage
       # where gcdkbancoage.bcocod    = d_ctc00m05.bcocod      and
       #       gcdkbancoage.bcoagnnum = ws.bcoagnnum
       #
       #if sqlca.sqlcode <> notfound  then
       #   display by name ws.bcoagnnom
       #
       #   if d_ctc00m05.bcoagndig <> ws.bcoagndig  then
       #      error " Digito da agencia incorreto!"
       #      next field bcoagndig
       #   end if
       #end if

    before field bcoctanum
       display by name d_ctc00m05.bcoctanum attribute (reverse)

    after  field bcoctanum
       display by name d_ctc00m05.bcoctanum

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field bcoagndig
         end if

       if d_ctc00m05.bcoctanum is null  or
          d_ctc00m05.bcoctanum =  0     then
          error " Numero da conta corrente deve ser informado!"
          next field bcoctanum
       end if

    before field bcoctadig
       display by name d_ctc00m05.bcoctadig attribute (reverse)

    after  field bcoctadig
       display by name d_ctc00m05.bcoctadig

    on key (interrupt)
       exit input

 end input

 if not int_flag   then
    let ws.fimok = "s"
 end if

 let int_flag = false
 close window ctc00m05

 return d_ctc00m05.socpgtopccod, d_ctc00m05.socfavnom,
        d_ctc00m05.pestip      , d_ctc00m05.cgccpfnum,
        d_ctc00m05.cgcord      , d_ctc00m05.cgccpfdig,
        d_ctc00m05.bcoctatip   , d_ctc00m05.bcocod,
        d_ctc00m05.bcoagnnum   , d_ctc00m05.bcoagndig,
        d_ctc00m05.bcoctanum   , d_ctc00m05.bcoctadig,
        d_ctc00m05.nscdat      , d_ctc00m05.sexcod,
        ws.fimok

end function  #  ctc00m05
