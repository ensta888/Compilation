require 'pp'
require_relative 'lexer'


# A COMPLETER !
OBERON_TOKEN_DEF={
  :module	=> /module|MODULE/,
  :end		=> /end|END/,
  :procedure	=> /procedure|PROCEDURE/,
  :begin	=> /begin|BEGIN/,
  :array	=> /array|ARRAY/,
  :of	        => /of|OF/,
  :if		=> /if|IF/,
  :elsif	=> /elsif|ELSIF/,
  :else		=> /else|ELSE/,
  :then		=> /then|THEN/,
  :do		=> /do|DO/,
  :var   	=> /var|VAR/,
  :while	=> /WHILE|while/,
  :type		=> /integer|INTEGER/,
  :type		=> /type|TYPE/,
  :const	=> /const|CONST/,
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
  :assign	=> /:=/,
  :colon	=> /:/,
  :eq		=> /\=/,
  :multiply	=> /\*/,
  :substract	=> /\-/,
  :tilde	=> /\~/,
  :hashtag	=> /\#/,
  :const	=> /CONST|const/,
   
  :plus		=> /\+/,

  :div		=> /div|DIV/,
  :or		=> /or|OR/,
  :mod		=> /mod|MOD/,
  :and		=> /\&/,

  :identifier	=> /[a-zA-Z][a-zA-Z0-9_]*/,
  :integer	=> /[0-9]+/,
}

class Parser

  attr_accessor :lexer

  def initialize
    @lexer=Lexer.new(OBERON_TOKEN_DEF)
  end

  def parse filename
    str=IO.read(filename)
    @lexer.tokenize(str)
    parseModule()
  end

  def expect token_kind
    next_tok=@lexer.get_next
    if next_tok.kind!=token_kind
      puts "expecting #{token_kind}. Got #{next_tok.kind}"
      raise "parsing error on line #{next_tok.pos.first}"
    end    
  end
  
  def showNext
    @lexer.show_next
  end

  def acceptIt
    @lexer.get_next
  end

  #=========== parse method relative to the grammar ========
  def parseModule
    puts "parseModule"
   
    expect :module  
    expect :identifier
    expect :semicolon
    parseDeclarations()
    #  written JCLL
    if showNext.kind==:begin
      acceptIt
      parseStatementSequence()
    end
    expect :end 
    expect :identifier
    expect :dot
  end
    
  #added JCLL
  def parseStatementSequence
    puts "parseStatementSequence"
    parseStatement()
    while showNext.kind==:semicolon
      acceptIt
      parseStatement()
    end
  end

  def parseProcedure
    puts "parseProcedure"
    expect :var
    expect :identifier
    expect :colon
    expect :type
    expect :semicolon
  end
    
  def parseBegin
    puts "parseBegin"
    expect :var
    expect :identifier
    expect :colon
    expect :type
    expect :semicolon
  end

  #fixed JCLL
  def parseActualParameters
    puts "parseActualParameters"
    expect :lbracket
    starters_exp=[:plus,:minus,:identifier,:integer,:lbracket,:tilde]
    if starters_exp.include? showNext.kind
      parseExpression()
      while showNext.kind==:comma
        parseExpression()
      end
    end
    expect :rbracket
  end
    
  def parseProcedureCall(identifier,selector)
    puts "parseProcedureCall"
    #.....already parsed.......
    #expect :identifier
    #parseSelector()
    #.........................
    if showNext.kind==:lbracket
      parseActualParameters()
    end
  end

  #rework JCLL
  def parseExpression
    puts "parseExpression"
    parseSimpleExpression()
    operators=[:eq,:hashtag,:inf,:infeq,:sup,:supeq]
    if operators.include? showNext.kind
      acceptIt 
      parseSimpleExpression()
    end
  end

  def parseFactor
    puts "parseFactor"
    case showNext.kind 
    when :identifier then
      acceptIt
      parseSelector()
    when :integer then
      acceptIt
    when :lbracket then
      acceptIt
      parseExpression()
      expect :rbracket
    when :tilde then
      acceptIt
      puts "got tilde"
      parseFactor()
    else
      raise "expecting : identifier number '(' or '~' at #{lexer.pos}"
    end
  end

  #reworked JCLL
  def parseSelector
    puts "parseSelector"
    while showNext.kind==:dot or showNext.kind==:lsbracket
      case showNext.kind
      when :dot
        acceptIt
        expect :identifier
      when :lsbracket
        acceptIt
        parseExpression()
        expect :rsbracket
      else
        raise "wrong selector : expecting '.' or '['. Got '#{showNext.value}'"
        continuer = false
      end
    end
  end
  
  #rewritten JCLl
  def parseAssignment(identifier,selector)
    puts "parseAssignement"
    # .....already analyzed......
    #expect :identifier
    # @lexer.print_stream(5)
    #parseSelector()
    #...........................
    expect :assign
    parseExpression()
  end


  def parseIfStatement
    puts "parseIfStatement"
    expect :if
    parseExpression()
    expect :then
    parseStatementSequence()
    while showNext.kind==:elsif
      acceptIt()
      parseExpression()
      expect :then
      parseStatementSequence()
    end
    if showNext.kind==:else
	acceptIt()
	parseStatementSequence()          
    end
    expect :end
  end

  def parseWhileStatement
    puts "parseWhileStatement"
    expect :while
    parseExpression()
    expect :do
    parseStatementSequence()
    expect :end
  end

#---------------------------------------------------------
  def parseTerm
    puts "parseTerm"
    parseFactor()
    starters_factor=[:multiply,:div,:mod,:and]
    while starters_factor.include? showNext.kind
      acceptIt
      parseFactor()
    end 
  end

  def parseSimpleExpression
    puts "parseSimpleExpression"
    if showNext.kind==:plus 
      acceptIt
    elsif showNext.kind==:substract
      acceptIt
    end
    parseTerm()
    while showNext.kind==:plus or showNext.kind==:substract or showNext.kind==:or
        acceptIt
      parseTerm()
    end
  end
	
  def parseFormalParameters
    puts "parseFormalParameters"
    expect :lbracket
    if (showNext.kind != :rbracket)
      parseFPSection()
      while showNext.kind==:semicolon
        acceptIt
        parseFPSection()
      end
    end
    expect :rbracket
  end

  def parseProcedureHeading
    puts "parseProcedureHeading"
    expect :procedure
    expect :identifier
    if showNext.kind==:lbracket
      parseFormalParameters()
    end
  end

  #added JCLL
  def parseStatement
    puts "parseStatement"
    case showNext.kind
    when :identifier then
      identifier=acceptIt()
      selector=parseSelector()
      if showNext().kind==:assign
        stmt=parseAssignment(identifier,selector)
      else
        stmt=parseProcedureCall(identifier,selector)
      end
    when :if then
      stmt=parseIfStatement()
    when :while then
      stmt=parseWhileStatement()
    else raise "expecting one of : identifier,if,while"
    end
    return stmt
  end

  #rewritten JCLL
  def parseProcedureBody
    puts "parseProcedureBody"
    parseDeclarations()
    if showNext.kind==:begin
      acceptIt
      parseStatementSequence()
    end
    expect :end
    expect :identifier
  end

  def parseProcedureDeclaration
    puts "parseProcedureDeclaration"
    parseProcedureHeading()
    expect :semicolon
    parseProcedureBody()
  end
  
  def parseDeclarations
    puts "parseDeclarations"
    if showNext.kind==:const
      acceptIt
      while showNext.kind==:identifier
        acceptIt
        expect :eq
        parseExpression()
        expect :semicolon
      end
    end
    
    if showNext.kind==:type
      acceptIt
      puts "type detected"
      while showNext.kind==:identifier
        acceptIt
        expect :eq
        parseType()
        expect :semicolon
      end
    end
    
    if showNext.kind==:var
      acceptIt
      puts "var detected"
      while showNext.kind==:identifier
        parseIdentList()
        expect :colon
        parseType()
        expect :semicolon
      end
    end
    
    while showNext.kind==:procedure
      parseProcedureDeclaration()
      expect :semicolon
    end
  end
  
  # missing. Added JCLL
  def parseIdentList
    puts "parseIdentList"
    expect :identifier
    while showNext.kind==:comma
      acceptIt
      expect :identifier
    end
  end

  #missing. Added JCLL
  def parseType
    puts "parseType"
    case showNext.kind
    when :identifier
      acceptIt
    when :array
      parseArrayType()
    when :record
      parseRecordType()
    else
      raise "parsing error for type"
    end
  end

  #missing. Added JCLL
  def parseArrayType
    puts "parseArrayType"
    expect :array
    parseExpression()
    expect :of
    parseType()
  end

  #missing. Added JCLL
  def parseRecordType
    puts "parseRecordType"
    expect :record
    parseFieldList()
    while showNext.kind==:semicolon
      acceptIt
      parseFieldList()
    end
    expect :end
  end

end
