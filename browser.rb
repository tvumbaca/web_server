require 'socket'
require 'json'

class Browser
  
  def initialize
    @hostname = 'localhost'
    @port = 2000
    @path = '/index.html'
    @socket = TCPSocket.open(@hostname, @port)
  end

  def request(action)
    if action == "POST"
      puts "To register for the viking raid, please enter your name."
      name = gets.chomp
      puts "Please enter your email address."
      email = gets.chomp
      viking_info = {:viking => {:name => name, :email => email}}.to_json
      template_path = '/thanks.html'
      request = "POST #{template_path} HTTP/1.0\r\nContent-Type: application/json\r\nContent-Length: #{viking_info.length}\r\n\r\n#{viking_info}\r\n"
      @socket.print(request)
    elsif action == "GET"
      request = "GET #{@path} HTTP/1.0\r\nContent-Type: text/html\r\nUser-Agent: HTTPTool/CLI-Browser\r\n\r\nmessage body\r\n"
      @socket.print(request)
    end

  end

  def start
    puts "What type of action would you like to perform 'POST' or 'GET'?"
    action = gets.chomp.upcase
    request(action)
    response = @socket.read
    puts "\r\n"
    print response
    @socket.close
  end

end

browser = Browser.new
browser.start
