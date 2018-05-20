require_relative "../cpu"
describe CPU do
  before :each do
    @cpu=CPU.new()
  end

  it "loads programs" do
    @cpu.setprog([0x00,0x08])
    expect(@cpu.ram).to eq [0x00,0x08]
  end

  it "executes the LOAD instruction" do
    @cpu.setprog([0x00,0x00,0x04,0xB0,0x08]) # LOAD 0,0x0004; HLT
    @cpu.run
    expect(@cpu.registers.compact).to eq [0x08]
  end

  it "executes the STOR instruction" do
    @cpu.setprog([0x40,0x08,0x10,0x00,0x06,0xB0]) # LODI 0,0x08; STOR 0,0x0006; HLT
    @cpu.run
    expect(@cpu.ram).to eq [0x40,0x08,0x10,0x00,0x06,0xB0,0x08]
  end

  it "executes the LOADP instruction" do
    @cpu.setprog([0x50,0x00,0x06,0x20,0x00,0xB0,0x08]) #LODIP 0,0x0006; LOADP 0,0; HLT
    @cpu.run
    expect(@cpu.registers.compact).to eq [0x08,0x06]
  end

  it "executes the STORP instruction" do
    @cpu.setprog([0x40,0x08,0x50,0x00,0x08,0x30,0x00,0xB0]) #LODI 0,0x08; LODIP 0,0x0008; STORP 0,0; HLT
    @cpu.run
    expect(@cpu.ram).to eq [0x40,0x08,0x50,0x00,0x08,0x30,0x00,0xB0,0x08]
  end

  it "executes the LODI instruction" do
    @cpu.setprog([0x40,0x08,0xB0]) #LODI 0,0x08; HLT
    @cpu.run
    expect(@cpu.registers.compact).to eq [0x08]
  end

  it "executes the LODIP instruction" do
    @cpu.setprog([0x50,0x00,0x08,0xB0]) #LODIP 0,0x08; HLT
    @cpu.run
    expect(@cpu.registers.compact).to eq [0x08]
  end

  it "executes the ARITH instruction" do
    @cpu.setprog([0x40,0x08,0x41,0x08,0x60,0x00,0x01,0xB0]) #LODI 0,0x08; LODI 1,0x08; ARITH ADD,0,0,1; HLT
    @cpu.run
    expect(@cpu.registers.compact).to eq [0x10,0x08]
  end

  it "executes the ARITI instruction" do
    @cpu.setprog([0x40,0x08,0x70,0x00,0x01,0xB0]) #LODI 0,0x08; ARITH ADD,0,0,1; HLT
    @cpu.run
    expect(@cpu.registers.compact).to eq [0x09]
  end

  it "executes the HLT instruction" do
    @cpu.setprog([0xB0]) #HLT
    expect {@cpu.run}.to_not raise_error
  end

  it "executes the MOV instruction" do
    @cpu.setprog([0x40,0x08,0x80,0x01,0xB0])
    @cpu.run
    expect(@cpu.registers.compact).to eq [0x08,0x08]
  end

  it "executes the JMPC instruction" do
    @cpu.setprog([0x70,0x00,0x00,0x91,0x00,0x07,0xB0,0x50,0xFF,0xFF,0x20,0x00])
    expect {@cpu.run}.to raise_error(ArgumentError)
  end
end
