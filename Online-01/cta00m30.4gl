#----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                            # 
#............................................................................# 
# Sistema........: Auto e RE - Itau Seguros                                  # 
# Modulo.........: cta00m30                                                  # 
# Objetivo.......: Replica Advertencia nos Itens da Apolice do Itau          # 
# Analista Resp. : Roberto Melo                                              # 
# PSI            :                                                           # 
#............................................................................# 
# Desenvolvimento: Roberto Melo                                              # 
# Liberacao      : 09/05/2011                                                # 
#............................................................................# 
                                                                               
                                                                               
database porto                                                                 
                                                                               
globals "/homedsa/projetos/geral/globals/glct.4gl"                             


 database porto

 define m_prepare smallint

 define hrr_aux   smallint

 define mh_cta00m30 array[300] of record
    c24ligdsc      like datmlighist.c24ligdsc
 end record

 define ma_cta00m30 array[1000] of record
    marca1        char(01)                         ,
    seta          char(01)                         ,
    marca2        char(01)                         ,
    itaaplitmnum  like datmitaaplitm.itaaplitmnum  ,
    vcldes        char (35)                        ,
    autplcnum     like datmitaaplitm.autplcnum 
 end record

#----------------------------------------------#
 function cta00m30_prepare()
#----------------------------------------------#

define l_sql char(500)

 let l_sql = " select itaaplitmnum, " ,           
             "         autplcnum  , " ,           
             "         autfbrnom  , " ,           
             "         autlnhnom  , " ,           
             "         autmodnom    " ,           
             " from datmitaaplitm "   ,           
             " where itaciacod = ? "  ,           
             " and   itaramcod = ? "  ,           
             " and   itaaplnum = ? "  ,           
             " and   aplseqnum = ? "              
 prepare p_cta00m30_001  from l_sql               
 declare c_cta00m30_001  cursor for p_cta00m30_001
 
 let l_sql = "select c24ligdsc      ",
             "  from datmlighist    ",
             "  where lignum = ?    ",
             "  order by c24txtseq  "
 prepare p_cta00m30_002 from l_sql
 declare c_cta00m30_002 cursor for p_cta00m30_002
 
 let l_sql = " select count(*)     " ,                            
             " from datmitaaplitm  "   ,           
             " where itaciacod = ? "  ,           
             " and   itaramcod = ? "  ,           
             " and   itaaplnum = ? "  ,           
             " and   aplseqnum = ? "              
 prepare p_cta00m30_003  from l_sql               
 declare c_cta00m30_003  cursor for p_cta00m30_003
 
  
 let m_prepare = true

end function


#----------------------------------------------#
 function cta00m30(lr_param)
#----------------------------------------------#


define lr_param record                                
   itaciacod     like datmitaapl.itaciacod       ,    
   itaramcod     like datmitaapl.itaramcod       ,    
   itaaplnum     like datmitaapl.itaaplnum       ,    
   aplseqnum     like datmitaapl.aplseqnum       , 
   succod        like datmitaapl.succod          ,
   funmat        like isskfunc.funmat            ,    
   data          date                            ,    
   hora          datetime hour to second         ,    
   c24atrflg     like datkassunto.c24atrflg      ,    
   c24jstflg     like datkassunto.c24jstflg      ,    
   funnom        like isskfunc.funnom            ,    
   lignum        like datmligacao.lignum             
end record                                            


define lr_retorno   record
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
   autfbrnom     like datmitaaplitm.autfbrnom    , 
   autlnhnom     like datmitaaplitm.autlnhnom    , 
   autmodnom     like datmitaaplitm.autmodnom    ,   
   obs           char(70)                        ,
   minimo        smallint                        ,
   maximo        smallint
end record

define aux_cta00m30 array[1000] of record
   seta1      char(01)
end record


define arr_aux       smallint,
       scr_aux       smallint,
       arr_aux1      smallint,
       arr_aux2      smallint,
       arr_cou       smallint,
       scr_count     smallint
  
  for  arr_aux  =  1  to  1000
     initialize  ma_cta00m30[arr_aux].*          ,
                 aux_cta00m30[arr_aux].* to  null
  end  for
 
  let arr_aux = null

  initialize lr_retorno.* to null


  if m_prepare is null or
     m_prepare <> true then
     call cta00m30_prepare()
  end if
 
 message " Aguarde, pesquisando..." attribute (reverse)

 let arr_aux   = 1
 let arr_aux1  = 1
 let arr_cou   = null
 let scr_count = 9

  open c_cta00m30_001 using lr_param.itaciacod,                                 
                            lr_param.itaramcod,                                 
                            lr_param.itaaplnum,                                 
                            lr_param.aplseqnum                                  
                                                                                
  foreach c_cta00m30_001 into ma_cta00m30[arr_aux].itaaplitmnum ,                  
                              ma_cta00m30[arr_aux].autplcnum    ,                  
                              lr_retorno.autfbrnom              ,                  
                              lr_retorno.autlnhnom              ,                  
                              lr_retorno.autmodnom                              
                                                                                
        # Despreza o Item Original                                    
        if  ma_cta00m30[arr_aux].itaaplitmnum = g_documento.itmnumdig then  
            continue foreach                                          
        end if                                                        
        
        
        let ma_cta00m30[arr_aux].vcldes = lr_retorno.autfbrnom clipped, " ",      
                                          lr_retorno.autlnhnom clipped, " ",      
                                          lr_retorno.autmodnom clipped            
                                                                                
        let ma_cta00m30[arr_aux].marca1    = "("
        let ma_cta00m30[arr_aux].marca2    = ")"
        
        let arr_aux = arr_aux + 1                                                 
                                                                                
        if arr_aux > 1000 then                                                  
           message "Limite excedido. Foram Encontrados mais de 1000 Itens!"     
           exit foreach                                                         
        end if                                                                  
                                                                                
  end foreach                                                                    

  message " "

 if arr_aux > 1  then
      
       call set_count(arr_aux - 1)
      
       let lr_retorno.obs =  "(F17)Abandona,(F8)Replica,(F9)Marca Todos,(F10)Desmarca Todos"

       open window cta00m30 at 07,14 with form "cta00m30"
                   attribute(border, form line first)
       
       options insert   key F40
       options delete   key F35
       options next     key F30
       options previous key F25
       display by name lr_retorno.obs

       input array ma_cta00m30 without defaults from s_cta00m30.*
         
         before row
              let arr_aux  = arr_curr()
              let scr_aux  = scr_line()
              let arr_cou  = arr_count()
         
         after field seta
          if  fgl_lastkey() <> fgl_keyval("down") and
              fgl_lastkey() <> fgl_keyval("up")   and
              fgl_lastkey() <> fgl_keyval("left") and
              fgl_lastkey() <> fgl_keyval("right")then
              
              if ma_cta00m30[arr_aux].seta <> "X" and
                 ma_cta00m30[arr_aux].seta is not null then
                   error "Tecle <ENTER> para Marcar ou Desmarcar!"
                   let ma_cta00m30[arr_aux].seta   = null
                   let aux_cta00m30[arr_aux].seta1 = null
                   display  ma_cta00m30[arr_aux].seta to s_cta00m30[scr_aux].seta
                   next field seta
              end if
              
              if ma_cta00m30[arr_aux].seta is null then
                  let ma_cta00m30[arr_aux].seta   = "X"
                  let aux_cta00m30[arr_aux].seta1 = "X"
                  display  ma_cta00m30[arr_aux].seta to s_cta00m30[scr_aux].seta
              else
                  let ma_cta00m30[arr_aux].seta   = null
                  let aux_cta00m30[arr_aux].seta1 = null
                  display  ma_cta00m30[arr_aux].seta to s_cta00m30[scr_aux].seta
              end if
              
              if arr_curr() = arr_count() then
                 next field seta
              end if
          
          else
              if fgl_lastkey() <> fgl_keyval("left") and
                 fgl_lastkey() <> fgl_keyval("up")   then
                    if arr_curr() = arr_count() then
                       next field seta
                    end if
              end if
              
              if ma_cta00m30[arr_aux].seta <> "X" and
                 ma_cta00m30[arr_aux].seta is not null then
                   
                   error "Tecle <ENTER> para Marcar ou Desmarcar!"
                   let ma_cta00m30[arr_aux].seta   = null
                   let aux_cta00m30[arr_aux].seta1 = null
                   display  ma_cta00m30[arr_aux].seta to s_cta00m30[scr_aux].seta
                   next field seta
              
              else
                  if (aux_cta00m30[arr_aux].seta1 is null and
                      ma_cta00m30[arr_aux].seta   is not null) or
                     (aux_cta00m30[arr_aux].seta1 is not null  and
                      ma_cta00m30[arr_aux].seta   is null)     then
                      
                      error "Tecle <ENTER> para Marcar ou Desmarcar!"
                      let ma_cta00m30[arr_aux].seta = aux_cta00m30[arr_aux].seta1
                      display  ma_cta00m30[arr_aux].seta to s_cta00m30[scr_aux].seta
                      next field seta
                  
                  end if
              end if
          end if
         
         on key (F8)
            
            # Recupera o Historico da Ligação Original
            if not cta00m30_recupera_historico(lr_param.lignum) then
                 exit input
            end if
            
            # Replica a Ligacao para os Itens Selecionados
            call cta00m30_replica(arr_cou             ,
                                  lr_param.itaciacod  ,
                                  lr_param.itaramcod  ,
                                  lr_param.itaaplnum  ,
                                  lr_param.aplseqnum  ,
                                  lr_param.succod     ,
                                  lr_param.funmat     ,
                                  lr_param.data       ,
                                  lr_param.hora       ,
                                  lr_param.c24atrflg  ,
                                  lr_param.c24jstflg  ,
                                  lr_param.funnom     )
         
         on key (F9)
           let arr_aux2  = 1
           
           # Calcula quais os Delimitadores a serem Marcados
           call cta00m30_delimitadores(scr_aux  ,
                                       arr_aux  ,
                                       scr_count)
           returning lr_retorno.minimo,
                     lr_retorno.maximo
           
           # Carrega Todos os Arrays
           for  arr_aux1  =  1  to  arr_count()
               let ma_cta00m30[arr_aux1].seta   = "X"
               let aux_cta00m30[arr_aux1].seta1 = "X"
           end for
           
           # Marca o "X" nos Campos da Tela
           for arr_aux1  = lr_retorno.minimo to lr_retorno.maximo
               display  ma_cta00m30[arr_aux1].seta to s_cta00m30[arr_aux2].seta
               let arr_aux2 = arr_aux2 + 1
           end for
           
           on key (F10)
             let arr_aux2  = 1
             
             # Calcula quais os Delimitadores a serem Desmarcados
             call cta00m30_delimitadores(scr_aux  ,
                                         arr_aux  ,
                                         scr_count)
             returning lr_retorno.minimo,
                       lr_retorno.maximo
             
             # Descarrega Todos os Arrays
             for  arr_aux1  =  1  to  arr_count()
                 let ma_cta00m30[arr_aux1].seta   = null
                 let aux_cta00m30[arr_aux1].seta1 = null
             end for
             
             # Desmarca o "X" nos Campos da Tela
             for arr_aux1  = lr_retorno.minimo to lr_retorno.maximo
                 display  ma_cta00m30[arr_aux1].seta to s_cta00m30[arr_aux2].seta
                 let arr_aux2 = arr_aux2 + 1
             end for
         
         on key (interrupt)
            initialize ma_cta00m30  to null
            exit input
       end input

       close window cta00m30
 end if

 return

end function

#----------------------------------------------#
 function cta00m30_recupera_historico(lr_param)
#----------------------------------------------#

define lr_param record
   lignum    like datmligacao.lignum
end record



     if m_prepare is null or
        m_prepare <> true then
        call cta00m30_prepare()
     end if

     for     hrr_aux  =  1  to  300
             initialize  mh_cta00m30[hrr_aux].*  to  null
     end     for

     let hrr_aux = 1

     open c_cta00m30_002 using lr_param.lignum

     foreach c_cta00m30_002 into mh_cta00m30[hrr_aux].c24ligdsc
       
       let hrr_aux = hrr_aux + 1
       if hrr_aux > 300 then
          exit foreach
       end if

     end foreach
     
     if hrr_aux = 1 then
        error "Erro ao Recuperar o Historico!"
        return false
     end if
     
     let hrr_aux = hrr_aux - 1
     
     return true


end function

#----------------------------------------------#
 function cta00m30_delimitadores(lr_param)
#----------------------------------------------#

define lr_param record
   arr_tela     smallint ,
   arr_corrente smallint ,
   arr_total    smallint
end record

define lr_retorno record
   minimo smallint ,
   maximo smallint
end record

initialize lr_retorno.* to null

   let lr_retorno.minimo = (lr_param.arr_corrente - lr_param.arr_tela) + 1
   let lr_retorno.maximo = (lr_param.arr_total - lr_param.arr_tela) + lr_param.arr_corrente

   return lr_retorno.*

end function


#----------------------------------------------#
 function cta00m30_replica(lr_param)
#----------------------------------------------#

define lr_param record
   qtd           smallint                   ,
   itaciacod     like datmitaapl.itaciacod  , 
   itaramcod     like datmitaapl.itaramcod  , 
   itaaplnum     like datmitaapl.itaaplnum  , 
   aplseqnum     like datmitaapl.aplseqnum  , 
   succod        like datmitaapl.succod     ,
   funmat        like isskfunc.funmat       ,
   data          date                       ,
   hora          datetime hour to second    ,
   c24atrflg     like datkassunto.c24atrflg ,
   c24jstflg     like datkassunto.c24jstflg ,
   funnom        like isskfunc.funnom
end record

define lr_retorno record
   lignum       like datmligacao.lignum ,
   ramnom       like gtakram.ramnom     ,
   ramsgl       char(15)                ,
   confirma     smallint                ,
   mensagem     char(60)                ,
   mensagem_aux char(60)                ,
   erro         smallint
end record

define lr_ant record
   itaaplitmnum  like datmitaaplitm.itaaplitmnum    ,
   aplseqnum     like datmitaapl.aplseqnum
end record

define arr_aux     smallint
define arr_aux1    smallint
define l_acesso    smallint
define l_replicado smallint

initialize lr_retorno.*  ,
           lr_ant.*      ,
           g_rep_lig     to null


let arr_aux              = null
let arr_aux1             = null
let l_replicado          = 0
let g_rep_lig            = true
let l_acesso             = false
let lr_ant.itaaplitmnum  = g_documento.itmnumdig
let lr_ant.aplseqnum     = g_documento.edsnumref
  
  
    for  arr_aux  =  1  to  lr_param.qtd
       
       let lr_retorno.erro   = 0
       
       error "Aguarde... Replicando Item ", ma_cta00m30[arr_aux].itaaplitmnum
       
       if ma_cta00m30[arr_aux].seta is not null  then
           
           let l_acesso = true     
           
           # Grava Ligacao
           if lr_retorno.erro = 0 then
               
               let g_documento.itmnumdig = ma_cta00m30[arr_aux].itaaplitmnum
               
               call cta02m00_grava(lr_param.c24atrflg
                                  ,lr_param.c24jstflg
                                  ,lr_param.funnom)
                returning lr_retorno.confirma,
                          lr_retorno.lignum
               
               if lr_retorno.confirma = false then
                  let lr_retorno.erro = 1
               end if
                   
           end if
           
           # Grava Historico
           if lr_retorno.erro = 0 then
             
             begin work
                for  arr_aux1  =  1  to  hrr_aux
                     call ctd06g01_ins_datmlighist(lr_retorno.lignum                ,
                                                   lr_param.funmat                  ,
                                                   mh_cta00m30[arr_aux1].c24ligdsc   ,
                                                   lr_param.data                    ,
                                                   lr_param.hora                    ,
                                                   g_issk.usrtip                    ,
                                                   g_issk.empcod                    )
                     returning lr_retorno.confirma  ,
                               lr_retorno.mensagem
                     
                      if lr_retorno.confirma <> 1 then
                         let lr_retorno.erro = 1
                         rollback work
                         exit for
                      end if
                
                end for
          
           end if
           
           # Grava Atendimento
           if lr_retorno.erro = 0 then
               
               if g_documento.atdnum is not null and
                  g_documento.atdnum <> 0       then
                  
                  let lr_retorno.mensagem_aux = "PRI - cta00m30 1 - chamando ctd25g00"
                  call errorlog(lr_retorno.mensagem_aux)
                  
                  call ctd25g00_insere_atendimento(g_documento.atdnum
                                                  ,lr_retorno.lignum )
                       returning lr_retorno.confirma  ,
                                 lr_retorno.mensagem
                  
                  if lr_retorno.confirma <> 0 then
                     let lr_retorno.erro = 1
                     rollback work
                  end if
               end if
           
           end if
            
            # Se deu Erro Exibe Mensagem
            if lr_retorno.erro <> 0 then
               error lr_retorno.mensagem , " Item ", ma_cta00m30[arr_aux].itaaplitmnum sleep 3
            else
               let l_replicado = l_replicado + 1
               commit work
            end if
       end if
       
       if not l_acesso then
          error "Selecione Algum Item!"
       else
          error l_replicado, " Iten(s) Replicado(s) com Sucesso. Tecle <CTRL-C> para Sair!"
       end if
    
    end for
    
    let g_documento.itmnumdig  = lr_ant.itaaplitmnum
    let g_documento.edsnumref  = lr_ant.aplseqnum
    let g_rep_lig              = false

end function

#------------------------------------------------------------------------------   
function cta00m30_recupera_qtd(lr_param)                                
#------------------------------------------------------------------------------   
                                                                                  
define lr_param record                         
   itaciacod     like datmitaapl.itaciacod  ,  
   itaramcod     like datmitaapl.itaramcod  ,  
   itaaplnum     like datmitaapl.itaaplnum  ,  
   aplseqnum     like datmitaapl.aplseqnum                              
end record                                                                        
                                                                                  
define lr_retorno record                                                                                          
 qtd   integer                                                                                                                              
end record                                                                        
                                                                                  
if m_prepare is null or                                                           
   m_prepare <> true then                                                         
   call cta00m30_prepare()                                                        
end if                                                                            
                                                                                  
initialize lr_retorno.* to null                                                   
                                                                                  
   open c_cta00m30_003 using lr_param.itaciacod,                           
                             lr_param.itaramcod,                           
                             lr_param.itaaplnum, 
                             lr_param.aplseqnum                                                     
   whenever error continue                                                        
   fetch c_cta00m30_003 into lr_retorno.qtd                                    
                                                          
   whenever error stop                                                            
   close c_cta00m30_003                                                          
                                                                                                                                                                    
   return lr_retorno.qtd                                                        
                                                   
                                                                                  
end function                                                                      