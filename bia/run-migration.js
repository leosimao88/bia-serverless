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
    database: 'bia',
    ssl: { rejectUnauthorized: false }
  });
  
  try {
    await client.connect();
    console.log('Conectado ao banco bia');
    
    // Cria a tabela Tarefas
    await client.query(`
      CREATE TABLE IF NOT EXISTS "Tarefas" (
        uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        titulo VARCHAR(255) NOT NULL,
        dia_atividade VARCHAR(255),
        importante BOOLEAN DEFAULT false,
        "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);
    
    console.log('Tabela Tarefas criada com sucesso');
    return { statusCode: 200, body: 'Migration executada' };
  } catch (error) {
    console.error('Erro:', error);
    throw error;
  } finally {
    await client.end();
  }
};
