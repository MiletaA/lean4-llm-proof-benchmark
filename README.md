# Lean 4 LLM Proof Benchmark

Ispitujemo da li lokalni jezički modeli mogu da napišu Lean 4 dokaze koji
prolaze proveru. Osam modela rešava dve teoreme o sabiranju prirodnih brojeva
kroz jednokratni i agentni protokol. Repozitorijum sadrži zadatke, upit,
skripte i sačuvane izlaze potrebne za proveru i novo pokretanje eksperimenta.

[Seminarski rad u PDF formatu](docs/Petar_Maletin_Mileta_Avramovic_Napredme_Metode.pdf)
opisuje metodologiju i rezultate.

## Zadaci i protokoli

Obe grupe modela rešavaju iste zadatke.

| Zadatak | Iskaz za prirodne brojeve | Ime teoreme u kodu |
| --- | --- | --- |
| Asocijativnost | `(a + b) + c = a + (b + c)` | `add_assoc_test` |
| Komutativnost | `a + b = b + a` | `add_comm_test` |

- **Jednokratni protokol** šalje jedan upit po paru model–teorema preko
  Ollama interfejsa `/api/generate`, uz `temperature=0` i `num_ctx=4096`.
- **Agentni protokol** koristi `ulam prove`. Lean proverava odgovor, a Ulam
  vraća grešku modelu za narednu rundu. Svaki par ima tri odvojena pokušaja,
  sa najviše četiri runde po pokušaju. Uzorkovanje koristi Ulam/Ollama
  podrazumevana podešavanja.

`verify.py` proverava da fajl sadrži očekivani iskaz i da nema `sorry` ni
`admit`, zatim pokreće `lake env lean`. Konačna presuda uključuje rezultat
kompilacije ili prekoračenje vremena. Početni zadaci u `leanproj/tasks/`
sadrže `sorry`, koje model treba da zameni dokazom.

## Zabeleženi rezultati

U jednokratnim kolonama „prolaz“ označava dokaz koji je prošao proveru.
Agentne kolone prikazuju broj uspeha od tri pokušaja za svaku teoremu.

| Model | Jednokratno asoc. | Jednokratno kom. | Agentno asoc. | Agentno kom. |
| --- | --- | --- | ---: | ---: |
| Gemma 3 4B | pad | pad | 0/3 | 1/3 |
| Gemma 3 12B | pad | pad | 0/3 | 0/3 |
| GLM-4 9B | pad | prolaz | 0/3 | 0/3 |
| GLM-4.7-Flash | prolaz | prolaz | 3/3 | 3/3 |
| Qwen2.5-Coder 14B | prolaz | pad | 2/3 | 1/3 |
| Qwen3 | prolaz | pad | 1/3 | 0/3 |
| DeepSeek-Coder-V2 16B | prolaz | prolaz | 0/3 | 0/3 |
| DeepSeek-R1 8B | pad | pad | 3/3 | 0/3 |
| **Ukupno** | **4/8** | **3/8** | **9/24** | **5/24** |

Ukupno je prošlo **7/16 jednokratnih dokaza** i **14/48 agentnih pokušaja**.
Oba protokola rešila su po **7/16 parova model–teorema** bar jednom, uz
različit broj pokušaja. U Qwen/DeepSeek logovima tri uspešna pokušaja imaju
popravku u drugoj rundi. U Gemma/GLM seriji svih sedam uspeha postignuto je
u prvoj rundi. Test obuhvata samo dve teoreme sa gotovim Mathlib lemama.

Izvorne tabele dostupne su uz rezultate svake serije.

| Grupa | Jednokratne presude | Agentni pokušaji |
| --- | --- | --- |
| Gemma i GLM | [verdicts.json](results/single-shot/gemma-glm/verdicts.json) | [attempts.csv](results/agentic/gemma-glm/attempts.csv) |
| Qwen i DeepSeek | [verdicts.json](results/single-shot/qwen-deepseek/verdicts.json) | [attempts.csv](results/agentic/qwen-deepseek/attempts.csv) |

Kod DeepSeek-R1 komutativnosti jednokratni fajl sadrži `-- no output`.
Oznaka `failed(wrong-statement)` u njegovoj tabeli beleži odsustvo
zadatog iskaza u izlazu.

## Struktura repozitorijuma

```text
leanproj/
  lean-toolchain             # Lean 4.31.0
  lakefile.toml              # Mathlib v4.31.0
  LeanProj.lean
  tasks/                     # Dve teoreme i šablon upita
scripts/
  reproduce_benchmark.sh      # Novo pokretanje modela i ocenjivanje
  verify.py                  # Provera sačuvanih Lean fajlova
results/
  single-shot/
    gemma-glm/               # proofs/, raw/, verdicts.json
    qwen-deepseek/           # proofs/, verdicts.json
  agentic/
    gemma-glm/               # proofs/, logs/, attempts.csv
    qwen-deepseek/           # proofs/, logs/, attempts.csv
docs/
  Petar_Maletin_Mileta_Avramovic_Napredme_Metode.pdf
requirements.txt             # Fiksirana revizija Ulam AI-ja
```

Imena agentnih fajlova sadrže oznake `r1`, `r2` i `r3` za odvojene
pokušaje. Runde popravke unutar pokušaja vide se u logu. Nazivi kolona
u dve agentne tabele prate originalne skripte. Gemma/GLM tabela ima i
`rounds_used`. Potpuni sirovi jednokratni odgovori sa metapodacima
sačuvani su u `results/single-shot/gemma-glm/raw/`.

## Priprema okruženja

Za proveru sačuvanih dokaza potrebni su Git, `curl`, Python 3 i Lean/Lake
preko Elan-a. Za novo agentno pokretanje koristite **Python 3.10 ili noviji**,
Bash, pokrenutu Ollama i Ulam AI iz `requirements.txt`.

Za početno postavljanje ostavite približno **12 GiB slobodnog prostora**
za Lean/Mathlib projekat. Težine modela traže dodatni prostor. Memorijski
zahtevi zavise od modela. Izvorna Gemma/GLM serija pokrenuta je na Mac mini
M4 sa 24 GB memorije, a Qwen/DeepSeek na MacBook Pro M2 Max sa 32 GB.
Postupak je testiran na macOS-u. Korišćeni alati imaju Linux podršku.

Klonirajte projekat i sve naredne komande pokrećite iz korena klona.

```bash
git clone https://github.com/MiletaA/lean4-llm-proof-benchmark.git
cd lean4-llm-proof-benchmark
```

Ako Elan još nije instaliran, pratite [Lean uputstvo](https://lean-lang.org/install/manual/).
Nakon instalacije proverite dostupnost alata.

```bash
export PATH="$HOME/.elan/bin:$PATH"
python3 --version
lake --version
```

Pripremite fiksirane Lean/Mathlib zavisnosti. Prvi korak preuzima izvore,
a naredni raspakuje prekompajlirani keš. U zagradi se menja direktorijum
samo za te komande.

```bash
(
  set -eu
  cd leanproj
  MATHLIB_NO_CACHE_ON_UPDATE=1 lake update
  lake exe cache get
  lake build Mathlib
)
```

Za novo pokretanje modela instalirajte [Ollama](https://docs.ollama.com/quickstart)
i pokrenite njen lokalni server. Na Linuxu pratite [Ollama Linux uputstvo](https://docs.ollama.com/linux).
Ako servis već radi, novi `ollama serve` nije potreban.

```bash
ollama serve
```

U drugom terminalu, iz korena klona, pripremite Python okruženje.

```bash
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt
ulam --help
ollama list
```

`requirements.txt` fiksira Ulam na reviziju koja odgovara dokumentovanom
Gemma/GLM okruženju, verziji 0.2.11. Izvorni Petrovi logovi ne sadrže tačnu
Ulam reviziju. Elan/Lean i Ollama instaliraju se zasebno. Python okruženje
i Mathlib build nastaju lokalno i pokriveni su `.gitignore` pravilima.

## Ponovna provera sačuvanih dokaza

Posle pripreme Lean projekta pokrenite sledeći blok. On pravi nove JSON
presude u privremenom folderu i ispisuje njegovu putanju.

```bash
(
  set -eu
  check_dir="$(mktemp -d)"
  for protocol in single-shot agentic; do
    for group in gemma-glm qwen-deepseek; do
      python3 scripts/verify.py \
        "results/$protocol/$group/proofs" \
        "$check_dir/$protocol-$group.json" \
        --project leanproj
    done
  done
  printf 'Nove presude: %s\n' "$check_dir"
)
```

Samostalni verifikator ima ograničenje od 600 sekundi po fajlu. Sačuvani
CSV i logovi beleže originalne ishode tokom Ulam pokretanja. Naknadna
kompilacija konačnog fajla može dati drugačiju presudu ako je prvobitni
pokušaj istekao ili je njegov sadržaj menjan tokom neuspešnih rundi.

## Novo pokretanje eksperimenta

Aktivirajte `.venv`, pokrenite Ollama i preuzmite modele koje želite da
testirate. Sledeća kratka proba radi jedan jednokratni i jedan agentni
pokušaj po teoremi, na modelu Gemma 3 4B.

```bash
ollama pull gemma3:4b
K=1 PROMPT_VARIANT=gemma-glm VERIFY_TIMEOUT=600 \
  bash scripts/reproduce_benchmark.sh gemma3:4b
```

Za kompletnu Gemma/GLM seriju koristite sledeće oznake modela i varijantu
originalnog upita. `VERIFY_TIMEOUT=600` prati originalnu samostalnu proveru
te serije. Agentna Lean provera ostaje na 300 sekundi.

```bash
(
  set -eu
  models=(gemma3:4b gemma3:12b glm4:9b glm-4.7-flash:latest)
  for model in "${models[@]}"; do
    ollama pull "$model"
  done
  PROMPT_VARIANT=gemma-glm VERIFY_TIMEOUT=600 \
    bash scripts/reproduce_benchmark.sh "${models[@]}"
)
```

Za kompletnu Qwen/DeepSeek seriju koristite sledeći blok.

```bash
(
  set -eu
  models=(deepseek-coder-v2:16b qwen2.5-coder:14b deepseek-r1:8b qwen3:latest)
  for model in "${models[@]}"; do
    ollama pull "$model"
  done
  PROMPT_VARIANT=qwen-deepseek \
    bash scripts/reproduce_benchmark.sh "${models[@]}"
)
```

Skripta za svako pokretanje podrazumevano pravi svež privremeni radni
folder. Njegova putanja piše u izlazu. Ako želite da izaberete mesto,
prosledite `WORKDIR` sa novom putanjom. Skripta odbija već postojeći
podfolder `out/`.

| Podešavanje | Podrazumevana vrednost | Značenje |
| --- | --- | --- |
| `K` | `3` | Odvojeni agentni pokušaji po paru model–teorema |
| `LLM_ROUNDS` | `4` | Najveći broj rundi u jednom pokušaju |
| `GEN_TIMEOUT` | `1800` | Sekunde po jednokratnom Ollama zahtevu |
| `TYPECHECK_TIMEOUT` | `300` | Sekunde po Lean proveri u agentnoj rundi |
| `VERIFY_TIMEOUT` | `TYPECHECK_TIMEOUT` | Sekunde po jednokratnoj Lean proveri u glavnoj skripti |
| `PROMPT_VARIANT` | `qwen-deepseek` | Izvorna formulacija upita za odabranu seriju |
| `SINGLE_SHOT_ONLY` | `0` | Sa `1` pokreće samo jednokratni protokol |
| `OLLAMA_URL` | `http://localhost:11434` | Adresa lokalnog Ollama servera |
| `ULAM_BIN` | `ulam` | Komanda ili puna putanja do Ulama |

`GEN_TIMEOUT` važi za jednokratni zahtev, a `TYPECHECK_TIMEOUT` za
pojedinačnu Lean proveru. Agentni pokušaj može ukupno trajati duže od tih
ograničenja jer sadrži generisanje i više rundi.

Izlaz novog pokretanja sadrži sledeće fajlove.

```text
out/
  ss_*.lean          # Jednokratni odgovori
  singleshot.json    # Njihove presude
  ag_*_r*.lean       # Konačni agentni odgovori po pokušaju
  ag_*_r*.log        # Tok rundi i Lean greške
  agentic.csv        # Agentni ishodi i vremena
  ulam_config.json  # Vremensko ograničenje agentne Lean provere
```

U režimu `SINGLE_SHOT_ONLY=1` nastaju jednokratni izlazi i `singleshot.json`.

Modele u sačuvanim rezultatima identifikuju Ollama oznake korišćene u eksperimentu.
Oznake poput `latest` mogu se promeniti. Pri novom pokretanju zabeležite
verzije alata, identifikatore modela iz `ollama list` i komandu pokretanja.
Agentno uzorkovanje, druga verzija težina i drugačiji hardver mogu dati
različite odgovore i trajanja. Cilj ponavljanja je proveriti postupak i
izmeriti novu seriju pod zabeleženim uslovima.

## Doprinosi

| Autor | Doprinos |
| --- | --- |
| Mileta Avramović | Gemma/GLM eksperimenti, Lean projekat, skripta za reprodukciju i objedinjena analiza |
| Petar Maletin | Qwen/DeepSeek eksperimenti, verifikator i Python zavisnost za agentni protokol |

## Ako pokretanje stane

| Poruka ili problem | Provera |
| --- | --- |
| `scripts/verify.py is required` | Povucite kompletan repozitorijum sa verifikatorom. |
| `lake is required` ili `lake: command not found` | Instalirajte Elan i dodajte `$HOME/.elan/bin` u `PATH`. |
| `ulam is required` | Aktivirajte `.venv` i instalirajte `requirements.txt`, ili izaberite `SINGLE_SHOT_ONLY=1`. |
| `Ollama is not reachable` | Proverite Ollama servis i `OLLAMA_URL`. |
| Model nije pronađen | Uradite `ollama pull` za tačnu oznaku modela. |
| `No space left on device` | Obezbedite prostor za Mathlib i preuzete modele. |
| `choose a WORKDIR without an existing out directory` | Izaberite novu putanju ili pustite skriptu da napravi privremenu. |

Zavisnosti projekta su [Lean](https://lean-lang.org/),
[Mathlib](https://github.com/leanprover-community/mathlib4),
[Ollama](https://ollama.com/) i [Ulam AI](https://github.com/ulamai/ulamai).
