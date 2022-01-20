#----------------------------------------------------------------------------
#  BDATR984.4gl - Extrai historico das reclamacoes W02, W04, W06
#----------------------------------------------------------------------------
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

 database porto

 main
    call fun_dba_abre_banco("CT24HS") 
    set isolation to dirty read
    call bdatr984()
 end main


#---------------------------------------------------------------
 function bdatr984()   
#---------------------------------------------------------------

 define d_bdatr984    record
    lignum            like datmligacao.lignum   ,
    ligdat            like datmligacao.ligdat   , 
    c24astcod         like datmligacao.c24astcod, 
    c24rclsitcod      like datmsitrecl.c24rclsitcod
 end record

 initialize d_bdatr984.*  to null

 #---------------------------------------------------------------
 # Cursor principal 
 #---------------------------------------------------------------
 declare c_datmservico cursor for           
    select datmligacao.lignum   ,
           datmligacao.ligdat   ,
           datmligacao.c24astcod   
      from datmligacao
     where datmligacao.ligdat    between  "01/02/2000"  and "31/03/2000"
       and datmligacao.c24astcod in ("W02", "W04", "W06")

 start report  rel_recl  to  "/rdat/RDAT98401" 

 foreach c_datmservico  into  d_bdatr984.lignum , 
                              d_bdatr984.ligdat , 
                              d_bdatr984.c24astcod  

    select max(c24rclsitcod) 
      into d_bdatr984.c24rclsitcod
      from datmsitrecl 
     where lignum  =  d_bdatr984.lignum 
              
    if d_bdatr984.c24rclsitcod is not null and
       d_bdatr984.c24rclsitcod   =  0      or
       d_bdatr984.c24rclsitcod   =  1      then   

       output to report rel_recl(d_bdatr984.*)  

    end if

    initialize d_bdatr984.*         to null

 end foreach

 finish report  rel_recl 

end function  ###  bdatr984


#---------------------------------------------------------------------------
 report rel_recl(r_bdatr984)
#---------------------------------------------------------------------------


 define r_bdatr984   record
    lignum            like datmligacao.lignum   ,
    ligdat            like datmligacao.ligdat   , 
    c24astcod         like datmligacao.c24astcod, 
    c24rclsitcod      like datmsitrecl.c24rclsitcod
 end record

 define h_bdatr984   record
    c24ligdsc        like datmlighist.c24ligdsc,
    c24funmat        like datmlighist.c24funmat,
    ligdat           like datmlighist.ligdat   ,
    lighorinc        like datmlighist.lighorinc 
 end record

 define ws           record     
    descrecl         char(50),
    descsit          char(50),
    funnom           like isskfunc.funnom       ,
    c24ligdsc        like datmlighist.c24ligdsc,
    ligdat           like datmlighist.ligdat   ,
    lighorinc        like datmlighist.lighorinc
 end record

 define flag_hist       smallint

 output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdatr984.c24astcod,
             r_bdatr984.lignum   

   format
      first page header
           print column 001, "RDAT98401",
                 column 040, "DATA: ", today,  
                 column 067, "PAGINA: ", pageno using "####&"
           print column 014, "RELATORIO DE RECLAMACOES PENDENTES OU EM ANALISE DE 2000"
           skip 1 lines


      before group of r_bdatr984.lignum  
           skip 1 line
           case r_bdatr984.c24astcod
             when "W02"
                 let ws.descrecl = "ATENDIMENTO PRESTADOR"
             when "W04"
                 let ws.descrecl = "ATRASO NA CHEGADA DO PRESTADOR"
             when "W06"
                 let ws.descrecl = "CARRO EXTRA"
           end case
           case r_bdatr984.c24rclsitcod
             when 0       
                 let ws.descsit = "PENDENTE"                
             when 1       
                 let ws.descsit = "EM ANALISE"                
           end case

           print column 001, "RECLAMACAO..: ", r_bdatr984.c24astcod," - ",
                                               ws.descrecl
           print column 001, "SITUACAO....: ", r_bdatr984.c24rclsitcod using "##&",
                                               " - ", ws.descsit   
           print column 001, "NR.LIGACAO..: ", r_bdatr984.lignum
           print column 001, "DATA........: ", r_bdatr984.ligdat

      after  group of r_bdatr984.lignum
           initialize  ws.ligdat ,ws.lighorinc to null 
           let  flag_hist = 0   
           print column 001, "HISTORICO...:" 

           declare c_historico cursor for  
            select ligdat   , lighorinc,
                   c24funmat, c24ligdsc 
              from datmlighist    
             where lignum = r_bdatr984.lignum

           foreach c_historico into  h_bdatr984.ligdat   ,
                                     h_bdatr984.lighorinc,
                                     h_bdatr984.c24funmat,
                                     h_bdatr984.c24ligdsc 

              if ws.ligdat    is null                  or
                 ws.ligdat    <> h_bdatr984.ligdat     or
                 ws.lighorinc <> h_bdatr984.lighorinc  then
                 select funnom 
                   into ws.funnom 
                   from isskfunc 
                   where funmat = h_bdatr984.c24funmat
                     and empcod = 1
        
                 let ws.c24ligdsc = "EM: "   , h_bdatr984.ligdat    clipped,
                                    "  AS: " , h_bdatr984.lighorinc clipped,
                                    "  POR: ", ws.funnom            clipped
                 let ws.ligdat    = h_bdatr984.ligdat         
                 let ws.lighorinc = h_bdatr984.lighorinc      
     
                 if flag_hist = 1 then
                    skip 1 lines
                 end if
                 
                 print column 009, ws.c24ligdsc          

              end if
   
              print column 009, h_bdatr984.c24ligdsc


           end foreach               

           if flag_hist = 0 then
              print column 015, " " 
              skip 1 lines
           end if
   
end report  ###  


