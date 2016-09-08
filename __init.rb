# -*- coding: utf-8 -*-

require 'fileutils'


class Main

  def self.main
    self.new.run(*ARGV)
  end

  def run(*args)
    dryrun = args[0] == '-D'
    autoremove = ["index.txt", __FILE__]
    fu = dryrun ? FileUtils::DryRun : FileUtils::Verbose
    #
    files = Dir.glob('**/*', File::FNM_DOTMATCH).reject {|x|
      x == '.git' || x.start_with?('.git/') || \
      x == '.' || x.end_with?('/.') || autoremove.include?(x)
    }
    #
    keeps, files = files.partition {|x| x.end_with?('/.keep') }
    fu.rm keeps
    #
    render_template_files(files)
    #
    puts "## install gems"
    sys "gem install bundler"
    sys "bundler install"
    #
    puts "## download jquery and so on"
    download_libraries_in("app/template/_layout.html.eruby", "static/lib")
    #
    puts "## files"
    descs = parse_index_file("index.txt")
    print_files(files, descs)
    #
    fu.rm autoremove
  end

  private

  def sys(*args)
    puts "$ #{args.join(' ')}"
    system *args
  end

  def render_template_files(filepaths, dryrun=false)
    require 'baby_erubis'
    require 'keight'
    template_class = Class.new(BabyErubis::Text) do
      rexp = BabyErubis::Text::PATTERN
      pattern = Regexp.compile(rexp.to_s.sub(/<%/, '\{\%').sub(/%>/, '\%\}'))
      define_method(:pattern) { pattern }
    end
    #
    filepaths.each do |fpath|
      next if File.directory?(fpath)
      next if fpath == '__setup.rb'
      s = template_class.new.from_file(fpath, 'ascii-8bit').render()
      if s != File.open(fpath, 'rb') {|f| f.read }
        File.open(fpath, 'wb') {|f| f.write(s) } unless dryrun
      end
    end
  end

  def parse_index_file(filename)
    descs = File.open(filename) {|f|
      f.select {|line| line !~ /^\s*#/ } \
        .map {|line| line.split(nil, 2) } \
        .each_with_object({}) {|(path, desc), d| d[path] = desc }
    }
    return descs
  end

  def print_files(filepaths, descs)
    filepaths.each do |fpath|
      next if fpath == __FILE__
      slash = File.directory?(fpath) ? "/" : ""
      arr = fpath.split("/")
      s = "  " * arr.length + arr[-1] + slash
      desc = descs[fpath+slash]
      puts "%-40s # %s" % [s, desc]
    end
  end

  def download_libraries_in(filepath, destdir)
    rexp = %r'<script src=".*?\/([-.\w]+)\/(\d+(?:\.\d+)+[-.\w]+)/[^"]*?\.js"'
    list = []
    File.read(filepath).scan(rexp) do
      library, version = $1, $2
      list << [library, version]
    end
    list.uniq.each do |library, version|
      sys "cdnget cdnjs #{library} #{version} #{destdir}"
    end
  end

end


Main.main()
