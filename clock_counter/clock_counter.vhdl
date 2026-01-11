-- clock_counter.vhdl - 4-bit counter, increment on rising clock.
--
-- Counts number of clock cycles.
--
-- Could add "enable" input to count arbitrary event.
--
-- Copyright (C) 2026 Robert Coffey
-- Released under the MIT license.

package counter_pkg is
  constant DATA_WIDTH : integer := 4;
end package;

-- Full Adder ------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.counter_pkg.all;

entity full_adder is
  port (
    A, B, Cin : in std_logic;
    S, Cout   : out std_logic);
end entity;

architecture structural of full_adder is
begin
  S    <= (A xor B) xor Cin;
  Cout <= (A and B) or (Cin and (A xor B));
end architecture;

-- n-bit Ripple Adder ----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.counter_pkg.all;

entity ripple_adder is
  port (
    A, B : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    Cin  : in std_logic;
    S    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    Cout : out std_logic);
end entity;

architecture structural of ripple_adder is
  signal carry : std_logic_vector(DATA_WIDTH downto 0);
begin
  carry(0) <= Cin;

  gen_fa: for i in 0 to DATA_WIDTH - 1 generate
    fa_inst: entity work.full_adder(structural)
      port map (
        A    => A(i),
        B    => B(i),
        Cin  => carry(i),
        S    => S(i),
        Cout => carry(i+1));
  end generate;

  Cout <= carry(DATA_WIDTH);
end architecture;

-- n-Bit Register --------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.counter_pkg.all;

entity counter_register is
  port (
    clk, rst_n : in std_logic;
    D          : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    Q          : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end entity;

architecture structural of counter_register is
begin
  process (rst_n, clk)
  begin
    -- asynchronous clear
    if rst_n = '0' then
      Q <= (others => '0');
    -- synchronous load
    elsif rising_edge(clk) then
      Q <= D;
    end if;
  end process;
end architecture;

-- n-bit Counter ---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.counter_pkg.all;

entity counter is
  port (
    clk, rst_n : in std_logic;
    ticks      : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end entity;

architecture structural of counter is
  signal ticks_sig : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal adder_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
begin
  adder: entity work.ripple_adder(structural)
    port map (
      A   => ticks_sig,
      B   => (0 => '1', others => '0'),
      Cin => '0',
      S   => adder_out);

  reg: entity work.counter_register(structural)
    port map (
      clk   => clk,
      rst_n => rst_n,
      D     => adder_out,
      Q     => ticks_sig);

  ticks <= ticks_sig;
end architecture;

-- Testbench -------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.counter_pkg.all;

entity testbench is
end entity;

architecture test of testbench is
  signal clk, rst_n : std_logic;
  signal ticks      : std_logic_vector(DATA_WIDTH - 1 downto 0);
begin
  UUT: entity work.counter(structural)
    port map (
      clk   => clk,
      rst_n => rst_n,
      ticks => ticks);

  stim_process: process
  begin
    rst_n <= '0';
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
    rst_n <= '1';

    for i in 0 to 16 loop
      clk <= '1';
      wait for 1 ns;
      clk <= '0';
      wait for 1 ns;
    end loop;

    wait;
  end process;
end architecture;
