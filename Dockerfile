FROM savonet/liquidsoap:v2.3.3

# All ENV variables are now set with defaults in entrypoint.sh
# This follows the same pattern as the icecast service

USER root

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY stream.liq entrypoint.sh ./

RUN chmod +x entrypoint.sh && \
    chown -R liquidsoap:liquidsoap /app

USER liquidsoap

EXPOSE 8001 1234

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/app/stream.liq"]
