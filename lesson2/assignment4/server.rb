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

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/plain\r\n\r\n"

  client.puts request_line
  client.puts http_method
  client.puts path
  client.puts params

  sides = params.fetch('sides') { 6 }.to_i
  rolls = params.fetch('rolls') { 1 }.to_i

  rolls.times { client.puts rand(sides) + 1}

  client.close
end
