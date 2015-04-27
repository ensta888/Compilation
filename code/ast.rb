class Ast
  def accept(visitor, arg=nil)
    name = self.class.name.split(/::/)[0]
    #puts "- visiting#{name}"
    visitor.send("visit#{name}".to_sym, self ,arg) #Jingle! Metaprog !
  end
end



class Identifier < Ast
  attr_accessor :val,:selector
  def initialize val
    @val=val
  end

  def to_s
    @val
  end
end

# Jingle! exactly similar to Identifier !
# this could be refactored to Number < Data & Identifier < Data
class Number < Ast 
  attr_accessor :val
  def initialize val
    @val=val
  end
  def to_s
    @val.to_s
  end
end

class Stmt < Ast
end

class Modul < Ast
  attr_accessor :ident,:declarations,:statements
  def initialize ident=nil,declarations=[],statements=[]
    @ident,@declarations,@statements=ident,declarations,statements
  end
end

class Const < Ast
  attr_accessor :ident,:expr
  def initialize ident=nil,expr=nil
    @ident,@expr=ident,expr
  end
end

class Type < Ast
  attr_accessor :ident,:type
  def initialize ident=nil,type=nil
    @ident,@type=ident,type
  end
end

class ArrayType
  attr_accessor :size,:type
  def initialize size=0,type=nil
    @size,@type=size,type
  end
end

class RecordType
  attr_accessor :fieldList
  def initialize fieldList=[]
    @fieldList=fieldList
  end
end

class FieldSection
  attr_accessor :identList,:type
  def initialize identList=[],type=nil
    @identList,@type=identList,type
  end
end

class Var < Ast
  attr_accessor :ident,:type
  def initialize ident=nil,type=nil
    @ident,@type=ident,type
  end
end

class ProcedureCall < Stmt
  attr_accessor :name,:actualParams
  def initialize name=nil,actualParams=[]
    @name,@actualParams=name,actualParams
  end
end

class ProcedureHeading < Stmt
  attr_accessor :name,:formalParameters
  def initialize name=nil,formalParameters=[]
    @name,@formalParameters=name,formalParameters
  end
end

class FormalParameter
  attr_accessor :identList,:type,:isVar
  def initialize identList=[],type=nil,isVar=false
    @identList,@type,@isVar=identList,type,isVar
  end
end

class ProcedureBody < Stmt
  attr_accessor :decls,:stmts
  def initialize decls=[],stmts=[]
    @decls,@stmts=decls,stmts
  end
end

class Declaration < Ast
end

class Procedure < Declaration
  attr_accessor :heading,:body
  def initialize heading=nil,body=nil
    @heading,@body=heading,body
  end
end

class Assign < Stmt
  attr_accessor :assignee,:expression
  def initialize assignee=nil,expression=nil
    @assignee,@expression=assignee,expression
  end
end

class If < Stmt
  attr_accessor :cond,:ifBlock,:elseBlock
  def initialize cond=nil,ifBlock=[],elseBlock=[]
    @cond,@ifBlock,@elseBlock=cond,ifBlock,elseBlock
  end
end

class While < Stmt
  attr_accessor :cond,:block
  def initialize cond=nil,block=[]
    @cond,@block=cond,block
  end
end

class Expression < Ast
  attr_accessor :lhs,:operator,:rhs
  def initialize lhs=nil,operator=nil,rhs=nil
    @lhs,@operator,@rhs=lhs,operator,rhs
  end
end

class Selector
  attr_accessor :ident,:expr
  def initialize ident=nil,expr=nil
    @ident,@expr=ident,expr
  end
end


class Operator < Ast
  attr_accessor :kind
  def initialize kind
    @kind=kind
  end
  def to_s
    @kind.to_s
  end
end
