-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        mux2g.vhd
-- // Date:        12/9/2004
-- // Description: 2 channel, n bit mux
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

 entity mux2g is
	generic(width:positive);
    Port ( 
	   a : in std_logic_vector(width-1 downto 0);
       b : in std_logic_vector(width-1 downto 0);
       sel : in std_logic;
       y : out std_logic_vector(width-1 downto 0)
		 );
end mux2g;

architecture mux2g_arch of mux2g is
begin
	process(a, b, sel)
	begin
	  case sel is
	  	when '0'  => y <= a;
		when others => y <= b;
	  end case;
	end process;

end mux2g_arch; 
