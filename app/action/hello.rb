# -*- coding: utf-8 -*-

require 'keight'

#require_relative '../action'


class HelloAPI < K8::Action    # or BaseAction

  mapping ''        , :GET=>:do_index, :POST=>:do_create
  mapping '/{id}'   , :GET=>:do_show, :PUT=>:do_update, :DELETE=>:do_delete
  ## or
  #mapping '.json'       , :GET=>:do_index, :POST=>:do_create
  #mapping '/{id}.json'  , :GET=>:do_show, :PUT=>:do_update, :DELETE=>:do_delete

  def do_index()
    query = @req.params_query   # QUERY_STRING
    {"action"=>"index", "query"=>query}
  end

  def do_create()
    form = @req.params_form   # or @req.params_json
    {"action"=>"create", "form"=>form}
  end

  def do_show(id)
    {"action"=>"show", "id"=>id}
  end

  def do_update(id)
    form = @req.params_form   # or @req.params_json
    {"action"=>"update", "id"=>id, "form"=>form}
  end

  def do_delete(id)
    {"action"=>"delete", "id"=>id}
  end

end
