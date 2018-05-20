class ALU

  def initialize()
    @carry=false
    @zero=false
    @sign=false
  end

  def run(op,a,b=nil)
    r=0
    case op
    when 0
      r=a+b
      if r>255
        @carry=true
        r=0
      else
        @carry=false
      end
    when 1,4
      r=a-b
    end
    if r==0
      @zero=true
    else
      @zero=false
    end
    if r.to_s(2).rjust(8,"0")[7]=="1"
      @sign=true
    else
      @sign=false
    end
    return r
  end

  def test(flagcond)
    flagcond=flagcond.rjust(3,"0")
    if flagcond[0]=="1"
      return false if !@sign
    end
    if flagcond[1]=="1"
      return false if !@carry
    end
    if flagcond[2]=="1"
      return false if !@zero
    end
    return true
  end
end
