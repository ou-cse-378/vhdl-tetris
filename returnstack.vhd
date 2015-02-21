-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        returnstack.vhd
-- // Date:        12/9/2004
-- // Description: Return stack Module
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ReturnStack is
    Port ( Rin : in std_logic_vector(15 downto 0);
	 		  rsel : in std_logic;
           rload : in std_logic;
           rdec : in std_logic;
           clr : in std_logic;
           clk : in std_logic;
           rpush : in std_logic;
           rpop : in std_logic;
           R : out std_logic_vector(15 downto 0));
end ReturnStack;

architecture Behavioral of ReturnStack is

component mux2g
	generic(width:positive);
    Port ( 
	   a : in std_logic_vector(width-1 downto 0);
       b : in std_logic_vector(width-1 downto 0);
       sel : in std_logic;
       y : out std_logic_vector(width-1 downto 0)
		 );
end component;

component reg2
    generic(width: positive);
    port (
       d : in STD_LOGIC_VECTOR (width-1 downto 0);
       load : in STD_LOGIC;
		 dec : in STD_LOGIC;
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       q : out STD_LOGIC_VECTOR (width-1 downto 0)
    );
end component;

component stack32x16
    port (
       d : in STD_LOGIC_VECTOR(15 downto 0);
	   clk : in STD_LOGIC;
	   clr : in STD_LOGIC;
       push : in STD_LOGIC;
       pop : in STD_LOGIC;
	   full : out STD_LOGIC;
       empty : out STD_LOGIC;
	   q : out STD_LOGIC_VECTOR(15 downto 0)
    );
end component;
constant bus_width: positive := 16;

signal R_IN: std_logic_vector (15 downto 0);
signal RS: std_logic_vector (15 downto 0);
signal R1: std_logic_vector (15 downto 0);
signal FULL: std_logic;
signal EMPTY: std_logic;


begin
	
R <= RS;
	
SWmux2g : mux2g generic map (width => bus_width) port map
	( a => Rin, b => R1, sel => rsel, y => R_IN );	
SWr : reg2 generic map (width => bus_width) port map
	( d => R_IN, load => rload, dec => rdec, clr => clr, clk => clk, q => RS );
SWstack32x16: stack32x16 port map
	( d => RS, clk => clk, clr => clr, push => rpush, pop => rpop, full => FULL, empty => EMPTY, q => R1 );

end Behavioral;
