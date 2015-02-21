-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        mux2g.vhd
-- // Date:        12/9/2004
-- // Description: 8 channel, n bit mux
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

 entity mux8g is
	generic(width:positive);
    Port (  
	   a : in std_logic_vector(width-1 downto 0);
	   b : in std_logic_vector(width-1 downto 0);
       c : in std_logic_vector(width-1 downto 0);
	   d : in std_logic_vector(width-1 downto 0);
	   e : in std_logic_vector(width-1 downto 0);
	   f : in std_logic_vector(width-1 downto 0);
       g : in std_logic_vector(width-1 downto 0);
       h : in std_logic_vector(width-1 downto 0);
       sel : in std_logic_vector(2 downto 0);
       y : out std_logic_vector(width-1 downto 0)
		 );
end mux8g;

architecture mux8g_arch of mux8g is
begin
	process(a, b, c, d, e, f, g, h, sel)
	begin
	  case sel is
	  	when "000" => y <= a;
			when "001" => y <= b;
			when "010" => y <= c;
			when "011" => y <= d;
			when "100" => y <= e;
			when "101" => y <= f;
			when "110" => y <= g;
			when others => y <= h;
	  end case;
	end process;
end mux8g_arch; 
