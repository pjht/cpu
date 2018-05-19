class RegisterFile < Array

  def []=(reg,val)
    if reg < 14
      if val > 255
        raise ArgumentError,"#{val} is out of range for a GPR"
      end
    elsif reg > 15
      raise ArgumentError "#{reg} is not a valid register"
    else
      if val > 65535
        raise ArgumentError,"#{val} is out of range for a pointer register"
      end
    end
    super(reg,val)
  end

  def [](reg)
    if reg > 15
      raise ArgumentError "#{reg} is not a valid register"
    end
    super(reg).to_i
  end

  def inspect()
    str="["
    i=0
    self.each do |byte|
      str+="0x#{byte.to_i.to_s(16).rjust(2,"0").upcase}"
      if i < self.length-1
        str+=", "
      end
      i+=1
    end
    str+="]"
    return str
  end
end
