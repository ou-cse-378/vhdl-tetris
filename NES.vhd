-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        NES.vhd
-- // Date:        12/9/2004
-- // Description: This module handles the input from the NES Controller.
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity NES is
    Port ( 	DataI : in std_logic;
           	clkO : out std_logic;	
						clkI : in std_logic;		--25 mhz
						waitCLKI : std_logic;		--48 Khz Khz
						clr : in std_logic;
           	latchO : out std_logic;
						Buttons : out std_logic_vector(7 downto 0)
		);
end NES;

architecture Behavioral of NES is
	type state_type is ( startup, readA, readB, readSel, readStart, readUp, readDown, readLeft, readRight);
	signal current_state, next_state : state_type;
	signal LatchBind : std_logic := '0';
	begin
		synch: process(clkI, clr)
			begin    
				if clr = '1' then
					current_state <= startup;
				elsif(clkI'event and clkI = '1') then
					current_state <= next_state;
				end if;
		end process synch;

		ReadButtons: process(current_state, waitclkI, clr)
		variable A, B, Sel, Start, Up, Left, Right, Down : std_logic := '1';
  		begin
			if clr = '1' then
				A :='1';
				B := '1';
				Sel := '1';
				Start := '1';
				Up := '1';
				Left := '1';
				Right := '1';
				Down := '1';
			elsif (waitclkI'event and waitclkI = '1') then
				Latchbind <= '0';
				case current_state is
					when startup =>
						next_state <= ReadA;
						Latchbind <= '1';
					when ReadA => 
						A := DataI;
						next_state <= ReadB;
					when ReadB =>
						B := DataI;
						next_state <= ReadSel;
					when readSel => 		
						Sel := DataI;
						next_state <= readStart;
					when readStart =>
						Start := DataI;
						next_state <= readUp;
 					when readUp =>
						Up := DataI;
						next_state <= readDown;
					when readDown =>
						Down := DataI;
						next_state <= readLeft;
 					when readLeft =>
						Left := DataI;
						next_state <= readRight;
					when readRight =>
						Right := DataI;
						next_state <= Startup;
				end case;
				Buttons(7 downto 0) <= Not(A & B & Sel & Start & Up & Down & Left & Right);
			end if;
		end process;
		clkO <= waitCLKI;
		LatchO <= waitclkI and LatchBind;
end Behavioral;