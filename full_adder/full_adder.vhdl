-- full_adder ------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
  port (
    A   : in std_logic;
    B   : in std_logic;
    Cin : in std_logic;

    S    : out std_logic;
    Cout : out std_logic);
end entity;

architecture rtl of full_adder is
  signal x1 : std_logic;
  signal x2 : std_logic;
  signal x3 : std_logic;
begin
  x1 <= A xor B;
  S  <= x1 xor Cin;

  x2   <= Cin and x1;
  x3   <= A and B;
  Cout <= x2 or x3;
end architecture;

-- testbench -------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.std_logic;

entity testbench is
end entity;

architecture test of testbench is
  signal A    : std_logic;
  signal B    : std_logic;
  signal Cin  : std_logic;
  signal S    : std_logic;
  signal Cout : std_logic;
begin
  UUT: entity work.full_adder(rtl)
    port map (
      A    => A,
      B    => B,
      Cin  => Cin,
      S    => S,
      Cout => Cout);

  stim_process: process
  begin
    A   <= '0';
    B   <= '0';
    Cin <= '0';
    wait for 10 ns;

    A <= '1';
    wait for 10 ns;

    B <= '1';
    wait for 10 ns;

    Cin <= '1';
    wait for 10 ns;

    wait;
  end process;
end architecture;
