# limas-docker

Welcome to a docker repository for [Limas](https://github.com/Lopo/Limas), a [Partkeepr](https://github.com/partkeepr/PartKeepr) rewrite.
It's an inventory system for smaller, mostly electrical build-parts, like resistors etc.



## Manual Build (inside docker folder)
`docker build -t local-limas-build .`

## Docker Usage

Run the image with: `docker run --name limas -p 8080:80 -v "./data:/var/www/html/data" -e "APP_ENV=prod" -e "DATABASE_URL=mysql://username:password@mysql_host:3306/database-name?serverVersion=8.4.6&charset=utf8mb4" n404/limas-docker`

On the first start an admin user with `admin@example.com` and `admin` will be created, as well as the database migrations, which run on every start.

A docker-compose example can be found in the `examples/docker-compose.yml` file.

Start the stack with `docker compose up -d` (inside the example folder, if you downloaded the whole folder).

Connect to the application via `http://localhost:8080` (or the corresponding hostname of your server)

To add SSL, you need a reverse proxy with SSL configured, like traefik. (Example will follow)

All Environment variables with their default values:

| Environment variable name | default value                                                              |
|---------------------------|----------------------------------------------------------------------------|
| REDIS_DSN                 | `redis://redis`                                                            |
| APP_ENV                   | `prod` (can only be set to `dev` or `prod`)                                |
| APP_SECRET                | _empty_                                                                    |
| DATABASE_URL              | `mysql://limas:limas@mysql:3306/limas?serverVersion=8.4.6&charset=utf8mb4` |
| NEXAR_ID                  | `client`                                                                   |
| NEXAR_SECRET              | `secret`                                                                   |
| NEXAR_COUNTRY             | `DE`                                                                       |
| NEXAR_CURRENCY            | `EUR`                                                                      |