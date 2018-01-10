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
class NounEntity < Entity   # or ResouceEntity
end

## ex: SalesOrder, Shipping, Requisition, Approval, ...
class VerbEntity < Entity      # or EventEntity
end

## ex: Client, Supplier, Position, ...
class RoleEntity < Entity
end

## ex: Belonging, Writing, BOM, ...
class MappingEntity < Entity
end


## Operation class (aka Service class)
class Operation

  def initialize(db, login_user=nil)
    @db = db
    @login_user = login_user
  end

end
