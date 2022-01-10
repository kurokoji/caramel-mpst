-module(raw).

-export([fail/1]).
-export([dontknow/0]).
-export([assertfalse/0]).
-export([todo/0]).
-export([guarded_receive/1]).
-export([make_polyvar/2]).
-export([destruct_polyvar/1]).

fail(X) -> erlang:error(X).

dontknow() -> dontknow.

assertfalse() -> throw(assertfalse).

todo() -> todo.

guarded_receive(From) ->
    receive
        X when element(0, X) == From ->
        X
    end.

make_polyvar(Tag, V) -> {Tag, V}.

destruct_polyvar({Tag, V}) -> {Tag, V}.
