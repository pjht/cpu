class ALU
  def run(op,a,b=nil)
    r=0
    case op
    when 0
      r=a+b
    when 1
      r=a-b
    end
    return r
  end
end
