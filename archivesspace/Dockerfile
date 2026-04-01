# Dockerfile for ArchivesSpace v2.6.0
# Since no official Docker image exists on Docker Hub for v2.6.0,
# this builds from the GitHub release zip file.

FROM eclipse-temurin:8-jre

LABEL maintainer="UIUC Library"
LABEL description="ArchivesSpace v2.6.0 for local testing"

ENV ARCHIVESSPACE_VERSION=v2.6.0 \
    ARCHIVESSPACE_LOGS=/dev/null \
    LANG=C.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        ca-certificates \
        wget \
        unzip \
        netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Download and install ArchivesSpace v2.6.0 from GitHub releases
RUN cd /tmp && \
    wget -q https://github.com/archivesspace/archivesspace/releases/download/v2.6.0/archivesspace-v2.6.0.zip && \
    unzip -q archivesspace-v2.6.0.zip -d / && \
    rm archivesspace-v2.6.0.zip

# Download MySQL connector (required for MySQL support)
RUN wget -q https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.39/mysql-connector-java-5.1.39.jar \
    -O /archivesspace/lib/mysql-connector-java-5.1.39.jar

# Copy startup script
COPY docker-startup.sh /archivesspace/startup.sh
RUN chmod +x /archivesspace/startup.sh

# Create archivesspace user (use different GID to avoid conflict)
RUN groupadd -g 1001 archivesspace && \
    useradd -l -M -u 1001 -g archivesspace archivesspace && \
    chown -R archivesspace:archivesspace /archivesspace

USER archivesspace

EXPOSE 8080 8081 8089 8090

HEALTHCHECK --interval=1m --timeout=5s --start-period=5m --retries=2 \
  CMD wget -q --spider http://localhost:8089/ || exit 1

CMD ["/archivesspace/startup.sh"]
