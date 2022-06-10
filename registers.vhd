--------------------------------------------------------------------------------
--
-- LAB #3
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(	bitin: in std_logic;
		enout: in std_logic;
		writein: in std_logic;
		bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
			-- WAS SUPPOSED TO BE rising_edge
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;


--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		 	 enout: in std_logic;
		 	 writein: in std_logic;
		 	 bitout: out std_logic);
	end component;
begin
	-- insert your code here.
	reg8: for i in 7 downto 0 generate
		reg: bitstorage port map (datain(i), enout, writein, dataout(i));
	end generate;
end architecture memmy;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	-- hint: you'll want to put register8 as a component here 
	component register8 port (
		datain: in std_logic_vector(7 downto 0);
	   	enout:  in std_logic;
	  	writein: in std_logic;
	  	dataout: out std_logic_vector(7 downto 0));
	end component register8;
	-- so you can use it below
	signal local_enout, local_writein	: std_logic_vector(3 downto 0):= "0000";
begin
	-- insert code here.
	local_enout	<= 	(others => '0') 			when enout32 = '0' else
				(3 downto 2 => '1', others => '0') 	when enout16 = '0' else
				(3 downto 1 => '1', others => '0') 	when enout8  = '0' else
				(others => '1');
	local_writein	<= 	(others => '1') 			when writein32 = '1' else
				(3 downto 2 => '0', others => '1') 	when writein16 = '1' else
				(3 downto 1 => '0', others => '1') 	when writein8  = '1' else
				(others => '0');
	reg32: for i in 4 downto 1 generate
		reg8i: register8 port map (datain((i*8-1) downto ((i-1)*8)), local_enout(i-1), local_writein(i-1), dataout((i*8-1) downto ((i-1)*8)));
	end generate;
	--reg32: register8 port map(datain(31 downto 24), local_enout(3), local_writein(3), dataout(31 downto 24));
	--reg24: register8 port map(datain(23 downto 16), local_enout(2), local_writein(2), dataout(23 downto 16));
	--reg16: register8 port map(datain(15 downto  8), local_enout(1), local_writein(1), dataout(15 downto  8));
	--reg8 : register8 port map(datain( 7 downto  0), local_enout(0), local_writein(0), dataout( 7 downto  0));
end architecture biggermem;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is
   component fulladder port (
	a, b, cin : in std_logic;
      	sum, carry : out std_logic);
	end component fulladder;
	signal c		: std_logic_vector(32 downto 0);
	signal p_datain_b	: std_logic_vector(31 downto 0);

begin
	-- insert code here.
	-- Flip and +1 when add_sub == 1
	c(0)		<= '1'			when add_sub = '1' else '0';
	p_datain_b	<= not datain_b	when add_sub = '1' else datain_b;
	
	-- set carry out to the last carry bit
	co <= c(31);
	
	fullAdd32: for i in 31 downto 0 generate
		FAi: fulladder port map (datain_a(i), p_datain_b(i), c(i), dataout(i), c(i+1));
	end generate;
	
end architecture calc;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port(	datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
begin
	-- insert code here.
	dataout <=	(datain(30 downto 0) &   '0') when (dir = '0' and shamt = "00001") else
			(datain(29 downto 0) &  "00") when (dir = '0' and shamt = "00010") else
			(datain(28 downto 0) & "000") when (dir = '0' and shamt = "00011") else
			('0'	&	datain(31 downto 1)) when (dir = '1' and shamt = "00001") else
			("00"	&	datain(31 downto 2)) when (dir = '1' and shamt = "00010") else
			("000"&	datain(31 downto 3)) when (dir = '1' and shamt = "00011") else
			datain;

end architecture shifter;