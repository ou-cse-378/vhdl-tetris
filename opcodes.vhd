--Name:Brad McMahon
--File:Opcodes.vhd
--Date:
--Description:Opcode constants
--CSE 378

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
package opcodes is
  subtype opcode is std_logic_vector(15 downto 0);  
  -- Register instructions    			--WHYP WORDS
  constant nop:  		opcode := X"0000";	-- NOP  
  constant dup:  		opcode := X"0001";	-- DUP  
  constant swap:  		opcode := X"0002";  -- SWAP
  constant drop:  		opcode := X"0003";  -- DROP
  constant over:  		opcode := X"0004";  -- OVER
  constant rot:  		opcode := X"0005";  -- ROT
  constant mrot:  		opcode := X"0006";  -- -ROT
  constant nip:  		opcode := X"0007";  -- NIP
  constant tuck:  		opcode := X"0008";  -- TUCK
  constant rot_drop:  		opcode := X"0009";  -- ROT_DROP
  constant rot_drop_swap:  	opcode := X"000A";  -- ROT_DROP_SWAP
  -- Function unit instructions
  constant plus:  		opcode := X"0010"; 	-- + 
  constant minus:  		opcode := X"0011"; 	-- - 
  constant plus1: 		opcode := X"0012"; 	-- 1+   
  constant minus1: 		opcode := X"0013";      -- 1-
  constant invert:  		opcode := X"0014"; 	-- INVERT
  constant andd:  		opcode := X"0015";      -- AND
  constant orr:  		opcode := X"0016";      -- OR
  constant xorr:  		opcode := X"0017";      -- XOR
  constant twotimes: 		opcode := X"0018";      -- 2*
  constant u2slash: 		opcode := X"0019";      -- U2/
  constant twoslash:  		opcode := X"001A";      -- 2/
  constant rshift:  		opcode := X"001B";      -- RSHIFT
  constant lshift: 		opcode := X"001C";	-- LSHIFT
  constant ones: 		opcode := X"0020";	-- TRUE
  constant zeros:  		opcode := X"0021";	-- FALSE 
  constant zeroequal: 		opcode := X"0022";	-- 0=
  constant zeroless: 		opcode := X"0023";	-- 0<
  constant zerogreat:            opcode := X"0f23";      -- 0>  
  constant ugt:  		opcode := X"0024"; 	-- U> 
  constant ult:   		opcode := X"0025"; 	-- U<   
  constant eq:  		opcode := X"0026";      -- =
  constant ugte: 		opcode := X"0027";	-- U>=
  constant ulte:  		opcode := X"0028";	-- U<=
  constant neq:  		opcode := X"0029";      -- <>
  constant gt:  		opcode := X"002A"; 	-- > 
  constant lt:   		opcode := X"002B"; 	-- <   
  constant gte: 		opcode := X"002C";	-- >=
  constant lte:  		opcode := X"002D";	-- <=  
  -- I/O instructions
  constant sfetch:  						opcode := X"0037";  -- S@
  constant digstore:            opcode := X"0038";  -- DIG!
  constant scorefetch:        	opcode := X"0040";  -- score@	
  constant destrofetch:         opcode := X"0041";  -- destrofetch
	constant ClearLines:          opcode := X"0042";  -- ClearLines
  -- Transfer instructions
  constant lit: 		opcode := X"0100";  -- LIT  
  constant jmp:  		opcode := X"0101";  -- AGAIN, ELSE 
  constant jz:  		opcode := X"0102";  -- IF, UNTIL 
  constant jb4HI:  		opcode := X"010D";  -- waitB4
  constant jb4LO:  		opcode := X"0109";
   
	--  Return Stack and I/O instructions
	constant tor:  		        opcode := X"0030";
	constant rfrom:  		opcode := X"0031";
	constant rfetch:  		opcode := X"0032";
	constant rfromdrop:  		opcode := X"0033";
	constant ldstore:  		opcode := X"0039";
	-- Transfer Instructions
	constant drjne:			opcode :=X"0103";
	constant call:			opcode :=X"0104";
	constant ret:			opcode :=X"0105";


end opcodes; 
