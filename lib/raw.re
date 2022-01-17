// external make_variant: (Transport.variant_tag, 't) => 'var = "make_variant";

external fail: unit => 'a = "fail";

external dontknow: unit => 'a = "dontknow";

external assertfalse: unit => 'a = "assertfalse";

external todo: unit => 'a = "todo";

external guarded_receive: (~from:Polyvar.tag) => 'a = "guarded_receive";

external make_polyvar: (Polyvar.tag, 'a) => 'var = "make_polyvar";

external destruct_polyvar: 'var => (Polyvar.tag, 'a) = "destruct_polyvar";

external cast : 'a => 'b = "cast";

