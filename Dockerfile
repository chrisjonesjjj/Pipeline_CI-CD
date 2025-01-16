# Étape 1 : Construction
FROM node:22-alpine3.19 AS builder

# Définir le répertoire de travail
WORKDIR /app

# Copier d'abord le .env
COPY .env .env

# Copier les fichiers package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm install --frozen-lockfile

# Copier le reste de l'application
COPY . .

RUN npx prisma generate

# Construire l'application
RUN npm run build

# Étape 2 : Production
FROM node:22-alpine3.19 AS production

# Définir le répertoire de travail
WORKDIR /app

# Définir l'environnement principal
ENV NODE_ENV=production

# Copier le fichier package.json nécessaire pour npm start
COPY --from=builder /app/package.json ./

# Copier les fichiers construits depuis l'étape de construction
COPY --from=builder /app/next.config.js .
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/.env ./.env

# Exposer le port
EXPOSE 3000

# Démarrer l'application
CMD ["npm", "start"]