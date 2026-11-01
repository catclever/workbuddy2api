FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    && pip install --no-cache-dir git+https://github.com/hawklithm/workbuddy2api.git \
    && rm -rf /var/lib/apt/lists/*

COPY run_proxy.py /app/run_proxy.py
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh /app/run_proxy.py

ENV PYTHONUNBUFFERED=1 \
    HOST=0.0.0.0 \
    PORT=48787 \
    WORKBUDDY_GLOBAL=true \
    WORKBUDDY_DESENSITIZE=true

EXPOSE 48787

HEALTHCHECK --interval=15s --timeout=3s --retries=3 \
  CMD sh -c 'curl -sf http://localhost:${PORT:-48787}/health || exit 1'

ENTRYPOINT ["/app/entrypoint.sh"]
