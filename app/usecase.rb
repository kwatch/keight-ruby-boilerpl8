# -*- coding: utf-8 -*-

require_relative './helper/baby_erubis_template'


## Usecase class in order to separate business logics from framework.
class UseCase

  ##
  ## Template engine (BabyErubis)
  ##
  include BabyErubisTemplateHelper
  ERUBY_PATH       = ['app/template', 'template']

  ##
  ## abstract method to execute usecase
  ##
  def run(*args)
    raise NotImplementedError.new("#{self.class.name}#run(): not implemented yet.")
  end

  #def initialize(db, login_user=nil)
  #  @db = db
  #  @login_user = login_user
  #end
  #
  #def run(params, *urlpath_params)
  #  errors = validate(params)
  #  return nil, errors if errors
  #  args = accommodate(params, *urlpath_params)
  #  model, error = execute(*args)
  #  return nil, error if error
  #  content = represent(model)
  #  return content, nil
  #end
  #
  #private
  #
  ### validate params and return errors as Hash object.
  #def validate(params)
  #  errors = {}
  #  return errors
  #end
  #
  ### convert params and urlpath params into args of execute()
  #def accommodate(params, *urlpath_params)
  #  args = urlpath_params + [params]
  #  return args
  #end
  #
  ### execute business logic
  #def execute(*args)
  #  model = nil
  #  return model
  #end
  #
  ### convert model object into JSON or HTML
  #def represent(model)
  #  return {}
  #end

end
