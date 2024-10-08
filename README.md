## DADOS DO PROJETO
- **Nome:** PongGame; 
- **Autor:** Leonardo Severino - leoseverino0901@gmail.com;
- **Data de Criação:** 30/10/2023 - 17:21:26;
 
## SOBRE
- **Descrição:**
  - Implementação de um jogo eletrônico de ping-pong em Linguagem de Descrição de Hardware(HDL) para ser executado em dispositivo lógico programável do tipo FPGA Digilent Nexys2 com integração a um teclado do tipo PS/2 e uma tela do tipo LCD;
- **Requisitos:**
  - x1 Placa do tipo FPGA Digilent Nexys2: Plataforma para execução do jogo, além de permitir aos jogadores controlarem o movimento das raquetes no eixo vertical através de 4 botões de sua arquitetura e exibir o placar da partida atual em seu display de sete segmentos;
  - x1 Teclado do tipo PS/2: Periférico que permitirá aos jogadores selecionarem o modo de jogo, selecionar o nível de dificuldade d no modo para um jogador, inserir o nome dos participantes da partida e resetar o jogo;
  - x1 Tela do tipo LCD: Periférico que exibirá as imagens do sistema, sejam os menus do jogo ou a partida atual, onde são exibidas as raquetes, a quadra, a bola e o placar com o nome dos participantes;
- **Funcionalidades:**
  - Visualização do menu de regras: Permitir aos usuários visualizarem um menu que os instrui como o jogo funciona, apresentando as regras do jogos, os modos de jogo e os controles;
  - Seleção do modo de jogo: Permitir aos usuários selecionar o modo de jogo, seja o modo para um jogador, onde um jogador compete contra a máquina, ou o modo para dois jogadores, onde dois jogadores competem entre si;
  - Seleção do nível de dificuldade no modo para 1 jogador: Permitir ao usuário escolher um entre três níveis de dificuldade, sendo eles fácil, médio ou difícil;
  - Inserção do nome dos participantes: Permitir que, através do teclado PS/2, os usuário insiram o nome dos participantes da partida, tanto dos jogadores quanto da máquina;
  - Easter Egg: Inclusão de uma surpresa, no qual a bola se torna um ícone de caveira quando o placar for 13:13, o "número do azar", independente do modo de jogo;
- **Referencial Teórico:**
  - Sincronismo de vídeo:
    - Utiliza-se o padrão VGA, o qual é largamente suportado por hardware de gráficos de computadores, para implementar as funções de vídeo, pois este é capaz de exibir oito cores diferentes(preto, azul, verde, ciano, vermelho, magenta, amarelo e branco) em uma interface de 640 pixels no sentido horizontal por 480 pixels no sentido vertical, com uma frequência de 25 MHz;
    - Para operar com o padrão VGA, é necessário utilizar uma controladora de vídeo, a qual gera os sinais de temporização e de sincronismo, além das saídas de dados seriais correspondentes às coordenadas dos pixels. O circuito de sincronismo de vídeo gera um sinal de sincronia horizontal, que especifica o período necessário para escanear uma linha, e outro de sincronia vertical, que especifica o período para escanear a tela inteira, além de um sinal de vídeo ativo, que informa se o pixel correspondente às coordenadas recebidas deve ou não ser exibido. Já o circuito de geração de pixels produz três sinais de vídeo, coletivamente conhecidos como rgb, que, de acordo com as coordenadas atuais do pixel e dos sinais de controle e de dados externos, possuíram um dos oito valores de cores diferentes do padrão;

      ![image](https://github.com/user-attachments/assets/6818d849-d801-4e85-b0e9-02a046405300)
      
  - Construção e movimentação de objetos:
    - Utilizando o padrão VGA descrito anteriormente, é possível construir e movimentar objetos em tela, definindo seus limites horizontais e verticais, e posteriormente comparando estes com as saídas de dados seriais e, caso aqueles estejam no intervalo destes, os objetos correspondentes são exibidos em tela, de acordo com um sistema de prioridades;
    - Para gerar objetos retangulares, utiliza-se o esquema de mapeamento por objeto(object-mapped scheme), no qual deve-se registrar as coordenadas horizontal e vertical do objeto e compará-las com as coordenadas do pixel atual e, caso estas estejam dentro da região daquelas, o objeto em questão será exibido com a cor especificada pelo sinal RGB. Este é método utilizado para criar a quadra(plano de fundo) e as raquetes(barras verticais esquerda e direita).
    - Para gerar a bola(esfera), que é um objeto não-retangular, utiliza-se o esquema de mapeamento por bit(bit-mapped scheme), no qual uma memória de vídeo é utilizada para armazenar os dados a serem exibidos em tela, mapeando
cada pixel da tela diretamente para uma palavra da memória, semelhante a uma matriz, sendo os sinais das coordenadas horizontal e vertical do pixel o endereço daquela. Posteriormente, um circuito especializado irá realizar leituras contínuas da memória de vídeo e rotear o dado para o sinal rgb. Sendo assim, para gerar o objeto, deve-se verificar se as coordenadas do pixel estão dentro da matriz e, caso positivo, obter o pixel correspondente ao bit mapeado, utilizando tal informação para definir se o objeto em questão será ou não exibido, bem como a sua cor correspondente;
    - Para gerar caracteres alfanuméricos, utiliza-se o esquema de mapeamento por ladrilhos(tile-mapped scheme), no qual uma coleção de bits é agrupada para formar um ladrilho(tile), e cada ladrilho é tratado como uma unidade de exibição separada composta por múltiplos pixels. Sendo assim, cada caractere será tratado como um ladrilho, cujo valor representa o código de um padrão específico correspondente ao caractere que se deseja exibir. Dessa forma, foi possível criar os menus de jogo, o placar de jogo e o nome dos jogadores durante a partida;
    - Para realizar a movimentação dos objetos, deve-se utilizar registradores para armazenar os limites e a posição horizontal e vertical deste, que serão lidos e atualizá-los a cada scan realizado pelo circuito de geração de pixels em uma frequência de 60 MHz, criando assim a ilusão de movimento do objeto em questão. Com isso, foi possível realizar o movimento vertical das raquetes, o qual é feito de acordo com as entradas fornecidas pelos jogadores, e os movimentos horizontal e vertical da bola durante a partida; 
  - Lógica de jogo:
    - O algoritmo de jogo foi baseado nas regras já definidas do ping pong para definir a lógica do jogo, permitindo partidas de jogador contra jogador ou jogador contra máquina. Para ambos os casos, se tem uma bola(esfera) e duas áreas, uma esquerda e outra direita, onde estão localizadas uma raquete(barra vertical) controlada por cada um dos competidores, que tem como objetivo ser o primeiro a marcar vinte pontos e, assim, ganhar a partida. Para tal, eles devem utilizar as raquetes para rebater a bola contra a área do oponente, de forma que este não consiga fazer o mesmo, dessa forma marcando um ponto;
    - As raquetes são movidas verticalmente para cima ou para baixo até atingirem os limites, seja o superior ou o inferior da tela, permanecendo fixas em sua posição no eixo horizontal, tal movimento ocorre quando é recebido um sinal, seja do jogador ou da máquina, para realizar o movimento, no qual os registradores de posição associados a cada raquete serão atualizados e sua posição em tela alterada;
    - O movimento da raquete esquerda é feito inteiramente pelo jogador 1, enquanto o da raquete da direita pode ser realizado pelo jogador 2 no modo para dois jogadores ou por uma inteligência artificial controlada pela máquina. No segundo caso, tem-se um algoritmo que verifica a posição atual da bola e altera a posição da raquete de acordo com esta, movendo-a para cima quando a bola estiver acima do limite superior da raquete e para baixo quando a bola estiver abaixo do limite inferior, em uma velocidade definida pelo jogador ao selecionar o nível de dificuldade;
    - Já a bola possui movimento, tanto de saque quanto de deslocamento, realizado de forma automática, simultaneamente no eixo vertical e horizontal, também alterando sua posição em tela de acordo com a atualização de seus registradores associados. A alteração do movimento no sentido horizontal da bola ocorre quando esta atinge uma das raquetes, sendo do sentido da esquerda para a direita quando ela é rebatida pela raquete do jogador 1 e da direita para a esquerda quando é rebatida pela raquete do jogador 2/máquina, e no sentido vertical quando atinge um dos limites, inferior ou superior, da tela, sendo de baixo para cima quando atinge o primeiro e de cima para baixo ao atingir o segundo;
    - Quando o jogo se inicia, é exibido na parte superior da tela o nome dos competidores, estando o do jogador 1 localizado na extremidade esquerda e o do jogador 2/máquina na direita, bem como o placar da partida, o qual está localizado no centro e tem nos dois dígitos da esquerda a pontuação do jogador 1 e nos da direita o do jogador 2/máquina. Abaixo do placar, tem-se a quadra onde a partida ocorre, sendo atravessado em seu centro horizontal por uma barra que a divide em duas áreas, sendo a área da esquerda é a do jogador 1, onde está localizada sua raquete próxima a extremidade correspondente da tela, e a área da direita será a do jogador 2/máquina, estando também sua raquete localizada na extremidade da tela;
    - A bola estará localizada na área esquerda da tela, posicionada levemente à direita da raquete do jogador 1, o qual dará o primeiro saque que, como mencionado anteriormente, ocorre de forma automática, no qual, após um breve intervalo de tempo, a bola se deslocará no sentido da esquerda para a direita e de cima para baixo;
    - Quanto à contabilidade de pontos, tem-se dois contadores, um para cada competidor, cujo valor é atualizado sempre que a bola atravessa uma das áreas. Caso a bola atravesse a área direita, o contador de pontos do jogador 1 será incrementado em uma unidade e a bola será posicionada na área esquerda, levemente à direita da raquete do jogador 1, onde, após um breve intervalo de tempo, ocorre o saque automático, no sentido da esquerda para a direita. Porém, caso a bola atravesse a área esquerda, contador de pontos do jogador 2/máquina será incrementado em uma unidade e a bola será posicionada na área direita, levemente à esquerda da raquete do jogador 2/máquina, e ocorre o saque automático, após um breve intervalo de tempo, no sentido da direita para a esquerda;
    - Tal processo se repete até que um dos contadores atinja a marca de 20 unidades, no qual a partida se encerra, é exibida a mensagem de fim de jogo e o nome associado ao vencedor, ou seja, do competidor cujo o contador associado foi o primeiro a atingir a marca de 20 pontos;
  - Lógica do teclado PS/2:
    - Para operar com um teclado PS/2, utiliza-se a comunicação device-to-host, onde o dispositivo, no caso, o teclado, gera tanto o sinal de relógio(clock) quanto o de dados, ambos iniciando em nível lógico alto e sendo trincados pelo host durante a borda de descida do sinal de clock. Além disso, necessita-se um filtro para ler tais dados com precisão, realizando um deslocamento dos sinais recebidos pelo dispositivo através de um registrador, em uma frequência de 25 MHz;
    - Para ler os dados recebidos pelo teclado, onde, para cada tecla física, tem-se dois códigos em scancode associados. O primeiro é chamado de make code, o qual é formato por um byte e é enviado pelo dispositivo enquanto a tecla estiver sendo pressionada, e o segundo é chamado de break code, que é formato por dois bytes, o byte do make code precedido pelo hex byte F0, e que será enviado pelo dispositivo ao soltar a tecla;
    - Dessa forma, é possível decodificar os dados recebidos pelo teclado, permitindo ao(s) usuário(s) interagir com o sistema, seja para inicializar o jogo, acessar os diferentes menu, selecionar um modo de jogo, inserir o nome dos competidores, definir ou alterar o nível de dificuldade, resetar o jogo ou reiniciar a partida atual;

      ![image](https://github.com/user-attachments/assets/145475e4-5f5c-4189-919a-dfb28e89baa9)
               
## DEMONSTRAÇÃO
![image](https://github.com/user-attachments/assets/3cfa6f87-2f86-47f5-bfd8-be7fb90b9cb8)
![image](https://github.com/user-attachments/assets/e6bc60c9-3dd7-4f6c-a26f-fccdc7043ac1)
![image](https://github.com/user-attachments/assets/f3a12451-ff91-45b9-8b9a-5d57e70f4d37)
![image](https://github.com/user-attachments/assets/985c7a10-2eda-49bc-85fb-5013bd386fe5)
![image](https://github.com/user-attachments/assets/c237cbf3-4746-4aa2-b98e-3da1d3316138)
![image](https://github.com/user-attachments/assets/d9a68d59-5140-4c6b-b8c0-43884e4c6dd5)
![image](https://github.com/user-attachments/assets/d9a5bb0d-27ce-476a-95dd-3164e8885224)
![image](https://github.com/user-attachments/assets/57239eca-a7bb-42ca-8969-efa8718749b7)
![image](https://github.com/user-attachments/assets/638ccf7c-6a48-4adf-885d-1ff11ddda43d)
![image](https://github.com/user-attachments/assets/c7eb53d8-63d3-4c30-aadc-19a674b9b690)
![image](https://github.com/user-attachments/assets/3fb2170e-e9f9-404c-a9e0-571fa4cd913d)
![image](https://github.com/user-attachments/assets/3d1a3a68-f835-4f06-bae0-5f6d741fa5c4)
![image](https://github.com/user-attachments/assets/5b1320ef-f8cf-4de2-946e-b2523d3e42de)
![image](https://github.com/user-attachments/assets/785f5130-538c-4f9c-b5d7-91b71e43a9b7)
![image](https://github.com/user-attachments/assets/e9daa5b2-e881-4887-815f-c1eb78e5f59e)
![image](https://github.com/user-attachments/assets/17002fb0-57b0-468f-a508-c8b08ae6ee49)
![image](https://github.com/user-attachments/assets/b0ff0d44-2c24-40e2-99f4-ce9438016157)
![image](https://github.com/user-attachments/assets/b3b17f02-a230-4fba-a503-b734b5e7767c)
![image](https://github.com/user-attachments/assets/b3b30f45-44ff-4623-b88c-0392964175da)
![image](https://github.com/user-attachments/assets/9dd80160-cea5-45ce-9fc8-8ebc9f82a0f3)
![image](https://github.com/user-attachments/assets/95a0468a-65d1-45da-a09b-e2f47f5e01cd)
![image](https://github.com/user-attachments/assets/b7b476a5-7a13-465c-a310-00d18b299cbe)
![image](https://github.com/user-attachments/assets/fe603998-1e90-46ae-9bcc-e1a10052f2a4)
![image](https://github.com/user-attachments/assets/5096834f-12be-4ca2-8b1b-bdf53b170afa)
![image](https://github.com/user-attachments/assets/ba007884-77cc-4273-9632-986ce4f5b5ee)
![image](https://github.com/user-attachments/assets/b0335aab-4a0d-4a08-b55e-8a0db01b08b3)
![image](https://github.com/user-attachments/assets/7e11f439-1769-456b-8931-6d884a11b6ba)






























