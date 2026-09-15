# 🏝️ INSULANO - Catálogo de Eventos do Náufrago

> **Versão 1.0** | 214 eventos | Para uso com Godot 4 + Beehave + Ollama (llama3.1:8b)
> Filosofia: *cómico mas com alma, nunca violento, PG-13*

---

## Notas de Design

- As **frases** são exemplos-semente para o LLM - o modelo deve variar ligeiramente a cada execução
- **Pesos sugeridos** no Beehave: COMUM = peso 100, RARO = 15, MUITO_RARO = 3, LENDÁRIO = 0.2
- Eventos marcados com ⚡ requerem condição climática especial
- Eventos marcados com 🌙 ocorrem apenas à noite
- Eventos marcados com ☀️ ocorrem apenas de dia

---

## 🟢 COMUM - O Quotidiano da Sobrevivência
*Acontece várias vezes por dia. O pão nosso de cada náufrago.*

| # | Nome Curto | Descrição da Animação | Frase do Náufrago |
|---|---|---|---|
| C01 | **Pesca à Cana** | O náufrago senta-se na beira da água com uma cana improvisada, balançando as pernas. De vez em quando olha para o anzol com esperança crescente. | *"Hoje apanho um. Tenho a certeza absoluta. Desta vez é definitivo."* |
| C02 | **Peixe que Foge** | Fisgou! O náufrago levanta-se animado - mas o peixe salta e escapa. Ele fica a olhar para a linha vazia com a boca aberta. | *"Fugiu. Claro que fugiu. É pessoalmente contra mim."* |
| C03 | **Peixe Minúsculo** | Puxa a linha triunfante e encontra um peixinho ridiculamente pequeno. Olha para ele, olha para o oceano, suspira. Come na mesma. | *"Nutricionalmente... deve valer qualquer coisa. Talvez."* |
| C04 | **Sesta à Sombra** ☀️ | Deita-se debaixo da palmeira, cruza os braços sobre o peito, chapéu de folhas sobre a cara. Ronca suavemente em zig-zag. | *"Não estou a dormir. Estou a meditar horizontalmente."* |
| C05 | **Sonho Agitado** 🌙 | Dorme mas mexe-se, dá pontapés no ar, murmura. De repente senta-se a suar, olha à volta, deita-se outra vez. | *"...não, a reunião é às nove... o relatório... ah. Não. Ok."* |
| C06 | **Olhar para o Horizonte** | Fica de pé na areia, mãos nas costas, a olhar fixamente para o oceano. Muito fixamente. Demasiado fixamente. | *"Há de passar um barco. A lei das probabilidades assim o exige."* |
| C07 | **Andar às Voltas** | Percorre a ilha inteira - que tem talvez 15 passos de diâmetro - em círculos crescentemente frenéticos. | *"Exercício. É fundamental. A saúde mental depende do exercício."* |
| C08 | **Passear na Praia** | Caminha devagar ao longo da água, deixando pegadas. Para, olha, continua. É uma caminhada de 8 passos. | *"A vista é sempre nova. Ou então já enlouqueci. Ambas as hipóteses."* |
| C09 | **Coco no Pequeno-Almoço** ☀️ | Parte um coco com uma pedra, bebe a água com cerimónia exagerada, como se fosse café de máquina. | *"Ah. O expresso das ilhas. Notas de... coco. Surpreendente."* |
| C10 | **Coco no Almoço** ☀️ | Come a polpa de coco com um pauzinho improvisado, sentado numa pedra como se fosse um restaurante. | *"O prato do dia. E o prato de ontem. E de amanhã."* |
| C11 | **Coco no Jantar** 🌙 | Abre mais um coco com cansaço filosófico. Olha para ele longamente antes de comer. | *"Se eu ver mais um coco vou... comer outro coco. Não tenho escolha."* |
| C12 | **Construir Abrigo** ☀️ | Empilha folhas de palmeira com arquitectura duvidosa. A estrutura inclina. Ele inclina a cabeça na mesma direcção para avaliar. | *"Feng shui tropical. É uma escolha estética, não um erro estrutural."* |
| C13 | **Abrigo que Colapsa** | A cabana cai sobre ele com um puff de folhas. Fica um momento soterrado. Emerge devagar. Suspira. Recomeça. | *"A física. Minha velha inimiga."* |
| C14 | **Acender Fogueira** 🌙 | Esfrega dois paus com dedicação crescente. Sopra. Esfrega mais. A faísca aparece. Fica boquiaberto com o próprio sucesso. | *"Sou literalmente o Prometeu. Mas mais suado."* |
| C15 | **Fogueira que Apaga** 🌙 | Uma brisa mínima apaga a chama laboriosamente conquistada. Ele fica a olhar para o fumo com olhos mortos. | *"Claro. Naturalmente. Era de esperar. Tudo bem."* |
| C16 | **Recolher Lenha** ☀️ | Junta raminhos e galhos com entusiasmo doméstico. Faz uma pilha pequenina. Olha satisfeito. | *"Está tudo organizado. Tenho um sistema."* |
| C17 | **Esticar na Praia** ☀️ | Deita-se de barriga para cima na areia quente, braços abertos, como estrela do mar. Contente de forma estranha. | *"Piscina privada. Vista de mar. Hotel cinco estrelas. Menos o hotel."* |
| C18 | **Gravar no Tronco** | Entalha mais um dia no tronco da palmeira com uma pedra afiada. Conta os sulcos. Deixa de contar a meio. | *"Dia... muitos. Muitos dias. Não importa o número exactamente."* |
| C19 | **Olhar para as Nuvens** ☀️ | Deita-se de costas e olha para o céu, apontando para nuvens com o dedo como se identificasse formas. | *"Aquela é um barco. Aquela é um helicóptero. Aquela é o meu chefe. Detesto aquela nuvem."* |
| C20 | **Afiar Ferramenta** | Lixa uma pedra noutra pedra com movimentos metodicamente circulares. É hipnótico e inútil em simultâneo. | *"Uma ferramenta afiada é a diferença entre civilização e caos."* |
| C21 | **Beber Água da Chuva** ⚡ | Abre a boca para o céu durante a chuva com olhos fechados em êxtase. É simultaneamente patético e belo. | *"Evian. Definitivamente Evian. Nota a diferença."* |
| C22 | **Fazer Inventário** | Alinha os seus pertences na areia - uma pedra, um pauzinho, meia concha - e conta-os com seriedade empresarial. | *"Activos totais: consideráveis. O departamento financeiro está satisfeito."* |
| C23 | **Espiar o Horizonte de Joelhos** | Ajoelha-se na praia e olha para o horizonte com a mão em pala, como sentinela medieval. Por longos segundos. | *"Não. Não era nada. Era só o oceano. Como sempre."* |
| C24 | **Sacudir a Areia** | Sacode vigorosamente a areia da roupa, do cabelo, das orelhas. Tem areia em todo o lado. A ilha inteira é areia. | *"Já reparei que há areia. Há muita. É um padrão recorrente."* |
| C25 | **Pentear com Concha** | Usa uma concha como pente com grande seriedade. O resultado estético é questionável mas o processo é digno. | *"A apresentação pessoal mantém a moral. Li isso algures."* |
| C26 | **Fazer Flexões** ☀️ | Começa a fazer flexões com determinação militar. Ao terceiro para, ofegante. Declara vitória na mesma. | *"Físico de atleta. Estou claramente em forma."* |
| C27 | **Contar as Palmeiras** | Percorre a ilha contando as palmeiras com o dedo. Para, recomeça porque perdeu a conta. Resultado diferente cada vez. | *"Três. Não, quatro. Espera. Três? Hei, quem meteu esta aqui?"* |
| C28 | **Escrever na Areia** | Escreve lentamente "SOCORRO" em enormes letras na areia. Olha satisfeito. Uma onda apaga tudo. | *"Bem. Recomeçamos. É um trabalho contínuo."* |
| C29 | **Apagar e Reescrever** | Olha para o "SOCORRO" na areia, apaga com o pé, escreve "HELP". Apaga. Escreve "AU SECOURS". Suspira. | *"Talvez seja um barco francês. Tenho de cobrir todas as hipóteses."* |
| C30 | **Olhar para as Estrelas** 🌙 | Deita-se na praia e olha para o céu estrelado com boca aberta. Aponta constelações com o dedo trémulo. | *"Aquela é o Órion. Aquela é o Carro. Aquela... inventei uma nova. Chama-se o Náufrago."* |
| C31 | **Pôr-do-Sol Contemplativo** ☀️ | Senta-se na beira da água a ver o pôr-do-sol. Fica perfeitamente imóvel durante vários segundos. Um momento de paz genuína. | *"...isto é bonito. Lá isso é."* |
| C32 | **Nascer do Sol Bolorento** 🌙 | Acorda, boceja, olha para o nascer do sol. Faz que sim com a cabeça como se fosse uma reunião de trabalho. | *"Ok. Mais um dia. Anotado. Vamos lá."* |
| C33 | **Remar com Tronco** | Senta-se num tronco flutuante e tenta remar com as mãos. Roda em círculos. Volta à praia. | *"A navegação requer optimização. É um trabalho em progresso."* |
| C34 | **Fumar Folha Imaginária** 🌙 | Põe uma folha seca nos lábios como cigarro imaginário e olha para o horizonte com ar de detetive noir. | *"Tenho de parar com isto. Mas ainda não."* |
| C35 | **Sacudir Palmeira** | Abana a palmeira com força esperando cocos. Cai apenas uma folha. Olha para a folha. Olha para a palmeira. | *"Agradeço a colaboração. Muito generosa."* |
| C36 | **Comer Crua Rindo** | Encontra um caranguejo pequeno na praia. Considera-o. Decide que não. Põe-no de volta. | *"Hoje não. Talvez amanhã. Possivelmente nunca. Ficámos amigos."* |
| C37 | **Arrumar a Ilha** | Recolhe algas e detritos da praia com ar de dona de casa. Faz uma pilhinha. Analisa o resultado. | *"Ambiente arrumado, mente sã. Ou o contrário. Já não sei."* |
| C38 | **Fazer Inventário Emocional** | Senta-se, conta pelos dedos, murmura consigo mesmo em lista: algo positivo, algo negativo, algo neutro. | *"Prós: sol, coco, silêncio. Contras: tudo o resto."* |
| C39 | **Olhar para a Própria Sombra** ☀️ | Examina a sombra com fascínio como se fosse um estranho. Imita os movimentos dela. Ri sozinho. | *"Pelo menos a sombra não me abandona. Boa companhia, a sombra."* |
| C40 | **Construir Calendário na Areia** | Desenha uma grelha na areia e marca os dias com pedrinhas. Uma onda apaga. Recomeça um pouco mais para trás. | *"Organização temporal. É fundamental. Não estou de todo a perder o juízo."* |
| C41 | **Meditar à Beira-Mar** | Senta-se de pernas cruzadas na beira da água, olhos fechados, mãos nos joelhos. O vento desfaz o cabelo. | *"Mmmm. Paz interior. Mmm. Fome interior também. Mas sobretudo paz."* |
| C42 | **Apanhar Sol de Costas** ☀️ | Deita-se de barriga para baixo, cabeça nos braços, nas costas ao sol. Ronrona quase. | *"Bronzeado de náufrago. Muito procurado nas praias de Cascais."* |
| C43 | **Espantar Mosquitos** 🌙 | Acena os braços freneticamente no escuro da noite combatendo inimigos invisíveis. Guerra sem fim. | *"São cinco. Não, seis. Há mais. São infinitos. SÃO INFINITOS."* |
| C44 | **Construir Armadilha de Pássaros** | Constrói cuidadosamente uma armadilha com um pauzinho, uma pedra e uma folha. Senta-se à espera. Nada. | *"A paciência é a virtude máxima. Ainda não estou preocupado."* |
| C45 | **Falar com Peixe na Água** | Debruça-se sobre a água e fala com os peixinhos que passam. Faz gestos. Parece uma reunião. | *"Ouçam, rapazes. Precisamos de chegar a um acordo mutuamente benéfico."* |
| C46 | **Dormir de Lado** 🌙 | Está enrolado em posição fetal na areia, usando o braço como almofada. A lua brilha sobre ele. Quieto e pequeno. | *[sem frase - dorme em paz por uma vez]* |
| C47 | **Acenos Desnecessários** | Um pássaro passa. O náufrago acena entusiasmado. O pássaro ignora. O náufrago baixa o braço devagar. | *"Ok. Muito bem. Voo com saúde."* |
| C48 | **Fazer Sinal de Fumo** | Atira folhas verdes na fogueira produzindo fumo espesso. Olha para o fumo. Olha para o céu vazio. Mais fumo. | *"É só questão de alguém estar a ver. Alguém deve estar a ver."* |
| C49 | **Afinar Voz** | Faz escalas vocais sozinho - dó ré mi - como aquecimento para uma actuação que nunca virá. | *"A voz é um músculo. Cuido dela para quando encontrar alguém."* |
| C50 | **Debater Consigo** | Faz um argumento, muda de lado, contra-argumenta, fica irritado consigo mesmo, resolve, fica satisfeito. | *"Exactamente. Concordo. - Não concordo. - Tens razão. - Obrigado."* |
| C51 | **Apanhar Chuva com Concha** ⚡ | Corre pela chuva com conchas e folhas a fazer de recipientes, tentando recolher água. Alegria caótica. | *"Sistema de recolha de água pluvial. Aprovado pelo Engenheiro Chefe. Que sou eu."* |
| C52 | **Treinar Discurso de Resgate** | Ensaia um discurso de agradecimento ao resgate, com gestos, pausas dramáticas, lágrimas controladas. | *"Quero agradecer... em primeiro lugar... ao oceano, por... não, isto não está certo."* |
| C53 | **Limpar os Dentes com Ramo** ☀️ | Usa um ramo de árvore como escova de dentes com seriedade odontológica. Examina os dentes na água. | *"Higiene oral. A fronteira entre humanidade e selvajaria."* |
| C54 | **Cozinhar Peixe na Pedra** ☀️ | Coloca um peixe minúsculo numa pedra quente ao sol e espera que coza. Metodicamente. Otimistamente. | *"Solar cooking. É sustentável. Sou sustentável."* |
| C55 | **Atirar Pedra à Água** | Atira pedras ao oceano, uma a uma, com expressão crescentemente niilista. Contabiliza os ressaltos. | *"Sete ressaltos. Recorde pessoal. Que ninguém testemunhou. Irrelevante."* |
| C56 | **Procurar Conchas** ☀️ | Vasculha a praia de joelhos à procura de conchas, seleccionando com critérios obscuros. Descarta as "erradas". | *"Esta tem boa vibração. Aquela não. É intuitivo."* |
| C57 | **Ouvir o Vento** | Para tudo o que está a fazer e inclina a cabeça, escutando o vento. Parece perceber algo. Continua a vida. | *"O vento diz coisas. A maioria não é animadora."* |
| C58 | **Dar Nomes às Pedras** | Alinha pedras e dá-lhes nomes, apresentando-as umas às outras com toda a seriedade cerimonial. | *"Este é o Pedro. Aquela é a Maria. Sejam felizes. É uma ilha pequena mas há espaço."* |
| C59 | **Reparar no Caranguejo** | Um caranguejo passa. O náufrago segue-o com os olhos por toda a praia. Troca um olhar grave com o crustáceo. | *"Tu e eu sabemos como é. Não precisamos de palavras."* |
| C60 | **Treinar Corrida** | Corre de uma ponta à outra da ilha em linha recta - 8 passos - com a seriedade de atleta olímpico. | *"Velocidade de ponta: razoável. Distância disponível: insuficiente."* |
| C61 | **Filosofia do Coco** | Segura um coco aberto, olha-o, vira-o, pondera. Faz um gesto de "e pronto" e come. | *"O coco é metáfora. Duro por fora, mas... também duro por dentro. Hmm."* |
| C62 | **Fazer Sombras na Parede** 🌙 | Junto à fogueira, faz sombras na palmeira com as mãos - pato, coelho, cão. Ri para as sombras. | *"Teatro de sombras. Preço de entrada: nada. Bilheteira: inexistente."* |
| C63 | **Espreguiçar Dramático** | Espreguiça-se de forma absolutamente épica - braços, pernas, coluna, pescoço, tudo. Produz sons. | *"O corpo é um templo. Um templo que precisa de uma boa espreguiçada."* |
| C64 | **Nadar Junto à Costa** ☀️ | Entra na água até aos joelhos, mergulha, nada um bocado, sai. Esfrega a água dos olhos com dignidade. | *"Banho de mar. Grátis. Ilimitado. Literalmente inescapável."* |
| C65 | **Bocejo Monumental** | Para tudo o que está a fazer, abre a boca numa das maiores bocejadas já registadas em pixel art. | *"Desculpem. Não há desculpa. Mas desculpem na mesma."* |
| C66 | **Raspar Areia dos Pés** | Senta-se a raspar areia dos pés meticulosamente. Imediatamente pisa areia outra vez. Olha para baixo. | *"Sísifo. Sou claramente Sísifo. Mas com pés."* |
| C67 | **Inspecção de Território** | Percorre a ilha com as mãos atrás das costas, inclinado para a frente, como inspector de saúde. | *"Território seguro. Pragas: nenhuma. Recursos: escassos. Relatório: desolador."* |
| C68 | **Escultura de Areia** ☀️ | Constrói uma figura na areia - humana, animal, ambígua. Afasta-se para apreciar o trabalho. Orgulhoso. | *"Arte é expressão da condição humana. Isto expressa muito bem a minha."* |
| C69 | **Acordar Assustado** 🌙 | Salta de sono por causa de um som imaginário, olha à volta em pânico total, percebe que é tudo igual. Volta a deitar. | *"...foi um peixe. Era um peixe. Tudo bem. Dormir. Agora."* |
| C70 | **Lançar Garrafa (Sem Mensagem)** | Tem uma garrafa. Não tem papel. Atira a garrafa ao mar vazia. Vê-a ir. Vê-a voltar com a maré. | *"Voltou. Bem. É um projecto a longo prazo."* |

---

## 🔵 RARO - Acontecimentos da Semana
*1-2 vezes por semana. Algo diferente na monotonia.*

| # | Nome Curto | Descrição da Animação | Frase do Náufrago |
|---|---|---|---|
| R01 | **Barco no Horizonte** | Um ponto minúsculo aparece no horizonte. O náufrago agita os braços com toda a energia. O ponto desaparece. Pausa longa. | *"Era um barco. Era definitivamente um barco. Ou uma baleia. Ou uma pedra. Ou o meu desespero materializado."* |
| R02 | **Avião Que Passa** ☀️ | Um avião risca o céu ao longe com um rasto branco. O náufrago corre para a praia, acena, grita. O avião continua. | *"Aquele avião vai para Lisboa. Eu sei. Eu deveria estar lá dentro."* |
| R03 | **Tartaruga na Praia** | Uma tartaruga-marinha arrasta-se lentamente pela areia. O náufrago segue-a reverentemente a uma distância respeitosa. | *"Sabedoria anciã. Viajante de oceanos. Não tem internet, como eu. Temos muito em comum."* |
| R04 | **Tempestade Repentina** ⚡ | Nuvens negras acumulam-se rapidamente. O náufrago corre a salvar o inventário antes do aguaceiro. Molha-se na mesma. | *"SISTEMA DE ALERTA ANTECIPADO: FALHOU. Anoto para acta."* |
| R05 | **Estrela Cadente** 🌙 | Uma estrela risca o céu nocturno. O náufrago fecha os olhos, junta as mãos, faz um pedido com intensidade máxima. | *"...e que traga comida. Muita. E pessoas. E pizza. Sobretudo pizza."* |
| R06 | **Mensagem na Garrafa Recebida** | Uma garrafa aparece na maré. O náufrago mergulha pela garrafa. Dentro está... areia. Ou alga. Suspiro cósmico. | *"Alguém enviou areia. Em garrafa. Artisticamente, é interessante. Humanamente, é cruel."* |
| R07 | **Visita do Golfinho** | Um golfinho salta ao largo. O náufrago corre para a água, grita para o golfinho, o golfinho salta outra vez e vai embora. | *"Passou, viu, saltou, foi-se embora. Como toda a gente."* |
| R08 | **Borboleta Perdida** | Uma borboleta enorme aterra no nariz do náufrago. Ele fica completamente imóvel. Ela vai-se embora. Ele chora uma lágrima. | *"Obrigado pela visita. Podes voltar quando quiseres. Tenho sempre coco."* |
| R09 | **Pesca Sortuda** | Pesca um peixe grandíssimo - para os padrões da ilha. Dança de vitória elaborada e privada. Come como rei. | *"BANQUETE. Isto é um BANQUETE. Categoricamente um banquete."* |
| R10 | **Encontrar Objecto na Praia** | Vê algo brilhar na areia - talvez uma lata, rolha ou fragmento de plástico. Examina-o como arqueólogo. | *"Civilização. O cheiro da civilização. Alguém, algures, abriu uma coca-cola."* |
| R11 | **Flutuar de Costas** ☀️ | Flutua de costas no mar tranquilo, braços abertos, olhos para o céu. Completamente em paz por uns segundos. | *"É quase bom. Quase. Falta muito para bom mas está mesmo perto de quase."* |
| R12 | **Arco-Íris** ⚡ | Surge um arco-íris depois da chuva. O náufrago aponta para ele, corre até à ponta dele (na água), decepcionado. | *"Não havia pote de ouro. Tinha esperança. Era irracional. Valeu a tentativa."* |
| R13 | **Naufrágio de Pequenas Esperanças** | Constrói uma jangada mínima de paus e folhas. Bota-a ao mar. Afunda em 3 segundos. Vê-a afundar. | *"Fase um: concluída. Fase dois: revisão completa do conceito."* |
| R14 | **Pôr-do-Sol Cor-de-Rosa** ☀️ | O céu fica de um cor-de-rosa impossível. O náufrago para tudo, boca aberta, absorto. Um momento de beleza genuína. | *"...não tenho palavras. Isso é bom ou mau para um escritor náufrago?"* |
| R15 | **Medir a Ilha** | Com passos cuidadosos, mede a ilha em todas as direcções. Anota os resultados com um pau na areia. Testa diferentes rotas. | *"Perímetro: 34 passos. Ou 36. Depende da maré. É uma ilha dinâmica."* |
| R16 | **Ensaiar Reencontro** | Pratica o reencontro com a família - abraços, conversas, o que vai dizer. Fica emocionado a sós no ensaio. | *"E então digo: 'Saudades, mas aprendi muito.' E abraço toda a gente. Toda."* |
| R17 | **Lua Cheia** 🌙 | A lua cheia ilumina a ilha como um holofote. O náufrago fica de pé a olhar para ela como lobisomem pensativo. | *"Lua cheia. Noutro tempo, isto era romântico. Agora é só... muito brilhante."* |
| R18 | **Canção Inventada** | Inventa e canta uma música sobre a sua situação - melodia razoável, letra autobiográfica, ritmo irregular. | *"♪ Tenho um coco e uma palmeiraaa / e o oceano todinho pra mim... ♪ Falta trabalho na letra."* |
| R19 | **Sinal de SOS nas Pedras** | Arruma pedras grandes em SOS na praia. Muito meticuloso. Muito simétrico. Onda apaga metade. Recomeça impassível. | *"Persistência. É a chave de tudo. Li isso numa moldura motivacional. Que afundou."* |
| R20 | **Manequim de Palha** | Constrói uma figura humanóide com ervas e galhos e fala com ela como colega de trabalho. Com profissionalismo. | *"Bom dia. Reunião a seguir ao almoço. Coco como sempre. Agenda densa."* |
| R21 | **Observar Formigas** | Deita-se de barriga e observa formigas com atenção de e

... [OUTPUT TRUNCATED - 4,803 chars omitted out of 54,731 total] ...

 ele. Ficam lado a lado a olhar para o mar. Uma camaradagem estranha e real. | *"Tu e eu. Guardas do horizonte. É uma profissão com futuro limitado."* |
| R43 | **Horizonte Cor de Sangue** ☀️ | O pôr-do-sol fica vermelho-vivo. O náufrago fica tenso - é bonito mas também levemente ominoso. | *"Céu vermelho ao serão... o que é que o ditado diz? Que é bom para quem está num barco, presumo."* |
| R44 | **Explorar Lado Desconhecido** | Vai ao lado da ilha que nunca explorou (3 passos mais à frente). Encontra... mais praia. Fica igualmente surpreendido. | *"Terra incógnita. Literalmente igual a todo o resto. Mas incógnita na mesma."* |
| R45 | **Ensaiar Discurso de Culpa** | Pratica o que vai dizer quando chegar a casa - as desculpas, as explicações, o "não foi culpa minha". Muito detalhado. | *"E então digo que o barco afundou. E eles dizem que não havia barco. E eu digo... hm. Problema."* |
| R46 | **Jogar ao Berlinde** | Joga berlinde sozinho - atira pedrinhas, tenta acertar em outras pedrinhas, marca pontos numa tabela na areia. | *"Vencedor: eu. Perdedor: também eu. Prémio: coco. Que já era meu."* |
| R47 | **Escrever Diário em Voz Alta** | Narra o seu dia para nenhum ouvinte, como se ditasse para uma secretária. Com datas, observações, conclusões. | *"Dia sem número. Comi coco. Pesquei mal. Contemplei. Repeti. Fim. Assino: eu."* |
| R48 | **Reunião de Emergência** | Convoca uma "reunião" com as pedras-nomeadas, apresenta o problema da situação, pede sugestões. Pausa. Não há sugestões. | *"Nenhuma ideia da mesa? Ok. Passamos ao ponto seguinte. Que é idêntico."* |
| R49 | **Bússola de Concha** | Tenta construir uma bússola com uma concha e uma gota de água. Funciona? Não sabe. Confia nela na mesma. | *"Norte. Estou a apontar para norte. O que significa que... há mais oceano ao norte. Excelente."* |
| R50 | **Fingir Que Está Bem** | Compõe-se, limpa-se, endireita-se, faz uma expressão positiva - como se alguém estivesse a olhar. Sorri. | *"Estou óptimo. Tudo a correr lindamente. Esta é a minha face de bem-estar."* |
| R51 | **Engraxar Sapatos Inexistentes** | Limpa e "engraxa" os pés descalços como se fossem sapatos. Com toda a seriedade do mundo. | *"Apresentação profissional. Primeira impressão não se repete. Diz quem nunca foi náufrago."* |
| R52 | **Tirar Fotografia Imaginária** | Faz uma moldura com os dedos, enquadra a paisagem, faz o som de obturador com a boca. Analisa o resultado invisível. | *"Esta vai para o Instagram quando tiver internet. Que pode demorar."* |
| R53 | **Teorias da Conspiração** | Começa a desenvolver uma teoria elaborada sobre como chegou aqui. Gestos, nós de narrativa, suspeitos. | *"Não foi acidente. Foi planeado. O cozinheiro do barco. Tinha cara de conspirador."* |
| R54 | **Culinária Experimental** | Combina coco, algas e peixinho numa "receita" que analisa criticamente depois de comer. | *"Notas: salgado em excesso, textura complexa, emplatamento a melhorar. Voltaria? Não tenho escolha."* |
| R55 | **Percurso de Obstáculos** | Dispõe pedras, galhos e conchas pela ilha e corre o percurso de obstáculos com cronômetro imaginário. | *"Tempo: excelente. Categoria: sobrevivência avançada. Juiz: eu. Resultado: aprovado."* |
| R56 | **Estudo das Marés** | Com uma vareta, marca o nível da água a cada hora. Anota conclusões na areia. Constrói teoria das marés. | *"Conclusão: a maré sobe e depois desce. É uma descoberta com implicações."* |
| R57 | **Cantarolar Sem Parar** ☀️ | Cantarola indefinidamente enquanto faz tarefas - pesca, arruma, constrói. A melodia muda mas não para nunca. | *"♪ Mmm-mm-mm cocooo, mm-mm-mm solidãooo... ♪ É uma obra em progresso."* |
| R58 | **Encontrar Ninho** | Descobre um ninho de ave na palmeira. Espia com cuidado máximo. Fica encantado. Guarda segredo. | *"Tenho vizinhos. Inquilinos, tecnicamente. Não lhes cobro renda. Sou um senhorio razoável."* |
| R59 | **Jogo do Encalhado** 🌙 | À noite, faz sombras na areia com as mãos e encena uma saga épica sobre o seu próprio resgate. Com vilões. | *"E então o herói - que sou eu - chega a casa e pede uma francesinha. FIM."* |
| R60 | **Inventar Palavra Nova** | Para subitamente, aponta o dedo para o ar, e declara que inventou uma palavra para algo para o qual não existe palavra. | *"'Cocamelancolia'. A tristeza específica de comer o décimo coco do dia. Registo para posteridade."* |

---

## 🟠 MUITO_RARO - O Que Muda o Dia
*Aproximadamente uma vez por mês. Algo para recordar.*

| # | Nome Curto | Descrição da Animação | Frase do Náufrago |
|---|---|---|---|
| MR01 | **Navio Que Para!** | Um navio para no horizonte. O náufrago entra em modo frenético - fogo, fumo, acenos, gritos. O navio recomeça. Partiu. Silêncio. | *"Viu-me. Juro que viu. Hesitou. Decidiu que não. Compreendo-o. Talvez até concordo."* |
| MR02 | **Baleia à Superfície** | Uma baleia emerge ao largo de forma majestosa. Ressoprando. O náufrago fica imóvel em admiração absoluta por longos segundos. | *"...não tenho palavras adequadas. E sou a única pessoa no mundo a ver isto agora. É perfeito e insuportável."* |
| MR03 | **Ilha Vizinha Avistada** | A névoa abre e revela uma ilha ao longe. Nunca estava lá. Ou estava e nunca viu. O náufrago fica paralisado. | *"Uma ilha. Outra ilha. Com pessoas? Com cocos diferentes? COM ALGUÉM?"* |
| MR04 | **Objecto Inexplicável** | Aparece na praia um objecto completamente fora de contexto - um chapéu, um sapato único, um brinquedo de criança. | *"Um sapato. Tamanho 42. Esquerdo. Há alguém descalço de um pé algures. Identifico-me."* |
| MR05 | **Memória Intensa** | Para de repente e fica com expressão distante. Flash de memória - casa, família, comida quente. Volta a si. Os olhos brilham. | *"...o cheiro do café de manhã. A luz da cozinha. Porquê é que me lembro agora disso."* |
| MR06 | **Construir Mascote Wilson** | Constrói um rosto numa pedra, coco ou concha grande. Apresenta-se formalmente. Dá-lhe um nome. Começa a tratá-la por tu. | *"Olá. Eu sou o António. Tu és... o Wilson. Ou o Rui. O Rui parece-me melhor para ti."* |
| MR07 | **Tremer de Saudade** | Senta-se, abraça os próprios joelhos, e fica assim durante um tempo longo. Não há comédia neste evento. Apenas humanidade. | *"...quero ir para casa."* |
| MR08 | **Ilusão de Barco** | Vê claramente um barco no horizonte. Corre, acena, grita. O "barco" é uma formação de nuvens. Fica devastado. | *"Foi real. Foi absolutamente real. A mente não inventaria algo assim. A mente é capaz de tudo."* |
| MR09 | **Garrafa com Mensagem Real** | Uma garrafa chega com algo dentro - um papel. O náufrago lê com mãos a tremer. É um recibo de restaurante. Fica em silêncio. | *"Restaurante Beira-Rio. Mesa para dois. Entrada: ameijoas. Deus, as ameijoas."* |
| MR10 | **Prova de Civilização** | Uma lata de refrigerante vazia aparece na praia. O náufrago examina-a, cheira-a, abraça-a. Guarda-a como tesouro. | *"Fabricada a 200 quilómetros daqui. Provavelmente. Há pessoas a 200 quilómetros. Há pessoas."* |
| MR11 | **Manta Raia à Superfície** | Uma manta raia enorme passa debaixo da água transparente. Vasta, elegante, impossível. O náufrago segue-a com os olhos. | *"É uma criatura de outro mundo. Estamos os dois perdidos no mesmo oceano."* |
| MR12 | **Ler as Estrelas** 🌙 | Com um pau como sextante improvisado, tenta determinar a sua posição pelo céu. Com mapas estelares desenhados na areia. | *"Estou... aqui. Na Terra. No hemisfério... algum. A precisão melhora com prática."* |
| MR13 | **Festa de Aniversário** | Declara que é o seu aniversário (pode não ser). Decora a ilha com folhas, canta parabéns, sopra uma concha como vela. | *"Parabéns a mim. Com toda a sinceridade do mundo. Quantos anos? Muitos. Suficientes."* |
| MR14 | **Coral de Pássaros** 🌙 | À noite, os pássaros da ilha fazem um barulho colectivo ensurdecedor. O náufrago escuta como se fosse ópera. | *"Temporada de ópera. Lugar na fila da frente. Já paguei em sofrimento suficiente."* |
| MR15 | **Escrever Romance** | Começa a escrever na areia um romance autobiográfico. Capítulo 1: cheio de acção. Capítulo 2: começa a divagar. | *"Capítulo um: o barco afundou. Capítulo dois: o oceano é grande. Besteller garante-se."* |
| MR16 | **Cerimónia do Coco de Ouro** | Encontra um coco especialmente bom. Eleva-o solenemente. Faz um discurso. Come-o com reverência ritual. | *"Este coco... é o escolhido. Não sei bem para quê. Mas o destino era claro."* |
| MR17 | **Tartaruga Gigante** | Uma tartaruga-de-couro - enorme, pré-histórica - emerge perto da praia. O náufrago fica de joelhos em reverência. | *"Duzentos anos. Duzentos anos a nadar. Antes da minha avó nascer. É mais velho que o meu país."* |
| MR18 | **Descobrir Gruta** | Descobre uma pequena gruta ou fissura na rocha que nunca viu. Espia lá para dentro. Entra. É pequena. Sai. Satisfeito. | *"Descoberta geográfica. Enrico o Navegador teria ficado impressionado. Provavelmente."* |
| MR19 | **Diálogo com Wilson** | Longa conversa animada com a mascote-pedra sobre filosofia, vida, planos para o futuro. Ambos os lados da conversa. | *"Discordo, Rui. A existência precede a essência. - 'Mas a solidão precede ambas.' - Tens razão. Detesto quando tens razão."* |
| MR20 | **Cheiro a Terra** | Um vento forte traz um cheiro diferente - ervas, terra húmida, coisas que crescem. Fica imóvel a cheirá-lo com olhos fechados. | *"Terra. Cheira a terra. Há terra perto. Há terra algures. Ainda há terra."* |
| MR21 | **Iluminação Filosófica** | Está a fazer algo mundano e para. Olho arregalado. Gesto de eureka. Longa pausa. Volta ao que estava a fazer como se nada. | *"Percebi. Percebi tudo. A vida, o universo, a resposta. Era... era... já não me lembro. Estava certo, porém."* |
| MR22 | **Brincadeira com Polvo** | Um polvo volta. O náufrago joga ao jogo da pedrinha com ele. O polvo apanha. O náufrago fica genuinamente impressionado. | *"Este é diferente. Este tem futuro. Vou recomendar-te para um cargo de gestão."* |
| MR23 | **Nuvem em Forma de Casa** ☀️ | Uma nuvem tem claramente a forma de uma casa. O náufrago segue-a pelo céu até se desfazer. Despede-se. | *"A minha casa era assim. Ligeiramente. Com mais paredes. E sem correntes de ar tão marcadas."* |
| MR24 | **Encontrar Anzol** | Encontra um anzol de pesca na praia. Segura-o como jóia medieval. Beija-o. É o melhor dia em semanas. | *"Um anzol. De aço. Feito por seres humanos. Um portador de civilização em formato miniatura."* |
| MR25 | **Chuva de Estrelas** 🌙 | Uma chuva de meteoros ilumina o céu durante minutos. O náufrago senta-se e vê com boca aberta. Palmas. Lágrimas. | *"Espectáculo do universo. Lugar exclusivo. Um único espectador. Não sei se é privilégio ou punição."* |
| MR26 | **Jangada 2.0** | Reconstrói a jangada com melhorias estruturais. Bota-a ao mar. Flutua 5 metros. Afunda. Fica satisfeito com o progresso. | *"Cinco metros. Eram zero. É um progresso de 500%. A engenharia é uma ciência cumulativa."* |
| MR27 | **Carta de Amor** | Escreve uma carta de amor longa na areia para alguém que ficou em terra. Sente cada palavra. A maré leva tudo suavemente. | *"...não sei se chegas a ler isto. Mas o oceano sabe. E o oceano vai a todo o lado."* |
| MR28 | **Encontrar Rádio Partido** | Encontra um rádio velho, oxidado, completamente morto. Tenta ligá-lo durante horas. Pressiona botões. Dança ao estático. | *"Ruído branco! TENHO RUÍDO BRANCO! ESTOU EM CONTACTO COM O UNIVERSO DA ELECTRÓNICA!"* |
| MR29 | **Testemunha de Tempestade** ⚡ 🌙 | Uma tempestade elétrica ao longe - relâmpagos sem chuva. O náufrago vê o espectáculo de longe, seguro na ilha. | *"Teatro da natureza. Bilhete grátis. Vista privilegiada. Pipocas: não disponíveis. Tragédia."* |
| MR30 | **Missão de Alto Risco** | Nada até uma rocha ao largo, sobe, planta uma bandeira de folha, declama algo épico, volta nadando. Satisfeito. | *"Território reivindicado em nome da República Individual do António. Está registado. Mentalmente."* |
| MR31 | **Colecção de Tesouros** | Arruma todos os seus "tesouros" encontrados - lata, anzol, concha especial, pedra - e faz inventário formal com gestos de leilão. | *"Lote um: concha em espiral com potencial estético. Lote dois: anzol de valor inestimável. Base: um coco."* |
| MR32 | **Descobrir Pegadas de Animal Grande** | Encontra pegadas na areia de algo maior do que o habitual. Segue-as. Perdem-se no mar. Fica a olhar para as ondas. | *"Algo grande. Passou aqui. Durante a noite. Não sei se me alegro ou me preocupo. Provavelmente ambos."* |
| MR33 | **Constelação Inventada** 🌙 | Liga estrelas no céu com o dedo inventando constelações novas e contando a sua história como mitologia pessoal. | *"A Constelação do Anzol. A Constelação da Jangada Que Afundou. A Constelação do Coco de Segunda. Elas ficam para sempre."* |
| MR34 | **Fazer Aniversário ao Wilson** | Celebra o aniversário da mascote-pedra com um bolo imaginário, parabéns, discurso de homenagem e coco de festa. | *"Um ano de amizade, Rui. Nunca me deixes. Tens feito um trabalho extraordinário a ficar quieto."* |
| MR35 | **Erupção de Felicidade Inexplicável** | Sem motivo aparente, o náufrago começa a rir, salta, corre, faz acrobacias. A alegria absurda dura 20 segundos. Volta ao normal. | *"Não sei. Não sei porquê. Mas por um segundo foi completamente hilariante existir."* |
| MR36 | **Mapa do Tesouro** | Desenha um elaborado mapa do tesouro da ilha (que não tem tesouro) com X a marcar o local. Segue o mapa. Encontra areia. | *"X marcava o local. O local era areia. O tesouro era a viagem. Já tinha ouvido isto antes."* |
| MR37 | **Pôr-do-Sol Verde** ☀️ | O raio verde - fenómeno óptico real - aparece no momento exacto em que o sol toca o horizonte. Um segundo de magia. | *"...o raio verde. Vi o raio verde. Dizem que quem o vê tem um desejo concedido. BARCO. Pensei logo em barco."* |
| MR38 | **Aprender com as Aves** | Passa horas a observar e imitar o comportamento das aves da ilha - voo, pesca, comunicação. Com caderno imaginário. | *"As fragatas não pousam na água. Não sabem nadar. Somos mais parecidos do que parece."* |
| MR39 | **Sessão de Psicoterapia** | Divide-se em terapeuta e paciente. Faz perguntas difíceis a si mesmo. Responde honestamente. O terapeuta faz silêncio incómodo. | *"- Como te sentes? - Mal. - E antes? - Melhor. - Então? - Então nada, é que está tudo horrível."* |
| MR40 | **Nublar Total** ⚡ | As nuvens cobrem tudo durante horas. A ilha fica cinzenta. O náufrago trabalha em modo semi-automático, calado. | *"Hoje o céu também não apareceu. Solidariedade climática. Apreço a solidariedade em qualquer formato."* |
| MR41 | **Inventar Dinheiro** | Atribui valores a diferentes conchas como sistema monetário. Faz transacções consigo mesmo. Declara-se milionário. | *"Sou o homem mais rico da ilha. É uma distinção com pouca concorrência mas ainda assim."* |
| MR42 | **Telescópio de Bambu** | Constrói um telescópio com canas. Não funciona opticamente. Olha pelo mesmo com grande seriedade e relata o que "vê". | *"Barcos ao longe. Cidades. Cafés com esplanada. Talvez esteja a inventar. Provavelmente."* |
| MR43 | **Cerimónia de Graduação** | Faz uma toga de folhas de palmeira, declara-se doutorado em Sobrevivência Insular, discursa, entrega diploma (concha) a si mesmo. | *"Pela presente, confiro o título de Doutor em Existência Adversa. Com distinção. Por unanimidade. De mim."* |
| MR44 | **Meditar no Centro da Ilha** | Senta-se no centro geométrico exacto da ilha (calculado com método duvidoso) e medita em silêncio absoluto durante um tempo longo. | *"...o centro. Estou no centro. De quê, exactamente? Da ilha? Do oceano? Da questão existencial? Sim."* |
| MR45 | **Cerimónia do Fogo** 🌙 | Celebra uma fogueira especialmente boa com dança ritualística à volta dela, braços abertos, figura de bruxa de Hallowe'en alegre. | *"Fogo! Fogo conseguido! O Prometeu da ilha tropical saúda os deuses do betão armado e do Wi-Fi!"* |
| MR46 | **Dicionário de Termos Novos** | Passa a tarde a inventar vocabulário para conceitos náufrago-específicos que o português não cobre. Escreve tudo na areia. | *"'Cocamelancolia'. 'Horizontismo'. 'Peixofobia progressiva'. 'Palmeirite crónica'. A língua enriquece-se."* |
| MR47 | **Dieta de Algas** | Experimenta cada tipo de alga da praia cientificamente. Regista resultados. Alguns resultados são melhores do que outros. | *"Alga verde: passável. Alga castanha: questionável. Alga roxa: não. Definitivamente não."* |
| MR48 | **Ópera Improvisada** 🌙 | Canta uma ópera completa sobre a própria vida em voz de tenor dramático, com ária, recitativo e finale. Para as estrelas. | *"♪ E o náufrago... chorou... no oceano vaaastooo... comeu cocooo... e sobreviveeuuu...♪ Bravíssimo. De mim."* |
| MR49 | **Encontrar Vidro Fosco** | Encontra vidro marítimo polido pelas ondas. Olha através dele. Tudo fica cor-de-laranja. Fica assim um tempo. | *"Mundo cor-de-laranja. Acho que prefiro. É menos desolador do que o azul."* |
| MR50 | **Fazer as Pazes com o Oceano** | Vai à beira-mar, faz uma vénia formal, discursa em tom diplomático, estende a mão. Olha para a mão. O oceano não aperta. | *"Proposta de armistício: manténs-me vivo, eu paro de te praguejar. Consideramos o acordo aceite por omissão."* |

---

## 🔴 LENDÁRIO - O Que Pode Nunca Acontecer
*Peso mínimo no sistema. O jogador pode nunca ver. Ou ver uma vez e nunca esquecer.*

| # | Nome Curto | Descrição da Animação | Frase do Náufrago |
|---|---|---|---|
| L01 | **O Resgate Falso** | Um barco aproxima-se, para, solta um bote. O náufrago chora de alegria. O bote traz... um turista que tira uma foto e vai embora. | *"Uma fotografia. Tirou uma fotografia. Serei um meme. Serei um meme viral. Tudo tem um propósito."* |
| L02 | **A Mensagem de Volta** | Envia uma garrafa com mensagem. Meses depois aparece uma garrafa com resposta. É real. É de alguém. É uma piada de mau gosto. | *"'Boa sorte, amigo.' Boa sorte. BOA SORTE. Que pessoa maravilhosa. Detestava-o mas agradeço-lhe."* |
| L03 | **Tsunami em Miniatura** ⚡ | Uma onda anormalmente grande varre a praia. O náufrago agarra-se à palmeira. A ilha sobrevive. Ele sobrevive. Tudo igual. | *"...isso aconteceu. Anotei para o relatório de incidentes. Que ninguém vai ler. Mas existe."* |
| L04 | **O Submarino** | Um submarino emerge à superfície a 50 metros. O náufrago nada até ele a todo o gás. O submarino submerge antes que chegue. | *"Um submarino. Real. Metálico. Militar. Com pessoas dentro. Que não me viram. Ou viram e foram embora. Ambas as hipóteses são piores uma que a outra."* |
| L05 | **Wilson Parte** | A pedra-mascote cai ao mar numa maré alta. O náufrago corre, entra na água, grita o nome. A pedra afunda. Pausa. Pausa longa. | *"...RRUUUIIII! Rui! RUUUIII! ... Adeus, Rui. Foste... foste o melhor amigo que uma pedra poderia ser."* |
| L06 | **Trovão Sem Chuva** ⚡ | Relâmpago atinge a palmeira. Fulmina. Silêncio ensurdecedor. Depois a palmeira recomeça a ser palmeira. O náufrago não pisca. | *"...ok. A ilha tem pára-raios. Não escolhi, mas aprovo."* |
| L07 | **A Televisão Que Aparece** | Aparece na praia uma televisão completamente queimada, sem ecrã. O náufrago senta-se à frente e finge ver durante 10 minutos. | *"Notícias das 20h. O mundo continua. Presumo. Isto é um jogo de suposições mas aprecia-se a rotina."* |
| L08 | **O Barco Que Para MESMO** | Um barco para, um bote desce, alguém vem até à praia. Fica à distância. Deixa uma caixa. Parte sem falar. A caixa tem arroz. | *"Arroz. Cru. Branco. Lindo. Serei que chorei? Deixa-me verificar. Sim. Chorei muito. O arroz merecia."* |
| L09 | **O Avião Que Baixa** | Um avião pequeno faz uma passagem baixa sobre a ilha. O piloto acena? Ou são turbulências? Repetem a passagem. Partem. | *"Viram-me. Sei que viram. Talvez não contem. Talvez contem a alguém que não liga. Está registado no cosmos."* |
| L10 | **Visita Inexplicável** | Uma canoa primitiva com figuras indistintas para ao largo. Olham para ele. Ele olha para eles. Partem sem comunicar nada. | *"...existem outros. Noutra ilha. A olhar para mim como se eu fosse o estranho. Tecnicamente, ambos."* |
| L11 | **Fogo na Água** ⚡ | Bioluminescência intensa à noite - o mar brilha azul-elétrico com cada onda. O náufrago fica joelhos no chão. | *"O oceano está a brilhar. O oceano. A brilhar. Nunca mais vou conseguir explicar isto a ninguém. Tudo bem. Sei eu que vi."* |
| L12 | **O Segundo Náufrago** | Uma figura humana emerge das ondas. Dois náufragos na mesma ilha. Ficam a olhar um para o outro. Pausa infinita. | *"Olá. Tens... tens nome? - Tens coco? - Tenho os dois. Sentemo-nos. Temos tempo."* |
| L13 | **Sereia (Dugongo)** 🌙 | À lua cheia, um dugongo emerge nas águas rasas. Na penumbra, a silhueta é humanamente ambígua. O náufrago não tem a certeza do que viu. | *"Vi... algo. Não era peixe. Não era humano. Era... o oceano a brincar comigo. Como sempre. Mas de forma mais elaborada."* |
| L14 | **O Manuscrito** | Aparece na praia uma garrafa com um manuscrito longo - alguém escreveu um diário. O náufrago lê na praia durante horas. Há outra pessoa como ele. | *"Páginas. Alguém escreveu páginas. Sobre o mar, a solidão, o coco maldito. Não estou sozinho na loucura. Estou consolado."* |
| L15 | **Eclipse** ☀️ | Um eclipse total cobre o sol. A ilha mergulha no escuro de dia. O náufrago fica de pé no escuro, em silêncio absoluto. | *"Apagaram o sol. Apagaram mesmo o sol. Passou. Ok. Já passou. Bem. Era necessário claramente."* |
| L16 | **Chuva de Peixes** ⚡ | Acontece uma tromba de água ao largo que aspira peixes - alguns caem na ilha. O náufrago está no meio de peixes a cair do céu. | *"...peixes. Do céu. Chovem peixes. CHOVEM PEIXES! Não é tempo de perguntas, é tempo de caçar!"* |
| L17 | **O Gato** | Um gato doméstico - de barco naufragado ou não se sabe - aparece na ilha. Senta-se. Olha para o náufrago. O náufrago fica louco de alegria. | *"Um gato. Um GATO! Gatinho! És real? És real és real és real. Não me lixes. Fica. Fica aqui. Por favor."* |
| L18 | **Cápsulas do Tempo** | Encontra enterrada na areia uma caixinha metálica. Dentro está um objeto de outra pessoa - um naufrágio anterior. Há uma nota. | *"Alguém esteve aqui. Antes de mim. Saiu - ou não. A nota diz: 'Boa sorte ao próximo.' Sou o próximo."* |
| L19 | **O Farol** | À noite, vê uma luz pulsante ao longe que claramente é um farol. Nada onde os mapas dizem que não há nada. | *"Um farol. Significa terra. Significa porto. Significa que o meu mapa é falso ou que a realidade é mais generosa do que eu pensava."* |
| L20 | **Bilhete de Avião na Praia** | Uma carteira chega à praia. Dentro tem documentos, fotos de família - mas nenhum bilhete. O náufrago olha para as fotos durante muito tempo. | *"Uma família. Em Setúbal, pelo postal. Ficaram à espera também. Nós - os que ficam à espera dos que não voltam - entendemo-nos."* |
| L21 | **O Drone** | Um drone zumbe sobre a ilha. Tem câmara. O náufrago faz gestos desesperados para a câmara durante um minuto. O drone parte. | *"Alguém viu. Em algum ecrã. Alguém viu um pixel a agitar os braços. Pode ser suficiente."* |
| L22 | **Ressurreição da Fogueira** 🌙 | A fogueira que ele jurava estar apagada reaprende sozinha às 3 da manhã. O náufrago olha para ela. Ela crepita. Ele aceita. | *"...obrigado. Não sei a quem. Mas obrigado."* |
| L23 | **A Tartaruga Volta** | A mesma tartaruga de sempre volta à mesma rocha. O náufrago reconhece-a. Ela pousa o olho nele. Um momento de reconhecimento mútuo. | *"Tu és a mesma. Eu já não sou o mesmo. Mas ainda estamos aqui. Isso conta, não conta?"* |
| L24 | **Peixe Que Volta** | O peixe que sempre foge aparece na superfície perto dele. Fica à superfície. Não foge. Ficam os dois imóveis um longo momento. | *"Tu. És tu. O meu antagonista. O meu adversário eterno. Que fazes aqui? ...Obrigado por ficares."* |
| L25 | **Barco de Papel de Gigante** | Aparece à deriva um enorme barco de origami feito de plástico oceânico - arte instalação perdida no mar. O náufrago trepa para cima. | *"Sou o capitão. Do barco de papel. Que não vai a lado nenhum. É uma metáfora mais elegante do que merecia."* |
| L26 | **A Voz no Rádio** | O rádio partido liga-se por fracção de segundo e transmite uma voz humana real - duas palavras percebíveis. Apaga. Silêncio. | *"Disse... 'está bem'? Ou 'não sei'? Ou só estática com formato de voz? Não importa. Foi uma voz. Era humana. Foi suficiente."* |
| L27 | **Noite de São João** 🌙 | O náufrago descobre que é noite de São João (calculou). Salta fogueiras. Bate na cabeça da mascote com alho. Faz magia fiteira sozinho. | *"São João! SARDINHA! Oh. Não tenho sardinha. Tenho... peixinho. Não é a mesma coisa mas o espírito é o mesmo."* |
| L28 | **O Barco Que Vem Buscá-lo** | [Evento Especial] Um barco vem mesmo. Para mesmo. A pessoa vem mesmo. É o evento impossível. O náufrago fica imóvel durante segundos. Não acredita. | *"...é real? ...és real? Não fales. Só... fica aí parado. Deixa-me verificar. Deixa-me verificar que és real."* |
| L29 | **Mensagem de Futuro** 🌙 | Um meteoro cai perto da ilha com impacto mínimo. No fragmento há algo que parece um número de telefone escrito em metal. | *"Não tenho telefone. Tenho um número de telefone. É filosófico. É também completamente inútil. Guardo na mesma."* |
| L30 | **O Último Coco** | A palmeira dá o último coco. Fica uma palmeira sem fruto. O náufrago percebe. Segura o coco por um longo tempo. | *"O último. Não tenho de o comer hoje. Posso ficar a segurá-lo. Só por hoje. Para o sentir. É o derradeiro da palmeira e o derradeiro de muita coisa."* |

---

## 📊 Resumo e Estatísticas

| Categoria | Nº de Eventos | Frequência Sugerida | Peso Beehave |
|---|---|---|---|
| 🟢 COMUM | 70 | Várias vezes/dia | 100 |
| 🔵 RARO | 60 | 1-2x/semana | 15 |
| 🟠 MUITO_RARO | 50 | ~1x/mês | 3 |
| 🔴 LENDÁRIO | 30 | Pode nunca acontecer | 0.2 |
| **TOTAL** | **210** | - | - |

---

## 🎮 Notas de Implementação para Godot 4 + Beehave

### Condições de Desbloqueio Sugeridas

```
⚡ Requer: WeatherSystem.current == RAIN ou STORM
🌙 Requer: DayNightCycle.is_night == true  
☀️ Requer: DayNightCycle.is_day == true
Wilson* Requer: wilson_mascot.exists == true (criado em MR06)
```

### Frases e o LLM Ollama

As frases no catálogo são **seeds de prompt** - enviar ao `llama3.1:8b` como:

```python
prompt = f"""
És um náufrago numa ilha tropical minúscula. És cómico mas com alma.
Acabaste de: {event.description}
Diz algo em português de Portugal (1 frase curta, {event.tone}).
Inspirado em: "{event.seed_phrase}"
"""
```

### Progressão Emocional

Os eventos LENDÁRIOS têm **peso narrativo** - recomenda-se guardar em `save_data.json` quais já aconteceram para o LLM poder referenciar eventos passados em frases futuras.

```
"O Rui já se foi. Hoje estou sozinho outra vez." [pós L05]
"Já vi bioluminescência. O oceano guarda segredos bonitos." [pós L11]
```

---

---

## Eventos da Fogueira (Feature T-119/T-120/T-121)

Condicao de acesso: `CampfireObject` implementado (T-119) e comportamento de cozedura activo (T-120).

| # | Raridade | Nome Curto | Descricao | Frase do Naufrago |
|---|---|---|---|---|
| CF01 | COMUM | **Fogueira ao Anoitecer** | O naufrago recolhe lenha enquanto o ceu escurece, acende a fogueira sem ter peixe, senta-se a olhar para as chamas. Nao tem nada para assar -- e so pelo calor e pela companhia. | *"Nao e so para o peixe. E tambem para isso."* |
| CF02 | RARO | **A Fogueira Atrai Algo** | A fogueira arde de noite. Ao longe, um barco desacelera. As luzes do barco ficam paradas durante 30 segundos. Depois retomam o rumo. O naufrago fica de pe a olhar. | *"Viu-me. Tinha de ter visto. Ou entao... o que e que viram?"* |
| CF03 | MUITO_RARO | **O Vento Apaga a Fogueira** | Um golpe de vento repentino apaga a fogueira que o naufrago construiu com tanto cuidado. Ele fica immovel a olhar para o fumo que sobe. Suspira lentamente. Nao recomeça logo. | *"Claro. A natureza tem opiniao propria."* |
| CF04 | LENDARIO | **A Fogueira que Nao Apaga** | Por razoes desconhecidas (humidade, madeira seca, boa sorte), a fogueira arde a noite toda sem se apagar. De manha o naufrago acorda, ve as brasas ainda vivas, e fica de joelhos na areia com a cabeca baixa durante um momento. | *"Sobreviveu. Nos dois sobrevivemos."* |

Notas de condicao:
- CF01: `!blackboard["has_fish"] && DayNightCycle.is_night` (o naufrago acende por calor, nao por fome)
- CF02: `CampfireObject.is_lit && DayNightCycle.is_night` -- trigger raro num timer nocturno
- CF03: `CampfireObject.is_lit` -- trigger por WeatherService (brisa) ou evento aleatorio
- CF04: `CampfireObject.is_lit` durante toda a noite sem interrupcao -- verificar ao amanhecer

---

> *"A ilha ensina o que a cidade esqueceu: que o tempo é vasto, o oceano é paciente, e um coco por dia mantém o niilismo afastado. Quase."*
> - O Náufrago, dia sem número

[steer did not land - the subagent finished before it could be delivered: DECISÃO DE PRODUTO IMPORTANTE: O companheiro imaginário NÃO se chama Wilson (evitar referência ao Cast Away por razões legais e de originalidade). Nos eventos que envolvam companheiro imaginário:
- O OBJECTO é aleatório: coco, tábua à deriva, destroço, garrafa, pedaço de vela, capacete de borracha, bóia, pedra com cara pintada, etc.
- O NOME é aleatório e independente do objecto: William, Guilherme, Senhor Coco, Tabinho, Naufrito, Bóia, Tábua (nome próprio), Amigalhaço, Boiante, Senhor Destroço, etc.
- Inclui eventos específicos de: apresentar o companheiro a visitantes, o companheiro ser levado por uma onda e o náufrago ficar devastado, encontrar um novo objecto e começar uma nova amizade com entusiasmo, fingir que o novo é o mesmo que o antigo.
- Continua com a lista de 200+ eventos. Já incluíste esta nota, continua onde estavas.
DECISÃO DE PRODUTO - ARCOS NARRATIVOS: Os eventos NÃO são independentes e aleatórios. Organiza-os em ARCOS NARRATIVOS. Um arco é uma sequência de eventos com início, desenvolvimento e resolução, que pode durar horas ou dias. Podem existir vários arcos em paralelo ou sequenciais. Cada evento da tua lista deve pertencer a um arco (ou ser AVULSO se for genuinamente isolado).

Exemplos de arcos para estruturares a lista:

- **Arco "A Jangada"**: encontra madeira → dias a construir → cerimónia de lançamento → a jangada afunda imediatamente → devastação → volta ao início
- **Arco "O Companheiro"**: encontra objecto (coco/tábua/destroço) → dá-lhe nome → constrói amizade → o objecto desaparece com onda → luto → encontra novo objecto → recomeça (ou não)  
- **Arco "O Amor Perdido"**: avista sombra ao longe → tenta aproximar-se → ilusão desfaz-se → melancolia → recuperação
- **Arco "A Sinalização"**: decide fazer fogo de sinalização → reúne madeira → acende → fumo enorme → barco passa ao longe sem parar → desespero cómico
- **Arco "O Naufrágio"**: encontra destroço na praia → investiga → encontra pista sobre outros sobreviventes → mistério que nunca se resolve completamente
- **Arco "A Civilização Própria"**: começa a construir coisas → nomeia lugares da ilha → cria "leis" da ilha → "eleições" sozinho → discurso político para as gaivotas
- **Arco "O Diário"**: começa a riscar dias numa pedra → celebra aniversários de sobrevivência → esquece a conta → começa de novo
- **Arco "O Clima Extremo"**: nuves escuras → tempestade → danos na ilha → reconstrução → calma → gratidão exagerada

Para cada arco: nome, duração típica (horas/dias de tempo de jogo), lista de eventos que o compõem em ordem, e como termina (pode ter múltiplos finais). Um arco pode ser interrompido por outro e retomado depois. Alguns arcos são ÚNICOS (acontecem uma vez), outros são CÍCLICOS (o náufrago recomeça após o fim). Reestrutura a tua lista de 200+ eventos organizando-os por arco primeiro, depois avulsos. Responde em português de Portugal.]