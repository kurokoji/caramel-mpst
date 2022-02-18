open Caramel_mpst;

type phantom('a) = 'a;

let get_alice_typ: global('a, 'b, 'c) => phantom('a) = _x => Raw.dontknow();
let get_bob_typ: global('a, 'b, 'c) => phantom('b) = _x => Raw.dontknow();
let get_carol_typ: global('a, 'b, 'c) => phantom('c) = _x => Raw.dontknow();

let alice = () => {
  Caramel_mpst.role_label: ((`Alice(v)):[`Alice('a)]) => v,
  role_lens: Caramel_mpst.lens_a(),
};

let bob = () => {
  Caramel_mpst.role_label: ((`Bob(v)):[`Bob('b)]) => v,
  role_lens: Caramel_mpst.lens_b(),
};

let carol = () => {
  Caramel_mpst.role_label: ((`Carol(v)):[`Carol('c)]) => v,
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

let req = () => {
  Caramel_mpst.label_closed: (`req(v)) => v,
  Caramel_mpst.label_open: v => `req(v),
};

let ac = () => {
  Caramel_mpst.label_closed: (`ac(v)) => v,
  Caramel_mpst.label_open: v => `ac(v),
};
let rej = () => {
  Caramel_mpst.label_closed: (`rej(v)) => v,
  Caramel_mpst.label_open: v => `rej(v),
};

let present = () => {
  Caramel_mpst.label_closed: (`present(v)) => v,
  Caramel_mpst.label_open: v => `present(v),
};
let to_alice = (dis): disj('lr, 'l, 'r) => {
  let concat = dis.concat;
  let split = dis.split;
  {
    concat: (l, r) =>
      Lists.map(
        v => `Alice({__out_witness: v}),
        concat(
          Lists.map((`Alice(v)) => v.__out_witness, l),
          Lists.map((`Alice(v)) => v.__out_witness, r),
        ),
      ),

    split: lr => {
      let (l, r) = split(Lists.map((`Alice(v)) => v.__out_witness, lr));
      (
        Lists.map(v => `Alice({__out_witness: v}), l),
        Lists.map(v => `Alice({__out_witness: v}), r),
      );
    },
  };
};

let to_bob = (dis): disj('lr, 'l, 'r) => {
  let concat = dis.concat;
  let split = dis.split;
  {
    concat: (l, r) =>
      Lists.map(
        v => `Bob({__out_witness: v}),
        concat(
          Lists.map((`Bob(v)) => v.__out_witness, l),
          Lists.map((`Bob(v)) => v.__out_witness, r),
        ),
      ),

    split: lr => {
      let (l, r) = split(Lists.map((`Bob(v)) => v.__out_witness, lr));
      (
        Lists.map(v => `Bob({__out_witness: v}), l),
        Lists.map(v => `Bob({__out_witness: v}), r),
      );
    },
  };
};

let ac_or_rej: unit => Caramel_mpst.disj('lr, 'l, 'r) =
  () => {
    split: lr => (
      [
        `ac(
          Caramel_mpst.list_match(
            fun
            | `ac(v) => v
            | `rej(_) => Raw.dontknow(),
            lr,
          ),
        ),
      ],
      [
        `rej(
          Caramel_mpst.list_match(
            fun
            | `rej(v) => v
            | `ac(_) => Raw.dontknow(),
            lr,
          ),
        ),
      ],
    ),
    concat: (l, r) => [
      `ac(Caramel_mpst.list_match((`ac(v)) => v, l)),
      `rej(Caramel_mpst.list_match((`rej(v)) => v, r)),
    ],
  };

// 不適切なプロトコルの例
/* 
 let g = () => {
   Caramel_mpst.choice_at(
     alice,
     to_bob(hello_or_goodbye()),
     (
       alice,
       () =>
         Caramel_mpst.comm(alice, bob, hello, () =>
           Caramel_mpst.comm(bob, carol, hello, () =>
             Caramel_mpst.comm(carol, bob, hello, Caramel_mpst.finish)
           )
         ),
     ),
     (
       alice,
       () =>
         Caramel_mpst.comm(alice, carol, goodbye, () =>
           Caramel_mpst.comm(carol, bob, goodbye, Caramel_mpst.finish)
         ),
     ),
   );
 };
 */
 /*
 let g = () => {
   Caramel_mpst.choice_at(
     alice,
     to_bob(hello_or_goodbye()),
     (
       alice,
       () =>
         Caramel_mpst.comm(alice, bob, hello, () =>
           Caramel_mpst.comm(bob, carol, hello, () =>
             Caramel_mpst.comm(carol, alice, hello, Caramel_mpst.finish)
           )
         ),
     ),
     (
       alice,
       () =>
         Caramel_mpst.comm(alice, bob, goodbye, () =>
           Caramel_mpst.comm(bob, carol, goodbye, Caramel_mpst.finish)
         ),
     ),
   );
 };
 */

 let g = () => {
   Caramel_mpst.comm(alice, bob, req, () => 
    Caramel_mpst.choice_at(
      bob,
      to_alice(ac_or_rej()),
      (
        bob,
        () =>
          Caramel_mpst.comm(bob, alice, ac, () =>
            Caramel_mpst.comm(alice, carol, present, Caramel_mpst.finish)
          ),
      ),
      (
        bob,
        () => Caramel_mpst.comm(bob, alice, rej, () => 
          Caramel_mpst.comm(alice, carol, rej, Caramel_mpst.finish))
      ),
    ));
 };


let fa = (ch: session('a)) => {
  let _: phantom('a) = get_alice_typ(g());

  // 発行申請を忘れている
  // let ch1 = send(ch, x => `Bob(x), x => `req(x), true);

  let ch2 = switch (recv(ch, x => `Bob(x))) {
    | `ac(v, ch1) => 
      send(ch1, x => `Carol(x), x => `present(x), v)
    | `rej(_, ch1) => 
      send(ch1, x => `Carol(x), x => `rej(x), false)
  };

  close(ch2);
};

let start = (g, fa, fb, fc) => {
  let pid_a = Process.make((...) => {
    let pids = recv();
    fa(make_session(pids));
  }); 
  ...
  // fb, fcも同様にして起動

  let pids = {
    `Alice: pid_a,
    `Bob: pid_b,
    `Carol: pid_c
  };

  // 全員にpidを配る
  Process.send(pid_a, pids);
  Process.send(pid_b, pids);
  Process.send(pid_c, pids);
};


let a = (ch: session('a)) => {
  let _: phantom('a) = get_alice_typ(g());

  let ch1 = Caramel_mpst.send(ch, x => `Bob(x), x => `req(x), true);

  let ch3 = switch (Caramel_mpst.recv(ch1, x => `Bob(x))) {
    | `ac(v, ch2) => 
          Caramel_mpst.send(ch2, x => `Carol(x), x => `present(x), v)
    | `rej(_, ch2) => 
          Caramel_mpst.send(ch2, x => `Carol(x), x => `rej(x), false)
  };

  Caramel_mpst.close(ch3);

/*
  if (true) {
    let ch1 = Caramel_mpst.send(ch, x => `Bob(x), x => `hello(x), 123);
    switch (Caramel_mpst.recv(ch1, x => `Carol(x))) {
    | `hello(_v, ch2) => Caramel_mpst.close(ch2)
    };
  } else {
    let ch1 = Caramel_mpst.send(ch, x => `Bob(x), x => `goodbye(x), 123);
    Caramel_mpst.close(ch1);
  };

  Io.format("Alice~n", []);
  */
};

 let b = (ch: session('b)) => {
   let _: phantom('b) = get_bob_typ(g());
   /*
   let ch3 =
     switch (Caramel_mpst.recv(ch, x => `Alice(x))) {
     | `hello(v, ch2) =>
       Caramel_mpst.send(ch2, x => `Carol(x), x => `hello(x), v + 123)
     | `goodbye(_v, ch2) =>
       // Caramel_mpst.send(ch2, x => `Carol(x), x => `goodbye(x), "foo")
       let `goodbye(_, ch3) = Caramel_mpst.recv(ch2, x => `Carol(x));
     };
   Caramel_mpst.close(ch3);
   Io.format("Bob~n", []);
   */
 };

 let c = (ch: session('c)) => {
   /*
   let _: phantom('c) = get_carol_typ(g());
   let ch3 =
     switch (Caramel_mpst.recv(ch, x => `Bob(x))) {
     | `hello(_v, ch2) => {
       Io.format("~p~n", [_v]);
       Caramel_mpst.send(ch2, x => `Alice(x), x => `hello(x), 123)
     };
     | `goodbye(_v, ch2) => {
       Io.format("~p~n", [_v]);
       ch2;
     }
     };
   Caramel_mpst.close(ch3);
   Io.format("Carol~n", []);
   */
 };


let main = () => {
  Caramel_mpst.start(g(), a, b, c);
};
