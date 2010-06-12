LANGUAGE = {
  :name => "python",
  :command => "/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/couchpy --log-file - --debug",
  :functions => {
    "emit-twice" => %{function(doc){emit("foo",doc.a); emit("bar",doc.a)}},
    "emit-once" => 
      <<-PY,
          {
            emit("baz",doc.a)
          }
       PY
    "reduce-values-length" => %{function(keys, values, rereduce) { return values.length; }},
    "reduce-values-sum" => %{function(keys, values, rereduce) { return sum(values); }},
    "validate-forbidden" => 
      <<-PY,
          function(newDoc, oldDoc, userCtx) {
            if(newDoc.bad)
              throw({forbidden:"bad doc"}); "foo bar";
          }
       PY
    "show-simple" => 
      <<-PY,
def fun(doc, req):
  log("ok");
  return ' - '.join([doc.title, doc.body])
PY
    "show-headers" => 
      <<-PY,
          function(doc, req) {
            var resp = {"code":200, "headers":{"X-Plankton":"Rusty"}};
            resp.body = [doc.title, doc.body].join(' - ');
            return resp;
          }
       PY
    "show-sends" => 
      <<-PY,
          function(head, req) {
            start({headers:{"Content-Type" : "text/plain"}});
            send("first chunk");
            send('second "chunk"');
            return "tail";
          };
      PY
    "show-while-get-rows" => 
      <<-PY,
          function(head, req) {
            send("first chunk");
            send(req.q);
            var row;
            log("about to getRow " + typeof(getRow));
            while(row = getRow()) {
              send(row.key);
            };
            return "tail";
          };
      PY
    "show-while-get-rows-multi-send" =>
      <<-PY,
          function(head, req) {
            send("bacon");
            var row;
            log("about to getRow " + typeof(getRow));
            while(row = getRow()) {
              send(row.key);
              send("eggs");
            };
            return "tail";
          };
      PY
    "list-simple" =>
      <<-PY,
          function(head, req) {
            send("first chunk");
            send(req.q);
            var row;
            while(row = getRow()) {
              send(row.key);
            };
            return "early";
          };
      PY
    "list-chunky" =>
      <<-PY,
          function(head, req) {
            send("first chunk");
            send(req.q);
            var row, i=0;
            while(row = getRow()) {
              send(row.key);
              i += 1;
              if (i > 2) {
                return('early tail');
              }
            };
          };
      PY
    "list-old-style" =>
      <<-PY,
          function(head, req, foo, bar) {
            return "stuff";
          }
      PY
    "list-capped" =>
      <<-PY,
          function(head, req) {
            send("bacon")
            var row, i = 0;
            while(row = getRow()) {
              send(row.key);
              i += 1;
              if (i > 2) {
                return('early');
              }
            };
          }
      PY
    "list-raw" =>
      <<-PY,
          function(head, req) {
            // log(this.toSource());
            // log(typeof send);
            send("first chunk");
            send(req.q);
            var row;
            while(row = getRow()) {
              send(row.key);
            };
            return "tail";
          };
      PY
    "filter-basic" =>
      <<-PY,
        function(doc, req) {
          if (doc.good) {
            return true;
          }
        }
      PY
    "update-basic" =>
      <<-PY,
      function(doc, req) {
        doc.world = "hello";
        var resp = [doc, "hello doc"];
        return resp;
      }
      PY
    "error" =>
      <<-PY,
      function() {
        throw(["error","error_key","testing"]);
      }
      PY
    "fatal" =>
      <<-PY,
      function() {
        throw(["fatal","error_key","testing"]);
      }
      PY
  }
}