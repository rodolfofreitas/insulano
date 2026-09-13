---
id: T-118
titulo: Companheiro imaginario -- objecto e nome aleatorios, ciclo de vida, luto
fase: 3
estado: pronto
tipo: visual
depende_de: [T-115, T-116]
---

## Objectivo

Quando SOLIDAO = 100, o naufrago encontra um objecto na praia, da-lhe um nome aleatorio
e forma uma amizade. O companheiro tem ciclo de vida (nascimento, desenvolvimento, morte
por onda) com reaccoes distintas do naufrago em cada fase.

## Ler antes

- `docs/needs-system.md` §2 (O Companheiro Imaginario)
- `docs/events-catalogue.md` -- eventos MR06 e seguintes

## Critérios de aceitação

- [ ] `game/world/companion.gd` com estado: sem_companheiro, nascimento, activo, luto
- [ ] Objecto aleatorio de lista em `game/data/companion_objects.json` (minimo 10 objectos)
- [ ] Nome aleatorio de lista em `game/data/companion_names.json` (minimo 12 nomes) -- nenhum e "Wilson"
- [ ] Combinacao nome+objecto guardada em `save.json`
- [ ] Animacao de baptismo: naufrago examina objecto, desenha cara, anuncia nome
- [ ] Animacao de morte: onda leva o objecto; 3 possiveis reaccoes aleatorias (devastado, filosofico, novo entusiasmo)
- [ ] Contexto do companheiro enviado ao LLMDirector (nome, objecto, estado)
- [ ] Testes GUT: seleccao aleatoria sem repeticao de nome na mesma sessao, ciclo de estados

## Fora de âmbito

- Apresentar o companheiro a visitantes (entra com arcos de visitantes)
- Companheiro como personagem visual independente com sprite proprio (v1.x -- e so referenciado em frases)

## Prova exigida

- Screenshot do naufrago com o companheiro referenciado num balao de fala
- Teste GUT: "Wilson" nao pode aparecer na lista de nomes
