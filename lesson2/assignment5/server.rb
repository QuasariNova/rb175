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

  client.puts "<h1>Rolls!</h1>"
  sides = params.fetch('sides') { 6 }.to_i
  rolls = params.fetch('rolls') { 1 }.to_i

  rolls.times { client.puts "<p>", rand(sides) + 1, "</p>" }

  client.puts "</body>"
  client.puts "</html>"
  client.close
end
