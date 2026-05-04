-- uart_tx.vhd: UART controller - transmitting (TX) side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_TX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic_vector(7 downto 0);
        DIN_VLD  : in std_logic;
        DIN_RDY  : out std_logic;
        DOUT     : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_TX is
begin

    -- Instance of TX FSM
    fsm: entity work.UART_TX_FSM
    port map (
        CLK => CLK,
        RST => RST
    );

    DIN_RDY <= '1';
    DOUT <= '1';

end architecture;
