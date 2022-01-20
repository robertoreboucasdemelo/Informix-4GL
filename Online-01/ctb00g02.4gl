#############################################################################
# Nome do Modulo: CTB00G02                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Funcao generica para verificacao do endereco e-mail              Jan/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

#---------------------------------------------------------
 function ctb00g02(ws_maides)
#---------------------------------------------------------

 define ws_maides  char (50)
 define ws_x       integer
 define ws_y       integer

 define ws         record
    varok          char (50),
    fglok          char (01),
    ctarroba       smallint
 end record


 let ws.varok     = "ABCDEFGHIJKLMNOPQRSTUVXWYZ0123456789.@-_"
 let ws.fglok     = "0"
 let ws.ctarroba  =  0
 let ws_x         = length(ws_maides)

 if ws_x < 6 then
    let ws.fglok = "1"
 else
    if ws_maides[1,1] = "." or ws_maides[1,1] = "@" then
       let ws.fglok = "1"
    else
#      if ws_maides[ws_x -2 ,ws_x] <> ".br" then
#         let ws.fglok = "1"
#      else
          for ws_x = 1 to length(ws_maides)
             let ws.fglok = "1"
             for ws_y = 1 to length(ws.varok)
                if upshift(ws_maides[ws_x,ws_x]) = ws.varok[ws_y,ws_y] then
                   let ws.fglok = "0"
                   exit for
                end if
             end for
             if ws_maides[ws_x,ws_x] = "@"  then
                if ws.ctarroba >= 1 then
                   let ws.fglok = "1"
                else
                   let ws.ctarroba = ws.ctarroba + 1
                end if
                if ws_maides[ws_x-1,ws_x-1] = "."     then
                   let ws.fglok = "1"
                else
                   if ws_maides[ws_x+1,ws_x+1] = "."  then
                      let ws.fglok = "1"
                   end if
                end if
             end if
             if ws.fglok = "1" then
                exit for
             end if
          end for
          if ws.ctarroba  = 0 then
             let ws.fglok = "1"
          end if
#      end if
    end if
 end if

 return ws.fglok

end function # e_mail

