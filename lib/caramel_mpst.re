type session('a) = {
  mpchan: Transport.mpchan,
  dummy_witness: 'a,
};

type global('a, 'b, 'c) = (session('a), session('b), session('c));

type lens('a, 'b, 's, 't) = {
  get: 's => session('a),
  put: ('s, session('b)) => 't,
};

let lens_a = () => {
  get: ((a, _, _)) => a,
  put: ((_, b, c), a) => (a, b, c),
};
let lens_b = () => {
  get: ((_, b, _)) => b,
  put: ((a, _, c), b) => (a, b, c),
};
let lens_c = () => {
  get: ((_, _, c)) => c,
  put: ((a, b, _), c) => (a, b, c),
};

// 多相ヴァリアントのコンストラクタ. open_variant([> `Bob('v)], 'v)
// [`Bob; `Carol; `Alice] <<-- list([> `Alice | `Bob | `Carol])
type open_variant('var, 'v) = 'v => 'var;

// (fun | `Bob(v) => v | `Alice(v) => v) : [< `Bob('v) | `Alice('v)] => 'v
type closed_variant('var, 'v) = 'var => 'v;

type disj('lr, 'l, 'r) = {
  concat: (list('l), list('r)) => list('lr),
  split: list('lr) => (list('l), list('r)),
};

type role('a, 'b, 's, 't, 'obj, 'v) = {
  role_label: closed_variant('obj, 'v),
  role_lens: lens('a, 'b, 's, 't),
};

type label('obj, 't, 'var, 'u) = {
  label_closed: closed_variant('obj, 't),
  label_open: open_variant('var, 'u),
};

type out('lab) = {__out_witness: 'lab};

type inp('lab) = {__inp_witness: 'lab};

let list_match: ('a => 'b, list('a)) => 'b = (_, _) => Raw.assertfalse();

// (x => `Bob(x))  を Erlang のアトム bob に変換する
let open_variant_to_tag: 'var. open_variant('var, _) => Polyvar.tag =
  var => {
    let (roletag, _) = Raw.destruct_polyvar(var(Raw.dontknow()));
    roletag;
  };

let send:
  'var 'lab 'v 'c.
  (
    session('var),
    open_variant('var, out('lab)),
    open_variant('lab, ('v, session('c))),
    'v
  ) =>
  session('c)
 =
  // payload
  // x => `hello(x)
  // x => `Bob(x)
  // mpchan のところに pid の一覧が入っている
  (sess, role, label, v) => {
    let roletag /* アトムbob */ = open_variant_to_tag(role);
    let labeltag /* hello */ = open_variant_to_tag(label);
    Transport.raw_send(sess.mpchan, roletag, labeltag, v);
    {mpchan: sess.mpchan, dummy_witness: Raw.dontknow()};
  };

let receive_:
  'var 'lab.
  (session('var), open_variant('var, inp('lab))) => 'lab
 =
  (sess, role) => {
    let roletag = open_variant_to_tag(role);
    let (labeltag, v) = Transport.raw_receive(~from=roletag);
    let cont = {mpchan: sess.mpchan, dummy_witness: Raw.dontknow()};
    Raw.make_polyvar(labeltag, (v, cont));
  };

let close: session(unit) => unit = _ => ();

let comm:
  'from 'to_ 'outlab 'inplab 's 't 'v 'next 'mid 'cur.
  (
    unit => role('s, 'to_, 'mid, 'cur, 'from, inp('inplab)),
    unit => role('t, 'from, 'next, 'mid, 'to_, out('outlab)),
    unit => label('outlab, ('v, session('s)), 'inplab, ('v, session('t))),
    unit =>'next
  ) =>
  'cur
 =
  (_from, _to, _label, _next) =>
    /*
     (alice --> bob)(hello, next)
     next : global('a, 'b, 'c)
     これがほしい: global([`Bob(out([`hello(session('a))]))], [`Alice(inp([`hello(session('b))]))], 'c)
     let bob_next = bob.role_lens.get(next);
     let bob_now = alice.role_label(hello.label_open(bob_next));
     let next = bob.role_lens.put(next, bob_now);
     let alice_next = alice.role_lens.get(next);
     let alice_now = bob.role_label(hello.label_close(alice_next));
     alice.role_lens.put(next,alice_now)
      */
    Raw.dontknow();

let finish: unit => global(unit, unit, unit) = () => Raw.dontknow();

let choice_at:
  'cur 'a 'b 'c 'left 'right 'lr 'l 'r 'x.
  (
    unit => role(unit, 'lr, global('a, 'b, 'c), 'cur, 'x, _),
    disj('lr, 'l, 'r),
    (
      unit => role('l, unit, 'left, global('a, 'b, 'c), 'x, _),
      unit => 'left,
    ),
    (
      unit => role('r, unit, 'right, global('a, 'b, 'c), 'x, _),
      unit => 'right,
    )
  ) =>
  'cur
 =
  (_alice, _disj, (_alice1, _left), (_alice2, _right)) =>
    /*
      choice(alice)(disj)(alice, (alice --> bob)(hello, left),
                          alice, (alice --> bob)(goodbye, right))
      let

     */
    Raw.dontknow();

/*
 let extract:
   'a 'b 'c.
   (
     unit => global('a, 'b, 'c),
     unit => role('t, _, global('a, 'b, 'c), _, _, _)
   ) =>
   session('t)
  =
   (_g, _role) => {
     Raw.todo();
             // {mpchan: /* ここに入れる */, dummy_witness: Raw.dontknow()}
   };
   */

// Example

let from_some = opt => {
  switch (opt) {
  | Some(v) => v
  | None => Raw.fail()
  };
};

let to_bob = dis => {
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

let payload_to_session: Transport.payload => session('a) = (x) => Raw.cast(x);

let start = (_g: global('a, 'b, 'c), fa:session('a) => unit, fb:session('b) => unit, fc:session('c) => unit) => {
  let pid_a =
    Process.make((_, recv) => {
      let (_, _, ch_a) = from_some(recv(~timeout=Process.Infinity));
      (fa(payload_to_session(ch_a)): unit);
    });
  let pid_b =
    Process.make((_, recv) => {
      let (_, _, ch_b) = from_some(recv(~timeout=Process.Infinity));
      (fb(payload_to_session(ch_b)): unit);
    });
  let pid_c =
    Process.make((_, recv) => {
      let (_, _, ch_c) = from_some(recv(~timeout=Process.Infinity));
      (fc(payload_to_session(ch_c)): unit);
    });

  /*
   let ch_a: session(_) =
     /* ここで `alice->pid_a, `bob->pid_b, `carol->pid_c の Map を作る */ Raw.dontknow();
   */

  let map_list = [
    (open_variant_to_tag(x => `Alice(x)), pid_a),
    (open_variant_to_tag(x => `Bob(x)), pid_b),
    (open_variant_to_tag(x => `Carol(x)), pid_c),
  ];
  let ch_a: session(_) = {
    mpchan: {
      self: open_variant_to_tag(x => `Alice(x)),
      channels: Maps.from_list(map_list),
    },
    dummy_witness: Raw.dontknow(),
  };
  let ch_b: session(_) = {
    mpchan: {
      self: open_variant_to_tag(x => `Bob(x)),
      channels: Maps.from_list(map_list),
    },
    dummy_witness: Raw.dontknow(),
  };
  let ch_c: session(_) = {
    mpchan: {
      self: open_variant_to_tag(x => `Carol(x)),
      channels: Maps.from_list(map_list),
    },
    dummy_witness: Raw.dontknow(),
  };

  let dummy_role = open_variant_to_tag(x => `Dummy(x));
  let dummy_label = open_variant_to_tag(x => `Dummy(x));
  Process.send(
    pid_a,
    (dummy_label, dummy_role, Transport.payload_cast(ch_a)),
  );
  Process.send(
    pid_b,
    (dummy_label, dummy_role, Transport.payload_cast(ch_b)),
  );
  Process.send(
    pid_c,
    (dummy_label, dummy_role, Transport.payload_cast(ch_c)),
  );
  ();
};

// let f = () => {
//   let x = 1;
//   let x = 2;
//   ()
// }
