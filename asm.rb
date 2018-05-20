require_relative "method_table"
mtable=MethodTable.new()
print "Enter .t8 file name:"
name=gets.chomp!
name+=".t8" unless name.include? ".t8"
$infile=File.read(name)
$outfile=File.open(name.gsub(".t8",".bin"),"w")
$ops=["ADD","SUB","ADC","SBB","CMP","AND","OR","NOT"]
def write_combined(nib1,nib2)
  $outfile.print ("#{nib1.to_s(16)}0".to_i(16)+nib2).chr
end
def load(reg,addr)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  addr=addr.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  write_combined(0,reg)
  $outfile.print byte1.chr
  $outfile.print byte2.chr
end
def stor(reg,addr)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  addr=addr.to_i.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  write_combined(1,reg)
  $outfile.print byte1.chr
  $outfile.print byte2.chr
end
def loadp(reg,pointer)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  raise ArgumentError, "Pointer #{pointer} is out of bounds." if pointer > 1
  write_combined(2,reg)
  $outfile.print pointer.chr
end
def storp(reg,pointer)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  raise ArgumentError, "Pointer #{pointer} is out of bounds." if pointer > 1
  write_combined(3,reg)
  $outfile.print pointer.chr
end
def lodi(pointer,data)
  write_combined(4,pointer)
  $outfile.print data.chr
end
def lodip(pointer,data)
  data=data.to_s(16).rjust(4,"0")
  byte1=data[0..1].to_i(16)
  byte2=data[2..3].to_i(16)
  write_combined(5,pointer)
  $outfile.print byte1.chr
  $outfile.print byte2.chr
end
def arith(op,dest,s1,s2)
  op=$ops.index(op)
  write_combined(6,op)
  $outfile.print dest.chr
  write_combined(s1,s2)
end
def ariti(op,dest,s1,data)
  op=$ops.index(op)
  write_combined(7,op)
  write_combined(dest,s1)
  $outfile.print data.chr
end
def mov(r1,r2)
  $outfile.print 0x80.chr
  write_combined(r1,r2)
end
def hlt()
  $outfile.print 0xB0.chr
end
def conv(str)
  if str.match(/0x([0-9a-f]+)/i)
    return $1.to_i(16)
  end
  if str.match(/([0-9]+)/)
    return $1.to_i
  end
  return str
end
mtable.add("load","stor","loadp","storp","lodi","lodip","arith","ariti","mov","hlt")
$infile.split("\n").each do |line|
  temp=line.split(" ")
  op=temp.shift
  args=temp.join(" ").split(",").map{|x| conv(x)}
  temp=[]
  if conv(op).is_a? Numeric
    puts "Writing #{op}"
    $outfile.print conv(op).chr
  else
    puts "Got #{op} #{args.join(",")}"
    op=op.downcase
    mtable.call(op,*args)
  end
end
$outfile.close
