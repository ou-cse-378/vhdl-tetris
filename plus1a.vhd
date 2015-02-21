-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        plus1a.vhd
-- // Date:        12/9/2004
-- // Description: Adds 1 to the input
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity plus1a is
    Port ( input : in std_logic_vector(15 downto 0);
           output : out std_logic_vector(15 downto 0));
end plus1a;

architecture plus1a_arch of plus1a is

begin

process(input)
	begin
		output <= (input + '1');
	end process;

end plus1a_arch;
