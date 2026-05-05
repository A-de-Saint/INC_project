-- uart_tx_fsm.vhd: UART controller - finite state machine controlling TX side
-- Author(s): Antonin Hrncir (xhrncia00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
       CLK : in std_logic;          -- clock
       RST : in std_logic;          -- reset
       DIN : in std_logic;          -- incoming data
       MID_BIT : in std_logic;      -- if the current clock is mid-bit
       EXP_END : in std_logic;      -- if end bit is expected

       COUNT_CE : out std_logic;    -- power clock counter
       READ_DATA : out std_logic;   -- read DIN bit (on midbit)
       SEND_DATA : out std_logic;   -- send data to DOUT
       VALID : out std_logic        -- if read word is valid
    );
end entity;



architecture behavioral of UART_RX_FSM is
    -- states of my fsm
    type fsm_states is (idle, start_prep, read_rdy, read_bit, send_valid, send_invalid);

    -- start idle
    signal curr_state : fsm_states := idle;

begin

    -- output ports
    COUNT_CE <= '0' when curr_state = idle or curr_state = send_valid or curr_state = send_invalid else '1';
    READ_DATA <= '1' when curr_state = read_bit else '0';
    SEND_DATA <= '1' when curr_state = send_valid or curr_state = send_invalid else '0';
    VALID <= '1' when curr_state = send_valid else '0';

    process(CLK) begin
        -- reset when RST received
        if RST = '1' then
            curr_state <= idle;
        elsif rising_edge(CLK) then
            case curr_state is
                when idle =>
                    if DIN = '0' then
                        curr_state <= start_prep;
                    end if;
                when start_prep =>
                    if MID_BIT = '1' then
                        if DIN = '0' then
                            curr_state <= read_rdy;
                        else 
                            curr_state <= idle;
                        end if;
                    end if;
                when read_rdy =>
                    if MID_BIT = '1' then
                        if EXP_END = '1' then
                            if DIN = '1' then
                                curr_state <= send_valid;
                            else
                                curr_state <= send_invalid;
                            end if;
                        else
                            curr_state <= read_bit;
                        end if;
                    end if;
                when read_bit =>
                    curr_state <= read_rdy;
                when send_valid =>
                    curr_state <= idle;
                when send_invalid =>
                    curr_state <= idle;
                when others => null; -- invalid entirely
            end case;
        end if;
    end process;
end architecture;
