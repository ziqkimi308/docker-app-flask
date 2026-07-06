# STAGE 1 - Builder
FROM python:3.11-slim AS builder

# new workspace
WORKDIR /build

# Defensive default. In case future dependancy needs to compile C code.
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# final product is in /final
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# STAGE 2 - Final Image
FROM python:3.11-slim AS final

# dumb-init is a tiny program is used to intentionally be the very first process PID 1 inside the container.
# So that your actual app runs as a child of dumb-init, not as PID 1.
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init && rm -rf /var/lib/apt/lists/*

# We don't want to use root user to run this, so create new user and group with home dir and custom id 1001
RUN useradd -m -u 1001 appuser

# new workspace
WORKDIR /app

COPY --from=builder /install /usr/local

COPY app.py .

RUN chown -R appuser:appuser /app

# switch user
USER appuser

EXPOSE 5000

# Ensure dumb-init execute first, then web app as child
# CMD does not execute during build unlike RUN. It executes later when run 'docker run image-name'
ENTRYPOINT [ "dumb-init", "--" ]
CMD [ "python", "app.py" ]