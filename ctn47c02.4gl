###########################################################################
# Nome do Modulo: CTN47C02                                       Ruiz     #
#     esta tela e chamada pelo pgm ctn47c01                               #
# Menu de consulta atendimento vidros                            Jun/2001 #
###########################################################################

database porto

#main
#  call ctn47c02("14-1000981/01",14981)
#end main
#----------------------------------------------------------------------------
 function ctn47c02(param)
#----------------------------------------------------------------------------
   define param record
       servico     char  (13),
       lignum      like datmligacao.lignum
   end record
   define d_ctn47c02  record
       lignum      like  datmligacao.lignum,
       atmstt1     smallint,
       data1       like  datmligacao.ligdat,
       hora1       like  datmligacao.lighorinc,
       descr1      char  (20),

       atmstt2     smallint,
       data2       like  datmligacao.ligdat,
       hora2       like  datmligacao.lighorinc,
       descr2      char  (20),

       atmstt3     smallint,
       data3       like  datmligacao.ligdat,
       hora3       like  datmligacao.lighorinc,
       descr3      char  (20),

       atmstt4     smallint,
       data4       like  datmligacao.ligdat,
       hora4       like  datmligacao.lighorinc,
       descr4      char  (20)
   end record
   define ws   record
       atmstt      smallint,
       ligdat      like  datmligacao.ligdat,
       lighorinc   like  datmligacao.lighorinc,
       atldat      like  datkassunto.atldat,
       atlhor      like  datmsrvext1.atlhor,
       atldat1     like  datkassunto.atldat,
       atlhor1     like  datmsrvext1.atlhor1,
       atldat2     like  datkassunto.atldat,
       atlhor2     like  datmsrvext1.atlhor2,
       comando     char (500),
       atdetpcod   like  datketapa.atdetpcod,
       atdsrvnum   like  datmservico.atdsrvnum,
       atdsrvano   like  datmservico.atdsrvano,
       resp        char (01)
   end record



	initialize  d_ctn47c02.*  to  null

	initialize  ws.*  to  null

   if param.servico   is null then
      error "Parametro invalido"
      return
   end if

   initialize d_ctn47c02.*    to null
   initialize ws.*            to null

   open window w_ctn47c02a at 09,25 with form "ctn47c02"
               attribute (border, form line first)

   let ws.atdsrvnum        = param.servico[4,10]
   let ws.atdsrvano        = param.servico[12,13]

   let int_flag = false
   initialize d_ctn47c02  to null

   message " Aguarde, pesquisando..."  attribute(reverse)

   let d_ctn47c02.lignum   = param.lignum

   select  atmstt,
           ligdat,
           lighorinc,
           atldat   ,
           atlhor   ,
           atldat1  ,
           atlhor1  ,
           atldat2  ,
           atlhor2
       into ws.atmstt,
            ws.ligdat,
            ws.lighorinc,
            ws.atldat   ,
            ws.atlhor   ,
            ws.atldat1  ,
            ws.atlhor1  ,
            ws.atldat2  ,
            ws.atlhor2
       from datmsrvext1
      where atdsrvnum = ws.atdsrvnum
        and atdsrvano = ws.atdsrvano
        and lignum    = param.lignum

   if ws.ligdat is not null then
      let d_ctn47c02.atmstt1 = 0
      let d_ctn47c02.data1   = ws.ligdat
      let d_ctn47c02.hora1   = ws.lighorinc
      let d_ctn47c02.descr1  = "ACIONADO"
   end if
   if ws.atldat is not null then
      let d_ctn47c02.atmstt2 = 1
      let d_ctn47c02.data2  = ws.atldat
      let d_ctn47c02.hora2  = ws.atlhor
      let d_ctn47c02.descr2 = "CONSULTA CARGLASS"
   end if
   if ws.atldat1 is not null then
      let d_ctn47c02.atmstt3 = 2
      let d_ctn47c02.data3   = ws.atldat1
      let d_ctn47c02.hora3   = ws.atlhor1
      let d_ctn47c02.descr3  = "CONTANTO O SEGURADO"
   end if
   if ws.atldat2 is not null then
      let d_ctn47c02.atmstt4 = 3
      let d_ctn47c02.data4   = ws.atldat2
      let d_ctn47c02.hora4   = ws.atlhor2
      let d_ctn47c02.descr4  = "ENCERRADO"
   end if
   message " (F17)Abandona "

   display by name d_ctn47c02.*
   prompt "Pressione qq tecla para sair." for char ws.resp

   let int_flag = false

   close window w_ctn47c02a

 end function

