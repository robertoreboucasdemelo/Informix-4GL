###############################################################################
# Nome do Modulo: CTB22M01                                           Wagner   #
#                                                                             #
# Alerta convenio / assunto                                          Jul/2002 #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function ctc22m01()
#--------------------------------------------------------------

 define d_ctc22m01   record
    ligcvntip        smallint,
    ligcvndes        char (40)  
 end record

 initialize d_ctc22m01.* to null

 let int_flag  = false

 open window ctc22m01 at 06,02 with form "ctc22m01"
      attribute (form line 1,comment line last - 1)

 message " (F17)Abandona"

 while true

    input by name d_ctc22m01.ligcvntip  without defaults

       before field ligcvntip
          display by name d_ctc22m01.ligcvntip attribute (reverse)

       after  field ligcvntip
          display by name d_ctc22m01.ligcvntip

          if d_ctc22m01.ligcvntip is null  then
             error " Informe o codigo do Convenio!"
             call ctc22m01_convenios() returning d_ctc22m01.ligcvntip 
             next field ligcvntip
          end if

          select cpodes 
            into d_ctc22m01.ligcvndes
            from datkdominio 
           where cponom = "ligcvntip"
             and cpocod = d_ctc22m01.ligcvntip

          if sqlca.sqlcode = notfound  then
             error " Convenio nao cadastrado!"
             call ctc22m01_convenios() returning d_ctc22m01.ligcvntip 
             next field ligcvntip
          end if

          display by name d_ctc22m01.ligcvntip
          display by name d_ctc22m01.ligcvndes

          call ctc22m01_assuntos(d_ctc22m01.ligcvntip)

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

 end while

 close window ctc22m01
 let int_flag = false

end function  #  ctc22m01


#--------------------------------------------------------------
 function ctc22m01_assuntos(param)
#--------------------------------------------------------------

 define param        record
    ligcvntip        like dammaleastcvn.ligcvntip   
 end record

 define a_ctc22m01   array[200] of record
    c24astcod        like datkassunto.c24astcod,    
    c24astdes        like datkassunto.c24astdes,    
    funnom           like isskfunc.funnom,
    atldat           like dammaleastcvn.atldat
 end record

 define ws           record
    c24astcod        like datkassunto.c24astcod,    
    atlmat           like dammaleastcvn.atlmat,  
    atlemp           like dammaleastcvn.atlemp,  
    atlusrtip        like dammaleastcvn.atlusrtip,
    confirma         char (01),
    operacao         char (01)
 end record

 define arr_aux      integer
 define scr_aux      integer
 define x            smallint


 initialize a_ctc22m01  to null
 initialize ws.*        to null
 let arr_aux = 1

 declare c_ctc22m01 cursor for
  select dammaleastcvn.c24astcod, dammaleastcvn.atlmat, 
         dammaleastcvn.atlemp   , dammaleastcvn.atlusrtip, 
         dammaleastcvn.atldat      
    from dammaleastcvn
   where dammaleastcvn.ligcvntip  = param.ligcvntip  
   order by dammaleastcvn.c24astcod

 foreach c_ctc22m01 into a_ctc22m01[arr_aux].c24astcod, ws.atlmat, 
                         ws.atlemp                    , ws.atlusrtip, 
                         a_ctc22m01[arr_aux].atldat      

    let a_ctc22m01[arr_aux].c24astdes = "NAO CADASTRADO!"     
    select datkassunto.c24astdes 
      into a_ctc22m01[arr_aux].c24astdes      
      from datkassunto
     where datkassunto.c24astcod = a_ctc22m01[arr_aux].c24astcod      

    let a_ctc22m01[arr_aux].funnom = "NAO CADASTRADO!"     
    select isskfunc.funnom 
      into a_ctc22m01[arr_aux].funnom        
      from isskfunc 
     where isskfunc.funmat = ws.atlmat 
       and isskfunc.empcod = ws.atlemp 
       and isskfunc.usrtip = ws.atlusrtip  

    let arr_aux = arr_aux + 1
    if arr_aux > 200 then
       error " Limite excedido, convenio com mais de 200 assuntos"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux-1)
 options comment line last - 1

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

 while 2

    let int_flag = false

    input array a_ctc22m01 without defaults from s_ctc22m01.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
             let ws.c24astcod   = a_ctc22m01[arr_aux].c24astcod
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc22m01[arr_aux].*  to null
          display a_ctc22m01[arr_aux].* to s_ctc22m01[scr_aux].*

       before field c24astcod
          display a_ctc22m01[arr_aux].c24astcod to
                  s_ctc22m01[scr_aux].c24astcod attribute (reverse)

       after field c24astcod
          display a_ctc22m01[arr_aux].c24astcod to
                  s_ctc22m01[scr_aux].c24astcod

          if a_ctc22m01[arr_aux].c24astcod is null then
             error " Codigo Assunto deve ser informado!"
             next field c24astcod
          end if

          if ws.operacao = "a" and
             a_ctc22m01[arr_aux].c24astcod <> ws.c24astcod then
             error " Codigo do Assunto nao deve ser alterado!"
             next field c24astcod
          end if

          initialize a_ctc22m01[arr_aux].c24astdes to null
          select datkassunto.c24astdes 
            into a_ctc22m01[arr_aux].c24astdes      
            from datkassunto
           where datkassunto.c24astcod = a_ctc22m01[arr_aux].c24astcod      

          if sqlca.sqlcode <> 0 then
             error " Assunto nao cadastrado !"
             next field c24astcod
          end if

          display a_ctc22m01[arr_aux].c24astdes  to
                  s_ctc22m01[scr_aux].c24astdes

          for x = 1 to 200
              if arr_aux <> x                                       and
                 a_ctc22m01[arr_aux].c24astcod = a_ctc22m01[x].c24astcod  then
                 error " Assunto ja' cadastrado para este Convenio!"
                 next field c24astcod
              end if
          end for

       before delete
          let ws.operacao = "d"
          if a_ctc22m01[arr_aux].c24astcod  is null  then
             continue input
          end if

          delete from dammaleastcvn  
           where dammaleastcvn.ligcvntip = param.ligcvntip
             and dammaleastcvn.c24astcod = a_ctc22m01[arr_aux].c24astcod 

          if sqlca.sqlcode <> 0 then
             error " Erro (", sqlca.sqlcode, ") na exclusao deste assintos, favor verificar!"
          end if

          initialize a_ctc22m01[arr_aux].* to null
          display a_ctc22m01[arr_aux].* to s_ctc22m01[scr_aux].*

       after row
          case ws.operacao
             when "i"
               insert into dammaleastcvn (ligcvntip,
                                          c24astcod,   
                                          caddat,      
                                          cadmat,      
                                          cademp,      
                                          cadusrtip,      
                                          atlmat,      
                                          atlemp,      
                                          atlusrtip,  
                                          atldat)          
                                  values (param.ligcvntip,
                                          a_ctc22m01[arr_aux].c24astcod,   
                                          today,      
                                          g_issk.funmat,
                                          g_issk.empcod,
                                          g_issk.usrtip,
                                          g_issk.funmat,
                                          g_issk.empcod,
                                          g_issk.usrtip,
                                          today )          

               if sqlca.sqlcode <> 0 then
                  error " Erro (", sqlca.sqlcode, ") na inclusao deste assunto favor verificar!"
               end if

            end case

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

end function  #  ctc22m01_assuntos


#-----------------------------------------------------------
 function ctc22m01_convenios() 
#-----------------------------------------------------------
 define a_cta00m00  array[150] of record
    cpodes          like iddkdominio.cpodes,
    cpocod          like iddkdominio.cpocod
 end record

 define arr_aux       integer
 define ws_ligcvntip  smallint

 open window cta00m00 at 08,12 with form "cta00m00"
                      attribute(form line 1, border)

 let int_flag = false
 initialize  a_cta00m00   to null
 initialize  ws_ligcvntip to null   

 declare c_cta00m00    cursor for
   select  cpocod, cpodes
     from  datkdominio
     where cponom = "ligcvntip"

 let arr_aux  = 1

 foreach c_cta00m00 into a_cta00m00[arr_aux].cpocod,
                         a_cta00m00[arr_aux].cpodes

    let arr_aux = arr_aux + 1
    if arr_aux  >  150   then
       error " Limite excedido, tabela de convenios com mais de 150 itens!"
       exit foreach
    end if
 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_cta00m00 to s_cta00m00.*

    on key (interrupt,control-c)
       initialize  ws_ligcvntip to null   
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       let ws_ligcvntip = a_cta00m00[arr_aux].cpocod
       exit display

 end display

 let int_flag = false
 close window  cta00m00

 return ws_ligcvntip 

end function  #  ctc22m01_convenios



