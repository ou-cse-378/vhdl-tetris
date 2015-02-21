-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        seg7dec
-- // Date:        12/9/2004
-- // Description: Display Component
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.std_logic_1164.all;

entity seg7dec is
    port (
	   q : in STD_LOGIC_VECTOR(3 downto 0);
   	   AtoG : out STD_LOGIC_VECTOR(6 downto 0));
end seg7dec;

architecture seg7dec_arch of seg7dec is
begin
    process(q)
    begin
        case q is
            when "0000" => AtoG <= "0000001";
            when "0001" => AtoG <= "1001111";
            when "0010" => AtoG <= "0010010";
            when "0011" => AtoG <= "0000110";
            when "0100" => AtoG <= "1001100";
            when "0101" => AtoG <= "0100100";
            when "0110" => AtoG <= "0100000";
            when "0111" => AtoG <= "0001101";
            when "1000" => AtoG <= "0000000";
            when "1001" => AtoG <= "0000100";
            when "1010" => AtoG <= "0001000";
            when "1011" => AtoG <= "1100000";
            when "1100" => AtoG <= "0110001";
            when "1101" => AtoG <= "1000010";
            when "1110" => AtoG <= "0110000";
            when others => AtoG <= "0111000";
        end case;
   end process;

end seg7dec_arch;
