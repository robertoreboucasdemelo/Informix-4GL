###############################################################################
# Nome do Modulo: ctc21m06                                           Almeida  #
#                                                                             #
# Cadastro dos textos referentes aos procedimentos                   jan/1999 #
###############################################################################
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data        Autor Fabrica  Origem      Alteracao                            #
# ----------  -------------- ---------  ------------------------------------  #
# 11/09/2003  Meta,Bruno     PSI175269   Implementacao na tela do campo       #
#                            OSF25780    Departamento(datktelprc.dptsgl).     #
# --------------------------------------------------------------------------  #
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- --------  -----------------------------------------#
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.               #
#-----------------------------------------------------------------------------#
 

 globals "/homedsa/projetos/geral/globals/glct.4gl"         

# PSI 175269 - Inicio 
 
 define m_prep_sql   smallint

 function ctc21m06_prepare()
 
    define l_sql        char(600)
        
    let l_sql = 'select a.dptsgl, b.dptnom ',
                '  from datktelprc a, isskdepto b ',
                ' where a.dptsgl = b.dptsgl ',
                '   and a.telprccod = ?'
    prepare pctc21m0601   from l_sql
    declare cctc21m0601   cursor for pctc21m0601
    
    let m_prep_sql = true
    
 end function
 
# PSI 175269 - Fim
                     
#------------------------------------------------------------
 function ctc21m06(param)                     
#------------------------------------------------------------
                                              
 define param          record                     
    tipo_proc          dec(1,0),
    origem             dec(1,0),
    prtprcnum          like datmprtprc.prtprcnum
 end record              

 define a_ctc21m06     array[100] of record
    prctxtseq          like datmprctxt.prctxtseq,
    prctxt             like datmprctxt.prctxt
 end record
 
#define at_ctc21m06     array[100] of record
#   telprcseq           like datkprctxt.telprcseq,
#   telprctxt           like datkprctxt.telprctxt
#end record    

 define ws             record
    acao               char(01),
    confirma           char(01),
    comando            char(500)
 end record

 define arr_aux        integer
 define scr_aux        integer
 
 define wnd_x          integer
 define wnd_y          integer

# PSI 175269 - Inicio 

 define lr_depto        record
        descrdp         char(60)
 end record

 define l_dptsgl       like isskdepto.dptsgl,
        l_dptnom       like isskdepto.dptnom

 if m_prep_sql is null or m_prep_sql = false then
    call ctc21m06_prepare()
 end if

# PSI 175269 - fim

 if param.prtprcnum  is null   then
    error " Numero do procedimento nao informado. AVISE INFORMATICA!"
    return
 end if

 if param.tipo_proc = 0 then
   let ws.comando = "select prctxtseq,",
                    "       prctxt ",
                    "from datmprctxt ",
                    "where prtprcnum  = ", param.prtprcnum clipped
 else

   let ws.comando =    "select telprcseq, ",
                       "       telprctxt ",
                       "  from datkprctxt ",
                       "where telprccod = ", param.prtprcnum clipped
  end if  

 prepare sel_datkprctxt from ws.comando
 declare c_ctc21m06 cursor with hold for sel_datkprctxt

 let wnd_x = 10    ## PSI 175269
 let wnd_y = 2

 let lr_depto.descrdp = null

 if param.tipo_proc = 1 then
    let wnd_x = 11  ## PSI 175269
 end if

 if param.origem = 0 then
    # Cadastro
    open window w_ctc21m06 at wnd_x,wnd_y with form "ctc21m06"
         attribute (form line 1)
 else
    # Consulta
    open window w_ctc21m06 at 10,5 with form "ctc21m06"
         attribute(border,form line 1)
         
## PSI 175269 - Inicio         
             
    open cctc21m0601      using param.prtprcnum
    whenever error continue
    fetch cctc21m0601     into l_dptsgl, l_dptnom
    whenever error stop
    if  sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let lr_depto.descrdp = null
        else
           display 'Erro SELECT dptsgl ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
           return
        end if
    else
        let lr_depto.descrdp = "Departamento : ",l_dptsgl clipped,
                               " - ", l_dptnom clipped 
    end if
    
    display by name lr_depto.descrdp
             
 ## PSI 175269 - Fim        
         
 end if

 while not int_flag

   initialize ws.*        to null
   initialize a_ctc21m06  to null
   let int_flag  =  false
   let arr_aux   =  1

   display by name lr_depto.descrdp

   if param.tipo_proc = 0 then
      let ws.comando = "select prctxtseq,",
                       "       prctxt ",
                       "from datmprctxt ",
                       "where prtprcnum  = ", param.prtprcnum 
#     declare c_ctc21m06  cursor for
#        select prctxtseq,
#               prctxt
#          from datmprctxt
#         where prtprcnum  =  param.prtprcnum

   else
      
     #declare c_ctc21m06 cursor for
     let ws.comando =    "select telprcseq, ",
                         "       telprctxt ",
                         "  from datkprctxt ",
                         "where telprccod = ", param.prtprcnum clipped
   end if
   
#  declare c_ctc21m06  cursor for ws.comando
   open c_ctc21m06 
      foreach c_ctc21m06 into  a_ctc21m06[arr_aux].prctxtseq,
                               a_ctc21m06[arr_aux].prctxt  

      let arr_aux  =  arr_aux + 1
      if arr_aux  >  100   then
        error " Limite excedido. Existem mais de 100 linhas de texto cadastradas!"
        exit foreach
      end if

   end foreach

   call set_count(arr_aux - 1)

   display by name lr_depto.descrdp

   input array a_ctc21m06 without defaults from s_ctc21m06.*

     before row
        let arr_aux = arr_curr()
        let scr_aux = scr_line()
        let ws.acao = "A"

     before insert
        let ws.acao = "I"
        initialize a_ctc21m06[arr_aux].*    to null
        display a_ctc21m06[arr_aux].prctxt  to s_ctc21m06[scr_aux].prctxt

     before field prctxt
        display a_ctc21m06[arr_aux].prctxt to
                s_ctc21m06[scr_aux].prctxt  attribute(reverse)

     after  field prctxt
        display a_ctc21m06[arr_aux].prctxt to
                s_ctc21m06[scr_aux].prctxt


        if fgl_lastkey() <> fgl_keyval("up")   then
           if a_ctc21m06[arr_aux].prctxt  is null then
#             a_ctc21m06[arr_aux].prctxt  =  ""     then
              error " Texto com os procedimentos deve ser informado!"
              next field prctxt
           end if
        end if

     before delete
        let ws.acao = "D"

        if a_ctc21m06[arr_aux].prctxtseq  is null   then
           continue input
        end if

        call cts08g01("A","S", "","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
             returning ws.confirma

        if ws.confirma  =  "N"   then
           display a_ctc21m06[arr_aux].prctxt to s_ctc21m06[scr_aux].prctxt
           exit input
        end if

        if param.tipo_proc = 0 then
           delete
             from datmprctxt
            where datmprctxt.prtprcnum  =  param.prtprcnum
              and datmprctxt.prctxtseq  =  a_ctc21m06[arr_aux].prctxtseq
        else
           delete
             from datkprctxt
           where datkprctxt.telprccod = param.prtprcnum
             and datkprctxt.telprcseq = a_ctc21m06[arr_aux].prctxtseq
        end if

     after row
        if fgl_lastkey() = fgl_keyval("up")   then
           continue input
        end if

        if a_ctc21m06[arr_aux].prctxtseq  is null   or
           a_ctc21m06[arr_aux].prctxtseq  =  0      then

           if param.tipo_proc = 0 then
              select max(prctxtseq)
                into a_ctc21m06[arr_aux].prctxtseq
                from datmprctxt
               where prtprcnum = param.prtprcnum
           else
              select max(telprcseq)
                into a_ctc21m06[arr_aux].prctxtseq
                from datkprctxt
               where telprccod = param.prtprcnum   
           end if

           if a_ctc21m06[arr_aux].prctxtseq is null then
              let a_ctc21m06[arr_aux].prctxtseq = 1
           else
              let a_ctc21m06[arr_aux].prctxtseq =
                  a_ctc21m06[arr_aux].prctxtseq + 1
           end if
        end if

        begin work

           if ws.acao  =  "I"   then
             if param.tipo_proc = 0 then
                insert into datmprctxt ( prtprcnum,
                                         prctxtseq,
                                         prctxt
                                       )
                            values     ( param.prtprcnum,
                                         a_ctc21m06[arr_aux].prctxtseq,
                                         a_ctc21m06[arr_aux].prctxt
                                       )
             else
                insert into datkprctxt ( telprccod,
                                         telprcseq,
                                         telprctxt
                                        )
                            values      ( param.prtprcnum,
                                          a_ctc21m06[arr_aux].prctxtseq,
                                          a_ctc21m06[arr_aux].prctxt
                                       )                    
             end if


           else
              if ws.acao  =  "A"   then
                 if param.tipo_proc = 0 then
                    update datmprctxt  set prctxt = a_ctc21m06[arr_aux].prctxt
                     where prtprcnum = param.prtprcnum
                       and prctxtseq = a_ctc21m06[arr_aux].prctxtseq
                  else
                    update datkprctxt set telprctxt = a_ctc21m06[arr_aux].prctxt                     where telprccod = param.prtprcnum  
                       and telprcseq = a_ctc21m06[arr_aux].prctxtseq
                  end if   
              end if
           end if

        commit work

        on key (accept)
           continue input

        on key (interrupt)
           let int_flag = true
           exit input

   end input

 end while

 let int_flag = false
 close window w_ctc21m06

end function   ###--- ctc21m06
