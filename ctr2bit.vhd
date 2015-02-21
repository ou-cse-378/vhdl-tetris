-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        ctr2bit.vhd
-- // Date:        12/9/2004
-- // Description: Display component
-- // Class:       CSE 378
-- =================================================================================


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ctr2bit is
    port (
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       q : out STD_LOGIC_VECTOR (1 downto 0)
    );
end ctr2bit;

architecture ctr2bit_arch of ctr2bit is
begin
process (clk, clr)
variable COUNT: STD_LOGIC_VECTOR (1 downto 0);
begin
   if clr = '1' then
	COUNT := "00";
   elsif clk'event and clk='1' then
      COUNT := COUNT + 1;
   end if;
   q <= COUNT;
end process;
end ctr2bit_arch;
