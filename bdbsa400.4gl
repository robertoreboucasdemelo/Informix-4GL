#############################################################################
# Nome do Modulo: bdbsa400                                           Sergio #
#                                                                    Burini #
# Envio de SMS.                                                    Nov/2007 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#

database porto

    define lr_envsms record
                        smsenvcod like dbsmenvmsgsms.smsenvcod,	
                        dddcel    like dbsmenvmsgsms.dddcel,
                        celnum    like dbsmenvmsgsms.celnum,
                        msgtxt    like dbsmenvmsgsms.msgtxt,
                        errmsg    like dbsmenvmsgsms.errmsg,
                        errcod    integer,
                        msgerr    char(20)                                         
                     end record
                     
    define l_sissgl     like pccmcorsms.sissgl,
           l_prioridade smallint, 
           l_expiracao  integer,
           m_tmpexp     datetime year to second,
           l_prcstt     like dpamcrtpcs.prcstt,
           m_path       char(100)           
                          

main
    call bdbsa400()
end main

#---------------------------#
 function bdbsa400_prepare()
#---------------------------#

     define l_sql char(1000)
     
     let l_sql = "select smsenvcod, ",
                       " dddcel, ",
                       " celnum, ",
                       " msgtxt ",
                  " from dbsmenvmsgsms ",
                 " where envstt = 'A' ",
                   " and (envprghor < current ",
                    " or envprghor is null)"

     prepare prbdbsa400_01 from l_sql
     declare cqbdbsa400_01 cursor for prbdbsa400_01
     
     let l_sql = "update dbsmenvmsgsms ",
                   " set envstt = 'E', ",
                       " envdat = current ",
                 " where smsenvcod = ? "
                 
     prepare prbdbsa400_02 from l_sql   
     
     let l_sql = "update dbsmenvmsgsms ",
                   " set errmsg = '?' ",
                 " where smsenvcod = ? "
                 
     prepare prbdbsa400_03 from l_sql       

 end function

#-------------------#                    
 function bdbsa400()
#-------------------#

    # ABRE_BANCO - PSI193755
    call fun_dba_abre_banco("GUINCHOGPS")

    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsa066.log"
    
    call startlog(m_path)
    
    set lock mode to wait 30
    set isolation to dirty read    

    call bdbsa400_prepare()
    
    let l_sissgl = "PSocorro"
    let l_prioridade = figrc007_prioridade_alta()
    let l_expiracao = figrc007_expiracao_1h()    
    let  m_tmpexp = current    
    
    while true
    
        call ctx28g00("bdbsa400", fgl_getenv("SERVIDOR"), m_tmpexp)
          returning m_tmpexp, l_prcstt
        
        if  l_prcstt = 'A' then   
        
            open cqbdbsa400_01
            
            foreach cqbdbsa400_01 into lr_envsms.smsenvcod,
                                       lr_envsms.dddcel,
                                       lr_envsms.celnum,
                                       lr_envsms.msgtxt
            
                      call figrc007_sms_send1 (lr_envsms.dddcel,           
                                         lr_envsms.celnum,     
                                         lr_envsms.msgtxt,   
                                         l_sissgl,     
                                         l_prioridade,
                                         l_expiracao)  
                             returning lr_envsms.errcod,
                                       lr_envsms.msgerr
                
                if lr_envsms.errcod <> 0 then                                             
                   let lr_envsms.errmsg = lr_envsms.errcod clipped, " ", lr_envsms.msgerr
                   execute prbdbsa400_03 using lr_envsms.errmsg, lr_envsms.smsenvcod                                                                    
                else
                    execute prbdbsa400_02 using lr_envsms.smsenvcod
                end if                                                                    
            
                call ctx28g00("bdbsa400", fgl_getenv("SERVIDOR"), m_tmpexp)
                  returning m_tmpexp, l_prcstt
                
            end foreach
        
        end if 
        
        sleep 10
        
    end while

 end function
