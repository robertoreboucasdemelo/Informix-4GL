#------------------------------------------------------------------------------r
#  Porto Seguro Cia de Seguros Gerais                                          #
#..............................................................................#
#  Programa       : ctc71m01.4gl                                               #
#  Objetivo       : Pesquisar locais especiais                                 #
#  Analista Resp. : Glauce Lima                                                #
#  PSI            : 183024                                                     #
#  OSF            : 33545                                                      #
#..............................................................................#
#                                                                              #
#  Desenvolvimento: Fabrica de Software - Teresinha Silva                      #
#  Data           : 18/03/2004                                                 #
#..............................................................................#
#                                                                              #
#                          ***  ALTERACOES  ***                                #
#                                                                              #
#  Data         Autor Fabrica  Alteracao                                       #
#  ----------   -------------  --------------------------                      #
#                                                                              #
#------------------------------------------------------------------------------#
database porto

   -- Dados a serem informados pelo usuario
   
   define m_ctc71m01001  record
          ufdcod         like glakest.ufdcod
        , cidnom         like glakcid.cidnom
        , brrnom         like datkfxolcl.brrnom
        , local          like datkfxolcl.c24fxolcldes
        , lgdnom         like datkfxolcl.lgdnom
   end record
   
   define m_ctc71m01003   array[500] of record
          c24fxolcldes    like datkfxolcl.c24fxolcldes
        , c24fxolclcod    like datkfxolcl.c24fxolclcod 
        , lgdnom          like datkfxolcl.lgdnom 
   end record

   -- Armazena os valores a serem retornados
   define m_ctc71m01002  record
          c24fxolclcod    like datkfxolcl.c24fxolclcod
        , c24fxolcldes    like datkfxolcl.c24fxolcldes
        , lgdtip          like datkfxolcl.lgdtip
        , lgdnom          like datkfxolcl.lgdnom
        , lgdcmp          like datkfxolcl.lgdnom
        , lgdnum          like datkfxolcl.lgdnum
        , lgdcep          like datkfxolcl.lgdcep
        , lgdcepcmp       like datkfxolcl.lgdcepcmp
        , brrnom          like datkfxolcl.brrnom
        , cidnom          like datkfxolcl.cidnom
        , ufdcod          like datkfxolcl.ufdcod
        , brrzonnom       like datkfxolcl.brrzonnom
        , c24lclpdrcod    like datkfxolcl.c24lclpdrcod
        , lclltt          like datkfxolcl.lclltt
        , lcllgt          like datkfxolcl.lcllgt
   end record

   define m_sql          char(01)

--------------------------------------- PARA TESTES ----------------------------
#main
#   define l_retornados     record
#          c24fxolclcod     like datkfxolcl.c24fxolclcod
#        , c24fxolcldes     like datkfxolcl.c24fxolcldes
#        , lgdtip           like datkfxolcl.lgdtip
#        , lgdnom           like datkfxolcl.lgdnom
#        , lgdcmp           like datkfxolcl.lgdnom
#        , lgdnum           like datkfxolcl.lgdnum
#        , lgdcep           like datkfxolcl.lgdcep
#        , lgdcepcmp        like datkfxolcl.lgdcepcmp
#        , brrnom           like datkfxolcl.brrnom
#        , cidnom           like datkfxolcl.cidnom
#        , ufdcod           like datkfxolcl.ufdcod
#        , brrzonnom        like datkfxolcl.brrzonnom
#        , c24lclpdrcod     like datkfxolcl.c24lclpdrcod
#        , lclltt           like datkfxolcl.lclltt
#        , lcllgt           like datkfxolcl.lcllgt
#   end record
#
#   define l_desc_local     char(40)
#   let l_desc_local = 'SHOPPING JARDIM ANALIA FRANCO'
#
#   defer interrupt
#   call ctc71m01(l_desc_local,"A")
#   returning l_retornados.*
#
#end main
-------------------------------------- PARA TESTES ----------------------------


# ---------------------------------------------------------------------------- #
function ctc71m01_prepare()
# ---------------------------------------------------------------------------- #

   define l_cmd  char(1000)

   let l_cmd = ' select ufdcod     '
             , '   from glakest    '
             , '  where ufdcod = ? '
   prepare pctc71m0101 from l_cmd
   declare cctc71m0101 cursor for pctc71m0101

   let l_cmd = ' select cidcod     '
             , '      , cidcep     '
             , '      , cidcepcmp  '
             , '   from glakcid    '
             , '  where cidnom = ? '
             , '    and ufdcod = ? ' 
   prepare pctc71m0102 from l_cmd
   declare cctc71m0102 cursor for pctc71m0102
   
   let l_cmd = ' select c24fxolclcod , c24fxolcldes , lgdtip , lgdnom       '
             , '      , lgdcmp       , lgdnum       , lgdcep , lgdcepcmp    '
             , '      , brrnom       , cidnom       , ufdcod , brrzonnom    '
             , '      , c24lclpdrcod , lclltt       , lcllgt                '
             , '   from datkfxolcl                                          '
             , '  where c24fxolclcod  = ?                                   '
             , '    and canhordat     is null                               '
             , '     or canhordat     =  ""                                 '
   prepare pctc71m0104 from l_cmd
   declare cctc71m0104 cursor for pctc71m0104

end function


# ---------------------------------------------------------------------------- #
function ctc71m01(l_desc_local,l_tela_origem,l_cidnom,l_ufdcod)
# ---------------------------------------------------------------------------- #

   define l_ctc71m01001   array[500] of record
          c24fxolcldes    like datkfxolcl.c24fxolcldes
        , c24fxolclcod    like datkfxolcl.c24fxolclcod  
        , lgdnom          like datkfxolcl.lgdnom 
   end record

   define l_cidcod        like glakcid.cidcod
        , l_cmd           char(400)
        , l_cont          integer
        , l_a             integer
        , l_tela_origem   char(1)
        , l_desc_local    like datkfxolcl.c24fxolcldes
        , l_ufdcod        like glakest.ufdcod
        , l_cidnom        like glakcid.cidnom
        

   let  int_flag          = false
   initialize m_ctc71m01001.* to null
   initialize l_ctc71m01001   to null
   initialize m_ctc71m01002.* to null
   
   let m_ctc71m01001.cidnom = l_cidnom
   let m_ctc71m01001.ufdcod = l_ufdcod
   

   if m_sql is null or
      m_sql = ""    or
      m_sql = 'F'   then
      call ctc71m01_prepare()
      let m_sql = 'T'
   end if

   open window t_ctc71m01 at 5,4 with form 'ctc71m01'
      attribute(border, form line 1)  

      clear form
      if l_tela_origem = 'A' then
         let m_ctc71m01001.local = l_desc_local
      end if

      input by name m_ctc71m01001.cidnom
                  , m_ctc71m01001.ufdcod
                  , m_ctc71m01001.brrnom
                  , m_ctc71m01001.local  without defaults

          -- Cidade
          before field cidnom
             display by name m_ctc71m01001.cidnom attribute(reverse)
             
             if m_ctc71m01001.cidnom is not null or
                m_ctc71m01001.cidnom <> " " then 
                next field ufdcod
             end if    
                
             
             
          after field cidnom
             if m_ctc71m01001.cidnom is null then
                error 'Informe a cidade'
                next field cidnom
             end if
             display by name m_ctc71m01001.cidnom 

          -- Unidade Federativa
          before field ufdcod
             display by name m_ctc71m01001.ufdcod attribute(reverse)
             if m_ctc71m01001.ufdcod is not null or 
                m_ctc71m01001.ufdcod <> " " then 
                next field local 
             end if    
             
          after field ufdcod
             if m_ctc71m01001.ufdcod is null then
                error 'Informe a UF'
                next field ufdcod
             end if

             whenever error continue
             open cctc71m0101 using m_ctc71m01001.ufdcod
             fetch cctc71m0101
             whenever error stop
             if sqlca.sqlcode = 100 then
                error 'Unidade Federativa nao cadastrada'
                next field ufdcod
             end if

             -- popup cidade e estado
             whenever error continue
             open cctc71m0102 using m_ctc71m01001.cidnom
                                  , m_ctc71m01001.ufdcod
             fetch cctc71m0102
             whenever error stop
             if sqlca.sqlcode = 100 then
                call cts06g04 ( m_ctc71m01001.cidnom
                              , m_ctc71m01001.ufdcod)
                returning l_cidcod
                        , m_ctc71m01001.cidnom
                        , m_ctc71m01001.ufdcod
             end if
           
             display by name m_ctc71m01001.ufdcod
             display by name m_ctc71m01001.cidnom

          -- Bairro
          before field brrnom
             display by name m_ctc71m01001.brrnom attribute(reverse)
          after field brrnom
             display by name m_ctc71m01001.brrnom 
   
          -- Local
          before field local
             display by name m_ctc71m01001.local attribute(reverse)
             
             if m_ctc71m01001.local is not null then 
                
                call ctc71m01_carrega_array(l_tela_origem) 
                     returning l_cont              
             
                call set_count(l_cont - 1)
                
                initialize m_ctc71m01002.* to null
                
                if l_cont = 1 then
                   error 'Nao ha registro cadastrado para este local'
                else
                   display  array m_ctc71m01003 to s_ctc71m01.*
                
                      on key (interrupt, control-c)
                         exit display
                
                      on key(f7)
                         let l_a = arr_curr()
                         call ctc71m03(m_ctc71m01003[l_a].c24fxolclcod)
                
                      on key(f8)
                         let l_a = arr_curr()
                                                                  
                         if l_tela_origem = 'A' then
                            call ctc71m01_atendimento(m_ctc71m01003[l_a].c24fxolclcod)
                         end if
                      
                         if l_tela_origem = 'C' then
                            let m_ctc71m01002.c24fxolcldes = 
                                m_ctc71m01003[l_a].c24fxolcldes
                            let m_ctc71m01002.cidnom       =  m_ctc71m01001.cidnom
                            let m_ctc71m01002.ufdcod       =  m_ctc71m01001.ufdcod
                            let m_ctc71m01002.brrnom       =  m_ctc71m01001.brrnom
                         end if                
                         exit display   
                      
                      on key (interrupt, control-c)
                         exit input                
                         
                         
                                                               
                   end display
                   
                   exit input                
                end if                                          
             end if         
             
             
             
          after field local
             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                display by name m_ctc71m01001.local 
                next field brrnom
             end if
 
             if m_ctc71m01001.local is null then
                error 'Informe o local'
                next field local
             end if
             display by name m_ctc71m01001.local 
   

          call ctc71m01_carrega_array(l_tela_origem) 
               returning l_cont              
          
          call set_count(l_cont - 1)

          initialize m_ctc71m01002.* to null

          if l_cont = 1 then
             error 'Nao ha registro cadastrado para este local'
          else
             display  array l_ctc71m01001 to s_ctc71m01.*

                on key (interrupt, control-c)
                   exit display

                on key(f7)
                   let l_a = arr_curr()
                   call ctc71m03(l_ctc71m01001[l_a].c24fxolclcod)

                on key(f8)
                   let l_a = arr_curr()

                   if l_tela_origem = 'A' then
                      call ctc71m01_atendimento(l_ctc71m01001[l_a].c24fxolclcod)
                   end if
                
                   if l_tela_origem = 'C' then
                      let m_ctc71m01002.c24fxolcldes = 
                          l_ctc71m01001[l_a].c24fxolcldes
                      let m_ctc71m01002.cidnom       =  m_ctc71m01001.cidnom
                      let m_ctc71m01002.ufdcod       =  m_ctc71m01001.ufdcod
                      let m_ctc71m01002.brrnom       =  m_ctc71m01001.brrnom
                      let m_ctc71m01002.lgdnom       =  m_ctc71m01001.lgdnom
                   end if

                   exit display

             end display

          end if

          on key (interrupt, control-c)
             exit input

      end input
   close window t_ctc71m01

   if int_flag       then
      let int_flag = false
      return m_ctc71m01002.*
   end if

   return m_ctc71m01002.*

end function


# ---------------------------------------------------------------------------- #
function ctc71m01_atendimento(l_c24fxolclcod)
# ---------------------------------------------------------------------------- #

  define l_c24fxolclcod like datkfxolcl.c24fxolclcod

  whenever error continue
  open cctc71m0104 using l_c24fxolclcod

  fetch cctc71m0104 into m_ctc71m01002.*
  close cctc71m0104

end function

function ctc71m01_carrega_array(l_tela_origem)

       
       define l_tela_origem char(1)       
       define l_cont smallint,
              l_cmd  char(500)
                                  
       let l_cont = 0 
       let l_cmd = null                     
                     
          let l_cmd = ' select c24fxolcldes '
                    , '      , c24fxolclcod '
                    , '      , lgdnom       '
                    , '   from datkfxolcl   '
                    , '  where ufdcod =    "',m_ctc71m01001.ufdcod,'"'
                    , '    and cidnom =    "',m_ctc71m01001.cidnom,'"'
   
          if m_ctc71m01001.brrnom  is not null then
             let l_cmd = l_cmd clipped
                      , ' and brrnom = "',m_ctc71m01001.brrnom,'"'
          end if


          let l_cmd  = l_cmd clipped
                     , ' and c24fxolcldes matches "*',m_ctc71m01001.local 
                       clipped ,'*"'
   
          if l_tela_origem = 'A' then
             let l_cmd = l_cmd clipped
                       , ' and canhordat is null or canhordat = ""'
          end if
          
          let l_cmd = l_cmd clipped,
                      "order by c24fxolcldes,c24fxolclcod"                    
          
          prepare pctc71m0103 from l_cmd
          declare cctc71m0103 cursor for pctc71m0103

          let l_cont = 1
          foreach cctc71m0103 into m_ctc71m01003[l_cont].c24fxolcldes     
                                 , m_ctc71m01003[l_cont].c24fxolclcod
                                 , m_ctc71m01003[l_cont].lgdnom
   
           
              let l_cont = l_cont + 1
	
              if l_cont > 500 then
                 error 'ARRAY SUPEROU O LIMITE DE LINHAS RESERVADAS!'
                 exit foreach
              end if

          end foreach
          
       return l_cont   
         
end function 




#___________________________________ FIM MODULO ______________________________ #
