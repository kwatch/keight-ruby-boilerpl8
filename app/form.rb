# -*- coding: utf-8 -*-


class Form

  def initialize(params={})
    @params = params
  end

  attr_reader :params, :errors

  def self.new_from(model)
    params = {
      #'val'    => model.val,
    }
    self.new(params)
  end

  def validate
    @errors = errors = {}
    #
    #k = 'val'
    #v = @params[k].to_s.strip
    #if v.empty?
    #  errors[k] = "Required"
    #elsif v !~ /\A\d+\z/
    #  errors[k] = "Integer expected"
    #end
    #@params[k] = v
    #
    return errors
  end

  def error(name)
    return @errors[name]
  end

  def populate_into(model)
    #model.val = @params['val'].to_i
    return model
  end

end
