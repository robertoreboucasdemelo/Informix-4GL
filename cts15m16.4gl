#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts15m16                                                   #
# Analista Resp : Roberto Reboucas                                           #
#                 Tela de confirmação de Envio de locação                    #
#............................................................................#
# Desenvolvimento: Amilton Pinto / Meta                                      #
# Liberacao      : 22/10/2010                                                #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica  Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#
############################################################################# 


globals  "/homedsa/projetos/geral/globals/glct.4gl"
#globals "/projetos/fornax/D0609511/central/marco/glct.4gl" 

#-----------------------------------------------------------------------
 function cts15m16(lr_param)
#-----------------------------------------------------------------------

 define lr_param record 
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
 end record        

 define d_cts15m16   record    
    msg1             char (50),
    msg2             char (50)
 end record
 

 initialize d_cts15m16.*  to null

 call cts15m00_recupera_msg()
 returning d_cts15m16.msg1,
           d_cts15m16.msg2  
 
 open window cts15m16 at 11,17 with form "cts15m16"
             attribute (form line 1, border)
 
#-----------------------------------------------------------------------
# Verifica se documento foi informado (laudo em branco)
#-----------------------------------------------------------------------

 input by name d_cts15m16.msg1   ,
               d_cts15m16.msg2 without defaults

   

   before field msg1
          display by name d_cts15m16.msg1      attribute (reverse)

   after  field msg1
          display by name d_cts15m16.msg1                    

   before field msg2
          display by name d_cts15m16.msg2      attribute (reverse)

   after  field msg2
          display by name d_cts15m16.msg2
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field msg1
          end if

   on key (interrupt)
      exit input

 end input

 if not int_flag  then    
    if d_cts15m16.msg1  is not null    or
       d_cts15m16.msg2  is not null    then       
       call cts15m16_hist(lr_param.atdsrvnum, lr_param.atdsrvano,
                          d_cts15m16.msg1, d_cts15m16.msg2)
    end if      
 end if

 let int_flag = false
 close window cts15m16
 
 return d_cts15m16.msg1,d_cts15m16.msg2

end function  ###  cts15m16



#-----------------------------------------------------------------------
 function cts15m16_hist(hist)
#-----------------------------------------------------------------------

 define hist     record
    atdsrvnum    like datmservico.atdsrvnum,
    atdsrvano    like datmservico.atdsrvano,
    msg1         char(50)                  ,
    msg2         char(50)
 end record

 define ws       record
    c24txtseq    like datmservhist.c24txtseq,
    time         char(08),
    hora         char(05),
    msg          char(50)
 end record

 define l_ret      smallint,
        l_mensagem char(60)

        initialize  ws.*  to  null

let ws.time = time
let ws.hora = ws.time[1,5]
    
    call ctd07g01_ins_datmservhist(hist.atdsrvnum,
                                   hist.atdsrvano,
                                   g_issk.funmat,
                                   hist.msg1,
                                   today,
                                   ws.hora,
                                   g_issk.empcod,
                                   g_issk.usrtip)

         returning l_ret,
                   l_mensagem

    if l_ret <> 1 then
       error l_mensagem, " - cts15m16 - AVISE A INFORMATICA!"
       return
    end if
    
    call ctd07g01_ins_datmservhist(hist.atdsrvnum,
                                   hist.atdsrvano,
                                   g_issk.funmat,
                                   hist.msg2,
                                   today,
                                   ws.hora,
                                   g_issk.empcod,
                                   g_issk.usrtip)

         returning l_ret,
                   l_mensagem

    if l_ret <> 1 then
       error l_mensagem, " - cts15m16 - AVISE A INFORMATICA!"       
       return
    end if

    if sqlca.sqlcode <> 0 then
       error " Erro (", sqlca.sqlcode, ") na inclusao do historico! AVISE A INFORMATICA!"       
       return
    end if 

end function  ### cts15m16_hist
