require 'rubygems'
require 'bundler'

Bundler.require(:default, :development)

module PNGSuite
  
  def png_suite_file(kind, file)
    File.join(png_suite_dir(kind), file)
  end
  
  def png_suite_dir(kind)
    File.expand_path("./png_suite/#{kind}", File.dirname(__FILE__))
  end
  
  def png_suite_files(kind, pattern = '*.png')
    Dir[File.join(png_suite_dir(kind), pattern)]
  end
end


module ResourceFileHelper
  
  def resource_file(name)
    File.expand_path("./resources/#{name}", File.dirname(__FILE__))
  end  
  
  def reference_canvas(name)
    ChunkyPNG::Canvas.from_file(resource_file("#{name}.png"))
  end
  
  def reference_image(name)
    ChunkyPNG::Image.from_file(resource_file("#{name}.png"))
  end
  
  def display(canvas)
    filename = resource_file('_tmp.png')
    canvas.to_datastream.save(filename)
    `open #{filename}`
  end  
end

RSpec.configure do |config|
  config.extend PNGSuite
  config.include PNGSuite
  config.include ResourceFileHelper
end
