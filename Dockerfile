FROM nginx:stable-alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy site
COPY . /usr/share/nginx/html

# Add a simple health-check endpoint (optional)
# We'll ensure nginx serves index.html on /
HEALTHCHECK --interval=15s --timeout=5s --start-period=5s \
  CMD wget -qO- --spider http://localhost:80/ || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

