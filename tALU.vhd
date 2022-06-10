--------------------------------------------------------------------------------
--
-- Test Bench for LAB #4
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY testALU_vhd IS
END testALU_vhd;

ARCHITECTURE behavior OF testALU_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT ALU
		Port(	DataIn1: in std_logic_vector(31 downto 0);
			DataIn2: in std_logic_vector(31 downto 0);
			ALUCtrl: in std_logic_vector(4 downto 0);
			Zero: out std_logic;
			ALUResult: out std_logic_vector(31 downto 0) );
	end COMPONENT ALU;

	--Inputs
	SIGNAL datain_a : std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL datain_b : std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL control	: std_logic_vector(4 downto 0)	:= (others=>'0');

	--Outputs
	SIGNAL result   :  std_logic_vector(31 downto 0);
	SIGNAL zeroOut  :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: ALU PORT MAP(
		DataIn1 => datain_a,
		DataIn2 => datain_b,
		ALUCtrl => control,
		Zero => zeroOut,
		ALUResult => result
	);
	

	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;

		-- Start testing the ALU
		-- control(4 downto 3) mux for: arith, shift, and, or
		-- control(2) add/shift left if 0, subtract/shift right if 1
		-- control(1 downto 0) shift by x bits

		-- Testing addition
		control  <= "0000X";		-- Control in binary (ADD and ADDI test)
		datain_a <= X"01234567";	-- DataIn in hex
		datain_b <= X"11223344";
		wait for 20 ns; 
		-- Expected output: result = 0x124578AB, zeroOut = 0

		-- Testing subtraction
		control <="0001X";
		datain_a <= X"01234567";
		datain_b <= X"11223344";
		wait for 20 ns;
		-- Expected output: result = 0xF0011223, zeroOut = 0

		-- Testing 2-bit leftward shift
		control <="0010X";
		datain_b <= X"00000002";
		wait for 20 ns;
		-- Expected output: result = 0x048D159C, zeroOut = 0

		-- Testing 2-bit rightward shift
		control <="0011X";
		wait for 20 ns;
		-- Expected output: result = 0x0048D159, zeroOut = 0

		-- Testing AND operation
		control <="010XX";
		datain_b <= X"11223344";
		wait for 20 ns;
		-- Expected output: result = 0x01220144, zeroOut = 0

		-- Testing OR operation
		control <="011XX";
		wait for 20 ns;
		-- Expected output: result = 0x11237767, zeroOut = 0

		-- Testing datainb bypass
		control <="1XXXX";
		datain_b <= X"01234567";
		wait for 20 ns;
		-- Expected output: result = 0x01234567, zeroOut = 0

		-- Testing zero output
		datain_b <= X"00000000";
		wait for 20 ns;
		-- Expected output: result = 0x0, zeroOut = 1

		wait; -- will wait forever
	END PROCESS;

END;