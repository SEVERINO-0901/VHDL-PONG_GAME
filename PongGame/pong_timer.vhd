--NOME DO PROJETO: PongGame - pong_timer 
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de temporizador, responsável por gerar um intervalo de 2 segundos entre transições de tela dentro do jogo.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity pong_timer is
	port(
		clk_in, reset_in : in std_logic;
		timer_start_in, timer_tick_in : in std_logic;
		timer_up_out : out std_logic
	);
end pong_timer;

architecture arch of pong_timer is
	signal timer_reg, timer_next : unsigned(6 downto 0) := (others=>'0');
begin
	
	--Saidas
	timer_up_out <= '1' when timer_reg=0 else '0'; --Sinal de fim do intervalo de 2s
	
	--Processos
	registers : process(clk_in, reset_in) --Logica dos Registradores
	begin
		if reset_in='1' then --Reset
			timer_reg <= (others=>'1'); --Reseta registrador(Valor 120)
		elsif (clk_in'event and clk_in='1') then
			timer_reg <= timer_next; --Atualiza registrador	
		end if;
	end process registers;
		
	timer : process(timer_start_in, timer_reg, timer_tick_in) --Logica do temporizador
	begin
		if (timer_start_in = '1') then --Inicia temporizador
			timer_next <= (others=>'1'); --Reseta buffer(Valor 120)
		elsif (timer_tick_in = '1' and timer_reg /= 0) then --Tick de 60Hz
			timer_next <= timer_reg - 1; --Reduz valor do buffer
		else
			timer_next <= timer_reg;
		end if;
	end process timer;

end arch;

