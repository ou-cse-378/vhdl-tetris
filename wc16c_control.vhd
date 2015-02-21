-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        WC16C_Control.vhd
-- // Date:        12/9/2004
-- // Description: WC16 Core
-- // Class:       CSE 378
-- =================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.opcodes.all;

entity WC16C_control is
    port (  
		 BTN4 : in std_logic;
			oClearLines : out std_logic;
      icode : in STD_LOGIC_VECTOR (15 downto 0);
       M : in STD_LOGIC_VECTOR (15 downto 0);  
       clr : in STD_LOGIC;
       clk : in STD_LOGIC;
       fcode : out STD_LOGIC_VECTOR (5 downto 0);
       pinc : out STD_LOGIC;
       pload : out STD_LOGIC;
       tload : out STD_LOGIC;
       nload : out STD_LOGIC;
       digload : out STD_LOGIC;
       iload : out STD_LOGIC;
	   dpush : out STD_LOGIC;
	   dpop : out STD_LOGIC;
	   tsel : out STD_LOGIC_VECTOR (2 downto 0);
	   nsel : out STD_LOGIC_VECTOR (1 downto 0);
	   ssel : out STD_LOGIC;
		R : in STD_LOGIC_VECTOR (15 downto 0);  
		T : in STD_LOGIC_VECTOR (15 downto 0);  
		rsel : out STD_LOGIC;
		rload : out STD_LOGIC;
		rdec : out STD_LOGIC;
		rpush : out STD_LOGIC;
		rpop : out STD_LOGIC;
		ldload : out STD_LOGIC;	
		psel : out STD_LOGIC;
		rinsel : out STD_LOGIC
    );
end WC16C_control;

architecture WC16C_control_arch of WC16C_control is
type state_type is (fetch, exec, exec_fetch);
signal current_state, next_state: state_type;
 
begin

synch: process(clk, clr)
  begin    
    if clr = '1' then
      current_state <= fetch;
    elsif (clk'event and clk = '1') then
      current_state <= next_state;
    end if;
 end process synch;
C1: process(current_state, M)
begin  case current_state is    
    when fetch =>				
      if M(8) = '1' then  		
        next_state <= exec;		  	
      else					
        next_state <= exec_fetch;	 	
      end if;      
    when exec_fetch =>			
      if M(8) = '1' then  		
        next_state <= exec;		  	
      else					
        next_state <= exec_fetch;		
      end if;
    when exec =>				
       next_state <= fetch;			
  end case;
end process C1;

C2: process(icode, current_state, R) --C2: process(icode, current_state, R, BTN4)--
   variable r1: std_logic;
   variable i: std_logic;
  begin 
   r1 := '0';
   for i in 15 downto 1 loop
     r1 := r1 or R(i);
   end loop;
   r1 := (not r1) and R(0);
    fcode <= "000000"; nsel <= "00"; tsel <= "000";
	ssel <= '0'; pload <= '0'; tload <= '0';
    nload <= '0'; digload <= '0'; pinc <= '1'; iload <= '0';
	dpush <= '0'; dpop <= '0'; 
	rload <= '0'; rpush <= '0'; rpop <= '0'; rinsel <= '0';
	rdec <= '0'; rsel <= '0'; ldload <='0'; psel <= '0';
	oClearLines <= '0';
    if (current_state = fetch) or 
	(current_state = exec_fetch)  then
       iload <= '1'; -- fetch next instruction 
    end if;
    if (current_state = exec) or 
	(current_state = exec_fetch) then
      case icode is
	when nop =>
	  null;                                            
    when dup =>
      nload <= '1'; dpush <= '1';
	when swap =>
	  tload <= '1'; nload <= '1'; tsel <= "111";
	when drop =>
	  tload <= '1'; nload <= '1'; tsel <= "111"; nsel <= "01"; dpop <= '1';
	when over =>
	  tload <= '1'; nload <= '1'; tsel <= "111"; dpush <= '1';
	when rot =>
	  tload <= '1'; nload <= '1'; tsel <= "110"; dpush <= '1'; dpop <= '1';                                                                   
    when mrot =>
	  tload <= '1'; nload <= '1'; tsel <= "111"; nsel <= "01"; ssel <= '1'; dpush <= '1'; dpop <= '1';
	when nip =>
	  nload <= '1'; nsel <= "01"; dpop <= '1';
	when tuck =>
	  ssel <= '1'; dpush <= '1';
	when rot_drop =>
	  dpop <='1';
	when rot_drop_swap =>
	  tload <= '1'; nload <= '1'; tsel <= "111"; dpop <= '1';
	when plus =>
          tload <= '1'; nload <= '1'; nsel <= "01"; dpop <='1'; fcode <= icode(5 downto 0);
        when plus1 =>
          tload <= '1'; fcode <= icode(5 downto 0); nsel <= "01";	  	  	  
        when invert =>
          tload <= '1'; fcode <= icode(5 downto 0); nsel <= "01";	  	  	  
        when twotimes =>
          tload <= '1'; fcode <= icode(5 downto 0); nsel <= "01";	  	  	  
	   when minus =>
	   		tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
	   when orr =>
	   		tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when andd =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when lshift =>
		  	tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when rshift =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when minus1 =>
			tload <= '1'; fcode <= icode(5 downto 0);
		when xorr =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when u2slash =>
			tload <= '1'; fcode <= icode(5 downto 0);
		when twoslash =>
			tload <= '1'; fcode <= icode(5 downto 0);
		when ones =>
			tload <= '1'; fcode <= icode(5 downto 0);
		when zeros =>
			tload <= '1'; fcode <= icode(5 downto 0);
		when zeroequal =>
			tload <= '1'; fcode <= icode(5 downto 0);
		when zeroless =>
			tload <= '1'; fcode <= icode(5 downto 0);
		when ugt =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when ult =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when eq =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when ugte =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when neq =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when gt =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when lt =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when gte =>
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when lte =>																			  
			tload <= '1'; nload <= '1'; nsel <= "01"; dpop <= '1'; fcode <= icode(5 downto 0);
		when sfetch =>
          tload <= '1'; tsel <= "010"; nload <= '1'; dpush <= '1';
    when scorefetch =>
          tload <= '1'; tsel <= "010"; nload <= '1'; dpush <= '1';
    when digstore =>
      		digload <= '1'; tload <= '1'; nload <= '1'; dpop <= '1'; tsel <= "111"; nsel <= "01";        
    when jmp =>
      		pload <= '1'; pinc <= '0';
    when destrofetch =>
					tload <= '1'; tsel <= "100"; nload <= '1'; dpush <= '1';
		when ClearLines =>
					oClearLines <= '1';
    when jb4LO =>
          pload <= not BTN4; pinc <= BTN4; 
    when jb4HI =>
          pload <= BTN4; pinc <= not BTN4;
	   when lit =>
	   		tload <= '1'; tsel <= "001"; nload <= '1'; dpush <= '1';
	   when tor =>
				tload <= '1'; nload <= '1'; tsel <= "111"; nsel <= "01"; dpop <= '1'; rload <= '1'; rpush <= '1'; rinsel <= '1';
		when rfrom =>
				tload <= '1'; nload <= '1'; tsel <= "011"; dpush <= '1'; rsel <= '1'; rload <= '1'; rpop <= '1';
		when rfetch =>
				tload <= '1'; nload <= '1'; tsel <= "011"; dpush <= '1';
		when rfromdrop =>
				rsel <= '1'; rload <= '1'; rpop <= '1';
		when ldstore =>
				ldload <= '1'; tload <= '1'; nload <= '1'; tsel <= "111"; nsel <= "01"; dpop <= '1';
		when drjne =>
			rdec <= not r1; pload <= not r1; psel <= '0'; pinc <= r1; rsel <= r1; rload <= r1; rpop <= r1;	
		when call =>
				pload <= '1'; rload <= '1'; rpush <= '1';
		when ret =>
				psel <= '1'; pload <= '1'; rsel <= '1'; rload <= '1'; rpop <= '1';
		when others =>
	    null;	  
    end case;
    end if;
  end process C2;
 end WC16C_control_arch;
