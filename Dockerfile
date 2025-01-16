# Étape 1 : Construction
FROM node:22-alpine3.19 AS builder

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm ci

# Copier le reste des fichiers, y compris .env
COPY . .

# Générer le client Prisma
RUN npx prisma generate

# Construire l'application
RUN npm run build

# Étape 2 : Production
FROM node:22-alpine3.19 AS production

# Définir le répertoire de travail
WORKDIR /app

# Définir l'environnement principal
ENV NODE_ENV=production

# Copier les fichiers nécessaires depuis l'étape de construction
COPY --from=builder /app/package.json ./
COPY --from=builder /app/next.config.js .
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.env ./.env
COPY --from=builder /app/prisma ./prisma

# Exposer le port
EXPOSE 3000

# Démarrer l'application
CMD ["npm", "start"]