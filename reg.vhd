-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        reg.vhd
-- // Date:        12/9/2004
-- // Description: generic register
-- // Class:       CSE 378
-- =================================================================================

-- // 
-- //         d(n-1 downto 0)
-- //                |
-- //          ______I______
-- // clr  --I|             |
-- //         |     reg     |I-- clk
-- // load --I|_____________|
-- //                O
-- //                |
-- //         q(n-1 downto 0)
-- //

library IEEE;
use IEEE.std_logic_1164.all;

entity reg is
    generic(width: positive);
    port 
    (
        d: in STD_LOGIC_VECTOR (width-1 downto 0);
        load: in STD_LOGIC;
        clr: in STD_LOGIC;
        clk: in STD_LOGIC;
        q: out STD_LOGIC_VECTOR (width-1 downto 0)
    );
end reg;

architecture reg_arch of reg is
begin
  process(clk, clr)
  begin
    if clr = '1' then
      for i in width-1 downto 0 loop
        q(i) <= '0';
      end loop;
    elsif (clk'event and clk = '1') then
      if load = '1' then
        q <= d;
      end if;
    end if;
  end process; 
end reg_arch;
