# -*- coding: utf-8 -*-

class Config < BaseConfig

  set :db_user      , ENV['USER']
  set :db_pass      , ''

  set :cdn_baseurl  , '/static/lib'   # don't use CDN when development mode

end
