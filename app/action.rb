# -*- coding: utf-8 -*-

require 'keight'
require './app/helper/baby_erubis_template_helper'


class BaseAction < K8::Action
  include BabyErubisTemplateHelper

  ##
  ## Error handler (or event handler)
  ##
  ## ex:
  ##   class Failure < Exception; end
  ##   class NotExist < Failure; end
  ##   class NotPermitted < Failure; end
  ##
  ##   def when_NotExist(ex)
  ##     @resp.status = 404   # 404 Not Found
  ##     {"error"=>"Not exist"}
  ##   end
  ##
  ##   def when_NotPermitted(ex)
  ##     @resp.status = 403   # 403 Forbidden
  ##     {"error"=>"Not permitted"}
  ##   end
  ##
  ##   def do_show(id)
  ##     item = Item.find(id)  or raise NotExist
  ##     return {"item"=>{"id"=>id, "name"=>item.name}}
  ##   end
  ##

  def invoke_action(action_name, urlpath_args)
    return super
  rescue Exception => ex
    c = ex.class
    while c != Object
      name = "when_#{c.name.gsub('::', '_')}"   # ex: "when_NotExist"
      return __send__(name, ex) if respond_to?(name)
      c = c.superclass
    end
    raise   # re-raise exception
  end

end


class AdminAction < BaseAction

  ## override template configs
  ERUBY_PATH       = ['admin/template']
  ERUBY_LAYOUT     = :_admin_layout

end
