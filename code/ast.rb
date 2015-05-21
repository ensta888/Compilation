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
	class_declaration 
      ::= 
      { modifier } "class" identifier [ "extends" super_class_name ][ "implements" interface_name { "," interface_name } ] "{" { field_declaration } "}" 
=end
class Class_Declaration < Ast
  attr_accessor :clsModif, :ident, :clsName, :interfName, :fieldDeclar
  def initialize clsModif=nil, ident=nil, clsName=nil, interfName=nil, fieldDeclar=nil
		@clsModif=clsModif, @ident=ident, @clsName=clsName, @interfName=interfName, @fieldDeclar=fieldDeclar
	end
end

=begin
	ClassModifier:
	(one of) Annotation 
		public protected private abstract static final strictfp 
=end
class Modifier < Ast
	attr_accessor :name
	def initialize modifier=nil
		@name = modifier	
	end
end

=begin
	SuperClassName::= identifer{"."identifer}
=end
class Super_Class_Name < Ast
	attr_accessor :ident
	def initialize  ident=nil
		@ident=ident 
	end
end

=begin
	InterfaceClassName::= identifer{"."ident}
=end
class Interface_name < Ast
	attr_accessor :ident
	def initialize  ident=nil
		@ident=ident 
	end
end

=begin
field_declaration 
	 ( method_declaration | constructor_declaration | variable_declaration )  | static_initializer | ";" 
=end
class Field_declaration < Ast
	attr_accessor :method_declaration, :constructor_declaration, :variable_declaration, :static_initializer
	def initialize  method_declaration=nil, constructor_declaration=nil,  variable_declaration=nil, static_initializer=nil
		@method_declaration =  method_declaration 
		@constructor_declaration = constructor_declaration
		@variable_declaration = variable_declaration
		@static_initializer = static_initializer
	end
end

=begin
methodDeclaration   
	    { modifier } type identtifier "(" [ parameter_list ] ")" { "[" "]" }( statement_block | ";" ) 
=end
class Method_Declaration < Ast
	attr_accessor :modifier, :type, :ident, :parameterList, :statementBlock
	def initialize  modifier=nil, type=nil, ident=nil, parameterList=nil, statementBlock=nil
		@modifier = modifier
		@type = type
		@ident = ident
		@parameterList = parameterList
		@statementBlock = statementBlock
	end
end

=begin
parameter_list  
	    parameter { "," parameter } 
=end
class Parameter_list < Ast
	attr_accessor :parameter
	def initialize parameter=nil
		@parameter = parameter
	end
end

=begin
parameter
      type identifier { "[" "]" }
=end
class Parameter < Ast
	attr_accessor :type, :ident
	def initialize type = nil, ident = nil
		@type= type
		@ident= ident
	end
end

=begin
Type
 type_specifier { "[" "]" } 
=end
class Type < Ast			
	attr_accessor :typeSpecifier
		def initialize typeSpecifier = nil
			@typeSpecifier = typeSpecifier
		end
end

=begin
type_specifier 
      "boolean" | "byte" | "char" | "short" | "int" | "float" | "long" | "double" | class_name |interface_name 
=end
class Type_specifier < Ast
	attr_accessor :name
	def initialize typeS=nil
		@name = typeS	
	end
end

=begin
statement_block 
     "{" { statement } "}" 
=end
class Statement_block < Ast
	attr_accessor :statement
	def initialize statement = nil
		@statement=statement
	end
end

=begin
statement 
      variable_declaration | ( expression ";" ) | ( statement_block ) | ( if_statement ) | ( do_statement ) 
			| ( while_statement ) | ( for_statement ) | ( try_statement ) |( switch_statement ) 
      | ( "synchronized" "(" expression ")" statement ) | ( "return" [ expression ] ";" ) | ( "throw" expression ";" ) 
			| ( identifier ":" statement ) | ( "break" [ identifier ] ";" ) | ( "continue" [ identifier ] ";" ) | ( ";" )
=end
class Statement < Ast
	attr_accessor :variableDeclaration, :expression, :statementB, :ifS, :whileS, :forS, :tryS,
:switchS, :ident, :statement
	def initialize variableDeclaration=nil, expression = nil, statementB = nil,ifS=nil,whileS=nil,forS=nil,tryS=nil,switchS=nil,ident=nil,statement=nil
			@variableDeclaration, @expression, @statementB, @ifS,@whileS, @forS, @tryS, @switchS, @ident, @statement = variableDeclaration, expression, statementB,ifS,whileS, forS,tryS, switchS, ident,statement
	end
end

=begin
variable_declaration 
      { modifier } type variable_declarator { "," variable_declarator } ";" 
=end
class Variable_declaration < Ast
	attr_accessor :modifier, :type, :variableDeclarator
	def initialize modifier =nil, type=nil, variableDeclarator=nil
		@modifier,@type,@variableDeclarator =modifier, type, variableDeclarator
	end
end

=begin
variable_declarator 
      identifier { "[" "]" } [ "=" variable_initializer ] 
=end
class Variable_declarator < Ast
	attr_accessor :ident, :variable_initializer
	def initialize variable_initializer =nil, ident=nil
		@variable_initializer, @ident= variable_initializer, ident
	end
end

=begin
variable_initializer 
      expression | ( "{" [ variable_initializer { "," variable_initializer } [ "," ] ] "}" ) 
=end
class variable_initializer < Ast
	attr_accessor :expression, :variable_initializer
	def initialize expression =nil, variable_initializer=nil
		 @variable_initializer,@expression= variable_initializer, expression
	end
end
