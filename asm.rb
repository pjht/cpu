require_relative "method_table"
mtable=MethodTable.new()
$outfile=File.open("test.bin","w")
$infile=File.open("test.t8","r")
def load(reg,addr)
  reg=reg.to_i
  raise ArgumemntError "Register #{reg} is out of bounds." if reg > 15
  addr=addr.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  $outfile.print reg.chr
  $outfile.print byte1.chr
  $outfile.print byte2.chr
end
def stor(reg,addr)
  reg=reg.to_i
  raise ArgumemntError "Register #{reg} is out of bounds." if reg > 15
  addr=addr.to_s(16).rjust(4,"0")
  byte1=addr[0..1].to_i(16)
  byte2=addr[2..3].to_i(16)
  $outfile.print (0x10+reg).chr
  $outfile.print byte1.chr
  $outfile.print byte2.chr
end
mtable.add("load","stor")
mtable.load(0,9)
mtable.call(stor(0,10)
$outfile.close
$infile.close
