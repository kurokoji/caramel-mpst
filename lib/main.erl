% Source code generated with Caramel.
-module(main).

-export([a/1]).
-export([alice/0]).
-export([b/1]).
-export([bob/0]).
-export([c/1]).
-export([carol/0]).
-export([g/0]).
-export([goodbye/0]).
-export([hello/0]).
-export([hello_or_goodbye/0]).
-export([main/0]).

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

-spec g() -> {caramel_mpst:session({bob, caramel_mpst:out({goodbye, {A, caramel_mpst:session(ok)}}
| {hello, {B, caramel_mpst:session({carol, caramel_mpst:inp({hello, {C, caramel_mpst:session(ok)}}
 )}
 )}}
)}
), caramel_mpst:session({alice, caramel_mpst:inp({hello, {B, caramel_mpst:session({carol, caramel_mpst:out({hello, {D, caramel_mpst:session(ok)}}
)}
)}}
), caramel_mpst:inp({goodbye, {A, caramel_mpst:session({carol, caramel_mpst:out({goodbye, {E, caramel_mpst:session(ok)}}
)}
)}}
)}
), caramel_mpst:session({bob, caramel_mpst:inp({hello, {D, caramel_mpst:session({alice, caramel_mpst:out({hello, {C, caramel_mpst:session(ok)}}
)}
)}}
), caramel_mpst:inp({goodbye, {E, caramel_mpst:session(ok)}}
)}
)}.
g() -> caramel_mpst:choice_at(fun alice/0, caramel_mpst:to_bob(hello_or_goodbye()), {fun alice/0, fun
  () -> caramel_mpst:comm(fun alice/0, fun bob/0, fun hello/0, fun
  () -> caramel_mpst:comm(fun bob/0, fun carol/0, fun hello/0, fun
  () -> caramel_mpst:comm(fun carol/0, fun alice/0, fun hello/0, fun caramel_mpst:finish/0)
end)
end)
end}, {fun alice/0, fun
  () -> caramel_mpst:comm(fun alice/0, fun bob/0, fun goodbye/0, fun
  () -> caramel_mpst:comm(fun bob/0, fun carol/0, fun goodbye/0, fun caramel_mpst:finish/0)
end)
end}).

-spec a(transport:payload()) -> ok.
a(Ch) ->
  case true of
    true -> Ch1 = caramel_mpst:send(caramel_mpst:payload_to_session(Ch), fun
  (X) -> {bob, X}
end, fun
  (X) -> {hello, X}
end, 123),
case caramel_mpst:receive_(Ch1, fun
  (X) -> {carol, X}
end) of
  {hello, {_v, Ch2}} -> caramel_mpst:close(Ch2)
end;
    false -> Ch1 = caramel_mpst:send(caramel_mpst:payload_to_session(Ch), fun
  (X) -> {bob, X}
end, fun
  (X) -> {goodbye, X}
end, 123),
caramel_mpst:close(Ch1)
  end.

-spec b(transport:payload()) -> ok.
b(Ch) ->
  Ch3 = case caramel_mpst:receive_(caramel_mpst:payload_to_session(Ch), fun
  (X) -> {alice, X}
end) of
    {hello, {V, Ch2}} -> caramel_mpst:send(Ch2, fun
  (X) -> {carol, X}
end, fun
  (X) -> {hello, X}
end, erlang:'+'(V, 123));
    {goodbye, {_v, Ch2}} -> caramel_mpst:send(Ch2, fun
  (X) -> {carol, X}
end, fun
  (X) -> {goodbye, X}
end, <<"foo">>)
  end,
  caramel_mpst:close(Ch3).

-spec c(transport:payload()) -> ok.
c(Ch) ->
  Ch3 = case caramel_mpst:receive_(caramel_mpst:payload_to_session(Ch), fun
  (X) -> {bob, X}
end) of
    {hello, {_v, Ch2}} -> caramel_mpst:send(Ch2, fun
  (X) -> {alice, X}
end, fun
  (X) -> {hello, X}
end, 123);
    {goodbye, {_v, Ch2}} -> Ch2
  end,
  caramel_mpst:close(Ch3).

-spec main() -> ok.
main() -> caramel_mpst:start(g(), fun a/1, fun b/1, fun c/1).


