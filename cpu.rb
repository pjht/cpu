require_relative "regfile"
require_relative "alu"
require_relative "ram"
require 'io/console'
class CPU
  attr_reader :ram,:registers
  @@ops=["Adding","Subtracting","Adding with carry","Subtracting with borrow","Comparing","Anding","Oring","Inverting","Exclusive oring"]
  def initialize(progfile=nil)
    @registers=RegisterFile.new()
    @alu=ALU.new()
    @ram=RAM.new(8)
    if progfile
      @ram.load(progfile)
    end
    @debug=false
    @step=false
    @device=0
  end
  def setdebug()
    @debug=true
  end

  def setstep()
    @step=true
  end

  def cleardebug()
    @debug=false
  end
  def clearstep()
    @step=false
  end

  def run()
    puts "Memory at start:#{ram.inspect}"  if @debug
    i=0
    while true
      byte=@ram[i].to_s(2).rjust(8, "0")
      i+=1
      op=byte[0..3].to_i(2)
      arg=byte[4..7].to_i(2)
      case op
      when 0 # 0000rrrr aaaaaaaa aaaaaaaa-LOAD r,addr
        addr1=@ram[i].to_s(2).rjust(8, "0")
        i+=1
        addr2=@ram[i].to_s(2).rjust(8, "0")
        i+=1
        addr=addr1+addr2
        addr=addr.to_i(2)
        if arg>14
          puts "Loading R#{arg} from the addresses #{addr} and #{addr+1}" if @debug
          byte1=@ram[addr].to_s(2).rjust(8, "0")
          byte2=@ram[addr+1].to_s(2).rjust(8, "0")
          data=byte1+byte2
          data=data.to_i(2)
        else
          puts "Loading R#{arg} from the address #{addr}" if @debug
          data=@ram[addr]
        end
        puts "Setting R#{arg} to #{data.to_s(16).rjust(2,"0")}" if @debug
        @registers[arg]=data
        puts "Registers:#{registers.inspect}" if @debug
      when 1 #0001rrrr aaaaaaaa aaaaaaaa-STOR r,addr
        addr1=@ram[i].to_s(2)
        i+=1
        addr2=@ram[i].to_s(2)
        i+=1
        addr=addr1+addr2
        addr=addr.to_i(2)
        if arg>14
          puts "Storing R#{arg} into RAM address #{addr} and #{addr+1}" if @debug
          data=@registers[arg].to_s(2).rjust(16, "0")
          byte1=data[0..7].to_i(2)
          byte2=data[8..15].to_i(2)
          @ram[addr]=byte1
          @ram[addr+1]=byte2
        else
          puts "Storing R#{arg} into RAM address #{addr}" if @debug
          @ram[addr]=@registers[arg]
        end
        puts "RAM:#{ram.inspect}" if @debug
      when 2 # 0010rrrr 0000p-LOADP r,p
        pointer=@ram[i]+14
        i+=1
        addr=@registers[pointer]
        puts "Loading R#{arg} using the address contained in pointer #{pointer-14}" if @debug
        if arg>14
          byte1=@ram[addr].to_s(2).rjust(8,"0")
          byte2=@ram[addr+1].to_s(2).rjust(8,"0")
          data=byte1+byte2
          data=data.to_i(2)
        else
          data=@ram[addr]
        end
        puts "Setting R#{arg} to #{data.to_s(16).rjust(2,"0")}" if @debug
        @registers[arg]=data
        puts "Registers:#{registers.inspect}" if @debug
      when 3 # 0011rrrr 0000p-STORP r,p
        pointer=@ram[i]+14
        i+=1
        addr=@registers[pointer]
        if arg>14
          puts "Storing R#{arg} into RAM address #{addr} and #{addr+1}" if @debug
          data=@registers[arg].to_s(2).rjust(16,"0")
          byte1=data[0..7].to_i(2)
          byte2=data[8..15].to_i(2)
          @ram[addr]=byte1
          @ram[addr+1]=byte2
        else
          puts "Storing R#{arg} into RAM address #{addr}" if @debug
          @ram[addr]=@registers[arg]
        end
        puts "RAM:#{ram.inspect}" if @debug
      when 4 # 0100rrrr dddddddd-LODI r,d
        data=@ram[i]
        i+=1
        puts "Setting R#{arg} to #{data.to_s(16).rjust(2,"0")}" if @debug
        @registers[arg]=data
        puts "Registers:#{registers.inspect}" if @debug
      when 5 # 0100000p dddddddd dddddddd-LODIP p,d
        byte1=@ram[i].to_s(2).rjust(8,"0")
        i+=1
        byte2=@ram[i].to_s(2).rjust(8,"0")
        i+=1
        data=byte1+byte2
        data=data.to_i(2)
        puts "Setting R#{arg+14} to #{data.to_s(16).rjust(2,"0")}" if @debug
        @registers[arg+14]=data
        puts "Registers:#{registers.inspect}" if @debug
      when 6 # 0110oooo 0000rrrr rrrrrrrr-ARITH op,dest,s1,s2
        cmp=false
        cmp=true if arg==4
        dest=@ram[i]
        i+=1
        reginfo=@ram[i].to_s(2).rjust(8,"0")
        i+=1
        reg2=reginfo[0..3].to_i(2)
        reg1=reginfo[4..7].to_i(2)
        puts "#{@@ops[arg]} R#{reg1} and R#{reg2} and putting the result in R#{dest}"  if @debug and !cmp
        puts "Comparing R#{reg1} and R#{reg2}" if @debug and cmp
        data=@alu.run(arg,@registers[reg1],@registers[reg2])
        puts "Setting R#{dest} to #{data.to_s(16).rjust(2,"0")}" if @debug and !cmp
        @registers[dest]=data
        puts "Registers:#{registers.inspect}" if @debug and !cmp
      when 7 # 0111oooo rrrrrrrr dddddddd-ARITHI op,dest,s1,d
        cmp=false
        cmp=true if arg==4
        reginfo=@ram[i].to_s(2).rjust(8,"0")
        i+=1
        reg1=reginfo[0..3].to_i(2)
        dest=reginfo[4..7].to_i(2)
        data=@ram[i]
        i+=1
        puts "#{@@ops[arg]} R#{reg1} and #{data} and putting the result in R#{dest}"  if @debug and !cmp
        puts "Comparing R#{reg1} and #{data}" if @debug and cmp
        data=@alu.run(arg,@registers[reg1],data)
        puts "Setting R#{dest} to #{data.to_s(16).rjust(2,"0")}" if @debug and !cmp
        @registers[dest]=data
        puts "Registers:#{registers.inspect}" if @debug and !cmp
      when 8 # 10000000 rrrrrrrr-MOV r1,r2
        reginfo=@ram[i].to_s(2).rjust(8,"0")
        i+=1
        reg1=reginfo[0..3].to_i(2)
        reg2=reginfo[4..7].to_i(2)
        puts "Moving R#{reg1} to R#{reg2}" if @debug
        puts "Setting R#{reg2} to #{@registers[reg1].to_s(16).rjust(2,"0")}" if @debug
        @registers[reg2]=@registers[reg1]
        puts "Registers:#{registers.inspect}" if @debug
      when 9 #10010fff aaaaaaaa aaaaaaaa-JMPC flags,addr
        if @alu.test(arg.to_s(2))
          addr1=@ram[i].to_s(2)
          i+=1
          addr2=@ram[i].to_s(2)
          i+=1
          addr=addr1+addr2
          addr=addr.to_i(2)
          puts "Jumping to adresss #{i.to_s(16).rjust(4,"0")}" if @debug
          i=addr
        else
          i+=2
        end
      when 11 #10110000-HLT,10110001-RET
        puts "Halting" if arg==0 and @debug
        puts if @debug
        break if arg==0
        # TODO: Implement return here
      when 12
        port=@ram[i]
        puts "Getting data from port #{port}" if @debug
        i+=1
        if port==0
          case @device
          when 0
            puts "CHAR"
            data=STDIN.getch.ord
          end
        end
        @registers[arg]=data
      when 13
        port=@ram[i]
        puts "Outputting #{@registers[arg].to_s(16).rjust(2,"0")} to port #{port}" if @debug
        i+=1
        if port==1
          @device=@registers[arg]
        end
      end
      if @step and @debug
        gets
      elsif @debug and (!@step)
        puts
      end
    end
    puts "Memory at finish:#{ram.inspect}"  if @debug
    puts "Registers at finish:#{registers.inspect}" if @debug
  end

  def setprog(array)
    @ram.clear()
    @ram.write(*array)
  end
end
