-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        dig7seg.vhd
-- // Date:        12/9/2004
-- // Description: Main display module
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

entity dig7seg is
    Port ( T: in std_logic_vector(15 downto 0);
    		 digload: in std_logic;
           clr : in std_logic;
           clk : in std_logic;		--25 Mhz
		 cclk : in std_logic;		--190 Hz
           AtoG : out std_logic_vector(6 downto 0);
           A : out std_logic_vector(1 to 4));
end dig7seg;

architecture Behavioral of dig7seg is

constant bus_width: positive := 16;
constant bus_width2: positive := 4;
signal y1: STD_LOGIC_VECTOR(3 downto 0) := "0000"; 
signal q1: std_logic_vector(1 downto 0) :="00";
signal Tout: std_logic_vector(15 downto 0) := "0000000000000000";
signal dig1: std_logic_vector(3 downto 0) := "0000"; 
signal dig2: std_logic_vector(3 downto 0) := "0000"; 
signal dig3: std_logic_vector(3 downto 0) := "0000"; 
signal dig4: std_logic_vector(3 downto 0) := "0000"; 
component mux4g is
    generic(width:positive);
    port (
        a: in STD_LOGIC_VECTOR (3 downto 0);
        b: in STD_LOGIC_VECTOR (3 downto 0);
	   c: in STD_LOGIC_VECTOR (3 downto 0);
	   d: in STD_LOGIC_VECTOR (3 downto 0);
        sel: in STD_LOGIC_VECTOR(1 downto 0);
        y: out STD_LOGIC_VECTOR (3 downto 0)
    );
end component;
component seg7dec is
    port (
	   q : in STD_LOGIC_VECTOR(3 downto 0);
   	   AtoG : out STD_LOGIC_VECTOR(6 downto 0));
end component;
component Acode is
    port (
        Aen: in STD_LOGIC_VECTOR (4 downto 1);
        Asel: in STD_LOGIC_VECTOR (1 downto 0);
        A: out STD_LOGIC_VECTOR (3 downto 0)
    );
end component;
component ctr2bit is
    port (
        clr: in STD_LOGIC;
        clk: in STD_LOGIC;
        q: out STD_LOGIC_VECTOR (1 downto 0));
end component;
component reg is
    generic(width: positive);
    port (
        d: in STD_LOGIC_VECTOR (width-1 downto 0);
        load: in STD_LOGIC;
        clr: in STD_LOGIC;
        clk: in STD_LOGIC;
        q: out STD_LOGIC_VECTOR (width-1 downto 0)
    );
end component;
begin
	dig1 <= Tout(15 downto 12);
	dig2 <= Tout(11 downto 8);
	dig3 <= Tout(7 downto 4);
	dig4 <= Tout(3 downto 0);

	DispReg:		reg generic map(width => bus_width) port map(d => T, load => digload, clr => clr, clk => clk, q => Tout);
	SEG7: 			seg7dec port map (q => y1, AtoG => AtoG);
	ACODE00:		Acode port map (Asel => q1, Aen => "1111", A => A);
	CTR2BIT00:	ctr2bit port map (clr => clr, clk => cclk, q => q1);
	MUX4G00:		mux4g generic map(width => bus_width2) port map(a => dig1, b => dig2, c => dig3, d => dig4, y => y1, sel => q1);
end Behavioral;
