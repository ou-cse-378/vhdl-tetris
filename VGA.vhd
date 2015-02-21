-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        RGB_Controller.vhd
-- // Date:        12/9/2004
-- // Description: This module handles the outputting a RGB stream to the
-- //            VGA ports and handles the VSync and HSync pulses.
-- // Class:       CSE 378
-- =================================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
    Port ( 	oRGB : out std_logic_vector(2 downto 0);
           	oVSync : out std_logic;
           	oHSync : out std_logic;
           	iClk : in std_logic;
           	iClr : in std_logic;		 				
						iRGB : in std_logic_vector(2 downto 0);
						iDiag : in std_logic);
end VGA;
architecture VGA_Core of VGA is
Signal tHCounter, tVCounter: std_logic_vector(10 downto 0) := "00000000000";
Signal tHSync : std_logic := '1';
						
Constant HFRONTPORCHSTART : integer :=  640;										--640
constant HPULSESTART : integer := HFRONTPORCHSTART + 17;				--17
constant HBACKPORCHSTART : integer := HPULSESTART + 96;					--96
constant HENDOFLINE : integer := HBACKPORCHSTART + 46;					--47
Constant VFRONTPORCHSTART : integer :=  480;										--480
constant VPULSESTART : integer := VFRONTPORCHSTART + 10;				--10
constant VBACKPORCHSTART : integer := VPULSESTART + 2;					--2
constant VENDOFFRAME : integer := VBACKPORCHSTART + 29;					--29


begin

	PixelCounter: process(iClk, iClr)
	begin
		if iClr = '1' then
			tHCounter <= "00000000000";
		elsif (iClk'event and iClk = '1') then
			if tHCounter < HENDOFLINE then
				tHCounter <= tHCounter + 1;
			else
				tHCounter <= "00000000000";
			end if;
		end if;
	end process;

	LineCounter: process(tHSync, iClr)
	begin
		if iClr = '1' then
			tVCounter <= "00000000000";
		elsif (tHSync'event and tHSync = '1') then
			if tVCounter < VENDOFFRAME then
				tVCounter <= tVCounter + 1;
			else
				tVCounter <= "00000000000";
			end if;
		end if;
	end process;

	HSync: process(iClk, tHCounter, iClr)
	begin
		if iClr = '1' then
			oHSync <= '1';
			tHSync <= '1';
		elsif (iClk'event and iClk = '1') then
			if tHCounter >= HPULSESTART and tHCounter < HBACKPORCHSTART then
				tHSync <= '0';
				oHSync <= '0';
			else
				oHSync <= '1';
				tHSync <= '1';
			end if;
		end if;
	end process;

	VSync: process(tVCounter, iClr)
	begin
		if iClr = '1' then
			oVSync <= '1';
		elsif tVCounter >= VPULSESTART and tVCounter < VBACKPORCHSTART then
			oVSync <= '0';
		else
			oVSync <= '1';
		end if;
	end process;

	RGBOut: process(iClk, iClr)
	begin
		if iClr = '1' then
			oRGB <= "000";
		elsif (iClk'event and iClk = '1') then
			oRGB <= "000";
			if iDiag = '1' then
					if tHCounter <= 213 then
						oRGB <= "100";
					elsif tHCounter > 213 and tHCounter <= 426 then
						oRGB <= "010";
					elsif tHCounter > 426  and tHCounter < HFRONTPORCHSTART then
						oRGB <= "001";
					end if;
			else
					oRGB <= iRGB;
				end if;
		end if;
	end process;	  
end VGA_Core;