-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        Datastack.vhd
-- // Date:        12/9/2004
-- // Description: Datastack
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity datastack is
    port (
       TLoad : in std_logic;
	   y1 : in STD_LOGIC_VECTOR(15 downto 0);
	   nsel : in STD_LOGIC_VECTOR(1 downto 0);
	   nload : in STD_LOGIC;
	   ssel : in STD_LOGIC;
	   clk : in STD_LOGIC;
	   clr : in STD_LOGIC;
      dpush : in STD_LOGIC;
      dpop : in STD_LOGIC;
	   Tin : in STD_LOGIC_VECTOR(15 downto 0);
	   T : out STD_LOGIC_VECTOR(15 downto 0);
	   N : out STD_LOGIC_VECTOR(15 downto 0);
	   N2 : out STD_LOGIC_VECTOR(15 downto 0)
    );
end datastack;

architecture Behavioral of datastack is

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
END component;

component mux2g
	generic(width:positive);
    Port ( 
	   a : in std_logic_vector(width-1 downto 0);
       b : in std_logic_vector(width-1 downto 0);
       sel : in std_logic;
       y : out std_logic_vector(width-1 downto 0)
		 );
end component;

component mux4g
	generic(width:positive);
    Port ( 
	   a : in std_logic_vector(width-1 downto 0);
       b : in std_logic_vector(width-1 downto 0);
	   c : in std_logic_vector(width-1 downto 0);
       d : in std_logic_vector(width-1 downto 0);
	   sel : in std_logic_vector(1 downto 0);
       y : out std_logic_vector(width-1 downto 0)
		 );
end component;

component reg
    generic(width: positive);
    port (
       d : in STD_LOGIC_VECTOR (width-1 downto 0);
       load : in STD_LOGIC;
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       q : out STD_LOGIC_VECTOR (width-1 downto 0)
    );
end component;

constant bus_width: positive := 16;

signal T1: std_logic_vector(15 downto 0);
signal N1: std_logic_vector(15 downto 0);
signal NS: std_logic_vector(15 downto 0);
signal D: std_logic_vector(15 downto 0);
signal NIN: std_logic_vector(15 downto 0);
signal FULL: std_logic; 
signal EMPTY: std_logic;

begin
T <= T1;
N <= N1;
N2 <= NS;

SWtreg : reg generic map (width => bus_width) port map
	( d => TIN, load => TLOAD, clr => CLR, clk => CLK, q => T1 );
SWnreg : reg generic map (width => bus_width) port map
	( d => NIN, load => NLOAD, clr => CLR, clk => CLK, q => N1 );
SWmux2g: mux2g generic map (width => bus_width) port map
	( a => N1, b => T1, sel => SSEL, y => D );
SWmux4g: mux4g generic map (width => bus_width) port map
	( a => T1, b => NS, c => Y1, d=> Y1, sel => NSEL, y => NIN );
SWstack32x16: stack32x16 port map
	( d => D, clk => CLK, clr => CLR, push => DPUSH, pop => DPOP, full => FULL, empty => EMPTY, q => NS );

end behavioral;