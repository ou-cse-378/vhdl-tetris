-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        stack_ctrl.vhd
-- // Date:        12/9/2004
-- // Description: Stack Controller
-- // Class:       CSE 378
-- =================================================================================
library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all; 
entity stack_ctrl is     
	port (         
		clr: in STD_LOGIC;
        clk: in STD_LOGIC;
        push: in STD_LOGIC;
        pop: in STD_LOGIC;
        we: out STD_LOGIC;
        amsel: out STD_LOGIC;
        wr_addr: out STD_LOGIC_VECTOR(4 downto 0);
        rd_addr: out STD_LOGIC_VECTOR(4 downto 0);
        full: out STD_LOGIC;
        empty: out STD_LOGIC
    );
end stack_ctrl;

architecture stack_ctrl_arch of stack_ctrl is
signal full_flag, empty_flag: STD_LOGIC;
begin
  stk: process(clr, clk, push, pop, full_flag, empty_flag)
  variable push_addr, pop_addr: STD_LOGIC_VECTOR(4 downto 0);
  begin
    if clr = '1' then
      push_addr := "11111";
      pop_addr := "00000";
      empty_flag <= '1';
      full_flag <= '0';
      wr_addr <= "11111";
      rd_addr <= "00000"; 
      full <= full_flag;
      empty <= empty_flag;     
    elsif clk'event and clk = '1' then
      if push = '1' then
if pop = '0' then
        if full_flag = '0' then
          push_addr := push_addr - 1;
          pop_addr := push_addr + 1;
          empty_flag <= '0';
          if push_addr = "11111" then
            full_flag <= '1';
            push_addr := "00000";
          end if;
        end if;
			end if;
      elsif pop = '1' then
        if empty_flag = '0' then
          pop_addr := pop_addr + 1;
          if full_flag = '0' then
            push_addr := push_addr + 1;
          end if;
          full_flag <= '0';
          if pop_addr = "00000" then
            empty_flag <= '1';
          end if;
        end if;
      end if;
      wr_addr <= push_addr;
      rd_addr <= pop_addr; 
    end if;
    full <= full_flag;
    empty <= empty_flag;
    if push = '1' and full_flag = '0' then
      we <= '1';
    else
      we <= '0';
    end if;   
    if push = '1' and pop = '1' then
      amsel <= '1';
    else
      amsel <= '0';
    end if;      
  end process stk;
end stack_ctrl_arch;
