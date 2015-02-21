-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        funit1.vhd
-- // Date:        12/9/2004
-- // Description: ALU Functional Unit
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity funit1 is
    generic(width:positive);
    port (
       a : in STD_LOGIC_VECTOR(width-1 downto 0);
	   b : in STD_LOGIC_VECTOR(width-1 downto 0);
       sel : in STD_LOGIC_VECTOR(5 downto 0);
       y : out STD_LOGIC_VECTOR(width-1 downto 0)
    );
end funit1;

architecture funit1_arch of funit1 is
begin
  funit_1: process(a, b, sel)
  variable true, false, z: STD_LOGIC_VECTOR (width-1 downto 0);
  variable avs, bvs: signed (width-1 downto 0);
  begin
	-- true is all ones; false is all zeros
    	for i in 0 to width-1 loop
		true(i)  := '1';
		false(i) := '0';
		z(i) := '0';
    	avs(i) := a(i);
		bvs(i) := b(i);
		end loop;
case sel is
		
	when "010000" =>				-- +
			y <= b + a;
	
	when "010001" =>                -- -
			y <= b - a;
	
	when "010010" =>                -- 1+
			y <= a + 1;
	
	when "010011" =>                -- 1-
			y <= a - 1;
	
	when "010100" =>				-- COMPLIMENT
		y <= not(a);
	
	when "010101" =>                -- AND
			y <= b AND a;
	
	when "010110" =>		-- OR
			y <= b OR a;
	
	when "010111" =>                -- XOR
			y <= b XOR a;
	
	when "011000" =>                -- 2*
			y <= a(width-2 downto 0) & '0';
	
	when "011001" =>		-- U2/
			y <= '0' & a(width-1 downto 1);
	
	when "011010" =>		-- 2/
			y <= a(width-1) & a(width-1 downto 1);
	
	when "011011" =>		-- RSHIFT
			y <= SHR(b,a);
	
	when "011100" =>		-- LSHIFT
			y <= SHL(b,a);
	
	--when "011101" =>		-- Reserved for multiplication
	  --		y <=
	
	--when "011110" =>		-- Reserved for division
	  --		y <=
			
	when "100000" =>		-- TRUE
			y <= true;
	
	when "100001" =>		-- FALSE
			y <= false;
			
	when "100010" =>		-- NOT 0=
			if a = false then
			  y <= true;
			else
			  y <= false;
			end if;
	
	when "100011" =>		-- 0<
			if a < 0 then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;	
	
	when "100100" =>		-- U>
			if b > a then
  		   	  y <= true;
  		   	else
    			  y <= false;
		    end if;
	
	when "100101" =>		-- U<
			if b < a then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;
	
	when "100110" =>		-- =
			if b = a then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;

	when "100111" =>		-- U>=
			if b >= a then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;	

	when "101000" =>		-- U<=
			if b <= a then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;	

	when "101001" =>		-- <>
			if b /= a then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;

	when "101010" =>		-- >
			if bvs > avs then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;

	when "101011" =>		-- <
			if bvs < avs then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;

	when "101100" =>		-- >=
			if bvs >= avs then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;	

	when others =>			-- <=
			if bvs <= avs then
  		   	  y <= true;
  		   	else
    			  y <= false;
		   	end if;	
  	end case;      
  end process funit_1;
end funit1_arch;