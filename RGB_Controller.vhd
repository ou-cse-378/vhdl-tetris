-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        RGB_Controller.vhd
-- // Date:        12/9/2004
-- // Description: Outputs RGB values to the VGA Controller
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

entity RGB_Controller is
    Port ( 	oRGB : out std_logic_vector(2 downto 0);
           	iClk : in std_logic;
           	iClr : in std_logic;		 				
						iPaused : in std_logic;
						iBlock: in std_logic_vector(15 downto 0);	--Block rows fom Block RAM
						oBlockAddr : out std_logic_vector(4 downto 0);		--address for block ram
						iBlockY : in std_logic_vector(4 downto 0);				--encoded Y
						iBlockX : in std_logic_vector(3 downto 0);				--encoded X
						iBlockReg : in std_logic_vector(15 downto 0));
end RGB_Controller;

architecture Behavioral of RGB_Controller is
	Signal tHCounter, tVCounter: std_logic_vector(10 downto 0) := "00000000000";
	Signal tRGB : std_logic_vector(2 downto 0) := "000";
	Signal tGFCurrentX : integer range 0 to 10 := 0;				--Current X on Game Field being rendered, set in Pixel Counter Process
	signal tGFCurrentY : integer range 0 to 21 := 0;				--Current Y on Game Field being rendered, set in Line Counter Process
	constant GBCOLOR : std_logic_vector(2 downto 0) := "111";
	constant BLOCKCOLOR : std_logic_vector(2 downto 0) := "010";
	constant PAUSEDCOLOR : std_logic_vector(2 downto 0) := "110";
	-- Game Boundary is 3 boxes, specified by and upper left and lower right coordinate
	type GBValues is array (NATURAL range <>)  of integer;
	--Each vertical column is a box.  The GBX1, GBY1, GBX2, GBY2 specify the
	--upper left and lower right corners of the boxes
	constant GBX1 : GBValues :=(40, 245, 40);
	constant GBY1 : GBValues :=(40, 40, 440);
	constant GBX2 : GBValues :=(45, 250, 250);
	constant GBY2 : GBValues :=(440, 440, 445);
	constant PBX1 : GBValues := (0,     0, 0, 630);
	constant PBX2 : GBValues := (640, 640, 10, 640);
	constant PBY1 : GBValues := (0,   470, 10, 10);
	constant PBY2 : GBValues := (10,  480, 470, 470);
	constant GFX1 : integer := 45;
	constant GFX2 : integer := 245;
	constant GFY1 : integer := 40;
	constant GFY2 : integer := 440;
	Constant HFRONTPORCHSTART : integer :=  640;										--640
	constant HPULSESTART : integer := HFRONTPORCHSTART + 17;				--17
	constant HBACKPORCHSTART : integer := HPULSESTART + 96;					--96
	constant HENDOFLINE : integer := HBACKPORCHSTART + 46;					--47
	Constant VFRONTPORCHSTART : integer :=  480;										--480
	constant VPULSESTART : integer := VFRONTPORCHSTART + 10;				--10
	constant VBACKPORCHSTART : integer := VPULSESTART + 2;					--2
	constant VENDOFFRAME : integer := VBACKPORCHSTART + 29;					--29
begin

	PixelCounter: process(iClk, iClr, tHCounter, tVCounter)
	variable tHBlockPixelCounter, tVBlockPixelCounter : integer range 0 to 20 := 0;
	begin
		if iClr = '1' then
			tHCounter <= "00000000000";
			tVCounter <= "00000000000";
			tHBlockPixelCounter := 0;
			tVBlockPixelCounter := 0;
			tGFCurrentX <= 0;
			tGFCurrentY <= 0;
		elsif (iClk'event and iClk = '1') then
		if tHCounter < HENDOFLINE then
			tHCounter <= tHCounter + 1;
		else
			tHCounter <= "00000000000";
			if tVCounter < VENDOFFRAME then
				tVCounter <= tVCounter + 1;
			else
				tVCounter <= "00000000000";
			end if;
		end if;
			--Count pixels if we're in the game field.
			if tVCounter >= GFY1 and tVCounter < GFY2 and tHCounter >= GFX1 and tHCounter < GFX2 then		
					tHBlockPixelCounter := tHBlockPixelCounter + 1;	
			end if;

			if tHBlockPixelCounter = 20 then
				tHBlockPixelCounter := 0;
				if tGFCurrentX < 9 then
					tGFCurrentX <= tGFCurrentX + 1;
				else
					tGFCurrentX <= 0;
					if tVBlockPixelCounter = 19 then
						tVBlockPixelCounter := 0;
						if tGFCurrentY < 19 then
							tGFCurrentY <= tGFCurrentY + 1;
						else
							tGFCurrentY <= 0;
						end if;
					else
						tVBlockPixelCounter := tVBlockPixelCounter + 1;
					end if;
				end if;
			end if;				
		end if;
	end process;



	oBlockAddr <= conv_std_logic_vector((tGFCurrentY + 3), 5) when iClr = '0' else "00000";

	RGBLoad: process(iClk, iClr)
		variable tTempY : integer := 0;
		variable tTempX : integer  := 0;
		variable tBlockRow : std_logic_vector(9 downto 0) := "0000000000";
	begin
		if iClr = '1' then
			tRGB <= "000";
			tTempX := 0;
			tTempY := 0;
			tBlockRow :="0000000000";
		elsif (iClk'event and iClk = '1') then
				--Draws Game Boundry
				tRGB <= "000";
				for i in 0 to 2 loop
					if tVCounter >= GBY1(i) and tVCounter < GBY2(i) and tHCounter >= GBX1(i) and tHCounter < GBX2(i) then
						tRGB <= GBCOLOR;
					end if;
				end loop;
				if iPaused = '1' then
					for i in 0 to 3 loop
						if tVCounter >= PBY1(i) and tVCounter < PBY2(i) and tHCounter >= PBX1(i) and tHCounter < PBX2(i) then
							tRGB <= PAUSEDCOLOR;
						end if;
					end loop;
				end if;
				--Draw Blocks
				if tVCounter >= GFY1 and tVCounter < GFY2 and tHCounter >= GFX1 and tHCounter < GFX2 then
					tTempX := conv_integer(iBlockX) - 3;
					tTempY := conv_integer(iBlockY) - 3;
					tBlockRow(9 downto 0) := iBlock(12 downto 3);
					
					if tGFCurrentY = tTempY then
						if tGFCurrentX = tTempX then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(15);
						elsif tGFCurrentX = tTempX + 1 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(14);							
						elsif tGFCurrentX = tTempX + 2 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(13);
						elsif tGFCurrentX = tTempX + 3 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(12);
						end if;
					end if;
					if tGFCurrentY = tTempY + 1 then
						if tGFCurrentX = tTempX then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(11);
						elsif tGFCurrentX = tTempX + 1 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(10);							
						elsif tGFCurrentX = tTempX + 2 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(9);
						elsif tGFCurrentX = tTempX + 3 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(8);
						end if;
					end if;
					if tGFCurrentY = tTempY + 2 then
						if tGFCurrentX = tTempX then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(7);
						elsif tGFCurrentX = tTempX + 1 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(6);							
						elsif tGFCurrentX = tTempX + 2 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(5);
						elsif tGFCurrentX = tTempX + 3 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(4);
						end if;
					end if;
					if tGFCurrentY = tTempY + 3 then
						if tGFCurrentX = tTempX then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(3);
						elsif tGFCurrentX = tTempX + 1 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(2);							
						elsif tGFCurrentX = tTempX + 2 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(1);
						elsif tGFCurrentX = tTempX + 3 then
							tBlockRow(9 - tGFCurrentX) := tBlockrow(9 - tGFCurrentX) OR iBlockreg(0);
						end if;
					end if;

					if tBlockRow(9 - tGFCurrentX) = '1' then
						tRGB <= BLOCKCOLOR;
					else
						tRGB <= "000";
					end if;
				end if;
		end if;	--clk event
	end process;

	RGBOut: process(iClk, iClr)
	begin
		if iClr = '1' then
			oRGB <= "000";
		elsif (iClk'event and iClk = '1') then
				--We're on the screen. Draw things.
				oRGB <= tRGB;
		end if;
	end process;
end Behavioral;
