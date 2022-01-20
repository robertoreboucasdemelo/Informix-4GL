###############################################################################
# Nome do Modulo: cto00m11                                    Helder Oliveira #
#                                                                             #
# Postos C.A.R.                                                      Abr/2011 #
###############################################################################
#                             ALTERACOES                                      #
#                             ----------                                      #
# Data         Autor         PSI             Descrição                        #
# -----------  ------------- -------------   -------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#
#                                                                             #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_cto00m11_prep       smallint

  define r_cto00m11 record
         atdcencod  like datkrpdatdcen.atdcencod
       , atdcennom  like datkrpdatdcen.atdcennom
       , atdcenltt  like datkrpdatdcen.atdcenltt
       , atdcenlgt  like datkrpdatdcen.atdcenlgt
  end record
  
  define m_index    smallint
  
   define param record
       ltt like datkrpdatdcen.atdcenltt
     , lgt like datkrpdatdcen.atdcenlgt
 end record
   
   define r_return record
        carnom      char(100)
       ,lgdtip      like datkrpdatdcen.lgdtipdes
       ,lgdnom      like datkrpdatdcen.lgdnom   
       ,lgdnum      like datkrpdatdcen.lgdnum
       ,brrnom      like datkrpdatdcen.brrnom
       ,cidnom      like datkrpdatdcen.cidnom
       ,ufdcod      like datkrpdatdcen.endufdsgl
       ,lgdcep      char(5)
       ,lgdcepcmp   char(3)
       ,endlgdcmp   like datkrpdatdcen.endcmpdes
       ,lclltt      like datkrpdatdcen.atdcenltt
       ,lcllgt      like datkrpdatdcen.atdcenlgt
       ,lclcttnom   char(100) # nome responsavel
       ,dddcod      like datkrpdatdcen.teldddnum
       ,lcltelnum   like datkrpdatdcen.telnum
       ,lclidttxt   char(100) # referencia do local - nao existe no cadastro 18/05/11
       ,stt         smallint
   end record
   
   define  l_cep       like datkrpdatdcen.cepnum
   define  l_lgdcepcmp like datkrpdatdcen.cepcmpnum

#===============================================================================
function cto00m11_prepare()
#===============================================================================
 define l_sql char(1000)

 let l_sql = ' select atdcencod     '
           , '      , atdcennom     '
           , '      , atdcenltt     '
           , '      , atdcenlgt     '
           , '   from datkrpdatdcen '
           , '  where atoflg = "S"  '
 prepare p_cto00m11_001 from l_sql
 declare c_cto00m11_001 cursor for p_cto00m11_001

 let l_sql = ' insert into tmp_cto00m11               '
           , ' ( atdcencod ,atdcennom ,dist_total )   '
           , ' values (?,?,?)                         '
 prepare p_cto00m11_002 from l_sql

  let l_sql = ' select atdcencod     '
            , '       , atdcennom     '
            , '       , dist_total    '
            , '    from tmp_cto00m11  '
            , '   order by dist_total '
 prepare p_cto00m11_003 from l_sql
 declare c_cto00m11_003 cursor for p_cto00m11_003

 let l_sql = ' select rspempcod     '
            ,'      , rspfunmat     '
            ,'      , lgdtipdes     '   
            ,'      , lgdnom        '   
            ,'      , lgdnum        '   
            ,'      , brrnom        '   
            ,'      , cidnom        '   
            ,'      , endufdsgl     '   
            ,'      , cepnum        '   
            ,'      , cepcmpnum     '   
            ,'      , endcmpdes     '   
            ,'      , atdcenltt     '   
            ,'      , atdcenlgt     '   
            ,'      , teldddnum     '    
            ,'      , telnum        '   
            ,'   from datkrpdatdcen '   
            ,'  where atdcencod = ? '
 prepare p_cto00m11_004 from l_sql
 declare c_cto00m11_004 cursor for p_cto00m11_004

 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
 prepare p_cto00m11_005 from l_sql
 declare c_cto00m11_005 cursor for p_cto00m11_005

 let l_sql = ' select rspempcod     '
            ,'      , rspfunmat     '
            ,'      , lgdtipdes     '   
            ,'      , lgdnom        '   
            ,'      , lgdnum        '   
            ,'      , brrnom        '   
            ,'      , cidnom        '   
            ,'      , endufdsgl     '   
            ,'      , cepnum        '   
            ,'      , cepcmpnum     '   
            ,'      , endcmpdes     '   
            ,'      , atdcenltt     '   
            ,'      , atdcenlgt     '   
            ,'      , teldddnum     '    
            ,'      , telnum        ' 
            ,'      , atdinchor     ' #
            ,'      , atdfnlhor     ' #
            ,'      , atdsemdiades  ' #
            ,'   from datkrpdatdcen '   
            ,'  where atdcencod = ? '
 prepare p_cto00m11_006 from l_sql
 declare c_cto00m11_006 cursor for p_cto00m11_006

 let m_cto00m11_prep = 1

end function

#===============================================================================
function cto00m11(l_ltt, l_lgt)
#===============================================================================
define l_ltt like datkrpdatdcen.atdcenltt
define l_lgt like datkrpdatdcen.atdcenlgt

 let param.ltt = l_ltt
 let param.lgt = l_lgt

 let m_index = 1
 initialize r_cto00m11.* to null
 initialize r_return.* to null
 
 let r_return.stt = false

  open window w_cto00m11 at 8,10 with form 'cto00m11'
             attribute(form line first,message line last,comment line last - 1, border )

  display 'POSTOS C.A.R. POR PROXIMIDADE' at 1,18
  
  message '  (F8)-Escolhe   (F10)-Endereco   (F17)-Abandona'
  
  call cto00m11_cria_temp()
 
  call cto00m11_prepare()
 
  call cto00m11_pesquisa()
  
  close window w_cto00m11
  
  drop table tmp_cto00m11
      
  display ' carnom    ', r_return.carnom   
  display ' lgdtip    ', r_return.lgdtip      
  display ' lgdnom    ', r_return.lgdnom      
  display ' lgdnum    ', r_return.lgdnum      
  display ' brrnom    ', r_return.brrnom      
  display ' cidnom    ', r_return.cidnom      
  display ' ufdcod    ', r_return.ufdcod      
  display ' lgdcep    ', r_return.lgdcep      
  display ' lgdcepcmp ', r_return.lgdcepcmp   
  display ' endlgdcmp ', r_return.endlgdcmp   
  display ' lclltt    ', r_return.lclltt      
  display ' lcllgt    ', r_return.lcllgt      
  display ' lclcttnom ', r_return.lclcttnom   
  display ' dddcod    ', r_return.dddcod      
  display ' lcltelnum ', r_return.lcltelnum   
  display ' lclidttxt ', r_return.lclidttxt  
  display ' stt       ', r_return.stt    
      
  return r_return.*
   
end function 

#===============================================================================
function cto00m11_pesquisa()
#===============================================================================
define l_dist_total  decimal(8,3)
define l_empcod  like datkrpdatdcen.rspempcod
define l_funmmat like datkrpdatdcen.rspfunmat


define la_cto00m11 array[1000] of record
       aux           char(1)
     , atdcencod     char(10)    
     , atdcennom     char(50)    
     , dist_total    char(15) #decimal(8,3)
end record

define arr_aux       smallint
define scr_aux       smallint
define i             smallint

 let i = 1
 initialize la_cto00m11 to null
 
 open c_cto00m11_001 
 
 foreach c_cto00m11_001 into r_cto00m11.atdcencod
                           , r_cto00m11.atdcennom
                           , r_cto00m11.atdcenltt
                           , r_cto00m11.atdcenlgt

   call cts18g00(param.ltt
                ,param.lgt
                ,r_cto00m11.atdcenltt
                ,r_cto00m11.atdcenlgt)
      returning l_dist_total
   
   
   execute p_cto00m11_002 using r_cto00m11.atdcencod 
                              , r_cto00m11.atdcennom 
                              , l_dist_total
   whenever error stop
     if sqlca.sqlcode <> 0 then
        error 'Erro INSERT tmp_cto00m11 / ', sqlca.sqlcode, ' / ' 
                                           ,r_cto00m11.atdcencod 
                                           ,r_cto00m11.atdcennom 
                                           ,l_dist_total
        exit foreach
     end if
   whenever error continue
   
 end foreach                            

 open c_cto00m11_003
 foreach c_cto00m11_003 into la_cto00m11[m_index].atdcencod
                           , la_cto00m11[m_index].atdcennom
                           , la_cto00m11[m_index].dist_total

                                
   let m_index = m_index + 1
   
   if m_index > 500 then
      error 'Numero de registros excedeu o limite de 500 registros!'
         exit foreach
   end if

 end foreach

 close c_cto00m11_003
 
 call set_count(m_index - 1)

  input array la_cto00m11 without defaults from s_cto00m11.*
     #-----------------------------------------------------------------------
        before row
     #-----------------------------------------------------------------------
           let arr_aux = arr_curr()
           let scr_aux = scr_line()
 
     #-----------------------------------------------------------------------
        before field aux 
     #-----------------------------------------------------------------------
           display la_cto00m11[arr_aux].* to s_cto00m11[scr_aux].* attribute(reverse)
     
     #-----------------------------------------------------------------------
        after field aux
     #-----------------------------------------------------------------------
           display la_cto00m11[arr_aux].* to s_cto00m11[scr_aux].*

           if fgl_lastkey() <> fgl_keyval("up")     and
              fgl_lastkey() <> fgl_keyval("left")   then
              
              if la_cto00m11[arr_aux+1].atdcencod is null then
                 next field aux
              end if
           end if
           
           let la_cto00m11[arr_aux].aux = ''
           display la_cto00m11[arr_aux].* to s_cto00m11[scr_aux].*
           
     #-----------------------------------------------------------------------
        on key(F8)
     #-----------------------------------------------------------------------
           whenever error continue
           open  c_cto00m11_004  using la_cto00m11[arr_aux].atdcencod
           fetch c_cto00m11_004  into  l_empcod
                                    ,  l_funmmat
                                    ,  r_return.lgdtip
                                    ,  r_return.lgdnom
                                    ,  r_return.lgdnum    
                                    ,  r_return.brrnom    
                                    ,  r_return.cidnom    
                                    ,  r_return.ufdcod    
                                    ,  l_cep    
                                    ,  l_lgdcepcmp 
                                    ,  r_return.endlgdcmp 
                                    ,  r_return.lclltt    
                                    ,  r_return.lcllgt    
                                    ,  r_return.dddcod    
                                    ,  r_return.lcltelnum 
          whenever error stop
    
          whenever error continue
           open c_cto00m11_005 using l_empcod
                                   , l_funmmat
           fetch c_cto00m11_005 into r_return.lclcttnom  # recebe nome do responsavel
          whenever error stop
              
          let r_return.lclidttxt = '' # referencia de local - nao tem no cadastro
          let r_return.stt = true
          
          let r_return.lgdcep     = l_cep       using '&&&&&'
          let r_return.lgdcepcmp  = l_lgdcepcmp using '&&&'
          
          let r_return.carnom     = la_cto00m11[arr_aux].atdcennom
          
          exit input
       
     #-----------------------------------------------------------------------
        on key(F10)
     #-----------------------------------------------------------------------
          # Mostra Endereco            
          call cto00m11_mostra_endereco(la_cto00m11[arr_aux].atdcencod,
                                        la_cto00m11[arr_aux].atdcennom)
          message '  (F8)-Escolhe   (F10)-Endereco   (F17)-Abandona'
          
     #-----------------------------------------------------------------------
        on key(control-c, interrupt)
     #-----------------------------------------------------------------------
           delete from tmp_cto00m11
           let r_return.stt = false
           exit input               
 
  end input
                      

end function

#===============================================================================
function cto00m11_cria_temp()
#===============================================================================
  
  create temp table tmp_cto00m11
  ( atdcencod   smallint      
   ,atdcennom   char(50)      
   ,dist_total  decimal(8,3)  
  ) with no log               
  create unique index idx_tmp_cto00m11 on tmp_cto00m11(atdcencod) 
   
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'Erro CREATE TEMP TABLE tmp_cto00m11 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
   end if

end function

#===============================================================================
function cto00m11_mostra_endereco(l_car, l_desc)
#===============================================================================
define l_car      like datkrpdatdcen.atdcencod
define l_desc     like datkrpdatdcen.atdcennom
define l_empcod   like datkrpdatdcen.rspempcod
define l_funmmat  like datkrpdatdcen.rspfunmat
define invisible  char(1)

define r_endereco record
       lgdtip        like datkrpdatdcen.lgdtipdes  
      ,lgdnom        like datkrpdatdcen.lgdnom     
      ,lgdnum        like datkrpdatdcen.lgdnum     
      ,brrnom        like datkrpdatdcen.brrnom     
      ,cidnom        like datkrpdatdcen.cidnom     
      ,ufdcod        like datkrpdatdcen.endufdsgl  
      ,cep           char(5)                       
      ,lgdcepcmp     char(3)                       
      ,endlgdcmp     like datkrpdatdcen.endcmpdes  
      ,lclltt        like datkrpdatdcen.atdcenltt  
      ,lcllgt        like datkrpdatdcen.atdcenlgt  
      ,dddcod        like datkrpdatdcen.teldddnum 
      ,lcltelnum     like datkrpdatdcen.telnum  
      ,atdinchor     like datkrpdatdcen.atdinchor   
      ,atdfnlhor     like datkrpdatdcen.atdfnlhor   
      ,atdsemdiades  like datkrpdatdcen.atdsemdiades
end record                   
  
  initialize r_endereco.* to null
  let l_empcod = ''
  let l_funmmat = ''             
  message '                         (F17)-Abandona'

  open window w_cto00m11a at 9,9 with form "cto00m11a"
   attribute(form line 1, border, comment line last)

   whenever error continue
   open  c_cto00m11_006  using l_car
   fetch c_cto00m11_006  into  l_empcod              # so para receber o valor
                            ,  l_funmmat             # idem
                            ,  r_endereco.lgdtip   
                            ,  r_endereco.lgdnom    
                            ,  r_endereco.lgdnum   
                            ,  r_endereco.brrnom   
                            ,  r_endereco.cidnom   
                            ,  r_endereco.ufdcod   
                            ,  r_endereco.cep      
                            ,  r_endereco.lgdcepcmp
                            ,  r_endereco.endlgdcmp
                            ,  r_endereco.lclltt   
                            ,  r_endereco.lcllgt   
                            ,  r_endereco.dddcod   
                            ,  r_endereco.lcltelnum
                            ,  r_endereco.atdinchor
                            ,  r_endereco.atdfnlhor
                            ,  r_endereco.atdsemdiades
   whenever error stop

   let r_endereco.cep        = r_endereco.cep       using '&&&&&'
   let r_endereco.lgdcepcmp  = r_endereco.lgdcepcmp using '&&&'

   display l_car   to codcar  attribute(reverse)
   display l_desc to desccar attribute(reverse)
   display by name r_endereco.*

   input by name invisible

     #--------------------------------
       after field invisible
     #--------------------------------
         next field invisible

     #--------------------------------
       on key(control-c, interrupt)
     #--------------------------------
        exit input

   end input
  
   close window w_cto00m11a

end function