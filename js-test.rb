LANGUAGE = {
  :name => "javascript",
  :command => "/opt/local/bin/couchjs /opt/local/share/couchdb/server/main.js",
  :functions => {
    "emit-twice" => %{function(doc){emit("foo",doc.a); emit("bar",doc.a); return 1;}},
    "error-in-map" => <<-JS,
      function(doc) {
       emit(x,doc)
      }
      JS
    "emit-once" => 
      <<-JS,
          function(doc){
            emit("baz",doc.a)
          }
       JS
    "reduce-values-length" => %{function(keys, values, rereduce) { return values.length; }},
    "reduce-values-sum" => %{function(keys, values, rereduce) { return sum(values); }},
    "validate-forbidden" => 
      <<-JS,
          function(newDoc, oldDoc, userCtx) {
            if(newDoc.bad)
              throw({forbidden:"bad doc"}); "foo bar";
          }
       JS
    "show-error" =>
      <<-JS,
          function(doc,req) {
            return {
          }
      JS
    "show-simple" => 
      <<-JS,
          function(doc, req) {
              log("ok");
              return [doc.title, doc.body].join(' - ');
          }
      JS
    "show-headers" => 
      <<-JS,
          function(doc, req) {
            var resp = {"code":200, "headers":{"X-Plankton":"Rusty"}};
            resp.body = [doc.title, doc.body].join(' - ');
            return resp;
          }
       JS
    "show-sends" => 
      <<-JS,
          function(head, req) {
            start({headers:{"Content-Type" : "text/plain"}});
            send("first chunk");
            send('second "chunk"');
            return "tail";
          };
      JS
    "show-while-get-rows" => 
      <<-JS,
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
      JS
    "show-while-get-rows-multi-send" =>
      <<-JS,
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
      JS
    "list-simple" =>
      <<-JS,
          function(head, req) {
            send("first chunk");
            send(req.q);
            var row;
            while(row = getRow()) {
              send(row.key);
            };
            return "early";
          };
      JS
    "list-chunky" =>
      <<-JS,
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
      JS
    "list-old-style" =>
      <<-JS,
          function(head, req, foo, bar) {
            return "stuff";
          }
      JS
    "list-capped" =>
      <<-JS,
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
      JS
    "list-raw" =>
      <<-JS,
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
      JS
    "filter-basic" =>
      <<-JS,
        function(doc, req) {
          if (doc.good) {
            return true;
          }
        }
      JS
    "update-basic" =>
      <<-JS,
      function(doc, req) {
        doc.world = "hello";
        var resp = [doc, "hello doc"];
        return resp;
      }
      JS
    "error" =>
      <<-JS,
      function() {
        throw(["error","error_key","testing"]);
      }
      JS
    "fatal" =>
      <<-JS,
      function() {
        throw(["fatal","error_key","testing"]);
      }
      JS
  }
}