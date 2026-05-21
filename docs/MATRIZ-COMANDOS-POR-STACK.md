# Matriz de comandos por stack — UBU-ISO/3.0

Use esta matriz para definir os comandos canônicos do projeto durante adoção inicial ou verificação de conformidade.

| Stack | Instalar | Atualizar | Rodar | Testar | Buildar | Doctor |
|---|---|---|---|---|---|---|
| Node npm | `npm install` ou `npm ci` | `npm update` ou `git pull --ff-only` | `npm start` | `npm test` | `npm run build` | `npm run doctor` |
| Node pnpm | `pnpm install` | `pnpm update` | `pnpm start` | `pnpm test` | `pnpm build` | `pnpm doctor` |
| Python pip | `python -m pip install -e .` | `python -m pip install -U -e .` | `python -m pacote` | `python -m pytest` | `python -m build` | `python -m pacote doctor` |
| Python requirements | `python -m pip install -r requirements.txt` | `python -m pip install -U -r requirements.txt` | `python main.py` | `python -m pytest` | `python -m compileall .` | script próprio |
| PHP Composer | `composer install` | `composer update` com cautela | comando do projeto | `composer test` ou `phpunit` | não aplicável ou script | `composer validate` |
| Laravel | `composer install` | `composer install` após pull | `php artisan serve` | `php artisan test` | `npm run build`, se aplicável | `php artisan about` |
| Docker | `docker compose build` | `docker compose pull && docker compose build` | `docker compose up --build` | comando dentro do container | `docker compose build` | `docker compose config` |
| Debian apt | `sudo apt-get install -y ...` | `sudo apt-get update` | n/a | n/a | n/a | `apt-cache policy ...` |
| Arch pacman | `sudo pacman -Sy --needed ...` | `sudo pacman -Syu` com cautela | n/a | n/a | n/a | `pacman -Qi ...` |
| Windows BAT | `install.bat` | `run.bat` verifica update | `run.bat` | script interno | script interno | `doctor.bat` |

## Regra de prioridade

1. Use o gerenciador declarado por lockfile.
2. Se não houver lockfile, use o padrão mais comum da stack.
3. Se houver divergência entre README e arquivos reais, corrija a documentação ou os scripts.
4. Se não for possível suportar uma stack, registre exceção formal.
