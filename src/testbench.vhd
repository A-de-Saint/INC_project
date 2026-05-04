-- testbench.vhd: Basic UART TX side simulation testing
-- Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;



entity testbench is
end testbench;



architecture TB of testbench is

    constant baudrate : natural := 9600;
    constant clkrate : natural := baudrate*16;
    constant clk_period : time := 1 sec / clkrate;
    constant baud_period : time := clk_period*16;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal din : std_logic_vector(7 downto 0) := (others => '0');
    signal din_vld : std_logic := '0';
    signal din_rdy : std_logic;
    signal dout : std_logic;
    signal running : boolean := true;
    type monitor_state is (IDLE, START, D0, D1, D2, D3, D4, D5, D6, D7, STOP);
    signal dout_state : monitor_state := IDLE;

begin

    -- Tested module
    DUT: entity work.UART_TX
    port map (
        CLK => clk,
        RST => rst,
        DIN => din,
        DIN_VLD => din_vld,
        DIN_RDY => din_rdy,
        DOUT => dout
    );

    -- Clock generator
    clk_process: process
    begin
        while running loop
            wait for clk_period/2;
            clk <= not clk;
        end loop;
        wait;
    end process;

    -- Output monitoring and reporting
    dout_process: process
        constant msg : string := "Output DOUT value: 0x";
        constant err_start : string := "ERROR: Output data malformed, wrong START bit value!";
        constant err_stop : string := "ERROR: Output data malformed, wrong STOP bit value!";
        variable row : line;
        variable word : std_logic_vector(10-1 downto 0);
    begin
        dout_state <= IDLE;
        while running loop
            wait until rising_edge(clk);
            if dout = '0' then -- activity detected
                dout_state <= START;
                wait for clk_period*8; -- MID bit allign
                for i in 0 to 9-1 loop
                    word(i) := dout;
                    wait for clk_period*8;
                    dout_state <= monitor_state'val(monitor_state'pos(dout_state)+1);
                    wait for clk_period*8;
                end loop;
                word(9) := dout;
                wait for clk_period*8;
                dout_state <= IDLE;
                if word(0) /= '0' then
                    write(row, err_start);
                elsif word(9) /= '1' then
                    write(row, err_stop);
                else
                    write(row, msg);
                    hwrite(row, word(8 downto 1));
                end if;
                writeline(OUTPUT, row);
            end if;
        end loop;
        wait;
    end process;

    -- Main testbench process
    test: process
        -- Auxilary procedure for byte sending and DIN generation
        procedure send_byte(constant byte_in : in std_logic_vector(7 downto 0)) is
            constant msg : string := "Sending DIN value: 0x";
            variable row : line;
        begin
            wait until rising_edge(clk); -- sync to CLK edge
            din <= byte_in;
            din_vld <= '1';
            wait until rising_edge(clk); -- VLD must be active at least one cycle
            while din_rdy = '0' loop     -- or until confirmed by active RDY
                wait until rising_edge(clk); 
            end loop;
            write(row, msg);
            hwrite(row, byte_in);
            writeline(OUTPUT, row);
            din_vld <= '0';
        end send_byte;
    begin
        wait for clk_period*5;
        rst <= '0';
        wait for clk_period*5;
        send_byte("01000111");
        wait for clk_period*220;
        send_byte("01010101");
        wait for clk_period*100;
        send_byte("10101010");
        wait for clk_period*200;
        send_byte("11001010");
        wait for clk_period*20;
                                 -- <<< TODO: Insert additional test words here.
        wait for clk_period*160; -- wait for DUT to finish operation
        running <= false;
        wait;
    end process;

end architecture;
