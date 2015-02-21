-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        acode.vhd
-- // Date:        12/9/2004
-- // Description: Display component
-- // Class:       CSE 378
-- =================================================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity Acode is
    port (
       Aen : in STD_LOGIC_VECTOR (3 downto 0);
       Asel : in STD_LOGIC_VECTOR (1 downto 0);
       A : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Acode;

architecture Acode_arch of Acode is
begin
  process(Aen, Asel)
  begin
    A <= "0000";
    case Asel is
      when "00" =>
        if Aen(0) = '1' then
           A <= "1000";
        end if;
      when "01" =>
        if Aen(1) = '1' then
           A <= "0100";
        end if;
      when "10" =>
        if Aen(2) = '1' then
           A <= "0010";
        end if;
      when others =>
        if Aen(3) = '1' then
           A <= "0001";
        end if; 
    end case;
  end process;                        
end Acode_arch;
