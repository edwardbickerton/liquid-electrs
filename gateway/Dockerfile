FROM nginx:1.27-alpine

RUN apk add --no-cache gettext

COPY entrypoint.sh /entrypoint.sh
COPY nginx.conf.template /templates/nginx.conf.template
COPY index.html.template /templates/index.html.template

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

