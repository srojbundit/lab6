--------------------------------------------------------------------------------
--
-- LAB #6 - Processor 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
   	     Port( clk : in  STD_LOGIC;
               opcode : in  STD_LOGIC_VECTOR (6 downto 0);
               funct3  : in  STD_LOGIC_VECTOR (2 downto 0);
               funct7  : in  STD_LOGIC_VECTOR (6 downto 0);
               Branch : out  STD_LOGIC_VECTOR(1 downto 0);
               MemRead : out  STD_LOGIC;
               MemtoReg : out  STD_LOGIC;
               ALUCtrl : out  STD_LOGIC_VECTOR(4 downto 0);
               MemWrite : out  STD_LOGIC;
               ALUSrc : out  STD_LOGIC;
               RegWrite : out  STD_LOGIC;
               ImmGen : out STD_LOGIC_VECTOR(1 downto 0));
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     ALUCtrl: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;

	component ImmGenerator is
	Port(	ImmControl: in std_logic_vector(1 downto 0);
		Immediate: in std_logic_vector(31 downto 0);
		Result: out std_logic_vector(31 downto 0) );
	end component ImmGenerator;
	
	SIGNAL ImmGenPCMUX: std_logic := '0';
	SIGNAL Zero, PC_adder_c, PCImmAdd_c, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite: std_logic;
	SIGNAL Branch, ImmGen: std_logic_vector(1 downto 0);
	SIGNAL WriteData, ReadData1, ImmMuxOut, ReadData2, ALUout, DataMemOut, PCin, PCout, ImmGenOut, InstructionOut, PCIncrement, PCImmAdd: std_logic_vector(31 downto 0);
	SIGNAL ReadReg1, ReadReg2, IndexReg, ALUCtrl: std_logic_vector(4 downto 0);

begin
	--PC
	PC: ProgramCounter PORT MAP(reset, clock, PCin, PCout); 
	--PC add 4
	PC_adder: adder_subtracter PORT MAP(PCout, x"00000004", '0', PCIncrement, PC_adder_c);
	--Branch Adder
	AdderBranch: adder_subtracter PORT MAP(PCout, ImmGenOut, '0', PCImmAdd, PCImmAdd_c);
	--send instruction to immGen to get result
	Immediate: ImmGenerator PORT MAP (ImmGen, InstructionOut, ImmGenOut);
	--Mux to PC in
	PCMux: BusMux2to1 PORT MAP(ImmGenPCMUX, PCIncrement, PCImmAdd, PCin);
	--get instructions from mem
	IMEM: InstructionRAM PORT MAP(reset, clock, PCout(31 downto 2), InstructionOut);
	
	--good
	ControlBlock: Control PORT MAP(clock, InstructionOut(6 downto 0), InstructionOut(14 downto 12), InstructionOut(31 downto 25), Branch, MemRead, MemtoReg, ALUCtrl, MemWrite, ALUSrc, RegWrite, ImmGen);
	--Register Block
	RegFile: Registers PORT MAP(ReadReg1, ReadReg2, IndexReg, WriteData, RegWrite, ReadData1, ReadData2);
	--ALU mux
	ALUInMux: BusMux2to1 PORT MAP(ALUSrc, ReadData2, ImmGenOut, ImmMuxOut);
	--ALU looks good 
	MainALU: ALU PORT MAP(ReadData1, ImmMuxOut, ALUCtrl, Zero, ALUout);
	--looks good, Only taking 30 bits of ALU out
	DataM: RAM PORT MAP(reset, clock, MemRead, MemWrite, ALUout(31 downto 2), ReadData2, DataMemOut);
	
	--looks good
	ALUOutMux: BusMux2to1 PORT MAP(MemToReg, ALUout, DataMemOut, WriteData);


	ImmGenPCMUX <= '1' WHEN (Branch = "01" AND Zero = '1') OR (Branch = "10" AND Zero = '0') ELSE '0';

	ReadReg1 <= InstructionOut(19 downto 15);
	ReadReg2 <= InstructionOut(24 downto 20);
	IndexReg <= InstructionOut(11 downto 7);
end holistic;