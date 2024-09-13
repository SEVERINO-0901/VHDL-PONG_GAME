--NOME DO PROJETO: PongGame - pong_clkdiv 
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de divisor de clock, responsável por dividir a frequência do clock base e gerar novos sinais para operar com os periféricos do sistema.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pong_clkdiv is
port(
	clk_in, reset_in : in std_logic;
	clk25_out, clk190_out : out std_logic
);
end pong_clkdiv;

architecture arch of pong_clkdiv is
	signal q : std_logic_vector(23 downto 0) := (others=>'0');
begin
	--Saídas
	clk25_out <= q(0); --Clock de 25 MHz
	clk190_out <= q(17); --Clock de 190 Hz
	
	--Processos
	registers : process(clk_in, reset_in) --Logica dos registradores
	begin
		if reset_in = '1' then --Reset
			q <= X"000000"; --Reseta contador(Valor 0)
		elsif clk_in'event and clk_in = '1' then
			q <= q + 1; --Incrementa contador
		end if;
	end process registers;
end arch;

