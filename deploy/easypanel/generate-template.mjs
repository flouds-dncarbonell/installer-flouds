import { randomBytes } from "node:crypto";

const randomString = (length) =>
  randomBytes(length).toString("base64url").slice(0, length);

const appServiceName = process.env.FZAP_SERVICE_NAME || "fzap";
const databaseServiceName = `${appServiceName}-db`;
const databasePassword = randomString(24);
const adminToken = randomString(32);

const env = [
  "TZ=America/Sao_Paulo",
  `FZAP_LANGUAGE=${process.env.FZAP_LANGUAGE || "pt-BR"}`,
  "PUBLIC_BASE_URL=https://$(PRIMARY_DOMAIN)",
  "LOG_LEVEL=info",
  "LOG_CALLER=false",
  "GLOBAL_PROXY_URL=",
  "PASSKEY_EXTENSION_URL=",
  `CHATWOOT_SYSTEM_IDENTIFIER=${process.env.CHATWOOT_SYSTEM_IDENTIFIER || ""}`,
  `CHATWOOT_SYSTEM_NAME=${process.env.CHATWOOT_SYSTEM_NAME || ""}`,
  `CHATWOOT_PLATFORM_NAME=${process.env.CHATWOOT_PLATFORM_NAME || "Chatwoot"}`,
  `CHATWOOT_SERVICE_URL=${process.env.CHATWOOT_SERVICE_URL || ""}`,
  "CHATWOOT_GLOBAL_DB_HOST=",
  "CHATWOOT_GLOBAL_DB_PORT=5432",
  "CHATWOOT_GLOBAL_DB_NAME=",
  "CHATWOOT_GLOBAL_DB_USER=",
  "CHATWOOT_GLOBAL_DB_PASS=",
  `ADMIN_TOKEN=${adminToken}`,
  `FLOUDS_LICENCE_KEY=${process.env.FLOUDS_LICENCE_KEY || ""}`,
  `FLOUDS_LIFETIME_LICENCE_KEY=${process.env.FLOUDS_LIFETIME_LICENCE_KEY || ""}`,
  "DB_DRIVER=postgres",
  `DB_HOST=$(PROJECT_NAME)_${databaseServiceName}`,
  "DB_PORT=5432",
  "DB_NAME=$(PROJECT_NAME)",
  "DB_USER=postgres",
  `DB_PASSWORD=${databasePassword}`,
  `SESSION_DEVICE_NAME=${process.env.SESSION_DEVICE_NAME || "Fzap"}`,
  "WEBHOOK_FORMAT=json",
  "IMAGE_QUALITY_HD=false",
  "MAX_FILE_SIZE_MB=40",
  "DOWNLOAD_TIMEOUT_SECONDS=120",
  "MESSAGE_DELIVERY_TIMEOUT_SECONDS=30",
  "GLOBAL_S3_BUCKET=",
  "GLOBAL_S3_ACCESS_KEY=",
  "GLOBAL_S3_SECRET_KEY=",
  "GLOBAL_S3_ENDPOINT=",
  "GLOBAL_S3_REGION=",
  "GLOBAL_S3_PATH_STYLE=",
  "GLOBAL_S3_PUBLIC_URL=",
  "GLOBAL_S3_MEDIA_DELIVERY=both",
  "GLOBAL_S3_RETENTION_DAYS=",
  "TRANSCRIPTION_ENABLED=false",
  "TRANSCRIPTION_PROVIDER=openai",
  "TRANSCRIPTION_API_KEY=",
  "TRANSCRIPTION_MODEL=",
  "TRANSCRIPTION_BASE_URL=",
  "META_APP_ID=",
  "META_APP_SECRET=",
  "META_CONFIG_ID=",
  "RABBITMQ_ENABLED=false",
  "RABBITMQ_URL=",
  "RABBITMQ_EXCHANGE=fzap_events",
  "RABBITMQ_PREFIX=fzap",
  "RABBITMQ_FRAME_MAX=131072",
  "RABBITMQ_HEARTBEAT=30",
  "RABBITMQ_MAX_RECONNECT=10",
  "RABBITMQ_RECONNECT_DELAY=5",
  "RABBITMQ_MAX_DELIVERY_ATTEMPTS=5",
  "RABBITMQ_DLQ_TTL_HOURS=168",
  "RABBITMQ_DLQ_MAX_LENGTH=10000",
  "SENTRY_DSN=",
].join("\n");

const template = {
  services: [
    {
      type: "postgres",
      data: {
        serviceName: databaseServiceName,
        password: databasePassword,
        image: "pgvector/pgvector:pg17",
      },
    },
    {
      type: "app",
      data: {
        serviceName: appServiceName,
        source: {
          type: "image",
          image: "dncarbonell/fzap:latest",
        },
        domains: [
          {
            host: "$(EASYPANEL_DOMAIN)",
            port: 8080,
          },
        ],
        mounts: [
          {
            type: "volume",
            name: "app-dbdata",
            mountPath: "/app/dbdata",
          },
          {
            type: "volume",
            name: "files",
            mountPath: "/app/files",
          },
          {
            type: "volume",
            name: "logos",
            mountPath: "/app/data/public-folder-logos",
          },
        ],
        deploy: {
          replicas: 1,
          zeroDowntime: false,
        },
        env,
      },
    },
  ],
};

process.stdout.write(`${JSON.stringify(template, null, 2)}\n`);
