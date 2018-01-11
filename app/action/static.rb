# -*- coding: utf-8 -*-

require 'keight'
require_relative '../action'


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
