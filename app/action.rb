# -*- coding: utf-8 -*-

require 'keight'
require 'baby_erubis'
require 'baby_erubis/renderer'


class StrippedHtmlTemplate < BabyErubis::Html
  def parse(input, *args)
    ## strip spaces of indentation
    stripped = input.gsub(/^[ \t]+</, '<')
    return super(stripped, *args)
  end
end


module My
end


class My::Action < K8::Action


  ##
  ## template
  ##

  ERUBY_PATH       = ['app/template', 'template']
  ERUBY_LAYOUT     = :_layout
  #ERUBY_HTML      = BabyErubis::Html
  ERUBY_HTML       = StrippedHtmlTemplate
  ERUBY_HTML_EXT   = '.html.eruby'
  ERUBY_TEXT       = BabyErubis::Text
  ERUBY_TEXT_EXT   = '.eruby'
  ERUBY_CACHE      = {}

  include BabyErubis::HtmlEscaper  # define escape()
  include BabyErubis::Renderer     # define eruby_render_{html,text}()

  protected

  alias render_html eruby_render_html
  alias render_text eruby_render_text


  protected

  ##
  ## Error handler (or event handler)
  ##
  ## ex:
  ##   class Failure < Exception; end
  ##   class NotExist < Failure; end
  ##   class NotPermitted < Failure; end
  ##
  ##   when_raised NotExist do |ex|
  ##     @resp.status = 404   # 404 Not Found
  ##     {"error"=>"Not exist"}
  ##   end
  ##
  ##   when_raised NotPermitted do |ex|
  ##     @resp.status = 403   # 403 Forbidden
  ##     {"error"=>"Not permitted"}
  ##   end
  ##
  ##   def do_show(id)
  ##     item = Item.find(id)  or raise NotExist
  ##     return {"item"=>{"id"=>id, "name"=>item.name}}
  ##   end
  ##

  WHEN_RAISED = {}   # ex: {NotFoundException => proc {|ex| .... }}

  def self.when_raised(exception_class, &block)
    WHEN_RAISED[exception_class] = block
  end

  def invoke_action(action_name, urlpath_args)
    return super
  rescue Exception => ex
    block = WHEN_RAISED[ex.class]  or raise
    return instance_exec(ex, &block)
  end

end


class My::AdminAction < My::Action

  ## override template configs
  ERUBY_PATH       = ['admin/template']
  ERUBY_LAYOUT     = :_admin_layout

end


class My::StaticPage < My::Action

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


class My::PublicPage < My::Action

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


class My::TopPage < My::PublicPage

  mapping ''               , :GET=>:do_render

  def do_render
    return render_html(:index)
  end

end
