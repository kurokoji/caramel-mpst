% Source code generated with Caramel.
-module(caramel_mpst).
-export_type([closed_variant/2]).
-export_type([disj/3]).
-export_type([global/3]).
-export_type([inp/1]).
-export_type([label/4]).
-export_type([lens/4]).
-export_type([open_variant/2]).
-export_type([out/1]).
-export_type([role/6]).
-export_type([session/1]).

-export([alice/0]).
-export([bob/0]).
-export([carol/0]).
-export([close/1]).
-export([comm/4]).
-export([finish/0]).
-export([from_some/1]).
-export([goodbye/0]).
-export([hello/0]).
-export([hello_or_goodbye/0]).
-export([lens_a/0]).
-export([lens_b/0]).
-export([lens_c/0]).
-export([list_match/2]).
-export([main/0]).
-export([open_variant_to_tag/1]).
-export([receive_/2]).
-export([send/4]).
-export([start/4]).
-export([payload_to_session/1]).

payload_to_session(A) -> A.

-type session(A) :: #{ mpchan => transport:mpchan()
                     , dummy_witness => A
                     }.

-type global(A, B, C) :: {session(A), session(B), session(C)}.

-type lens(A, B, S, T) :: #{ get => fun((S) -> session(A))
                           , put => fun((S, session(B)) -> T)
                           }.

-type open_variant(Var, V) :: fun((V) -> Var).

-type closed_variant(Var, V) :: fun((Var) -> V).

-type disj(Lr, L, R) :: #{ concat => fun((list(L), list(R)) -> list(Lr))
                         , split => fun((list(Lr)) -> {list(L), list(R)})
                         }.

-type role(A, B, S, T, Obj, V) :: #{ role_label => closed_variant(Obj, V)
                                   , role_lens => lens(A, B, S, T)
                                   }.

-type label(Obj, T, Var, U) :: #{ label_closed => closed_variant(Obj, T)
                                , label_open => open_variant(Var, U)
                                }.

-type out(Lab) :: #{ '__out_witness' => Lab }.

-type inp(Lab) :: #{ '__inp_witness' => Lab }.

-spec lens_a() -> lens(A, B, {session(A), C, D}, {session(B), C, D}).
lens_a() ->
  #{ get => fun
  ({A, _, _}) -> A
end
   , put => fun
  ({_, B, C}, A) -> {A, B, C}
end
   }.

-spec lens_b() -> lens(A, B, {C, session(A), D}, {C, session(B), D}).
lens_b() ->
  #{ get => fun
  ({_, B, _}) -> B
end
   , put => fun
  ({A, _, C}, B) -> {A, B, C}
end
   }.

-spec lens_c() -> lens(A, B, {C, D, session(A)}, {C, D, session(B)}).
lens_c() ->
  #{ get => fun
  ({_, _, C}) -> C
end
   , put => fun
  ({A, B, _}, C) -> {A, B, C}
end
   }.

-spec alice() -> role(A, B, {session(A), C, D}, {session(B), C, D}, {alice, E}
   , E).
alice() ->
  #{ role_label => fun
  ({alice, V}) -> V
end
   , role_lens => lens_a()
   }.

-spec bob() -> role(A, B, {C, session(A), D}, {C, session(B), D}, {bob, E}
 , E).
bob() ->
  #{ role_label => fun
  ({bob, V}) -> V
end
   , role_lens => lens_b()
   }.

-spec carol() -> role(A, B, {C, D, session(A)}, {C, D, session(B)}, {carol, E}
   , E).
carol() ->
  #{ role_label => fun
  ({carol, V}) -> V
end
   , role_lens => lens_c()
   }.

-spec hello() -> label({hello, A}
   , A, {hello, B}
   , B).
hello() ->
  #{ label_closed => fun
  ({hello, V}) -> V
end
   , label_open => fun
  (V) -> {hello, V}
end
   }.

-spec goodbye() -> label({goodbye, A}
     , A, {goodbye, B}
     , B).
goodbye() ->
  #{ label_closed => fun
  ({goodbye, V}) -> V
end
   , label_open => fun
  (V) -> {goodbye, V}
end
   }.

-spec list_match(fun((_a) -> _b), list(_a)) -> _b.
list_match(_, _) -> raw:assertfalse().

-spec hello_or_goodbye() -> disj({goodbye, A}
              | {hello, B}
              , {hello, B}
              , {goodbye, A}
              ).
hello_or_goodbye() ->
  #{ concat => fun
  (L, R) -> [{hello, list_match(fun
  ({hello, V}) -> V
end, L)} | [{goodbye, list_match(fun
  ({goodbye, V}) -> V
end, R)} | []]]
end
   , split => fun
  (Lr) -> {[{hello, list_match(fun
  ({hello, V}) -> V;
  ({goodbye, _}) -> raw:dontknow()
end, Lr)} | []], [{goodbye, list_match(fun
  ({goodbye, V}) -> V;
  ({hello, _}) -> raw:dontknow()
end, Lr)} | []]}
end
   }.

-spec open_variant_to_tag(open_variant(_, _)) -> polyvar:tag().
open_variant_to_tag(Var) ->
  {Roletag, _} = raw:destruct_polyvar(Var(raw:dontknow())),
  Roletag.

-spec send(session(_var), open_variant(_var, out(_lab)), open_variant(_lab, {_v, session(_c)}), _v) -> session(_c).
send(Sess, Role, Label, V) ->
  Roletag = open_variant_to_tag(Role),
  Labeltag = open_variant_to_tag(Label),
  begin
    transport:raw_send(maps:get(mpchan, Sess), Roletag, Labeltag, V),
    #{ mpchan => maps:get(mpchan, Sess)
     , dummy_witness => raw:dontknow()
     }
  end.

-spec receive_(session(_var), open_variant(_var, inp(_lab))) -> _lab.
receive_(Sess, Role) ->
  Roletag = open_variant_to_tag(Role),
  {Labeltag, V} = transport:raw_receive(Roletag),
  Cont = #{ mpchan => maps:get(mpchan, Sess)
   , dummy_witness => raw:dontknow()
   },
  raw:make_polyvar(Labeltag, {V, Cont}).

-spec close(session(ok)) -> ok.
close(_) -> ok.

-spec comm(fun(() -> role(_s, _to_, _mid, _cur, _from, inp(_inplab))), fun(() -> role(_t, _from, _next, _mid, _to_, out(_outlab))), fun(() -> label(_outlab, {_v, session(_s)}, _inplab, {_v, session(_t)})), fun(() -> _next)) -> _cur.
comm(_from, _to, _label, _next) -> raw:dontknow().

-spec finish() -> global(ok, ok, ok).
finish() -> raw:dontknow().

-spec from_some(option:t(A)) -> A.
from_some(Opt) ->
  case Opt of
    {some, V} -> V;
    none -> raw:fail()
  end.

-spec start(global(_, _, _), fun((transport:payload()) -> ok), fun((transport:payload()) -> ok), fun((transport:payload()) -> ok)) -> ok.
start(_g, Fa, Fb, Fc) ->
  Pid_a = process:make(fun
  (_, Recv) ->
  {_, _, Ch_a} = from_some(Recv(infinity)),
  Fa(Ch_a)
end),
  Pid_b = process:make(fun
  (_, Recv) ->
  {_, _, Ch_b} = from_some(Recv(infinity)),
  Fb(Ch_b)
end),
  Pid_c = process:make(fun
  (_, Recv) ->
  {_, _, Ch_c} = from_some(Recv(infinity)),
  Fc(Ch_c)
end),
  Map_list = [{open_variant_to_tag(fun
  (X) -> {alice, X}
end), Pid_a} | [{open_variant_to_tag(fun
  (X) -> {bob, X}
end), Pid_b} | [{open_variant_to_tag(fun
  (X) -> {carol, X}
end), Pid_c} | []]]],
  Ch_a = #{ mpchan => #{ self => open_variant_to_tag(fun
  (X) -> {alice, X}
end)
 , channels => maps:from_list(Map_list)
 }
   , dummy_witness => raw:dontknow()
   },
  Ch_b = #{ mpchan => #{ self => open_variant_to_tag(fun
  (X) -> {bob, X}
end)
 , channels => maps:from_list(Map_list)
 }
   , dummy_witness => raw:dontknow()
   },
  Ch_c = #{ mpchan => #{ self => open_variant_to_tag(fun
  (X) -> {carol, X}
end)
 , channels => maps:from_list(Map_list)
 }
   , dummy_witness => raw:dontknow()
   },
  Dummy_role = open_variant_to_tag(fun
  (X) -> {dummy, X}
end),
  Dummy_label = open_variant_to_tag(fun
  (X) -> {dummy, X}
end),
  begin
    process:send(Pid_a, {Dummy_label, Dummy_role, transport:payload_cast(Ch_a)}),
    process:send(Pid_b, {Dummy_label, Dummy_role, transport:payload_cast(Ch_b)}),
    process:send(Pid_c, {Dummy_label, Dummy_role, transport:payload_cast(Ch_c)}),
    ok
  end.

-spec main() -> ok.
main() -> start(comm(fun alice/0, fun bob/0, fun hello/0, fun finish/0), fun
  (Ch) ->
  Ch_prime = send(payload_to_session(Ch), fun
  (X) -> {bob, X}
end, fun
  (X) -> {hello, X}
end, 123),
  close(Ch_prime)
end, fun
  (Ch) ->
  {hello, {_v, Ch_prime}} = receive_(payload_to_session(Ch), fun
  (X) -> {alice, X}
end),
  close(Ch_prime)
end, fun
  (Ch) -> close(payload_to_session(Ch))
end).


