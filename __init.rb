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
          src << "#{lspace} #{code};#{rspace}"
        else                   # statement
          src << _t(lspace) << "#{code};" << _t(rspace)
        end
      end
      text = pos == 0 ? input : input[pos..-1]   # or $' || input
      src << _t(text)
      src << " _buf.to_s\n"    # postamble
      return src
    end

    def render(context=nil)
      ctxobj = context.nil?          ? Object.new
             : ! context.is_a?(Hash) ? context
             : context.each_with_object(Object.new) {|o, (k, v)| o.instance_variable_set("@#{k}", v) }
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
    filepaths.each do |fpath|
      next if File.directory?(fpath)
      next if fpath == '__setup.rb'
      s = Boilerpl8Template.new.from_file(fpath, 'ascii-8bit').render()
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
