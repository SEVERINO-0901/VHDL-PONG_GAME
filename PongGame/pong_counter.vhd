--NOME DO PROJETO: PongGame - pong_counter 
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de contador, utilizada para realizar a contagem de pontos durante o jogo.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity pong_counter is
	port(
		clk_in, reset_in : in std_logic;
		d_inc_in, d_clr_in : in std_logic;
		dig0_out, dig1_out : out std_logic_vector(3 downto 0)
	);
end pong_counter;

architecture arch of pong_counter is
	signal dig0_reg, dig1_reg, dig0_next, dig1_next : unsigned(3 downto 0) := (others=>'0');
begin
	
	--Saídas
	dig0_out <= std_logic_vector(dig0_reg); --Segundo digito
	dig1_out <= std_logic_vector(dig1_reg); --Primeiro digito
	
	--Processos
	registers : process(clk_in, reset_in) --Lógica dos registradores
	begin
		if reset_in='1' then --Reset
			dig1_reg <= (others=>'0'); --Reseta registrador do 1º digito(Valor 0)
			dig0_reg <= (others=>'0'); --Reseta registrador do 2º digito(Valor 0)
		elsif (clk_in'event and clk_in='1') then
			dig1_reg <= dig1_next; --Atualiza registrador do 1º digito(Valor 0)
			dig0_reg <= dig0_next; --Atualiza registrador do 2º digito(Valor 0)
		end if;
	end process registers;
	
	counter : process(d_clr_in, d_inc_in, dig1_reg, dig0_reg) --Lógica do contador
	begin
		if (d_clr_in='1') then --Sinal de clear
			dig1_next <= (others=>'0'); --Reseta registrador do 1º digito(Valor 0)
			dig0_next <= (others=>'0'); --Reseta registrador do 2º digito(Valor 0)
		elsif (d_inc_in='1') then --Sinal de incremento
			if dig0_reg = 9 then --2º digito igual a '9'
				dig0_next <= (others=>'0'); --Reseta registrador do 2º digito(Valor 0)
				if dig1_reg = 9 then --1º digito igual a '9'
					dig1_next <= (others=>'0'); --Reseta registrador do 1º digito(Valor 0)
				else
					dig1_next <= dig1_reg + 1; --Incrementa valor do 1º digito
				end if;
			else
				dig1_next <= dig1_reg;
				dig0_next <= dig0_reg + 1; --Incrementa valor do 2º digito
			end if;
		else
			dig1_next <= dig1_reg;
			dig0_next <= dig0_reg;
		end if;
	end process counter;
end arch;

