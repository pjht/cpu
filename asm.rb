require_relative "method_table"
mtable=MethodTable.new()
$outfile=File.open("test.bin","w")
$infile=File.read("test.t8")
def write_op(opcode,arg)
  $outfile.print ("#{opcode}0".to_i(16)+arg).chr
end
def load(reg,addr)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  addr=addr.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  write_op(0,reg)
  $outfile.print byte1.chr
  $outfile.print byte2.chr
end
def stor(reg,addr)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  addr=addr.to_i.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  write_op(1,reg)
  $outfile.print byte1.chr
  $outfile.print byte2.chr
end
def loadp(reg,pointer)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  raise ArgumentError, "Pointer #{pointer} is out of bounds." if pointer > 1
  write_op(2,reg)
  $outfile.print pointer.chr
end
def storp(reg,pointer)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  raise ArgumentError, "Pointer #{pointer} is out of bounds." if pointer > 1
  write_op(3,reg)
  $outfile.print pointer.chr
end
def lodip(pointer,data)
  data=data.to_s(16).rjust(4,"0")
  byte1=data[0..1].to_i(16)
  byte2=data[2..3].to_i(16)
  write_op(5,pointer)
  $outfile.print byte1.chr
  $outfile.print byte2.chr
end
def to_num(str)
  if str.match(/0x([0-9a-f]+)/i)
    return $1.to_i(16)
  end
  if str.match(/([0-9]+)/)
    return $1.to_i
  end
end
mtable.add("load","stor","loadp","storp","lodip")
puts mtable.inspect
$infile.split("\n").each do |line|
  temp=line.split(" ")
  op=temp.shift
  args=temp.join(" ").split(",").map{|x| to_num(x)}
  temp=[]
  puts "Got a #{op} instruction with arguments #{args}"
  op=op.downcase
  mtable.call(op,*args)
end
$outfile.close
