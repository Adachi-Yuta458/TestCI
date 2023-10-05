#
# GET: curl 'localhost:5555/?hoge=test'
# POST curl -X POST -H "Content-Type: application/json" -d "{"name" : "omosu" , "mail" : "omosu@luxiar.com"}" localhost:5555/api/users
# 
# ブラウザでやってみよう
# localhost:5555/?hoge=test
#
require 'socket'

# ヘッダとボディの境目は空行。これもプロトコルの仕様として決まっている
#
def request_headers(socket)
  headers = []
  while header = socket.gets
    break if header.chomp.empty?
    headers << header
  end
  headers
end

def get_method(headers)
  method_line = headers.first
  return unless method_line

  method_line.split(' ')[0]
end

def request_body(socket, headers)
  length_header = headers.find { |header| header.include? 'Content-Length' }
  return unless length_header

  size = length_header.split(/:\s/, 2)[1].to_i
  socket.read(size)
end

def render(socket, method)
  case method
  when 'GET'
    socket.puts 'HTTP/1.1 200 OK'
    socket.puts 'Content-Type: text/html'
    socket.puts
    socket.puts '<html><h1>GET</h1></html>'
  when 'POST'
    socket.puts 'HTTP/1.1 200 OK'
    socket.puts 'Content-Type: text/html'
    socket.puts
    socket.puts '<html><h1>POST</h1></html>'
  else
    redirect(socket)
  end
end

def redirect(socket)
  # 試しに200にするとどうなる                                                                                                                                                                
  socket.puts 'HTTP/1.1 302 Found'                                                                                                                                                           
  socket.puts 'Location: https://luxiar.com'
  socket.puts
  socket.puts '<html><h1>Test</h1></html>'
end

server = TCPServer.open(5555)

loop do
  Thread.start(server.accept) do |socket|
    headers = request_headers(socket)
    p '------header------'
    p headers

    method = get_method(headers)
    p '------method--------'
    p method

    body = request_body(socket, headers)
    p '------body--------'
    p body

    render(socket, method)

    socket.close
  end
end