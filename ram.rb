class RAM < Array
  def initialize(kilobytes)
    super()
    @kilobytes=kilobytes
  end

  def write(*vals)
    i=0
    while true
      raise ArgumentError, "Data is bigger than RAM size of #{@kilobytes}K" if i>(1024*@kilobytes)-1
      break if vals[i]==nil
      self[i]=vals[i]
      i+=1
    end
  end

  def load(name)
    f=File.open(name,"r")
    data=[]
    f.each_byte do |c|
      data.push c.ord
    end
    write(*data)
  end

  def []=(addr,val)

    if addr>(1024*@kilobytes)-1
      raise ArgumentError, "#{addr} out of range for #{@kilobytes}K RAM"
    end
    if val > 255
      raise ArgumentError, "#{val} out of range for RAM"
    end
    super(addr,val)
  end

  def [](addr)
    if addr>(1024*@kilobytes)-1
      raise ArgumentError, "#{addr} out of range for #{@kilobytes}K RAM"
    end
    super(addr).to_i
  end

  def inspect()
    str="["
    i=0
    self.each do |byte|
      str+="0x#{byte.to_s(16).rjust(2,"0").upcase}"
      if i < self.length-1
        str+= ", "
      end
      i+=1
    end
    str+="]"
    return str
  end
end
