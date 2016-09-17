# -*- coding: utf-8 -*-

#require "bundler/gem_tasks"

#require 'rake/testtask'
#Rake::TestTask.new(:test) do |t|
#  t.libs << "test"
#  t.test_files = FileList['test/**/*_test.rb']
#  #t.verbose = true
#end

desc "run test scripts"
task :test do
  files = [
    './test/**/*_test.rb',
  ]
  code = 'ARGV.each {|p| Dir.glob(p).each {|f| require f } }'
  system "ruby -v"
  system "ruby", "-e", code, *files
end

task :default => :test


def run(command)
  print "[rake]$ "
  sh command
end

def gem_home_required
  return if ENV['GEM_HOME']
  $stderr.puts <<'END'
***
*** ERROR: $GEM_HOME environment variable required.
***
*** (MacOSX, Linux)
***   $ mkdir gems
***   $ export GEM_HOME=$PWD/gems
***
*** (Windows)
***   $ md gems
***   $ set GEM_HOME=%CD%\gems
***
END
  exit 1
end


desc "start server process"
task :server do |t|
  port = ENV['port'] || ENV['PORT'] || 8000
  run "rackup -p #{port} -E production -s puma config.ru"
end


desc "install gems and download libs"
task :setup => ['setup:gems', 'setup:static']

namespace :setup do

  desc "install required libraries"
  task :gems do |t|
    gem_home_required()
    run "gem install bundler"
    puts ""
    run "bundler install"
  end

  desc "download jquery.js etc from cdnjs"
  task :static do |t|
    filename = "app/template/_layout.html.eruby"
    rexp = %r'<script src=".*?\/([-.\w]+)\/(\d+(?:\.\d+)+[-.\w]+)/[^"]*?\.js"'
    done = {}
    File.read(filename).scan(rexp) do
      library, version = $1, $2
      key = "#{library}--#{version}"
      unless done[key]
        run "k8rb cdnjs #{library} #{version}"
        done[key] = true
      end
    end
  end

  desc "download *.js etc into 'static/lib/'"
  task :staticlib do |t|
    Dir.glob("static/lib/*/*").each do |libpath|
      next unless File.directory?(libpath)
      libpath =~ %r`\Astatic/lib/([^/]+)/([^/]+)\z`  or next
      library, version = $1, $2
      #run "k8rb cdnjs #{library} #{version}"
      run "cdnget cdnjs #{library} #{version} static/lib"
    end
  end

end


namespace :mapping do

  desc "show action mapping in text format"
  task :text do
    require './main'
    $k8_app.each_mapping do |urlpath, action_class, action_methods|
      action_methods.each do |meth, name|
        puts "%-6s %-30s  #=> %s#%s" % [meth, urlpath, action_class, name]
      end
    end
  end

  desc "show action mapping in YAML format"
  task :yaml do
    require './main'
    $k8_app.each_mapping do |urlpath, action_class, action_methods|
      puts "- url:     '#{urlpath}'"
      puts "  class:   #{action_class}"
      s = action_methods.collect {|k, v| "#{k}: #{v}" }.join(", ")
      puts "  method:  {#{s}}"
      puts ""
    end
  end

  desc "show action mapping in JSON format"
  task :json do
    require './main'
    puts "{ \"mappings\": ["
    sep = "  "
    $k8_app.each_mapping do |urlpath, action_class, action_methods|
      puts "#{sep}{ \"url\":    \"#{urlpath}\""
      puts "  , \"class\":  \"#{action_class}\""
      string = action_methods.collect {|k, v| "\"#{k}\": \"#{v}\"" }.join(", ")
      puts "  , \"method\": {#{string}}"
      puts "  }"
      sep = ", "
    end
    puts "]}"
  end

  _format_javascript = proc do |attr|
    require './main'
    puts     "{"
    dict = {}
    $k8_app.each_mapping do |urlpath, action_class, action_methods|
      (dict[action_class] ||= []) << [urlpath, action_methods]
    end
    s1 = "  "
    dict.each do |action_class, arr|
      puts   "#{s1}#{action_class.name.gsub(/::/, '_')}: {"
      s2 = "  "
      arr.each do |urlpath, action_methods|
        rexp = /\{(\w*)(?::.*?)?\}/
        params    = urlpath.scan(rexp).collect {|m| m[0] }
        upath_str = urlpath.gsub(rexp, "'+\\1+'")
        upath_str = ("'" + upath_str + "'").gsub(/\+''/, '')
        action_methods.each do |meth, name|
          puts "  #{s2}#{name}: function(#{params.join(', ')}) {"
          puts "      return {#{attr}: '#{meth}', url: #{upath_str}};"
          puts "    }"
          s2 = ", "
        end
      end
      puts "  }"
      s1 = ", "
    end
    puts "}"
  end

  desc "generate Javascript code for jQuery"
  task :jquery do
    _format_javascript.call('type')
    #_format_javascript.call('type')
  end

  desc "generate Javascript code for AngularJS"
  task :angularjs do
    _format_javascript.call('method')
  end

end
