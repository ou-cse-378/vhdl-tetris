-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        PC.vhd
-- // Date:        12/9/2004
-- // Description: Program Counter
-- // Class:       CSE 378
-- =================================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity PC is
    port (
       d : in STD_LOGIC_VECTOR (15 downto 0);
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       inc : in STD_LOGIC;
       pload : in STD_LOGIC;        
       q : out STD_LOGIC_VECTOR (15 downto 0)
    );
end PC;

architecture PC_arch of PC is
signal COUNT: STD_LOGIC_VECTOR (15 downto 0);
begin

process (clk, clr)
begin
   if clr = '1' then
      COUNT <= "0000000000000000";
   elsif clk'event and clk='1' then
      if pload = '0' then
         if inc = '1' then
            COUNT <= COUNT + 1;
         end if;
      else
         COUNT <= d;
      end if;
   end if;
   q <= COUNT;
end process;

end PC_arch;
