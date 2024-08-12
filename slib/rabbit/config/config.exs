import Config

config :rabbit, Rabbit.Repo,
  database: "slib_rabbit_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :rabbit,
  ecto_repos: [Rabbit.Repo]

config :rabbit, Rabbit.Vault,
  ciphers: [
    default:
      {Cloak.Ciphers.AES.GCM,
       tag: "AES.GCM.V1",
       key:
         Base.decode64!(
           System.get_env("CLOAK_KEY") ||
             "C/EKczaPvY7Zk+QKZaFzTYw3zbSgveJoTkLJQGxMS9E="
         )}
  ]
