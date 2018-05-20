class MethodTable < Hash
  def []=(index,mname)
    mname=mname.to_sym()
    func=method(mname)
    super(index,func)
  end

  def add(*mlist)
    mlist.each do |mname|
      self[mname.to_sym]=mname
    end
  end

  def method_missing(mname,*args)
    self[mname].(*args)
  end

  def call(mname,*args)
    self[mname].(*args)
  end
end
