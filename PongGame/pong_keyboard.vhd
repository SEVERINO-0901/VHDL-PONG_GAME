--NOME DO PROJETO: PongGame - pong_keyboard
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de teclado, responsável por integrar o teclado PS/2 ao restante do sistema.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;

entity pong_keyboard is
	port(
		clk_in, clr_in, ps2c_in, ps2d_in : in std_logic;
		dp_out : out std_logic;
		xkey_out : out std_logic_vector(15 downto 0)
		
	);
end pong_keyboard;

architecture arch of pong_keyboard is
	signal PS2Cf, PS2Df : std_logic := '0';
	signal ps2c_filter, ps2d_filter : std_logic_vector(7 downto 0) := (others=>'0');
	signal shift1, shift2 : std_logic_vector(10 downto 0) := (others=>'0');	
begin

	--Saídas
	dp_out <= '1';
	xkey_out <= shift2(8 downto 1) & shift1(8 downto 1);
	
	--Processos
	filter : process(clk_in, clr_in, ps2c_filter, ps2d_filter) --Logica do filtro
	begin
		if clr_in = '1' then
			ps2c_filter <= (others=>'0');
			ps2d_filter <= (others=>'0');
			PS2Cf <= '1';
			PS2Df <= '1';
		elsif clk_in'event and clk_in = '1' then
			ps2c_filter(7) <= ps2c_in;
			ps2c_filter(6 downto 0) <= ps2c_filter(7 downto 1);
			ps2d_filter(7) <= ps2d_in;
			ps2d_filter(6 downto 0) <= ps2d_filter(7 downto 1);
			if ps2c_filter = X"FF" then
				PS2Cf <= '1';
			elsif ps2c_filter = X"00" then
				PS2Cf <= '0';
			end if;
			if ps2d_filter = X"FF" then
				PS2Df <= '1';
			elsif ps2d_filter = X"00" then
				PS2Df <= '0';
			end if;
		end if;
	end process filter;
	
	shift : process(PS2Cf, PS2Df, clr_in, shift1, shift2) --Logica do shift
	begin
		if (clr_in = '1') then
			shift1 <= (others=>'0');
			shift2 <= (others=>'0');
		elsif (PS2Cf'event and PS2Cf = '0') then
			shift1 <= PS2Df & shift1(10 downto 1);
			shift2 <= shift1(0) & shift2(10 downto 1);
		end if;
	end process shift;
end arch;

