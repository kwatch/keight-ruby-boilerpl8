# -*- coding: utf-8 -*-

##
## Define base classes of models here.
##

## ***********************************************
## The followings are just examples.
## Remove them and define your own classes.
## ***********************************************

class Entity
end

## ex: Customer, Department, Company, Product, ...
class ResourceEntity < Entity   # or NounEntity
end

## ex: SalesOrder, Shipping, Requisition, Approval, ...
class EventEntity < Entity      # or VerbEntity
end

## ex: Client, Supplier, Position, ...
class RoleEntity < Entity
end

## ex: Belonging, Writing, BOM, ...
class MappingEntity < Entity
end


## Define event class as exception in order to be
## caught in BaseAction class.
class Event < Exception
end

class NotExist < Event
end

class NotPermitted < Event
end

class NotCorrect < Event
end


## Form class
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
    @errors[name]
  end

  def populate_into(model)
    #model.val = @params['val'].to_i
    return model
  end

end


## Operation class (aka Service class)
class Operation

  def initialize(db, login_user=nil)
    @db = db
    @login_user = login_user
  end

end
