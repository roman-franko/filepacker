class ZipThemAll
  require 'fileutils'
  require 'open-uri'
  require 'rubygems'
  require 'zip/zipfilesystem'

  attr_accessor :list_of_file_paths, :zip_file_path, :root_path

  def initialize( root_path, zip_file_path)
    @zip_file_path = zip_file_path+'.zip'
    @root_path = root_path
    @swop_file = []
    @list_of_file_paths = [] 
  end

  def add( list )
    Array(list).each do |path|
      list_of_file_paths << parse_path(path)
    end    
  end

  def parse_path(file_path)
    unless file_path.match(/^(http:\/\/|ftp:\/\/)/)
      file_path
    else
       file_regexp = /(?:(?:[-_a-zA-Z\d]*)\.(?:[-_a-zA-Z\d])*)$/
       download file_path, file_path.match(file_regexp).to_s
       file_path = file_path.match(file_regexp).to_s
       @swop_file.push(file_path)
       file_path
    end
  end

  def rm
    unless @swop_file.empty?
      @swop_file.each do |file_name|
        directories = Dir.glob(File.join(@root_path+file_name))
        FileUtils.rm_rf directories
      end
    end
  end

  def download full_url, to_here
    writeOut = open(@root_path+to_here, "wb")
    writeOut.write(open(full_url).read)
    writeOut.close
  end

  def zip 
    unless @list_of_file_paths == nil 
      zip = Zip::ZipFile.open(self.root_path+self.zip_file_path, Zip::ZipFile::CREATE) do | zip_file |
        @list_of_file_paths.each { | file_path | archiving file_path, zip_file }
      end
      rm
    end
  end

  def archiving file_path, zip_file
    if File.exists? file_path
      file_name = File.basename( file_path )
      if zip_file.find_entry( file_name )
       zip_file.replace( file_name, file_path )
      else
        zip_file.add( file_name, file_path)
      end
    else
      puts "Warning: file #{file_path} does not exist"
    end
  end
end
## DEMO
z = ZipThemAll.new '/home/muk/rails_project/filepacker/', 'pic'
z.add ['http://musicgeneration.com.ua/blog/wp-content/uploads/2011/05/download_large.gif'] 
z.add ['http://intrigan.com/uploads/images/6/7/3/a/5/90cfdb9fdf.jpg']
z.zip

