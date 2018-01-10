# -*- coding: utf-8 -*-

require_relative '../action/public'


class TopPage < PublicPage

  mapping ''               , :GET=>:do_render

  def do_render
    return render_html(:index)
  end

end
