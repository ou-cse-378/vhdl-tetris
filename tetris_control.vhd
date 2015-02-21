-- =================================================================================
-- // Name:        Bryan Mason, James Batcheler, & Brad	McMahon
-- // File:        tetris_control.vhd
-- // Date:        12/9/2004
-- // Description: Tetris program controller
-- // Class:       CSE 378
-- =================================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity tetris_control is
port 
(	
 	clk: in STD_LOGIC;
 	clr: in STD_LOGIC;

	i_buttons: in STD_LOGIC_VECTOR(7 downto 0); -- controller buttons vector

	i_block_code: in STD_LOGIC_VECTOR(2 downto 0); -- 0..7, chooses next block

	o_load_xpos:  out STD_LOGIC; -- '1' when xreg should be loaded with xpos
	o_xpos_val:   out STD_LOGIC_VECTOR(3 downto 0); -- 0..9 < 16 
	o_load_ypos:  out STD_LOGIC; -- '1' when yreg should be loaded with ypos
	o_ypos_val:   out STD_LOGIC_VECTOR(4 downto 0); -- 0..19 < 32 
     
	o_load_block: out STD_LOGIC; -- '1' when blockreg should be loaded with shape
	o_block_val:  out STD_LOGIC_VECTOR(15 downto 0); -- 4x4 block, '1' = SOLID

	o_paused: out STD_LOGIC; -- '1' when the game is paused

	-- // for fetching rows into and out of tetris_control / ramtable
	i_row_val:   in  STD_LOGIC_VECTOR(15 downto 0);
	o_row_fetch: out STD_LOGIC; -- '1' when i_row_val should be loaded for i_row_no	
	o_row_load:  out STD_LOGIC; -- '1' when o_row_val should br put for o_row_no
	o_row_no:    out STD_LOGIC_VECTOR(4 downto 0); -- 0..19 < 32		
	o_row_val:   out STD_LOGIC_VECTOR(15 downto 0);
	o_Lines_Destroyed : out std_logic_vector(2 downto 0);
	i_Clear_Lines : in std_logic
); 
end tetris_control;

architecture tetris_control_arch of tetris_control is  
type state_type is 
(
	startup,
	purge,
	wait_for_start,
	read_nes_pad, 
	make_block, 
	move_left,
	move_right,
	move_down,
	check_down,
	check_down2,
	rot_right,
	rot_left,
	fetch_in_row0,
	fetch_in_row1,
	fetch_in_row2,
	write_out_row0,
	write_out_row,
	kill_row,
	kill_row2,
	kill_row3,
	kill_row4
);

	-- // the number of clock cycles that pass before the block will drop
	-- // 50,000,000 = 1 Hz = 1 second
	constant C_READ_GAME_INPUT_MAX_TICKS: positive := 50000000;
	--constant C_READ_GAME_INPUT_MAX_TICKS: positive := 20;
	
	-- // the number of ticks to wait between controller commands (buffering)
	constant C_MASTER_READ_WAIT_TICKS: positive := 25000000 / 5;
     --constant C_MASTER_READ_WAIT_TICKS: positive := 10;

	-- // the grid offset for to the first position (x,y) on screen
	constant C_GRID_OFFSET: positive := 3;

     constant C_READ_BUTTON_A_WAIT_TICKS: positive := C_MASTER_READ_WAIT_TICKS*2;
	constant C_READ_BUTTON_B_WAIT_TICKS: positive := C_MASTER_READ_WAIT_TICKS*2; 
	constant C_READ_BUTTON_SELECT_WAIT_TICKS: positive := C_MASTER_READ_WAIT_TICKS; 
	constant C_READ_BUTTON_START_WAIT_TICKS: positive := C_MASTER_READ_WAIT_TICKS*4;
	constant C_READ_BUTTON_UP_WAIT_TICKS: positive := C_MASTER_READ_WAIT_TICKS/2;
	constant C_READ_BUTTON_DOWN_WAIT_TICKS: positive := C_MASTER_READ_WAIT_TICKS/2;
	constant C_READ_BUTTON_LEFT_WAIT_TICKS: positive := C_MASTER_READ_WAIT_TICKS/2;
	constant C_READ_BUTTON_RIGHT_WAIT_TICKS: positive := C_MASTER_READ_WAIT_TICKS/2;

	-- // indexes to breakout the individual buttons from the button vector
	constant BUTTON_A: integer := 7;
	constant BUTTON_B: integer := 6;
	constant BUTTON_SELECT: integer := 5;
	constant BUTTON_START: integer := 4;
	constant BUTTON_UP: integer := 3;
	constant BUTTON_DOWN: integer := 2;
	constant BUTTON_LEFT: integer := 1;
	constant BUTTON_RIGHT: integer := 0;
	
	-- // the current count of clock cycles past since the last reset
	signal t_read_game_input_ticks: std_logic_vector(31 downto 0) := X"00000000";
	
	-- // counts up the number of rows that have been "purged" / reset
	signal t_purge_counter : integer := 0;

	signal t_Lines_Destroyed : std_logic_vector(2 downto 0) := "000";
	signal t_kill_counter : integer := 0;
	
	-- // the number of ticks that the controller input is disabled
	signal t_button_a_wait_ticks_remain: std_logic_vector(31 downto 0) := X"00000000";
	signal t_button_b_wait_ticks_remain: std_logic_vector(31 downto 0) := X"00000000";
	signal t_button_select_wait_ticks_remain: std_logic_vector(31 downto 0) := X"00000000";
	signal t_button_start_wait_ticks_remain: std_logic_vector(31 downto 0) := X"00000000";	
	signal t_button_up_wait_ticks_remain: std_logic_vector(31 downto 0) := X"00000000";
	signal t_button_down_wait_ticks_remain: std_logic_vector(31 downto 0) := X"00000000";
	signal t_button_left_wait_ticks_remain: std_logic_vector(31 downto 0) := X"00000000";
	signal t_button_right_wait_ticks_remain: std_logic_vector(31 downto 0) := X"00000000";
	signal t_lines_killed : std_logic_vector(2 downto 0) := "000";
signal t_condense_inner_counter : integer := 23;
signal t_condense_outer_counter : integer := 0;
signal t_Shift_row : std_logic := '0';
signal t_condenseB : std_logic_vector(15 downto 0) := "0000000000000000";
signal t_condenseA : std_logic_vector(15 downto 0) := "0000000000000000";
	-- // signals holding for the states set for the program
	signal current_state, next_state: state_type;

    -- // the current block shape
    signal t_block_val : std_logic_vector(15 downto 0) := X"0000";

	-- // the x-position of the block on the grid
	signal t_xpos : std_logic_vector(3 downto 0) := "0011";
	-- // the y-position of the block on the grid
	signal t_ypos : std_logic_vector(4 downto 0) := "00011"; 
	
	-- // '1' when the read_nes_pad state should write out rows / make block 
	signal t_down_movement_done : std_logic := '0';
	
	-- // '1' when the fetch_row routines should stop looping
	signal t_row_fetches_done : std_logic := '1';
	
	-- // temp work variable for storing the last row processed in reading / writing
	signal t_last_row_processed : std_logic_vector(4 downto 0) := "00011";

	-- // cached row data around and below the current piece
	signal t_row0_data : std_logic_vector(15 downto 0) := X"0000";
	signal t_row1_data : std_logic_vector(15 downto 0) := X"0000";
	signal t_row2_data : std_logic_vector(15 downto 0) := X"0000";
	signal t_row3_data : std_logic_vector(15 downto 0) := X"0000";
	signal t_row4_data : std_logic_vector(15 downto 0) := X"0000";
	
begin

	-- // =================================================================																	  	
	-- // process for clear, setting up first state, next state progression
	-- // also increments counter for clock cycles processed
	-- // =================================================================
	synch: process(clk, clr)
	begin    

	   if clr = '1' then -- on clear
	     current_state <= startup;		
		 		 
	   elsif (clk'event and clk = '1') then	-- on the rising edge of the clock
	   	 -- // set the next state
	     current_state <= next_state;				
	   end if;

	end process synch;

	-- // =================================================================
	-- // process for setting up the next state based on the current state
	-- // =================================================================
	C1: process(current_state, 
	            t_read_game_input_ticks,
			    t_button_a_wait_ticks_remain,
			    t_button_b_wait_ticks_remain,
			    t_button_select_wait_ticks_remain,
			    t_button_start_wait_ticks_remain,
			    t_button_up_wait_ticks_remain,
			    t_button_down_wait_ticks_remain,
			    t_button_left_wait_ticks_remain,
			    t_button_right_wait_ticks_remain,			  
			    i_buttons,
			    t_last_row_processed,
			    t_purge_counter, t_block_val, t_row_fetches_done, t_down_movement_done, t_ypos, t_kill_counter,t_condense_outer_counter, t_Shift_row,t_condense_inner_counter)
	begin  

	  case current_state is    	  
		  
		when startup =>
		   next_state <= purge;

		when purge =>
		   if t_purge_counter < 32 then
		      next_state <= purge;
		   else
			  next_state <= wait_for_start;
		   end if;				

	    when wait_for_start =>
	       -- // wait for START button depressed, else keep waiting
		   if i_buttons(BUTTON_START) = '1' then
			   if  t_button_start_wait_ticks_remain = X"00000000" then
				  -- // TRUE when we haven't recently done something on button press		                              				
				  if t_block_val /= X"0000" then
	          	     next_state <= read_nes_pad;
				  else
				  	 next_state <= make_block; 
				  end if;
				else
				  -- // OR FALSE when we need to just keep waiting (next_state <= this)
				  next_state <= wait_for_start;
	           end if;			  
			else 
			   next_state <= wait_for_start;
		    end if;	    
    
	    when read_nes_pad =>								 	
		
	     -- // we get out of the read loop state when we have spent a certain number
		 -- // of clock ticks here, the move and rot states return back to here		  	     			  
		 if t_read_game_input_ticks < C_READ_GAME_INPUT_MAX_TICKS then	
			  			 
			  -- // ============================================== 
			  -- // ALL IN GAME BUTTON next states are set here	  
			  -- // ==============================================
			  if i_buttons(BUTTON_LEFT) = '1' then

			     if t_button_left_wait_ticks_remain = X"00000000" then
				  -- // TRUE when we haven't recently done something on button press		                              				
 				  next_state <= move_left;
				else
				  -- // OR FALSE when we need to just keep waiting (next_state <= this)
				  next_state <= read_nes_pad;
                    end if;

			  elsif i_buttons(BUTTON_RIGHT) = '1' then

			     if t_button_right_wait_ticks_remain = X"00000000" then
				  -- // TRUE when we haven't recently done something on button press		                              				
 				  next_state <= move_right;
				else
				  -- // OR FALSE when we need to just keep waiting (next_state <= this)
				  next_state <= read_nes_pad;
                    end if;

			  elsif i_buttons(BUTTON_B) = '1' then

			     if t_button_b_wait_ticks_remain = X"00000000" then
				  -- // TRUE when we haven't recently done something on button press		                              				
 				  next_state <= rot_left;
				else
				  -- // OR FALSE when we need to just keep waiting (next_state <= this)
				  next_state <= read_nes_pad;
                    end if;

			  elsif i_buttons(BUTTON_A) = '1' then

			     if t_button_a_wait_ticks_remain = X"00000000" then
				  -- // TRUE when we haven't recently done something on button press		                              				
 				  next_state <= rot_right;
				else
				  -- // OR FALSE when we need to just keep waiting (next_state <= this)
				  next_state <= read_nes_pad;
                    end if;

			  elsif i_buttons(BUTTON_START) = '1' then			     

			     if t_button_start_wait_ticks_remain = X"00000000" then
				   -- // TRUE when we haven't recently done something on button press		                              				
 				   next_state <= wait_for_start;
				 else
				   -- // OR FALSE when we need to just keep waiting (next_state <= this)
				   next_state <= read_nes_pad;
                 end if;

			  elsif i_buttons(BUTTON_DOWN) = '1' then

			     if t_button_down_wait_ticks_remain = X"00000000" then
				  -- // TRUE when we haven't recently done something on button press		                              				
 				  next_state <= move_down;
				else
				  -- // OR FALSE when we need to just keep waiting (next_state <= this)
				  next_state <= read_nes_pad;
                    end if;

			  else
			     next_state <= read_nes_pad;
			  end if;

            else
		  	  next_state <= move_down;
		  end if;

	    when make_block =>
	       -- // pull random number from random number generator
		  -- // use random number to get a block and write it into
		  -- // current block description RAM
		  -- // dump the starting block position out to the xreg, yreg
		  next_state <= read_nes_pad;
			
			when fetch_in_row0 =>
				next_state <= fetch_in_row1;

	    when fetch_in_row1 =>
		   if t_row_fetches_done /= '1' then
	          next_state <= fetch_in_row2;
		   else
		   	  next_state <= check_down; 
		   end if;

	    when fetch_in_row2 =>
	       next_state <= fetch_in_row1;

		when check_down =>
					next_state <= check_down2;

		when check_down2 =>
		   if t_down_movement_done = '1' then
			   next_state <= write_out_row0;
		   else
			   next_state <= read_nes_pad;
		   end if;
		   
	    when move_down =>

				next_state <= fetch_in_row0;

	    when move_left =>
	       next_state <= read_nes_pad;

	    when move_right =>
	       next_state <= read_nes_pad;

	    when rot_left =>
	       next_state <= read_nes_pad;

        when rot_right =>
	       next_state <= read_nes_pad;

			when write_out_row0 =>
				next_state <= write_out_row;

	    when write_out_row =>
	       if t_last_row_processed = t_ypos + 4 then
		     next_state <= kill_row;
           else
		     next_state <= write_out_row;
           end if;

	    when kill_row =>
				if t_kill_counter <= 22 then
					next_state <= kill_row2;
				else
					next_state <= kill_row4;
				end if;

			when kill_row2 =>
				next_state <= kill_row3;
				
			when kill_row3 =>
				next_state <= kill_row;

			when kill_row4 =>
				next_state <= make_block; --condense0;

	  end case;

	end process C1;

	C2: process(current_state, clr, clk)
	   
	   -- // is set to '1' when the process should clear current clock
	   -- // cycle count to zero rather than increment it
	   variable p_read_game_input_clear: std_logic := '0';

	   -- // temp variable used by make block
	   variable p_block_val: std_logic_vector(15 downto 0) := X"0000";

	   -- // what the block would look like rotated to the left
	   variable p_block_left : std_logic_vector(15 downto 0) := X"0000";

	   -- // what the block would look like rotated to the right
	   variable p_block_right : std_logic_vector(15 downto 0) := X"0000";

	   -- // temporary variables
	   variable p_tmp_work : std_logic_vector(3 downto 0) := "0000"; 
	   variable p_tmp_var : std_logic := '0';
	   
	   -- // temporary x,y position
	   variable p_ypos : integer range 26 downto 0 := 0;
	   variable p_xpos : integer range 16 downto 0 := 0;

	   -- // the data behind / near the block at its current position
	   variable p_data_behind_block : std_logic_vector(15 downto 0) := X"0000";				
	   variable p_data_below_block : std_logic_vector(3 downto 0) := "0000";
	   variable p_data_right_of_block : std_logic_vector(3 downto 0) := "0000";
	   variable p_data_left_of_block : std_logic_vector(3 downto 0) := "0000";

	   -- // '1' when named action is allowed for the current state of block	
	   variable p_move_down_ok : std_logic := '0';
	   variable p_move_left_ok : std_logic := '0';
	   variable p_move_right_ok : std_logic := '0';		
	   variable p_rotate_right_ok : std_logic := '0';		
	   variable p_rotate_left_ok : std_logic := '0';		

	   -- // row data if the current t_block were committed to the row data
	   variable p_row0_final_data : std_logic_vector(15 downto 0) := X"0000";
	   variable p_row1_final_data : std_logic_vector(15 downto 0) := X"0000";
	   variable p_row2_final_data : std_logic_vector(15 downto 0) := X"0000";
	   variable p_row3_final_data : std_logic_vector(15 downto 0) := X"0000";

	   -- // first filled columns and rows
	   variable p_first_filled_column_from_left : integer := 0;
	   variable p_first_filled_column_from_right : integer := 0;
	   variable p_first_filled_row_from_bottom : integer := 0;

	begin		
	  if (clr = '1') then
		t_Shift_row <= '0';
		t_condenseA <= "0000000000000000";
		t_condenseB <= "0000000000000000";
		t_condense_inner_counter <= 23;
		t_condense_outer_counter <= 0;
		t_read_game_input_ticks <= X"00000000";
		t_purge_counter <= 0;
		t_button_a_wait_ticks_remain <= X"00000000";
		t_button_b_wait_ticks_remain <= X"00000000";
		t_button_select_wait_ticks_remain <= X"00000000";
		t_button_start_wait_ticks_remain <= X"00000000";	
		t_button_up_wait_ticks_remain <= X"00000000";
		t_button_down_wait_ticks_remain <= X"00000000";
		t_button_left_wait_ticks_remain <= X"00000000";
		t_button_right_wait_ticks_remain <= X"00000000";
		t_Lines_Destroyed <= "000";
		o_Lines_Destroyed <= "000";
	  t_block_val <= X"0000";
		t_xpos <= "0011";
		t_ypos <= "00011"; 
		t_down_movement_done <= '0';
		t_row_fetches_done <= '1';
		t_last_row_processed <= "00011";
		t_row0_data <= X"0000";
		t_row1_data <= X"0000";
		t_row2_data <= X"0000";
		t_row3_data <= X"0000";
		t_row4_data <= X"0000";
		t_kill_counter <= 3;
	    p_read_game_input_clear := '0';
	    p_block_val := X"0000";
	    p_block_left := X"0000";
	    p_block_right := X"0000";
	    p_tmp_work := "0000"; 
	    p_tmp_var := '0';
	    p_ypos := 0;
	    p_xpos := 0;
	    p_data_behind_block := X"0000";				
	    p_data_below_block := "0000";
	    p_data_right_of_block := "0000";
	    p_data_left_of_block := "0000";	
	    p_move_down_ok := '0';
	    p_move_left_ok := '0';
	    p_move_right_ok := '0';		
	    p_rotate_right_ok := '0';		
	    p_rotate_left_ok := '0';		
	    p_row0_final_data := X"0000";
	    p_row1_final_data := X"0000";
	    p_row2_final_data := X"0000";
	    p_row3_final_data := X"0000";
	    p_first_filled_column_from_left := 0;
	    p_first_filled_column_from_right := 0;
	    p_first_filled_row_from_bottom := 0;			
			t_Shift_row <= '0';
	  elsif (clk'event and clk = '1') then
			if i_Clear_Lines = '1' then
				t_Lines_Destroyed <= "000";
				o_Lines_Destroyed <= t_Lines_Destroyed;
			end if;		


		-- // by default, don't load new xpos, ypos, or blocks
		o_load_xpos <= '0';
		o_xpos_val <= "0000";
		o_load_ypos <= '0';  
		o_ypos_val <= "00000";
		o_load_block <= '0';
		o_block_val <= X"0000";
		o_row_fetch <= '0';
		o_row_load <= '0';
	 	o_row_no <= "00000";
		o_row_val <= X"0000";		
		p_block_val := t_block_val;
		p_xpos := CONV_INTEGER(t_xpos);
		p_ypos := CONV_INTEGER(t_ypos);
		p_read_game_input_clear := '0';
		p_tmp_var := '0';
		
		-- // by default we are not paused
		o_paused <= '0';

	  	-- // predetermine the rotated forms of the current piece
	  	p_block_left := p_block_val(3) & p_block_val(7) & p_block_val(11) & p_block_val(15) &
	                    p_block_val(2) & p_block_val(6) & p_block_val(10) & p_block_val(14) &
		   		      			p_block_val(1) & p_block_val(5) & p_block_val(9)  & p_block_val(13) &
				      				p_block_val(0) & p_block_val(4) & p_block_val(8)  & p_block_val(12);
	     p_block_right := p_block_val(12) & p_block_val(8)  & p_block_val(4) & p_block_val(0) &
	                      p_block_val(13) & p_block_val(9)  & p_block_val(5) & p_block_val(1) &
		  		       				p_block_val(14) & p_block_val(10) & p_block_val(6) & p_block_val(2) &
			            			p_block_val(15) & p_block_val(11) & p_block_val(7) & p_block_val(3);

	  -- // fetch data behind / near the block using the position of the current block	 	  	  
	  for i in 0 to 3 loop
	     p_data_behind_block(15 - i) := t_row0_data(15 - p_xpos - i);	
		p_data_behind_block(11 - i) := t_row1_data(15 - p_xpos - i);
		p_data_behind_block(7 - i) := t_row2_data(15 - p_xpos - i);
		p_data_behind_block(3 - i) := t_row3_data(15 - p_xpos - i);
	  end loop;

      -- // find the first row (from bottom to top) on the piece that contains a bit
	  if ((t_block_val(12) or t_block_val(13) or t_block_val(14) or t_block_val(15)) = '1') then
	    p_first_filled_row_from_bottom := 3;
	  elsif ((t_block_val(8) or t_block_val(9) or t_block_val(10) or t_block_val(11)) = '1') then
		p_first_filled_row_from_bottom := 2;
	  elsif ((t_block_val(4) or t_block_val(5) or t_block_val(6) or t_block_val(7)) = '1') then
		p_first_filled_row_from_bottom := 1;
	  else
	    p_first_filled_row_from_bottom := 0;
      end if;

	  -- // find the first column (from right to left) on the piece that contains a bit
	  if ((t_block_val(3) or t_block_val(7) or t_block_val(11) or t_block_val(15)) = '1') then  
	  	p_first_filled_column_from_right := 3;	
	  elsif ((t_block_val(2) or t_block_val(6) or t_block_val(10) or t_block_val(14)) = '1') then
		p_first_filled_column_from_right := 2;
	  elsif ((t_block_val(1) or t_block_val(5) or t_block_val(9) or t_block_val(13)) = '1') then
		p_first_filled_column_from_right := 1;
	  else
	     p_first_filled_column_from_right := 0;	     
      end if;
	  
       -- // find the first column (from left to right) on the piece that contains a bit
	  if ((t_block_val(0) or t_block_val(4) or t_block_val(8) or t_block_val(12)) = '1') then
	     p_first_filled_column_from_left := 0;
	  elsif ((t_block_val(1) or t_block_val(5) or t_block_val(9) or t_block_val(13)) = '1') then
		p_first_filled_column_from_left := 1;
	  elsif ((t_block_val(2) or t_block_val(6) or t_block_val(10) or t_block_val(14)) = '1') then
		p_first_filled_column_from_left := 2;
	  else
	     p_first_filled_column_from_left := 3;
       end if;
	  
	  -- // fetch data below
	  for i in 0 to 3 loop
	  	p_data_below_block(3 - i) := t_row4_data(15 - p_xpos - i);
	  end loop;	  

	  -- // fetch data to the right

		--Changed from 0...3 to 1...4
	  p_data_right_of_block(3 downto 0) := 	t_row0_data(15 - p_xpos - 4) & 
			                 				t_row1_data(15 - p_xpos - 4) & 
		  	  		       					t_row2_data(15 - p_xpos - 4) & 
						  								t_row3_data(15 - p_xpos - 4);   

	  -- // fetch data to the left
	  p_data_left_of_block(3 downto 0) := t_row0_data(15 - p_xpos + 1) & 
			                			t_row1_data(15 - p_xpos + 1) &
			          	 					t_row2_data(15 - p_xpos + 1) & 
						 								t_row3_data(15 - p_xpos + 1);	 

	  -- // ===========================================================
	  -- // perform checks to see if movements are allowed
	  -- // ===========================================================

	  -- // check downward movement
	  p_tmp_var := '1';	
	  for i in 0 to 3 loop
		 p_tmp_var := p_tmp_var and (p_data_below_block(i) nand t_block_val(i)); 
	  end loop;
      for i in 0 to 11 loop
		 p_tmp_var := p_tmp_var and (p_data_behind_block(i) nand t_block_val(i+4));
	  end loop;  
	  if p_tmp_var = '1' then
	     p_move_down_ok := '1';
	  else
	  	p_move_down_ok := '0';
	  end if;
	  
	  -- // check left movement
	  p_tmp_var := '1';	
	  for i in 0 to 15 loop
		if i /= 15 and i /= 11 and i /= 7 and i /= 3 then -- exclude farthest right column
		  p_tmp_var := (p_tmp_var and (p_data_behind_block(i + 1) nand t_block_val(i)));
		end if;
	  end loop; -- check farthest left data column	 
	  for i in 0 to 3 loop
	  	p_tmp_var := p_tmp_var and (t_block_val(4*i+3) nand p_data_left_of_block(i));		  
	  end loop;	  	  
	  if p_tmp_var = '1' then
	    p_move_left_ok := '1';
	  else
	  	p_move_left_ok := '0';
	  end if;
	  	  
	  -- // check right movement
	  p_tmp_var := '1';	
	  for i in 0 to 15 loop
		if i /= 0 and i /= 4 and i /= 8 and i /= 12 then -- exclude farthest left column
		  p_tmp_var := (p_tmp_var and (p_data_behind_block(i - 1) nand t_block_val(i)));
		end if;
	  end loop; -- check farthest right column
	  for i in 0 to 3 loop
	  	p_tmp_var := p_tmp_var and (t_block_val(4*i) nand p_data_right_of_block(i));		  
	  end loop;	  	  	  
	  if p_tmp_var = '1' then
	    p_move_right_ok := '1';
	  else
	  	p_move_right_ok := '0';
	  end if;
	  
	  -- // check left rotation
	  p_tmp_var := '1';
	  for i in 0 to 15 loop
	    p_tmp_var := p_tmp_var and (p_data_behind_block(i) nand p_block_left(i));
	  end loop;
	  if p_tmp_var = '1' then
	     p_rotate_left_ok := '1';
	  else
	  	 p_rotate_left_ok := '0';
	  end if;
	  
	  -- // check right rotation
	  p_tmp_var := '1';
	  for i in 0 to 15 loop
	    p_tmp_var := p_tmp_var and (p_data_behind_block(i) nand p_block_right(i));
	  end loop;
	  if p_tmp_var = '1' then
	     p_rotate_right_ok := '1';
	  else
	  	 p_rotate_right_ok := '0';
	  end if;

	  -- // =============================================================
	  -- // build the final piece data that will be used when writing out
	  -- // =============================================================
	  p_row0_final_data(15 downto 0) := t_row0_data(15 downto 0);
	  p_row1_final_data(15 downto 0) := t_row1_data(15 downto 0);
	  p_row2_final_data(15 downto 0) := t_row2_data(15 downto 0);
	  p_row3_final_data(15 downto 0) := t_row3_data(15 downto 0);
	  for i in 0 to 3 loop
		  p_row0_final_data(15 - p_xpos - i) := (t_block_val(15  - i) or t_row0_data(15 - p_xpos - i));
			p_row1_final_data(15 - p_xpos - i) := (t_block_val(11  - i) or t_row1_data(15 - p_xpos - i)); 
		  p_row2_final_data(15 - p_xpos - i) := (t_block_val(7  - i) or t_row2_data(15 - p_xpos - i));
			p_row3_final_data(15 - p_xpos - i) := (t_block_val(3 - i) or t_row3_data(15 - p_xpos - i)); 
    end loop;

		case current_state is
		
			when startup =>
				t_purge_counter <= 0;

			when purge =>
					if t_purge_counter < 3 or t_purge_counter > 22 then
				 		o_row_val <= "1111111111111111";
			   	else
			     o_row_val <= "1110000000000111";
			   end if;
			   o_row_load <= '1';
			   o_row_no <= CONV_STD_LOGIC_VECTOR(t_purge_counter, 5);
			   t_purge_counter <= t_purge_counter + 1;
		       
		    when wait_for_start =>
			   -- // wait for START button depressed, else keep waiting
			   o_paused <= '1';
			   if (i_buttons(BUTTON_START) = '1') then
				   t_button_start_wait_ticks_remain <= CONV_STD_LOGIC_VECTOR(C_READ_BUTTON_START_WAIT_TICKS, 32);
			   end if;			   
	     
		    when read_nes_pad =>								 
			  -- // check for controller keystrokes	

				when fetch_in_row0 =>
					t_last_row_processed <= conv_std_logic_vector(p_ypos,5);
				   
		    when fetch_in_row1 =>
			  	o_row_fetch <= '1';				
					o_row_no <= t_last_row_processed;                 		       
			
		    when fetch_in_row2 =>  
			  if (t_last_row_processed /= p_ypos + 5) then
				-- // shift all rows up and shift in new row to bottom
			    t_row0_data <= t_row1_data;
			    t_row1_data <= t_row2_data;
			    t_row2_data <= t_row3_data;
			    t_row3_data <= t_row4_data;				
					t_row4_data <= i_row_val;
				--for i in 0 to 15 loop --backwards read
			    --  t_row4_data(i) <= i_row_val(15 - i);	
				--end loop;
			    t_last_row_processed <= t_last_row_processed + 1;					 
			  else				
					t_row_fetches_done <= '1';
 			  end if;

		    when move_left =>
	    	  -- // move the xreg position left
			  if p_move_left_ok = '1' then
			  	o_load_xpos <= '1';				
		  	  	p_xpos := p_xpos - 1;
				o_xpos_val <= CONV_STD_LOGIC_VECTOR(p_xpos, 4);
				t_xpos <= CONV_STD_LOGIC_VECTOR(p_xpos, 4);
				t_button_left_wait_ticks_remain <= CONV_STD_LOGIC_VECTOR(C_READ_BUTTON_LEFT_WAIT_TICKS, 32);
			  end if;

		    when move_right	=>
	    	  -- // move the xreg position right
			  if p_move_right_ok = '1' then
			  	o_load_xpos <= '1';
				p_xpos := p_xpos + 1;
		  	  	o_xpos_val <= CONV_STD_LOGIC_VECTOR(p_xpos, 4);
				t_xpos <= CONV_STD_LOGIC_VECTOR(p_xpos, 4);
				t_button_right_wait_ticks_remain <= CONV_STD_LOGIC_VECTOR(C_READ_BUTTON_RIGHT_WAIT_TICKS, 32);
			  end if;
				   
		  when move_down =>

		   
			when check_down =>
					t_row_fetches_done <= '0';
				  if p_move_down_ok = '0' then
				    t_down_movement_done <= '1';				
				  end if;		
					if p_move_down_ok = '1' then
						 t_down_movement_done <= '0';
				      -- // decrement the yreg position
							o_load_ypos <= '1';
							p_ypos := p_ypos + 1;		  		
							o_ypos_val <= CONV_STD_LOGIC_VECTOR(p_ypos, 5);
					    t_ypos <= CONV_STD_LOGIC_VECTOR(p_ypos, 5);
					  	-- // the block has moved down, reset the allowed input time 
					  	p_read_game_input_clear := '1';
							t_button_down_wait_ticks_remain <= CONV_STD_LOGIC_VECTOR(C_READ_BUTTON_DOWN_WAIT_TICKS, 32);
				  else				  
				  		--t_last_row_processed <= CONV_STD_LOGIC_VECTOR(p_ypos, 5) - 1;  
				  end if;
		
				when check_down2 =>
			  
		    when rot_left =>
	    	       -- // rotate the piece left
			  if p_rotate_left_ok = '1' then
			  	o_load_block <= '1';
				t_block_val <= p_block_left;
		  	  	o_block_val <= p_block_left;
				p_block_val := p_block_left;
				t_button_b_wait_ticks_remain <= CONV_STD_LOGIC_VECTOR(C_READ_BUTTON_B_WAIT_TICKS, 32);
			  end if;

		    when rot_right =>
		       -- // rotate the piece right
			  if p_rotate_right_ok = '1' then
			    o_load_block <= '1';
				t_block_val <= p_block_right;
			    o_block_val <= p_block_right;
				p_block_val := p_block_right;
				t_button_a_wait_ticks_remain <= CONV_STD_LOGIC_VECTOR(C_READ_BUTTON_A_WAIT_TICKS, 32);
			  end if;

		    when make_block =>
		       -- // pull random number from random number generator
			  -- // use random number to get a block and write it into
			  -- // current block description RAM
			  -- // dump the starting block position out to the xreg, yreg
				--Reset killed lines counter.
			  t_last_row_processed <= CONV_STD_LOGIC_VECTOR(C_GRID_OFFSET, 5);			  
			  o_load_xpos <= '1';
			  o_load_ypos <= '1';
			  o_xpos_val <= CONV_STD_LOGIC_VECTOR(C_GRID_OFFSET + 4, 4);  -- 7, middle (x) of screen (+3 offset border)
			  o_ypos_val <= CONV_STD_LOGIC_VECTOR(C_GRID_OFFSET, 5); -- 3, top (y) of screen (+3 offset border)
			  -- // also store current x,y position stored in signals
			  t_xpos <= CONV_STD_LOGIC_VECTOR(C_GRID_OFFSET + 4, 4);  
			  t_ypos <= CONV_STD_LOGIC_VECTOR(C_GRID_OFFSET, 5);
			  o_load_block <= '1';
			  if i_block_code = "000" then
			  	p_block_val := "1010" & -- custom "cup" block
				               "1010" & -- a REAL PAIN
							   "1110" & 
						   	   "0000";
	          elsif i_block_code = "001" then
			  	p_block_val := "0000" & -- square block
				               "0110" &
							   "0110" &
							   "0000"; 
	          elsif i_block_code = "010" then
			  	p_block_val := "0010" & -- tee block
				               "0110" &
							   "0010" &
							   "0000"; 
	          elsif i_block_code = "011" then
			  	p_block_val := "0100" & -- bolt right block
				               "0110" &
							   "0010" &
							   "0000"; 
	          elsif i_block_code = "100" then
			  	p_block_val := "0010" & -- bolt left block
				               "0110" &
							   "0100" &
							   "0000"; 
	          elsif i_block_code = "101" then
			  	p_block_val := "0010" & -- arch left block
				               "0010" &
							   "0110" &
							   "0000"; 
	          elsif i_block_code = "110" then
			  	p_block_val := "0100" & -- arch right block
				               "0100" &
							   "0110" &
							   "0000"; 		 
			  elsif i_block_code = "111" then
			  	p_block_val := "0100" & -- the legendary pipe block
				               "0100" &
						       "0100" &
							   "0100";
			  end if;
			  t_block_val <= p_block_val; 
			  o_block_val <= p_block_val;
				


				
		    when kill_row =>
					--Read in row
					o_row_no <= conv_std_logic_vector(t_kill_counter, 5);

				when kill_row2 =>
					--Make comparison.
					if i_row_val = "1111111111111111" and t_kill_counter >= 3 and t_kill_counter <= 22 then
						o_row_val <= "1110000000000111";
						o_row_no <=	conv_std_logic_vector(t_kill_counter, 5);
						o_row_load <= '1';
						t_lines_killed <= t_lines_killed + 1;
					end if;

				when kill_row3 =>
					t_kill_counter <= t_kill_counter + 1;

				when kill_row4 =>
					t_kill_counter <= 0;
					t_Lines_Destroyed <= t_lines_killed;
					o_Lines_Destroyed <= t_Lines_Destroyed;
					t_lines_killed <= "000";
					

		    when write_out_row0 =>
			  t_last_row_processed <= conv_std_logic_vector(p_ypos,5);

		    when write_out_row =>		    
		       t_down_movement_done <= '0';	              			  
			  if t_last_row_processed = p_ypos then
			      o_row_val <= p_row0_final_data;
						 o_row_load <= '1';
						 o_row_no <= CONV_STD_LOGIC_VECTOR(p_ypos, 5);
                 elsif t_last_row_processed = p_ypos + 1 then
			      o_row_val <= p_row1_final_data;
				 o_row_load <= '1';
				 o_row_no <= CONV_STD_LOGIC_VECTOR(p_ypos + 1, 5);
                 elsif t_last_row_processed = p_ypos + 2 then
			      o_row_val <= p_row2_final_data;
				 o_row_load <= '1';
				 o_row_no <= CONV_STD_LOGIC_VECTOR(p_ypos + 2, 5);
                 elsif t_last_row_processed = p_ypos + 3 then
			      o_row_val <= p_row3_final_data ;
				 o_row_load <= '1';
				 o_row_no <= CONV_STD_LOGIC_VECTOR(p_ypos + 3, 5);
                 end if;
			  t_last_row_processed <= t_last_row_processed + 1;

		end case;  	

	  -- // either increment or clear the number of ticks that have passed
	  if p_read_game_input_clear = '1' then
	     t_read_game_input_ticks <= X"00000000";
	  else
	     t_read_game_input_ticks <= t_read_game_input_ticks + 1;
       end if;
		
	  -- // decrement the no of clock cycles the read counters must wait
	  if t_button_a_wait_ticks_remain > X"00000000" then
		t_button_a_wait_ticks_remain <= t_button_a_wait_ticks_remain - 1;
	  end if;
	  if t_button_b_wait_ticks_remain > X"00000000" then
		t_button_b_wait_ticks_remain <= t_button_b_wait_ticks_remain - 1;
	  end if;
	  if t_button_start_wait_ticks_remain > X"00000000" then
		t_button_start_wait_ticks_remain <= t_button_start_wait_ticks_remain - 1;
	  end if;
	  if t_button_select_wait_ticks_remain > X"00000000" then
		t_button_select_wait_ticks_remain <= t_button_select_wait_ticks_remain - 1;
	  end if;
	  if t_button_up_wait_ticks_remain > X"00000000" then
		t_button_up_wait_ticks_remain <= t_button_up_wait_ticks_remain - 1;
	  end if;
	  if t_button_down_wait_ticks_remain > X"00000000" then
		t_button_down_wait_ticks_remain <= t_button_down_wait_ticks_remain - 1;
	  end if;
	  if t_button_left_wait_ticks_remain > X"00000000" then
		t_button_left_wait_ticks_remain <= t_button_left_wait_ticks_remain - 1;
	  end if;
	  if t_button_right_wait_ticks_remain > X"00000000" then
		t_button_right_wait_ticks_remain <= t_button_right_wait_ticks_remain - 1;
	  end if;

	end if; -- // matching endif for clk='1' and clk'event

  end process C2;

end;