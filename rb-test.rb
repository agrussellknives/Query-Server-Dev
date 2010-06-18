LANGUAGE = {
  :name => "ruby",
  :command => "/opt/local/lib/ruby/gems/1.9.1/gems/couchdb-ruby-0.8.0/bin/couchdb_pipe_server",
  :functions => {
    "emit-twice" => <<-RUBY,
      lambda{|doc|
        emit "foo",doc['a']
        emit "bar",doc['a']
      }
      RUBY
    "emit-once" =>
      <<-RUBY,
          lambda { |doc| 
            emit "baz",doc['a']
          }
       RUBY
    "reduce-values-length" => 
      <<-RUBY,
        lambda { |k,v,r| 
          return v.length;
        }
      RUBY
    "reduce-values-sum" => 
      <<-RUBY,
        lambda { |k,v,r|
          return v.inject { |sum,x| sum + x }
        }
      RUBY
    "validate-forbidden" => 
      <<-RUBY,
          lambda { |newdoc,olddoc,ctx| 
            if newdoc['bad'] then
              throw(:forbidden,"bad doc")
            end
          }
       RUBY
    "show-simple" => 
      <<-RUBY,
          lambda { |doc,req|
            return [doc['title'], doc['body']].join(' - ')
          }
      RUBY
    "show-headers" => 
      <<-RUBY,
          lambda { |doc,req| 
            resp = {code:200, headers:{"X-Plankton" => "Rusty"}}
            resp['body'] = [doc['title'], doc['body']].join(' - ')
            return resp
          }
       RUBY
    "show-sends" => 
      <<-RUBY,
          lambda { |head,req|
            start({headers:{"Content-Type"=>"text/plain"}})
            send "first chunk";
            send 'second "chunk"';
            return "tail";
          }
      RUBY
    "show-while-get-rows" => 
      <<-RUBY,
          lambda { |head, req| 
            send("first chunk")
            send(req['q'])
            log("about to get_row")
            while(row = get_row) do
              send(row['key'])
            end
            return "tail"
          }
      RUBY
    "show-while-get-rows-multi-send" =>
      <<-RUBY,
          lambda { |head,req|
            send("bacon")
            log("about to get_row")
            while(row = get_row) do
              send(row['key'])
              send("eggs")
            end
            return "tail"
          }
      RUBY
    "list-simple" =>
      <<-RUBY,
          lambda { |head,req| 
            send("first chunk")
            send(req['q'])
            while(row = get_row) do
              send(row['key'])
            end
            return "early"
          }
      RUBY
    "list-chunky" =>
      <<-RUBY,
          lambda { |head,req|
            send "first chunk"
            send req['q']
            i = 0;
            while(row = get_row) do
              send row['key']
              i += 1
              if (i > 2) then
                return 'early tail'
              end
            end
          }
      RUBY
    "list-old-style" =>
      <<-RUBY,
          lambda { |head,req,foo,bar|
            return "stuff"
          }
      RUBY
    "list-capped" =>
      <<-RUBY,
          lambda { |head,req| 
            send "bacon"
            i = 0
            while(row = get_row) do
              send row['key']
              i += 1
              if (i > 2) then
                  return 'early'
              end
            end
          }
      RUBY
    "list-raw" =>
      <<-RUBY,
          lambda { |head,req|
            send "first chunk"
            send req['q']
            while(row = get_row) do
              send row['key']
            end
            return "tail"
          }
      RUBY
    "filter-basic" =>
      <<-RUBY,
        lambda { |d,r| 
          if (d['good']) then
            return true
          end
        }
      RUBY
    "update-basic" =>
      <<-RUBY,
        lambda { |d,r| 
          d['world'] = "hello"
          resp = [d, "hello doc"]
          return resp
        }
      RUBY
    "error" =>
      <<-RUBY,
      lambda { |d,r|
        throw(:error,["error_key","testing"])
      }
      RUBY
    "fatal" =>
      <<-RUBY,
      lambda { |d,r|
        throw(:fatal,["error_key","testing"])
      }
      RUBY
  }
}