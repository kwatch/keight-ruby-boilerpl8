# -*- coding: utf-8 -*-

require_relative '../action/public'


class HomePage < PublicPage     # extends PublicPage, not Action

  mapping ''               , :GET=>:do_render

  def do_render
    return render_html(:index)  # renders 'public/index.html.eruby'
  end

end
