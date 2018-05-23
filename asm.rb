require_relative "method_table"
mtable=MethodTable.new()
if ARGV.length > 0
  name = ARGV[0]
else
  print "Enter .t8 file name:"
  name=gets.chomp!
  name+=".t8" unless name.include? ".t8"
end
$infile=File.read(name)
$outfile=File.open(name.gsub(".t8",".bin"),"w")
$listfile=File.open(name.gsub(".t8",".lst"),"w")
$ops=["ADD","SUB","ADC","SBB","CMP","AND","OR","NOT"]

def write_combined(nib1,nib2)
  $outfile.print ("#{nib1.to_s(16)}0".to_i(16)+nib2).chr
end

def load(reg,addr)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  addr=addr.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  [0x00+reg, byte1, byte2]
end

def stor(reg,addr)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  addr=addr.to_i.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  [0x10+reg, byte1, byte2]
end

def loadp(reg,pointer)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  raise ArgumentError, "Pointer #{pointer} is out of bounds." if pointer > 1
  [0x20 + reg, pointer]
end

def storp(reg,pointer)
  raise ArgumentError, "Register #{reg} is out of bounds." if reg > 15
  raise ArgumentError, "Pointer #{pointer} is out of bounds." if pointer > 1
  [0x30 + reg, pointer]
end

def lodi(pointer,data)
  [0x40 + pointer, data]
end

def lodip(pointer,data)
  data=data.to_s(16).rjust(4,"0")
  byte1=data[0..1].to_i(16)
  byte2=data[2..3].to_i(16)
  [0x50 + pointer, byte1, byte2]
end

def arith(op,dest,s1,s2)
  op=$ops.index(op)
  [0x60 + op, dest, (s1<<4) + s2]
end

def ariti(op,dest,s1,data)
  op=$ops.index(op)
  [0x70 + op, (dest<<4) + s1, data]
end

def mov(r1,r2)
  [0x80, (r1<<4) + r2]
end

def jmpc(flags,addr)
  addr=addr.to_i.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  [0x90+flags, byte1, byte2]
end

def hlt()
  [0xB0]
end

def in(reg,port)
  [0xC0 + reg, port]
end

def out(reg,port)
  [0xD0 + reg, port]
end

def conv(str)
  if str.match(/0x([0-9a-f]+)/i)
    return $1.to_i(16)
  end
  if str.match(/([0-9]+)/)
    return $1.to_i
  end
  if $labels.include? str
    return $labels[str]
  end
  return str
end

mtable.add("load","stor","loadp","storp","lodi","lodip","arith","ariti","mov","jmpc","hlt","in","out")
lengths={
  "LOAD"=>3,
  "STOR"=>3,
  "LOADP"=>2,
  "STORP"=>2,
  "LODI"=>2,
  "LODIP"=>3,
  "ARITH"=>3,
  "ARITI"=>3,
  "MOV"=>2,
  "JMPC"=>3,
  "HLT"=>1,
  "CALL"=>3,
  "RET"=>1,
  "IN"=>2,
  "OUT"=>2,
  "PUSH"=>1,
  "POP"=>1
}

def parse_asm_line(line)
  label = nil
  op = nil
  args = []
  code, comment = line.split("#")
  if code
    parts = code.split(" ")
    if parts.length > 0
      #line not empty
      if parts[0].match(/(.+):/)
        label = parts.shift.chomp
      end
      if parts.length > 0
        op = parts.shift #first or second token
        op = conv(op) if conv(op).is_a? Numeric
      end
      args = parts.join(" ").split(",").map{|x| conv(x)} #anything left
     end
  end
  {:label=>label, :op=>op, :args=>args}
end

$labels={}
i=0

#first pass, get label values
$infile.split("\n").each do |line|
  parsed = parse_asm_line(line)
  label, op, args = parsed.values_at(:label, :op, :args)
  if label
    $labels[label] = i
    puts "Found Label #{label} at #{i}"
  end
  if op
    puts "Found op #{op} at #{i}"
    i += lengths[op]
  end
end

#second pass, generate code
i = 0
$infile.split("\n").each do |line|
  parsed = parse_asm_line(line)
  label, op, args = parsed.values_at(:label, :op, :args)
  next if op==nil
  if op.is_a? Numeric
    puts "Writing #{op}"
    $outfile.print conv(op).chr
    i += 1
  else
    puts "Got #{op} #{args.join(",")}"
    op=op.downcase
    code = mtable.call(op,*args)
    #write to bin file
    code.each do |byte|
      $outfile.print byte.chr
    end
    #write to list file
    $listfile.print (i.to_s(16).rjust(4, "0") + " ")
    code.each do |byte|
      $listfile.print (byte.to_s(16).rjust(2, "0") + " ")
    end
    i += code.length
  end
  $listfile.print line + "\n"
end
$outfile.close
