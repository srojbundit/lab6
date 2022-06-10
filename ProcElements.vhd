--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
	Port(	selector: in std_logic;
		In0, In1: in std_logic_vector(31 downto 0);
		Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
	Result <= In0 when selector = '0' else In1;
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ImmGenerator is
	Port(	ImmControl: in std_logic_vector(1 downto 0); --same as immGen
		Immediate: in std_logic_vector(31 downto 0);
		Result: out std_logic_vector(31 downto 0) ); --immGenOut
end entity ImmGenerator;


architecture ImmediateSelector of ImmGenerator is
begin
--sends back immediate based on type
	Result(31 downto 12) <= Immediate(31 downto 12) when ImmControl = "11" else (Others=>'0');
					
	Result(11 Downto 0) <= Immediate(31 downto 20)  when ImmControl = "00" ELSE
			       Immediate(31 downto 25) & Immediate(11 downto 7) WHEN ImmControl = "01" ELSE
			       Immediate(7) & Immediate(30 downto 25) & Immediate(11 downto 8) & '0' WHEN ImmControl = "10" ELSE (OTHERS=>'0');
end architecture ImmediateSelector;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
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
end Control;

architecture CODE of Control is
	SIGNAL ImmANDALUCtrl: std_logic_vector(3 DOWNTO 0);
begin
	--Tells us Immediate and 
	ImmANDALUCtrl <=
		"0000" WHEN opcode = "0110011" AND funct3 = "000" AND funct7 = "0000000" ELSE		--ADD
		"1000" WHEN opcode = "0010011" AND funct3 = "000" ELSE					--ADDI
		"0100" WHEN opcode = "0110011" AND funct3 = "000" AND funct7 = "0100000" ELSE		--SUB
		"0Z11" WHEN opcode = "0110011" AND funct3 = "110" AND funct7 = "0000000" ELSE		--OR
		"1Z11" WHEN opcode = "0010011" AND funct3 = "110" ELSE					--ORI
		"0Z10" WHEN opcode = "0110011" AND funct3 = "111" AND funct7 = "0000000" ELSE		--AND
		"1Z10" WHEN opcode = "0010011" AND funct3 = "111" ELSE					--ANDI
		"0001" WHEN opcode = "0110011" AND funct3 = "001" AND funct7 = "0000000" ELSE		--SLL
		"1001" WHEN opcode = "0010011" AND funct3 = "001" ELSE					--SLLI
		"0101" WHEN opcode = "0110011" AND funct3 = "101" AND funct7 = "0000000" ELSE		--SRL 
		"1101" WHEN opcode = "0010011" AND funct3 = "101" ELSE					--SRLI
		"1111"; --Pass Through otherwise /LUI 


	ALUCtrl <= "ZZ" & ImmANDALUCtrl(2 DOWNTO 0);
	ALUSrc <= '0' WHEN ImmANDALUCtrl(3) = '0' ELSE '1';			--tells us if immediate is used 
	
	--good
	Branch <= "01" WHEN opcode = "1100011" AND funct3 = "000" ELSE		--BEQ
		  "10" WHEN opcode = "1100011" AND funct3 = "001" ELSE		--BNE
		  "00";								--No Branch
	
	--good
	ImmGen <= "00" WHEN opcode = "0010011" OR opcode = "0000011" ELSE	--I-types / LW
		  "01" WHEN opcode = "0100011" ELSE				--S-type
		  "10" WHEN opcode = "1100011" ELSE				--B-type
		  "00";								--R-type or U-type
	
	--GOOD
	RegWrite <= '1' WHEN (opcode = "0110111" OR opcode = "0000011" OR opcode = "0010011" OR opcode = "0110011") AND clk = '0' ELSE '0';
	MemWrite <= '1' WHEN opcode = "0100011" ELSE '0';
	MemRead <= '1' WHEN opcode = "0000011" ELSE '0';
	MemToReg <= '1' WHEN opcode = "0000011" ELSE '0';
end CODE;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;

architecture executive of ProgramCounter is
--signal PC1, PC2 : integer range 0 to 1073741823;
begin
	--PC1 <= to_integer(PCin);
	
	PCProc: process(Clock, Reset) is
	begin
		if Reset = '1' then
			PCout <= x"00400000";
		end if;
		if Rising_edge(Clock) then
			PCout <= PCin;
		end if;
	end process PCProc;
	--PCout <= std_logic_vector(to_unsigned(PC2, PCout'length));
end executive;
--------------------------------------------------------------------------------