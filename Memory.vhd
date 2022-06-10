
--------------------------------------------------------------------------------
--
-- LAB #5 - Memory and Register Bank
--
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity RAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;	 
	 OE:      in std_logic;
	 WE:      in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataIn:  in std_logic_vector(31 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity RAM;

architecture staticRAM of RAM is

   type ram_type is array (0 to 127) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;
   signal intAddress: integer;
begin
  intAddress <= to_integer(unsigned(Address));
  RamProc: process(Clock, Reset, OE, WE, Address) is
  
  begin
    if Reset = '1' then
      for i in 0 to 127 loop
          i_ram(i) <= X"00000000";
      end loop;
    end if;

    if falling_edge(Clock) then
	if WE = '1' then
	 	i_ram(intAddress) <= DataIn;   
	end if; 
    end if;
  end process RamProc;

	DataOut <=	"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" 	when intAddress > 127 or OE = '1' else
			i_ram(intAddress) 			when OE = '0';

end staticRAM;	


--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity Registers is
    Port(ReadReg1: in std_logic_vector(4 downto 0); 
         ReadReg2: in std_logic_vector(4 downto 0); 
         WriteReg: in std_logic_vector(4 downto 0);
	 WriteData: in std_logic_vector(31 downto 0);
	 WriteCmd: in std_logic;
	 ReadData1: out std_logic_vector(31 downto 0);
	 ReadData2: out std_logic_vector(31 downto 0));
end entity Registers;

architecture remember of Registers is
	component register32
  	    port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
	end component;
	type RegOut is array (0 to 31) of std_logic_vector(31 downto 0);
	signal DataOut, DataIn  : RegOut;
	signal intAddress1, intAddress2 : integer range 0 to 31;
	signal RegAddress : std_logic_vector(4 downto 0);

begin
	intAddress1 <= to_integer(unsigned(ReadReg1));
	intAddress2 <= to_integer(unsigned(ReadReg2));
	DataIn(to_integer(unsigned(WriteReg))) <= WriteData;

	Mem: for i in 31 downto 1 generate		
		reg: register32 port map (DataIn(i), '0', '1', '1', WriteCmd, '0', '0', DataOut(i));
	end generate;
	-- x0 register
	DataOut(0) <= x"00000000";
	-- rd1
	ReadData1 <= DataOut(intAddress1);
	-- rd2
	ReadData2 <= DataOut(intAddress2);		
end remember;
---------------------------------------------------------------------------------------------------------------------------------------------------------------