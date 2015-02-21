-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        promscore.vhd
-- // Date:        12/9/2004
-- // Description: WHYP PROM
-- // Class:       CSE 378
-- =================================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use opcodes.all;

entity Promscore is
    port (
       addr : in STD_LOGIC_VECTOR (15 downto 0);
	   M : out STD_LOGIC_VECTOR (15 downto 0)
    );
end Promscore;

architecture Promscore_arch of Promscore is

type rom_array is array (NATURAL range <>)  of STD_LOGIC_VECTOR (15 downto 0);
constant rom: rom_array := (
	JMP, 			--0
	X"0002", 		--1
	DESTROFETCH, 	--2
	CLEARLINES,		--3
	plus, 				--5
	dup, 			--6
	digstore, 		--7
	JMP, 			--8
	X"0002", 		--9
	X"0000" 		--A
	);
	
begin
  process(addr)
  variable j: integer;
  begin 
    j := conv_integer(addr);
    M <= rom(j);
  end process; 

end Promscore_arch;
