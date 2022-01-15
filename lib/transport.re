type role_tag = Polyvar.tag;

type label_tag = Polyvar.tag;

type payload;

type mpst_msg = (role_tag, label_tag, payload);

// type handle('msg) = Erlang.pid('msg);

type mpchan = {
  self: role_tag,
  channels: Maps.t(role_tag, Erlang.pid(mpst_msg)),
};

external payload_cast: 'v => payload = "payload_cast";
// external payload_cast: 'v => payload = "%identity";

let raw_send: 'v. (mpchan, role_tag, label_tag, 'v) => unit =
  (mpchan, role, label, v) => {
    let ch = Maps.get(role, mpchan.channels, Raw.dontknow());
    Process.send(ch, (mpchan.self, label, payload_cast(v)));
  };

let raw_receive: 'v. (~from: role_tag) => (label_tag, 'v) =
  (~from) => {
    let (_, label, v) =
      Raw.guarded_receive(~from=from);
    (label, v);
  };
