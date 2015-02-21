-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:       stack32x16.vhd
-- // Date:        12/9/2004
-- // Description: basic implementation of a stack
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity stack32x16 is
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
end stack32x16;

architecture Behavioral of stack32x16 is

component dpram32x16
	port (
	   A : IN std_logic_VECTOR(4 downto 0);
	   CLK : IN std_logic;
	   D : IN std_logic_VECTOR(15 downto 0);
	   WE : IN std_logic;
	   DPRA : IN std_logic_VECTOR(4 downto 0);
	   DPO : OUT std_logic_VECTOR(15 downto 0);
	   SPO : OUT std_logic_VECTOR(15 downto 0));
END component;

component stack_ctrl
    port (
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       push : in STD_LOGIC;
       pop : in STD_LOGIC;
       we : out STD_LOGIC;
       amsel : out STD_LOGIC;
       wr_addr : out STD_LOGIC_VECTOR(4 downto 0);
       rd_addr : out STD_LOGIC_VECTOR(4 downto 0);
       full : out STD_LOGIC;
       empty : out STD_LOGIC
    );
end component;

component mux2g
	generic(width:positive);
    Port ( 
	   a : in std_logic_vector(4 downto 0);
       b : in std_logic_vector(4 downto 0);
       sel : in std_logic;
       y : out std_logic_vector(4 downto 0)
		 );
end component;

constant bus_width: positive := 5;

signal WE: std_logic;
signal AMSEL: std_logic;
signal WR_ADDR: std_logic_vector(4 downto 0);
signal WR2_ADDR: std_logic_vector(4 downto 0);
signal RD_ADDR: std_logic_vector(4 downto 0);
signal O: std_logic_VECTOR(15 downto 0);

begin

SWdpram : dpram32x16 port map
	( A => WR2_ADDR, DPRA => RD_ADDR, WE => WE, CLK => CLK, D => D, DPO => Q, SPO => O );
SWstackctrl32 : stack_ctrl port map
	( clr => CLR, clk => CLK, push => PUSH, pop => POP, we => WE, amsel => AMSEL, wr_addr => WR_ADDR, rd_addr => RD_ADDR, full => full, empty => empty );
SWmux2g: mux2g generic map (width => bus_width) port map
	( a => WR_ADDR, b => RD_ADDR, sel => AMSEL, y => WR2_ADDR );

end behavioral;