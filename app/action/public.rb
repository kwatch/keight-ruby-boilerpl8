# -*- coding: utf-8 -*-

require 'keight'
require_relative '../action'


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
