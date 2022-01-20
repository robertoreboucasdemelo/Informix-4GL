#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: CT24h                                                     #
# Modulo.........: ctc26m00.4gl                                              #
# Analista Resp..: Glauce Lima                                               #
# PSI/OSF........: 180.475 / 30228                                           #
# Objetivo.......: Cadastro de Motivos.                                      #
#............................................................................#
# Desenvolvimento: Meta, Bruno Gama                                          #
# Liberacao......: 19/12/2003                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# Data        Autor Fabrica   PSI/OSF       Alteracao                        #
# ----------  -------------   ------------  -------------------------------- #
#                                                                            #
# 13/01/2004 Ivone, Meta   PSI180475   Cadastrar motivos por assunto         #
#                          OSF 30228                                         #
#                                                                            #
#----------------------------------------------------------------------------#
#............................................................................#

# globals '/homedsa/fontes/ct24h/producao/glct.4gl'

globals "/homedsa/projetos/geral/globals/glct.4gl"     

 define m_prep_sql          smallint
 #inicio psi180475  ivone
 define mr_assunto          record 
        c24astcod           like datkassunto.c24astcod,
        c24astdes           like datkassunto.c24astdes, 
        rcuccsmtvobrflg     like datkassunto.rcuccsmtvobrflg
 end record
  
 define am_ctc26m00         array[100] of record
        rcuccsmtvcod        like datkrcuccsmtv.rcuccsmtvcod,
        rcuccsmtvdes        like datkrcuccsmtv.rcuccsmtvdes,
        rcuccsmtvstt        like datkrcuccsmtv.rcuccsmtvstt
 end record
 
 define m_qtde              smallint
 
#inicio psi180475  ivone
#==============================================================================
 function ctc26m00_prepare()
#==============================================================================

    define l_sql               char(500)
 
    let l_sql = " select rcuccsmtvcod, ",
                "        rcuccsmtvdes, ",
                "        rcuccsmtvstt  ",
                "   from datkrcuccsmtv ",
                "   where c24astcod = ? ",
                "  order by 2   "
    prepare pctc26m00001    from l_sql
    declare cctc26m00001    cursor for pctc26m00001
        
    let l_sql = " insert into datkrcuccsmtv ",
                "        (    rcuccsmtvcod, ",
                "             rcuccsmtvdes, ",
                "             rcuccsmtvstt, ",
                "             caddat      , ",
                "             c24astcod)    ",
                " values (?,?,?,?,?)          "
    prepare pctc26m00002     from l_sql
    
    let l_sql = " delete from datkrcuccsmtv ",
                "  where rcuccsmtvcod = ?   ",
                "    and c24astcod    = ?   " 
    prepare pctc26m00003     from l_sql

    let l_sql = " update datkrcuccsmtv ",
                "    set rcuccsmtvdes = ?  ,",
                "        rcuccsmtvstt = ?   ",
                "  where rcuccsmtvcod = ?   ",
                "    and c24astcod    = ?   " 
    prepare pctc26m00004     from l_sql

    let l_sql = " select max(rcuccsmtvcod) ",
                "   from datkrcuccsmtv ",
                "  where rcuccsmtvcod > 0 ",
                "    and c24astcod    = ? " 
    prepare pctc26m00005    from l_sql
    declare cctc26m00005    cursor for pctc26m00005
    
    #inicio psi180475   ivone
    let l_sql = " select c24astdes, rcuccsmtvobrflg ",      
            "   from datkassunto ",          
            "  where c24astcod = ? "        
    prepare pctc26m00006    from l_sql             
    declare cctc26m00006    cursor for pctc26m00006

    #fim psi180475   ivone

    
    let m_prep_sql = true

 end function

#==============================================================================
 function ctc26m00()
#==============================================================================
    
    define l_cont              smallint   
    define l_erro              smallint                                 #psi180475   ivone
                                           
    let l_erro = false
    
    if m_prep_sql is null or m_prep_sql <> true then
       call ctc26m00_prepare()
    end if
        
    #inicio psi180475  ivone  
    open window w_ctc26m00 at 3,2 with form "ctc26m00" 
         attribute (form line first)

    while true
    
        let int_flag = false
        
        clear form
    
        initialize am_ctc26m00  to null
        initialize mr_assunto.* to null
        
        display by name mr_assunto.c24astcod
        display by name mr_assunto.c24astdes
    
        let m_qtde = 0
        
        input mr_assunto.c24astcod  from  c24astcod
        
          after field  c24astcod
              if mr_assunto.c24astcod is null  then
                 error "Digite o codigo do assunto"  sleep 2
                 next field c24astcod
              end if
              let mr_assunto.c24astdes =  null
              open cctc26m00006  using  mr_assunto.c24astcod
              whenever error continue
              fetch cctc26m00006 into   mr_assunto.c24astdes,
                                        mr_assunto.rcuccsmtvobrflg
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode <> notfound then
                     error 'Erro SELECT cctc26m00006', sqlca.sqlcode, '/',sqlca.sqlerrd[2] sleep 2
                     error 'ctc26m00()/',mr_assunto.c24astcod sleep 2
                     let l_erro = true
                     exit input 
                 else
                     error "Codigo do assunto nao cadastrado"   sleep 2    
                     display by name mr_assunto.c24astdes
                     next field c24astcod
                 end if
              end if
    
              display mr_assunto.c24astdes to c24astdes
              
              if  mr_assunto.rcuccsmtvobrflg is null then
                  let mr_assunto.rcuccsmtvobrflg = "N"
              end if
                  
        end input
        
        if int_flag = true then
           exit while
        end if
    
        if l_erro  then                               
           exit while
        end if
    
        let l_cont = 1
    
        open    cctc26m00001 using mr_assunto.c24astcod   
        foreach cctc26m00001  into am_ctc26m00[l_cont].rcuccsmtvcod,
                                   am_ctc26m00[l_cont].rcuccsmtvdes,
                                   am_ctc26m00[l_cont].rcuccsmtvstt
           let l_cont = l_cont + 1
           if  l_cont > 100 then
               error 'Estouro Array !'
               exit foreach
           end if
        end foreach
        
        let m_qtde = l_cont - 1
        
        if l_cont = 1 then
           error "Assunto nao tem motivos cadastrados"  sleep 2
        end if
       
        if l_cont > 12 then
            call set_count(l_cont - 1)
        else
            call set_count(12)
        end if
    
        call ctc26m00_input_array()
    
        let int_flag = false
    
    end while

    #fim psi180475  ivone
       
    close window w_ctc26m00

 end function
 
#psi180475  ivone 
#==============================================================================
 function  ctc26m00_input_array()
#==============================================================================

  define l_arr               smallint
  define l_scr               smallint
  define l_data              date
  define l_acao              char(01)
  define l_codigo            like datkrcuccsmtv.rcuccsmtvcod
  define l_loop              smallint
  
  let  l_loop = true
  
  while l_loop 

    let l_data = today
    let l_acao = null
    
    let int_flag = false
    
    input array am_ctc26m00 without defaults from s_ctc26m00.*
                          
       before row
           let l_arr = arr_curr()
           let l_scr = scr_line()
           let l_acao = null
           
           if  l_arr > 100 then
               exit input
           end if
                    
       before insert
                  
           let l_acao = "I"
           
           next field rcuccsmtvdes
        
       before delete
        
           execute pctc26m00003   using am_ctc26m00[l_arr].rcuccsmtvcod,
                                       mr_assunto.c24astcod
           if sqlca.sqlcode <> 0 then
              error 'Erro DELETE datkrcuccsmtv', sqlca.sqlcode, '/',sqlca.sqlerrd[2] sleep 2
              error 'ctc26m00()/',am_ctc26m00[l_arr].rcuccsmtvcod sleep 2
              exit input
           end if
   
       before field rcuccsmtvcod

           let l_codigo = am_ctc26m00[l_arr].rcuccsmtvcod
           
           if m_qtde = 0 then
              let m_qtde = m_qtde + 1
              let l_acao = "I"
              next field rcuccsmtvdes
           end if
           
           if am_ctc26m00[l_arr].rcuccsmtvcod is null then
              let l_acao = "I"
              next field rcuccsmtvdes
           end if
          
           if l_acao is not null then
              next field rcuccsmtvdes
           end if

       after field rcuccsmtvcod

           let am_ctc26m00[l_arr].rcuccsmtvcod = l_codigo 
           
           display am_ctc26m00[l_arr].rcuccsmtvcod to s_ctc26m00[l_scr].rcuccsmtvcod

           if fgl_lastkey() = fgl_keyval("down") then
              if am_ctc26m00[l_arr + 1].rcuccsmtvdes is null then
                 next field rcuccsmtvdes
              end if
           end if

           if fgl_lastkey() <> fgl_keyval("up")   and
              fgl_lastkey() <> fgl_keyval("down") and
              fgl_lastkey() <> 2014               then
              if l_acao is null then
                 next field rcuccsmtvcod
              end if
           end if

       before field rcuccsmtvdes

           if l_acao is null then
              next field rcuccsmtvcod
           end if
              
       after field rcuccsmtvdes
           
           if fgl_lastkey() <> fgl_keyval("up")   and
              fgl_lastkey() <> fgl_keyval("left") then
              if am_ctc26m00[l_arr].rcuccsmtvdes is null then
                 next field rcuccsmtvdes
              end if
           end if
   
        after field rcuccsmtvstt
    
           if fgl_lastkey() <> fgl_keyval("up")   and
              fgl_lastkey() <> fgl_keyval("left") then
              if am_ctc26m00[l_arr].rcuccsmtvstt is null then
                 next field rcuccsmtvstt
              end if
           end if

           if l_acao = "I" then
              let l_codigo = null
              open  cctc26m00005  using mr_assunto.c24astcod
              whenever error continue
              fetch cctc26m00005  into  l_codigo
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode <> notfound then
                    error 'Erro SELECT datkrcuccsmtv', sqlca.sqlcode, '/',sqlca.sqlerrd[2] sleep 2
                    let l_loop = false
                    exit input
                 end if
              end if
              if l_codigo is null then
                 let l_codigo = 0
              end if
              let am_ctc26m00[l_arr].rcuccsmtvcod = l_codigo + 1
              whenever error continue
              execute pctc26m00002   using am_ctc26m00[l_arr].rcuccsmtvcod,
                                           am_ctc26m00[l_arr].rcuccsmtvdes,
                                           am_ctc26m00[l_arr].rcuccsmtvstt,
                                           l_data,
                                           mr_assunto.c24astcod
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 error 'Erro INSERT datkrcuccsmtv', sqlca.sqlcode, '/',sqlca.sqlerrd[2] sleep 2
                 error 'ctc26m00()/',am_ctc26m00[l_arr].rcuccsmtvcod,'/',am_ctc26m00[l_arr].rcuccsmtvdes sleep 2
                 error '/',am_ctc26m00[l_arr].rcuccsmtvstt,'/',l_data sleep 2
                 let l_loop = false
                 exit input
              end if
           end if
           if l_acao = "A" then
              whenever error continue
              execute pctc26m00004   using am_ctc26m00[l_arr].rcuccsmtvdes,
                                           am_ctc26m00[l_arr].rcuccsmtvstt,
                                           am_ctc26m00[l_arr].rcuccsmtvcod,
                                           mr_assunto.c24astcod
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 error 'Erro UPDATE datkrcuccsmtv', sqlca.sqlcode, '/',sqlca.sqlerrd[2] sleep 2
                 error 'ctc26m00()/',am_ctc26m00[l_arr].rcuccsmtvcod,'/',am_ctc26m00[l_arr].rcuccsmtvdes sleep 2
                 error '/',am_ctc26m00[l_arr].rcuccsmtvstt,'/',l_data sleep 2
                 let l_loop = false
                 exit input
              end if
           end if

           let l_acao = null
           
        after row
   
           if fgl_lastkey() = fgl_keyval("up")   or 
              fgl_lastkey() = fgl_keyval("left") then
              if l_acao = "I" then
                 initialize am_ctc26m00[l_arr].* to null
                 display am_ctc26m00[l_arr].* to s_ctc26m00[l_scr].*
                 let l_acao = null
              end if
           end if
        
           let l_acao = null
        
        on key (f5, control-o)
           
          let l_arr = arr_curr()
          if am_ctc26m00[l_arr].rcuccsmtvcod is not null then
             let l_acao = "A"
             next field rcuccsmtvdes
          end if
          
        on key (f8)
          call ctc26m02_sub_motivo(mr_assunto.c24astcod
                                 , mr_assunto.c24astdes
                                 , am_ctc26m00[l_arr].rcuccsmtvcod
                                 , am_ctc26m00[l_arr].rcuccsmtvdes)
          
          display am_ctc26m00[l_arr].rcuccsmtvcod to s_ctc26m00[l_scr].rcuccsmtvcod
           
        on key (f17, control-c, interrupt)
           let l_loop = false
           exit input
    end input

  end while
 
  let int_flag = false

 end function
#fim psi180475  ivone
