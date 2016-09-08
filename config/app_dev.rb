# -*- coding: utf-8 -*-

class Config < BaseConfig

  set :db_user      , ENV['USER']
  set :db_pass      , ''

end
