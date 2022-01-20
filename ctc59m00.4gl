#####################################################################################
# Nome do Modulo: CTC59M00                                                 Raji     #
#                                                                                   #
# Regulador de servicos por cota                                          Jul/2002  #
#...................................................................................#
#                                                                                   #
#                           * * * Alteracoes * * *                                  #
#                                                                                   #
# Data        Autor Fabrica  Origem          Alteracao                              #
# ----------  -------------- --------------- ---------------------------------------#
# 11/04/2011  Robert Lima    PSI201105440/ev Inclusão das cotas para a cada 1/2 hora#
#-----------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto
define m_prep_sql smallint

define a_ctc59m00 array[100] of record
       atdsrvorg    like datmsrvrgl.atdsrvorg,
       srvrglcod    like datmsrvrgl.srvrglcod,
       srvrgldes    char(15),
       h0cota       decimal(6,0),
       h0utili      decimal(6,0),
       h030cota     decimal(6,0),
       h030utili    decimal(6,0),
       h1cota       decimal(6,0),
       h1utili      decimal(6,0),
       h130cota     decimal(6,0),
       h130utili    decimal(6,0),
       h2cota       decimal(6,0),
       h2utili      decimal(6,0),
       h230cota     decimal(6,0),
       h230utili    decimal(6,0),
       h3cota       decimal(6,0),
       h3utili      decimal(6,0),
       h330cota     decimal(6,0),
       h330utili    decimal(6,0),
       h4cota       decimal(6,0),
       h4utili      decimal(6,0),
       h430cota     decimal(6,0),
       h430utili    decimal(6,0),
       h5cota       decimal(6,0),
       h5utili      decimal(6,0),
       h530cota     decimal(6,0),
       h530utili    decimal(6,0),
       h6cota       decimal(6,0),
       h6utili      decimal(6,0),
       h630cota     decimal(6,0),
       h630utili    decimal(6,0),
       h7cota       decimal(6,0),
       h7utili      decimal(6,0),
       h730cota     decimal(6,0),
       h730utili    decimal(6,0),
       h8cota       decimal(6,0),
       h8utili      decimal(6,0),
       h830cota     decimal(6,0),
       h830utili    decimal(6,0),
       h9cota       decimal(6,0),
       h9utili      decimal(6,0),
       h930cota     decimal(6,0),
       h930utili    decimal(6,0),
       h10cota      decimal(6,0),
       h10utili     decimal(6,0),
       h1030cota    decimal(6,0),
       h1030utili   decimal(6,0),
       h11cota      decimal(6,0),
       h11utili     decimal(6,0),
       h1130cota    decimal(6,0),
       h1130utili   decimal(6,0),
       h12cota      decimal(6,0),
       h12utili     decimal(6,0),
       h1230cota    decimal(6,0),
       h1230utili   decimal(6,0),
       h13cota      decimal(6,0),
       h13utili     decimal(6,0),
       h1330cota    decimal(6,0),
       h1330utili   decimal(6,0),
       h14cota      decimal(6,0),
       h14utili     decimal(6,0),
       h1430cota    decimal(6,0),
       h1430utili   decimal(6,0),
       h15cota      decimal(6,0),
       h15utili     decimal(6,0),
       h1530cota    decimal(6,0),
       h1530utili   decimal(6,0),
       h16cota      decimal(6,0),
       h16utili     decimal(6,0),
       h1630cota    decimal(6,0),
       h1630utili   decimal(6,0),
       h17cota      decimal(6,0),
       h17utili     decimal(6,0),
       h1730cota    decimal(6,0),
       h1730utili   decimal(6,0),
       h18cota      decimal(6,0),
       h18utili     decimal(6,0),
       h1830cota    decimal(6,0),
       h1830utili   decimal(6,0),
       h19cota      decimal(6,0),
       h19utili     decimal(6,0),
       h1930cota    decimal(6,0),
       h1930utili   decimal(6,0),
       h20cota      decimal(6,0),
       h20utili     decimal(6,0),
       h2030cota    decimal(6,0),
       h2030utili   decimal(6,0),
       h21cota      decimal(6,0),
       h21utili     decimal(6,0),
       h2130cota    decimal(6,0),
       h2130utili   decimal(6,0),
       h22cota      decimal(6,0),
       h22utili     decimal(6,0),
       h2230cota    decimal(6,0),
       h2230utili   decimal(6,0),
       h23cota      decimal(6,0),
       h23utili     decimal(6,0),
       h2330cota    decimal(6,0),
       h2330utili   decimal(6,0)
       end record

function ctc59m00_prepare()

   define l_sql char(500)

   let l_sql = " update datmsrvrgl ",
               "    set cotqtd = ? ",
               "  where cidcod = ? ",
               "    and rgldat = ? ",
               "    and atdsrvorg = ? ",
               "    and srvrglcod = ? ",
               "    and rglhor    = ? "

   prepare cctc59m00001 from l_sql

   let l_sql = " insert into datmsrvrgl ",
               " (cidcod, rgldat, atdsrvorg, srvrglcod, cotqtd, utlqtd, ",
	       "  rglhor) values (?,?,?,?,?,0,?) "

   prepare cctc59m00002 from l_sql

   let l_sql = " select cotqtd, utlqtd from datmsrvrgl",
               " where cidcod  = ? ",
               " and rgldat  = ? ",
               " and atdsrvorg  = ? ",
               " and srvrglcod  = ? ",
               " and rglhor  = ? "

   prepare pctc59m00003 from l_sql
   declare cctc59m00003 cursor with hold for pctc59m00003   
   
   let l_sql = " select cpocod ",
                 " from iddkdominio ",
                " where cponom = 'ctc59m00'",
                  " and cpodes = ?"
   prepare pctc59m00004 from l_sql
   declare cctc59m00004 cursor with hold for pctc59m00004   


   let m_prep_sql = true

end function
#--------------------------------------------------------------
 function ctc59m00()
#--------------------------------------------------------------

 define d_ctc59m00   record
    rgldat           like datmsrvrgl.rgldat,
    cidnom           like glakcid.cidnom,
    ufdcod           like glakcid.ufdcod,
    cidcod           like datmsrvrgl.cidcod
 end record

 define l_confirma char(1)
 
 if m_prep_sql = false then
    call ctc59m00_prepare()
 end if

 initialize d_ctc59m00.* to null
 let int_flag  = false
 
 # Veifica se o usuario tem permissao para acessar o cadastro
 open cctc59m00004 using g_issk.funmat
 fetch cctc59m00004
 if sqlca.sqlcode = notfound then ## Usuario nao autorizado
    close cctc59m00004
    call cts08g01("A","N","","ACESSO CONTROLADO PELA COORDENACAO DA",
                             "CENTRAL DE OPERACOES",
                             "")
         returning l_confirma
    return
 end if
 close cctc59m00004
 
 open window ctc59m00 at 06,02 with form "ctc59m00"
      attribute (form line 1,comment line last - 1)

 message " (F17)Abandona"

 while true
    
    display "Utilizacao" to util
    
    input by name d_ctc59m00.rgldat,
                  d_ctc59m00.cidnom,
                  d_ctc59m00.ufdcod  without defaults

       before field rgldat
              display by name d_ctc59m00.rgldat attribute (reverse)

       after  field rgldat
          display by name d_ctc59m00.rgldat

          if d_ctc59m00.rgldat is null  then
             error " A data deve ser informada!"
             next field rgldat
          end if

       before field cidnom
              display by name d_ctc59m00.cidnom attribute (reverse)

       after  field cidnom
          display by name d_ctc59m00.cidnom

          if d_ctc59m00.cidnom is null  then
             error " Cidade deve ser informada!"
             next field cidnom
          end if

       before field ufdcod
          display by name d_ctc59m00.ufdcod attribute (reverse)

       after  field ufdcod
          display by name d_ctc59m00.ufdcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field cidnom
          else
             if d_ctc59m00.ufdcod is null  then
                error " Sigla da unidade da federacao deve ser informada!"
                next field ufdcod
             end if

             #--------------------------------------------------------------
             # Verifica se UF esta cadastrada
             #--------------------------------------------------------------
             select ufdcod
                       from glakest
              where ufdcod = d_ctc59m00.ufdcod

             if sqlca.sqlcode = notfound then
                error " Unidade federativa nao cadastrada!"
                next field ufdcod
             end if

             if d_ctc59m00.ufdcod = d_ctc59m00.cidnom  then
                select ufdnom
                          into d_ctc59m00.cidnom
                  from glakest
                         where ufdcod = d_ctc59m00.cidnom

                if sqlca.sqlcode = 0  then
                   display by name d_ctc59m00.cidnom
                else
                   let d_ctc59m00.cidnom = d_ctc59m00.ufdcod
                end if
             end if

             #--------------------------------------------------------------
             # Verifica se a cidade esta cadastrada
             #--------------------------------------------------------------
             declare c_glakcid cursor for
                select cidcod
                  from glakcid
                         where cidnom = d_ctc59m00.cidnom
                   and ufdcod = d_ctc59m00.ufdcod

             open  c_glakcid
             fetch c_glakcid  into  d_ctc59m00.cidcod

             if sqlca.sqlcode  =  100   then
                call cts06g04(d_ctc59m00.cidnom, d_ctc59m00.ufdcod)
                     returning d_ctc59m00.cidcod ,
                               d_ctc59m00.cidnom ,
                               d_ctc59m00.ufdcod

                if d_ctc59m00.cidnom  is null   then
                   error " Cidade deve ser informada!"
                end if
                next field cidnom
             end if
             close c_glakcid
          end if

          call ctc59m00_cotas(d_ctc59m00.rgldat,
                               d_ctc59m00.cidcod)

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

 end while

 close window ctc59m00
 let int_flag = false

end function  #  ctc59m00


#--------------------------------------------------------------
 function ctc59m00_cotas(param)
#--------------------------------------------------------------

 define param        record
    rgldat        like datmsrvrgl.rgldat,
    cidcod        like datmsrvrgl.cidcod
 end record


 define ws           record
    atdsrvorg        like datmsrvrgl.atdsrvorg,
    srvrglcod        like datmsrvrgl.srvrglcod,
    atlmat           like dammaleastcvn.atlmat,
    atlemp           like dammaleastcvn.atlemp,
    atlusrtip        like dammaleastcvn.atlusrtip,
    confirma         char (01),
    operacao         char (01),
    hora             datetime hour to minute
 end record

 define arr_aux      integer
 define scr_aux      integer
 define x            smallint
 define comando      char(200)
 define l_cotaflg   smallint
 define l_cota_ant  integer
 define l_sqlcode   integer,
        prompt_key  char(1),
        l_retorno   smallint

 initialize a_ctc59m00  to null
 initialize ws.*        to null
 let arr_aux = 1
 let l_sqlcode = 0

 declare c_ctc59m00 cursor for
  select distinct atdsrvorg, srvrglcod from datmsrvrgl
   where cidcod  = param.cidcod
     and rgldat  = param.rgldat

 foreach c_ctc59m00 into a_ctc59m00[arr_aux].atdsrvorg,
                         a_ctc59m00[arr_aux].srvrglcod


    let a_ctc59m00[arr_aux].srvrgldes = "NAO CADASTRADO!"
    if a_ctc59m00[arr_aux].atdsrvorg = 9 then
       select socntzgrpdes
              into a_ctc59m00[arr_aux].srvrgldes
         from datksocntzgrp
        where socntzgrpcod = a_ctc59m00[arr_aux].srvrglcod
    else
       select asitipabvdes
              into a_ctc59m00[arr_aux].srvrgldes
         from datkasitip
        where asitipcod = a_ctc59m00[arr_aux].srvrglcod
    end if

    #####################  CARREGA HORARIOS ##################################

    call ctc59m00_carrega_hor(param.cidcod, param.rgldat,
                              a_ctc59m00[arr_aux].atdsrvorg,
                              a_ctc59m00[arr_aux].srvrglcod)
         returning a_ctc59m00[arr_aux].h0cota    , a_ctc59m00[arr_aux].h0utili   ,
                   a_ctc59m00[arr_aux].h030cota  , a_ctc59m00[arr_aux].h030utili ,
                   a_ctc59m00[arr_aux].h1cota    , a_ctc59m00[arr_aux].h1utili   ,
                   a_ctc59m00[arr_aux].h130cota  , a_ctc59m00[arr_aux].h130utili ,
                   a_ctc59m00[arr_aux].h2cota    , a_ctc59m00[arr_aux].h2utili   ,
                   a_ctc59m00[arr_aux].h230cota  , a_ctc59m00[arr_aux].h230utili ,
                   a_ctc59m00[arr_aux].h3cota    , a_ctc59m00[arr_aux].h3utili   ,
                   a_ctc59m00[arr_aux].h330cota  , a_ctc59m00[arr_aux].h330utili ,
                   a_ctc59m00[arr_aux].h4cota    , a_ctc59m00[arr_aux].h4utili   ,
                   a_ctc59m00[arr_aux].h430cota  , a_ctc59m00[arr_aux].h430utili ,
                   a_ctc59m00[arr_aux].h5cota    , a_ctc59m00[arr_aux].h5utili   ,
                   a_ctc59m00[arr_aux].h530cota  , a_ctc59m00[arr_aux].h530utili ,
                   a_ctc59m00[arr_aux].h6cota    , a_ctc59m00[arr_aux].h6utili   ,
                   a_ctc59m00[arr_aux].h630cota  , a_ctc59m00[arr_aux].h630utili ,
                   a_ctc59m00[arr_aux].h7cota    , a_ctc59m00[arr_aux].h7utili   ,
                   a_ctc59m00[arr_aux].h730cota  , a_ctc59m00[arr_aux].h730utili ,
                   a_ctc59m00[arr_aux].h8cota    , a_ctc59m00[arr_aux].h8utili   ,
                   a_ctc59m00[arr_aux].h830cota  , a_ctc59m00[arr_aux].h830utili ,
                   a_ctc59m00[arr_aux].h9cota    , a_ctc59m00[arr_aux].h9utili   ,
                   a_ctc59m00[arr_aux].h930cota  , a_ctc59m00[arr_aux].h930utili ,
                   a_ctc59m00[arr_aux].h10cota   , a_ctc59m00[arr_aux].h10utili  ,
                   a_ctc59m00[arr_aux].h1030cota , a_ctc59m00[arr_aux].h1030utili,
                   a_ctc59m00[arr_aux].h11cota   , a_ctc59m00[arr_aux].h11utili  ,
                   a_ctc59m00[arr_aux].h1130cota , a_ctc59m00[arr_aux].h1130utili,
                   a_ctc59m00[arr_aux].h12cota   , a_ctc59m00[arr_aux].h12utili  ,
                   a_ctc59m00[arr_aux].h1230cota , a_ctc59m00[arr_aux].h1230utili,
                   a_ctc59m00[arr_aux].h13cota   , a_ctc59m00[arr_aux].h13utili  ,
                   a_ctc59m00[arr_aux].h1330cota , a_ctc59m00[arr_aux].h1330utili,
                   a_ctc59m00[arr_aux].h14cota   , a_ctc59m00[arr_aux].h14utili  ,
                   a_ctc59m00[arr_aux].h1430cota , a_ctc59m00[arr_aux].h1430utili,
                   a_ctc59m00[arr_aux].h15cota   , a_ctc59m00[arr_aux].h15utili  ,
                   a_ctc59m00[arr_aux].h1530cota , a_ctc59m00[arr_aux].h1530utili,
                   a_ctc59m00[arr_aux].h16cota   , a_ctc59m00[arr_aux].h16utili  ,
                   a_ctc59m00[arr_aux].h1630cota , a_ctc59m00[arr_aux].h1630utili,
                   a_ctc59m00[arr_aux].h17cota   , a_ctc59m00[arr_aux].h17utili  ,
                   a_ctc59m00[arr_aux].h1730cota , a_ctc59m00[arr_aux].h1730utili,
                   a_ctc59m00[arr_aux].h18cota   , a_ctc59m00[arr_aux].h18utili  ,
                   a_ctc59m00[arr_aux].h1830cota , a_ctc59m00[arr_aux].h1830utili,
                   a_ctc59m00[arr_aux].h19cota   , a_ctc59m00[arr_aux].h19utili  ,
                   a_ctc59m00[arr_aux].h1930cota , a_ctc59m00[arr_aux].h1930utili,
                   a_ctc59m00[arr_aux].h20cota   , a_ctc59m00[arr_aux].h20utili  ,
                   a_ctc59m00[arr_aux].h2030cota , a_ctc59m00[arr_aux].h2030utili,
                   a_ctc59m00[arr_aux].h21cota   , a_ctc59m00[arr_aux].h21utili  ,
                   a_ctc59m00[arr_aux].h2130cota , a_ctc59m00[arr_aux].h2130utili,
                   a_ctc59m00[arr_aux].h22cota   , a_ctc59m00[arr_aux].h22utili  ,
                   a_ctc59m00[arr_aux].h2230cota , a_ctc59m00[arr_aux].h2230utili,
                   a_ctc59m00[arr_aux].h23cota   , a_ctc59m00[arr_aux].h23utili  ,
                   a_ctc59m00[arr_aux].h2330cota , a_ctc59m00[arr_aux].h2330utili

    let arr_aux = arr_aux + 1

    if arr_aux > 100 then
       error " Limite excedido, convenio com mais de 100 assuntos"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux-1)
 options comment line last - 1

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui, (F3)Proximo, (F4)Anterior"

 while 2

    let int_flag = false

    input array a_ctc59m00 without defaults from s_ctc59m00.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
             let ws.atdsrvorg = a_ctc59m00[arr_aux].atdsrvorg
             let ws.srvrglcod = a_ctc59m00[arr_aux].srvrglcod
          end if
          next field atdsrvorg

       before insert
          let ws.operacao = "i"
          initialize a_ctc59m00[arr_aux].*  to null
          display a_ctc59m00[arr_aux].* to s_ctc59m00[scr_aux].*


       before field atdsrvorg
              display a_ctc59m00[arr_aux].atdsrvorg to
                      s_ctc59m00[scr_aux].atdsrvorg attribute (reverse)

       after  field atdsrvorg
          display a_ctc59m00[arr_aux].atdsrvorg to
                  s_ctc59m00[scr_aux].atdsrvorg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and 
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  and
                ws.atdsrvorg <> a_ctc59m00[arr_aux].atdsrvorg then
                error " A Origem do servico nao pode ser alterada!"
                let a_ctc59m00[arr_aux].atdsrvorg = ws.atdsrvorg
                next field atdsrvorg
             end if
             if a_ctc59m00[arr_aux].atdsrvorg is null and (fgl_keyval("F4") = false) then
                error " Origem do servico deve ser informado!"
                next field atdsrvorg
             end if
          end if

       before field srvrglcod
          display a_ctc59m00[arr_aux].srvrglcod to
                  s_ctc59m00[scr_aux].srvrglcod attribute (reverse)

       after  field srvrglcod
          display a_ctc59m00[arr_aux].srvrglcod to
                  s_ctc59m00[scr_aux].srvrglcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and 
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  and
                ws.srvrglcod <> a_ctc59m00[arr_aux].srvrglcod then
                error " O Tipo de servico/Grupo de natureza nao pode ser alterada!"
                let a_ctc59m00[arr_aux].srvrglcod = ws.srvrglcod
                next field srvrglcod
             end if

             if a_ctc59m00[arr_aux].srvrglcod is null  then
                error " Tipo de servico/Grupo de natureza deve ser informado!"
                next field srvrglcod
             end if

             #--------------------------------------------------------------
             # Verifica se o tipo de servico esta cadastrado
             #--------------------------------------------------------------
             if a_ctc59m00[arr_aux].atdsrvorg = 9 then
                select socntzgrpdes
                       into a_ctc59m00[arr_aux].srvrgldes
                  from datksocntzgrp
                 where socntzgrpcod = a_ctc59m00[arr_aux].srvrglcod
             else
                select asitipabvdes
                       into a_ctc59m00[arr_aux].srvrgldes
                  from datkasitip
                 where asitipcod = a_ctc59m00[arr_aux].srvrglcod
             end if

             if sqlca.sqlcode = notfound then
                error " Tipo de servico nao cadastrada!"
                next field srvrglcod
             end if
             display a_ctc59m00[arr_aux].srvrgldes to
                     s_ctc59m00[scr_aux].srvrgldes

          end if

          for x = 1 to 100
              if arr_aux <> x                                            and
                 a_ctc59m00[arr_aux].atdsrvorg = a_ctc59m00[x].atdsrvorg and
                 a_ctc59m00[arr_aux].srvrglcod = a_ctc59m00[x].srvrglcod then
                 error " Servico ja' cadastrada para esta data!"
                 next field srvrglcod
              end if
          end for

       before field h0cota
          let l_cota_ant = a_ctc59m00[arr_aux].h0cota

       after  field h0cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h0cota
                                       ,a_ctc59m00[arr_aux].h0utili )
                     returning l_cotaflg

                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h0cota = l_cota_ant
                   next field h0cota
                end if
 
                let ws.hora = "00:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h0cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h0cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field srvrglcod
             else
                if fgl_lastkey() = fgl_keyval("down") then
                   next field h030cota
                else
                   if fgl_lastkey() = fgl_keyval("right") then
                      next field h5cota
                   else
                      if fgl_lastkey() = fgl_keyval("left") then
                         next field h0cota
                      end if 
                   end if  
                end if 
             end if 
             
          end if
       
       before field h030cota
          let l_cota_ant = a_ctc59m00[arr_aux].h030cota
          
       after  field h030cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then                                       
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()                
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h030cota
                                       ,a_ctc59m00[arr_aux].h030utili )
                     returning l_cotaflg

                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h030cota = l_cota_ant
                   next field h030cota
                end if
 
                let ws.hora = "00:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h030cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h030cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h0cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1cota
                else
                   let arr_aux = arr_count()
                   if fgl_lastkey() = fgl_keyval("right") then
                      next field h530cota
                   else
                      if fgl_lastkey() = fgl_keyval("left") then
                         next field h20cota
                      end if
                   end if   
                end if 
             end if 
          end if          
       
       before field h1cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1cota

       after  field h1cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1cota
                                       ,a_ctc59m00[arr_aux].h1utili )
                     returning l_cotaflg

               if l_cotaflg <> 0 then
                  let a_ctc59m00[arr_aux].h1cota = l_cota_ant
                  next field h1cota
               end if

                let ws.hora = "01:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h1cota
                end if
             end if
           else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h030cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h130cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h6cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h2030cota
                         end if
                      end if   
                   
                end if  
             end if 
          end if
       
       before field h130cota
          let l_cota_ant = a_ctc59m00[arr_aux].h130cota

       after  field h130cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()            
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h130cota
                                       ,a_ctc59m00[arr_aux].h130utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h130cota = l_cota_ant
                   next field h130cota
                end if
       
                let ws.hora = "01:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h130cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
       
                if l_sqlcode <> 0 then
                   next field h130cota
                end if
       
             end if
           else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h2cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h630cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h21cota
                         end if
                      end if   
                   
                end if   
             end if 
          end if
              
       before field h2cota
          let l_cota_ant = a_ctc59m00[arr_aux].h2cota

       after  field h2cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h2cota
                                       ,a_ctc59m00[arr_aux].h2utili )
                     returning l_cotaflg

               if l_cotaflg <> 0 then
                  let a_ctc59m00[arr_aux].h2cota = l_cota_ant
                  next field h2cota
               end if

                let ws.hora = "02:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h2cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h130cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h230cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h7cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h2130cota
                         end if
                      end if  
                   
                end if  
             end if 
          end if
       
       before field h230cota
          let l_cota_ant = a_ctc59m00[arr_aux].h230cota

       after  field h230cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h230cota
                                       ,a_ctc59m00[arr_aux].h230utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h230cota = l_cota_ant
                   next field h230cota
                end if
       
                let ws.hora = "02:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h230cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h230cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h2cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h3cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h730cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h22cota
                         end if
                      end if   
                   
                end if   
             end if 
          end if
       
       before field h3cota
          let l_cota_ant = a_ctc59m00[arr_aux].h3cota

       after  field h3cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h3cota
                                       ,a_ctc59m00[arr_aux].h3utili )
                     returning l_cotaflg

               if l_cotaflg <> 0 then
                  let a_ctc59m00[arr_aux].h3cota = l_cota_ant
                  next field h3cota
               end if

                let ws.hora = "03:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h3cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h3cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h230cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h330cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h8cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h2230cota
                         end if
                      end if  
                   
                end if  
             end if 
          end if
       
       before field h330cota
          let l_cota_ant = a_ctc59m00[arr_aux].h330cota

       after  field h330cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h330cota
                                       ,a_ctc59m00[arr_aux].h330utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h330cota = l_cota_ant
                   next field h330cota
                end if
       
                let ws.hora = "03:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h330cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h330cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h3cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h4cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h830cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h23cota
                         end if
                      end if   
                   
                end if   
             end if 
          end if
       
       before field h4cota
          let l_cota_ant = a_ctc59m00[arr_aux].h4cota

       after  field h4cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h4cota
                                       ,a_ctc59m00[arr_aux].h4utili )
                     returning l_cotaflg

               if l_cotaflg <> 0 then
                  let a_ctc59m00[arr_aux].h4cota = l_cota_ant
                  next field h4cota
               end if

                let ws.hora = "04:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h4cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h4cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h330cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h430cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h9cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h2330cota
                         end if
                      end if   
                   
                end if    
             end if 
          end if
       
       before field h430cota
          let l_cota_ant = a_ctc59m00[arr_aux].h430cota

       after  field h430cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h430cota
                                       ,a_ctc59m00[arr_aux].h430utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h430cota = l_cota_ant
                   next field h430cota
                end if
       
                let ws.hora = "04:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h430cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h430cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h4cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h5cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h930cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h19cota
                         end if
                      end if    
                   
                end if    
             end if 
          end if
       
       before field h5cota
          let l_cota_ant = a_ctc59m00[arr_aux].h5cota

       after  field h5cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h5cota
                                       ,a_ctc59m00[arr_aux].h5utili )
                     returning l_cotaflg

               if l_cotaflg <> 0 then
                  let a_ctc59m00[arr_aux].h5cota = l_cota_ant
                  next field h5cota
               end if

                let ws.hora = "05:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h5cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h5cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h430cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h530cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h10cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h0cota
                         end if
                      end if   
                   
                end if   
             end if 
          end if
       
       before field h530cota
          let l_cota_ant = a_ctc59m00[arr_aux].h530cota

       after  field h530cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then             
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr() 
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h530cota
                                       ,a_ctc59m00[arr_aux].h530utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h530cota = l_cota_ant
                   next field h530cota
                end if
       
                let ws.hora = "05:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h530cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h530cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h5cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h6cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1030cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h030cota
                         end if
                      end if   
                   
                end if 
             end if 
          end if
       
       before field h6cota
          let l_cota_ant = a_ctc59m00[arr_aux].h6cota

       after  field h6cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()             
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h6cota
                                       ,a_ctc59m00[arr_aux].h6utili )
                     returning l_cotaflg

               if l_cotaflg <> 0 then
                  let a_ctc59m00[arr_aux].h6cota = l_cota_ant
                  next field h6cota
               end if

                let ws.hora = "06:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h6cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h6cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h530cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h630cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h11cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1cota
                         end if
                      end if   
                   
                end if 
             end if 
          end if
       
       before field h630cota
          let l_cota_ant = a_ctc59m00[arr_aux].h630cota

       after  field h630cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h630cota
                                       ,a_ctc59m00[arr_aux].h630utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h630cota = l_cota_ant
                   next field h630cota
                end if
       
                let ws.hora = "06:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h630cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h630cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h6cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h7cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1130cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h130cota
                         end if
                      end if   
                   
                end if  
             end if 
          end if
       
       before field h7cota
          let l_cota_ant = a_ctc59m00[arr_aux].h7cota

       after  field h7cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h7cota
                                        ,a_ctc59m00[arr_aux].h7utili )
                     returning l_cotaflg

                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h7cota = l_cota_ant
                   next field h7cota
                end if

                let ws.hora = "07:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h7cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h7cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h630cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h730cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h12cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h2cota
                         end if
                      end if   
                   
                end if  
             end if 
          end if
       
       before field h730cota
          let l_cota_ant = a_ctc59m00[arr_aux].h730cota

       after  field h730cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h730cota
                                       ,a_ctc59m00[arr_aux].h730utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h730cota = l_cota_ant
                   next field h730cota
                end if
       
                let ws.hora = "07:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h730cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h730cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h7cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h8cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1230cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h230cota
                         end if
                      end if   
                   
                end if  
             end if 
          end if
       
       before field h8cota
          let l_cota_ant = a_ctc59m00[arr_aux].h8cota

       after  field h8cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h8cota
                                        ,a_ctc59m00[arr_aux].h8utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h8cota = l_cota_ant
                   next field h8cota
                end if

                let ws.hora = "08:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h8cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h8cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h730cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h830cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h13cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h3cota
                         end if
                      end if   
                  # end if 
                end if 
             end if 
          end if
       
       before field h830cota
          let l_cota_ant = a_ctc59m00[arr_aux].h830cota

       after  field h830cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h830cota
                                       ,a_ctc59m00[arr_aux].h830utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h830cota = l_cota_ant
                   next field h830cota
                end if
       
                let ws.hora = "08:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h830cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h830cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h8cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h9cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1330cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h330cota
                         end if
                      end if   
                   
                end if  
             end if
          end if
       
       before field h9cota
          let l_cota_ant = a_ctc59m00[arr_aux].h9cota

       after  field h9cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h9cota
                                        ,a_ctc59m00[arr_aux].h9utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h9cota = l_cota_ant
                   next field h9cota
                end if

                let ws.hora = "09:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h9cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h9cota
                end if
             end if
           else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h830cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h930cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h14cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h4cota
                         end if
                      end if   
                   
                end if  
             end if
          end if
       
       before field h930cota
          let l_cota_ant = a_ctc59m00[arr_aux].h930cota

       after  field h930cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h930cota
                                       ,a_ctc59m00[arr_aux].h930utili )
                     returning l_cotaflg
                                                   
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h930cota = l_cota_ant
                   next field h930cota
                end if
       
                let ws.hora = "09:30"                
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h930cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h930cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h9cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h10cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1430cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h430cota
                         end if
                      end if   
                   
                end if  
             end if
          end if
       
       before field h10cota
          let l_cota_ant = a_ctc59m00[arr_aux].h10cota

       after  field h10cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h10cota
                                        ,a_ctc59m00[arr_aux].h10utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h10cota = l_cota_ant
                   next field h10cota
                end if

                let ws.hora = "10:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h10cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h10cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h930cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1030cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h15cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h5cota
                         end if
                      end if   
                   
                end if   
             end if
          end if
       
       before field h1030cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1030cota

       after  field h1030cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()             
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1030cota
                                       ,a_ctc59m00[arr_aux].h1030utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1030cota = l_cota_ant
                   next field h1030cota
                end if
       
                let ws.hora = "10:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1030cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1030cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h10cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h11cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1530cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h530cota
                         end if
                      end if   
                   
                end if    
             end if
          end if
       
       before field h11cota
          let l_cota_ant = a_ctc59m00[arr_aux].h11cota

       after  field h11cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h11cota
                                        ,a_ctc59m00[arr_aux].h11utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h11cota = l_cota_ant
                   next field h11cota
                end if

                let ws.hora = "11:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h11cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h11cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1030cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1130cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h16cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h6cota
                         end if
                      end if   
                   
                end if   
             end if
          end if
       
       before field h1130cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1130cota

       after  field h1130cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1130cota
                                       ,a_ctc59m00[arr_aux].h1130utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1130cota = l_cota_ant
                   next field h1130cota
                end if
       
                let ws.hora = "11:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1130cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1130cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h11cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h12cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1630cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h630cota
                         end if
                      end if   
                   
                end if    
             end if
          end if
       
       before field h12cota
          let l_cota_ant = a_ctc59m00[arr_aux].h12cota

       after  field h12cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h12cota
                                        ,a_ctc59m00[arr_aux].h12utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h12cota = l_cota_ant
                   next field h12cota
                end if

                let ws.hora = "12:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h12cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h12cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1130cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1230cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h17cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h7cota
                         end if
                      end if   
                   
                end if    
             end if
          end if
       
       before field h1230cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1230cota

       after  field h1230cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1230cota
                                       ,a_ctc59m00[arr_aux].h1230utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1230cota = l_cota_ant
                   next field h1230cota
                end if
       
                let ws.hora = "12:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1230cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1230cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h12cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h13cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1730cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h730cota
                         end if
                      end if   
                   
                end if     
             end if
          end if
       
       before field h13cota
          let l_cota_ant = a_ctc59m00[arr_aux].h13cota

       after  field h13cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h13cota
                                        ,a_ctc59m00[arr_aux].h13utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h13cota = l_cota_ant
                   next field h13cota
                end if

                let ws.hora = "13:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h13cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h13cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1230cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1330cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h18cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h8cota
                         end if
                      end if   
                   
                end if     
             end if
          end if
       
       before field h1330cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1330cota

       after  field h1330cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1330cota
                                       ,a_ctc59m00[arr_aux].h1330utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1330cota = l_cota_ant
                   next field h1330cota
                end if
       
                let ws.hora = "13:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1330cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1330cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h13cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h14cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1830cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h830cota
                         end if
                      end if   
                   
                end if  
             end if
          end if
       
       before field h14cota
          let l_cota_ant = a_ctc59m00[arr_aux].h14cota

       after  field h14cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h14cota
                                        ,a_ctc59m00[arr_aux].h14utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h14cota = l_cota_ant
                   next field h14cota
                end if

                let ws.hora = "14:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h14cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h14cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1330cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1430cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h19cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h9cota
                         end if
                      end if   
                   
                end if   
             end if
          end if
       
       before field h1430cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1430cota

       after  field h1430cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1430cota
                                       ,a_ctc59m00[arr_aux].h1430utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1430cota = l_cota_ant
                   next field h1430cota
                end if
       
                let ws.hora = "14:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1430cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1430cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h14cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h15cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1930cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h930cota
                         end if
                      end if   
                   
                end if    
             end if
          end if
       
       before field h15cota
          let l_cota_ant = a_ctc59m00[arr_aux].h15cota

       after  field h15cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h15cota
                                        ,a_ctc59m00[arr_aux].h15utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h15cota = l_cota_ant
                   next field h15cota
                end if

                let ws.hora = "15:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h15cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h15cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1430cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1530cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h20cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h10cota
                         end if
                      end if   
                   
                end if    
             end if
          end if
       
       before field h1530cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1530cota

       after  field h1530cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1530cota
                                       ,a_ctc59m00[arr_aux].h1530utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1530cota = l_cota_ant
                   next field h1530cota
                end if
       
                let ws.hora = "15:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1530cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1530cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h15cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h16cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h2030cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1030cota
                         end if
                      end if   
                   
                end if 
             end if
          end if
       
       before field h16cota
          let l_cota_ant = a_ctc59m00[arr_aux].h16cota

       after  field h16cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h16cota
                                        ,a_ctc59m00[arr_aux].h16utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h16cota = l_cota_ant
                   next field h16cota
                end if

                let ws.hora = "16:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h16cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h16cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1530cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1630cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h21cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h11cota
                         end if
                      end if   
                   
                end if  
             end if
          end if
       
       before field h1630cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1630cota

       after  field h1630cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1630cota
                                       ,a_ctc59m00[arr_aux].h1630utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1630cota = l_cota_ant
                   next field h1630cota
                end if
       
                let ws.hora = "16:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1630cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1630cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h16cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h17cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h2130cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1130cota
                         end if
                      end if   
                   
                end if   
             end if
          end if
       
       before field h17cota
          let l_cota_ant = a_ctc59m00[arr_aux].h17cota

       after  field h17cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then   
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h17cota
                                        ,a_ctc59m00[arr_aux].h17utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h17cota = l_cota_ant
                   next field h17cota
                end if

                let ws.hora = "17:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h17cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h17cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1630cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1730cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h22cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h12cota
                         end if
                      end if   
                   
                end if   
             end if
          end if
       
       before field h1730cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1730cota

       after  field h1730cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1730cota
                                       ,a_ctc59m00[arr_aux].h1730utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1730cota = l_cota_ant
                   next field h1730cota
                end if
       
                let ws.hora = "17:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1730cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1730cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h17cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h18cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h2230cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1230cota
                         end if
                      end if   
                   
                end if    
             end if
          end if
       
       before field h18cota
          let l_cota_ant = a_ctc59m00[arr_aux].h18cota

       after  field h18cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h18cota
                                        ,a_ctc59m00[arr_aux].h18utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h18cota = l_cota_ant
                   next field h18cota
                end if

                let ws.hora = "18:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h18cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h18cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1730cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1830cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h23cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h13cota
                         end if
                      end if   
                   
                end if    
             end if
          end if
       
       before field h1830cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1830cota

       after  field h1830cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1830cota
                                       ,a_ctc59m00[arr_aux].h1830utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1830cota = l_cota_ant
                   next field h1830cota
                end if
       
                let ws.hora = "18:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1830cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1830cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h18cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h19cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h2330cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1330cota
                         end if
                      end if   
                   
                end if    
             end if
          end if
       
       before field h19cota
          let l_cota_ant = a_ctc59m00[arr_aux].h19cota

       after  field h19cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h19cota
                                        ,a_ctc59m00[arr_aux].h19utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h19cota = l_cota_ant
                   next field h19cota
                end if

                let ws.hora = "19:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h19cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h19cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1830cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h1930cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h430cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h14cota
                         end if
                      end if  
                   
                end if    
             end if
          end if
       
       before field h1930cota
          let l_cota_ant = a_ctc59m00[arr_aux].h1930cota

       after  field h1930cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h1930cota
                                       ,a_ctc59m00[arr_aux].h1930utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h1930cota = l_cota_ant
                   next field h1930cota
                end if
       
                let ws.hora = "19:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1930cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h1930cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h19cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h20cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1930cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1430cota
                         end if
                      end if  
                   
                end if   
             end if
          end if
       
       before field h20cota
          let l_cota_ant = a_ctc59m00[arr_aux].h20cota

       after  field h20cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h20cota
                                        ,a_ctc59m00[arr_aux].h20utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h20cota = l_cota_ant
                   next field h20cota
                end if

                let ws.hora = "20:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h20cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h20cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h1930cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h2030cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h030cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h15cota
                         end if
                      end if  
                   
                end if  
             end if
          end if
       
       before field h2030cota
          let l_cota_ant = a_ctc59m00[arr_aux].h2030cota

       after  field h2030cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h2030cota
                                       ,a_ctc59m00[arr_aux].h2030utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h2030cota = l_cota_ant
                   next field h2030cota
                end if
       
                let ws.hora = "20:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2030cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h2030cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h20cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h21cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h1cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1530cota
                         end if
                      end if 
                   
                end if  
             end if
          end if
       
       before field h21cota
          let l_cota_ant = a_ctc59m00[arr_aux].h21cota

       after  field h21cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h21cota
                                        ,a_ctc59m00[arr_aux].h21utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h21cota = l_cota_ant
                   next field h21cota
                end if

                let ws.hora = "21:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h21cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h21cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h2030cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h2130cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h130cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h16cota
                         end if
                      end if 
                   
                end if  
             end if
          end if
       
       before field h2130cota
          let l_cota_ant = a_ctc59m00[arr_aux].h2130cota

       after  field h2130cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h2130cota
                                       ,a_ctc59m00[arr_aux].h2130utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h2130cota = l_cota_ant
                   next field h2130cota
                end if
       
                let ws.hora = "21:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2130cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h2130cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h21cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h22cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h2cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1630cota
                         end if
                      end if 
                   
                end if   
             end if
          end if
       
       before field h22cota
          let l_cota_ant = a_ctc59m00[arr_aux].h22cota

       after  field h22cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h22cota
                                        ,a_ctc59m00[arr_aux].h22utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h22cota = l_cota_ant
                   next field h22cota
                end if

                let ws.hora = "22:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h22cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h22cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h2130cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h2230cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h230cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h17cota
                         end if
                      end if 
                   
                end if   
             end if
          end if
       
       before field h2230cota
          let l_cota_ant = a_ctc59m00[arr_aux].h2230cota

       after  field h2230cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h2230cota
                                       ,a_ctc59m00[arr_aux].h2230utili )
                     returning l_cotaflg
       
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h2230cota = l_cota_ant
                   next field h2230cota
                end if
       
                let ws.hora = "22:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2230cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h2230cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h22cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h23cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h3cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1730cota
                         end if
                      end if 
                   
                end if 
             end if
          end if
       
       before field h23cota
          let l_cota_ant = a_ctc59m00[arr_aux].h23cota

       after  field h23cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota( a_ctc59m00[arr_aux].h23cota
                                        ,a_ctc59m00[arr_aux].h23utili )
                      returning l_cotaflg
 
                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h23cota = l_cota_ant
                   next field h23cota
                end if

                let ws.hora = "23:00"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h23cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode
 
                if l_sqlcode <> 0 then
                   next field h23cota
                end if
             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h2230cota
             else
                if fgl_lastkey() = fgl_keyval("down")   then
                   next field h2330cota
                else
                   let arr_aux = arr_count()
                   
                      if fgl_lastkey() = fgl_keyval("right") then
                         next field h330cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h18cota
                         end if
                      end if 
                   
                end if
             end if
          end if
       
       before field h2330cota
          let l_cota_ant = a_ctc59m00[arr_aux].h2330cota

       after  field h2330cota
          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") and 
             fgl_lastkey() <> fgl_keyval("down") and
             fgl_lastkey() <> fgl_keyval("right") then
             if ws.operacao  = "a"  then
                let arr_aux = arr_curr()
                call ctc59m00_verifcota(a_ctc59m00[arr_aux].h2330cota
                                       ,a_ctc59m00[arr_aux].h2330utili )
                     returning l_cotaflg

                if l_cotaflg <> 0 then
                   let a_ctc59m00[arr_aux].h2330cota = l_cota_ant
                   next field h2330cota
                end if
       
                let ws.hora = "23:30"
                call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2330cota,
                                       param.cidcod,param.rgldat,
                                       a_ctc59m00[arr_aux].atdsrvorg,
                                       a_ctc59m00[arr_aux].srvrglcod,
                                       ws.hora)
                     returning l_sqlcode

                if l_sqlcode <> 0 then
                   next field h2330cota
                end if

             end if
          else
             if fgl_lastkey() = fgl_keyval("up")   then
                next field h23cota
             else
                let arr_aux = arr_count()
                
                   if fgl_lastkey() = fgl_keyval("right") then
                         next field h4cota
                      else
                         if fgl_lastkey() = fgl_keyval("left") then
                            next field h1830cota
                         end if
                      end if 
                
             end if
          end if
       
       before delete
          let ws.operacao = "d"
          if a_ctc59m00[arr_aux].atdsrvorg  is null  or
             a_ctc59m00[arr_aux].srvrglcod  is null  then
             continue while
          end if
             
	  call cts08g01('C','S',"","   Confirma a exclusao?","","")
               returning prompt_key
          if prompt_key = 'N' then
             continue while
          end if
	  
          delete from datmsrvrgl
           where cidcod = param.cidcod
             and rgldat = param.rgldat
             and atdsrvorg = a_ctc59m00[arr_aux].atdsrvorg
             and srvrglcod = a_ctc59m00[arr_aux].srvrglcod

          if sqlca.sqlcode <> 0 then
             error " Erro (", sqlca.sqlcode, ") na exclusao deste regulador, favor verificar!"
          end if
          
          initialize a_ctc59m00[arr_aux].* to null                          
          continue while
          

       after row
         if a_ctc59m00[arr_aux].atdsrvorg is not null and
            a_ctc59m00[arr_aux].srvrglcod is not null then

            #if ws.operacao = "i" then

               call ctc59m00_init(arr_aux)

               let ws.hora = "00:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h0cota,param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                   returning l_retorno
               
               let ws.hora = "00:30"               
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h030cota,param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                    returning l_retorno
               
               let ws.hora = "01:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1cota, param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                    returning l_retorno

               let ws.hora = "01:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h130cota, param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                    returning l_retorno
               
               let ws.hora = "02:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2cota, param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                   returning l_retorno
                                      
               let ws.hora = "02:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h230cota, param.cidcod,
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                   returning l_retorno
                                      
               let ws.hora = "03:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h3cota, param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "03:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h330cota, param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "04:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h4cota, param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "04:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h430cota, param.cidcod, 
                                      param.rgldat, a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod, ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "05:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h5cota, param.cidcod, 
                                      param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "05:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h530cota, param.cidcod, 
                                      param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "06:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h6cota, param.cidcod,
                                      param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "06:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h630cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "07:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h7cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "07:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h730cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "08:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h8cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "08:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h830cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "09:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h9cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "09:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h930cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                                      
                   returning l_retorno                   
                   
               let ws.hora = "10:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h10cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "10:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1030cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "11:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h11cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "11:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1130cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "12:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h12cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "12:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1230cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "13:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h13cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "13:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1330cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "14:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h14cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "14:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1430cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "15:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h15cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "15:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1530cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "16:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h16cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "16:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1630cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "17:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h17cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "17:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1730cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "18:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h18cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "18:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1830cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "19:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h19cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "19:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h1930cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "20:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h20cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "20:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2030cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "21:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h21cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "21:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2130cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "22:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h22cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "22:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2230cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno                   
                   
               let ws.hora = "23:00"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h23cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno
                   
               let ws.hora = "23:30"
               call ctc59m00_upd_cota(a_ctc59m00[arr_aux].h2330cota, param.cidcod, param.rgldat,
                                      a_ctc59m00[arr_aux].atdsrvorg,
                                      a_ctc59m00[arr_aux].srvrglcod,
                                      ws.hora)
                   returning l_retorno
                   
               #continue while
            #end if

          end if

          let ws.operacao = " "

       on key (interrupt)
          exit input

    end input

    if int_flag    then
       exit while
    end if

end while

clear form

let int_flag = false

end function  #  ctc59m00_cidades

function ctc59m00_verifcota ( l_param )

   define l_param        record
      cotaqtd           integer
     ,utlqtd             integer
   end record

   if l_param.cotaqtd < l_param.utlqtd then
      error "Quantidade de cotas nao pode ser menor do que a quantidade "
           ,"utilizada!"
      return 1
   end if

   return 0

end function

function ctc59m00_upd_cota(lr_param)

   define lr_param    record 
          hcota       like datmsrvrgl.cotqtd,
          cidcod      like datmsrvrgl.cidcod,
          rgldat      like datmsrvrgl.rgldat,
          atdsrvorg   like datmsrvrgl.atdsrvorg,
          srvrglcod   like datmsrvrgl.srvrglcod,
          rglhor      like datmsrvrgl.rglhor
          end record 

   if lr_param.hcota is null then
      let lr_param.hcota = 0
   end if
   
   if lr_param.atdsrvorg is null then
     return 0
   end if

   open cctc59m00003 using lr_param.cidcod, lr_param.rgldat,
                           lr_param.atdsrvorg, lr_param.srvrglcod,
                           lr_param.rglhor
   fetch cctc59m00003

   if sqlca.sqlcode = notfound then ## insere hora      
      execute cctc59m00002 using lr_param.cidcod,
                                 lr_param.rgldat,
                                 lr_param.atdsrvorg,
                                 lr_param.srvrglcod,
                                 lr_param.hcota,
                                 lr_param.rglhor
   else
      execute cctc59m00001 using lr_param.hcota, lr_param.cidcod,
                                 lr_param.rgldat, lr_param.atdsrvorg,
                                 lr_param.srvrglcod, lr_param.rglhor
   end if

   if sqlca.sqlcode <> 0 then
      error "Erro ", sqlca.sqlcode, " na atualizacao da hora ", lr_param.rglhor
      close cctc59m00003
      return sqlca.sqlcode
   else
      close cctc59m00003
      return 0
   end if

end function

function ctc59m00_init(arr_aux)

   define arr_aux integer

   if a_ctc59m00[arr_aux].h0cota is null then
      let a_ctc59m00[arr_aux].h0cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1cota is null then
      let a_ctc59m00[arr_aux].h1cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h2cota is null then
      let a_ctc59m00[arr_aux].h2cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h3cota is null then
      let a_ctc59m00[arr_aux].h3cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h4cota is null then
      let a_ctc59m00[arr_aux].h4cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h5cota is null then
      let a_ctc59m00[arr_aux].h5cota = 0
   end if
   if a_ctc59m00[arr_aux].h6cota is null then
      let a_ctc59m00[arr_aux].h6cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h7cota is null then
      let a_ctc59m00[arr_aux].h7cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h8cota is null then
      let a_ctc59m00[arr_aux].h8cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h9cota is null then
      let a_ctc59m00[arr_aux].h9cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h10cota is null then
      let a_ctc59m00[arr_aux].h10cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h11cota is null then
      let a_ctc59m00[arr_aux].h11cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h12cota is null then
      let a_ctc59m00[arr_aux].h12cota = 0
   end if

   if a_ctc59m00[arr_aux].h13cota is null then
      let a_ctc59m00[arr_aux].h13cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h14cota is null then
      let a_ctc59m00[arr_aux].h14cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h15cota is null then
      let a_ctc59m00[arr_aux].h15cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h16cota is null then
      let a_ctc59m00[arr_aux].h16cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h17cota is null then
      let a_ctc59m00[arr_aux].h17cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h18cota is null then
      let a_ctc59m00[arr_aux].h18cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h19cota is null then
      let a_ctc59m00[arr_aux].h19cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h20cota is null then
      let a_ctc59m00[arr_aux].h20cota = 0
   end if

   if a_ctc59m00[arr_aux].h20cota is null then
      let a_ctc59m00[arr_aux].h20cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h21cota is null then
      let a_ctc59m00[arr_aux].h21cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h22cota is null then
      let a_ctc59m00[arr_aux].h22cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h23cota is null then
      let a_ctc59m00[arr_aux].h23cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h030cota is null then
      let a_ctc59m00[arr_aux].h030cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h130cota is null then
      let a_ctc59m00[arr_aux].h130cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h230cota is null then
      let a_ctc59m00[arr_aux].h230cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h330cota is null then
      let a_ctc59m00[arr_aux].h330cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h430cota is null then
      let a_ctc59m00[arr_aux].h430cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h530cota is null then
      let a_ctc59m00[arr_aux].h530cota = 0
   end if
   if a_ctc59m00[arr_aux].h630cota is null then
      let a_ctc59m00[arr_aux].h630cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h730cota is null then
      let a_ctc59m00[arr_aux].h730cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h830cota is null then
      let a_ctc59m00[arr_aux].h830cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h930cota is null then
      let a_ctc59m00[arr_aux].h930cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1030cota is null then
      let a_ctc59m00[arr_aux].h1030cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1130cota is null then
      let a_ctc59m00[arr_aux].h1130cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1230cota is null then
      let a_ctc59m00[arr_aux].h1230cota = 0
   end if

   if a_ctc59m00[arr_aux].h1330cota is null then
      let a_ctc59m00[arr_aux].h1330cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1430cota is null then
      let a_ctc59m00[arr_aux].h1430cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1530cota is null then
      let a_ctc59m00[arr_aux].h1530cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1630cota is null then
      let a_ctc59m00[arr_aux].h1630cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1730cota is null then
      let a_ctc59m00[arr_aux].h1730cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1830cota is null then
      let a_ctc59m00[arr_aux].h1830cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h1930cota is null then
      let a_ctc59m00[arr_aux].h1930cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h2030cota is null then
      let a_ctc59m00[arr_aux].h2030cota = 0
   end if

   if a_ctc59m00[arr_aux].h2030cota is null then
      let a_ctc59m00[arr_aux].h2030cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h2130cota is null then
      let a_ctc59m00[arr_aux].h2130cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h2230cota is null then
      let a_ctc59m00[arr_aux].h2230cota = 0
   end if
   
   if a_ctc59m00[arr_aux].h2330cota is null then
      let a_ctc59m00[arr_aux].h2330cota = 0
   end if
   
end function

function ctc59m00_ins_cota(lr_param)

   define lr_param    record
          cidcod      like datmsrvrgl.cidcod,
          rgldat      like datmsrvrgl.rgldat,
          atdsrvorg   like datmsrvrgl.atdsrvorg,
          srvrglcod   like datmsrvrgl.srvrglcod,
          cotqtd      like datmsrvrgl.cotqtd,
          rglhor      like datmsrvrgl.rglhor
          end record

   execute cctc59m00002 using lr_param.cidcod, 
                              lr_param.rgldat,
                              lr_param.atdsrvorg,
                              lr_param.srvrglcod,
                              lr_param.cotqtd, 
                              lr_param.rglhor

   if sqlca.sqlcode <> 0 then
      error "Erro ", sqlca.sqlcode, " na inclusao da hora ", lr_param.rglhor
   end if

end function

function ctc59m00_carrega_hor(lr_param)

   define lr_param   record
          cidcod     like datmsrvrgl.cidcod,
          rgldat     like datmsrvrgl.rgldat,
          atdsrvorg  like datmsrvrgl.atdsrvorg,
          srvrglcod  like datmsrvrgl.srvrglcod
          end record

   define l_hora char(5)

   define l_ret   record
          h0cota       decimal(6,0),
          h0utili      decimal(6,0),
          h030cota     decimal(6,0),
          h030utili    decimal(6,0),
          h1cota       decimal(6,0),
          h1utili      decimal(6,0),
          h130cota     decimal(6,0),
          h130utili    decimal(6,0),
          h2cota       decimal(6,0),
          h2utili      decimal(6,0),
          h230cota     decimal(6,0),
          h230utili    decimal(6,0),
          h3cota       decimal(6,0),
          h3utili      decimal(6,0),
          h330cota     decimal(6,0),
          h330utili    decimal(6,0),
          h4cota       decimal(6,0),
          h4utili      decimal(6,0),
          h430cota     decimal(6,0),
          h430utili    decimal(6,0),
          h5cota       decimal(6,0),
          h5utili      decimal(6,0),
          h530cota     decimal(6,0),
          h530utili    decimal(6,0),
          h6cota       decimal(6,0),
          h6utili      decimal(6,0),
          h630cota     decimal(6,0),
          h630utili    decimal(6,0),
          h7cota       decimal(6,0),
          h7utili      decimal(6,0),
          h730cota     decimal(6,0),
          h730utili    decimal(6,0),
          h8cota       decimal(6,0),
          h8utili      decimal(6,0),
          h830cota     decimal(6,0),
          h830utili    decimal(6,0),
          h9cota       decimal(6,0),
          h9utili      decimal(6,0),
          h930cota     decimal(6,0),
          h930utili    decimal(6,0),
          h10cota      decimal(6,0),
          h10utili     decimal(6,0),
          h1030cota    decimal(6,0),
          h1030utili   decimal(6,0),
          h11cota      decimal(6,0),
          h11utili     decimal(6,0),
          h1130cota    decimal(6,0),
          h1130utili   decimal(6,0),
          h12cota      decimal(6,0),
          h12utili     decimal(6,0),
          h1230cota    decimal(6,0),
          h1230utili   decimal(6,0),
          h13cota      decimal(6,0),
          h13utili     decimal(6,0),
          h1330cota    decimal(6,0),
          h1330utili   decimal(6,0),
          h14cota      decimal(6,0),
          h14utili     decimal(6,0),
          h1430cota    decimal(6,0),
          h1430utili   decimal(6,0),
          h15cota      decimal(6,0),
          h15utili     decimal(6,0),
          h1530cota    decimal(6,0),
          h1530utili   decimal(6,0),
          h16cota      decimal(6,0),
          h16utili     decimal(6,0),
          h1630cota    decimal(6,0),
          h1630utili   decimal(6,0),
          h17cota      decimal(6,0),
          h17utili     decimal(6,0),
          h1730cota    decimal(6,0),
          h1730utili   decimal(6,0),
          h18cota      decimal(6,0),
          h18utili     decimal(6,0),
          h1830cota    decimal(6,0),
          h1830utili   decimal(6,0),
          h19cota      decimal(6,0),
          h19utili     decimal(6,0),
          h1930cota    decimal(6,0),
          h1930utili   decimal(6,0),
          h20cota      decimal(6,0),
          h20utili     decimal(6,0),
          h2030cota    decimal(6,0),
          h2030utili   decimal(6,0),
          h21cota      decimal(6,0),
          h21utili     decimal(6,0),
          h2130cota    decimal(6,0),
          h2130utili   decimal(6,0),
          h22cota      decimal(6,0),
          h22utili     decimal(6,0),
          h2230cota    decimal(6,0),
          h2230utili   decimal(6,0),
          h23cota      decimal(6,0),
          h23utili     decimal(6,0),
          h2330cota    decimal(6,0),
          h2330utili   decimal(6,0) 
          end record

   let l_hora = "00:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h0cota, l_ret.h0utili
   close cctc59m00003

   let l_hora = "01:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1cota, l_ret.h1utili
   close cctc59m00003

   let l_hora = "02:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h2cota, l_ret.h2utili
   close cctc59m00003

   let l_hora = "03:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h3cota, l_ret.h3utili
   close cctc59m00003

   let l_hora = "04:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h4cota, l_ret.h4utili
   close cctc59m00003

   let l_hora = "05:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h5cota, l_ret.h5utili
   close cctc59m00003

   let l_hora = "06:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h6cota, l_ret.h6utili
   close cctc59m00003

   let l_hora = "07:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h7cota, l_ret.h7utili
   close cctc59m00003

   let l_hora = "08:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h8cota, l_ret.h8utili
   close cctc59m00003

   let l_hora = "09:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h9cota, l_ret.h9utili
   close cctc59m00003

   let l_hora = "10:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h10cota, l_ret.h10utili
   close cctc59m00003

   let l_hora = "11:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h11cota, l_ret.h11utili
   close cctc59m00003

   let l_hora = "12:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h12cota, l_ret.h12utili
   close cctc59m00003

   let l_hora = "13:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h13cota, l_ret.h13utili
   close cctc59m00003

   let l_hora = "14:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h14cota, l_ret.h14utili
   close cctc59m00003

   let l_hora = "15:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h15cota, l_ret.h15utili
   close cctc59m00003

   let l_hora = "16:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h16cota, l_ret.h16utili
   close cctc59m00003

   let l_hora = "17:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h17cota, l_ret.h17utili
   close cctc59m00003

   let l_hora = "18:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h18cota, l_ret.h18utili
   close cctc59m00003

   let l_hora = "19:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h19cota, l_ret.h19utili
   close cctc59m00003

   let l_hora = "20:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h20cota, l_ret.h20utili
   close cctc59m00003

   let l_hora = "21:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h21cota, l_ret.h21utili
   close cctc59m00003

   let l_hora = "22:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h22cota, l_ret.h22utili
   close cctc59m00003

   let l_hora = "23:00"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h23cota, l_ret.h23utili
   close cctc59m00003
   
   let l_hora = "00:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h030cota, l_ret.h030utili
   close cctc59m00003
   
   let l_hora = "01:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h130cota, l_ret.h130utili
   close cctc59m00003
   
   let l_hora = "02:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h230cota, l_ret.h230utili
   close cctc59m00003
   
   let l_hora = "03:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h330cota, l_ret.h330utili
   close cctc59m00003
   
   let l_hora = "04:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h430cota, l_ret.h430utili
   close cctc59m00003
   
   let l_hora = "05:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h530cota, l_ret.h530utili
   close cctc59m00003
   
   let l_hora = "06:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h630cota, l_ret.h630utili
   close cctc59m00003
   
   let l_hora = "07:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h730cota, l_ret.h730utili
   close cctc59m00003
   
   let l_hora = "08:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h830cota, l_ret.h830utili
   close cctc59m00003
   
   let l_hora = "09:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h930cota, l_ret.h930utili
   close cctc59m00003
   
   let l_hora = "10:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1030cota, l_ret.h1030utili
   close cctc59m00003
   
   let l_hora = "11:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1130cota, l_ret.h1130utili
   close cctc59m00003
   
   let l_hora = "12:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1230cota, l_ret.h1230utili
   close cctc59m00003
   
   let l_hora = "13:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1330cota, l_ret.h1330utili
   close cctc59m00003
   
   let l_hora = "14:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1430cota, l_ret.h1430utili
   close cctc59m00003
   
   let l_hora = "15:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1530cota, l_ret.h1530utili
   close cctc59m00003
      
   let l_hora = "16:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1630cota, l_ret.h1630utili
   close cctc59m00003

   let l_hora = "17:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1730cota, l_ret.h1730utili
   close cctc59m00003
   
   let l_hora = "18:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1830cota, l_ret.h1830utili
   close cctc59m00003
   
   let l_hora = "19:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h1930cota, l_ret.h1930utili
   close cctc59m00003
   
   let l_hora = "20:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h2030cota, l_ret.h2030utili
   close cctc59m00003
   
   let l_hora = "21:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h2130cota, l_ret.h2130utili
   close cctc59m00003
   
   let l_hora = "22:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h2230cota, l_ret.h2230utili
   close cctc59m00003
   
   let l_hora = "23:30"
   open cctc59m00003 using lr_param.*, l_hora
   fetch cctc59m00003 into l_ret.h2330cota, l_ret.h2330utili
   close cctc59m00003

   return l_ret.*

end function
