-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        mux4g.vhd
-- // Date:        12/9/2004
-- // Description: 4 way generic mux
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

 entity mux4g is
	generic(width:positive);
    Port ( 
	   a : in std_logic_vector(width-1 downto 0);
       b : in std_logic_vector(width-1 downto 0);
	   c : in std_logic_vector(width-1 downto 0);
       d : in std_logic_vector(width-1 downto 0);
	   sel : in std_logic_vector(1 downto 0);
       y : out std_logic_vector(width-1 downto 0)
		 );
end mux4g;

architecture mux4g_arch of mux4g is
begin
	process(a, b, c, d, sel)
	begin
	  case sel is
	  	when "00" => y <= a;
		when "01" => y <= b;
		when "10" => y <= c;
		when others => y <= d;
	  end case;
	end process;

end mux4g_arch; 
