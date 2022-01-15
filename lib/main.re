let alice = () => {
  Caramel_mpst.role_label: (`Alice(v)) => v,
  role_lens: Caramel_mpst.lens_a(),
};

let bob = () => {
  Caramel_mpst.role_label: (`Bob(v)) => v,
  role_lens: Caramel_mpst.lens_b(),
};

let carol = () => {
  Caramel_mpst.role_label: (`Carol(v)) => v,
  role_lens: Caramel_mpst.lens_c(),
};
let hello = () => {
  Caramel_mpst.label_closed: (`hello(v)) => v,
  Caramel_mpst.label_open: v => `hello(v),
};
let goodbye = () => {
  Caramel_mpst.label_closed: (`goodbye(v)) => v,
  Caramel_mpst.label_open: v => `goodbye(v),
};

let hello_or_goodbye: unit => Caramel_mpst.disj('lr, 'l, 'r) =
  () => {
    split: lr => (
      [
        `hello(
          Caramel_mpst.list_match(
            fun
            | `hello(v) => v
            | `goodbye(_) => Raw.dontknow(),
            lr,
          ),
        ),
      ],
      [
        `goodbye(
          Caramel_mpst.list_match(
            fun
            | `goodbye(v) => v
            | `hello(_) => Raw.dontknow(),
            lr,
          ),
        ),
      ],
    ),
    concat: (l, r) => [
      `hello(Caramel_mpst.list_match((`hello(v)) => v, l)),
      `goodbye(Caramel_mpst.list_match((`goodbye(v)) => v, r)),
    ],
  };

let g = () => {
  Caramel_mpst.choice_at(
    alice,
    Caramel_mpst.to_bob(hello_or_goodbye()),
    (
      alice,
      () => Caramel_mpst.comm(
        alice,
        bob,
        hello,
        () => Caramel_mpst.comm(bob, carol, hello, () => Caramel_mpst.comm(carol, alice, hello, Caramel_mpst.finish)),
      ),
    ),
    (
      alice,
      () => Caramel_mpst.comm(
        alice,
        bob,
        goodbye, () => Caramel_mpst.comm(bob, carol, goodbye, Caramel_mpst.finish))),
  );
}

let a = ch =>
  if (true) {
    let ch1 = Caramel_mpst.send(Caramel_mpst.payload_to_session(ch), x => `Bob(x), x => `hello(x), 123);
    switch (Caramel_mpst.receive_(ch1, x => `Carol(x))) {
    | `hello(_v, ch2) => Caramel_mpst.close(ch2)
    };
  } else {
    let ch1 = Caramel_mpst.send(Caramel_mpst.payload_to_session(ch), x => `Bob(x), x => `goodbye(x), 123);
    Caramel_mpst.close(ch1);
  };

let b = ch => {
  let ch3 =
    switch (Caramel_mpst.receive_(Caramel_mpst.payload_to_session(ch), x => `Alice(x))) {
    | `hello(v, ch2) => Caramel_mpst.send(ch2, x => `Carol(x), x => `hello(x), v + 123)
    | `goodbye(_v, ch2) =>
      Caramel_mpst.send(ch2, x => `Carol(x), x => `goodbye(x), "foo")
    };
  Caramel_mpst.close(ch3);
};

let c = ch => {
  let ch3 =
    switch (Caramel_mpst.receive_(Caramel_mpst.payload_to_session(ch), x => `Bob(x))) {
    | `hello(_v, ch2) =>
      Caramel_mpst.send(ch2, x => `Alice(x), x => `hello(x), 123)
    | `goodbye(_v, ch2) => ch2
    };
  Caramel_mpst.close(ch3);
};

/*
let main = () => {
  Caramel_mpst.start(
    Caramel_mpst.comm(alice, bob, hello, Caramel_mpst.finish),
    ch => {
      // Alice
      // payloadにキャストされて送られてくるのでsession型にキャストしなおす必要がある
      let ch' =
        Caramel_mpst.send(
          Caramel_mpst.payload_to_session(ch),
          x => `Bob(x),
          x => `hello(x),
          123,
        );
      // Io.format("Alice ch => ~p~n", [ch']);
      Caramel_mpst.close(ch');
    },
    ch => {
      Io.format("Bob ch => ~p~n", [ch]);
      // Bob
      let `hello(_v, ch') =
        Caramel_mpst.receive_(Caramel_mpst.payload_to_session(ch), x =>
          `Alice(x)
        );

      Io.format("Bob recv value => ~p~n", [_v]);
      Caramel_mpst.close(ch');
    },
    ch => {
      // Carol
      Caramel_mpst.close(Caramel_mpst.payload_to_session(ch))
    },
  );
};

*/

let main = () => {
  Caramel_mpst.start(g(), a, b, c);
}

/*
let main = () => {
  Caramel_mpst.start(
    Caramel_mpst.comm(alice, bob, hello, () => Caramel_mpst.comm(bob, alice, hello, Caramel_mpst.finish)),
    ch => {
      // Alice
      // payloadにキャストされて送られてくるのでsession型にキャストしなおす必要がある
      let ch' =
        Caramel_mpst.send(
          Caramel_mpst.payload_to_session(ch),
          x => `Bob(x),
          x => `hello(x),
          123,
        );
      

      let `hello(_v, ch'') = Caramel_mpst.receive_(ch', x => `Bob(x));

      Io.format("From Bob => ~p~n", [_v]);

      // Io.format("Alice ch => ~p~n", [ch']);
      Caramel_mpst.close(ch'');
    },
    ch => {
      // Io.format("Bob ch => ~p~n", [ch]);
      // Bob
      let `hello(_v, ch') =
        Caramel_mpst.receive_(Caramel_mpst.payload_to_session(ch), x =>
          `Alice(x)
        );
      
      Io.format("From alice => ~p~n", [_v]);

      let ch'' = Caramel_mpst.send(
        ch',
        x => `Alice(x),
        x => `hello(x),
        345
      );

      Caramel_mpst.close(ch'');
    },
    ch => {
      // Carol
      Caramel_mpst.close(Caramel_mpst.payload_to_session(ch))
    },
  );
};
*/