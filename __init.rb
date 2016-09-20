# -*- coding: utf-8 -*-

require 'fileutils'


module BabyErubis


  class Template

    def from_file(filename, encoding='utf-8')
      input = File.open(filename, "rb:#{encoding}") {|f| f.read() }
      compile(parse(input), filename, 1)
      return self
    end

    def from_str(input, filename=nil, linenum=1)
      compile(parse(input), filename, linenum)
      return self
    end

    PATTERN = /(^[ \t]*)?<%([=\#])? ?(.*?) ?%>([ \t]*\r?\n)?/m

    def compile(src, filename=nil, linenum=1)
      @proc = eval("proc { #{src} }", empty_binding(), filename || '(eRuby)', linenum)
      return self
    end

    def parse(input)
      pattern = self.class.const_get(:PATTERN)
      src = "_buf = '';"       # preamble
      pos = 0
      input.scan(pattern) do |lspace, ch, code, rspace|
        match = Regexp.last_match
        text  = input[pos, match.begin(0) - pos]
        pos   = match.end(0)
        src << _t(text)
        if    ch == '='        # expression
          src << _t(lspace) << " _buf << (#{code}).to_s;" << _t(rspace)
        elsif ch == '#'        # comment
          src << _t(lspace) << ("\n" * code.count("\n")) << _t(rspace)
        elsif lspace && rspace # statement (with spaces)
          src << "#{lspace}#{code};#{rspace}"
        else                   # statement
          src << _t(lspace) << " #{code};" << _t(rspace)
        end
      end
      text = pos == 0 ? input : input[pos..-1]   # or $' || input
      src << _t(text)
      src << " _buf.to_s\n"    # postamble
      return src
    end

    def render(context=nil)
      if context.nil?
        ctxobj = Object.new
      elsif context.is_a?(Hash)
        ctxobj = Object.new
        context.each {|k, v| ctxobj.instance_variable_set("@#{k}", v) }
      else
        ctxobj = context
      end
      return ctxobj.instance_eval(&@proc)
    end

    private

    def build_text(text)
      return "" if text.nil? || text.empty?
      return " _buf << '#{text.gsub!(/['\\]/, '\\\\\&') || text}';"
    end
    alias _t build_text

    def empty_binding
      return binding()
    end

  end
  Text = Template              # for shortcut


end


class Boilerpl8Template < BabyErubis::Template

  rexp = BabyErubis::Template::PATTERN
  PATTERN = Regexp.compile(rexp.to_s.sub(/<%/, '\{\%').sub(/%>/, '\%\}'))

end


class Main

  class SystemError < StandardError
  end

  def self.main
    begin
      self.new.run(*ARGV)
    rescue SystemError
      $stderr.puts "***"
      $stderr.puts "*** ERROR: Command failed."
      $stderr.puts "***        See above error message."
      $stderr.puts "***"
      exit 1
    end
  end

  def run(*args)
    autoremove = ["index.txt", __FILE__]
    #
    rm_rf '**/.keep'
    #
    files = Dir.glob('**/*', File::FNM_DOTMATCH).reject {|x|
      x == '.git' || x.start_with?('.git/') || \
      x == '.' || x.end_with?('/.') || autoremove.include?(x)
    }
    #
    render_template_files(files)
    puts ""
    #
    puts "## install gems"
    sys "gem install bundler"
    sys "$GEM_HOME/bin/bundler install"
    puts ""
    #
    puts "## select CSS framework"
    select_css_framework()
    #
    puts "## download jquery and so on"
    download_libraries_in("app/template/_layout.html.eruby", "static/lib")
    #
    puts "## files"
    puts File.basename(Dir.pwd) + "/"
    descs = parse_index_file("index.txt")
    print_files(files, descs)
    puts ""
    #
    puts "## remove files"
    rm_rf *autoremove
  end

  private

  def sys(cmd)
    if ENV['GEM_HOME']
      puts "$ #{cmd}"
      cmd = cmd.gsub(/\$GEM_HOME/, ENV['GEM_HOME'])
    else
      cmd = cmd.gsub(/\$GEM_HOME\/bin\//, '')
      puts "$ #{cmd}"
    end
    system cmd  or
      raise SystemError.new
  end

  def rm_rf(*args)
    puts "$ rm -rf #{args.join(' ')}"
    FileUtils.rm_rf args.each {|x| Dir.glob(x) }
  end

  def render_template_files(filepaths, dryrun=false)
    filepaths.each do |fpath|
      next if File.directory?(fpath)
      next if fpath.start_with?('__init.')
      s = Boilerpl8Template.new.from_file(fpath, 'ascii-8bit').render()
      if s != File.open(fpath, 'rb') {|f| f.read }
        File.open(fpath, 'wb') {|f| f.write(s) } unless dryrun
      end
    end
  end

  def select_css_framework
    puts "**    1. None"
    puts "**    2. Bootstrap"
    puts "**    3. Pure (recommended)"
    while true
      print "** Which CSS framework do you like? [1-3]: "
      answer = $stdin.gets().strip().to_i
      break if (1..3).include?(answer)
    end
    case answer
    when 1     # html5boilerplate
    when 2     # bootstrap
      mv "template/bootstrap/_layout_jumbotron.html.eruby", "template/_layout.html.eruby"
      mv "public/bootstrap/jumbotron.html.eruby", "public/index.html.eruby"
      mv "static/bootstrap/jumbotron.css", "static/css/main.css"
      edit("template/_layout.html.eruby") {|s|
        s.sub('href="/static/bootstrap/jumbotron.css"', 'href="/static/css/main.css')
      }
      edit("public/index.html.eruby") {|s|
        s = s.sub(/^ *\@_layout = .*\n/, '')
        s
      }
    when 3     # pure
      mv "template/pure/_layout_landing.html.eruby", "template/_layout.html.eruby"
      mv "public/pure/landing.html.eruby", "public/index.html.eruby"
      mv "static/pure/css/landing.css"   , "static/css/main.css"
      mv "static/pure/img/file-icons.png", "static/image/file-icons.png"
      edit("template/_layout.html.eruby") {|s|
        s.sub('/static/pure/css/landing.css', '/static/css/main.css')
      }
      edit("public/index.html.eruby") {|s|
        s.sub(/^ *\@_layout = .*\n/, '')\
         .sub('/static/pure/img/file-icons.png', '/static/image/file-icons.png')
      }
    else
      raise "** unreachable"
    end
    rm_rf "public/bootstrap",   "public/pure"
    rm_rf "template/bootstrap", "template/pure"
    rm_rf "static/bootstrap",   "static/pure"
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
      sys "$GEM_HOME/bin/cdnget cdnjs #{library} #{version} #{destdir}"
    end
  end

end


Main.main()
