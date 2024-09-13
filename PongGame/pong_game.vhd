--NOME DO PROJETO: PongGame - pong_game
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de jogo, responsável por controlar os objetos do jogo, os estágios do jogo, a contagem de pontos e implementação do easter egg.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity pong_game is
	port(
		clk_in, reset_in, start_in : in std_logic;
		match_type_in, dif_in: in std_logic_vector(1 downto 0);
		btn_in: in std_logic_vector(3 downto 0);
		pixel_x_in, pixel_y_in : in std_logic_vector(9 downto 0);
		over_out : out std_logic;
		match_winner_out : out std_logic_vector(1 downto 0);
		objects_on_out : out std_logic_vector(3 downto 0);
		p1_score_out, p2_score_out : out std_logic_vector(7 downto 0)
	);
end pong_game;

architecture arch of pong_game is
	type rom_type is array(0 to 7) of std_logic_vector(0 to 7); --Definicao da ROM
	constant BALL_ROM : rom_type := 
	(
	"00111100", --  ****
	"01111110", -- ******
	"11111111", --********
	"11111111", --********
	"11111111", --********
	"11111111", --********
	"01111110", -- ******
	"00111100"  --  ****
	);
	constant EASTER_EGG_ROM : rom_type := 
	(
	"01111110", -- ******
	"01011010", -- * ** * 
	"01111110", -- ******
	"10011001", --*  **  *
	"01000010", -- *    *
	"00111100", --  ****
	"01000010", -- *    *
	"10000001"  --*      *
	);
	type fsmd_states is (NEW_GAME, FIRST_DRAW , MATCH, P1_DRAFT, P2_DRAFT, P1_WON, P2_WON); --Definicao da FSMD
	signal state, next_state : fsmd_states := NEW_GAME;
	constant SCORE_U : integer := 30;
	constant SCORE_D : integer := 31;
	constant SQUARE_V1 : integer := 50;
	constant SQUARE_V2 : integer := 184;
	constant SQUARE_V3_L : integer := 318;
	constant SQUARE_V3_R : integer := 321;
	constant SQUARE_V4 : integer := 455;
	constant SQUARE_V5 : integer := 589;
	constant SQUARE_H1 : integer := 82;
	constant SQUARE_H2 : integer := 132;
	constant SQUARE_H3_U : integer := 255;
	constant SQUARE_H3_D : integer := 256;	
	constant SQUARE_H4 : integer := 379;
	constant SQUARE_H5 : integer := 429;
	constant MAX_Y : integer := 480;
	constant PD_VEL : integer := 5;
	constant PD_Y_SIZE : INTEGER := 72;
	constant PD1_X_L : INTEGER := 12;
	constant PD1_X_R : INTEGER := 15;
	constant PD2_X_L : INTEGER := 625;
	constant PD2_X_R : INTEGER := 628;
	constant BALL_SIZE : integer := 8;
	constant BALL_VP : unsigned(9 downto 0) := to_unsigned(2,10);
	constant BALL_VN : unsigned(9 downto 0) := unsigned(to_signed(-2,10));
	constant DRAFT_P1 : integer := 50;
	constant DRAFT_P2 : integer := 589;
	constant GOAL_P1 : integer := 2;
	constant GOAL_P2 : integer := 637;
	constant LINE : integer := 318;
	signal over, refr_tick, square_on, pd1_on, pd2_on, rom_bit, ball_aux, ball_on, gra_still, timer_tick, timer_start, timer_up, p1_inc, p1_clr, p2_inc, p2_clr, ee : std_logic := '0';
	signal match_winner, draft, player_draw, player_score : std_logic_vector(1 downto 0) := (others=>'0');
	signal p1_dig0, p1_dig1, p2_dig0, p2_dig1 : std_logic_vector(3 downto 0) := (others=>'0');
	signal rom_data : std_logic_vector(7 downto 0) := (others=>'0');
	signal MODIFIER : integer := 0;
	signal rom_addr, rom_col : unsigned(2 downto 0) := (others=>'0');
	signal p1_points, p1_next, p2_points, p2_next : unsigned(4 downto 0) := (others=>'0');
	signal pix_x, pix_y, pd1_y_t, pd1_y_b, pd1_y_reg, pd1_y_next, pd2_y_t, pd2_y_b, pd2_y_reg, pd2_y_next, ball_x_l, ball_x_r, ball_y_t, ball_y_b, ball_x_reg, ball_x_next, ball_y_reg, ball_y_next, x_delta_reg, x_delta_next, y_delta_reg, y_delta_next : unsigned(9 downto 0) := (others=>'0');
begin

	--Instancias
	timer_unit : entity work.pong_timer(arch) --Temporizador
		port map(clk_in=>clk_in, reset_in=>reset_in, timer_start_in=>timer_start, timer_tick_in=>timer_tick, timer_up_out=>timer_up);
	P1_counter_unit : entity work.pong_counter --Contador de pontos P1
		port map(clk_in=>clk_in, reset_in=>reset_in, d_inc_in=>p1_inc, d_clr_in=>p1_clr, dig0_out=>p1_dig0, dig1_out=>p1_dig1);
	P2_counter_unit : entity work.pong_counter --Contador de pontos P2
		port map(clk_in=>clk_in, reset_in=>reset_in, d_inc_in=>p2_inc, d_clr_in=>p2_clr, dig0_out=>p2_dig0, dig1_out=>p2_dig1);

	--Saídas
	over_out <= over;
	match_winner_out <= match_winner;
	objects_on_out <= square_on & pd1_on & pd2_on & ball_on;
	p1_score_out <= p1_dig1 & p1_dig0; 
	p2_score_out <= p2_dig1 & p2_dig0;
	
	--Atribuiçoes
	pix_x <= unsigned(pixel_x_in); --Coordenada horizontal
	pix_y <= unsigned(pixel_y_in); --Coordenada vertical
	refr_tick <= '1' when (pix_y=481) and (pix_x=0) else '0'; --tick de relógio, atualizado para o nível lógico no incio da sincronização vertical(60 Hz - 60 vezes/segundo) 
	timer_tick <= '1' when pixel_x_in="0000000000" and pixel_y_in="0000000000" else '0'; --tick de 60 Hz
	
	--pixels da quadra
	square_on <= '1' when (SCORE_U<=pix_y) and (pix_y<=SCORE_D) else
				 '1' when ((SQUARE_V1<=pix_x) and (pix_x<=SQUARE_V1)) and ((SQUARE_H1<=pix_y) and (pix_y<=SQUARE_H5)) and (SCORE_D<pix_y) else
				 '1' when ((SQUARE_V2<=pix_x) and (pix_x<=SQUARE_V2)) and ((SQUARE_H2<=pix_y) and (pix_y<=SQUARE_H4)) and (SCORE_D<pix_y) else
				 '1' when ((SQUARE_V3_L<=pix_x) and (pix_x<=SQUARE_V3_R)) and (SCORE_D<pix_y) else
				 '1' when ((SQUARE_V4<=pix_x) and (pix_x<=SQUARE_V4)) and ((SQUARE_H2<=pix_y) and (pix_y<=SQUARE_H4)) and (SCORE_D<pix_y) else
				 '1' when ((SQUARE_V5<=pix_x) and (pix_x<=SQUARE_V5)) and ((SQUARE_H1<=pix_y) and (pix_y<=SQUARE_H5)) and (SCORE_D<pix_y) else
				 '1' when ((SQUARE_H1<=pix_y) and (pix_y<=SQUARE_H1)) and ((SQUARE_V1<=pix_x) and (pix_x<=SQUARE_V5)) else
				 '1' when ((SQUARE_H2<=pix_y) and (pix_y<=SQUARE_H2)) and ((SQUARE_V1<=pix_x) and (pix_x<=SQUARE_V5)) else
				 '1' when ((SQUARE_H3_U<=pix_y) and (pix_y<=SQUARE_H3_D)) and ((SQUARE_V2<=pix_x) and (pix_x<=SQUARE_V4)) else
				 '1' when ((SQUARE_H4<=pix_y) and (pix_y<=SQUARE_H4)) and ((SQUARE_V1<=pix_x) and (pix_x<=SQUARE_V5)) else
				 '1' when ((SQUARE_H5<=pix_y) and (pix_y<=SQUARE_H5)) and ((SQUARE_V1<=pix_x) and (pix_x<=SQUARE_V5)) else
			     '0';
	
	--Raquete 1(esquerda)
	pd1_on <= '1' when (PD1_X_L<=pix_x) and (pix_x<=PD1_X_R) and (pd1_y_t<=pix_y) and (pix_y<=pd1_y_b) else '0'; --pixels ativos da raquete 1
	pd1_y_t <= pd1_y_reg + SCORE_D; --limite superior da raquete 1
	pd1_y_b <= pd1_y_t + PD_Y_SIZE - 1; --limite inferior da raquete 1
	
	--Raquete 2(direita)
	pd2_on <= '1' when (PD2_X_L<=pix_x) and (pix_x<=PD2_X_R) and (pd2_y_t<=pix_y) and (pix_y<=pd2_y_b) else '0'; --pixels ativos da raquete 2
	pd2_y_t <= pd2_y_reg + SCORE_D;  --limite superior da raquete 2
	pd2_y_b <= pd2_y_t + PD_Y_SIZE - 1; --limite inferior da raquete 2
	
	--Bola
	ball_on <= '1' when (ball_aux='1') and (rom_bit='1') else '0'; --pixels da bola(redonda)
	ball_x_l <= ball_x_reg; --limite esquerdo da bola
	ball_y_t <= ball_y_reg; --limite superior da bola
	ball_x_r <= ball_x_l + BALL_SIZE - 1;  --limite direito da bola
	ball_y_b <= ball_y_t + BALL_SIZE - 1; --limite inferior da bola
	ball_aux <= '1' when (ball_x_l<=pix_x) and (pix_x<=ball_x_r) and (ball_y_t<=pix_y) and (pix_y<=ball_y_b) else '0'; --pixels da bola(quadrada)
	--Mapeamento das coordenadas do pixel para a ROM da bola
	rom_bit <= rom_data(to_integer(rom_col)); --Bit da ROM
	rom_addr <= pix_y(2 downto 0) - ball_y_t(2 downto 0); --Linha da ROM
	rom_col <= pix_x(2 downto 0) - ball_x_l(2 downto 0); --Coluna da ROM
	--Nova posição da bola(horizontal)
	ball_x_next <= to_unsigned(DRAFT_P1,10) when (gra_still='1' and draft = "01") else --Saque J1
				   to_unsigned(DRAFT_P2,10) when (gra_still='1' and draft = "10") else --Saque J2
				   ball_x_reg + x_delta_reg when refr_tick='1' else --Nova posição horizontal
				   ball_x_reg;
	--Nova posição da bola(vertical)
	ball_y_next <= to_unsigned((MAX_Y)/2,10) when gra_still='1' else --Saque 
				   ball_y_reg + y_delta_reg when refr_tick='1' else --Nova posição vertical
				   ball_y_reg;
	
	--Processos
	registers : process(clk_in, reset_in) --Lógica dos registradores
	begin
		if reset_in='1' then --Reseta valores
			state <= NEW_GAME;
			pd1_y_reg <= (others=>'0');
			pd2_y_reg <= (others=>'0');
			ball_x_reg <= (others=>'0');
			ball_y_reg <= (others=>'0');
			x_delta_reg <= ("0000000100");
			y_delta_reg <= ("0000000100");
			p1_points <= (others=>'0');
			p2_points <= (others=>'0');
		elsif (clk_in'event and clk_in='1') then --Atualiza valores
			state <= next_state; --Registrador de estado
			pd1_y_reg <= pd1_y_next; --Registrador da posição vertical da raquete 1(Esquerda)
			pd2_y_reg <= pd2_y_next; --Registrador da posição vertical da raquete 2(Direita)
			ball_x_reg <= ball_x_next; --Registrador da posição horizontal da bola
			ball_y_reg <= ball_y_next; --Registrador da posição vertical da bola
			x_delta_reg <= x_delta_next; --Registrador da velocidade horizontal da bola
			y_delta_reg <= y_delta_next; --Registrador da velocidade vertical da bola
			p1_points <= p1_next; --Contador de pontos do J1
			p2_points <= p2_next; --Contador de pontos do J2
		end if;
	end process registers;
	
	fmsd_next_state : process(player_score, timer_up, state, p1_points, p2_points, start_in) --Lógica dos estados
	begin
		case state is
			when NEW_GAME => --NOVO JOGO
				gra_still <= '1'; --Gráfico estático
				over <= '0';
				p1_next <= "00000";
				p2_next <= "00000";	
				draft <= "01"; --Saque na area 1
				p1_inc <= '0';
				p2_inc <= '0';
				p1_clr <= '1'; --Limpar placar do J1
				p2_clr <= '1'; --Limpar placar do J2
				p1_next <= p1_points;
				p2_next <= p2_points;
				player_draw <= "00";
				match_winner <= "00";
				if start_in = '1' then --Inicia novo jogo
					timer_start <= '1'; --Inicia intervalo de 2s
					next_state <= FIRST_DRAW; --Vai para PRIMEIRO SAQUE 
				else
					timer_start <= '0'; 
					next_state <= NEW_GAME; --Permanece em NOVO JOGO
				end if;
			when FIRST_DRAW => --PRIMEIRO SAQUE(Dado sempre pelo J1)
				gra_still <= '1'; --Gráfico estático
				over <= '0';
				p1_inc <= '0';
				p2_inc <= '0';
				p1_clr <= '0';
				p2_clr <= '0';
				timer_start <= '0';
				p1_next <= p1_points;
				p2_next <= p2_points;
				draft <= "01"; --Saque na area 1
				match_winner <= "00";
				if timer_up = '1' then --Dá o primeiro saque depois de 2s
					player_draw <= "10"; --J1 saca
					next_state <= MATCH; --Vai para PARTIDA 
				else 
					player_draw <= "00";
					next_state <= FIRST_DRAW; --Permanece em PRIMEIRO SAQUE
				end if;	
			when MATCH => --PARTIDA
				over <= '0';
				gra_still <= '0'; --Gráfico animado 
				p1_clr <= '0';
				p2_clr <= '0';
				draft <= "00";
				player_draw <= "00";
				match_winner <= "00";
					if player_score = "10" then --J1 marca ponto
						p1_inc <= '1'; --Incrementa pontos do J1
						p2_inc <= '0'; 
						timer_start <= '1'; --Inicia intervalo de 2s 
						p1_next <= p1_points + 1; --Incrementa contador de pontos do J1
						p2_next <= p2_points;
						next_state <= P1_DRAFT; --Vai para SAQUE J1 
					elsif player_score = "01" then --J2 marca ponto
						p2_inc <= '1'; --Incrementa pontos do J2
						p1_inc <= '0';	
						timer_start <= '1'; --Inicia intervalo de 2s 
						p2_next <= p2_points + 1; --Incrementa contador de pontos do J2
						p1_next <= p1_points;
						next_state <= P2_DRAFT; --Vai para SAQUE J2 
					else
						p1_inc <= '0';
						p2_inc <= '0';
						timer_start <= '0';
						p1_next <= p1_points;
						p2_next <= p2_points;
						next_state <= MATCH; --Permanece em PARTIDA
					end if;
			when P1_DRAFT => --SAQUE J1
				gra_still <= '1'; --Gráfico estático
				over <= '0';
				timer_start <= '0';
				p1_inc <= '0';
				p2_inc <= '0';
				p1_clr <= '0';
				p2_clr <= '0';
				p1_next <= p1_points;
				p2_next <= p2_points;
				draft <= "01"; --Saque na area 1
				match_winner <= "00";
				if (p1_points = 20) then --J1 marcou 20 pontos
					player_draw <= "00";
					next_state <= P1_WON; --Vai para J1 VENCE 
				else
					if timer_up='1' then
						player_draw <= "10"; --J1 saca apos marcar
						next_state <= MATCH; --Vai para PARTIDA
					else
						player_draw <= "00";
						next_state <= P1_DRAFT; --Permanece em SAQUE J1
					end if;
				end if;
			when P2_DRAFT => --SAQUE J2
				gra_still <= '1'; --Gráfico estático
				over <= '0';
				timer_start <= '0';
				p1_inc <= '0';
				p2_inc <= '0';
				p1_clr <= '0';
				p2_clr <= '0';
				p1_next <= p1_points;
				p2_next <= p2_points;
				draft <= "10"; --Saque na area 2
				match_winner <= "00";
				if (p2_points = 20) then --J2 marcou 20 pontos
					player_draw <= "00";
					next_state <= P2_WON; --Vai para J2 VENCE 
				else
					if timer_up='1' then
						player_draw <= "01"; --J2 saca apos marcar
						next_state <= MATCH; --Vai para PARTIDA
					else
						player_draw <= "00";
						next_state <= P2_DRAFT; --Permanece em SAQUE J2	
					end if;
				end if;	
			when P1_WON => --J1 VENCE 
				gra_still <= '1'; --Gráfico estático
				over <= '1'; --Encerra o jogo
				timer_start <= '0';
				p1_inc <= '0';
				p2_inc <= '0';
				p1_clr <= '0';
				p2_clr <= '0';
				p1_next <= p1_points;
				p2_next <= p2_points;
				match_winner <= "01"; --J1 venceu a partida
				draft <= "00";
				player_draw <= "00";
				if timer_up='1' and start_in = '1' then --Inicia novo jogo
					next_state <= NEW_GAME; --Vai para NOVO JOGO 
				else
					next_state <= P1_WON; --Permanece em J1 VENCE
				end if;
			when P2_WON => --J2 VENCE 
				gra_still <= '1'; --Gráfico estático
				over <= '1'; --Encerra o jogo
				timer_start <= '0';
				p1_inc <= '0';
				p2_inc <= '0';
				p1_clr <= '0';
				p2_clr <= '0';
				p1_next <= p1_points;
				p2_next <= p2_points;
				match_winner <= "10"; --J2 venceu a partida
				draft <= "00";
				player_draw <= "00";
				if timer_up='1' and start_in = '1' then --Inicia novo jogo
					next_state <= NEW_GAME; --Vai para NOVO JOGO
				else
					next_state <= P2_WON; --Permanece em J2 VENCE
				end if;
			when others=>
				gra_still <= '1'; --Gráfico estático]
				over <= '0';
				timer_start <= '0';
				p1_inc <= '0';
				p2_inc <= '0';
				p1_clr <= '0';
				p2_clr <= '0';
				match_winner <= "00";
				draft <= "00";
				player_draw <= "00";
				p1_next <= p1_points;
				p2_next <= p2_points;
				next_state <= state;
		end case;	
	end process fmsd_next_state;
	
	paddle_01 : process(pd1_y_reg, pd1_y_b, pd1_y_t, refr_tick, btn_in) --Lógica de movimento da raquete 1(esquerda)
	begin
		if refr_tick = '1' then --Tick de 60Hz
			if btn_in(2)='1' and pd1_y_b<(MAX_Y-1-PD_VEL) then --btn2 pressionado
				pd1_y_next <= pd1_y_reg + PD_VEL; --Mover p/ baixo
			elsif btn_in(3)='1' and (pd1_y_t > PD_VEL + SCORE_D) then --btn3 pressionado
				pd1_y_next <= pd1_y_reg - PD_VEL; --Mover p/ cima
			else
				pd1_y_next <= pd1_y_reg; --Sem movimento
			end if;
		else
			pd1_y_next <= pd1_y_reg; --Sem movimento
		end if;
	end process paddle_01;
	
	paddle_02 : process(pd2_y_reg, pd2_y_b, pd2_y_t, refr_tick, btn_in, match_type_in, y_delta_reg, ball_y_t, ball_y_b, ball_y_reg, ball_x_l, MODIFIER) --Lógica de movimento da raquete 2(direita)
	begin
		if refr_tick = '1' then --Tick de 60Hz
			if (match_type_in = "01") then --IA
				if (ball_y_t > pd2_y_b) and (pd2_y_b < (MAX_Y - 1 - PD_VEL)) and (ball_x_l > LINE) then --Bola abaixo do limite inferior da raquete e dentro da area 2
					pd2_y_next <= pd2_y_reg + (PD_VEL - MODIFIER); --Mover p/ baixo
				elsif (ball_y_b < pd2_y_t) and (pd2_y_t > (PD_VEL + SCORE_D)) and (ball_x_l > LINE) then --Bola acima do limite superior da raquete e dentro da area 2
					pd2_y_next <= pd2_y_reg - (PD_VEL + MODIFIER); --Mover p/ cima
				else
					pd2_y_next <= pd2_y_reg; --Sem movimento	
				end if;
			else --J2
				if btn_in(0)='1' and pd2_y_b<(MAX_Y-1-PD_VEL) then --btn0 pressionado
					pd2_y_next <= pd2_y_reg + PD_VEL; --Mover p/ baixo
				elsif btn_in(1)='1' and (pd2_y_t > PD_VEL + SCORE_D) then --btn1 pressionado
					pd2_y_next <= pd2_y_reg - PD_VEL; --Mover p/ cima
				else
					pd2_y_next <= pd2_y_reg; --Sem movimento
				end if;
			end if;
		else
			pd2_y_next <= pd2_y_reg; --Sem movimento
		end if;
	end process paddle_02;
	
	difficult_level : process(dif_in) --Lógica da dificuldade
	begin
		if dif_in = "01" then --Dificuldade FACIL
			MODIFIER <= 3;
		elsif dif_in = "10" then --Dificuldade MÉDIO
			MODIFIER <= 2;
		else  --Dificuldade DIFICIL
			MODIFIER <= 1;
		end if;
	end process difficult_level;
	
	ball : process(x_delta_reg, y_delta_reg, ball_y_t, ball_x_l, ball_x_r, ball_y_t, ball_y_b, pd1_y_t, pd2_y_t, pd1_y_b, pd2_y_b, gra_still, player_draw) --Lógica de velocidade da bola
	begin
		if gra_still = '1' then --Velocidade inicial
			if player_draw = "10" then --J1 saca
				x_delta_next <= BALL_VP; --Velocidade positiva(Direita->Esquerda)
				y_delta_next <= y_delta_reg;
			elsif player_draw = "01" then --J2 saca
				x_delta_next <= BALL_VN; --Velocidade negativa(Esquerda->Direita)
				y_delta_next <= y_delta_reg;
			else
				x_delta_next <= x_delta_reg;
				y_delta_next <= y_delta_reg;
			end if;
		else
			if ball_y_t < SCORE_D then --Alcancou LS
				x_delta_next <= x_delta_reg;
				y_delta_next <= BALL_VP; --Rebate em velocidade positiva(Cima->Baixo)
			elsif ball_y_b > (MAX_Y-1) then --Alcancou LI
				x_delta_next <= x_delta_reg;
				y_delta_next <= BALL_VN; --Rebate em velocidade negativa(Baixo->Cima)
			elsif ((ball_x_l<=PD1_X_R) and (ball_x_l>PD1_X_L)) and ((pd1_y_t<=ball_y_b) and (ball_y_t<=pd1_y_b)) then --Bateu na raq1
				x_delta_next <= BALL_VP; --Rebate em velocidade positiva(Direita->Esquerda)
				y_delta_next <= y_delta_reg;	
			elsif ((PD2_X_L<=ball_x_r) and (ball_x_r<=PD2_X_R)) and ((pd2_y_t<=ball_y_b) and (ball_y_t<=pd2_y_b)) then --Bateu na raq2
				x_delta_next <= BALL_VN; --Rebate em velocidade negativa(Esquerda->Direita)
				y_delta_next <= y_delta_reg;
			else
				x_delta_next <= x_delta_reg;
				y_delta_next <= y_delta_reg;
			end if;
		end if;
	end process ball;
	
	p_score : process(gra_still, ball_x_l, ball_x_r) --Lógica da marcação de pontos
	begin
		if gra_still = '0' then
			if (ball_x_l < GOAL_P1) then --Bola atravessa area 1
				player_score <= "01"; --J2 marca um ponto
			elsif (ball_x_r > GOAL_P2) then --Bola atravessa area 2
				player_score <= "10"; --J1 marca um ponto
			else
				player_score <= "00";
			end if;	
		else
			player_score <= "00";
		end if;
	end process p_score;	
	
	easter_egg : process(p1_points, p2_points) --Lógica do easter egg
	begin	
		if (p1_points = 13 and p2_points = 13) then --Placar 13:13 
			ee <= '1'; --Easter_egg ativo
		else
			ee <= '0';
		end if;
	end process;
	
	rom : process(ee) --Lógica da ROM da bola
	begin
		if ee = '1' then
			rom_data <= EASTER_EGG_ROM(to_integer(rom_addr)); --ROM do easter_egg
		else
			rom_data <= BALL_ROM(to_integer(rom_addr)); --ROM da bola
		end if;
	end process rom;
	
end arch;

