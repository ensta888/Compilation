=begin
　　< > : 内包含的为必选项。 
　　[ ] : 内包含的为可选项。 
　　{ } : 内包含的为可重复0至无数次的项。 
　　|  : 表示在其左右两边任选一项，相当于"OR"的意思。 
　　::= : 是“被定义为”的意思 
　　"..." : 术语符号 
 　　[...] : 选项，最多出现一次 
　　{...} : 重复项，任意次数，包括 0 次 
　　(...) : 分组 
　　|   : 并列选项，只能选一个 
=end

class Ast
  def accept(visitor, arg=nil)
    name = self.class.name.split(/::/)[0]
    visitor.send("visit#{name}".to_sym, self ,arg) #Jingle! Metaprog !
  end
end

=begin
	Identifier:	
		IdentifierChars but not a Keyword or BooleanLiteral or NullLiteral 
=end

class Identifier < Ast
  attr_accessor :name
  def initialize name=nil
    @name=name
  end

  def to_s
    @name.value
  end
end

=begin
ClassDeclaration:
	NormalClassDeclaration | EnumDeclaration
=end

class Class_declaration < Ast
  attr_accessor :nClsDcl, :enumClsDcl
  def initialize nClsDcl=nil, enumClsDcl=nil
		@nClsDcl, @enumClsDcl = nClsDcl, enumClsDcl
	end
end

=begin
NormalClassDeclaration:
	{ClassModifier} class Identifier [TypeParameters] [Superclass] [Superinterfaces] ClassBody 
=end
class Normal_Class_Declaration < Ast
  attr_accessor :clsModif, :ident, :typeParms, :superCls, :superIntfs, :clsBody
  def initialize clsModif=nil, ident=nil, typeParms=nil, superCls=nil, superIntfs=nil, clsBody=nil
		@clsModif=clsModif, @ident=ident, @typeParms=typeParms, @superCls=superCls, @superIntfs=superIntfs, @clsBody=clsBody
	end
end

=begin
ClassModifier:
(one of) Annotation 
	public protected private abstract static final strictfp 
=end
class Class_Modifier < Ast
	attr_accessor :name
	def initialize modifier=nil
		@name = modifier	
	end
end

=begin
TypeParameters:
	< TypeParameterList >
=end
class TypeParameters < Ast
	attr_accessor :typeParameterList
	def initialize  typeParameterList = []
		@typeParameterList = typeParameterList 
	end
end

=begin
TypeParameterList:
	TypeParameter {, TypeParameter}
=end
class TypeParameterList < Ast
	attr_accessor :typeParameter
	def initialize  typeParameter = []
		@typeParameter = typeParameter 
	end
end

=begin
typeParameter :
	{TypeParameterModifier} Identifier [TypeBound]
=end
class TypeParameter < Ast
	attr_accessor :typeParameterModifier, :ident, :typeBound
	def initialize  typeParameterModifier=nil, ident=nil,  typeBound=nil
		@typeParameterModifier = typeParameterModifier 
		@ident = ident
		@typeBound = typeBound
	end
end

=begin
typePrameterModifier:
	Annotation 
=end
class TypeParameterModifier < Ast
	attr_accessor :name 
	def initialize  name=nil 
		@name = name
	end
end

=begin
EnumDeclaration:
	{ClassModifier} enum Identifier [Superinterfaces] EnumBody 
=end

class Enum_Declaration < Ast
  attr_accessor :clsModif, :ident, :superIntfs, :enumBody
  def initialize clsModif=nil, ident=nil, superIntfs=nil, enumBody=nil
		@clsModif=clsModif, @ident=ident, @superIntfs=superIntfs, @enumBody=enumBody
	end
end
