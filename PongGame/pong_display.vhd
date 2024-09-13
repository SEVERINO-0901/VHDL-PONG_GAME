--NOME DO PROJETO: PongGame - pong_display
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de display, responsável por exibir no display de 7 segmentos o placar da partida.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pong_display is
port(
	clk_in, reset_in : in std_logic;
	digit_in : in std_logic_vector(15 downto 0);
	an_out : out std_logic_vector(3 downto 0);
	display_out : out std_logic_vector(6 downto 0)
);
end pong_display;

architecture arch of pong_display is
	signal count : std_logic_vector(1 downto 0) := (others=>'0');
	signal an, digit, aen : std_logic_vector(3 downto 0) := (others=>'0');
	signal display : std_logic_vector(6 downto 0) := (others=>'0');
begin

	--Saídas
	an_out <= an; --Digito ativo do display
	display_out <= display; --Segmentos ativos do display
	
	--Atribuicoes
	aen <= "1111"; --Todos os digitos do display ativos
	
	with count select --Seleciona qual caractere será exibido em cada digito do display 
		digit <= digit_in(3 downto 0) when "00", --4° Digito 
					digit_in(7 downto 4) when "01", --3° Digito 
					digit_in(11 downto 8) when "10", --2° Digito
					digit_in(15 downto 12) when others; --1° Digito
	--seg7dec
	with digit select --Caractere exibido nos segmentos do digito
	display <= 	"0000001" when "0000", --0
					"1001111" when "0001", --1
					"0010010" when "0010", --2
					"0000110" when "0011", --3
					"1001100" when "0100", --4
					"0100100" when "0101", --5
					"0100000" when "0110", --6
					"0001111" when "0111", --7
					"0000000" when "1000", --8
					"0000100" when "1001", --9
					"0001000" when "1010", --A
					"1100000" when "1011", --B
					"0110001" when "1100", --C
					"1000010" when "1101", --D
					"0110000" when "1110", --E
					"0111000" when "1111", --F
					"1111111" when others; --NULL
	
	--Processos
	ctr2bit : process(clk_in, reset_in) --Logica do contador de 2 bits
	begin
		if reset_in = '1' then --Reset
			count <= "00"; --Reseta contador(Valor 0)
		elsif (clk_in'event and clk_in = '1') then	
			count <= count + 1; --Incrementa contador
		end if;
	end process ctr2bit;
	
	ancode : process(count, aen) --Logica do digito ativo
	begin
		if (aen(conv_integer(count)) = '1') then --Seleciona o digito ativo
			an <= (others=>'1');
			an(conv_integer(count)) <= '0';
		else
			an <= "1111";
		end if;
	end process ancode;

end arch;

