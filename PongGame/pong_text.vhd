--NOME DO PROJETO: PongGame - pong_text
--AUTOR: Leonardo Severino - leoseverino0901@gmail.com
--DATA: 30/10/2023 - 17:21:26
--DESCRIÇÃO:
--	Unidade de texto, responsável por exibir os textos do jogo.

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity pong_text is
	port(
		clk_in, reset_in : in std_logic;
		match_winner_in, match_type_in, player_getname_in : in std_logic_vector(1 downto 0);
		text_active_in : in std_logic_vector(4 downto 0);
		digit_in : in std_logic_vector(6 downto 0);
		p1_score_in, p2_score_in : in std_logic_vector(7 downto 0);
		pixel_x_in, pixel_y_in : in std_logic_vector(9 downto 0);
		text_rgb_out : out std_logic_vector(2 downto 0);
		text_on_out : out std_logic_vector(14 downto 0)
	);
end pong_text;

architecture arch of pong_text is
	type name is array(0 to 9) of std_logic_vector(6 downto 0);
	signal name1, name2 : name := 
	(
    "0000000",
	 "0000000",
	 "0000000",	
	 "0000000",	
	 "0000000",	
	 "0000000",	
	 "0000000",	
	 "0000000",
	 "0000000",
	"0000000"	 
	);
	constant SCORE_L : integer := 212;
	constant SCORE_R : integer := 427;
	constant SCORE_D : integer := 30;
	constant DIF_U : integer := 250;
	constant DIF_D : integer := 320;
	constant P1_NAME_L : integer := 0;
	constant P1_NAME_R : integer := 211;
	constant P2_NAME_L : integer := 428;
	constant P2_NAME_R : integer := 639;
	signal score_on, logo_on, logo1_on, sc_on, mm_on, rule_on, over_on, over_on2, over_on3, p1_name_on, p2_name_on, winner_on, name1_on, name2_on, dif_on, font_bit : std_logic := '0';
	signal bit_addr, bit_addr_s, bit_addr_p1, bit_addr_p2, bit_addr_l, bit_addr_l1, bit_addr_sc, bit_addr_mm, bit_addr_r, bit_addr_o, bit_addr_o2, bit_addr_o3, bit_addr_w, bit_addr_name1, bit_addr_name2, bit_addr_dif, text_rgb : std_logic_vector(2 downto 0) := (others=>'0');
	signal row_addr, row_addr_s, row_addr_p1, row_addr_p2, row_addr_l, row_addr_l1, row_addr_sc, row_addr_mm, row_addr_r, row_addr_o, row_addr_o2, row_addr_o3, row_addr_w, row_addr_name1, row_addr_name2, row_addr_dif : std_logic_vector(3 downto 0) := (others=>'0');
	signal char_addr, char_addr_s, char_addr_p1, char_addr_p2, char_addr_l, char_addr_l1, char_addr_sc, char_addr_mm, char_addr_r, char_addr_o, char_addr_o2, char_addr_o3,char_addr_w, char_addr_name1, char_addr_name2, char_addr_dif, dig, dig1, dig2, dig3 : std_logic_vector(6 downto 0) := (others=>'0');
	signal font_word : std_logic_vector(7 downto 0) := (others=>'0');
	signal rom_addr : std_logic_vector(10 downto 0) := (others=>'0');
	signal cont1, cont1_next, cont2, cont2_next : integer := 0;
	signal pix_x, pix_y : unsigned(9 downto 0) := (others=>'0');
begin

	--Instancias
	font_unit : entity work.pong_font
		port map(clk_in=>clk_in, addr_in=>rom_addr, data_out=>font_word);
	
	--Saídas
	text_rgb_out <= text_rgb; --Cor do texto ativo
	text_on_out <= logo_on & logo1_on & sc_on & mm_on & rule_on & name1_on & name2_on & dif_on & score_on & p1_name_on & p2_name_on & winner_on & over_on & over_on2 & over_on3; --Texto ativo
	
	--Atribuicoes
	pix_x <= unsigned(pixel_x_in); --Coordenada horizontal do pixel
	pix_y <= unsigned(pixel_y_in); --Coordenada vertical do pixel
	rom_addr <= char_addr & row_addr; --Interface com font rom
	font_bit <= font_word(to_integer(unsigned(not bit_addr)));
	
	--LOGO
	--PONG
	logo_on <= '1' when ((3<=pix_x(9 downto 6) and pix_x(9 downto 6)<=6) and (pix_y(9 downto 5) <= "00010")) and (text_active_in = "00000" or text_active_in = "00001") else '0'; --Pixels do texto do LOGO
	row_addr_l <= std_logic_vector(pix_y(6 downto 3)); 
	bit_addr_l <= std_logic_vector(pix_x(5 downto 3)); 
	with (pix_x(8 downto 6)) select
	char_addr_l  <= 
			"1010000" when "011", -- P 
			"1001111" when "100", -- 0  
			"1001110" when "101", -- N 
			"1000111" when "110", --G
			"0000000" when others;
	--By Leo
	logo1_on  <= '1' when (3<=pix_x(9 downto 6) and pix_x(9 downto 6)<=6) and (pix_y(9 downto 5) = "00011") and (text_active_in = "00000" or text_active_in = "00001") else '0';  --Pixels do texto do LOGO
	row_addr_l1 <= std_logic_vector(pix_y(4 downto 1)); 
	bit_addr_l1 <= std_logic_vector(pix_x(3 downto 1));
	with pix_x(9 downto 4) select
		char_addr_l1  <=
			"1000010" when "001100", --B
			"1011001" when "001101", --Y
			
			"1001100" when "001111", --L
			"1000101" when "010000", --E
			"1001111" when "010001", --O
			"0000000" when others;
			
	--TELA INICIAL		
	--Aperte (ENTER) para iniciar
	sc_on  <= '1'  when (pix_x(9 downto 4)<="100000" and "000110"<=pix_x(9 downto 4)) and (pix_y(9 downto 5) >= "01010") and (text_active_in = "00000") else '0'; --Pixels do texto da TELA INICIAL 
	row_addr_sc <= std_logic_vector(pix_y(4 downto 1)); 
	bit_addr_sc <= std_logic_vector(pix_x(3 downto 1));
	with (pix_y(9 downto 5) & pix_x(9 downto 4)) select
		char_addr_sc  <=
			--LINHA 10
			"1000001" when "01010000110", --A
			"1010000" when "01010000111", --P
			"1000101" when "01010001000", --E
			"1010010" when "01010001001", --R
			"1010100" when "01010001010", --T
			"1000101" when "01010001011", --E 
			
			"1011011" when "01010001101", --(
			"1000101" when "01010001110", --E
			"1001110" when "01010001111", --N
			"1010100" when "01010010000", --T
			"1000101" when "01010010001", --E
			"1010010" when "01010010010", --R
			"1011101" when "01010010011", --)
			
			"1010000" when "01010010101", --P
			"1000001" when "01010010110", --A
			"1010010" when "01010010111", --R
			"1000001" when "01010011000", --A
			
			"1001001" when "01010011010", --I
			"1001110" when "01010011011", --N
			"1001001" when "01010011100", --I
			"1000011" when "01010011101", --C
			"1001001" when "01010011110", --I
			"1000001" when "01010011111", --A
			"1010010" when "01010100000", --R
			"0000000" when others;
	
	--MENU PRINCIPAL
	mm_on <= '1' when (pix_y(9 downto 5) > "00011") and (text_active_in = "00001") else '0'; --Pixels do texto do MENU PRINCIPAL 
	row_addr_mm <= std_logic_vector(pix_y(4 downto 1));
	bit_addr_mm <= std_logic_vector(pix_x(3 downto 1));
	with (pix_y(9 downto 5) & pix_x(9 downto 4)) select
		char_addr_mm <= 	
			--LINHA 8
			"0111100" when "01000001100",--<
			"0110001" when "01000001101",--1
			"0111110" when "01000001110",-->
			"1000011" when "01000001111",--C
			"1001111" when "01000010000",--O
			"1001101" when "01000010001",--M
			"1001111" when "01000010010",--O

			"1001010" when "01000010100",--J
			"1001111" when "01000010101",--O
			"1000111" when "01000010110",--G
			"1000001" when "01000010111",--A
			"1010010" when "01000011000",--R
			--LINHA 9
			"0111100" when "01001001100",--<
			"0110010" when "01001001101",--2
			"0111110" when "01001001110",-->
			"0110001" when "01001001111",--1

			"1001010" when "01001010001",--J
			"1001111" when "01001010010",--O
			"1000111" when "01001010011",--G
			"1000001" when "01001010100",--A
			"1000100" when "01001010101",--D
			"1001111" when "01001010110",--O
			"1010010" when "01001010111",--R
			--LINHA 10
			"0111100" when "01010001100",--<
			"0110011" when "01010001101",--3
			"0111110" when "01010001110",-->
			"0110010" when "01010001111",--2

			"1001010" when "01010010001",--J
			"1001111" when "01010010010",--O
			"1000111" when "01010010011",--G
			"1000001" when "01010010100",--A
			"1000100" when "01010010101",--D
			"1001111" when "01010010110",--O
			"1010010" when "01010010111",--R
			"1000101" when "01010011000",--E
			"1010011" when "01010011001",--S
			--LINHA15
			"0111100" when "01110000000",--[
			"0110001" when "01110000001",--1
			"0111110" when "01110000010",--]
			"1001111" when "01110000011",--O
			"1110000" when "01110000100",--p
			"1100011" when "01110000101",--c
			"1100001" when "01110000110",--a
			"1101111" when "01110000111",--o
			"0110001" when "01110001000",--1

			"0111100" when "01110001010",--[
			"0110010" when "01110001011",--2
			"0111110" when "01110001100",--]
			"1001111" when "01110001101",--O
			"1110000" when "01110001110",--p
			"1100011" when "01110001111",--c
			"1100001" when "01110010000",--a
			"1101111" when "01110010001",--o
			"0110010" when "01110010010",--2

			"0111100" when "01110010100",--[
			"0110011" when "01110010101",--3
			"0111110" when "01110010110",--]
			"1001111" when "01110010111",--O
			"1110000" when "01110011000",--p
			"1100011" when "01110011001",--c
			"1100001" when "01110011010",--a
			"1101111" when "01110011011",--o
			"0110011" when "01110011100",--3
			"0000000" when others;
			
	--MENU DE REGRAS
	rule_on <= '1' when text_active_in = "00010" else '0'; --Pixels do texto do MENU DE REGRAS
	row_addr_r <= std_logic_vector(pix_y(4 downto 1));
	bit_addr_r <= std_logic_vector(pix_x(3 downto 1));
	with (pix_y(9 downto 5) & pix_x(9 downto 4)) select
		char_addr_r <= 	--LINHA 1
						"1010010" when "00000000000", --R
								"1000101" when "00000000001", --E
								"1000111" when "00000000010", --G
								"1010010" when "00000000011", --R
								"1000001" when "00000000100", --A
								"1010011" when "00000000101", --S
								"1111100" when "00000000110", --:
								"1000011" when "00000000111", --C
								"1100001" when "00000001000", --a
								"1100100" when "00000001001", --d
								"1100001" when "00000001010", --a

								"1000011" when "00000001100", --C
								"1101111" when "00000001101", --o
								"1101101" when "00000001110", --m
								"1110000" when "00000001111", --p
								"1100101" when "00000010000", --e
								"1110100" when "00000010001", --t
								"1101001" when "00000010010", --i
								"1100100" when "00000010011", --d
								"1101111" when "00000010100", --o
								"1110010" when "00000010101", --r

								"1000011" when "00000010111", --C
								"1101111" when "00000011000", --o
								"1101110" when "00000011001", --n
								"1110100" when "00000011010", --t
								"1110010" when "00000011011", --r
								"1101111" when "00000011100", --o
								"1101100" when "00000011101", --l
								"1100001" when "00000011110", --a

								"1110101" when "00000100000", --u
								"1101101" when "00000100001", --m
								"1100001" when "00000100010", --a

								"1010010" when "00000100100", --R
								"1100001" when "00000100101", --a
								"1110001" when "00000100110", --q
								"1110101" when "00000100111", --u
								--LINHA 2
								"1100101" when "00001000000",--e	
								"1110100" when "00001000001",--t
								"1100101" when "00001000010",--e
								"0111100" when "00001000011",--(
								"1000010" when "00001000100",--B
								"1100001" when "00001000101",--a 
								"1110010" when "00001000110",--r
								"1110010" when "00001000111",--r
								"1100001" when "00001001000",--a

								"1010110" when "00001001010",--V
								"1100101" when "00001001011",--e
								"1110010" when "00001001100",--r
								"1110100" when "00001001101",--t
								"1101001" when "00001001110",--i
								"1100011" when "00001001111",--c
								"1100001" when "00001010000",--a
								"1101100" when "00001010001",--l
								"0111110" when "00001010010",--)

								"1100101" when "00001010100",--e

								"1100100" when "00001010110",--d
								"1100101" when "00001010111",--e
								"1110110" when "00001011000",--v
								"1100101" when "00001011001",--e

								"1010101" when "00001011011",--U
								"1110011" when "00001011100",--s
								"1100001" when "00001011101",--a
								"0101101" when "00001011110",-- -
								"1101100" when "00001011111",--l
								"1100001" when "00001100000",--a

								"1110000" when "00001100010",--p
								"1100001" when "00001100011",--a
								"1110010" when "00001100100",--r
								"1100001" when "00001100101",--a

								"1010010" when "00001100111",--R
								
								--LINHA 3
								"1100101" when "00010000000",--e
								"1100010" when "00010000001",--b
								"1100001" when "00010000010",--a
								"1110100" when "00010000011",--t
								"1100101" when "00010000100",--e
								"1110010" when "00010000101",--r
				
								"1100001" when "00010000111",--a
								
								"1000010" when "00010001001",--B
								"1101111" when "00010001010",--o
								"1101100" when "00010001011",--l
								"1100001" when "00010001100",--a
								"0111100" when "00010001101",--(
								"1000101" when "00010001110",--E
								"1110011" when "00010001111",--s
								"1100110" when "00010010000",--f
								"1100101" when "00010010001",--e
								"1110010" when "00010010010",--r
								"1100001" when "00010010011",--a
								"0111110" when "00010010100",--)
								
								"1000011" when "00010010110",--C
								"1101111" when "00010010111",--o
								"1101110" when "00010011000",--n
								"1110100" when "00010011001",--t
								"1110010" when "00010011010",--r
								"1100001" when "00010011011",--a
								
								"1100001" when "00010011101",--a
								
								"1000001" when "00010011111",--A
								"1110010" when "00010100000",--r
								"1100101" when "00010100001",--e
								"1100001" when "00010100010",--a
								
								"1100100" when "00010100100",--d
								"1101111" when "00010100101",--o
								
								"1001111" when "00010100111",--O
								--LINHA 4
								"1110000" when "00011000000",--p
								"1101111" when "00011000001",--o
								"1101110" when "00011000010",--n
								"1100101" when "00011000011",--e
								"1101110" when "00011000100",--n
								"1110100" when "00011000101",--t
								"1100101" when "00011000110",--e
								
								"1110000" when "00011001000",--p
								"1100001" when "00011001001",--a
								"1110010" when "00011001010",--r
								"1100001" when "00011001011",--a
								
								"1001101" when "00011001101",--M
								"1100001" when "00011001110",--a
								"1110010" when "00011001111",--r
								"1100011" when "00011010000",--c
								"1100001" when "00011010001",--a
								"1110010" when "00011010010",--r
								
								"1110101" when "00011010100",--u
								"1101101" when "00011010101",--m
								
								"1010000" when "00011010111",--P
								"1101111" when "00011011000",--o
								"1101110" when "00011011001",--n
								"1110100" when "00011011010",--t
								"1101111" when "00011011011",--o
								"0101110" when "00011011100",--.
								"1010110" when "00011011101",--V
								"1100101" when "00011011110",--e
								"1101110" when "00011011111",--n
								"1100011" when "00011100000",--c
								"1100101" when "00011100001",--e
								
								"1101111" when "00011100011",--o
								
								"1010000" when "00011100101",--P
								"1110010" when "00011100110",--r
								"1101001" when "00011100111",--i
								--LINHA 5
								"1101101" when "00100000000",--m
								"1100101" when "00100000001",--e
								"1101001" when "00100000010",--i
								"1110010" when "00100000011",--r
								"1101111" when "00100000100",--o
								
								"1100001" when "00100000110",--a
								
								"1000001" when "00100001000",--A
								"1110100" when "00100001001",--t
								"1101001" when "00100001010",--i
								"1101110" when "00100001011",--n
								"1100111" when "00100001100",--g
								"1101001" when "00100001101",--i
								"1110010" when "00100001110",--r
								
								"0110010" when "00100010000",--2
								"0110000" when "00100010001",--0
								
								"1010000" when "00100010011",--P
								"1101111" when "00100010100",--o
								"1101110" when "00100010101",--n
								"1110100" when "00100010110",--t
								"1101111" when "00100010111",--o
								"1110011" when "00100011000",--s
								"0101110" when "00100011001",--.
								"1000001" when "00100011010",--A
								"1110101" when "00100011011",--u
								"1110100" when "00100011100",--t
								"1101111" when "00100011101",--o

								"1010011" when "00100011111",--S
								"1100001" when "00100100000",--a
								"1110001" when "00100100001",--q
								"1110101" when "00100100010",--u
								"1100101" when "00100100011",--e
								"0101110" when "00100100100",--.
								--LINHA 6
								"1001101" when "00101000000",--M
								"1001111" when "00101000001",--O
								"1000100" when "00101000010",--D
								"1001111" when "00101000011",--O
								"1010011" when "00101000100",--S

								"1000100" when "00101000110",--D
								"1000101" when "00101000111",--E

								"1001010" when "00101001001",--J
								"1001111" when "00101001010",--O
								"1000111" when "00101001011",--G
								"1001111" when "00101001100",--O
								"1111100" when "00101001101",--:
								--LINHA 7
								"0110001" when "00110000000",--1
								"1001010" when "00110000001",--J
								"1101111" when "00110000010",--o
								"1100111" when "00110000011",--g
								"1100001" when "00110000100",--a
								"1100100" when "00110000101",--d
								"1101111" when "00110000110",--o
								"1110010" when "00110000111",--r
								"0101101" when "00110001000",-- -
								"1001010" when "00110001001",--J
								"0110001" when "00110001010",--1
								"0111100" when "00110001011",--(
								"1000001" when "00110001100",--A
								"1110010" when "00110001101",--r
								"1100101" when "00110001110",--e
								"1100001" when "00110001111",--a

								"1000101" when "00110010001",--E
								"1110011" when "00110010010",--s
								"1110001" when "00110010011",--q
								"0101110" when "00110010100",--.
								"0111110" when "00110010101",--)
								"1111000" when "00110010110",--x
								"1001001" when "00110010111",--I
								"1000001" when "00110011000",--A
								"0111100" when "00110011001",--(
								"1000001" when "00110011010",--A
								"1110010" when "00110011011",--r
								"1100101" when "00110011100",--e
								"1100001" when "00110011101",--a

								"1000100" when "00110011111",--D
								"1101001" when "00110100000",--i
								"1110010" when "00110100001",--r
								"0101110" when "00110100010",--.
								"0111110" when "00110100011",--)
								--LINHA 8
								"0110010" when "00111000000",--2
								"1001010" when "00111000001",--J
								"1101111" when "00111000010",--o
								"1100111" when "00111000011",--g
								"1100001" when "00111000100",--a
								"1100100" when "00111000101",--d
								"1101111" when "00111000110",--o
								"1110010" when "00111000111",--r
								"1100101" when "00111001000",--e
								"1110011" when "00111001001",--s
								"0101101" when "00111001010",-- - 
								"1001010" when "00111001011",--J
								"0110001" when "00111001100",--1
								"0111100" when "00111001101",--(
								"1000001" when "00111001110",--A
								"1110010" when "00111001111",--r
								"1100101" when "00111010000",--e
								"1100001" when "00111010001",--a

								"1000101" when "00111010011",--E
								"1110011" when "00111010100",--s
								"1110001" when "00111010101",--q
								"0101110" when "00111010110",--.
								"0111110" when "00111010111",--)
								"1111000" when "00111011000",--x
								"1001010" when "00111011001",--J
								"0110010" when "00111011010",--2
								"0111100" when "00111011011",--(
								"1000001" when "00111011100",--A
								"1110010" when "00111011101",--r
								"1100101" when "00111011110",--e
								"1100001" when "00111011111",--a

								"1000100" when "00111100001",--D
								"1101001" when "00111100010",--i
								"1110010" when "00111100011",--r
								"0101110" when "00111100100",--.
								"0111110" when "00111100101",--)
								--LINHA 9
								"1000011" when "01000000000",--C
								"1001111" when "01000000001",--O
								"1001110" when "01000000010",--N
								"1010100" when "01000000011",--T
								"1010010" when "01000000100",--R
								"1001111" when "01000000101",--O
								"1001100" when "01000000110",--L
								"1000101" when "01000000111",--E
								"1010011" when "01000001000",--S
								"1111100" when "01000001001",--:
								--LINHA 10
								"1001010" when "01001000000",--J
								"0110001" when "01001000001",--1
								"0101101" when "01001000010",-- - 
								"0111100" when "01001000011",--(
								"1000010" when "01001000100",--B
								"1010100" when "01001000101",--T
								"1001110" when "01001000110",--N
								"0110011" when "01001000111",--3
								"0111110" when "01001001000",--)
								"1001101" when "01001001001",--M
								"1101111" when "01001001010",--o
								"1110110" when "01001001011",--v
								"1100101" when "01001001100",--e
								"1110010" when "01001001101",--r

								"1010010" when "01001001111",--R
								"1100001" when "01001010000",--a
								"1110001" when "01001010001",--q
								"1110101" when "01001010010",--u
								"1100101" when "01001010011",--e
								"1110100" when "01001010100",--t
								"1100101" when "01001010101",--e

								"1110000" when "01001010111",--p
								"1100001" when "01001011000",--a
								"1110010" when "01001011001",--r
								"1100001" when "01001011010",--a

								"1000011" when "01001011100",--C
								"1101001" when "01001011101",--i
								"1101101" when "01001011110",--m
								"1100001" when "01001011111",--a
								--LINHA 11
								"0111100" when "01010000011",--(
								"1000010" when "01010000100",--B
								"1010100" when "01010000101",--T
								"1001110" when "01010000110",--N
								"0110010" when "01010000111",--2
								"0111110" when "01010001000",--)
								"1001101" when "01010001001",--M
								"1101111" when "01010001010",--o
								"1110110" when "01010001011",--v
								"1100101" when "01010001100",--e
								"1110010" when "01010001101",--r

								"1010010" when "01010001111",--R
								"1100001" when "01010010000",--a
								"1110001" when "01010010001",--q
								"1110101" when "01010010010",--u
								"1100101" when "01010010011",--e
								"1110100" when "01010010100",--t
								"1100101" when "01010010101",--e

								"1110000" when "01010010111",--p
								"1100001" when "01010011000",--a
								"1110010" when "01010011001",--r
								"1100001" when "01010011010",--a

								"1000010" when "01010011100",--B
								"1100001" when "01010011101",--a
								"1101001" when "01010011110",--i
								"1111000" when "01010011111",--x
								"1101111" when "01010100000",--o
								--LINHA 12
								"1001010" when "01011000000",--J
								"0110010" when "01011000001",--2
								"0101101" when "01011000010",-- - 
								"0111100" when "01011000011",--(
								"1000010" when "01011000100",--B
								"1010100" when "01011000101",--T
								"1001110" when "01011000110",--N
								"0110001" when "01011000111",--1
								"0111110" when "01011001000",--)
								"1001101" when "01011001001",--M
								"1101111" when "01011001010",--o
								"1110110" when "01011001011",--v
								"1100101" when "01011001100",--e
								"1110010" when "01011001101",--r

								"1010010" when "01011001111",--R
								"1100001" when "01011010000",--a
								"1110001" when "01011010001",--q
								"1110101" when "01011010010",--u
								"1100101" when "01011010011",--e
								"1110100" when "01011010100",--t
								"1100101" when "01011010101",--e

								"1110000" when "01011010111",--p
								"1100001" when "01011011000",--a
								"1110010" when "01011011001",--r
								"1100001" when "01011011010",--a

								"1000011" when "01011011100",--C
								"1101001" when "01011011101",--i
								"1101101" when "01011011110",--m
								"1100001" when "01011011111",--a
								--LINHA 13
								"0111100" when "01100000011",--(
								"1000010" when "01100000100",--B
								"1010100" when "01100000101",--T
								"1001110" when "01100000110",--N
								"0110000" when "01100000111",--0
								"0111110" when "01100001000",--)
								"1001101" when "01100001001",--M
								"1101111" when "01100001010",--o
								"1110110" when "01100001011",--v
								"1100101" when "01100001100",--e
								"1110010" when "01100001101",--r

								"1010010" when "01100001111",--R
								"1100001" when "01100010000",--a
								"1110001" when "01100010001",--q
								"1110101" when "01100010010",--u
								"1100101" when "01100010011",--e
								"1110100" when "01100010100",--t
								"1100101" when "01100010101",--e

								"1110000" when "01100010111",--p
								"1100001" when "01100011000",--a
								"1110010" when "01100011001",--r
								"1100001" when "01100011010",--a

								"1000010" when "01100011100",--B
								"1100001" when "01100011101",--a
								"1101001" when "01100011110",--i
								"1111000" when "01100011111",--x
								"1101111" when "01100100000",--o
								--LINHA 14
								"0111100" when "01101000000",--(
								"1000101" when "01101000001",--E
								"1010011" when "01101000010",--S
								"1000011" when "01101000011",--C
								"0111110" when "01101000100",--)
								"1010010" when "01101000101",--R
								"1100101" when "01101000110",--e
								"1110011" when "01101000111",--s
								"1100101" when "01101001000",--e
								"1110100" when "01101001001",--t
								"1100001" when "01101001010",--a
								"1110010" when "01101001011",--r

								"1101111" when "01101001101",--o

								"1010011" when "01101001111",--S
								"1101001" when "01101010000",--i
								"1110011" when "01101010001",--s
								"1110100" when "01101010010",--t
								"1100101" when "01101010011",--e
								"1101101" when "01101010100",--m
								"1100001" when "01101010101",--a
								--LINHA 15
								"0111100" when "01110010101",--(
								"1000010" when "01110010110",--B
								"1000001" when "01110010111",--A
								"1000011" when "01110011000",--C
								"1001011" when "01110011001",--K
								"1010011" when "01110011010",--S
								"1010000" when "01110011011",--P
								"1000001" when "01110011100",--A
								"1000011" when "01110011101",--C
								"1000101" when "01110011110",--E
								"0111110" when "01110011111",--)
								"1010010" when "01110100000",--R
								"1100101" when "01110100001",--e
								"1110100" when "01110100010",--t
								"1101111" when "01110100011",--o
								"1110010" when "01110100100",--r
								"1101110" when "01110100101",--n
								"1100001" when "01110100110",--a
								"1110010" when "01110100111",--r
								--OUTROS
								"0000000" when others;	
	
	--MENU DE INTRODUCAO DE NOME J1
	name1_on  <= '1' when (text_active_in = "00011" or text_active_in = "00110") else '0'; --Pixels do texto do MENU DE INTRODUCAO DE NOME J1
	row_addr_name1 <= std_logic_vector(pix_y(4 downto 1)); 
	bit_addr_name1 <= std_logic_vector(pix_x(3 downto 1));
	with (pix_y(9 downto 5) & pix_x(9 downto 4)) select
		char_addr_name1  <=
			--LINHA1
			"1001001" when "00001000110", --I 
			"1001110" when "00001000111", --N
			"1010011" when "00001001000", --S
			"1001001" when "00001001001", --I
			"1010010" when "00001001010", --R
			"1000001" when "00001001011", --A
 
			"1001110" when "00001001101", --N
			"1001111" when "00001001110", --O
			"1001101" when "00001001111", --M	
			"1000101" when "00001010000", --E

			"1000100" when "00001010010", --D
			"1000101" when "00001010011", --E

			"1001010" when "00001010101", --J
			"0110001" when "00001010110", --1
			"1111011" when "00001010111", --(
			"0110001" when "00001011000", --1
			"0110000" when "00001011001", --0

			"1000100" when "00001011011", --D
			"1001001" when "00001011100", --I
			"1000111" when "00001011101", --G
			"1111101" when "00001011110", --)
			"1111100" when "00001011111", --:
			--LINHA2
			name1(0) when "00010000110",--Digit1
			name1(1) when "00010000111",--Digit2
			name1(2) when "00010001000",--Digit3
			name1(3) when "00010001001",--Digit4
			name1(4) when "00010001010",--Digit5
			name1(5) when "00010001011",--Digit6
			name1(6) when "00010001100",--Digit7
			name1(7) when "00010001101",--Digit8
			name1(8) when "00010001110",--Digit9
			name1(9) when "00010001111",--Digit10
			--LINHA15
			"0111100" when "01110011010",--<
			"1000101" when "01110011011",--E
			"1001110" when "01110011100",--N
			"1010100" when "01110011101",--T
			"1000101" when "01110011110",--E
			"1010010" when "01110011111",--R
			"0111110" when "01110100000",-->
			"1000001" when "01110100001",--A
			"1110110" when "01110100010",--v
			"1100001" when "01110100011",--a
			"1101110" when "01110100100",--n
			"1100011" when "01110100101",--c
			"1100001" when "01110100110",--a
			"1110010" when "01110100111",--r
			"0000000" when others;
			
	--MENU DE INTRODUCAO DE NOME J2/IA
	name2_on  <= '1' when (text_active_in = "00100" or text_active_in = "00111") else '0'; --Pixels do texto do MENU DE INTRODUCAO DE NOME J2
	row_addr_name2 <= std_logic_vector(pix_y(4 downto 1)); 
	bit_addr_name2 <= std_logic_vector(pix_x(3 downto 1));
	with (pix_y(9 downto 5) & pix_x(9 downto 4)) select
		char_addr_name2  <=
			--LINHA1
			"1001001" when "00001000110", --I 
			"1001110" when "00001000111", --N
			"1010011" when "00001001000", --S
			"1001001" when "00001001001", --I
			"1010010" when "00001001010", --R
			"1000001" when "00001001011", --A
 
			"1001110" when "00001001101", --N
			"1001111" when "00001001110", --O
			"1001101" when "00001001111", --M	
			"1000101" when "00001010000", --E

			"1000100" when "00001010010", --D
			"1000101" when "00001010011", --E
			"0000000" when "00001010100", --
			dig when "00001010101", --J/I
			dig1 when "00001010110", --2/A
			"1111011" when "00001010111", --(
			"0110001" when "00001011000", --1
			"0110000" when "00001011001", --0

			"1000100" when "00001011011", --D
			"1001001" when "00001011100", --I
			"1000111" when "00001011101", --G
			"1111101" when "00001011110", --)
			"1111100" when "00001011111", --:
			--LINHA2
			name2(0) when "00010000110",--Digit1
			name2(1) when "00010000111",--Digit2
			name2(2) when "00010001000",--Digit3
			name2(3) when "00010001001",--Digit4
			name2(4) when "00010001010",--Digit5
			name2(5) when "00010001011",--Digit6
			name2(6) when "00010001100",--Digit7
			name2(7) when "00010001101",--Digit8
			name2(8) when "00010001110",--Digit9
			name2(9) when "00010001111",--Digit10
			--LINHA15
			"0111100" when "01110011010",--<
			"1000101" when "01110011011",--E
			"1001110" when "01110011100",--N
			"1010100" when "01110011101",--T
			"1000101" when "01110011110",--E
			"1010010" when "01110011111",--R
			"0111110" when "01110100000",-->
			"1000001" when "01110100001",--A
			"1110110" when "01110100010",--v
			"1100001" when "01110100011",--a
			"1101110" when "01110100100",--n
			"1100011" when "01110100101",--c
			"1100001" when "01110100110",--a
			"1110010" when "01110100111",--r	
			"0000000" when others;
			
	--MENU DE SELECAO DE DIFICULDADE
	dif_on  <= '1' when (text_active_in = "00101") else '0'; --Pixels do texto do MENU DE SELECAO DE DIFICULDADE 
	row_addr_dif <= std_logic_vector(pix_y(4 downto 1)); 
	bit_addr_dif <= std_logic_vector(pix_x(3 downto 1));
	with (pix_y(9 downto 5) & pix_x(9 downto 4)) select
		char_addr_dif  <=
			--LINHA1
			"1010011" when "00001000110", --S 
			"1000101" when "00001000111", --E
			"1001100" when "00001001000", --L
			"1000101" when "00001001001", --E
			"1000011" when "00001001010", --C
			"1001001" when "00001001011", --I
			"1001111" when "00001001100", --O
			"1001110" when "00001001101", --N
			"1000101" when "00001001110", --E

			"1000001" when "00001010000", --A
			
			"1000100" when "00001010010", --D
			"1001001" when "00001010011", --I
			"1000110" when "00001010100", --F	
			"1001001" when "00001010101", --I
			"1000011" when "00001010110", --C
			"1010101" when "00001010111", --U
			"1001100" when "00001011000", --L
			"1000100" when "00001011001", --D
			"1000001" when "00001011010", --A
			"1000100" when "00001011011", --D
			"1000101" when "00001011100", --E
			"1111100" when "00001011101", --:
			--LINHA 3
			"0111100" when "00011001100",--<
			"0110001" when "00011001101",--1
			"0111110" when "00011001110",-->
			"1000110" when "00011001111",--F
			"1000001" when "00011010000",--A
			"1000011" when "00011010001",--C
			"1001001" when "00011010010",--I
			"1001100" when "00011010011",--L
			--LINHA 4
			"0111100" when "00100001100",--<
			"0110010" when "00100001101",--2
			"0111110" when "00100001110",-->
			"1001101" when "00100001111",--M
			"1000101" when "00100010000",--E
			"1000100" when "00100010001",--D
			"1001001" when "00100010010",--I
			"1001111" when "00100010011",--O
			--LINHA 5
			"0111100" when "00101001100",--<
			"0110011" when "00101001101",--3
			"0111110" when "00101001110",-->
			"1000100" when "00101001111",--D
			"1001001" when "00101010000",--I
			"1000110" when "00101010001",--F
			"1001001" when "00101010010",--I
			"1000011" when "00101010011",--C
			"1001001" when "00101010100",--I
			"1001100" when "00101010101",--L
			--LINHA15
			"0111100" when "01110000000",--[
			"0110001" when "01110000001",--1
			"0111110" when "01110000010",--]
			"1001111" when "01110000011",--O
			"1110000" when "01110000100",--p
			"1100011" when "01110000101",--c
			"1100001" when "01110000110",--a
			"1101111" when "01110000111",--o
			"0110001" when "01110001000",--1

			"0111100" when "01110001010",--[
			"0110010" when "01110001011",--2
			"0111110" when "01110001100",--]
			"1001111" when "01110001101",--O
			"1110000" when "01110001110",--p
			"1100011" when "01110001111",--c
			"1100001" when "01110010000",--a
			"1101111" when "01110010001",--o
			"0110010" when "01110010010",--2

			"0111100" when "01110010100",--[
			"0110011" when "01110010101",--3
			"0111110" when "01110010110",--]
			"1001111" when "01110010111",--O
			"1110000" when "01110011000",--p
			"1100011" when "01110011001",--c
			"1100001" when "01110011010",--a
			"1101111" when "01110011011",--o
			"0110011" when "01110011100",--3	
			"0000000" when others;

	--TELA DA PARTIDA
	--Nome J1
	p1_name_on <= '1' when (((P1_NAME_L<=pix_x) and (pix_x<=P1_NAME_R)) and (pix_y<SCORE_D) and (text_active_in = "01000" or text_active_in = "01001")) else '0'; --Pixels do texto do NOME DO J1
	row_addr_p1 <=  std_logic_vector(pix_y(4 downto 1));
	bit_addr_p1 <=  std_logic_vector(pix_x(3 downto 1));
	with pix_x(7 downto 4) select
		char_addr_p1 <=
			"1001010" when "0000", --J 
			"0110001" when "0001", --1
			"0101101" when "0010", -- - 
			name1(0) when "0011", 
			name1(1) when "0100", 
			name1(2) when "0101", 
			name1(3) when "0110", 
			name1(4) when "0111",
			name1(5) when "1000",
			name1(6) when "1001",
			name1(7) when "1010",
			name1(8) when "1011",
			name1(9) when "1100",	
			"0000000" when others;
	
	--Placar	
	score_on <= '1' when (((SCORE_L<=pix_x) and (pix_x<=SCORE_R)) and (pix_y<SCORE_D) and (text_active_in = "01000")) else '0'; --Pixels do texto do NOME DO PLACAR
	row_addr_s <=  std_logic_vector(pix_y(4 downto 1));
	bit_addr_s <=  std_logic_vector(pix_x(3 downto 1));
	with pix_x(9 downto 4) select
		char_addr_s <=
			"011" & p1_score_in(7 downto 4) when "010001",
			"011" & p1_score_in(3 downto 0) when "010010",
			
			"011" & p2_score_in(7 downto 4) when "010101",
			"011" & p2_score_in(3 downto 0) when "010110",
			"0000000" when others;
	
	--Nome J2/IA
	p2_name_on <= '1' when (((P2_NAME_L<=pix_x) and (pix_x<=P2_NAME_R)) and (pix_y<SCORE_D) and (text_active_in = "01000" or text_active_in = "01001")) else '0'; --Pixels do texto do NOME DO J2
	row_addr_p2 <=  std_logic_vector(pix_y(4 downto 1));
	bit_addr_p2 <=  std_logic_vector(pix_x(3 downto 1));
	with pix_x(9 downto 4) select
		char_addr_p2 <=
			name2(9) when "100111",
			name2(8) when "100110",
			name2(7) when "100101",
			name2(6) when "100100",
			name2(5) when "100011",
			name2(4) when "100010",
			name2(3) when "100001",
			name2(2) when "100000",
			name2(1) when "011111",
			name2(0) when "011110",
			"0101101" when "011101", -- -
			dig1 when "011100", --2/A
			dig when "011011", --J/I	
			"0000000" when others;
	
	--Nome do vencedor
	winner_on <= '1' when (((SCORE_L<=pix_x) and (pix_x<=SCORE_R)) and (pix_y<SCORE_D) and text_active_in = "01001") else '0'; --Pixels do texto do NOME DO VENCEDOR
	row_addr_w <=  std_logic_vector(pix_y(4 downto 1));
	bit_addr_w <=  std_logic_vector(pix_x(3 downto 1));
	with pix_x(9 downto 4) select
		char_addr_w <=
			"0010011" when "001111", --!!
			dig2 when "010000", --J/I
			dig3 when "010001", --A/numero
			
			"1010110" when "010011", --V
			"1000101" when "010100", --E
			"1001110" when "010101", --N
			"1000011" when "010110", --C
			"1000101" when "010111", --E
			"1010101" when "011000", --U
			"0010011" when "011001", --!!
			"0000000" when others;
	
	--Menu de GAME OVER
	over_on <= '1' when ((pix_y(9 downto 6)=3 and 5<=pix_x(9 downto 5) and pix_x(9 downto 5)<=13) and text_active_in = "01001") else '0'; --Pixels do texto do MENU DE FIM DE JOGO
	row_addr_o <= std_logic_vector(pix_y(5 downto 2));
	bit_addr_o <= std_logic_vector(pix_x(4 downto 2));
	with pix_x(8 downto 5) select  
		char_addr_o  <=
			"1000111" when "0101", --G
			"1100001" when "0110", --a
			"1101101" when "0111", --m
			"1100101" when "1000", --e
			"0000000" when "1001", --
			"1001111" when "1010", --O
			"1110110" when "1011", --v
			"1100101" when "1100", --e
			"1110010" when others; --r	
	over_on2 <= '1'  when ((pix_x(9 downto 4) >= "000101" and pix_x(9 downto 4) <= "011111") and (pix_y(9 downto 5) = "01010")) and (text_active_in = "01001") else '0'; --Pixels do texto do MENU DE FIM DE JOGO
	row_addr_o2 <= std_logic_vector(pix_y(4 downto 1));
	bit_addr_o2 <= std_logic_vector(pix_x(3 downto 1));
	with (pix_y(9 downto 5) & pix_x(9 downto 4)) select 
		char_addr_o2  <=
			--LINHA 10
			"0111100" when "01010000101",--(
			"1010011" when "01010000110",--S
			"1010000" when "01010000111",--P
			"1000001" when "01010001000",--A
			"1000011" when "01010001001",--C
			"1000101" when "01010001010",--E
			"1000010" when "01010001011",--B
			"1000001" when "01010001100",--A
			"1010010" when "01010001101",--R
			"0111110" when "01010001110",--)
			"1010010" when "01010001111",--R
			"1100101" when "01010010000",--e
			"1101001" when "01010010001",--i
			"1101110" when "01010010010",--n
			"1101001" when "01010010011",--i
			"1100011" when "01010010100",--c
			"1101001" when "01010010101",--i
			"1100001" when "01010010110",--a
			"1110010" when "01010010111",--r

			"1010000" when "01010011001",--P
			"1100001" when "01010011010",--a
			"1110010" when "01010011011",--r
			"1110100" when "01010011100",--t
			"1101001" when "01010011101",--i
			"1100100" when "01010011110",--d
			"1100001" when "01010011111",--a
			"0000000" when others;
	over_on3 <= '1'  when ((pix_x(9 downto 4) >= "000101" and pix_x(9 downto 4) <= "100010") and (pix_y(9 downto 5) = "01011")) and (text_active_in = "01001" and match_type_in = "01") else '0'; --Pixels do texto do MENU DE FIM DE JOGO
	row_addr_o3 <= std_logic_vector(pix_y(4 downto 1));
	bit_addr_o3 <= std_logic_vector(pix_x(3 downto 1));
	with (pix_y(9 downto 5) & pix_x(9 downto 4)) select 
		char_addr_o3  <=
			--LINHA 10
			"0111100" when "01011000101",--(
			"1000010" when "01011000110",--B
			"1000001" when "01011000111",--A
			"1000011" when "01011001000",--C
			"1001011" when "01011001001",--K
			"1010011" when "01011001010",--S
			"1010000" when "01011001011",--P
			"1000001" when "01011001100",--A
			"1000011" when "01011001101",--C
			"1000101" when "01011001110",--E
			"0111110" when "01011001111",--)
			"1000001" when "01011010000",--A
			"1101100" when "01011010001",--l
			"1110100" when "01011010010",--t
			"1100101" when "01011010011",--e
			"1110010" when "01011010100",--r
			"1100001" when "01011010101",--a
			"1110010" when "01011010110",--r

			"1000100" when "01011011000",--D
			"1101001" when "01011011001",--i
			"1100110" when "01011011010",--f
			"1101001" when "01011011011",--i
			"1100011" when "01011011100",--c
			"1110101" when "01011011101",--u
			"1101100" when "01011011110",--l
			"1100100" when "01011011111",--d
			"1100001" when "01011100000",--a
			"1100100" when "01011100001",--d
			"1100101" when "01011100010",--e
			"0000000" when others;
	
	--Processos
	mux : process(font_bit, winner_on, logo_on, char_addr_l, row_addr_l, bit_addr_l, logo1_on, char_addr_l1, row_addr_l1, bit_addr_l1, sc_on, char_addr_sc, row_addr_sc, bit_addr_sc, mm_on, row_addr_mm, bit_addr_mm, char_addr_mm, score_on, char_addr_s, row_addr_s, bit_addr_s, p1_name_on, char_addr_p1, row_addr_p1, bit_addr_p1, p2_name_on, char_addr_p2, row_addr_p2, bit_addr_p2, over_on, char_addr_o, row_addr_o, bit_addr_o, char_addr_w, row_addr_w, bit_addr_w, name1_on, name2_on, dif_on, over_on2, char_addr_name1, char_addr_name2, char_addr_dif, bit_addr_o2, row_addr_name1, row_addr_name2, row_addr_dif, char_addr_o2, bit_addr_name1, bit_addr_name2, bit_addr_dif, row_addr_o2, rule_on, char_addr_r, row_addr_r, bit_addr_r, over_on3, char_addr_o3, row_addr_o3, bit_addr_o3) --Logica do texto ativo
	begin
		if logo_on='1' then --Exibe LOGO
			char_addr <= char_addr_l;
			row_addr <= row_addr_l;
			bit_addr <= bit_addr_l;
			if font_bit='1' then
				text_rgb <= "100";
			else
				text_rgb <= "000";
			end if;
		elsif logo1_on='1' then --Exibe LOGO
			char_addr <= char_addr_l1;               
			row_addr <= row_addr_l1;
			bit_addr <= bit_addr_l1;
			if font_bit='1' then
				text_rgb <= "111";
			else
				text_rgb <= "000";
			end if;
		elsif sc_on='1' then --Exibe TELA INICIAL
			char_addr <= char_addr_sc;
			row_addr <= row_addr_sc;
			bit_addr <= bit_addr_sc;
			if font_bit='1' then
				text_rgb <= "111";
			else
				text_rgb <= "000";
			end if;
		elsif mm_on = '1' then --Exibe MENU PRINCIPAL
			char_addr <= char_addr_mm;
			row_addr <= row_addr_mm;
			bit_addr <= bit_addr_mm;
			if font_bit='1' then
				text_rgb <= "111";
			else
				text_rgb <= "000";
			end if;
		elsif score_on = '1' then --Exibe PLACAR
			char_addr <= char_addr_s;
			row_addr <= row_addr_s;
			bit_addr <= bit_addr_s;
			if font_bit='1' then
				text_rgb <= "001";
			else
				text_rgb <= "010";
			end if;
		elsif p1_name_on = '1' then --Exibe NOME DO J1(PARTIDA)
			char_addr <= char_addr_p1;
			row_addr <= row_addr_p1;
			bit_addr <= bit_addr_p1;
			if font_bit='1' then
				text_rgb <= "001";
			else
				text_rgb <= "010";
			end if;
		elsif p2_name_on = '1' then --Exibe NOME DO J2(PARTIDA)
			char_addr <= char_addr_p2;
			row_addr <= row_addr_p2;
			bit_addr <= bit_addr_p2;
			if font_bit='1' then
				text_rgb <= "001";
			else
				text_rgb <= "010";
			end if;
		elsif over_on = '1' then --Exibe MENU DE FIM DE JOGO
			char_addr <= char_addr_o;
			row_addr <= row_addr_o;
			bit_addr <= bit_addr_o;
			if font_bit='1' then
				text_rgb <= "100";
			else
				text_rgb <= "000";
			end if;
		elsif over_on2 = '1' then --Exibe MENU DE FIM DE JOGO
			char_addr <= char_addr_o2;
			row_addr <= row_addr_o2;
			bit_addr <= bit_addr_o2;
			if font_bit='1' then
				text_rgb <= "100";
			else
				text_rgb <= "000";
			end if;
		elsif over_on3 = '1' then --Exibe MENU DE FIM DE JOGO
			char_addr <= char_addr_o3;
			row_addr <= row_addr_o3;
			bit_addr <= bit_addr_o3;
			if font_bit='1' then
				text_rgb <= "100";
			else
				text_rgb <= "000";
			end if;		
		elsif winner_on = '1' then --Exibe NOME DO VENCEDOR
			char_addr <= char_addr_w;
			row_addr <= row_addr_w;
			bit_addr <= bit_addr_w;
			if font_bit='1' then
				text_rgb <= "001";
			else
				text_rgb <= "010";
			end if;
		elsif name1_on = '1' then --Exibe NOME DO J1(MENU DE INTRODUÇÃO DE NOMES)
			char_addr <= char_addr_name1;               
			row_addr <= row_addr_name1;
			bit_addr <= bit_addr_name1;
			if font_bit='1' then
				text_rgb <= "111";
			else
				text_rgb <= "000";
			end if;
		elsif name2_on = '1' then --Exibe NOME DO J2(MENU DE INTRODUÇÃO DE NOMES)
			char_addr <= char_addr_name2;               
			row_addr <= row_addr_name2;
			bit_addr <= bit_addr_name2;
			if font_bit='1' then
				text_rgb <= "111";
			else
				text_rgb <= "000";
			end if;
		elsif dif_on = '1' then --Exibe MENU DE SELECAO DE DIFICULDADE
			char_addr <= char_addr_dif;               
			row_addr <= row_addr_dif;
			bit_addr <= bit_addr_dif;
			if font_bit='1' then
				text_rgb <= "111";
			else
				text_rgb <= "000";
			end if;
		else --Exibe MENU DE REGRAS
			char_addr <= char_addr_r;
			row_addr <= row_addr_r;
			bit_addr <= bit_addr_r;
			if font_bit='1' then
				text_rgb <= "111";
			else
				text_rgb <= "000";
			end if;
		end if;
	end process mux;
	
	p1_getname : process(clk_in, reset_in ,player_getname_in ,digit_in, cont1) --Lógica do nome do J1
	begin
		if (reset_in = '1') then --Reseta valores
			cont1 <= 0;
			cont1_next <= 0;
			name1 <=
			(
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000"
			);
		elsif (clk_in'event and clk_in = '1') then --Atualiza valores
			if (player_getname_in = "10") then --Recebe nome do competidor
				if (digit_in /= "0000000") then --Recebe digito
					if (digit_in = "0000001") then --Apaga digito
						name1(cont1) <= "0000000";
						if (cont1 > 0) then --Verifica limite minimo do vetor
							cont1_next <= cont1 - 1; --Decrementa contador
						else
							cont1_next <= cont1;
						end if;
					else --Escreve digito
						name1(cont1) <= digit_in;
						if (cont1 < 10) then --Verifica limite maximo do vetor
							cont1_next <= cont1 + 1; --Incrementa contador
						else
							cont1_next <= cont1;
						end if;
					end if;
				else
					cont1 <= cont1_next; --Atualiza contador
				end if;
			end if;
		end if;
	end process p1_getname;
	
	p2_getname : process(clk_in, reset_in ,player_getname_in ,digit_in, cont2) --Lógica do nome do J2
	begin
		if (reset_in = '1') then --Reseta valores
			cont2 <= 0;
			cont2_next <= 0;
			name2 <=
			(
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000",
				"0000000"
			);
		elsif (clk_in'event and clk_in = '1') then --Atualiza valores
			if (player_getname_in = "01") then --Recebe nome do competidor
				if (digit_in /= "0000000") then --Recebe digito
					if (digit_in = "0000001") then --Apaga digito
						name2(cont2) <= "0000000";
						if (cont2 > 0) then --Verifica limite minimo do vetor
							cont2_next <= cont2 - 1; --Decrementa contador
						else
							cont2_next <= cont2;
						end if;
					else --Escreve digito
						name2(cont2) <= digit_in; --Verifica limite maximo do vetor
						if (cont2 < 10) then
							cont2_next <= cont2 + 1; --Incrementa contador
						else
							cont2_next <= cont2;
						end if;
					end if;
				else
					cont2 <= cont2_next; --Atualiza contador
				end if;
			end if;
		end if;
	end process p2_getname;
	
	oponent_id : process(match_type_in) --Lógica do identificador do oponente
	begin
		if match_type_in = "01" then --1 jogador
			dig <= "1001001"; --I 
			dig1 <= "1000001"; --A
		else --2 jogadores
			dig <= "1001010"; --J
			dig1 <= "0110010"; --2
		end if;
	end process oponent_id;
	
	winner_id : process(match_winner_in, match_type_in)  --Lógica do identificador do vencedor
	begin
		if match_winner_in = "01" then --J1 venceu
			dig2 <= "1001001"; --J
			dig3 <= "0110001"; --1
		else 
			if match_type_in = "01" then --IA venceu
				dig2 <= "1001001"; --I
				dig3 <= "1000001"; --A
			else --J2 venceu
				dig2 <= "1001001"; --J
				dig3 <= "0110010"; --2
			end if;
		end if;
	end process winner_id;
	
end arch;

