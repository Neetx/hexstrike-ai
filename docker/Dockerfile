# syntax=docker/dockerfile:1

FROM kalilinux/kali-last-release

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    HEXSTRIKE_HOST=0.0.0.0 \
    HEXSTRIKE_PORT=8888

WORKDIR /app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      dnsutils \
      file \
      git \
      iproute2 \
      iputils-ping \
      net-tools \
      netcat-openbsd \
      procps \
      python3 \
      python3-pip \
      python3-psutil \
      python3-setuptools \
      python3-venv \
      python3-wheel \
      tini \
      vim-common \
      wget \
    && rm -rf /var/lib/apt/lists/*

COPY docker/requirements-server.txt /tmp/requirements-server.txt
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements-server.txt

# Toolset options:
# - core: strictly installs essentials and best-effort installs common tools.
# - full: also attempts heavier or less stable packages.
# - none: Python server runtime only; /health will report missing tools.
ARG HEXSTRIKE_TOOLSET=core

RUN if [[ "${HEXSTRIKE_TOOLSET}" != "none" ]]; then \
      set -eux; \
      apt-get update; \
      apt-get install -y --no-install-recommends \
        binutils \
        dirb \
        dnsenum \
        ffuf \
        feroxbuster \
        gobuster \
        hashcat \
        hydra \
        john \
        nmap \
        nikto \
        sqlmap; \
      optional_core=( \
        amass arjun arp-scan binwalk checksec chromium chromium-driver dalfox \
        dirsearch dnsenum feroxbuster ffuf fierce libimage-exiftool-perl \
        masscan nuclei responder rustscan smbmap subfinder tcpdump testssl.sh \
        trivy wafw00f whatweb wordlists wpscan \
      ); \
      for pkg in "${optional_core[@]}"; do \
        apt-get install -y --no-install-recommends "$pkg" || echo "Optional Kali package unavailable: $pkg"; \
      done; \
      if [[ "${HEXSTRIKE_TOOLSET}" == "full" ]]; then \
        optional_full=( \
          aircrack-ng autorecon bulk-extractor exploitdb foremost ghidra \
          hash-identifier httpie jaeles medusa metasploit-framework nbtscan \
          netexec one-gadget ophcrack patator python3-angr python3-pwntools \
          radare2 ropgadget ropper scalpel steghide testdisk volatility3 wfuzz \
          xsser zaproxy \
        ); \
        for pkg in "${optional_full[@]}"; do \
          apt-get install -y --no-install-recommends "$pkg" || echo "Optional Kali package unavailable: $pkg"; \
        done; \
      fi; \
      if command -v httpx-toolkit >/dev/null 2>&1 && ! command -v httpx >/dev/null 2>&1; then \
        ln -s "$(command -v httpx-toolkit)" /usr/local/bin/httpx; \
      fi; \
      rm -rf /var/lib/apt/lists/*; \
    fi

COPY . /app
RUN chmod +x /app/docker/entrypoint.sh

EXPOSE 8888

HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
  CMD curl -fsS "http://127.0.0.1:${HEXSTRIKE_PORT}/health" >/dev/null || exit 1

ENTRYPOINT ["/usr/bin/tini", "--", "/app/docker/entrypoint.sh"]
CMD ["server"]
