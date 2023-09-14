# Multi-stage build : optimisation de l'image finale
# 1. INSTALLATION DES DEPENDANCES | build stage
# Runtime officiel Node.js comme image
FROM node:14-alpine
# Déterminer le working directory sur /app
WORKDIR /app
# Copie du package.json and package-lock.json dans le conteneur
COPY package*.json ./
# Installer les dépendances             
RUN npm install \
    # Installation de Babel et de ses plugins associés pour transpiler le code JSX en js
    && npm install --save-dev @babel/core @babel/preset-env @babel/preset-react babel-loader \
    # Installation de Webpack et de ses plugins associés pour compiler le code JSX et le bundler dans un seul fichier
    # webpack.config.js dans le root directory, avec le Dockerfile
    && npm install --save-dev webpack webpack-cli \
    # Installation de ReactDOM pour l'affichage des composants React dans le DOM
    && npm install --save react react-dom
# Copie des fichiers de l'application dans le conteneur
COPY . .
# Build de l'application
RUN npm run build
# 2. COPIE DU BUILD DIRECTORY A PARTIR DU BUILD STAGE
# L'image finale ne contient que les fichiers statiques compilés sans les dépendances
# de développement installées dans la première étape
# Runtime officiel Nginx comme image
FROM nginx:alpine
# Copie des fichiers de l'application buildés dans le conteneur
COPY --from=0 /app/build /usr/share/nginx/html
# Exposition du port
EXPOSE 80
# Lancement de Nginx
CMD ["nginx", "-g", "daemon off;"]
