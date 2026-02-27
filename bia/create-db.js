const { Client } = require('pg');
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");

exports.handler = async (event) => {
  const secretsClient = new SecretsManagerClient({ region: 'us-east-1' });
  
  const secretData = await secretsClient.send(
    new GetSecretValueCommand({ SecretId: process.env.DB_SECRET_ARN })
  );
  
  const secrets = JSON.parse(secretData.SecretString);
  
  const client = new Client({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: secrets.username,
    password: secrets.password,
    database: 'postgres',
    ssl: { rejectUnauthorized: false }
  });
  
  try {
    await client.connect();
    console.log('Conectado ao PostgreSQL');
    
    // Verifica se o banco já existe
    const checkDb = await client.query(
      "SELECT 1 FROM pg_database WHERE datname = 'bia'"
    );
    
    if (checkDb.rows.length === 0) {
      await client.query('CREATE DATABASE bia');
      console.log('Banco de dados "bia" criado com sucesso');
      return { statusCode: 200, body: 'Banco criado' };
    } else {
      console.log('Banco de dados "bia" já existe');
      return { statusCode: 200, body: 'Banco já existe' };
    }
  } catch (error) {
    console.error('Erro:', error);
    throw error;
  } finally {
    await client.end();
  }
};
