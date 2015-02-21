-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        GPU.vhd
-- // Date:        12/9/2004
-- // Description: Main GPU Module
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity GPU is
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
end GPU;

architecture Behavioral of GPU is

Signal tRGB : std_logic_vector(2 downto 0);

component RGB_Controller is
    Port ( 	oRGB : out std_logic_vector(2 downto 0);
           	iClk : in std_logic;
           	iClr : in std_logic;		 				
						iPaused : in std_logic;
						iBlock: in std_logic_vector(15 downto 0);	--Block rows fom Block RAM
						oBlockAddr : out std_logic_vector(4 downto 0);		--address for block ram
						iBlockY : in std_logic_vector(4 downto 0);				--encoded Y
						iBlockX : in std_logic_vector(3 downto 0);				--encoded X
						iBlockReg : in std_logic_vector(15 downto 0));
end component;

component VGA is
    Port ( 	oRGB : out std_logic_vector(2 downto 0);
           	oVSync : out std_logic;
           	oHSync : out std_logic;
           	iClk : in std_logic;
						iDiag : in std_logic;
           	iClr : in std_logic;		 				
						iRGB : in std_logic_vector(2 downto 0));
end component;

begin
	RGB00 : RGB_controller port map(
		oRGB => tRGB,  
		iClk => iClk25Mhz, 
		iClr => iClr,		
		iPaused => iPaused,
		iBlock => iBlockData, 
		oBlockAddr => oBlockAddr,
		iBlockX => iBlockX,
		iBlockY => iBlockY,
		iBlockReg => iBlockReg);

	VGA00 : VGA port map(
		oRGB => oRGB, 
		iRGB => tRGB,
		iDiag => iDiag, 
		oVSync => oVSync, 
		oHSync => oHSync, 
		iClk => iClk25Mhz, 
		iClr => iClr);
end Behavioral;
