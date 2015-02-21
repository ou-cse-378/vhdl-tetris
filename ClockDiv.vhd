-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        clockdiv.vhd
-- // Date:        12/9/2004
-- // Description: A clock divider.  Divides mclk into 25 Mhz, 48 Khz, and 190 Hz
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockDiv is
    Port ( iMclk : in std_logic;
           oclk190Hz : out std_logic;
           oclk48Khz : out std_logic;
					 oclk25Mhz : out std_logic);
end ClockDiv;

architecture Behavioral of ClockDiv is
signal tClkdiv: std_logic_vector(31 downto 0) := X"00000000";

begin	
	process (iMclk)
	begin
		if iMclk = '1' and iMclk'event then
			tClkdiv <= tClkdiv + 1;
		end if;
	end process;
	oClk190Hz <= tClkdiv(17);	--190.7 Hz					Seven Segment Display
	oClk48Khz <= tClkdiv(9);	--48.8 Khz					Nintenido Controller Clock
	oClk25Mhz <= tClkdiv(0); 	--25 Mhz						VGA Clock
end Behavioral;
