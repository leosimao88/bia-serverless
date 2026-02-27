const express = require("express");
var cors = require("cors");
var path = require("path");
const config = require("config");
var bodyParser = require("body-parser");

module.exports = () => {
  const app = express();

  // SETANDO VARIÁVEIS DA APLICAÇÃO
  app.set("port", process.env.PORT || config.get("server.port"));

  //Setando react
  app.use(express.static(path.join(__dirname, "../", "client", "build")));

  // parse request bodies (req.body)
  app.use(express.urlencoded({ extended: true }));
  app.use(bodyParser.json());

  app.use(cors());

  app.get('/ping', (req, res) => res.json({ status: 'ok' }));

  require("../api/routes/tarefas")(app);
  require("../api/routes/versao")(app);

  // Fallback para React Router - serve index.html apenas para rotas não-API
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api')) {
      return next(); // Deixa o Express retornar 404 para rotas API não encontradas
    }
    res.sendFile(path.join(__dirname, "../", "client", "build", "index.html"));
  });

  return app;
};
