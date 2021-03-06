require "singleton"
require 'em-websocket'
require 'json'
class SimpleLivereload
  include Singleton
  attr_accessor :clients

  def initialize
    @clients=[]
  end

  def watch(dir, options)
    unwatch
    start_watch_project(dir)
    start_websocket_server(options)
  end


  def start_websocket_server(options)
    options={
      :host => '127.0.0.1', 
      :port => 35729,
      :debug => false
    }.merge(options)

    Thread.abort_on_exception = true
    @livereload_thread = Thread.new do 
      EventMachine::WebSocket.start( options ) do |ws|
        ws.onopen do
          begin
            puts "Browser connected."; 
            ws.send "!!ver:#{1.6}";
            SimpleLivereload.instance.clients << ws
          rescue
            puts $!
            puts $!.backtrace
          end
        end
        ws.onmessage do |msg|
          puts "Browser URL: #{msg}"
        end
        ws.onclose do
          SimpleLivereload.instance.clients.delete ws
          puts "Browser disconnected."
        end
      end
    end
  end

  def unwatch
    if @livereload_thread && @livereload_thread.alive?
      EventMachine::WebSocket.stop
    end
    @watch_project_thread.kill if @watch_project_thread && @watch_project_thread.alive?
  end


  def send_livereload_msg( base, relative )
    data = JSON.dump( ['refresh', { :path => File.join(base, relative),
                     :apply_js_live  => false,
                     :apply_css_live => true,
                     :apply_images_live => true }] )
    @clients.each do |ws|
      EM::next_tick do
        ws.send(data)
      end
    end 
  end 

  def start_watch_project(dir)
    @watch_project_thread = Thread.new do
      FSSM.monitor do |monitor|
        monitor.path dir do |path|
          path.glob '**/*.{css,png,jpg,gif,js,html}'
          path.update do |base, relative|
            puts ">>> Change detected to: #{relative}"
            SimpleLivereload.instance.send_livereload_msg( base, relative )
          end 
          path.create do |base, relative|
            puts ">>> New file detected: #{relative}"
            SimpleLivereload.instance.send_livereload_msg( base, relative )
          end 
          path.delete do |base, relative|
            puts ">>> File Removed: #{relative}"
            SimpleLivereload.instance.send_livereload_msg( base, relative )
          end 
        end 
      end 
    end 
  end 

end

