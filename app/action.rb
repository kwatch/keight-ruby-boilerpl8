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
    while c != Exception
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


class StaticPage < BaseAction

  mapping '/{urlpath:str<.+>}',   :GET=>:do_send_file
  STATIC_DIR = "static"

  def do_send_file(urlpath)
    filepath = "#{STATIC_DIR}/#{urlpath}"
    File.file?(filepath)  or raise K8::HttpException.new(404)
    #env = @req.env
    #header_name = env['sendfile.type'] || env['HTTP_X_SENDFILE_TYPE']
    #if header_name && ! header_name.empty?
    #  @resp.headers[header_name] = File.absolute_path(filepath)
    #  return nil
    #else
      return send_file(filepath)
    #end
  end

end


class PublicPage < BaseAction

  ERUBY_PATH       = ['public', 'template']
  SCRIPT_SUFFIX    = ".app.rb"

  mapping '/{urlpath:str<.*>}'  ,  :GET=>:do_render

  def do_render(urlpath)
    filepath = File.join('public', urlpath)
    #
    if filepath.end_with?('.eruby') || filepath.end_with?(SCRIPT_SUFFIX)
      raise K8::HttpException.new(404)
    end
    #
    if File.directory?(filepath)
      if ! filepath.end_with?('/')
        location = urlpath + '/'
        qs = @req.query_string
        location = "#{location}?#{qs}" if qs && ! qs.empty?
        return redirect_permanently_to(location)
      end
      filepath = File.join(filepath, 'index.html')
    end
    #
    return handle_static_file(filepath)   if File.file?(filepath)
    #
    template = "#{filepath}#{ERUBY_TEXT_EXT}"
    return handle_template_file(template) if File.file?(template)
    #
    script = "#{filepath}#{SCRIPT_SUFFIX}"
    return handle_script_file(script)     if File.file?(script)
    #
    script_path = find_script_file(filepath)
    return handle_sript_file(script_path) if script_path
    #
    return handle_not_found(urlpath)
  end

  private

  def handle_static_file(filepath)
    return send_file(filepath)
  end

  def handle_template_file(template_path)
    template_path = template_path.sub('public/', '')
    template_path =~ /(\.\w+)\.\w+\z/
    case $1
    when '.html', '.xml', '.atom'
      content = render_html(template_path)
    else
      content = render_text(template_path)
    end
    return content
  end

  def handle_script_file(script_path)
    raise NotImplementedError.new("#{self.class.name}#handle_script_file(): not implemented yet.")
  end

  def find_script_file(flepath)
    return nil
  end

  def handle_not_found(urlpath)
    raise K8::HttpException.new(404)
  end

end


class TopPage < PublicPage

  mapping ''               , :GET=>:do_render

  def do_render
    return render_html(:index)
  end

end
