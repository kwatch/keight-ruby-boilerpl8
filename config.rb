# -*- coding: utf-8 -*-

app_mode = ENV['APP_MODE']    # 'dev', 'prod', 'stg', 'test'
if app_mode.nil? || app_mode.empty?
  $stderr.write '
**
** ERROR: Set $APP_MODE environment variable at first.
**
** Example (MacOSX, UNIX):
**    $ export APP_MODE=dev       # development mode
**    $ export APP_MODE=prod      # production mode
**    $ export APP_MODE=stg       # staging mode
**
'
  exit 1
end


## Ruby < 2.2 has obsoleted 'Config' class, therefore remove it at first.
Object.class_eval { remove_const :Config } if defined?(Config)

## load 'app.rb', 'app_xxx.rb' and 'app_xxx.private'
require_relative "config/app"
require_relative "config/app_#{app_mode}"
fpath = File.join(File.dirname(__FILE__), "config", "app_#{app_mode}.private")
load fpath if File.file?(fpath)

## create $config object
$config = Config.new()

## temporary directory to put uploaded files
ENV['K8_UPLOAD_DIR'] = $config.k8_upload_dir if $config.k8_upload_dir
