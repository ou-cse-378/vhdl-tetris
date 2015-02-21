-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        random.vhd
-- // Date:        12/9/2004
-- // Description: Random Number Generator
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity random is
    Port ( iClk : in std_logic;
           iClr : in std_logic;
			 		 oRandom : out std_logic_vector(2 downto 0);
					 iT : in std_logic_vector(15 downto 0);
					 iP : in std_logic_vector(15 downto 0);
					 iM : in std_logic_vector(15 downto 0);
					 iX : in std_logic_vector(3 downto 0);
					 iY : in std_logic_vector(4 downto 0));
end random;

architecture Behavioral of random is

begin
	Random: process(iClr, iClk)
	begin
		if iClr = '1' then
			oRandom <= "000";
		elsif (iClk'event and iClk = '1') then
			oRandom(0) <= iT(0) xor iP(1) xor iM(2) xor iX(2) xor iY(1);
			oRandom(1) <= iT(1) xor iP(2) xor iM(0) xor iX(1) xor iY(3);
			oRandom(2) <= iT(2) xor iP(0) xor iM(1) xor iX(0) xor iY(2);
		end if;
	end process;

end Behavioral;
