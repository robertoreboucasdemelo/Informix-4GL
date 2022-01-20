database porto 

globals
  define g_issk record
    succod	like isskfunc.succod,
    funmat	like isskfunc.funmat,
    funnom	like isskfunc.funnom,
    dptsgl	like isskfunc.dptsgl,
    dpttip	like isskdepto.dpttip,
    dptcod	like isskdepto.dptcod,
    sissgl	like ibpksist.sissgl, 
    acsnivcod   like issmnivel.acsnivcod, 
    prgsgl	like ibpkprog.prgsgl,
    acsnivcns   like ibpmprogmod.acsnivcns,
    acsnivatl  	like ibpmprogmod.acsnivatl,
    usrtip      char(1),
    empcod      like isskusuario.empcod,
    iptcod      like isskdepto.iptcod,
    usrcod      like isskusuario.usrcod,
    maqsgl      like ismkmaq.maqsgl
  end record

  define g_log char(60),l_user char(20)
  define g_datmov date
  define g_perito like sgkkperi.sinpricod
  define g_supervisor like sgkkperi.sinpricod
  define w_hostname char(20)
  define var_pipe  char(40)
  define g_issparam  char(30)

end globals
