-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        tetrisIO.vhd
-- // Date:        12/9/2004
-- // Description: Main Tetris Program
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

entity TetrisIO is
	port (	NESData : in std_logic;
					mclk : in std_logic;
					NESClock : out std_logic;
					NESLatch: out std_logic;
					RGB : out std_logic_vector(2 downto 0);
    			VSync : out std_logic;
    			HSync : out std_logic;
					LDG : out std_logic;
					LED : out std_logic;
					LD : out std_logic_vector(1 to 8);
					bn : in std_logic;
					BTN4 : in std_logic;
					SW : in std_logic_vector(7 downto 0);
					A : out std_logic_vector(1 to 4);
					AtoG : out std_logic_vector(6 downto 0));
end TetrisIO;

architecture Behavioral of TetrisIO is
	signal clr : std_logic;
	signal tClk190hz, tClk25mhz, tClk48khz : std_logic;
	signal Buttons : std_logic_vector(7 downto 0);
	signal tGPUBlockAddr : std_logic_vector(4 downto 0);			--Holds static blocks
  signal tGPUBlockData : std_logic_vector(15 downto 0);
	signal tDiag : std_logic;

  -- // intermediate signals connecting into the x position register
	signal t_xpos_in : std_logic_vector(3 downto 0) := "0000";
	signal t_xpos_out :	std_logic_vector(3 downto 0) := "0000";
	signal t_xpos_load : std_logic := '0';	

  -- // intermediate signals connecting into the y position register
	signal t_ypos_in : std_logic_vector(4 downto 0) := "00000";
	signal t_ypos_out :	std_logic_vector(4 downto 0) := "00000";
	signal t_ypos_load : std_logic := '0';

  -- // intermediate signals connecting into the block shape register
	signal t_block_in : std_logic_vector(15 downto 0) := X"0000";
	signal t_block_out :	std_logic_vector(15 downto 0) := X"0000";
	signal t_block_load : std_logic := '0';
	Signal tT : std_logic_vector(15 downto 0);
	signal tDigLoad : std_logic;
	Signal tAddr : std_logic_vector(15 downto 0);
	Signal tM : std_logic_vector(15 downto 0);
	Signal tLinesDestroyed : std_logic_vector(2 downto 0);
	signal tClearLines : std_logic := '0';
	Signal tClr : std_logic := '0';
	signal clrflag : std_logic := '0';
	

	-- // '1' denotes "PAUSED" status
	signal t_paused : std_logic := '0';

	-- // Intermediate signals for tetris_control
	Signal t_row_no : std_logic_vector(4 downto 0);
	Signal t_row_val : std_logic_vector(15 downto 0);
	Signal t_row_val2 : std_logic_vector(15 downto 0);
	Signal t_row_load : std_logic;
	
	signal tRandom : std_logic_vector(2 downto 0) := "000";

	component tetris_control is
  port(	
 	clk: in STD_LOGIC;
 	clr: in STD_LOGIC;

	i_buttons: in STD_LOGIC_VECTOR(7 downto 0); -- controller buttons vector

	i_block_code: in STD_LOGIC_VECTOR(2 downto 0); -- 0..8, chooses next block

	o_load_xpos:  out STD_LOGIC; -- '1' when xreg should be loaded with xpos
	o_xpos_val:   out STD_LOGIC_VECTOR(3 downto 0); -- 0..9 < 16 
	o_load_ypos:  out STD_LOGIC; -- '1' when yreg should be loaded with ypos
	o_ypos_val:   out STD_LOGIC_VECTOR(4 downto 0); -- 0..19 < 32 
     
	o_load_block: out STD_LOGIC; -- '1' when blockreg should be loaded with shape
	o_block_val:  out STD_LOGIC_VECTOR(15 downto 0); -- 4x4 block, '1' = SOLID

	o_paused: out STD_LOGIC; -- '1' when the game is paused

	-- // for fetching rows into and out of tetris_control / ramtable
	i_row_val:   in  STD_LOGIC_VECTOR(15 downto 0);
	o_row_fetch: out STD_LOGIC; -- '1' when i_row_val should be loaded for i_row_no	
	o_row_load:  out STD_LOGIC; -- '1' when o_row_val should br put for o_row_no
	o_row_no:    out STD_LOGIC_VECTOR(4 downto 0); -- 0..19 < 32		
	o_row_val:   out STD_LOGIC_VECTOR(15 downto 0);
	o_Lines_Destroyed : out std_logic_vector(2 downto 0);
	i_clear_Lines : in std_logic
	); 
	end component;
component reg is
    generic(width: positive);
    port 
    (
        d: in STD_LOGIC_VECTOR (width-1 downto 0);
        load: in STD_LOGIC;
        clr: in STD_LOGIC;
        clk: in STD_LOGIC;
        q: out STD_LOGIC_VECTOR (width-1 downto 0)
    );
end component;
	component dpram32x16 IS
	port
	(
		A: IN std_logic_VECTOR(4 downto 0);
		CLK: IN std_logic;
		D: IN std_logic_VECTOR(15 downto 0);
		WE: IN std_logic;
		DPRA: IN std_logic_VECTOR(4 downto 0);
		DPO: OUT std_logic_VECTOR(15 downto 0);
		SPO: OUT std_logic_VECTOR(15 downto 0)
	);
	end component;

	component NES is
    Port ( 	DataI : in std_logic;
           	clkO : out std_logic;	
					 	clkI : in std_logic;		--50 mhz
						waitCLKI : std_logic;		--97.6 Khz
						clr : in std_logic;
           	latchO : out std_logic;
						Buttons : out std_logic_vector(7 downto 0));
	end component;
	component ClockDiv is
	    Port ( iMclk : in std_logic;
	           oClk190Hz : out std_logic;
	           oClk48Khz : out std_logic;
						 oClk25Mhz : out std_logic);
	end component;
	component GPU is
		port(
				iClk25MHZ : in std_logic;
				iPaused : in std_logic;
				iScore : std_logic_vector(15 downto 0);
				oBlockAddr : out std_logic_vector(4 downto 0);			--Holds static blocks
				iBlockData : in std_logic_vector(15 downto 0);			--Holds each row
				iBlockY : in std_logic_vector(4 downto 0);					--top edge of moving block
				iBlockX : in std_logic_vector(3 downto 0);					--left edge of moving block
				iBlockReg : in std_logic_vector(15 downto 0);				--encoded dynamic block memory
				iClr : in std_logic;
				iDiag : in std_logic;
				oRGB : out std_logic_vector(2 downto 0);
				oVSync : out std_logic;
				oHSync : out std_logic);
	end component;
	component whypcore is
    port (
     p : out STD_LOGIC_VECTOR(15 downto 0);
	   destro : in STD_LOGIC_VECTOR(2 downto 0);
	   m : in STD_LOGIC_VECTOR(15 downto 0);
		 SW : in std_logic_vector(7 downto 0);
		  BTN4 : in std_logic;
	   clk : in STD_LOGIC;
	   clr : in STD_LOGIC;
	   digload : out STD_LOGIC;
	   ldload: out STD_LOGIC;
	   t : out STD_LOGIC_VECTOR(15 downto 0);
		 o_Clear_Lines : out std_logic
    );
	end component;
	component Promscore is
    port (
       addr : in STD_LOGIC_VECTOR (15 downto 0);
	   M : out STD_LOGIC_VECTOR (15 downto 0)
    );
	end component;
	component dig7seg is
	    Port ( T: in std_logic_vector(15 downto 0);
	    		 	 digload: in std_logic;
	           clr : in std_logic;
	           clk : in std_logic;		--25 Mhz
			 			 cclk : in std_logic;		--190 Hz
	           AtoG : out std_logic_vector(6 downto 0);
	           A : out std_logic_vector(1 to 4));
	end component;

	component IBUFG
		port (
			I : in STD_LOGIC; 
			O : out std_logic
		);
	end component;
	component random is
    Port ( iClk : in std_logic;
           iClr : in std_logic;
           iM : in std_logic_vector(15 downto 0);
					 iP : in std_logic_vector(15 downto 0);
					 oRandom : out std_logic_vector(2 downto 0);
					 iT : in std_logic_vector(15 downto 0);
					 iX : in std_logic_vector(3 downto 0);
					 iY : in std_logic_vector(4 downto 0));
end component;
	begin
		RND00 : random port map(
			iClk => tclk25Mhz,
			iClr => clr,
			iP => tAddr,
			iM => tM,
			oRandom => tRandom,
			iX => t_xpos_in,
			iY => t_ypos_in,
			iT => tT);

		GPU00 : GPU port map( 
			iClk25Mhz => tclk25Mhz, 
			iPaused => t_paused, 
			iScore => X"0000", 
			oBlockAddr => tGPUBlockAddr,
			iBlockData => tGPUBlockData,
			iBlockX => t_xpos_out,
			iBlockY => t_ypos_out,
			iBlockReg => t_block_out,
			iClr => clr,
			iDiag => tDiag,
			oRGB => RGB,
			oVSync => VSync,
			oHSync => HSync);

		CLK00 : ClockDiv port map(iMclk => mclk, oClk190Hz => tClk190hz, oClk48khz => tClk48khz, oClk25mhz => tClk25mhz);
		NES00 : NES port map(DataI => NESData, clkO => NESClock, clkI => tclk25Mhz, WaitclkI => tClk48Khz, clr => clr, latchO => NESLatch, buttons => Buttons);
		DEB00 : IBUFG port map(I => BN, O => tClr);

		RegXPos : Reg generic map(width => 4) port map(clk => tclk25Mhz, clr => clr, d => t_xpos_in, q => t_xpos_out, load => t_xpos_load);
		RegYPos : Reg generic map(width => 16) port map(clk => tclk25Mhz, clr => clr, d => t_block_in, q => t_block_out, load => t_block_load);
		RegBlk: Reg generic map(width => 5) port map(clk => tclk25Mhz, clr => clr, d => t_ypos_in, q => t_ypos_out, load => t_ypos_load);
		BlockRAM :  dpram32x16 port map(A => t_row_no, clk => tclk25Mhz, d => t_row_val, we => t_row_load, DPRA=> tGPUBlockAddr, SPO => t_row_val2, DPO => tGPUBlockData);

	  tc_00: tetris_control port map(
		  clk => tclk25Mhz,
	 	  clr => clr,
		  i_buttons => Buttons,
		  i_block_code => tRandom, 
		  o_load_xpos => t_xpos_load,
		  o_xpos_val => t_xpos_in,
		  o_load_ypos	=> t_ypos_load,
		  o_ypos_val => t_ypos_in,
		  o_load_block => t_block_load,
		  o_block_val => t_block_in,
		  o_paused => t_paused,
		  i_row_val => t_row_val2, 
		  --o_row_fetch	
		  o_row_load => t_row_load,
		  o_row_no => t_row_no,	
		  o_row_val => t_row_val,
			o_Lines_Destroyed => tLinesDestroyed,
			i_clear_Lines => tClearLines);

	d7s00:  dig7seg port map(
			T => tT,
			digload => tDigLoad,
			clr => clr,
			clk => tclk25Mhz,
			cclk => tclk190hz,
			AtoG => AtoG,
			A => A);

		PRM00: Promscore port map(
			addr => tAddr,
			M => tM);

	WPC00 : whypcore port map(
			p => tAddr,
			M => tM,
			digload => tDigLoad,
			T => tT,
			clk => tclk25Mhz,
			clr => clr,
			Destro => tLinesDestroyed,
			BTN4 => BTN4,
			SW => SW,
			o_Clear_Lines => tClearLines);
	
		Reset : process(tClk190hz, tClr, clr, Buttons)
		begin
			if tClk190hz'event and tClk190hz = '1' then
					if (((Buttons(7) and Buttons(6) and Buttons(5) and Buttons(4)) or tClr) and (not clrflag)) = '1' then
						clr <= '1';
						clrflag <= '1';
					else
						clr <= '0';
						clrflag <= '0';
				end if;
			end if;
		end process;
		tDiag <= SW(7);
		LD <= Buttons;
		LED <= clr;
		LDG <= '1';


end Behavioral;