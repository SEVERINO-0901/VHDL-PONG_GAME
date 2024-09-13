--NOME DO PROJETO: PongGame - pong_video
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de vídeo, responsável por realizar o sincronismo de vídeo.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity pong_video is
port(
	clk_in, reset_in : in std_logic;
	hsync_out, vsync_out, video_on_out, p_tick_out : out std_logic;
	pixel_x_out, pixel_y_out : out std_logic_vector(9 downto 0)
);
end pong_video;

architecture arch of pong_video is
	constant HD : integer := 640; --Area horizontal
	constant HF : integer := 16; --Borda horizontal(esquerda)
	constant HB : integer := 48; --Borda horizontal(direita)
	constant HR : integer := 96; --Recuo horizontal
	constant VD : integer := 480; --Area vertical
	constant VF : integer := 10; --Borda vertical(inferior)
	constant VB : integer := 33; --Borda vertical(superior)
	constant VR : integer := 2; --Recuo vertical
	signal mod2_reg, mod2_next, v_sync_reg, h_sync_reg, v_sync_next, h_sync_next, h_end, v_end, pixel_tick : std_logic := '0';
	signal v_count_reg, v_count_next, h_count_reg, h_count_next : unsigned(9 downto 0) := (others=>'0');
begin

	--Saídas
	hsync_out <= h_sync_reg; --Sincronia horizontal
	vsync_out <= v_sync_reg; --Sincronia vertical 
	video_on_out <= '1' when (h_count_reg<HD) and (v_count_reg<VD) else '0'; --Vídeo ativo 
	p_tick_out <= pixel_tick; --Tick de 25MHz
	pixel_x_out <= std_logic_vector(h_count_reg); --Coordenada horizontal do pixel
	pixel_y_out <= std_logic_vector(v_count_reg); --Coordenada vertical do pixel
	
	--Atribuições
	mod2_next <= not mod2_reg; --Circuito para gerar o tick de 25MHz
	pixel_tick <= '1' when mod2_reg='1' else '0'; --Sinal do tick de 25MHz
	h_end <= '1' when h_count_reg=(HD+HF+HB+HR-1) else '0'; --Sinal do fim da sincronia horizontal
	v_end <= '1' when v_count_reg=(VD+VF+VB+VR-1) else '0'; --Sinal do fim da sincronia vertical
	h_sync_next <= '1' when (h_count_reg >=(HD+HF)) and (h_count_reg<=(HD+HF+HR-1)) else '0'; --Buffer de sincronia horizontal
	v_sync_next <= '1' when (v_count_reg >=(VD+VF)) and (v_count_reg<=(VD+VF+VR-1)) else '0'; --Buffer de sincronia vertical
	
	--Processos
	registers : process(clk_in, reset_in) --Logica dos registradores
		begin
			if reset_in = '1' then --Reseta valores
				mod2_reg <= '0';
				v_count_reg <= (others => '0');
				h_count_reg <= (others => '0');
				v_sync_reg <= '0';
				h_sync_reg <= '0';
			elsif (clk_in'event and clk_in='1') then --Atualiza valores
				mod2_reg <= mod2_next; --Contador mod-2
				v_count_reg <= v_count_next; --Contador de sincronia vertical 
				h_count_reg <= h_count_next; --Contador de sincronia horizontal 
				v_sync_reg <= v_sync_next; --Registrador de sincronia vertical
				h_sync_reg <= h_sync_next; --Registrador de sincronia horizontal	
			end if;
	end process registers;
	
	h_counter : process(h_count_reg, h_end, pixel_tick) --Logica do contador horizontal
		begin
			if pixel_tick='1' then --Tick de 25MHz
				if h_end='1' then --Fim da sincronia horizontal
					h_count_next <= (others=>'0'); --Reseta contador(Valor 0)
				else
					h_count_next <= h_count_reg + 1; --Incrementa contador
				end if;
			else
				h_count_next <= h_count_reg;
			end if;
	end process h_counter;
	
	v_counter : process(v_count_reg, h_end, v_end, pixel_tick) --Logica do contador vertical
		begin
			if pixel_tick='1' and h_end='1' then --Tick de 25MHz/Fim da sincronia horizontal
				if (v_end='1') then --Fim da sincronia vertical
					v_count_next <= (others=>'0'); --Reseta contador(Valor 0)
				else
					v_count_next <= v_count_reg + 1; --Incrementa contador
				end if;
			else
				v_count_next <= v_count_reg;
			end if;
	end process v_counter;
end arch;

