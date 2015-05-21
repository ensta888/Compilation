#BNF for JAVA : http://cui.unige.ch/isi/bnf/JAVA/BNFindex.html

# -*- coding: utf-8 -*-
require 'pp'
require_relative 'lexer'
require_relative 'ast'

# A COMPLETER !
JAVA_TOKEN_DEF={
#-----------key words of JAVA--------------------
#A
	:abstract => /abstract|ABSTRACT/,
#B
	:boolean => /boolean|BOOLEAN/,
	:break   => /break|BREAK/,
	:byte    => /byte|BYTE/,
#C
	:case     => /case|CASE/,
	:catch    => /catch|CATCH/,
	:char     => /char|CHAR/,
	:class    => /class|CLASS/,
	:const    => /const|CONST/,
	:continue => /continue|CONTINUE/,
#D
	:d	      => /d|D/,
	:default  => /default|DEFAULT/,
	:do	      => /do|DO/,
	:double	  => /double|DOUBLE/,
#E
  :else     => /else|ELSE/,
	:extends  => /extends|EXTENDS/,
#F
	:final      => /final|FINAL/,
	:finally    => /finally|FINALLY/,
	:float      => /float|FLOAD/,
	:for        => /for|FOR/,
#I
  :if						=> /if|IF/,
	:implements   => /implements|IMPLEMENTS/,
	:import       => /import|IMPORT/,
	:instanceof   => /instanceof|INSTANCEOF/,
  :int					=> /int|INT/,
  :interface		=> /interface|INTERFACE/,
#L
  :long					=> /long|LONG/,
#N
  :new					=> /new|NEW/,
  :null					=> /null|NULL/,
	:native       => /native|NATIVE/,
#P
  :package			=> /package|PACKAGE/,  
  :private			=> /private|PRIVATE/, 
  :protected		=> /protected|PROTECTED/,
  :public  			=> /public|PUBLIC/,  
#R
  :return 			=> /return|RETURN/, 
#S
  :short  			=> /short|SHORT/, 
  :static  			=> /static|STATIC/,
  :super  			=> /super|SUPER/, 
  :switch  			=> /switch|SWITCH/, 
	:strictfp			=> /strictfp|STRICTFP/,
  :synchronized => /synchronized|SYNCHRONIZED/,
#T
  :this		  => /this|THIS/,
  :throw		=> /throw|THROW/, 
  :throws		=> /throws|THROWS/, 
  :true  		=> /true|TRUE/,
  :try  		=> /try|TRY/,
  :transient=> /transient|TRANTIENT/,
#V
  :void  		=> /void|VOID/,
	:volatile => /volatile|VOLATILE/,

 #W
  :while	=> /WHILE|while/,

#-----------punctuation mark--------------------

  :semicolon	=> /\;/,
  :dot		=> /\./,
  
  :comma	=> /\,/,
  :infeq	=> /<=/,
  :supeq	=> />=/,
  :sup		=> />/,
  :inf		=> /</,
  
  :lbracket	=> /\(/,
  :rbracket	=> /\)/,
  :lsbracket	=> /\[/,
  :rsbracket	=> /\]/,
	:lbrace	=> /\{/,
	:rbrace	=> /\}/,
  :assign	=> /:=/,
  :colon	=> /\:/,
  :eq		=> /\=/,
  :multiply	=> /\*/,
  :substract	=> /\-/,
  :tilde	    => /\~/,
  :hashtag	  => /\#/,
   
  :plus		=> /\+/,
  :div		=> /div|DIV/,
  :or		  => /or|OR/,
  :mod		=> /mod|MOD/,
  :and		=> /\&/,

  :ident	  => /[a-zA-Z][a-zA-Z0-9_]*/,
  :integer			=> /[0-9]+/,
}

class Parser

  attr_accessor :lexer

  def initialize verbose=false
    @lexer=Lexer.new(JAVA_TOKEN_DEF)
    @verbose=verbose
  end

  def parse filename
    str=IO.read(filename)
    @lexer.tokenize(str)
    parseClassDeclaration()
  end

  def expect token_kind
    next_tok=@lexer.get_next
    if next_tok.kind!=token_kind
      puts "expecting #{token_kind}. Got #{next_tok.kind}"
      raise "parsing error on line #{next_tok.pos.first}"
    end   
    return next_tok	 
  end
  
  def showNext
    @lexer.show_next
  end

  def acceptIt
    @lexer.get_next
  end

  def say txt
    puts txt if @verbose
  end
  #=========== mon parse method relative to the grammar ========
=begin
	class_declaration 
      ::= 
      { modifier } "class" ident [ "extends" super_class_name ] [ "implements" interface_name { "," interface_name } ] "{" { field_declaration } "}" 
=end
	def parseClassDeclaration
		 	puts "parseClassDeclaration"
		 	parseModifier()
			expect :class
			expect :ident
		  if showNext.kind==:extends
		    acceptIt
		    parseSuperClassName()
		  end
		  if showNext.kind==:implements
		    acceptIt
		   	parseInterfaceName()
				while showNext.kind==:comma
					acceptIt
					parseInterfaceName()
				end
		  end		
			expect :lbrace
			parseFieldDeclaration()
			expect :rbrace
	end

=begin
if class modifier , all  return 1
if var modifier , except :abstract return 2
else return 0 error

     "public" 
      | "private" 
      | "protected" 
      | "static" 
      | "final" 
      | "native" 
      | "synchronized" 
      | "abstract" 
      | "threadsafe" 
      | "transient" 
=end
	def parseModifier 
			puts "parseModifier"
			annotations=[:public,:protected,:private,:abstract,:static,:final,:strictfp]
		  while annotations.include? showNext.kind
		    	acceptIt
		  end
	end

=begin
	SuperClassName::= identifer{"."ident}
=end
	def parseSuperClassName()
			puts "parseSuperClassName"
			expect :ident
			while showNext.kind== :dot
				acceptIt
				expect :ident
			end
	end

=begin
	InterfaceClassName::= identifer{"."ident}
=end
	def parseInterfaceName()
			puts "parseInterfaceClassName"
			expect :ident
			while showNext.kind== :dot
				acceptIt
				expect :ident
			end
	end

=begin
field_declaration 
	 ( method_declaration | constructor_declaration | variable_declaration )  | static_initializer | ";" 
=end
	def parseFieldDeclaration()
	# static_initializer | ";" 
			while showNext.kind== :semicolon or showNext.kind==:static 
					case showNext.kind
							when :semicolon
								acceptIt
							when :static
								acceptIt
								parseStaticInitialiser()
					end
			end
		# ( method_declaration | constructor_declaration | variable_declaration )
			while true
					a=parseModifier()
					if a==0
						break
					end
					if expect(:ident).kind==:ident
						acceptIt
						parseConstructorDeclaration()
					end		
					if a==1
						parseMethodDeclaration()
					end
					if a==2
						parseVariableDeclaration()
					end
			end 	
	end
=begin
methodDeclaration   
	    { modifier } type ident "(" [ parameter_list ] ")" { "[" "]" }( statement_block | ";" ) 
=end
	def parseMethodDeclaration
			puts "parseMethodDeclaration"
			a=parseModifier()
			while a==2
				parseType()
				expect :ident
				expect :lbracket
				b=parseParameter()
				if b=1
					parseParameterList()
				end
				expect :rbracket
				while showNext.kind== :lsbracket
					acceptIt
					expect :rsbracket
				end
				if showNext.kind== :semicolon
					acceptIt
				else
					parseStatementBlock()
				end
			end
	end

=begin
parameter_list  
	    parameter { "," parameter } 
=end
	def parseParameter
			puts "parseParameter"
			parseParameter()
			while showNext.kind== :comma
				acceptIt
				parseParameter()
				while showNext.kind== :lsbracket
					acceptIt
					expect :rsbracket
				end
			end
	end

=begin
parameter
      type identifier { "[" "]" }
=end
	def parseParameter
			puts "parseParameter"
			parseType()
			expect :ident
			while showNext.kind== :lsbracket
				acceptIt
				expect :rsbracket
			end
	end

=begin
Type
 type_specifier { "[" "]" } 
=end
	def parseType
			puts "parseType"
			parseTypeSpecifier()
			while showNext.kind== :lsbracket
				acceptIt
				expect :rsbracket
			end
	end

=begin
type_specifier 
      "boolean" | "byte" | "char" | "short" | "int" | "float" | "long" | "double" | class_name |interface_name 
=end
	def parseTypeSpecifier
			puts "parseTypeSpecifier"
#to complete class_name |interface_name
			types=[:boolean,:byte,:char,:short,:int,:float,:long,:double]
		  while types.include? showNext.kind
		    	acceptIt
		  end
	end

=begin
statement_block 
     "{" { statement } "}" 
=end
	def parseStatementBlock
		puts "parseStatementBlock"
		expect :lbrace
		#to complete condition while
		while 
			parseStatement()
		end
		expect :rbrace
	end

=begin
statement 
      variable_declaration | ( expression ";" ) | ( statement_block ) | ( if_statement ) | ( do_statement ) 
			| ( while_statement ) | ( for_statement ) | ( try_statement ) |( switch_statement ) 
      | ( "synchronized" "(" expression ")" statement ) | ( "return" [ expression ] ";" ) | ( "throw" expression ";" ) 
			| ( identifier ":" statement ) | ( "break" [ identifier ] ";" ) | ( "continue" [ identifier ] ";" ) | ( ";" )
=end
	def parseStatement
			puts "parseStatement"
			a=parseModifier()
		  case showNext.kind
			#not sure for definit variable_declaration
			when a==2 then
				acceptIt
			#to complete the condition when for ( expression ";" )
			when then
				parseExpression()
				expect :semicolon
			when :lbrace then
				acceptIt
				parseIfStatementBlock()
			when :if then
				acceptIt
				parseIfStatement()
			when :do then
				acceptIt
				parseDoStatement()
			when :while then
				acceptIt
				parseWhileStatement()
			when :for then
				acceptIt
				parseForStatement()
			when :try then
				acceptIt
				parseTryStatement()
			when :switch then
				acceptIt
				parseSwitchStatement() 
		  when :synchronized then
		    acceptIt
		    expect :lbracket
				parseExpression()
		    expect :rbracket
				parseStatement()
		  when :return then
		    acceptIt
				#to complete condition if
				if
					parseExpression()
				end
				expect :semicolon
		  when :throw then
		    acceptIt
				parseExpression()
				expect :semicolon
		  when :ident then
		    acceptIt
				expect :colon
				parseStatement()
		  when :break then
				acceptIt
				if showNext.kind== :ident
					acceptIt
				end
				expect :semicolon
		  when :continue then
				acceptIt
				if showNext.kind== :ident
					acceptIt
				end
				expect :semicolon
			when :semicolon then
				acceptIt
			end

=begin
variable_declaration 
      { modifier } type variable_declarator { "," variable_declarator } ";" 
=end
	def parseVariableDeclaration
			puts "parseVariableDeclaration"
			#to complete condition while
			while 
				parseModifier()
			end
			parseType()
			parseVariableDeclarator()
			while showNext.kind== :comma
				acceptIt
				parseVariableDeclarator()
			end
			expect :semicolon
	end

=begin
variable_declarator 
      identifier { "[" "]" } [ "=" variable_initializer ] 
=end
	def parseVariableDeclarator
			puts "parseVariableDeclarator"
			expect :ident
			while showNext.kind== :lsbracket
				acceptIt
				expect :rsbracket
			end
			if showNext.kind== :eq
				acceptIt
				parseVariableInitializer() 
			end
	end

=begin
variable_initializer 
      expression | ( "{" [ variable_initializer { "," variable_initializer } [ "," ] ] "}" ) 
=end

	def parseVariableInitializer
			puts "parseVariableInitializer"
	end
end
