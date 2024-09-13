--NOME DO PROJETO: PongGame - pong_top
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de topo, responsável por instanciar as demais unidades e integrá-las ao FPGA.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity pong_top is
	port(
	clk_in, reset_in, ps2c_in, ps2d_in : in std_logic;
	btn_in : in std_logic_vector(3 downto 0);
	hsync_out, vsync_out, dp_out, toggle_out : out std_logic;
	rgb_out : out std_logic_vector(2 downto 0);
	an_out : out std_logic_vector(3 downto 0);
	display_out : out std_logic_vector(6 downto 0)	
	);
end pong_top;

architecture arch of pong_top is
	type fsmd_states is(START_SCREEN, MAIN_MENU, RULES, DIFFICULT_SELECTION, OPM_NAME1, OPM_NAME2, TPM_NAME1, TPM_NAME2, ONE_PLAYER_MATCH, TWO_PLAYER_MATCH);
	signal state, next_state : fsmd_states := START_SCREEN;
	signal hsync, vsync, dp, video_on, pixel_tick, reset, start, over, timer_start, timer_tick, timer_up, clk25, clk190, clr, clr_next, toggle, toggle_next : std_logic := '0';
	signal match_type, dif, dif_next, match_winner, player_getname : std_logic_vector(1 downto 0) := (others=>'0');
	signal rgb_reg, rgb_next, text_rgb : std_logic_vector(2 downto 0) := (others=>'0');
	signal an, objects_on : std_logic_vector(3 downto 0) := (others=>'0');
	signal text_active : std_logic_vector(4 downto 0) := (others=>'0');
	signal display, digit : std_logic_vector(6 downto 0) := (others=>'0');
	signal p1_score, p2_score : std_logic_vector(7 downto 0) := (others=>'0');
	signal pixel_x, pixel_y : std_logic_vector(9 downto 0) := (others=>'0');
	signal text_on : std_logic_vector(14 downto 0) := (others=>'0');
	signal match_score, xkey, key : std_logic_vector(15 downto 0) := (others=>'0');
begin

	--Instancias
	video_unit : entity work.pong_video(arch) --unidade de vídeo
		port map(clk_in=>clk_in, reset_in=>reset, video_on_out=>video_on, p_tick_out=>pixel_tick, hsync_out=>hsync, vsync_out=>vsync, pixel_x_out=>pixel_x, pixel_y_out=>pixel_y);
	game_unit : entity work.pong_game(arch) --unidade de jogo
		port map(clk_in=>clk_in, reset_in=>reset, start_in=>start, match_type_in=>match_type, dif_in=>dif, btn_in=>btn_in, pixel_x_in=>pixel_x, pixel_y_in=>pixel_y, over_out=>over, match_winner_out=>match_winner, objects_on_out=>objects_on, p1_score_out=>p1_score, p2_score_out=>p2_score);
	timer_unit : entity work.pong_timer --temporizador
		port map(clk_in=>clk_in, reset_in=>reset, timer_start_in=>timer_start, timer_tick_in=>timer_tick, timer_up_out=>timer_up);
	clkdiv_unit : entity work.pong_clkdiv(arch) --divisor de clock
		port map(clk_in=>clk_in, reset_in=>reset, clk25_out=>clk25, clk190_out=>clk190);
	display_unit : entity work.pong_display(arch) --unidade do display
		port map(clk_in=>clk190, reset_in=>reset, digit_in=>match_score, an_out =>an, display_out =>display);
	keyboard_unit : entity work.pong_keyboard(arch) --unidade do teclado
		port map(clk_in=>clk25, clr_in=>clr, ps2c_in=>ps2c_in, ps2d_in=>ps2d_in, dp_out=>dp, xkey_out=>xkey);
	text_unit : entity work.pong_text(arch) --unidade de texto
		port map(clk_in=>clk_in, reset_in=>reset, match_winner_in=>match_winner, match_type_in=>match_type, player_getname_in=>player_getname, text_active_in=>text_active, digit_in=>digit, p1_score_in=>p1_score, p2_score_in=>p2_score, pixel_x_in=>pixel_x, pixel_y_in=>pixel_y, text_rgb_out=>text_rgb, text_on_out=>text_on);
	
	--Saídas
	hsync_out <= hsync;
	vsync_out <= vsync;
	dp_out <= dp; 
	toggle_out <= toggle;
	rgb_out <= rgb_reg;
	an_out <= an;
	display_out <= display;
	
	--Atribuicoes
	match_score <= p1_score & p2_score when (state = ONE_PLAYER_MATCH or state = TWO_PLAYER_MATCH) else (others=>'1'); --Placar do jogo/Tecla pressionada(exibido no display)
	timer_tick <= '1' when pixel_x="0000000000" and pixel_y="0000000000" else '0';  --tick de 60 Hz
	with (toggle & key) select 
		digit <= --Digito do nome
			--LOWER CASE
			"0110000" when "00100010100000000",--0
			"0110001" when "00001011000000000",--1
			"0110010" when "00001111000000000",--2
			"0110011" when "00010011000000000",--3
			"0110100" when "00010010100000000",--4
			"0110101" when "00010111000000000",--5
			"0110110" when "00011011000000000",--6
			"0110111" when "00011110100000000",--7
			"0111000" when "00011111000000000",--8
			"0111001" when "00100011000000000",--9
			"1100001" when "00001110000000000",--a
			"1100010" when "00011001000000000",--b
			"1100011" when "00010000100000000",--c
			"1100100" when "00010001100000000",--d
			"1100101" when "00010010000000000",--e
			"1100110" when "00010101100000000",--f
			"1100111" when "00011010000000000",--g
			"1101000" when "00011001100000000",--h
			"1101001" when "00100001100000000",--i
			"1101010" when "00011101100000000",--j
			"1101011" when "00100001000000000",--k
			"1101100" when "00100101100000000",--l
			"1101101" when "00011101000000000",--m
			"1101110" when "00011000100000000",--n
			"1101111" when "00100010000000000",--o
			"1110000" when "00100110100000000",--p
			"1110001" when "00001010100000000",--q
			"1110010" when "00010110100000000",--r
			"1110011" when "00001101100000000",--s
			"1110100" when "00010110000000000",--t
			"1110101" when "00011110000000000",--u
			"1110110" when "00010101000000000",--v
			"1110111" when "00001110100000000",--w
			"1111000" when "00010001000000000",--x
			"1111001" when "00011010100000000",--y
			"1111010" when "00001101000000000",--z
			--UPPER CASE
			--Shift+key
			"1000001" when "00001001000011100",--A
			"1000010" when "00001001000110010",--B
			"1000011" when "00001001000100001",--C
			"1000100" when "00001001000100011",--D
			"1000101" when "00001001000100100",--E
			"1000110" when "00001001000101011",--F
			"1000111" when "00001001000110100",--G
			"1001000" when "00001001000110011",--H
			"1001001" when "00001001001000011",--I
			"1001010" when "00001001000111011",--J
			"1001011" when "00001001001000010",--K
			"1001100" when "00001001001001011",--L
			"1001101" when "00001001000111010",--M
			"1001110" when "00001001000110001",--N
			"1001111" when "00001001001000100",--O
			"1010000" when "00001001001001101",--P
			"1010001" when "00001001000010101",--Q
			"1010010" when "00001001000101101",--R
			"1010011" when "00001001000011011",--S
			"1010100" when "00001001000101100",--T
			"1010101" when "00001001000111100",--U
			"1010110" when "00001001000101010",--V
			"1010111" when "00001001000011101",--W
			"1011000" when "00001001000100010",--X
			"1011001" when "00001001000110101",--Y
			"1011010" when "00001001000011010",--Z
			--Caps lock
			"0110000" when "10100010100000000",--0
			"0110001" when "10001011000000000",--1
			"0110010" when "10001111000000000",--2
			"0110011" when "10010011000000000",--3
			"0110100" when "10010010100000000",--4
			"0110101" when "10010111000000000",--5
			"0110110" when "10011011000000000",--6
			"0110111" when "10011110100000000",--7
			"0111000" when "10011111000000000",--8
			"0111001" when "10100011000000000",--9
			"1000001" when "10001110000000000",--A
			"1000010" when "10011001000000000",--B
			"1000011" when "10010000100000000",--C
			"1000100" when "10010001100000000",--D
			"1000101" when "10010010000000000",--E
			"1000110" when "10010101100000000",--F
			"1000111" when "10011010000000000",--G
			"1001000" when "10011001100000000",--H
			"1001001" when "10100001100000000",--I
			"1001010" when "10011101100000000",--J
			"1001011" when "10100001000000000",--K
			"1001100" when "10100101100000000",--L
			"1001101" when "10011101000000000",--M
			"1001110" when "10011000100000000",--N
			"1001111" when "10100010000000000",--O
			"1010000" when "10100110100000000",--P
			"1010001" when "10001010100000000",--Q
			"1010010" when "10010110100000000",--R
			"1010011" when "10001101100000000",--S
			"1010100" when "10010110000000000",--T
			"1010101" when "10011110000000000",--U
			"1010110" when "10010101000000000",--V
			"1010111" when "10001110100000000",--W
			"1011000" when "10010001000000000",--X
			"1011001" when "10011010100000000",--Y
			"1011010" when "10001101000000000",--Z
			--OPERADORES
			"0000001" when "-0110011000000000",--Backspace
			"0100000" when "-0010100100000000",--Spacebar
			--SÍMBOLOS
			"0100111" when "-0000111000000000",--'
			"0100010" when "-0001001000001110",--"
			"0100001" when "-0001001000010110",--!
			"1000000" when "-0001001000011110",--@
			"0100011" when "-0001001000100110",--#
			"0100100" when "-0001001000100101",--$
			"0100101" when "-0001001000101110",--%
			"0011100" when "-0001001000110110",-- ¬
			"0100110" when "-0001001000111101",--&
			"0101010" when "-0001001000111110",--*
			"0101000" when "-0001001001000110",--(
			"0101001" when "-0001001001000101",--)
			"0101101" when "-0100111000000000",-- -
			"1011111" when "-0001001001001110",--_
			"0111101" when "-0101010100000000",--=
			"0010101" when "-0001000101010101",--§	
			"0101011" when "-0001001001010101",--+
			"1100000" when "-0001001001010100",--`	
			"1011011" when "-0101011000000000",--[	
			"1111011" when "-0001001001010110",--{
			"1111110" when "-0101001000000000",--~	
			"1011110" when "-0001001001010010",--^		
			"1011101" when "-0101110100000000",--]
			"1111101" when "-0001001001011101",--}
			"0001001" when "-0001000101011101",--º	
			"1011100" when "-0110000100000000",--\	
			"0101100" when "-0100000100000000",--,
			"0111100" when "-0001001001000001",--<
			"0101110" when "-0100100100000000",--.
			"0111110" when "-0001001001001001",-->
			"0111011" when "-0100101000000000",--;
			"0111010" when "-0001001001001010",--:
			"0101111" when "-0101000100000000",--/
			"0111111" when "-0001001001010001",--?
			"0000111" when "-0001000101010001",--°
			"0000000" when others;
	
	--Processos
	sys_reset : process(xkey, reset_in) --Lógica de reset
	begin
		if ((xkey(15 downto 8) = x"76" and xkey(7 downto 0) = x"F0") or (reset_in = '1')) then --Pressionado tecla ESC
			reset <= '1'; --Ativa reset
		else
			reset <= '0';
		end if;
	end process sys_reset;
	
	fsmd : process(clk_in, reset) --Lógica da fsmd
	begin
		if reset = '1' then --Reset
			state <= START_SCREEN;
			clr <= '1';
			rgb_reg <= (others=>'0');
			dif <= (others=>'0');
		elsif (clk_in'event and clk_in='1') then --Proximo estado
			state <= next_state;
			clr <= clr_next;
			dif <= dif_next;
			if (pixel_tick='1') then
				rgb_reg <= rgb_next;
			else
				rgb_reg <= rgb_reg;
			end if;
		end if;
	end process fsmd;
	
	video_mux : process(video_on, objects_on, state, text_on, text_rgb, over) --Multiplexador de vídeo ativo
	begin
		if video_on = '0' then --Video desativado
			rgb_next <= "000";
		else --Video ativo
			if state = START_SCREEN then
				if (text_on(14) = '1' or text_on(13) = '1' or text_on(12) = '1') then --Texto da TELA DE INICIO
					rgb_next <= text_rgb;
				else	
					rgb_next <= "000";
				end if;
			elsif state = MAIN_MENU then
				if (text_on(14) = '1' or text_on(13) = '1' or text_on(11) = '1') then --Texto do MENU PRINCIPAL
					rgb_next <= text_rgb;
				else	
					rgb_next <= "000";
				end if;
			elsif state = RULES then --Texto do MENU DE REGRAS
				if (text_on(10) = '1') then
					rgb_next <= text_rgb;
				else	
					rgb_next <= "000";
				end if;
			elsif state = OPM_NAME1 then --Texto do MENU DE INTRODUCAO DO NOME J1(1 jogador)
				if (text_on(9) = '1') then
					rgb_next <= text_rgb;
				else	
					rgb_next <= "000";
				end if;
			elsif state = OPM_NAME2 then --Texto do MENU DE INTRODUCAO DO NOME J2(1 jogador)
				if (text_on(8) = '1') then
					rgb_next <= text_rgb;
				else	
					rgb_next <= "000";
				end if;
			elsif state = DIFFICULT_SELECTION then --Texto do MENU DE SELECAO DE DIFICULDADE
				if (text_on(7) = '1') then
					rgb_next <= text_rgb;
				else	
					rgb_next <= "000";
				end if;	
			elsif state = TPM_NAME1 then  --Texto do MENU DE INTRODUCAO DO NOME J1(2 jogadores)
				if (text_on(9) = '1') then
					rgb_next <= text_rgb;
				else	
					rgb_next <= "000";
				end if;
			elsif state = TPM_NAME2 then  --Texto do MENU DE INTRODUCAO DO NOME J2(2 jogadores)
				if (text_on(8) = '1') then
					rgb_next <= text_rgb;
				else	
					rgb_next <= "000";
				end if;
			elsif (state = ONE_PLAYER_MATCH or state = TWO_PLAYER_MATCH) then --PARTIDA
				if ((text_on(6) = '1' or text_on(5) = '1' or text_on(4) = '1') and over = '0') then --Texto da PARTIDA 
					rgb_next <= text_rgb;
				elsif ((text_on(5) = '1' or text_on(4) = '1' or text_on(3) = '1' or text_on(2) = '1' or text_on(1) = '1' or text_on(0) = '1') and over = '1') then --Texto de FIM DE JOGO
					rgb_next <= text_rgb;
				elsif (objects_on(3) = '1') then --Contorno da QUADRA(Branco)
					rgb_next <= "111";
				elsif (objects_on(2) = '1' or objects_on(1) = '1') then --Contorno das RAQUETES(Amarelas)
					rgb_next <= "110";
				elsif (objects_on(0) = '1') then --Contorno da BOLA(Azul)
					rgb_next <= "001";
				else
					rgb_next <= "010"; --Plano de fundo(Verde)
				end if;
			else
				rgb_next <= "000";
			end if;
		end if;	
	end process video_mux;
	
	fmsd_next_state : process(state, xkey, timer_up, dif, over) --Lógica dos estados
	begin
		case state is
			when START_SCREEN => --TELA INICIAL
				start <= '0';
				player_getname <= "00";
				text_active <= "00000";
				match_type <= "00";
				dif_next <= "00";
				if (xkey(15 downto 8) = x"5A" and xkey(7 downto 0) = x"F0") then --Pressionado tecla ENTER
					timer_start <= '1'; --Inicia temporizador de 2s
					next_state <= MAIN_MENU; --Vai para MENU PRINCIPAL
				else
					timer_start <= '0';
					next_state <= START_SCREEN;
				end if;
			WHEN MAIN_MENU => --MENU PRINCIPAL
				start <= '0';
				player_getname <= "00";
				text_active <= "00001";
				dif_next <= "00";
					if (timer_up = '1') then
						if (xkey(15 downto 8) = x"16" and xkey(7 downto 0) = x"F0") then --Pressionado tecla 1
							timer_start <= '1'; --Inicia temporizador de 2s
							match_type <= "00";
							next_state <= RULES; --Vai para MENU DE REGRAS
						elsif (xkey(15 downto 8) = x"1E" and xkey(7 downto 0) = x"F0") then --Pressionado tecla 2 
							timer_start <= '1'; --Inicia temporizador de 2s
							match_type <= "01"; --Partida para 1 jogador
							next_state <= OPM_NAME1; --Vai para MENU DE INTRODUÇÃO DE NOME J1(1 Jogador)
						elsif (xkey(15 downto 8) = x"26" and xkey(7 downto 0) = x"F0") then --Pressionado tecla 3 
							timer_start <= '1'; --Inicia temporizador de 2s
							match_type <= "10"; --Partida para 2 jogadores
							next_state <= TPM_NAME1; --Vai para MENU DE INTRODUÇÃO DE NOME J1(2 Jogadores)	
						else
							timer_start <= '0';
							match_type <= "00";
							next_state <= MAIN_MENU; --Permanece no MENU PRINCIPAL
						end if;
					else
						timer_start <= '0';
						match_type <= "00";
						next_state <= MAIN_MENU; --Permanece no MENU PRINCIPAL
					end if;
			When RULES => --MENU DE REGRAS
				start <= '0';
				player_getname <= "00";
				match_type <= "00";
				dif_next <= "00";
				text_active <= "00010";
					if (timer_up = '1') then
						if (xkey(15 downto 8) = x"66" and xkey(7 downto 0) = x"F0") then --Pressionado tecla BACKSPACE
							timer_start <= '1'; --Inicia temporizador de 2s
							next_state <= MAIN_MENU; --Vai para MENU PRINCIPAL
						else
							timer_start <= '0';
							next_state <= RULES; --Permanece no MENU DE REGRAS
						end if;
					else
						timer_start <= '0';
						next_state <= RULES; --Permanece no MENU DE REGRAS
					end if;
			When OPM_NAME1 => --MENU DE INTRODUÇÃO DE NOME J1(1 Jogador)
				start <= '0';
				match_type <= "01";
				dif_next <= "00";
				text_active <= "00011";
					if timer_up = '1' then
						player_getname <= "10"; --Pega nome do J1
						if (xkey(15 downto 8) = x"5A" and xkey(7 downto 0) = x"F0") then --Pressionado tecla ENTER
							timer_start <= '1'; --Inicia temporizador de 2s
							next_state <= OPM_NAME2; --MENU DE INTRODUÇÃO DE NOME J2(1 Jogador)
						else
							timer_start <= '0';
							next_state <= OPM_NAME1; --Permanece no MENU DE INTRODUÇÃO DE NOME J1(1 Jogador)
						end if;
					else
						player_getname <= "00";
						timer_start <= '0';
						next_state <= OPM_NAME1; --Permanece no MENU DE INTRODUÇÃO DE NOME J1(1 Jogador)
					end if;
			When OPM_NAME2 => --MENU DE INTRODUÇÃO DE NOME J2(1 Jogador)
				start <= '0';
				match_type <= "01";
				dif_next <= "00";
				text_active <= "00100";
					if timer_up = '1' then
						player_getname <= "01"; --Pega nome do J2
						if (xkey(15 downto 8) = x"5A" and xkey(7 downto 0) = x"F0") then --Pressionado tecla ENTER
							timer_start <= '0';
							next_state <= DIFFICULT_SELECTION; --Vai para MENU DE SELECAO DE DIFICULDADE
						else
							timer_start <= '0';
							next_state <= OPM_NAME2; --Permanece no MENU DE INTRODUÇÃO DE NOME J2(1 Jogador)
						end if;
					else
						player_getname <= "00";
						timer_start <= '0';
						next_state <= OPM_NAME2; --Permanece no MENU DE INTRODUÇÃO DE NOME J2(1 Jogador)
					end if;
			When DIFFICULT_SELECTION => --MENU DE SELECAO DE DIFICULDADE
				timer_start <= '0';
				player_getname <= "00";
				match_type <= "01";
				text_active <= "00101";
					if (xkey(15 downto 8) = x"16" and xkey(7 downto 0) = x"F0") then --Pressionado tecla 1
						start <= '1'; --Inicia partida
						dif_next <= "01"; --Dificuldade FACIL
						next_state <= ONE_PLAYER_MATCH; --Vai para PARTIDA DE 1 JOGADOR
					elsif (xkey(15 downto 8) = x"1E" and xkey(7 downto 0) = x"F0") then --Pressionado tecla 2
						start <= '1'; --Inicia partida
						dif_next <= "10"; --Dificuldade MEDIO
						next_state <= ONE_PLAYER_MATCH; --Vai paraPARTIDA DE 1 JOGADOR
					elsif (xkey(15 downto 8) = x"26" and xkey(7 downto 0) = x"F0") then --Pressionado tecla 3
						start <= '1'; --Inicia partida
						dif_next <= "11"; --Dificuldade DIFICIL
						next_state <= ONE_PLAYER_MATCH; --Vai para PARTIDA DE 1 JOGADOR
					else
						start <= '0';
						dif_next <= "00";
						next_state <= DIFFICULT_SELECTION; --Permanece no MENU DE SELECAO DE DIFICULDADE 
					end if;
			When TPM_NAME1 => --MENU DE INTRODUÇÃO DE NOME J1(2 Jogadores)
				start <= '0';
				match_type <= "10";
				dif_next <= "00";
				text_active <= "00011";
					if timer_up = '1' then
						player_getname <= "10"; --Pega nome do J1
						if (xkey(15 downto 8) = x"5A" and xkey(7 downto 0) = x"F0") then --Pressionado tecla ENTER
							timer_start <= '1'; --Inicia temporizador de 2s
							next_state <= TPM_NAME2; --Vai para MENU DE INTRODUÇÃO DE NOME J2(2 Jogadores)
						else
							timer_start <= '0';
							next_state <= TPM_NAME1; --Permanece no MENU DE INTRODUÇÃO DE NOME J1(2 Jogadores)
						end if;
					else
						player_getname <= "00";
						timer_start <= '0';
						next_state <= TPM_NAME1; --Permanece no MENU DE INTRODUÇÃO DE NOME J1(2 Jogadores)
					end if;
			When TPM_NAME2 => --MENU DE INTRODUÇÃO DE NOME J2(2 Jogadores)
				start <= '0';
				match_type <= "10";
				dif_next <= "00";
				text_active <= "00100";
					if timer_up = '1' then
						player_getname <= "01"; --Pega nome do J2
						if (xkey(15 downto 8) = x"5A" and xkey(7 downto 0) = x"F0") then --Pressionado tecla ENTER
							timer_start <= '0';
							next_state <= TWO_PLAYER_MATCH; --Vai para PARTIDA DE 2 JOGADORES
						else
							timer_start <= '0';
							next_state <= TPM_NAME2; --Permanece no MENU DE INTRODUÇÃO DE NOME J2(2 Jogadores)
						end if;
					else
						player_getname <= "00";
						timer_start <= '0';
						next_state <= TPM_NAME2; --Permanece no MENU DE INTRODUÇÃO DE NOME J2(2 Jogadores)
					end if;
			when ONE_PLAYER_MATCH => --PARTIDA DE 1 JOGADOR
				timer_start <= '0';
				player_getname <= "00";
				match_type <= "01";
				dif_next <= dif;
				if over = '1' then --Fim de jogo
					text_active <= "01001";
					if (xkey(15 downto 8) = x"29" and xkey(7 downto 0) = x"F0") then --Pressionado tecla SPACEBAR
						start <= '1'; --Partida ativa
						next_state <= ONE_PLAYER_MATCH; --Permanece em PARTIDA DE 1 JOGADOR
					elsif (xkey(15 downto 8) = x"66" and xkey(7 downto 0) = x"F0") then --Pressionado tecla BACKSPACE 
						start <= '0';
						next_state <= DIFFICULT_SELECTION; --Vai para MENU DE SELECAO DE DIFICULDADE 
					else
						start <= '0';
						next_state <= ONE_PLAYER_MATCH; --Permanece em PARTIDA DE 1 JOGADOR
					end if;
				else --Partida atual
					start <= '1'; --Partida ativa
					text_active <= "01000";
					next_state <= ONE_PLAYER_MATCH; --Permanece em PARTIDA DE 1 JOGADOR
				end if;
			when TWO_PLAYER_MATCH => --PARTIDA DE 2 JOGADORES
				timer_start <= '0';
				player_getname <= "00";
				match_type <= "10";
				dif_next <= "00";
				next_state <= TWO_PLAYER_MATCH; --Permanece em PARTIDA DE 2 JOGADORES
				if over = '1' then --Fim de jogo
					text_active <= "01001";
					if (xkey(15 downto 8) = x"29" and xkey(7 downto 0) = x"F0") then --Pressionado tecla SPACEBAR
						start <= '1'; --Partida ativa
					else
						start <= '0';
					end if;
				else --Partida atual
					start <= '1'; --Partida ativa
					text_active <= "01000";
				end if;	
			when others => --OUTROS 
				start <= '0';
				timer_start <= '0';
				player_getname <= "00";
				match_type <= "00";
				dif_next <= "00";
				text_active <= "00000";
				next_state <= START_SCREEN;
		end case;
	end process fmsd_next_state;
	
	pressed_key : process(xkey, state, reset_in) --Lógica da tecla pressionada
	begin
		if (state = OPM_NAME1 or state = OPM_NAME2 or state = TPM_NAME1 or state = TPM_NAME2) then --Entrar com nome dos participantes
				if (xkey(15 downto 8) /= x"00" and xkey(7 downto 0) = x"F0") then --Pressionado uma TECLA
					key <= xkey(15 downto 8) & "00000000"; --Pega scancode da tecla
					clr_next <= '1'; --Dá um clear em seguida
				else
					if (xkey(15 downto 8) = x"F0" and xkey(7 downto 0) /= x"00") then --Soltada a tecla
						key <= (others=>'1');	
						clr_next <= '1'; --Dá um clear em seguida
					elsif ((xkey(15 downto 8) = x"11" or xkey(15 downto 8) = x"12") and xkey(7 downto 0) /= x"00") then --Pressionado SHIFT+TECLA
						key <= xkey; --Pega scancode da tecla
						clr_next <= '1'; --Dá um clear em seguida
					else --Aguarda pressionar uma TECLA
						key <= (others=>'1');
						clr_next <= '0';
					end if;
				end if;
		else
			key <= (others=>'1');
			if ((xkey(15 downto 8) = x"76" and xkey(7 downto 0) = x"F0") or reset_in = '1') then --Pressionado tecla ESC
				clr_next <= '1';  --Dá um clear em seguida
			else
				clr_next <= '0';
			end if;	
		end if;
	end process pressed_key;
	
	capslock : process(clk_in, reset, xkey) --Lógica do CAPSLOCK 
	begin
		if (reset = '1') then --reset
			toggle <= '0';
			toggle_next <= '0';
		elsif (clk_in'event and clk_in = '1') then
			if (state = OPM_NAME1 or state = OPM_NAME2 or state = TPM_NAME1 or state = TPM_NAME2) then --Entrar com nome dos participantes
				if (xkey(15 downto 8) = x"F0" and xkey(7 downto 0) = x"58") then --Pressionado tecla CAPSLOCK
					toggle_next <= not toggle; --Alterna CAPSLOCK ativo
				else
					toggle <= toggle_next;
				end if;
			else
				toggle <= '0';
			end if;
		end if;	
	end process capslock;
	
end arch;

