-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        Whypcore.vhd
-- // Date:        12/9/2004
-- // Description: WHYP Core
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity whypcore is
    port (
     p : out STD_LOGIC_VECTOR(15 downto 0);
	   destro : in STD_LOGIC_VECTOR(2 downto 0);
	   m : in STD_LOGIC_VECTOR(15 downto 0);
		 SW : in std_logic_vector(7 downto 0);
		  BTN4 : in std_logic;
	   b : in STD_LOGIC;
	   clk : in STD_LOGIC;
	   clr : in STD_LOGIC;
	   digload : out STD_LOGIC;
	   ldload: out STD_LOGIC;
	   t : out STD_LOGIC_VECTOR(15 downto 0);
		 o_Clear_Lines : out std_logic
    );
end whypcore;

architecture Behavioral of whypcore is

component mux2g
	generic(width:positive);
    Port (  
       a : in std_logic_vector(width-1 downto 0);
       b : in std_logic_vector(width-1 downto 0);
       sel : in std_logic;
       y : out std_logic_vector(width-1 downto 0)
		 );
end component;

component PC
    port (
       d : in STD_LOGIC_VECTOR (15 downto 0);
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       inc : in STD_LOGIC;
       pload : in STD_LOGIC;        
       q : out STD_LOGIC_VECTOR (15 downto 0)
    );
end component;

component plus1a
    Port ( input : in std_logic_vector(15 downto 0);
           output : out std_logic_vector(15 downto 0));
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

component WC16C_control
    port (
				oClearLines : out std_logic;
       icode : in STD_LOGIC_VECTOR (15 downto 0);
       M : in STD_LOGIC_VECTOR (15 downto 0);  
			 BTN4 : in std_logic;
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       fcode : out STD_LOGIC_VECTOR (5 downto 0);
       pinc : out STD_LOGIC;
       pload : out STD_LOGIC;
       tload : out STD_LOGIC;
       nload : out STD_LOGIC;
       digload : out STD_LOGIC;
       iload : out STD_LOGIC;
       dpush : out STD_LOGIC;
	   dpop : out STD_LOGIC;
	   tsel : out STD_LOGIC_VECTOR (2 downto 0);
	   nsel : out STD_LOGIC_VECTOR (1 downto 0);
	   ssel : out STD_LOGIC;
		R : in STD_LOGIC_VECTOR (15 downto 0);  
		T : in STD_LOGIC_VECTOR (15 downto 0);  
		rsel : out STD_LOGIC;
		rload : out STD_LOGIC;
		rdec : out STD_LOGIC;
		rpush : out STD_LOGIC;
		rpop : out STD_LOGIC;
		ldload : out STD_LOGIC;	
		psel : out STD_LOGIC;
		rinsel : out STD_LOGIC
    );
end component;	

component ReturnStack
    Port ( Rin : in std_logic_vector(15 downto 0);
	 		  rsel : in std_logic;
           rload : in std_logic;
           rdec : in std_logic;
           clr : in std_logic;
           clk : in std_logic;
           rpush : in std_logic;
           rpop : in std_logic;
           R : out std_logic_vector(15 downto 0));
end component;

component mux8g
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
end component;

component datastack
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
end component;

component funit1
    generic(width:positive);
    port (
       a : in STD_LOGIC_VECTOR(width-1 downto 0);
	   b : in STD_LOGIC_VECTOR(width-1 downto 0);
       sel : in STD_LOGIC_VECTOR(5 downto 0);
       y : out STD_LOGIC_VECTOR(width-1 downto 0)
    );
end component;

constant bus_width: positive := 16;

signal Y: std_logic_vector(15 downto 0);
signal tC : std_logic_vector(15 downto 0);
signal tE : std_logic_vector(15 downto 0);
signal Y1: std_logic_vector(15 downto 0);
signal T1: std_logic_vector(15 downto 0);
signal TIN: std_logic_vector(15 downto 0);
signal N: std_logic_vector(15 downto 0);
signal N2: std_logic_vector(15 downto 0);
signal ICODE: std_logic_vector(15 downto 0);
signal FCODE: std_logic_vector(5 downto 0);
signal ILOAD: std_logic;
signal R: std_logic_vector(15 downto 0);
signal E1: std_logic_vector(15 downto 0);
signal E2: std_logic_vector(15 downto 0);
signal PLOAD: std_logic;
signal TLOAD: std_logic;
signal NLOAD: std_logic;
signal PINC: std_logic;
signal NSEL: std_logic_vector(1 downto 0);
signal DPUSH: std_logic;
signal DPOP: std_logic;
signal TSEL: std_logic_vector(2 downto 0);
signal SSEL: std_logic;
signal Pin: std_logic_vector(15 downto 0);
signal PS: std_logic_vector(15 downto 0);
signal P1: std_logic_vector(15 downto 0);
signal Rin: std_logic_vector(15 downto 0);
signal rsel: std_logic;
signal rload: std_logic;
signal rdec: std_logic;
signal rpush: std_logic;
signal rpop: std_logic;
signal rinsel: std_logic;
signal psel: STD_LOGIC;

begin

T <= T1;
P <= PS;

tE <= "0000000000000" & destro(2) & destro(1) & destro(0);
tC <= "00000000" & SW;

SWpmux : mux2g generic map (width => bus_width) port map 
( a => M, b => R, sel => psel, y => Pin );

SWpc : pc port map 
( d => Pin, clr => CLR, clk => CLK, inc => PINC, pload => PLOAD, q => PS );

SWplus1a :  plus1a port map 
( input => PS, output => P1 );
SWir : reg generic map (width => bus_width) port map 
( d => M, load => ILOAD, clr => CLR, clk => CLK, q => ICODE );
SWwc16ccontrol : WC16C_control port map 
( R => R, icode => ICODE, oClearLines => o_Clear_Lines, BTN4 => BTN4, M => M, clr => CLR, clk => CLK, fcode => FCODE, pinc => PINC, pload => PLOAD, tload => TLOAD, nload => NLOAD, digload => DIGLOAD, iload => ILOAD, dpush => DPUSH, dpop => DPOP, tsel => TSEL, nsel => NSEL, ssel => SSEL, T => T1, ldload => ldload, rload => rload, rdec => rdec, rinsel => rinsel, rsel => rsel, rpush => rpush, rpop => rpop, psel => psel );	
SWrmux : mux2g generic map (width => bus_width) port map
( a => P1, b => T1, sel => rinsel, y => Rin );
SWreturnstack : ReturnStack port map
	( Rin => Rin, rsel => rsel, rload => rload, rdec => rdec, clr => clr, clk => clk, rpush => rpush, rpop => rpop, r => R );

SWtmux : mux8g generic map (width => bus_width) port map
	( a => Y, b => M, c => tC , d => R, e => tE, f => "0000000000000000", g => N2, h => N, sel => TSEL, y => TIN );

SWdatastack : datastack port map
	( Tload => TLOAD, y1 => Y1, nsel => NSEL, nload => NLOAD, ssel => SSEL, clk => CLK, clr => CLR, dpush => DPUSH, dpop => DPOP, tin => TIN, N => N, N2 => N2, T => T1 );
SWfunit1 : funit1 generic map (width => bus_width) port map
	( a => T1, b => N, sel => FCODE, y => Y );

end behavioral;