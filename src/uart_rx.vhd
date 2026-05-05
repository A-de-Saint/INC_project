-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Antonin Hrncir (xhrncia00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    -- signals from FSM
    signal count_CE : std_logic := '0';     -- signal to start counting clock cycles
    signal read_data : std_logic := '0';    -- signal to read data (1 bit)
    signal send_data : std_logic := '0';    -- signal to send data (all 8 bits)

    -- custom signals
    signal clock_count : integer range 0 to 15 := 0;    -- clock counter
    signal mid_bit : std_logic := '0';                   -- signal if the process is mid-bit
    signal exp_end : std_logic := '0';                  -- signal if fsm should expect an end bit
    signal data_count : integer range 0 to 7 := 0;      -- counter of bits read

begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        mid_bit => MID_BIT,
        exp_end => EXP_END,

        COUNT_CE => count_ce,
        READ_DATA => read_data,
        SEND_DATA => send_data,
        VALID => DOUT_VLD
    );

    process (CLK) begin

        if RST = '1' then
            DOUT <= (others => '0');
            clock_count <= 0;
            mid_bit <= '0';
            exp_end <= '0';
            data_count <= 0;

        elsif rising_edge(CLK) then
		
	    mid_bit <= '0';
            -- check if counting is on
            if count_CE = '0' then          -- if not counting clocks
                clock_count <= 0;           -- reset clock
                if send_data = '0' then     -- if not sending data, also reset other counters and signals
                    exp_end <= '0';         -- reset end expect
                    data_count <= 0;        -- reset data count
                end if;

            -- counting clocks
            else
                if clock_count = 7 then     -- case midbit
                    mid_bit <= '1';
                    clock_count <= clock_count + 1;
                elsif clock_count = 15 then -- case end of bit
                    clock_count <= 0;
                else
                    clock_count <= clock_count + 1;     -- clock count++
                end if;
            end if;

            if read_data = '1' then
                -- save bit to its position
                case data_count is
                    when 0 =>
                        DOUT(0) <= DIN;
			            data_count <= data_count + 1;   -- data count++
                    when 1 =>
                        DOUT(1) <= DIN;
			            data_count <= data_count + 1;   -- data count++
                    when 2 =>
                        DOUT(2) <= DIN;
			            data_count <= data_count + 1;   -- data count++
                    when 3 =>
                        DOUT(3) <= DIN;
			            data_count <= data_count + 1;   -- data count++
                    when 4 =>
                        DOUT(4) <= DIN;
			            data_count <= data_count + 1;   -- data count++
                    when 5 =>
                        DOUT(5) <= DIN;
			            data_count <= data_count + 1;   -- data count++
                    when 6 =>
                        DOUT(6) <= DIN;
	                    data_count <= data_count + 1;   -- data count++

                    when 7 =>
                        DOUT(7) <= DIN;
			            exp_end <= '1';
			            data_count <= 0;
                end case;
            end if;

            if send_data = '1' then
                exp_end <= '0';
            end if;
        end if;

    end process;

end architecture;
