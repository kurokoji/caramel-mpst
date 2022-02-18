% Source code generated with Caramel.
-module(main2).
-export_type([phantom/1]).

-export([a/1]).
-export([alice/0]).
-export([b/1]).
-export([bob/0]).
-export([c/1]).
-export([carol/0]).
-export([g/0]).
-export([get_alice_typ/1]).
-export([get_bob_typ/1]).
-export([get_carol_typ/1]).
-export([goodbye/0]).
-export([hello/0]).
-export([hello_or_goodbye/0]).
-export([integer/0]).
-export([main/0]).
-export([res/0]).
-export([to_bob/1]).

-type phantom(A) :: A.

-spec get_alice_typ(caramel_mpst:global(_a, _, _)) -> phantom(_a).
get_alice_typ(_x) -> raw:dontknow().

-spec get_bob_typ(caramel_mpst:global(_, _b, _)) -> phantom(_b).
get_bob_typ(_x) -> raw:dontknow().

-spec get_carol_typ(caramel_mpst:global(_, _, _c)) -> phantom(_c).
get_carol_typ(_x) -> raw:dontknow().

-spec alice() -> caramel_mpst:role(A, B, {caramel_mpst:session(A), C, D}, {caramel_mpst:session(B), C, D}, {alice, E}
   , E).
alice() ->
  #{ role_label => fun
  ({alice, V}) -> V
end
   , role_lens => caramel_mpst:lens_a()
   }.

-spec bob() -> caramel_mpst:role(A, B, {C, caramel_mpst:session(A), D}, {C, caramel_mpst:session(B), D}, {bob, E}
 , E).
bob() ->
  #{ role_label => fun
  ({bob, V}) -> V
end
   , role_lens => caramel_mpst:lens_b()
   }.

-spec carol() -> caramel_mpst:role(A, B, {C, D, caramel_mpst:session(A)}, {C, D, caramel_mpst:session(B)}, {carol, E}
   , E).
carol() ->
  #{ role_label => fun
  ({carol, V}) -> V
end
   , role_lens => caramel_mpst:lens_c()
   }.

-spec hello() -> caramel_mpst:label({hello, A}
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

-spec goodbye() -> caramel_mpst:label({goodbye, A}
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

-spec to_bob(caramel_mpst:disj(A, B, C)) -> caramel_mpst:disj({bob, caramel_mpst:out(A)}
    , {bob, caramel_mpst:out(B)}
    , {bob, caramel_mpst:out(C)}
    ).
to_bob(Dis) ->
  Concat = maps:get(concat, Dis),
  Split = maps:get(split, Dis),
  #{ concat => fun
  (L, R) -> lists:map(fun
  (V) -> {bob, #{ '__out_witness' => V }}
end, Concat(lists:map(fun
  ({bob, V}) -> maps:get('__out_witness', V)
end, L), lists:map(fun
  ({bob, V}) -> maps:get('__out_witness', V)
end, R)))
end
   , split => fun
  (Lr) ->
  {L, R} = Split(lists:map(fun
  ({bob, V}) -> maps:get('__out_witness', V)
end, Lr)),
  {lists:map(fun
  (V) -> {bob, #{ '__out_witness' => V }}
end, L), lists:map(fun
  (V) -> {bob, #{ '__out_witness' => V }}
end, R)}
end
   }.

-spec hello_or_goodbye() -> caramel_mpst:disj({goodbye, A}
              | {hello, B}
              , {hello, B}
              , {goodbye, A}
              ).
hello_or_goodbye() ->
  #{ concat => fun
  (L, R) -> [{hello, caramel_mpst:list_match(fun
  ({hello, V}) -> V
end, L)} | [{goodbye, caramel_mpst:list_match(fun
  ({goodbye, V}) -> V
end, R)} | []]]
end
   , split => fun
  (Lr) -> {[{hello, caramel_mpst:list_match(fun
  ({hello, V}) -> V;
  ({goodbye, _}) -> raw:dontknow()
end, Lr)} | []], [{goodbye, caramel_mpst:list_match(fun
  ({goodbye, V}) -> V;
  ({hello, _}) -> raw:dontknow()
end, Lr)} | []]}
end
   }.

-spec integer() -> caramel_mpst:label({integer, A}
     , A, {integer, B}
     , B).
integer() ->
  #{ label_closed => fun
  ({integer, V}) -> V
end
   , label_open => fun
  (V) -> {integer, V}
end
   }.

-spec res() -> caramel_mpst:label({res, A}
 , A, {res, B}
 , B).
res() ->
  #{ label_closed => fun
  ({res, V}) -> V
end
   , label_open => fun
  (V) -> {res, V}
end
   }.

-spec g() -> {caramel_mpst:session({bob, caramel_mpst:out({integer, {A, caramel_mpst:session({bob, caramel_mpst:out({integer, {B, caramel_mpst:session({bob, caramel_mpst:inp({res, {C, caramel_mpst:session({carol, caramel_mpst:out({integer, {D, caramel_mpst:session({carol, caramel_mpst:inp({res, {E, caramel_mpst:session(ok)}}
)}
)}}
)}
)}}
)}
)}}
)}
)}}
)}
), caramel_mpst:session({alice, caramel_mpst:inp({integer, {A, caramel_mpst:session({alice, caramel_mpst:inp({integer, {B, caramel_mpst:session({alice, caramel_mpst:out({res, {C, caramel_mpst:session(ok)}}
)}
)}}
)}
)}}
)}
), caramel_mpst:session({alice, caramel_mpst:inp({integer, {D, caramel_mpst:session({alice, caramel_mpst:out({res, {E, caramel_mpst:session(ok)}}
)}
)}}
)}
)}.
g() -> caramel_mpst:comm(fun alice/0, fun bob/0, fun integer/0, fun
  () -> caramel_mpst:comm(fun alice/0, fun bob/0, fun integer/0, fun
  () -> caramel_mpst:comm(fun bob/0, fun alice/0, fun res/0, fun
  () -> caramel_mpst:comm(fun alice/0, fun carol/0, fun integer/0, fun
  () -> caramel_mpst:comm(fun carol/0, fun alice/0, fun res/0, fun caramel_mpst:finish/0)
end)
end)
end)
end).

-spec a(caramel_mpst:session(phantom({bob, caramel_mpst:out({integer, {integer(), caramel_mpst:session({bob, caramel_mpst:out({integer, {integer(), caramel_mpst:session({bob, caramel_mpst:inp({res, {integer(), caramel_mpst:session({carol, caramel_mpst:out({integer, {integer(), caramel_mpst:session({carol, caramel_mpst:inp({res, {integer(), caramel_mpst:session(ok)}}
)}
)}}
)}
)}}
)}
)}}
)}
)}}
)}
))) -> ok.
a(Ch) ->
  get_alice_typ(g()),
  P1 = 2,
  P2 = 4,
  Ch1 = caramel_mpst:send(Ch, fun
  (X) -> {bob, X}
end, fun
  (X) -> {integer, X}
end, P1),
  Ch2 = caramel_mpst:send(Ch1, fun
  (X) -> {bob, X}
end, fun
  (X) -> {integer, X}
end, P2),
  {res, {Value1, Ch3}} = caramel_mpst:recv(Ch2, fun
  (X) -> {bob, X}
end),
  begin
    io:format(<<"Plus: ~p + ~p = ~p~n">>, [P1 | [P2 | [Value1 | []]]]),
    Ch4 = caramel_mpst:send(Ch3, fun
  (X) -> {carol, X}
end, fun
  (X) -> {integer, X}
end, Value1),
    {res, {Value2, Ch5}} = caramel_mpst:recv(Ch4, fun
  (X) -> {carol, X}
end),
    begin
      io:format(<<"Square: ~p * ~p = ~p~n">>, [Value1 | [Value1 | [Value2 | []]]]),
      caramel_mpst:close(Ch5)
    end
  end.

-spec b(caramel_mpst:session(phantom({alice, caramel_mpst:inp({integer, {integer(), caramel_mpst:session({alice, caramel_mpst:inp({integer, {integer(), caramel_mpst:session({alice, caramel_mpst:out({res, {integer(), caramel_mpst:session(ok)}}
)}
)}}
)}
)}}
)}
))) -> ok.
b(Ch) ->
  get_bob_typ(g()),
  {integer, {Value1, Ch1}} = caramel_mpst:recv(Ch, fun
  (X) -> {alice, X}
end),
  {integer, {Value2, Ch2}} = caramel_mpst:recv(Ch1, fun
  (X) -> {alice, X}
end),
  Ch3 = caramel_mpst:send(Ch2, fun
  (X) -> {alice, X}
end, fun
  (X) -> {res, X}
end, erlang:'+'(Value1, Value2)),
  caramel_mpst:close(Ch3).

-spec c(caramel_mpst:session(phantom({alice, caramel_mpst:inp({integer, {integer(), caramel_mpst:session({alice, caramel_mpst:out({res, {integer(), caramel_mpst:session(ok)}}
)}
)}}
)}
))) -> ok.
c(Ch) ->
  get_carol_typ(g()),
  {integer, {Value, Ch1}} = caramel_mpst:recv(Ch, fun
  (X) -> {alice, X}
end),
  Ch2 = caramel_mpst:send(Ch1, fun
  (X) -> {alice, X}
end, fun
  (X) -> {res, X}
end, erlang:'*'(Value, Value)),
  caramel_mpst:close(Ch2).

-spec main() -> ok.
main() -> caramel_mpst:start(g(), fun a/1, fun b/1, fun c/1).


