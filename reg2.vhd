-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        reg2.vhd
-- // Date:        12/9/2004
-- // Description: n line register
-- // Class:       CSE 378
-- =================================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg2 is
    generic(width: positive);
    port (
       d : in STD_LOGIC_VECTOR (width-1 downto 0);
       load : in STD_LOGIC;	
	   dec : in STD_LOGIC;
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       q : out STD_LOGIC_VECTOR (width-1 downto 0)
    );
end reg2;

architecture reg2_arch of reg2 is	 
signal temp : std_logic_vector (width-1 downto 0);
begin
  process(clk, clr)
  begin
    if clr = '1' then
      for i in width-1 downto 0 loop
        q(i) <= '0';
      end loop;
    elsif (clk'event and clk = '1') then
      if load = '1' then
        temp <= d;	  
	  elsif dec = '1' then 
		temp <= temp - '1' ;
      end if;
    end if;	
	q <= temp;
  end process; 
end reg2_arch;
