require 'socket'
require 'json'

class Server

  def initialize
    @server = TCPServer.open(2000)
  end

  def parse_request(request)
    initial_line = request[0].split
    action = initial_line[0]
    file = initial_line[1][1..-1] # had to ommit the first slash from the file path
    http_version = initial_line[2]
    body = request[-1]
    
    if action == "GET"
      if File.exist?(file) 
        body = File.read(file)
        send_response(http_version, "200 OK", body)
      else
        send_response(http_version, "404 Not Found")
      end
    elsif action == "POST"
      params = JSON.parse(body)
      name = params["viking"]["name"]
      email = params["viking"]["email"]
      new_item = "<li>Name: #{name}</li><li>Email: #{email}</li>"
      mod_template = File.read(file).sub!("<%= yield %>", new_item)
      send_response(http_version, "200 OK", mod_template)
    end
  end

  def send_response(http_version, status, *body)
    if status == "200 OK"
      content_length = body[0].length
      response = "#{http_version} #{status}\r\nDate: #{Time.now.strftime("%a, %e %b %Y %H:%M:%S GMT")}\r\nContent-Length: #{content_length}\r\n\r\n#{body[0]}"
    else
      response = "#{http_version} #{status}"
    end
  end

  def run_server
    loop {
      client = @server.accept
      request = client.recv(1000).split("\r\n") # receives request from client and splits into array
      client.puts parse_request(request) 
      client.close
    }
  end

end

server = Server.new
server.run_server 
