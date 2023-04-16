require 'socket'

def parse_request(request_line)
  http_method, path_and_params, _ = request_line.split

  path, param_strs = path_and_params.split '?'

  return [http_method, path, {}] unless param_strs

  param_strs = param_strs.split '&'

  params = param_strs.map { |param| param.split '=' }.to_h
  [http_method, path, params]
end

server = TCPServer.new('localhost', 3003)
loop do
  client = server.accept

  request_line = client.gets
  next if !request_line || request_line =~ /favicon/
  puts request_line

  http_method, path, params = parse_request(request_line)

  client.puts "HTTP/1.0 200 OK"
  client.puts "Content-Type: text/html"
  client.puts
  client.puts '<html>'
  client.puts '<body>'
  client.puts "<pre>"
  client.puts http_method
  client.puts path
  client.puts params
  client.puts "</pre>"

  client.puts "<h1>Counter</h1>"

  number = params['number'].to_i
  client.puts "<p>The current number is #{number}.</p>"

  client.puts "<a href='?number=#{number + 1}'>+</a>"
  client.puts "<a href='?number=#{number - 1}'>-</a>"

  client.puts "</body>"
  client.puts "</html>"
  client.close
end
