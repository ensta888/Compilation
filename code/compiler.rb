require 'pp'

class Compiler

  def initialize h={}
    puts "Oberon-0 compiler".center(40,'=')
    pp h
    case h[:parser]
    when nil
      require_relative 'parser'
    when :eleves
      require_relative 'parser_etudiant'
    else
      raise "unknown parser for OBERON compiler"
    end
    @parser=Parser.new
  end

  def compile filename
    raise "usage error : Oberon-0 file needed !" if not filename
    puts "==> compiling #{filename}"
    ast=@parser.parse(filename)
  end
  
end

compiler=Compiler.new :parser=>:eleves
compiler.compile ARGV[0]
