# -*- coding: utf-8 -*-

require 'baby_erubis'
require 'baby_erubis/renderer'


##
## strip html tags (ex: '  <p></p>' => '<p></p>')
##
class StrippedHtmlTemplate < BabyErubis::Html
  def parse(input, *args)
    ## strip spaces of indentation
    stripped = input.gsub(/^[ \t]+</, '<')
    return super(stripped, *args)
  end
end


module BabyErubisTemplateHelper

  ##
  ## Template engine (BabyErubis)
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

end
